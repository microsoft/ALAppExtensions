codeunit 10506 "Create Bank Acc. Posting GrpUS"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Bank Account Posting Group")
    var
        CreateUSGLAccounts: Codeunit "Create US GL Accounts";
        CreateBankAccPostingGrp: Codeunit "Create Bank Acc. Posting Grp";
    begin
        case Rec.Code of
            CreateBankAccPostingGrp.Checking():
                ValidateRecordFields(Rec, CreateUSGLAccounts.BusinessAccountOperatingDomestic());
            CreateBankAccPostingGrp.Operating():
                ValidateRecordFields(Rec, CreateUSGLAccounts.BusinessAccountOperatingDomestic());
            CreateBankAccPostingGrp.Savings():
                ValidateRecordFields(Rec, CreateUSGLAccounts.OtherBankAccounts());
        end;
    end;

    local procedure ValidateRecordFields(var BankAccountPostingGroup: Record "Bank Account Posting Group"; GLAccountNo: Code[20])
    begin
        BankAccountPostingGroup.Validate("G/L Account No.", GLAccountNo);
    end;
}