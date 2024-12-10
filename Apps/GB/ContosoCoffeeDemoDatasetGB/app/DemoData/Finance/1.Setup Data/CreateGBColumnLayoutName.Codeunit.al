codeunit 10514 "Create GB Column Layout Name"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertColumnLayoutName(BalanceBudget(), BalanceBudgetLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(BalanceLastYear(), BalanceLastYearLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(NetChangeBudget(), NetChangeBudgetLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(NetChangeLastYear(), NetChangeLastYearLbl);
    end;

    procedure BalanceBudget(): Code[10]
    begin
        exit(BalanceBudgetTok);
    end;

    procedure BalanceLastYear(): Code[10]
    begin
        exit(BalanceLastYearTok);
    end;

    procedure NetChangeBudget(): Code[10]
    begin
        exit(NetChangeBudgetTok);
    end;

    procedure NetChangeLastYear(): Code[10]
    begin
        exit(NetChangeLastYearTok);
    end;

    var
        BalanceBudgetTok: Label 'BAL_BUDG', MaxLength = 10;
        BalanceLastYearTok: Label 'BAL_LAST', MaxLength = 10;
        NetChangeBudgetTok: Label 'NET_BUDG', MaxLength = 10;
        NetChangeLastYearTok: Label 'NET_LAST', MaxLength = 10;
        BalanceBudgetLbl: Label 'Balance/Budget', MaxLength = 80;
        BalanceLastYearLbl: Label 'Balance/Last Year', MaxLength = 80;
        NetChangeBudgetLbl: Label 'Net Change/Budget', MaxLength = 80;
        NetChangeLastYearLbl: Label 'Net Change/Last Year', MaxLength = 80;
}