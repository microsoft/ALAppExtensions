codeunit 11586 "Create CH Bank Acc Posting Grp"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Bank Account Posting Group")
    var
        CreateBankAccPostingGrp: Codeunit "Create Bank Acc. Posting Grp";
        CreateCHGLAccounts: Codeunit "Create CH GL Accounts";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case Rec.Code of
            CreateBankAccPostingGrp.Cash():
                ValidateRecordFields(Rec, CreateGLAccount.Cash());
            CreateBankAccPostingGrp.Checking():
                ValidateRecordFields(Rec, CreateCHGLAccounts.BankCredit());
            CreateBankAccPostingGrp.Operating():
                ValidateRecordFields(Rec, CreateCHGLAccounts.BankOverdraft());
            CreateBankAccPostingGrp.Savings():
                ValidateRecordFields(Rec, CreateCHGLAccounts.PostAcc());
        end;
    end;

    local procedure ValidateRecordFields(var BankAccountPostingGroup: Record "Bank Account Posting Group"; GLAccountNo: Code[20])
    begin
        BankAccountPostingGroup.Validate("G/L Account No.", GLAccountNo);
    end;
}