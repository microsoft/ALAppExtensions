codeunit 13711 "Create Bank Acc Posting Grp DK"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateGLAccountDK: Codeunit "Create GL Acc. DK";
    begin
        ContosoPostingGroup.InsertBankAccountPostingGroup(Kassekred(), CreateGLAccount.RevolvingCredit());
        ContosoPostingGroup.InsertBankAccountPostingGroup(Valuta(), CreateGLAccountDK.Bankaccountcurrencies());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertBankAccPostingGroup(var Rec: Record "Bank Account Posting Group"; RunTrigger: Boolean)
    var
        CreateBankAccPostingGrp: Codeunit "Create Bank Acc. Posting Grp";
        CreateGLAccountDK: Codeunit "Create GL Acc. DK";
    begin
        case Rec.Code of
            CreateBankAccPostingGrp.Checking(),
            CreateBankAccPostingGrp.Savings():
                ValidateRecordFields(Rec, CreateGLAccountDK.Bank());
            CreateBankAccPostingGrp.Operating():
                ValidateRecordFields(Rec, CreateGLAccountDK.Bankaccountcurrencies());
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