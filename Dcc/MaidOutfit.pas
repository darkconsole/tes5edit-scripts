UNIT
	MaidOutfit;

CONST
	GameDir = 'D:\Games\Steam\steamapps\common\Skyrim Special Edition';
	JsonFile = '\data\meshes\dcc-maid\outfits.json';

IMPLEMENTATION

	FUNCTION MaidReplaceFormID(
		Input: String;
		OutfitID: String;
		VariantName: String;
		EditPrefix: Boolean;
	): String;
	VAR
		Output: String;
	BEGIN
		Output := Input;

		Output := Util.PregReplace('%Variant%',VariantName,Output);
		Output := Util.PregReplace('%ID%',OutfitID,Output);

		IF(EditPrefix = TRUE)
		THEN BEGIN
			Output := Util.PregReplace('dcc_maid_','dcc_maidx_',Output);
		END;

		Result := Output;
	END;

	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	PROCEDURE MaidBuildOutfits(Plugin: IInterface);
	VAR
		JSON: TJsonObject;
		OutfitIter: Integer;
		Outfit: TJsonObject;
		ArmorIter: Integer;
		Armor: TJsonObject;
		VariantIter: Integer;
		VariantName: String;
		ArmaForm: IInterface;
		ArmoForm: IInterface;
		CraftForm: IInterface;
		TemperForm: IInterface;

	BEGIN

		// load in the json file.

		JSON := TJsonObject.Create;
		JSON.LoadFromFile(GameDir + JsonFile);

		// look at the outfits.

		FOR OutfitIter := 0 TO (JSON.A['Outfits'].Count - 1)
		DO BEGIN
			Outfit := JSON.A['Outfits'].O[OutfitIter];

			FOR ArmorIter := 0 TO (Outfit.A['Armors'].Count - 1)
			DO BEGIN
				Armor := Outfit.A['Armors'].O[ArmorIter];

				FOR VariantIter := 0 TO 2
				DO BEGIN
					VariantName := Skyrim.GetArmorTypeWord(VariantIter);
					AddMessage('=== Building ' + Outfit.S['ID'] + ' ' + VariantName);
					AddMessage(StringOfChar('=',80));
					AddMessage('');

					ArmaForm := MaidBuildArmaRecord(
						Plugin,
						JSON,
						Outfit,
						Armor,
						VariantName
					);
					AddMessage('');

					ArmoForm := MaidBuildArmoRecord(
						Plugin,
						JSON,
						Outfit,
						Armor,
						VariantName,
						ArmaForm
					);
					AddMessage('');

					CraftForm := MaidBuildCraftRecord(
						Plugin,
						JSON,
						Outfit,
						Armor,
						VariantName,
						ArmoForm
					);
					AddMessage('');

					TemperForm := MaidBuildTemperRecord(
						Plugin,
						JSON,
						Outfit,
						Armor,
						VariantName,
						ArmoForm
					);
					AddMessage('');

				END;
			END;
		END;

	END;

	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	FUNCTION MaidBuildArmaRecord(
		Plugin: IInterface;
		JSON: TJsonObject;
		OutfitEntry: TJsonObject;
		ArmorEntry: TJsonObject;
		VariantName: String
	): IInterface;
	VAR
		DestID: String;
		DestForm: IInterface;
		SourceID: String;
		SourceForm: IInterface;
		TextureCount: Integer;
		TextureIter: Integer;
		ShapeName: String;
		TextureSetID: String;
		TextureSet: IInterface;

	BEGIN

		SourceID := MaidReplaceFormID(
			JSON.O['Sources'].O[ArmorEntry.S['Source']].S['ARMA'],
			OutfitEntry.S['ID'],
			VariantName,
			FALSE
		);

		DestID := MaidReplaceFormID(
			JSON.O['Outputs'].O[ArmorEntry.S['Source']].S['ARMA'],
			OutfitEntry.S['ID'],
			VariantName,
			TRUE
		);

		DestForm := Skyrim.FormFind(Plugin,'ARMA',DestID);
		TextureCount := ArmorEntry.O['Textures'].Count;

		// make sure we can load the template form.

		SourceForm := Skyrim.FormFind(Plugin,'ARMA',SourceID);
		IF(NOT Assigned(SourceForm))
		THEN BEGIN
			RAISE Exception.Create('Source ARMA Not Found: ' + SourceID);
		END;

		// make sure all the textures exist before we do something crazy.

		FOR TextureIter := 0 TO (TextureCount - 1)
		DO BEGIN
			ShapeName := ArmorEntry.O['Textures'].Names[TextureIter];
			TextureSetID := ArmorEntry.O['Textures'].S[ShapeName];
			TextureSet := Skyrim.FormFind(Plugin,'TXST',TextureSetID);

			IF(NOT Assigned(TextureSet))
			THEN BEGIN
				RAISE Exception.Create('TXST Not Found: ' + TextureSetID);
			END;
		END;

		// see if this form is already done.

		IF(DestForm <> NIL)
		THEN BEGIN
			AddMessage('!!! Keeping Existing ' + DestID);
		END
		ELSE BEGIN
			AddMessage('+++ ARMA: ' + DestID);
			DestForm := FormCopy(SourceForm);
			Skyrim.FormSetEditorID(DestForm,DestID);
		END;

		// update the textures.

		FOR TextureIter := 0 TO (TextureCount - 1)
		DO BEGIN
			ShapeName := ArmorEntry.O['Textures'].Names[TextureIter];
			TextureSetID := ArmorEntry.O['Textures'].S[ShapeName];
			TextureSet := Skyrim.FormFind(Plugin,'TXST',TextureSetID);
			AddMessage('*** TXST: ' + ShapeName + ' -> ' + TextureSetID);

			Skyrim.ArmaSetModelTextureSetByShape(
				DestForm,
				Skyrim.ArmaModelFemaleThird,
				ShapeName,
				TextureSet
			);
		END;

		Result := DestForm;
	END;

	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	FUNCTION MaidBuildArmoRecord(
		Plugin: IInterface;
		JSON: TJsonObject;
		OutfitEntry: TJsonObject;
		ArmorEntry: TJsonObject;
		VariantName: String;
		ArmaForm: IInterface
	): IInterface;
	VAR
		DestID: String;
		DestForm: IInterface;
		SourceID: String;
		SourceForm: IInterface;
		ArmoName: String;
	BEGIN
		SourceID := MaidReplaceFormID(
			JSON.O['Sources'].O[ArmorEntry.S['Source']].S['ARMO'],
			OutfitEntry.S['ID'],
			VariantName,
			FALSE
		);

		DestID := MaidReplaceFormID(
			JSON.O['Outputs'].O[ArmorEntry.S['Source']].S['ARMO'],
			OutfitEntry.S['ID'],
			VariantName,
			TRUE
		);

		DestForm := Skyrim.FormFind(Plugin,'ARMO',DestID);
		ArmoName := OutfitEntry.S['Prefix'] + ' ' + VariantName + ' Maid ' + JSON.O['Names'].S[ArmorEntry.S['Source']];

		// make sure we can load the template form.

		SourceForm := Skyrim.FormFind(Plugin,'ARMO',SourceID);
		IF(NOT Assigned(SourceForm))
		THEN BEGIN
			RAISE Exception.Create('Source ARMO Not Found: ' + SourceID);
		END;

		// see if this form is already done.

		IF(DestForm <> NIL)
		THEN BEGIN
			AddMessage('!!! Keeping Existing ' + DestID);
		END
		ELSE BEGIN
			AddMessage('+++ ARMO: ' + DestID);
			DestForm := FormCopy(SourceForm);
			Skyrim.FormSetEditorID(DestForm,DestID);
		END;

		// doit reel gud

		AddMessage('*** FULL: ' + ArmoName);
		Skyrim.FormSetName(DestForm,ArmoName);

		AddMessage('*** ARMA: ' + EditorID(ArmaForm));
		Skyrim.ArmoSetModelByIndex(DestForm,0,ArmaForm);

		Result := DestForm;
	END;

	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	FUNCTION MaidBuildCraftRecord(
		Plugin: IInterface;
		Json: TJsonObject;
		OutfitEntry: TJsonObject;
		ArmorEntry: TJsonObject;
		VariantName: String;
		ArmoForm: IInterface
	): IInterface;
	VAR
		SourceID: String;
		SourceForm: IInterface;
		DestID: String;
		DestForm: IInterface;
	BEGIN
		SourceID := MaidReplaceFormID(
			JSON.O['Sources'].O[ArmorEntry.S['Source']].S['Craft'],
			OutfitEntry.S['ID'],
			VariantName,
			FALSE
		);

		DestID := MaidReplaceFormID(
			JSON.O['Outputs'].O[ArmorEntry.S['Source']].S['Craft'],
			OutfitEntry.S['ID'],
			VariantName,
			TRUE
		);

		DestForm := Skyrim.FormFind(Plugin,'COBJ',DestID);

		// check that the template exists.

		SourceForm := Skyrim.FormFind(Plugin,'COBJ',SourceID);
		IF(NOT Assigned(SourceForm))
		THEN BEGIN
			RAISE Exception.Create('Source Craft COBJ Not Found: ' + SourceID);
		END;

		// check if it is already done.

		IF(DestForm <> NIL)
		THEN BEGIN
			AddMessage('!!! Keeping Existing ' + DestID);
		END
		ELSE BEGIN
			AddMessage('+++ COBJ: ' + DestID);
			DestForm := FormCopy(SourceForm);
			Skyrim.FormSetEditorID(DestForm,DestID);
		END;

		// finish him

		AddMessage('*** CNAM: ' + EditorID(ArmoForm));
		Skyrim.CobjSetCreatedObject(DestForm,ArmoForm);

		Result := DestForm;
	END;

	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	FUNCTION MaidBuildTemperRecord(
		Plugin: IInterface;
		Json: TJsonObject;
		OutfitEntry: TJsonObject;
		ArmorEntry: TJsonObject;
		VariantName: String;
		ArmoForm: IInterface
	): IInterface;
	VAR
		SourceID: String;
		SourceForm: IInterface;
		DestID: String;
		DestForm: IInterface;
	BEGIN
		SourceID := MaidReplaceFormID(
			JSON.O['Sources'].O[ArmorEntry.S['Source']].S['Temper'],
			OutfitEntry.S['ID'],
			VariantName,
			FALSE
		);

		DestID := MaidReplaceFormID(
			JSON.O['Outputs'].O[ArmorEntry.S['Source']].S['Temper'],
			OutfitEntry.S['ID'],
			VariantName,
			TRUE
		);

		DestForm := Skyrim.FormFind(Plugin,'COBJ',DestID);

		// check that the template exists.

		SourceForm := Skyrim.FormFind(Plugin,'COBJ',SourceID);
		IF(NOT Assigned(SourceForm))
		THEN BEGIN
			RAISE Exception.Create('Source Temper COBJ Not Found: ' + SourceID);
		END;

		// check if it is already done.

		IF(DestForm <> NIL)
		THEN BEGIN
			AddMessage('!!! Keeping Existing ' + DestID);
		END
		ELSE BEGIN
			AddMessage('+++ COBJ: ' + DestID);
			DestForm := FormCopy(SourceForm);
			Skyrim.FormSetEditorID(DestForm,DestID);
		END;

		// finish him

		AddMessage('*** CNAM: ' + EditorID(ArmoForm));
		Skyrim.CobjSetCreatedObject(DestForm,ArmoForm);

		Result := DestForm;
	END;

END.