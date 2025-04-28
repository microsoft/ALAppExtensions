#pragma warning disable AA0247
codeunit 31466 "Create Compensations Setup CZC"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCompensationsCZC: Codeunit "Contoso Compensations CZC";
        CreateGLAccountCZ: Codeunit "Create G/L Account CZ";
        CreateNoSeriesCZ: Codeunit "Create No. Series CZ";
    begin
        ContosoCompensationsCZC.InsertCompensationsSetup(CreateGLAccountCZ.Internalsettlement(), CreateNoSeriesCZ.Compensation());
    end;
}
