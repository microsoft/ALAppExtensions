codeunit 5574 "Create Resources Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateNoSeries: Codeunit "Create No. Series";
        ContosoProjects: Codeunit "Contoso Projects";
    begin
        ContosoProjects.InsertResourcesSetup(CreateNoSeries.Resource(), CreateNoSeries.TimeSheet());
    end;
}