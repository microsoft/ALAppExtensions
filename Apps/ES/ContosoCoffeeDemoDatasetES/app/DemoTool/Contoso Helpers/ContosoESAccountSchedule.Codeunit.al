codeunit 10797 "Contoso ES Account Schedule"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
                tabledata "Column Layout" = ri;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertColumnLayout(ColumnLayoutName: Code[10]; LineNo: Integer; ColumnNo: Code[10]; ColumnHeader: Text[30]; ColumnType: Enum "Column Layout Type"; LedgerEntryType: Enum "Column Layout Entry Type"; AmountType: Enum "Account Schedule Amount Type"; Formula: Code[80]; ShowOppositeSign: Boolean; Show: Enum "Column Layout Show"; ComparisonPeriodFormula: Code[20]; ComparisonDateFormula: Code[10])
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
        ColumnLayout.Validate("Amount Type", AmountType);

        if Exists then
            ColumnLayout.Modify(true)
        else
            ColumnLayout.Insert(true);
    end;

    var
        OverwriteData: Boolean;
}