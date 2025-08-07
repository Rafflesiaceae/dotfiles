# How to source ~/.xprofile

This doesn't happen by default, so:

Make sure this is at the top of your `/etc/gdm/Xsession`:

```
# Always source ~/.xprofile if it exists
if [ -f "$HOME/.xprofile" ]; then
    . "$HOME/.xprofile"
fi
```

