{
	Create Armor Variants
	darkconsole http://darkconsole.tumblr.com

	Given an ARMO record (or list of) create any variants (cloth, light, heavy)
	of that item properly editing the EditorID, Title, and swapping out the
	various keywords that make an armor Cloth, Light, or Heavy.

	Personally I suggest you create Cloth variants of all your armors, and then
	let this script generate the Light and Heavy. Given a base armor damage
	resist value that you would expect to see on a chest piece (say, 35), this
	script will calculate what the values for gloves, boots, and helmets for
	you based on that value. Cloth items will be automatically set to 0 armor
	so mages work properly.

	For it to work to its fullest there are a few requirements:

	* The EditorID should contain _Cloth, _Light, or _Heavy. If this is missing
	it will add the tag to the editor ID but your original will still have
	a bad (in my opinion) EditorID.

	* The Full Name should contain Cloth Light or Heavy in it. If this is
	missing then it will add (Cloth), (Light), or (Heavy) to the end of the
	full name. IT IS ACCEPTABLE if you are starting from cloth originals to
	not have the word Cloth in the name, letting the script add Light and
	Heavy for you.

	* For Keywords to work well, your originals will have to be properly
	keyworded as well. This means your original keywords should have their
	proper body part and armor type keywords. For example turning cloth into
	heavy will convert the following Keywords:

		ClothingBody => ArmorCuirass
		ArmorClothing => ArmorHeavy
		VendorItemClothing => VendorItemArmor

	If your original is not properly keyworded then we cant replace them for
	you. KEYWORDS ARE IMPORTANT FOR PERKS AND SHIT SO TAKE THE TIME.
}

Unit
	UserScript;

Uses
	'Dcc\Skyrim';

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Procedure DccMakeArmorVariant(Form: IInterface; ArmorType: Integer);
Var
	FormNew: IInterface;
	RegEx: TPerlRegex;
	ArmorRating: Integer;
Begin
	ArmorRating := 35;

	RegEx := TPerlRegex.Create();
	RegEx.RegEx       := '_(cloth|light|heavy)';
	RegEx.Options     := [ preCaseless ];
	RegEx.Replacement := '_' + GetArmorTypeWord(ArmorType);
	RegEx.Subject     := EditorID(Form);

	If(RegEx.Match())
	Then RegEx.ReplaceAll()
	Else RegEx.Subject := EditorID(Form) + '_' + GetArmorTypeWord(ArmorType);

	If(NOT Assigned(Skyrim.FormFind(GetFile(Form),'ARMO',RegEx.Subject)))
	Then Begin
		FormNew := Skyrim.FormCopy(Form);

		// first update its editor id.
		Skyrim.FormSetEditorID(FormNew,RegEx.Subject);

		// set it to be the armor we need and replace whatever needs it.
		Skyrim.ArmoSetArmorType(FormNew,ArmorType);
		Skyrim.ArmoReplaceArmorTypeKeywords(FormNew,ArmorType);
		Skyrim.ArmoReplaceArmorTypeName(FormNew,ArmorType);

		// then handling updating values that depend on the type of armor.
		Skyrim.ArmoSetArmorRatingAuto(FormNew,ArmorRating);
	End;

	RegEx.Free();
End;

Procedure DccProcessArmor(Form: IInterface);
Var
	ArmorType: Integer;
Begin
	ArmorType := 0;
	While(ArmorType <= 2)
	Do Begin
		If(Skyrim.ArmoGetArmorType(Form) <> ArmorType)
		Then DccMakeArmorVariant(Form,ArmorType);

		Inc(ArmorType);
	End;
End;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Function Initialize: Integer;
Begin

End;

Function Process(Form: IInterface): Integer;
Begin

	If(CompareText('ARMO',Signature(Form)) <> 0)
	Then Begin
		AddMessage('[!!!] ' + EditorID(Form) + ' is not an armor.');
	End
	Else Begin
		DccProcessArmor(Form);
	End;
End;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

End.
