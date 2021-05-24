#!/usr/bin/env python3

from datetime import datetime, timezone
from os import path as pathlib
from pathlib import Path
from types import SimpleNamespace
import atexit
import filecmp
import importlib
import json
import os
import platform
import stat
import subprocess
import sys

import jinja2

from common import open_utf8
import common
import list

home_base_path = pathlib.expanduser("~")
scriptpath = os.path.dirname(__file__)
__log_cache = []

class JinjaGlobalsModule(object):
    """ Wrapper around a py-module used to pass to Jinja as context """
    def __init__(self, module):
        self.module = module

    def __iter__(self):
        for key, val in self.module.__dict__.items():
            if key.startswith("_"):
                continue
            yield (key, val)

    def __getitem__(self, key):
        return getattr(self.module, key)

    def __getattr__(self, attr):
        return getattr(self.module, attr)

def log_syschange(did, undo):
    """ Log do/undo shell commands to a file as to what this script changes on the system - best effort """
    global __log_cache
    now_iso_8601 = datetime.now(timezone.utc).astimezone().isoformat()

    __log_cache.append(json.dumps({
        "time": now_iso_8601,
        "did": did,
        "undo": undo,
    })+"\n")

def log_syschange_write():
    """ We don't write logs immediately in order to reverse them at the end, so that .undo fields can be dumped/applied without thought """
    global __log_cache
    if len(__log_cache) < 1:
        return

    now_posix = datetime.now().timestamp()
    __log_cache.reverse() # it's important to apply undos in reverse order
    with open(f"{scriptpath}/syschange_{now_posix}.log", "w") as f:
        f.writelines(__log_cache)
atexit.register(log_syschange_write)

def load_ignore_file():
    result = ["./.dotignore",
            "./bootstrap.py",
            "./build",
            "./__pycache__",

            "./config.py",
            "./config_example.py",
            "./requirements.txt"]

    with open_utf8("./.dotignore", "r") as f:
        for ignore_re in f:
            if ignore_re:
                result.append("./"+ignore_re.rstrip())

    return tuple(result)

def backup_file(file_path):
    """ Renames file at path passed into something like {}.bk0 """
    COUNT_MAX_BACKUPS = 9
    for bak_file_path in ("{}.bk{}".format(file_path, i) for i in range(0, COUNT_MAX_BACKUPS)):
        if not pathlib.exists(bak_file_path):
            os.rename(file_path, bak_file_path)
            log_syschange(f"mv \"{file_path}\" \"{bak_file_path}\"", f"mv \"{bak_file_path}\" \"{file_path}\"")
            return

    raise Exception("reached maximal number ({}) of allowed backups for file {}".format(COUNT_MAX_BACKUPS, file_path))

def home_path_equivalent(repo_path, file_path):
    return home_base_path + pathlib.realpath(file_path).replace(repo_path, "")

def is_already_linked(source_path, target_path):
    """ Checks if file inside the repo is already linked from the outside """
    if common.isWindows:
        # assumes cygwin
        return pathlib.realpath(source_path) == pathlib.realpath(
            common.sh_cygpath(
                common.sh_realpath(target_path)
            )
        )

    return pathlib.realpath(source_path) == pathlib.realpath(target_path)

def jinja_paths(repo_path, raw_source_path, raw_target_path):
    template_path = pathlib.realpath(raw_source_path).replace(repo_path, "")

    source_path = pathlib.join( repo_path, "build" ) + \
                  pathlib.realpath(raw_source_path).replace(repo_path, "")
    source_path = pathlib.splitext(source_path)[0]

    source_path_bk = source_path+".bk"

    target_path = raw_target_path

    # !!! in the case that the file doesnt exist and we have to link it,
    # the target path will have the .j2 filename if we dont do this below
    if pathlib.splitext(raw_target_path)[1] == ".j2":
        target_path = repo_path + \
                pathlib.realpath(raw_source_path).replace(repo_path, "")
        target_path = pathlib.splitext(target_path)[0]
        target_path = home_path_equivalent(repo_path, target_path)

    return SimpleNamespace(
        template_path = template_path,
        source_path = source_path,
        source_path_bk = source_path_bk,
        target_path = target_path
    )

