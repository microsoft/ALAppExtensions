codeunit 27015 "Create CA Bank Account"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Bank Account")
    var
        CreateBankAccount: Codeunit "Create Bank Account";
        CreateCABankAccPostingGrp: Codeunit "Create CA Bank Acc Posting Grp";
        CreateBankAccPostingGrp: Codeunit "Create Bank Acc. Posting Grp";
    begin
        case Rec."No." of
            CreateBankAccount.Checking():
                ValidateRecordFields(Rec, -2163200, CreateCABankAccPostingGrp.LCY(), PostCodeLbl, LastRemittanceAdviceNoLbl, '');
            CreateBankAccount.Savings():
                ValidateRecordFields(Rec, 0, CreateBankAccPostingGrp.Cash(), PostCodeLbl, '', '');
        end;
    end;

    local procedure ValidateRecordFields(var BankAccount: Record "Bank Account"; MinBalance: Decimal; BankAccPostingGroup: Code[20]; PostCode: Code[20]; LastRemittanceAdviceNo: Code[20]; BankStatementImportFormat: Code[20])
    begin
        BankAccount.Validate("Min. Balance", MinBalance);
        BankAccount.Validate("Bank Acc. Posting Group", BankAccPostingGroup);
        BankAccount.Validate("Post Code", PostCode);
        BankAccount.Validate("Bank Statement Import Format", BankStatementImportFormat);

        if LastRemittanceAdviceNo <> '' then
            BankAccount.Validate("Last Remittance Advice No.", LastRemittanceAdviceNo);
    end;

    var
        PostCodeLbl: Label 'GB-WC1 3DG', MaxLength = 20;
        LastRemittanceAdviceNoLbl: Label '1', MaxLength = 20;
}