codeunit 31465 "Contoso Compensations CZC"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Compensations Setup CZC" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertCompensationsSetup(CompensationBalAccountNo: Code[20]; CompensationNos: Code[20])
    var
        CompensationsSetupCZC: Record "Compensations Setup CZC";
    begin
        if not CompensationsSetupCZC.Get() then
            CompensationsSetupCZC.Insert();

        CompensationsSetupCZC.Validate("Compensation Bal. Account No.", CompensationBalAccountNo);
        CompensationsSetupCZC.Validate("Compensation Nos.", CompensationNos);
        CompensationsSetupCZC.Modify(true);
    end;
}
