	{
	Skyrim: Display Model 2
	Speed up the process of creating Idles with Packages that use them.
}

Unit
	UserScript;
	
Const
	TemplateIdle = $1d97;
	TemplatePkg  = $1d98;
	
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

Procedure DccSetAnimationEvent(Form: IInterface; EventName: String);
Begin
	SetElementEditValues(Form,'ENAM - Animation Event',EventName);
End;

Procedure DccSetIdleAnimation(Form: IInterface; IdleForm: IInterface);
Begin
	SetNativeValue(ElementByIndex(ElementByPath(Form,'Idle Animations\IDLA - Animations'),0),FormID(IdleForm));
End;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Procedure DccCreateNewIdle(Plugin: IInterface);
Var
	IdleEditorID: String;  // input
	IdleEventName: String; // input
	FormNewIdle: IInterface;
	FormNewPkg: IInterface;
	InputResult: Boolean;
Begin
	AddMessage('Creating a new Idle and Package in ' + Name(Plugin));
	
	////////
	////////
	
	InputResult := TRUE;
	
	While InputResult
	Do Begin

		IdleEditorID := NULL;
		IdleEventName := NULL;
		
		InputResult := InputQuery(
			'Enter Editor ID',
			'Value will be prefixed with "dcc_dm_Idle" and "dcc_dm_PackageIdle" (Ex: Hogtie1)',
			IdleEditorID
		);
		
		If(InputResult = FALSE)
		Then Begin
			Exit;
		End;
		
		InputResult := InputQuery(
			'Enter Animation Event Name',
			'Enter the value given to SAE to trigger the animation.',
			IdleEventName
		);
		
		If(InputResult = FALSE)
		Then Begin
			Exit;
		End;	

	
		////////
		////////
		
		FormNewIdle := DccCreateForm(TemplateIdle,Plugin);
		DccSetEditorID(FormNewIdle,('dcc_dm_Idle' + IdleEditorID));
		DccSetAnimationEvent(FormNewIdle,IdleEventName);
		AddMessage('Created ' + Name(FormNewIdle));
		
		FormNewPkg := DccCreateForm(TemplatePkg,Plugin);
		DccSetEditorId(FormNewPkg,('dcc_dm_PackageIdle' + IdleEditorID));
		DccSetIdleAnimation(FormNewPkg,FormNewIdle);
		AddMessage('Created ' + Name(FormNewPkg));
	End;
	
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
		If(CompareText(GetFileName(Plugin),'dcc-dm2.esp') = 0)
		Then Begin
			DccCreateNewIdle(Plugin);
		End;
	End;

End;

End.
