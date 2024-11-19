codeunit 14120 "Create Bank Account MX"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertBankAccount(var Rec: Record "Bank Account")
    var
        CreateBankAccount: Codeunit "Create Bank Account";
    begin
        case Rec."No." of
            CreateBankAccount.Checking():
                ValidateRecordFields(Rec, -12960000, '', '1', PostCode6100Lbl);
            CreateBankAccount.Savings():
                ValidateRecordFields(Rec, 0, '', '', PostCode6100Lbl);
        end;
    end;

    local procedure ValidateRecordFields(var BankAccount: Record "Bank Account"; MinBalance: Decimal; BankStatementImportFormat: Code[20]; LastRemittanceAdviceNo: Code[20]; PostCode: Code[20])
    begin
        BankAccount.Validate("Min. Balance", MinBalance);
        BankAccount.Validate("Bank Statement Import Format", BankStatementImportFormat);
        if LastRemittanceAdviceNo <> '' then
            BankAccount.Validate("Last Remittance Advice No.", LastRemittanceAdviceNo);
        BankAccount.Validate("Post Code", PostCode);
    end;

    var
        PostCode6100Lbl: Label 'GB-WC1 3DG', MaxLength = 20;
}