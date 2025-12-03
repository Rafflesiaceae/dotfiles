from ranger.api.commands import Command

class toggle_flat(Command):
    """
    :toggle_flat

    Toggle between `flat -1` (fully flattened) and `flat 0` (normal view)
    for the current directory.
    """
    def execute(self):
        thisdir = self.fm.thisdir
        # current level (0 or None => "off")
        level = getattr(thisdir, 'flat', 0)

        if level in (0, None):
            new_level = -1   # turn flat view on (infinite depth)
        else:
            new_level = 0    # turn flat view off

        thisdir.unload()
        thisdir.flat = new_level
        thisdir.load_content()
