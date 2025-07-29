# GTK3/4 Themes
Get the following packages:
+ pacman -Sy lxappearance-gtk3 gnome-themes-extra papirus-icon-theme

Run 'lxappearance' and set:
```
Widget     : 'Adwaita-dark'
Icon Theme : 'Papirus-Dark'
```

Also for gtk4 make sure that your `~/.profile` has:
```
# gtk4 (has no config files, only env variables)
export GTK_THEME=Adwaita:dark
```

## Result
Should look like:
```
.config/gtk-3.0/settings.ini:
    perm: "0644"
    content: |
        [Settings]
        gtk-theme-name=Adwaita-dark
        gtk-icon-theme-name=Papirus-Dark
        gtk-font-name=Adwaita Sans 11
        gtk-cursor-theme-name=Adwaita
        gtk-cursor-theme-size=0
        gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
        gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
        gtk-button-images=0
        gtk-menu-images=0
        gtk-enable-event-sounds=1
        gtk-enable-input-feedback-sounds=1
        gtk-xft-antialias=1
        gtk-xft-hinting=1
        gtk-xft-hintstyle=hintslight
        gtk-xft-rgba=rgb
```
