codeunit 10884 "Create Cust. Posting Grp FR"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateFRGLAccount: Codeunit "Create GL Account FR";
    begin
        ContosoPostingGroup.InsertCustomerPostingGroup(FRANCEEFF(), CreateFRGLAccount.ClientsBillsReceivable(), CreateGLAccount.FeesAndChargesRecDom(), CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.InvoiceRounding(), CreateGLAccount.FinanceChargesFromCustomers(), CreateGLAccount.FinanceChargesfromCustomers(), CreateFRGLAccount.ApplicationRoundingLcy(), CreateGLAccount.PmtTolReceivedDecreases(), CreateFRGLAccount.ApplicationRoundDebit(), CreateFRGLAccount.ApplicationRoundingDebit(), CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.PaymentToleranceGranted(), CreateGLAccount.PmtTolGrantedDecreases(), '');
        ContosoPostingGroup.InsertCustomerPostingGroup(FRANCEENC(), CreateFRGLAccount.BillsForCollection(), CreateGLAccount.FeesAndChargesRecDom(), CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.InvoiceRounding(), CreateGLAccount.FinanceChargesFromCustomers(), CreateGLAccount.FinanceChargesfromCustomers(), CreateFRGLAccount.ApplicationRoundingLcy(), CreateGLAccount.PmtTolReceivedDecreases(), CreateFRGLAccount.ApplicationRoundDebit(), CreateFRGLAccount.ApplicationRoundingDebit(), CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.PaymentToleranceGranted(), CreateGLAccount.PmtTolGrantedDecreases(), '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCustomerPostingGrp(var Rec: Record "Customer Posting Group")
    var
        CreateFRGLAccount: Codeunit "Create GL Account FR";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateCustomerPostingGrp: Codeunit "Create Customer Posting Group";
    begin
        case Rec.Code of
            CreateCustomerPostingGrp.Domestic():
                ValidateCustomerPostingGroup(Rec, CreateGLAccount.CustomersDomestic(), CreateGLAccount.FeesAndChargesRecDom(), CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.InvoiceRounding(), CreateGLAccount.FinanceChargesFromCustomers(), CreateGLAccount.FinanceChargesfromCustomers(), CreateFRGLAccount.ApplicationRoundingLcy(), CreateGLAccount.PmtTolReceivedDecreases(), CreateFRGLAccount.ApplicationRoundDebit(), CreateFRGLAccount.ApplicationRoundingDebit(), CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.PaymentToleranceGranted(), CreateGLAccount.PmtTolGrantedDecreases());
            CreateCustomerPostingGrp.EU():
                ValidateCustomerPostingGroup(Rec, CreateGLAccount.CustomersDomestic(), CreateGLAccount.FeesAndChargesRecDom(), CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.InvoiceRounding(), CreateGLAccount.FinanceChargesfromCustomers(), CreateGLAccount.FinanceChargesfromCustomers(), CreateFRGLAccount.ApplicationRoundingLcy(), CreateGLAccount.PmtTolReceivedDecreases(), CreateFRGLAccount.ApplicationRoundDebit(), CreateFRGLAccount.ApplicationRoundingDebit(), CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.PaymentToleranceGranted(), CreateGLAccount.PmtTolGrantedDecreases());
            CreateCustomerPostingGrp.Foreign():
                ValidateCustomerPostingGroup(Rec, CreateGLAccount.CustomersForeign(), CreateGLAccount.FeesAndChargesRecDom(), CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.InvoiceRounding(), CreateGLAccount.FinanceChargesfromCustomers(), CreateGLAccount.FinanceChargesfromCustomers(), CreateFRGLAccount.ApplicationRoundingLcy(), CreateGLAccount.PmtTolReceivedDecreases(), CreateFRGLAccount.ApplicationRoundDebit(), CreateFRGLAccount.ApplicationRoundingDebit(), CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.PaymentToleranceGranted(), CreateGLAccount.PmtTolGrantedDecreases());
        end;
    end;

    local procedure ValidateCustomerPostingGroup(var CustomerPostingGroup: Record "Customer Posting Group"; ReceivablesAccount: Code[20]; ServiceChargeAcc: Code[20]; PaymentDiscDebitAcc: Code[20]; InvoiceRoundingAccount: Code[20]; AdditionalFeeAccount: Code[20]; InterestAccount: Code[20]; DebitCurrApplnRndgAcc: Code[20]; CreditCurrApplnRndgAcc: Code[20]; DebitRoundingAccount: Code[20]; CreditRoundingAccount: Code[20]; PaymentDiscCreditAcc: Code[20]; PaymentToleranceDebitAcc: Code[20]; PaymentToleranceCreditAcc: Code[20])
    begin
        CustomerPostingGroup.Validate("Receivables Account", ReceivablesAccount);
        CustomerPostingGroup.Validate("Service Charge Acc.", ServiceChargeAcc);
        CustomerPostingGroup.Validate("Payment Disc. Debit Acc.", PaymentDiscDebitAcc);
        CustomerPostingGroup.Validate("Invoice Rounding Account", InvoiceRoundingAccount);
        CustomerPostingGroup.Validate("Additional Fee Account", AdditionalFeeAccount);
        CustomerPostingGroup.Validate("Interest Account", InterestAccount);
        CustomerPostingGroup.Validate("Debit Curr. Appln. Rndg. Acc.", DebitCurrApplnRndgAcc);
        CustomerPostingGroup.Validate("Credit Curr. Appln. Rndg. Acc.", CreditCurrApplnRndgAcc);
        CustomerPostingGroup.Validate("Debit Rounding Account", DebitRoundingAccount);
        CustomerPostingGroup.Validate("Credit Rounding Account", CreditRoundingAccount);
        CustomerPostingGroup.Validate("Payment Disc. Credit Acc.", PaymentDiscCreditAcc);
        CustomerPostingGroup.Validate("Payment Tolerance Debit Acc.", PaymentToleranceDebitAcc);
        CustomerPostingGroup.Validate("Payment Tolerance Credit Acc.", PaymentToleranceCreditAcc);
    end;

    procedure FRANCEEFF(): Code[20]
    begin
        exit(FRANCEEFFTok);
    end;

    procedure FRANCEENC(): Code[20]
    begin
        exit(FRANCEENCTok);
    end;

    var
        FRANCEEFFTok: Label 'FRANCE-EFF', MaxLength = 20;
        FRANCEENCTok: Label 'FRANCE-ENC', MaxLength = 20;
}