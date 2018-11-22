# QLSVGSprite
A QuickLook plugin able to preview SVG sprites and SVG images.

About
------------
SVG sprites are a special kind of SVG file, mostly unsupported by SVG editors or viewers. They are made of different symbols, each a simple image with an id. This QL plugin allows previewing the contents of a sprite SVG file.
All the sprites are displayed within a grid, headed by the symbol name.

Installation
------------
* Make sure you have a **QuickLook** folder under **~/Library/QuickLook**. If unsure, just go to a terminal and run:

```
mkdir ~/Library/QuickLook  # Create the folder, or give an error if it exists
```
* Download the [DMG](https://github.com/nunopedrosa/QLSVGSprite/blob/master/QLSVGSprite-Installer.dmg), open it and drag the generator into the QuickLook shortcut.
It should be available immediately.

If, for some reason, the previewer does not work, open a terminal and refresh QuickLook plugins with the *qlmanage* utility:

```
qlmanage -r
```

Creating the Installer
----------------------
* Create Icons for the installer

```
./build_icons.sh QLSVGSprite.png
```

* Create DMG installer

```
../create-dmg/create-dmg \
--volname "QLSVGSprite Installer" \
--volicon "installer/QLSVGSprite.icns" \
--background "installer/background.png" \
--window-pos 200 120 \
--window-size 600 400 \
--icon "QLSVGSprite.qlgenerator" 150 190 \
--ql-drop-link 450 185 \
"QLSVGSprite-Installer.dmg" \
"to_install/"
```

References
----------
* [https://github.com/andreyvit/create-dmg](https://github.com/andreyvit/create-dmg)
* [https://github.com/p2/quicklook-csv](https://github.com/p2/quicklook-csv)

License
-------

This work is [Apache 2](./LICENSE.txt) licensed: [NOTICE.txt](./NOTICE.txt).
