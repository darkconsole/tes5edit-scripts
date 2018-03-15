Unit
	UserScript;

Uses
	'Dcc\Skyrim',
	'Dcc\MaidOutfit';

{
	Build the Maid Outfit Variants.
	-------------------------------
	Hotkey: Ctrl+B
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Procedure DccBuildForms(Plugin: IInterface);
Begin
	AddMessage('');
	AddMessage('=== Beginning Maid Form Build: ' + Name(Plugin));
	AddMessage(StringOfChar('=',80));
	AddMessage('');
	MaidBuildArma(Plugin);
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

		If(CompareText(GetFileName(Plugin),'dcc-maid-build.esp') = 0)
		Then Begin
			DccBuildForms(Plugin);
		End;
	End;

End;

End.
