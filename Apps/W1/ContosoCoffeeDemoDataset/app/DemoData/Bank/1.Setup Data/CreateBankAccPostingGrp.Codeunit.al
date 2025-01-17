codeunit 5293 "Create Bank Acc. Posting Grp"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoPostingGroup.InsertBankAccountPostingGroup(Cash(), CreateGLAccount.Cash());
        ContosoPostingGroup.InsertBankAccountPostingGroup(Checking(), CreateGLAccount.BankLCY());
        ContosoPostingGroup.InsertBankAccountPostingGroup(Operating(), CreateGLAccount.RevolvingCredit());
        ContosoPostingGroup.InsertBankAccountPostingGroup(Savings(), CreateGLAccount.GiroAccount());
    end;

    procedure Cash(): Code[20]
    begin
        exit(CashTok);
    end;

    procedure Checking(): Code[20]
    begin
        exit(CheckingTok);
    end;

    procedure Operating(): Code[20]
    begin
        exit(OperatingTok);
    end;

    procedure Savings(): Code[20]
    begin
        exit(SavingsTok);
    end;

    var
        CashTok: Label 'CASH', MaxLength = 20;
        CheckingTok: Label 'CHECKING', MaxLength = 20;
        OperatingTok: Label 'OPERATING', MaxLength = 20;
        SavingsTok: Label 'SAVINGS', MaxLength = 20;
}