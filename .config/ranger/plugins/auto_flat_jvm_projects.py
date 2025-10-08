# ~/.config/ranger/plugins/auto_flat_src_main.py
import os
import ranger.api

_old_hook_init = ranger.api.hook_init

def _is_under_src_main(path: str) -> bool:
    parts = os.path.normpath(path).split(os.sep)
    # True for .../src/main and anything below (e.g. .../src/main/java)
    for i in range(len(parts)):
        if parts[i] == "src":
            return True
    return False

def hook_init(fm):
    def on_cd(signal):
        # new path after cd
        new_path = getattr(signal, "new", None)
        new_path = getattr(new_path, "path", None) or (fm.thisdir.path if fm.thisdir else "")

        if _is_under_src_main(new_path):
            fm.execute_console("flat -1")  # always flatten under src/main/...
        else:
            fm.execute_console("flat 0")   # otherwise keep normal view

    fm.signal_bind("cd", on_cd)  # run on every directory change
    return _old_hook_init(fm)

# ranger.api.hook_init = hook_init
