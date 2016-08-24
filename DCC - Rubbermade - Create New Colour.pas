{
	Rubbermade:
	Create new colour TextureSets
	darkconsole http://darkconsole.tumblr.com
}

Unit
	UserScript;

Const
	TemplateTxst = $d62;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Function DccCreateForm(TemplateID: Integer; Plugin: IInterface): IInterface;
Var
	FormID: Integer;
Begin
	AddMessage('Load Order ' + IntToStr(GetLoadOrder(Plugin)));
	FormID := (GetLoadOrder(Plugin) shl 24) + TemplateID;

	AddMessage('Creating Form From Template: ' + IntToHex(FormID,8));

	Result := wbCopyElementToFile(
		DccGetForm(FormID),
		Plugin,
		True, True
	);
End;

Function DccGetForm(FormID: Integer): IInterface;
Begin
	Result := RecordByFormID(
		FileByLoadOrder(FormID shr 24),
		LoadOrderFormIDtoFileFormID( FileByLoadOrder(FormID shr 24), FormID ),
		True
	);
End;

Procedure DccSetEditorID(Form: IInterface; EditorID: String);
Begin
	SetElementEditValues(Form,'EDID - Editor ID',EditorID);
End;

Procedure DccSetTextureDiffuse(Form: IInterface; Filename: String);
Begin
	SetElementEditValues(Form,'Textures (RGB/A)\TX00 - Difuse',Filename);
End;

Procedure DccSetTextureNormal(Form: IInterface; FileName: String);
Begin
	SetElementEditValues(Form,'Textures (RGB/A)\TX01 - Normal/Gloss',Filename);
End;

Procedure DccSetTextureEnv(Form: IInterface; FileName: String);
Begin
	SetElementEditValues(Form,'Textures (RGB/A)\TX05 - Environment',Filename);
End;

Function DccFirstCase(StrIn: string): String;
Var
	StrOut: String;
	Iter: Int;
Begin

	Iter := 1;
	StrOut := '';

	While Iter <= Length(StrIn)
	Do Begin

		If(Iter = 1)
		Then Begin
			StrOut := StrOut + UpperCase(Copy(StrIn,Iter,1));
		End
		Else Begin
			StrOut := StrOut + LowerCase(Copy(StrIn,Iter,1));
		End;

		Inc(Iter)
	End;


	Result := StrOut;
End;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Procedure DccCreateTxst(Plugin: IInterface; ColourName: String; ColourFile: String; FinishKey: String; SolidKey: String);
Var
	Form: IInterface;
	EditorID: String;
	DiffuseFile: String;
	NormalFile: String;
	FinishFile: String;
Begin

	if(LowerCase(FinishKey) = 's')
	Then Begin
		FinishFile := 'e.shine.dds';
	End
	Else Begin
		FinishFile := 'e.matte.dds';
	End;

	DiffuseFile := 'd.' + LowerCase(SolidKey) + '-' + LowerCase(ColourFile) + '.dds';
	NormalFile := 'n.' + LowerCase(SolidKey) + '.dds';
	EditorID := 'dcc_latex_Tex' + DccFirstCase(ColourFile) + '_' + UpperCase(FinishKey) + UpperCase(SolidKey);

	AddMessage(EditorID + ': ' + DiffuseFile + ', ' + NormalFile + ', ' + FinishFile);

	Form := DccCreateForm(TemplateTxst,Plugin);
	DccSetEditorID(Form,EditorID);
	DccSetTextureDiffuse(Form,('dcc-rubbermade\common\' + DiffuseFile));
	DccSetTextureNormal(Form,('dcc-rubbermade\common\' + NormalFile));
	DccSetTextureEnv(Form,('dcc-rubbermade\common\' + FinishFile));

End;

Procedure DccCreateTxstSolidShiny(Plugin: IInterface; ColourName: String; ColourFile: String);
Begin
	DccCreateTxst(Plugin,ColourName,ColourFile,'s','s');
End;

Procedure DccCreateTxstTransparentShiny(Plugin: IInterface; ColourName: String; ColourFile: String);
Begin
	DccCreateTxst(Plugin,ColourName,ColourFile,'s','t1');
End;

Procedure DccCreateTxstTranslucentShiny(Plugin: IInterface; ColourName: String; ColourFile: String);
Begin
	DccCreateTxst(Plugin,ColourName,ColourFile,'s','t2');
End;

Procedure DccCreateTxstSolidMatte(Plugin: IInterface; ColourName: String; ColourFile: String);
Begin
	DccCreateTxst(Plugin,ColourName,ColourFile,'m','s');
End;

Procedure DccCreateTxstTransparentMatte(Plugin: IInterface; ColourName: String; ColourFile: String);
Begin
	DccCreateTxst(Plugin,ColourName,ColourFile,'m','t1');
End;

Procedure DccCreateTxstTranslucentMatte(Plugin: IInterface; ColourName: String; ColourFile: String);
Begin
	DccCreateTxst(Plugin,ColourName,ColourFile,'m','t2');
End;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Procedure DccCreateTextureSet(Plugin: IInterface);
Var
	ColourName: String; // input
	ColourFile: String; // input

	TempString: String;

	InputResult: Boolean;
	FormNewTxst: IInterface;
Begin

	AddMessage('Creating new Texture Set Set in ' + Name(Plugin));

	////////
	////////

	InputResult := TRUE;

	While InputResult
	Do Begin

		ColourName := NULL;
		ColourFile := NULL;

		InputResult := InputQuery(
			'Enter Colour Name',
			'Type it as you would want it displayed, with caps etc.',
			ColourName
		);

		If(InputResult = FALSE)
		Then Begin
			Exit;
		End;

		InputResult := InputQuery(
			'Enter Colour File',
			'Type it as it appears in the filenames. Note your files should follow the file naming system.',
			ColourFile
		);

		If(InputResult = FALSE)
		Then Begin
			Exit;
		End;

		////////
		////////

		DccCreateTxstSolidShiny(Plugin,ColourName,ColourFile);
		DccCreateTxstTransparentShiny(Plugin,ColourName,ColourFile);
		DccCreateTxstTranslucentShiny(Plugin,ColourName,ColourFile);
		DccCreateTxstSolidMatte(Plugin,ColourName,ColourFile);
		DccCreateTxstTransparentMatte(Plugin,ColourName,ColourFile);
		DccCreateTxstTranslucentMatte(Plugin,ColourName,ColourFile);

	End;


	////////
	////////



End;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Function Initialize: Integer;
Var
	Iter: Integer;
	Plugin: IInterface;
Begin
	For Iter := 0 To FileCount - 1
	Do Begin
		Plugin := FileByIndex(Iter);
		AddMessage('-- ' + IntToStr(Iter) + ' ' + Name(Plugin));
		If(CompareText(GetFileName(Plugin),'dcc-rubbermade.esm') = 0)
		Then Begin
			DccCreateTextureSet(Plugin);
		End;
	End;

End;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

End.
