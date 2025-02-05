codeunit 5227 "Create Customer Posting Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoPostingGroup.InsertCustomerPostingGroup(Domestic(), CreateGLAccount.CustomersDomestic(), CreateGLAccount.FeesandChargesRecDom(), CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.InvoiceRounding(), CreateGLAccount.FinanceChargesfromCustomers(), CreateGLAccount.FinanceChargesfromCustomers(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.PmtDiscGrantedDecreases(), CreateGLAccount.PaymentToleranceGranted(), CreateGLAccount.PmtTolGrantedDecreases(), DomesticCustomersLbl);
        ContosoPostingGroup.InsertCustomerPostingGroup(EU(), CreateGLAccount.CustomersForeign(), CreateGLAccount.FeesandChargesRecDom(), CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.InvoiceRounding(), CreateGLAccount.FinanceChargesfromCustomers(), CreateGLAccount.FinanceChargesfromCustomers(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.PmtDiscGrantedDecreases(), CreateGLAccount.PaymentToleranceGranted(), CreateGLAccount.PmtTolGrantedDecreases(), EUCustomersLbl);
        ContosoPostingGroup.InsertCustomerPostingGroup(Foreign(), CreateGLAccount.CustomersForeign(), CreateGLAccount.FeesandChargesRecDom(), CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.InvoiceRounding(), CreateGLAccount.FinanceChargesfromCustomers(), CreateGLAccount.FinanceChargesfromCustomers(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.PmtDiscGrantedDecreases(), CreateGLAccount.PaymentToleranceGranted(), CreateGLAccount.PmtTolGrantedDecreases(), ForeignCustomersLbl);
    end;

    procedure Domestic(): Code[20]
    begin
        exit(DomesticTok);
    end;

    procedure EU(): Code[20]
    begin
        exit(EUTok);
    end;

    procedure Foreign(): Code[20]
    begin
        exit(ForeignTok);
    end;

    var
        DomesticCustomersLbl: Label 'Domestic customers', MaxLength = 100;
        EUCustomersLbl: Label 'Customers in EU', MaxLength = 100;
        ForeignCustomersLbl: Label 'Foreign customers (not EU)', MaxLength = 100;
        DomesticTok: Label 'DOMESTIC', MaxLength = 20;
        EUTok: Label 'EU', MaxLength = 20;
        ForeignTok: Label 'FOREIGN', MaxLength = 20;
}