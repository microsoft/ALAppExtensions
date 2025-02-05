codeunit 11509 "Create GB Bank Acc Posting Grp"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Bank Account Posting Group"; RunTrigger: Boolean)
    var
        CreateBankAccPostingGrp: Codeunit "Create Bank Acc. Posting Grp";
        CreateGBGLAccounts: Codeunit "Create GB GL Accounts";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case Rec.Code of
            CreateBankAccPostingGrp.Checking():
                ValidateRecordFields(Rec, CreateGBGLAccounts.BusinessAccountOperatingDomestic());
            CreateBankAccPostingGrp.Operating():
                ValidateRecordFields(Rec, CreateGLAccount.Cash());
            CreateBankAccPostingGrp.Savings():
                ValidateRecordFields(Rec, CreateGBGLAccounts.OtherBankAccounts());
        end;
    end;

    local procedure ValidateRecordFields(var BankAccountPostingGroup: Record "Bank Account Posting Group"; GLAccountNo: Code[20])
    begin
        BankAccountPostingGroup.Validate("G/L Account No.", GLAccountNo);
    end;
}