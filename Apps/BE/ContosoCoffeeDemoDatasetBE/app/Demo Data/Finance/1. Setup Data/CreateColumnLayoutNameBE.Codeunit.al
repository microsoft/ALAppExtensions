codeunit 11403 "Create Column Layout Name BE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertColumnLayoutName(Balance(), ManagementBalanceDescLbl);
    end;

    procedure Balance(): Code[10]
    begin
        exit(BalanceTok);
    end;

    var
        BalanceTok: Label 'BALANCE', MaxLength = 10, Locked = true;
        ManagementBalanceDescLbl: Label 'Management Balance', MaxLength = 80;
}
