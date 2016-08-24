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

#### About Standards

In order for it to properly detect if an armor type already exists, it needs
to have _cloth, _light, or _heavy somewhere in its EditorID. Good Examples:

* ```dcc_latex_ArmoTanktop_ClearS_Cloth```
* ```aaaIdiotPrefixModderArmor_Cloth_Body```
* ```zzzidiotprefixmodder_clotharmor```

This script will then check if these exist:

* ```dcc_latex_ArmoTanktop_ClearS_Heavy```
* ```aaaIdiotPrefixModderArmor_Heavy_Body```
* ```zzzidiotprefixmodder_Heavyarmor```

and if it does not find those, it will make them. By convention I suggest you
always put _Cloth, _Light, and _Heavy at the end of the Editor ID, as that is
where this script is going to put them.

#### About Keywords

I personally suggest when you create outfits that you create the Cloth version
first. You also should properly keyword the outfit before you run this script.
For example, ALL pieces in a cloth outfit should have the following Keywords:

* ArmorClothing
* VendorItemClothing
* ClothingBody (or ClothingFeet, ClothignHands, ClothingHead)

Then when this script gets run, your new Heavy armor will translate those
keywords into the following:

* ArmorHeavy
* VendorItemArmor
* ArmorCuirass (or ArmorBoots, ArmorGauntlets, ArmorHelmet)

#### Example: Creating Light and Heavy from Cloth

![A bunch of cloth items.](https://66.media.tumblr.com/008c9d4a8b90d7a41d97cfe57af190a4/tumblr_ocdy3o4ZIM1u8cymno1_1280.png)

If you run the script on the Armor category it will process all of them to make
sure that Cloth, Light, and Heavy variants exist for everything. You can also
select just certain items if you wish, like maybe do 1 set at a time, so that
you can give the sets different armor values.

![Provide a base armor value](https://66.media.tumblr.com/61654b2c71261f20a81beec01e8b79d7/tumblr_inline_ocdxx0g2Rf1r6qwqv_1280.png)

It will ask you for the armor value which you would see on the chest piece for
this particular set, and show you some reasonable values to choose from. All
chest pieces will be given this value. Boots, gauntlets, and helmets, will be
given a value auto calculated to be reasonable values based on the chest piece,
scaling in simliar ways to the normal armor already in the game. If the script
is creating Cloth pieces for you, then the armor will be automatically set to 0
so that mage perks work properly.

![Tada](https://67.media.tumblr.com/1fee4207495a8fc0ff02c5e932350867/tumblr_inline_ocdxzqVlGE1r6qwqv_1280.png)

# The Framework

The framework is far from complete. It contains functions that I needed to make
the other scripts. It includes functions like setting an Editor ID, setting
an Item's weight and value, etc, without having to know the paths or dick with
the Element iterations yourself. See dcc\skyrim.pas for available functions.