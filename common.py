import os
from os import path as pathlib
import importlib
from functools import partial

import platform
import subprocess

isLinux = platform.system() == "Linux"
isArchLinux = isLinux and "arch" in platform.uname().release.lower()
isWindows = platform.system() == "Windows"
isMacos = platform.system() == "Darwin"

proj_dir = pathlib.dirname(pathlib.abspath(__file__))
open_utf8 = partial(open, encoding='UTF-8')

terminal_symbol_reload = "↻" if not isWindows else "<)"
terminal_symbol_to = "→" if not isWindows else "->"

def get_current_os():
    if isWindows: return "windows"
    elif isLinux: return "linux"
    elif isMacos: return "macos"

def expand_path(path):
    """ expand portions of path like ~/$ """
    if path.startswith('$'):
        path = proj_dir + path[1:]
    elif path.startswith('~'):
        path = pathlib.expanduser(path)

    return path

def sh(cmd, verbose=False):
    if verbose:
        print("$", " ".join(cmd))
    subprocess.check_call(cmd)

def sh_cygpath(path):
    return subprocess.check_output(["cygpath", "-w", path]).decode("utf-8").strip()
def sh_realpath(path):
    return os.path.realpath(path)

_DIRSTACK = []
def pushd(dir):
    _DIRSTACK.append(os.curdir)
    os.chdir(dir)
def popd():
    os.chdir(_DIRSTACK.pop())

def load_config():
    config_path = "config"
    def module_iter(self):
        for key, val in self.__dict__.items():
            if key.startswith("_"):
                continue
            yield (key, val)

    if not pathlib.isfile(config_path+".py"):
        return {}

    result = importlib.import_module(config_path)
    return result

def symlink(src, dst):
    """ Symlink to src from dst - or not if already exists and is correctly linked """
    if pathlib.exists(dst) and pathlib.realpath(dst) == src:
        return

    os.symlink(src, dst)
