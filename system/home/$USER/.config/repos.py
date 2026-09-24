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
