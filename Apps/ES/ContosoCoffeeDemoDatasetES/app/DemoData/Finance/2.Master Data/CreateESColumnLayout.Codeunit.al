codeunit 10796 "Create ES Column Layout"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoESAccountSchedule: Codeunit "Contoso ES Account Schedule";
        CreateESColumnLayoutName: Codeunit "Create ES Column Layout Name";
    begin
        ContosoESAccountSchedule.InsertColumnLayout(CreateESColumnLayoutName.Balance(), 10000, '', CurrentFiscalYearLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, Enum::"Account Schedule Amount Type"::"Net Amount", '', false, Enum::"Column Layout Show"::Always, '', '');
        ContosoESAccountSchedule.InsertColumnLayout(CreateESColumnLayoutName.Balance(), 20000, '', LastFiscalYearLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, Enum::"Account Schedule Amount Type"::"Net Amount", '', false, Enum::"Column Layout Show"::Always, '', '<-1Y>');

        ContosoESAccountSchedule.InsertColumnLayout(CreateESColumnLayoutName.Pyg(), 10000, '', CurrentFiscalYearLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, Enum::"Account Schedule Amount Type"::"Net Amount", '', false, Enum::"Column Layout Show"::Always, '', '');
        ContosoESAccountSchedule.InsertColumnLayout(CreateESColumnLayoutName.Pyg(), 20000, '', LastFiscalYearLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, Enum::"Account Schedule Amount Type"::"Net Amount", '', false, Enum::"Column Layout Show"::Always, '', '<-1Y>');
    end;

    var
        CurrentFiscalYearLbl: Label 'Current Fiscal Year', MaxLength = 30;
        LastFiscalYearLbl: Label 'Last Fiscal Year', MaxLength = 30;
}