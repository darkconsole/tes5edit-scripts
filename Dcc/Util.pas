
Unit
	Util;

Interface
	Function FirstCase: String;

Implementation

	Function FirstCase(StrIn: String): String;
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

	Function PregReplace(Format: String; Replacement: String; Source: String): String;
	Var
		RegEx: TPerlRegex;
	Begin

		RegEx := TPerlRegex.Create();
		RegEx.RegEx := Format;
		RegEx.Replacement := Replacement;
		RegEx.Options := [ preCaseless ];
		RegEx.Subject := Source;

		If(RegEx.Match())
		Then Begin
			RegEx.ReplaceAll();
		End;

		Result := RegEx.Subject;
	End;

End.
