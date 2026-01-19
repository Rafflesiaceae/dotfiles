# -*- coding: utf-8 -*-
import os
import sys
import ranger.api

HOOK_INIT_OLD = ranger.api.hook_init

EMOJI = "🗳️"  # change to whatever you want, e.g. "🦝"


def _fmt_path(p: str) -> str:
    home = os.path.expanduser("~")
    if p.startswith(home + os.sep) or p == home:
        return "~" + p[len(home) :]
    return p


def _set_terminal_title(title: str) -> None:
    # OSC 0 sets both icon name + window title in most xterm-compatible terminals (incl. urxvt)
    sys.stdout.write(f"\033]0;{title}\007")
    sys.stdout.flush()


def hook_init(fm):
    def on_cd(signal=None):
        if fm.thisdir:
            path = _fmt_path(fm.thisdir.path)
            _set_terminal_title(f"{EMOJI} {path}")

    fm.signal_bind("cd", on_cd)
    return HOOK_INIT_OLD(fm)


ranger.api.hook_init = hook_init
