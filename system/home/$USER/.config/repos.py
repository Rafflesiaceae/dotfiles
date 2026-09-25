import os
import subprocess

workdir_root = "~/workspace"

repo_files = [
    "~/.numdots/repos.conf",
]


# optional - resolved first
def remap_host(repo):
    return repo["host"]


# optional - resolved second
def remap_remote(repo):
    if repo["host"] == "gh":
        assert len(repo["path"]) == 2
        return f"ssh://git@github.com:{"/".join(repo["path"])}.git"

    return None


# optional - resolved third
def remap_workdir(repo):
    return {
        "gh:Rafflesiaceae/dotfiles": "~/.numdots",
    }.get(repo["id"])


# optional
def custom_clone_cmd(repo):
    return ["gitusers-clone", repo["remote"], repo["workdir"]]


def post_update_hook(repo):
    def process_optional_file(name):
        build_sh = os.path.join(repo["workdir"], name)

        if os.path.isfile(build_sh):
            subprocess.run(
                [f"./{name}"],
                cwd=repo["workdir"],
                check=True,
            )

    process_optional_file("build.sh")
    process_optional_file("install.sh")
    process_optional_file("bootstrap.py")
