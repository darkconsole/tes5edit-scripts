
Unit Util;

Interface
	Function FirstCase: String;

Implementation

	Function FirstCase(StrIn: string): String;
	Var
		StrOut: String;
		Iter: Int;
	Begin
		// tes5edit does not seem to have very many nice string functions
		// even basic ones like LeftStr or RightStr that most pascal/del
		// documentations reference.

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

End.
