codeunit 10503 "Create Bank Account US"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Bank Account")
    var
        CreateBankAccount: Codeunit "Create Bank Account";
    begin
        case Rec."No." of
            CreateBankAccount.Checking():
                ValidateRecordFields(Rec, -1440000, PostCodeLbl, LastRemittanceAdviceNoLbl, '');
            CreateBankAccount.Savings():
                ValidateRecordFields(Rec, 0, PostCodeLbl, '', '');
        end;
    end;

    local procedure ValidateRecordFields(var BankAccount: Record "Bank Account"; MinBalance: Decimal; PostCode: Code[20]; LastRemittanceAdviceNo: Code[20]; BankStatementImportFormat: Code[20])
    begin
        BankAccount.Validate("Min. Balance", MinBalance);
        BankAccount.Validate("Post Code", PostCode);
        BankAccount.Validate("Bank Statement Import Format", BankStatementImportFormat);
        BankAccount."Last Remittance Advice No." := LastRemittanceAdviceNo;
    end;

    var
        PostCodeLbl: Label 'GB-WC1 3DG', MaxLength = 20;
        LastRemittanceAdviceNoLbl: Label '1', MaxLength = 20;
}