codeunit 11499 "Contoso Account Schedule US"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
                tabledata "Column Layout" = ri;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertColumnLayout(ColumnLayoutName: Code[10]; LineNo: Integer; ColumnNo: Code[10]; ColumnHeader: Text[30]; ColumnType: Enum "Column Layout Type"; LedgerEntryType: Enum "Column Layout Entry Type"; Formula: Code[80]; ShowOppositeSign: Boolean; Show: Enum "Column Layout Show"; ComparisonPeriodFormula: Code[20]; HideCurrencySymbol: Boolean; ComparisonDateFormula: Text[10]; RoundingFactor: Enum "Analysis Rounding Factor")
    begin
        InsertColumnLayout(ColumnLayoutName, LineNo, ColumnNo, ColumnHeader, ColumnType, LedgerEntryType, Enum::"Account Schedule Amount Type"::"Net Amount", Formula, ShowOppositeSign, Show, ComparisonPeriodFormula, HideCurrencySymbol, ComparisonDateFormula, RoundingFactor);
    end;

    procedure InsertColumnLayout(ColumnLayoutName: Code[10]; LineNo: Integer; ColumnNo: Code[10]; ColumnHeader: Text[30]; ColumnType: Enum "Column Layout Type"; LedgerEntryType: Enum "Column Layout Entry Type"; AmountType: Enum "Account Schedule Amount Type"; Formula: Code[80]; ShowOppositeSign: Boolean; Show: Enum "Column Layout Show"; ComparisonPeriodFormula: Code[20]; HideCurrencySymbol: Boolean; ComparisonDateFormula: Text[10]; RoundingFactor: Enum "Analysis Rounding Factor")
    var
        ColumnLayout: Record "Column Layout";
        Exists: Boolean;
    begin
        if ColumnLayout.Get(ColumnLayoutName, LineNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ColumnLayout.Validate("Column Layout Name", ColumnLayoutName);
        ColumnLayout.Validate("Line No.", LineNo);
        ColumnLayout.Validate("Column No.", ColumnNo);
        ColumnLayout.Validate("Column Header", ColumnHeader);
        ColumnLayout.Validate("Column Type", ColumnType);
        ColumnLayout.Validate("Ledger Entry Type", LedgerEntryType);
        ColumnLayout.Validate(Formula, Formula);
        ColumnLayout.Validate("Show Opposite Sign", ShowOppositeSign);
        ColumnLayout.Validate(Show, Show);
        ColumnLayout.Validate("Comparison Period Formula", ComparisonPeriodFormula);
        Evaluate(ColumnLayout."Comparison Date Formula", ComparisonDateFormula);
        ColumnLayout.Validate("Comparison Date Formula");
        ColumnLayout.Validate("Amount Type", AmountType);
        ColumnLayout.Validate("Hide Currency Symbol", HideCurrencySymbol);
        ColumnLayout.Validate("Rounding Factor", RoundingFactor);

        if Exists then
            ColumnLayout.Modify(true)
        else
            ColumnLayout.Insert(true);
    end;

    var
        OverwriteData: Boolean;
}