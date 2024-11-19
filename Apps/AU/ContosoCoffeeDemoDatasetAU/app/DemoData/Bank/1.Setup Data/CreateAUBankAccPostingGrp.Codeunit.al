codeunit 17124 "Create AU Bank Acc Posting Grp"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertBankAccountPostingGroup(Fcy(), CreateGLAccount.BankCurrencies());
        ContosoPostingGroup.InsertBankAccountPostingGroup(Lcy(), CreateGLAccount.BankLcy());
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Bank Account Posting Group"; RunTrigger: Boolean)
    var
        CreateBankAccPostingGrp: Codeunit "Create Bank Acc. Posting Grp";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case Rec.Code of
            CreateBankAccPostingGrp.Cash():
                ValidateRecordFields(Rec, CreateGLAccount.Cash());
            CreateBankAccPostingGrp.Operating():
                ValidateRecordFields(Rec, CreateGLAccount.RevolvingCredit());
        end;
    end;

    local procedure ValidateRecordFields(var BankAccountPostingGroup: Record "Bank Account Posting Group"; GLAccountNo: Code[20])
    begin
        BankAccountPostingGroup.Validate("G/L Account No.", GLAccountNo);
    end;

    procedure Fcy(): Code[20]
    begin
        exit(FcyTok);
    end;

    procedure Lcy(): Code[20]
    begin
        exit(LcyTok);
    end;

    var
        FcyTok: Label 'FCY', MaxLength = 20, Locked = true;
        LcyTok: Label 'LCY', MaxLength = 20, Locked = true;
}