codeunit 5236 "Create Online Map Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoEServices: Codeunit "Contoso eServices";
        OnlineMapParaSetup: Codeunit "Create Online Map Para. Setup";
    begin
        ContosoEServices.InsertEServicesOnlineMapSetup(OnlineMapParaSetup.OnlineMapParameter(), 0, 0, false);
    end;
}