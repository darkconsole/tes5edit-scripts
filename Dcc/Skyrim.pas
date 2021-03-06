Unit Skyrim;

Uses
	'Dcc\Util';

{
	TES5Edit Reference:
	http://www.creationkit.com/index.php?title=TES5Edit_Scripting_Functions
}

Interface
	Function FormCopy: IInterface;
	Function FormCopyFromTemplateID(): IInterface;
	Function FormFind: IInterface;
	Function FormGet: IInterface;

Const
	Debug = FALSE;
	LineBreak = #13#10;

	ArmorTypeCloth = 0;
	ArmorTypeLight = 1;
	ArmorTypeHeavy = 2;

	ArmaModelMaleThird = 2;
	ArmaModelFemaleThird = 3;
	ArmaModelMaleFirst = 4;
	ArmaModelFemaleFirst = 5;

Implementation

	////////
	////////

	Function FormFind(Plugin: IInterface; FormType: String; EditorID: String): IInterface;
	Begin

		// according to the ck wiki, MainRecordByEditorID does not work very
		// well unless you narrow it down by group.

		Result := MainRecordByEditorID(
			GroupBySignature(Plugin,UpperCase(FormType)),
			EditorID
		);
	End;

	Function FormCopy(Form: IInterface): IInterface;
	Begin

		If(Debug)
		Then AddMessage('[:::] Copying ' + EditorID(Form));

		Result := wbCopyElementToFile(
			Form,
			GetFile(Form),
			TRUE, TRUE
		);
	End;

	Function FormCopyFromTemplateID(Plugin: IInterface; TemplateID: Integer): IInterface;
	Var
		FormID: Integer;
	Begin
		FormID := (GetLoadOrder(Plugin) shl 24) + TemplateID;
		Result := FormCopy(FormGet(FormID));
	End;

	Function FormGet(FormID: Integer): IInterface;
	Begin
		Result := RecordByFormID(
			FileByLoadOrder(FormID shr 24),
			LoadOrderFormIDtoFileFormID( FileByLoadOrder(FormID shr 24), FormID ),
			True
		);
	End;

	////////
	////////

	// these are functions which can be used on multiple different form types
	// because they share field names. granted not all forms will have all the
	// fields but if they were generic enough they went here. you will have
	// to be smart and not try to do something like set a Weight on a Texture
	// Set or whatever dumbness.

	Function FormHasKeywordString(Form: IInterface; KeywordID: String): Integer;
	Var
		Keyring: IInterface;
		Count: Integer;
		Output: Integer;
	Begin

		Output := -1;
		Keyring := ElementBySignature(Form,'KWDA');
		Count := ElementCount(Keyring);

		While Count > 0
		Do Begin
			If(CompareText(EditorID(LinksTo(ElementByIndex(Keyring,(Count-1)))),KeywordID) = 0)
			Then Begin
				Output := Count;
				Count := -1;
			End;
			Dec(Count);
		End;

		Result := Output;
	End;

	Function FormGetName(Form: IInterface): String;
	Begin
		Result := GetEditValue(ElementbySignature(Form,'FULL'));
	End;

	Procedure FormSetName(Form: IInterface; NewName: String);
	Begin
		SetEditValue(
			ElementBySignature(Form,'FULL'),
			NewName
		);
	End;

	Procedure FormSetEditorID(Form: IInterface; EditorID: String);
	Begin
		SetElementEditValues(Form,'EDID - Editor ID',EditorID);
	End;

	Function FormGetValue(Form: IInterface): Integer;
	Begin
		Result := Floor(GetElementNativeValues(
			Form,
			'DATA - Data\Value'
		));
	End;

	Procedure FormSetValue(Form: IInterface; Value: Integer);
	Begin
		SetElementNativeValues(
			Form,
			'DATA - Data\Value',
			Value
		);
	End;

	Function FormGetWeight(Form: IInterface): Integer;
	Begin
		Result := Floor(GetElementNativeValues(
			Form,
			'DATA - Data\Weight'
		));
	End;

	Procedure FormSetWeight(Form: IInterface; Value: Integer);
	Begin
		SetElementNativeValues(
			Form,
			'DATA - Data\Weight',
			Value
		);
	End;

	////////
	////////

	// TextureSet specific functions.

	Procedure TxstSetTextureDiffuse(Form: IInterface; Filename: String);
	Begin
		SetElementEditValues(Form,'Textures (RGB/A)\TX00 - Difuse',Filename);
	End;

	Procedure TxstSetTextureNormal(Form: IInterface; FileName: String);
	Begin
		SetElementEditValues(Form,'Textures (RGB/A)\TX01 - Normal/Gloss',Filename);
	End;

	Procedure TxstSetTextureEnv(Form: IInterface; FileName: String);
	Begin
		SetElementEditValues(Form,'Textures (RGB/A)\TX05 - Environment',Filename);
	End;

	////////
	////////

	// Armor specific functions.

	Function GetArmorTypeWord(ArmorType: Integer): String;
	Begin
		Case ArmorType Of
			1: Result := 'Light';
			2: Result := 'Heavy';
		Else
			Result := 'Cloth';
		End;
	End;

	Function ArmoGetArmorType(Form: IInterface): Integer;
	Var
		ArmorType: String;
		Output: Integer;
	Begin
		Output := 0;

		ArmorType := GetElementEditValues(
			Form,
			'BOD2 - Biped Body Template\Armor Type'
		);

		If(CompareText('Light Armor',ArmorType) = 0)
		Then Begin
			Output := ArmorTypeLight;
		End
		Else If(CompareText('Heavy Armor',ArmorType) = 0)
		Then Begin
			Output := ArmorTypeHeavy;
		End;

		Result := Output;
	End;

	Procedure ArmoSetArmorType(Form: IInterface; ArmorType: Integer);
	Var
		ArmorWord: String;
	Begin
		// ArmorType: 0 = Clothing, 1 = Light, 2 = Heavy

		Case ArmorType Of
			1: ArmorWord := 'Light Armor';
			2: ArmorWord := 'Heavy Armor';
		Else
			ArmorWord := 'Clothing';
		End;

		SetElementEditValues(
			Form,
			'BOD2 - Biped Body Template\Armor Type',
			ArmorWord
		);
	End;

	Procedure ArmoSetArmorRating(Form: IInterface; ArmorValue: Integer);
	Begin
		// passing a value of 42 for a weight resulted in it being set as
		// 0.42 in the form.

		SetElementNativeValues(
			Form,
			'DNAM - Armor Rating',
			(ArmorValue * 100)
		);
	End;

	Procedure ArmoSetArmorRatingAuto(Form: IInterface; BaseValue: Integer);
	Var
		Rating: Int;
	Begin
		Rating := (BaseValue * 0.2);

		If(ArmoGetArmorType(Form) = 0)
		Then Begin
			Rating := 0;
		End

		Else If(FormHasKeywordString(Form,'ArmorCuirass') <> -1)
		Then Begin
			Rating := BaseValue;
		End

		Else If(FormHasKeywordString(Form,'ArmorGauntlets') <> -1)
		Then Begin
			Rating := (BaseValue * 0.3);
		End

		Else If(FormHasKeywordString(Form,'ArmorBoots') <> -1)
		Then Begin
			Rating := (BaseValue * 0.4);
		End

		Else If(FormHasKeywordString(Form,'ArmorHelmet') <> -1)
		Then Begin
			Rating := (BaseValue * 0.3);
		End;

		ArmoSetArmorRating(Form,Rating);
	End;

	Procedure ArmoReplaceArmorTypeName(Form: IInterface; ArmorType: Integer);
	Var
		Reg: TPerlRegex;
	Begin
		Reg := TPerlRegex.Create();
		Reg.RegEx := '\b(light|heavy|cloth)\b';
		Reg.Options := [ preCaseLess ];
		Reg.Subject := FormGetName(Form);

		Case ArmorType Of
			1: Reg.Replacement := 'Light';
			2: Reg.Replacement := 'Heavy';
		Else
			Reg.Replacement := 'Cloth';
		End;

		If(Reg.Match())
		Then Begin
			Reg.ReplaceAll();
			FormSetName(Form,Reg.Subject);
		End
		Else Begin
			FormSetName(Form,Reg.Subject + ' (' + Reg.Replacement + ')');
		End;

	End;

	Procedure ArmoReplaceArmorTypeKeywords(Form: IInterface; TargetType: Integer);
	Var
		Iter: Integer;
		Kter: Integer;
		Kndex: Integer;
		KeywordCount: Integer;
		KeywordBox: IInterface;
		KeywordItem: IInterface;
		KeywordNew: IInterface;
		ArmorTypeSet: Array[0..5] of TStringList;
	Begin
		// given the target armor type, look for keywords from the old type
		// and replace them with their matching. E.g. swap out keywords like
		// Armor* for Clothing*, ArmorType*, VendorType*

		// this should probably be moved to a global location and be
		// initialised at startup.

		Iter := 0;
		While Iter < Length(ArmorTypeSet)
		Do Begin
			ArmorTypeSet[Iter] := TStringList.Create;
			Inc(Iter);
		End;

		ArmorTypeSet[0].Add('ClothingBody');
		ArmorTypeSet[0].Add('ArmorCuirass');
		ArmorTypeSet[0].Add('ArmorCuirass');
		ArmorTypeSet[1].Add('ClothingFeet');
		ArmorTypeSet[1].Add('ArmorBoots');
		ArmorTypeSet[1].Add('ArmorBoots');
		ArmorTypeSet[2].Add('ClothingHands');
		ArmorTypeSet[2].Add('ArmorGauntlets');
		ArmorTypeSet[2].Add('ArmorGauntlets');
		ArmorTypeSet[3].Add('ClothingHead');
		ArmorTypeSet[3].Add('ArmorHelmet');
		ArmorTypeSet[3].Add('ArmorHelmet');
		ArmorTypeSet[4].Add('VendorItemClothing');
		ArmorTypeSet[4].Add('VendorItemArmor');
		ArmorTypeSet[4].Add('VendorItemArmor');
		ArmorTypeSet[5].Add('ArmorClothing');
		ArmorTypeSet[5].Add('ArmorLight');
		ArmorTypeSet[5].Add('ArmorHeavy');

		////////
		////////

		KeywordBox := ElementBySignature(Form,'KWDA');
		KeywordCount := ElementCount(KeywordBox);

		Iter := 0;
		While Iter < KeywordCount
		Do Begin
			KeywordItem := LinksTo(ElementByIndex(KeywordBox,Iter));

			Kter := 0;
			While Kter < Length(ArmorTypeSet)
			Do Begin
				Kndex := ArmorTypeSet[Kter].IndexOf(EditorID(KeywordItem));

				If(Kndex <> -1)
				Then Begin
					KeywordNew := FormFind(
						GetFile(KeywordItem),
						'KYWD',
						ArmorTypeSet[Kter].Strings[TargetType]
					);

					SetEditValue(
						ElementByIndex(KeywordBox,Iter),
						IntToHex(FormID(KeywordNew),8)
					);

					Kter := Length(ArmorTypeSet) + 1;
					End;

				Inc(Kter);
			End;

			Inc(Iter);
		End;

		Iter := 0;
		While Iter < Length(ArmorTypeSet)
		Do Begin
			ArmorTypeSet[Iter].Free();
			Inc(Iter);
		End;

	End;

	Function ArmoGetModelElement(Form: IInterface): IInterface;
	Begin
		Result := ElementByPath(Form,'Armature');
	End;

	Function ArmoGetModelCount(Form: IInterface): Integer;
	Begin
		Result := ElementCount(ArmoGetModelElement(Form));
	End;

	Procedure ArmoSetModelByIndex(Form: IInterface; ModelNum: Integer; Model: IInterface);
	Begin
		SetEditValue(
			ElementByIndex(ArmoGetModelElement(Form),ModelNum),
			IntToHex(FormID(Model),8)
		);
	End;

	////////
	////////

	Function GetArmaPathRoot(ModelKey: Integer): String;
	Begin
		Case ModelKey Of
			2: Result := 'Male world model';
			3: Result := 'Female world model';
			4: Result := 'Male 1st Person';
			5: Result := 'Female 1st Person';
		Else
			Result := 'Male world model';
		End;
	End;

	Function ArmaGetModelFilename(Form: IInterface; ModelKey: Integer): String;
	Var
		ModelPath: String;
	Begin
		ModelPath := GetArmaPathRoot(ModelKey) + '\MOD' + IntToStr(ModelKey) +  ' - Model Filename';
		Result := GetEditValue(ElementByPath(Form,ModelPath));
	End;

	Function ArmaGetModelTextureElementByIndex(Form: IInterface; ModelKey: Integer): IInterface;
	Var
		ModelPath: String;
		TextureCount: Integer;
		Iter: Integer;
	Begin
		ModelPath := GetArmaPathRoot(ModelKey) + '\MO' + IntToStr(ModelKey) + 'S - Alternate Textures';
		Result := ElementByPath(Form,ModelPath);
	End;

	Function ArmaGetModelTextureCount(Form: IInterface; ModelKey: Integer): Integer;
	Begin
		Result := ElementCount(ArmaGetModelTextureElementByIndex(Form,ModelKey));
	End;

	Function ArmaGetModelTextureSetByIndex(Form: IInterface; ModelKey: Integer; TextureKey: Integer): IInterface;
	Var
		TextureElement: IInterface;
	Begin
		TextureElement := ElementByIndex(ArmaGetModelTextureElementByIndex(Form,ModelKey),TextureKey);
		Result := LinksTo(ElementByPath(TextureElement,'New Texture'));
	End;

	Procedure ArmaSetModelTextureSetByIndex(Form: IInterface; ModelKey: Integer; TextureKey: Integer; TextureSet: IInterface);
	Var
		TextureElement: IInterface;
	Begin
		TextureElement := ElementByIndex(ArmaGetModelTextureElementByIndex(Form,ModelKey),TextureKey);
		SetEditValue(
			ElementByPath(TextureElement,'New Texture'),
			IntToHex(FormID(TextureSet),8)
			//IntToHex(LoadOrderFormIDtoFileFormID( FileByLoadOrder(TextureSet shr 24), TextureSet )),
		);
	End;

	////////////////////////////////
	////////////////////////////////

	FUNCTION ArmaGetModelTextureSetByShape(
		Form: IInterface;
		ModelKey: Integer;
		ShapeName: String
	): IInterface;

	VAR
		TextureList: IInterface;
		TextureCount: Integer;
		TextureIter: Integer;
		TextureItem: IInterface;
		TextureName: String;

	BEGIN
		TextureList := ArmaGetModelTextureElementByIndex(Form,ModelKey);
		TextureCount := ElementCount(TextureList);

		FOR TextureIter := 0 TO (TextureCount - 1)
		DO BEGIN
			TextureItem := ElementByIndex(TextureList,TextureIter);
			TextureName := GetEditValue(ElementByPath(TextureItem,'3D Name'));

			IF(CompareText(TextureName,ShapeName) = 0)
			THEN BEGIN
				Result := LinksTo(ElementByPath(TextureItem,'New Texture'));
				EXIT;
			END;

		END;

		Result := NIL;
	END;

	////////////////////////////////
	////////////////////////////////

	PROCEDURE ArmaSetModelTextureSetByShape(
		Form: IInterface;
		ModelKey: Integer;
		ShapeName: String;
		TextureSet: IInterface
	);

	VAR
		TextureList: IInterface;
		TextureCount: Integer;
		TextureIter: Integer;
		TextureItem: IInterface;
		TextureName: String;

	BEGIN
		TextureList := ArmaGetModelTextureElementByIndex(Form,ModelKey);
		TextureCount := ElementCount(TextureList);

		FOR TextureIter := 0 TO (TextureCount - 1)
		DO BEGIN
			TextureItem := ElementByIndex(TextureList,TextureIter);
			TextureName := GetEditValue(ElementByPath(TextureItem,'3D Name'));

			IF(CompareText(TextureName,ShapeName) = 0)
			THEN BEGIN
				SetEditValue(
					ElementByPath(TextureItem,'New Texture'),
					IntToHex(FormID(TextureSet),8)
				);
				EXIT;
			END;

		END;
	END;

	////////////////////////////////
	////////////////////////////////

	Function CobjGetWorkebenchKeyword(Form: IInterface): IInterface;
	Begin
		Result := GetEditValue(ElementbySignature(Form,'BNAM'));
	End;

	Procedure CobjSetWorkebenchKeyword(Form: IInterface; FormID: Integer);
	Begin
		SetEditValue(
			ElementBySignature(Form,'BNAM'),
			FormID
		);
	End;

	////////////////////////////////
	////////////////////////////////

	FUNCTION CobjGetCreatedObject(Form: IInterface): IInterface;
	BEGIN
		Result := GetEditValue(ElementBySignature(Form,'CNAM'));
	END;

	////////////////////////////////
	////////////////////////////////

	PROCEDURE CobjSetCreatedObject(Form: IInterface; CreateObject: IInterface);
	BEGIN
		SetEditValue(
			ElementBySignature(Form,'CNAM'),
			IntToHex(FormID(CreateObject),8)
		);
	END;

End.
