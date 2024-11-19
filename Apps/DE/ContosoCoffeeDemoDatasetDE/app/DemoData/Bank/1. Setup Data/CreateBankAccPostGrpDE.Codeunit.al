codeunit 11089 "Create Bank Acc. Post. Grp DE"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertBankAccountingpostingGrp(var Rec: Record "Bank Account Posting Group")
    var
        CreateDEGLAccount: Codeunit "Create DE GL Acc.";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateBankAccPostingGroup: Codeunit "Create Bank Acc. Posting Grp";
    begin
        case Rec.Code of
            CreateBankAccPostingGroup.Checking():
                ValidateBankAccountingpostingGrp(Rec, CreateDEGLAccount.BusinessAccountOperatingDomestic());
            CreateBankAccPostingGroup.Operating():
                ValidateBankAccountingpostingGrp(Rec, CreateGLAccount.Cash());
            CreateBankAccPostingGroup.Savings():
                ValidateBankAccountingpostingGrp(Rec, CreateDEGLAccount.BusinessAccountOperatingForeign());
        end;
    end;

    local procedure ValidateBankAccountingpostingGrp(var BankAccountPostingGrp: Record "Bank Account Posting Group"; GLAccountNo: Code[20])
    begin
        BankAccountPostingGrp.Validate("G/L Account No.", GLAccountNo);
    end;
}