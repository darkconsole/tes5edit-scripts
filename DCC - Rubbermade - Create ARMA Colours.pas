{
	DCC - Rubbermade: Create ARMA Colours
	darkconsole http://darkconsole.tumblr.com

	This script will allow you to select a specific ARMA form and use it as a
	template to create the bajillion others for the other colour variants that
	Rubbermade supports.

	You have to select a template form that way we can detect which of the
	3d objects we should overwrite the textureset for and which one we should
	not.

	1) Make an ArmorAddon in CK with the TextureSets of your choice.
	2) Run this script on it.
}

Unit
	UserScript;

Uses
	'Dcc\Skyrim';

Var
	Colors: TStringList;
	Finishes: TStringList;
	Opacities: TStringList;

Implementation

	Procedure DccProcessArma(Form: IInterface; TextureKey: String);
	Var
		Reg: TPerlRegex;
		FormNew: IInterface;
		ElementIDNew: String;

		M: Integer;
		T: Integer;

		TextureCount: Integer;
		TextureSet: IInterface;
		TextureName: String;
	Begin
		Reg := TPerlRegex.Create();
		Reg.Subject := EditorID(Form);
		Reg.RegEx := '_[A-Za-z]+[MS](?:T[12])?\b';
		Reg.Replacement := '_' + TextureKey;
		Reg.ReplaceAll();

		ElementIDNew := Reg.Subject;
		TextureName := 'dcc_latex_Tex' + TextureKey;

		If(Assigned(Skyrim.FormFind(GetFile(Form),'ARMA',ElementIDNew)))
		Then Begin
			AddMessage('[***] ' + ElementIDNew + ' already exists');
		End
		Else Begin
			AddMessage('[+++] ' + ElementIDNew);
			Reg.RegEx := '^dcc_latex_Tex';
			FormNew := Skyrim.FormCopy(Form);
			Skyrim.FormSetEditorID(FormNew,ElementIDNew);

			M := 2;
			While(M < 5)
			Do Begin
				// foreach of the models in an arma...

				TextureCount := Skyrim.ArmaGetModelTextureCount(FormNew,M);
				If(TextureCount >= 0)
				Then Begin
					T := 0;
					While(T < TextureCount)
					Do Begin
						// foreach of the texture overrides on the model...

						TextureSet := Skyrim.ArmaGetModelTextureSetByIndex(FormNew,M,T);
						If(Assigned(TextureSet))
						Then Begin
							Reg.Subject := EditorID(TextureSet);
							If(Reg.Match())
							Then Begin
								// if the existing texture set is in rubbermade's namespace...

								Skyrim.ArmaSetModelTextureSetByIndex(
									FormNew,M,T,
									Skyrim.FormFind(GetFile(TextureSet),'TXST',TextureName)
								);
							End;
						End;
						Inc(T);
					End;
				End;
				Inc(M);
			End;
		End;

		Reg.Free();
	End;

	Procedure DccProcessSingle(Form: IInterface; TextureKey: String);
	Begin

		If(CompareText('ARMA',Signature(Form)) = 0)
		Then DccProcessArma(Form,TextureKey)
		Else DccProcessArmo(Form,TextureKey);

	End;

	Procedure DccProcess(Form: IInterface);
	Var
		C: Integer;
		F: Integer;
		O: Integer;
		TextureKey: String;
		ModelFilename: String;
	Begin

		// because the interpeter seems to lack a lot of features especally
		// with arrays and arrays in structures, we're going to do this the
		// compsci 101 way. maybe 102.

		C := 0;
		While(C < Colors.Count)
		Do Begin
			F := 0;
			While(F < Finishes.Count)
			Do Begin
				If(CompareText(Colors[C],'Clear') = 0)
				Then Begin
					DccProcessSingle(Form,(Colors[C] + '' + Finishes[F]));
				End
				Else Begin
					O := 0;
					While(O < Opacities.Count)
					Do Begin
						DccProcessSingle(Form,(Colors[C] + '' + Finishes[F] + Opacities[O]));
						Inc(O);
					End;
				End;
				Inc(F);
			End;
			Inc(C);
		End;

	End;

	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

Function Initialize: Integer;
Begin
	Colors := TStringList.Create();
	Finishes := TStringList.Create();
	Opacities := TStringList.Create();

	// these are the colour names as they appear in the TextureSet EditorID
	// of Rubbermade. We will also use these in the EditorID's of the new ARMA.
	Colors.Add('Clear');
	Colors.Add('Red');
	Colors.Add('Orange');
	Colors.Add('Yellow');
	Colors.Add('Green');
	Colors.Add('Teal');
	Colors.Add('Blue');
	Colors.Add('Purple');
	Colors.Add('Black');
	Colors.Add('White');
	Colors.Add('Natural');

	// these are the finish names as they appear in the TextureSet EditorIDs.
	Finishes.Add('M'); // matte.
	Finishes.Add('S'); // shiny.

	// these are the opacitiy names as they appear in the TextureSet EditorIDs.
	Opacities.Add('S');
	Opacities.Add('T1');
	Opacities.Add('T2');

End;

	Function Process(Form: IInterface): Integer;
	Begin

		If(CompareText('ARMA',Signature(Form)) <> 0)
		Then Begin
			If(CompareText('ARMO',Signature(Form)) <> 0)
			Then Begin
				AddMessage('[!!!] ' + EditorID(Form) + ' (' + Signature(Form) + ') is not ARMO or ARMA.');
				Result := 1;
				Exit;
			End;
		End;

		DccProcess(Form);
		Result := 1;
	End;

End.