def render_jinja_template(config, paths, backup=False):

    def include_if_exists(path):
        path = common.expand_path(path)

        if not pathlib.isfile(path):
            return "" # TODO still creates an empty line

        with open_utf8(path) as f:
            content = f.read()
        return content.rstrip() # remove trailing newline

    env = jinja2.Environment(
        loader = jinja2.FileSystemLoader("."),
        autoescape    = False,
        trim_blocks   = True,
        lstrip_blocks = True,

        # custom delimiters ( {{ conflicts with default vim-folds {{{ )
        variable_start_string = "»",
        variable_end_string   = "«",
    )

    p = paths
    assert pathlib.splitext(p.template_path)[1] == ".j2"

    output = env.get_template(Path(p.template_path).as_posix()).render(
            config,
            include_if_exists=include_if_exists,
            proj_dir=common.proj_dir,
            isLinux=common.isLinux,
            isArchLinux=common.isArchLinux,
            isWindows=common.isWindows,
            )

    os.makedirs(pathlib.split(p.source_path)[0], exist_ok=True)
    with open_utf8(p.source_path, "w") as f:
        f.write(output)

    if backup:
        with open_utf8(p.source_path_bk, "w") as f:
            f.write(output)

def resolve_sources_list(sources):
    """
    Sources map from local file-paths to either a global string/path or
    another dict that defines them per os, this func resolves the dict
    ones for the current os
    """

    # filter out all all sources that don't match my os
    sources = { k: v for (k,v) in sources.items()
                if not (isinstance(v, dict) and not common.get_current_os() in v) }

    def empty_v_to_k(k,v):
        return v if v else k

    def resolve_source_obj(v):
        if isinstance(v, dict):
            current_os = common.get_current_os()
            if not current_os in v:
                # this should never happen
                raise Exception(f"Couldn't find our OS in source {current_os}")
            return v[current_os]

        elif isinstance(v, str):
            return v

        else:
            raise Exception("What are you trying to pass me here ?")


    sources = { k: empty_v_to_k(k, resolve_source_obj(v))
               for (k,v)
               in sources.items() }

    return sources

def main():
    repo_path = pathlib.dirname(pathlib.realpath(__file__))
    os.chdir(repo_path)

    ignores = load_ignore_file() # TODO this might be obsolete now, we change from blacklisting to whitelisting
    config = JinjaGlobalsModule( common.load_config() )
    global home_base_path
    home_base_path = config.home_base_path if hasattr(config,
                                                      "home_base_path") \
                                           else home_base_path


    sources = resolve_sources_list(list.sources)
    for source_path, target_path in sources.items():
        target_path = pathlib.abspath(home_path_equivalent(repo_path, target_path)) # set target_path to be local of $HOME

        # skip ignored files
        if source_path.startswith(ignores):
            continue

        # skip any symlinked sources leading outside of the project root
        if not pathlib.realpath(source_path).startswith(repo_path):
            continue

        # TODO cache state and check if it changed

        # build .j2 templates
        if pathlib.splitext(source_path)[1] == ".j2":
            p = jinja_paths(repo_path, source_path, target_path)
            source_path = p.source_path
            target_path = p.target_path

            # request confirmation in the case that he output of a template has been changed, such changes will be lost and should be migrated to the actual template file
            # XXX I know this is a mess, just stick with it

            if pathlib.exists(p.source_path_bk) and not filecmp.cmp(p.source_path, p.source_path_bk):
                response_should_skip = False
                while True:
                    response = input('"{}" has been changed since last invocation.\n(D)iscard changes/(S)kip file altogether/(V)iew differences (d/s/v) '.format(p.source_path))
                    response = response.lower()

                    if response == "d":
                        response_should_skip = False
                        break
                    elif response == "s":
                        response_should_skip = True
                        break
                    elif response == "v":
                        subprocess.check_call(["vimdiff", p.source_path, p.source_path_bk])

                if response_should_skip:
                    continue

            render_jinja_template(config, p, backup=True)

        target_path = common.expand_path(target_path)

        # skip already linked files
        if is_already_linked(source_path, target_path):
            continue

        # unlink wrongly linked files
        try:
            if stat.S_ISLNK( os.lstat(target_path).st_mode ):
                os.unlink(target_path)
                print(f"{common.terminal_symbol_to} unlinking {target_path}")
        except:
            pass

        # backup already present files
        if pathlib.exists(target_path):
            backup_file(target_path)

        # create parent directories to target if they don't exist yet
        target_parent_path = pathlib.dirname(target_path)
        if not pathlib.exists(target_parent_path):
            os.makedirs(target_parent_path)

        assert not pathlib.exists(target_path)

        source_path = pathlib.abspath(source_path)
        target_path = pathlib.abspath(target_path)

        print("{} {} {}".format(source_path, common.terminal_symbol_to, target_path))
        os.symlink(source_path, target_path)
        log_syschange(f"ln -s \"{source_path}\" \"{target_path}\"", f"rm \"{target_path}\"")

if __name__ == "__main__":
    main()
