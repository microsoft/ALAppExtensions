codeunit 17129 "Create AU Cust Posting Group"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateAUGLAccounts: Codeunit "Create AU GL Accounts";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertCustomerPostingGroup(Intercomp(), CreateAUGLAccounts.CustomersIntercompany(), CreateGLAccount.FeesAndChargesRecDom(), CreateGLAccount.PaymentDiscountsReceived(), CreateGLAccount.InvoiceRounding(), CreateGLAccount.FinanceChargesFromCustomers(), CreateGLAccount.FinanceChargesFromCustomers(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.PmtdiscGrantedDecreases(), CreateGLAccount.PmtTolGrantedDecreases(), CreateGLAccount.PmtTolGrantedDecreases(), IntercompanyLbl);
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Customer Posting Group")
    var
        CreateCustomerPostingGroup: Codeunit "Create Customer Posting Group";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case Rec.Code of
            CreateCustomerPostingGroup.Domestic(),
        CreateCustomerPostingGroup.Foreign():
                ValidateRecordFields(Rec, CreateGLAccount.PaymentDiscountsReceived(), CreateGLAccount.PmtTolGrantedDecreases());
        end;
    end;

    procedure Intercomp(): Code[20]
    begin
        exit(IntercompTok);
    end;

    local procedure ValidateRecordFields(var CustomerPostingGroup: Record "Customer Posting Group"; PaymentDiscDebitAcc: Code[20]; PaymentToleranceDebitAcc: Code[20])
    begin
        CustomerPostingGroup.Validate("Payment Disc. Debit Acc.", PaymentDiscDebitAcc);
        CustomerPostingGroup.Validate("Payment Tolerance Debit Acc.", PaymentToleranceDebitAcc);
    end;

    var
        IntercompTok: Label 'INTERCOMP', MaxLength = 20;
        IntercompanyLbl: Label 'Intercompany', MaxLength = 100;
}