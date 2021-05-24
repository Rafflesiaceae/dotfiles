# What is this?
Just my dotfiles.

# Install
run `bootstrap.py`

# TODO
- add click/cli
- add option to check if linked files built from templates have changed (store a checksum)
- remove symbolic links we stopped tracking (store previous states to detect changes)
- if x - tests if x is falsy, if we want to control x depending if theres an
  empty dict for it or not in the config this wont work, as the empty dict
  would be falsy
- add inlinefunc/lambda for a source in source\_list that determines if the file is being source or not (like checking if the cfg has a certain variable etc.)
- add CLI option to search and clean up dead symlink
- expand "~" and "$" differently, even in source lists
