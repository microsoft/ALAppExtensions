#pragma warning disable AA0247
codeunit 5234 "Create Sust. Financial Report"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoSustAccSchName: Codeunit "Create Sust. Acc. Sch. Name";
        ContosoSustColumnLayout: Codeunit "Create Sust. Column Layout";
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertFinancialReport(ESG(), ESGLbl, ContosoSustAccSchName.ESG(), ContosoSustColumnLayout.ESGPERIODColumnName());
    end;

    procedure ESG(): Code[10]
    begin
        exit(ESGTok);
    end;

    var
        ESGTok: Label 'ESG', MaxLength = 10, Locked = true;
        ESGLbl: Label 'ESG', MaxLength = 80;
}
