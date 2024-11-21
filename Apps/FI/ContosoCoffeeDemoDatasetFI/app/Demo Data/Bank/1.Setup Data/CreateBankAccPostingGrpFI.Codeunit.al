codeunit 13422 "Create Bank Acc Posting Grp FI"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertBankAccPostingGroup(var Rec: Record "Bank Account Posting Group"; RunTrigger: Boolean)
    var
        CreateBankAccPostingGrp: Codeunit "Create Bank Acc. Posting Grp";
        CreateFIGLAccount: Codeunit "Create FI GL Accounts";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case Rec.Code of
            CreateBankAccPostingGrp.Cash():
                ValidateRecordFields(Rec, CreateGLAccount.Cash());
            CreateBankAccPostingGrp.Checking():
                ValidateRecordFields(Rec, CreateFIGLAccount.Bank3());
            CreateBankAccPostingGrp.Operating():
                ValidateRecordFields(Rec, CreateFIGLAccount.Loansfromcreditinstitutions1());
            CreateBankAccPostingGrp.Savings():
                ValidateRecordFields(Rec, CreateFIGLAccount.BankSampo());
        end;
    end;

    local procedure ValidateRecordFields(var BankAccountPostingGroup: Record "Bank Account Posting Group"; GLAccountNo: Code[20])
    begin
        BankAccountPostingGroup.Validate("G/L Account No.", GLAccountNo);
    end;

    procedure Kassekred(): Code[20]
    begin
        exit(KassekredTok);
    end;

    procedure Valuta(): Code[20]
    begin
        exit(ValutaTok);
    end;

    var
        KassekredTok: Label 'KASSEKRED', Locked = true;
        ValutaTok: Label 'VALUTA', Locked = true;
}