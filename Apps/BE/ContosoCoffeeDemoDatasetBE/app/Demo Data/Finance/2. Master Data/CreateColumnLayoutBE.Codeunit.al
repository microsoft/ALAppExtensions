codeunit 11404 "Create Column Layout BE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateColumnLayoutNameBE: Codeunit "Create Column Layout Name BE";
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
        CreateColumnLayoutName: Codeunit "Create Column Layout Name";
    begin
        ContosoAccountSchedule.InsertColumnLayout(CreateColumnLayoutNameBE.Balance(), 10000, '', BalanceLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateColumnLayoutNameBE.Balance(), 20000, '', BalanceLastYearLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);

        ContosoAccountSchedule.SetOverwriteData(true);
        ContosoAccountSchedule.InsertColumnLayout(CreateColumnLayoutName.BalanceOnly(), 10000, '', CreateColumnLayoutNameBE.Balance(), Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.SetOverwriteData(false);

        UpdateColumLayout();
    end;

    local procedure UpdateColumLayout()
    var
        ColumLayout: Record "Column Layout";
        CreateColumnLayoutNameBE: Codeunit "Create Column Layout Name BE";
    begin
        ColumLayout.Get(CreateColumnLayoutNameBE.Balance(), 20000);

        Evaluate(ColumLayout."Comparison Date Formula", '<-1Y>');
        ColumLayout.Validate("Comparison Date Formula");
        ColumLayout.Modify(true);
    end;

    var
        BalanceLbl: Label 'Balance', MaxLength = 30;
        BalanceLastYearLbl: Label 'Balance Last Year', MaxLength = 30;
}