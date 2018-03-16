{
	Create Temper Patterns
	darkconsole https://darkconsole.tumblr.com

	Given a list of COBJ forms create versions for Tempering the item.
}

Unit
	UserScript;

Uses
	'Dcc\Skyrim';

Var
	TemperType: Integer; // 1 = workbench, 2 = grindstone.
	Workbench: IInterface;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Procedure DccProcessThing(Form: IInterface);
Begin
	AddMessage('[>>>] ' + EditorID(Form) + '');
End;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Function Initialize: Integer;
Var
	InputResult: Boolean;
	InputTemperType: Integer;
Begin
	InputResult := InputQuery(
		'Select Temper Type',
		('1 = Workbench' + Skyrim.LineBreak + '2 = Grindstone' + Skyrim.LineBreak),
		InputTemperType
	);

	// stop if no input.
	If(InputResult = FALSE)
	Then Result := 1;

	// mark down what was selected in the global.
	InputTemperType := Trim(InputTemperType);
	TemperType := StrToIntDef(InputTemperType,1);
End;

Function Process(Form: IInterface): Integer;
Begin

	If(CompareText('COBJ',Signature(Form)) <> 0)
	Then Begin
		AddMessage('[!!!] ' + EditorID(Form) + ' is not an constructable.');
	End
	Else Begin
		DccProcessThing(Form);
	End;

	Result := 0;
End;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

End.
