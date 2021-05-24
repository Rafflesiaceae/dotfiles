gitconfig = {
    "use_lfs" : False,
}

alacritty = {
    "font_size": 11,
    "additional": "",
}

i3 = {
    "mod_keys": ["Mod3", "Mod4"],
    "floating_modifier": "Mod4",
    "floating_term_geometry":  "169x20+0+415",

    "show_systray": True,
    # "statuscmd": "/usr/bin/my_statuscmd",
}

dpi = 98

default_terminal_emulator = "urxvt"

def modify_source_list(source_list):
    # ignore_sources = set( pathlib.abspath(source) for source in [
    #     "gitconfig.j2"
    # ] )

    # return source_list - ignore_sources
    return source_list
