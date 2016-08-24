# TES5Edit Scripts

Frameworking and Scripts to make editing shit with TES5Edit so smooth.

# The Scripts

## DCC - Skyrim - Create Armor Variants

This script will let you quickly create any missing variants of an outfit. This
means if you create an armor piece that is Light, you can use this to quickly
create Cloth and Heavy versions of it. It will automatically update the editor
ID, the in-game name, and swap out all the keywords that matter for making perks
work and stuff. It will also auto calculate the proper armor values for the
pieces based on the chest piece armor value.

![A bunch of cloth items.](https://66.media.tumblr.com/008c9d4a8b90d7a41d97cfe57af190a4/tumblr_ocdy3o4ZIM1u8cymno1_1280.png)

![Provide a base armor value](https://66.media.tumblr.com/61654b2c71261f20a81beec01e8b79d7/tumblr_inline_ocdxx0g2Rf1r6qwqv_1280.png)

![Tada](https://67.media.tumblr.com/1fee4207495a8fc0ff02c5e932350867/tumblr_inline_ocdxzqVlGE1r6qwqv_1280.png)

# The Framework

The framework is far from complete. It contains functions that I needed to make
the other scripts. It includes functions like setting an Editor ID, setting
an Item's weight and value, etc, without having to know the paths or dick with
the Element iterations yourself. See dcc\skyrim.pas for available functions.