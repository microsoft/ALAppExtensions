codeunit 5568 "Create Vendor Posting Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoPostingGroup.InsertVendorPostingGroup(Domestic(), CreateGLAccount.VendorsDomestic(), CreateGLAccount.OtherCostsofOperations(), CreateGLAccount.PmtDiscReceivedDecreases(), CreateGLAccount.InvoiceRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.PaymentDiscountsReceived(), CreateGLAccount.PmtTolReceivedDecreases(), CreateGLAccount.PaymentToleranceReceived(), DomesticVendorsLbl, false);
        ContosoPostingGroup.InsertVendorPostingGroup(EU(), CreateGLAccount.VendorsForeign(), CreateGLAccount.OtherCostsofOperations(), CreateGLAccount.PmtDiscReceivedDecreases(), CreateGLAccount.InvoiceRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.PaymentDiscountsReceived(), CreateGLAccount.PmtTolReceivedDecreases(), CreateGLAccount.PaymentToleranceReceived(), EUVendorsLbl, false);
        ContosoPostingGroup.InsertVendorPostingGroup(Foreign(), CreateGLAccount.VendorsForeign(), CreateGLAccount.OtherCostsofOperations(), CreateGLAccount.PmtDiscReceivedDecreases(), CreateGLAccount.InvoiceRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.PaymentDiscountsReceived(), CreateGLAccount.PmtTolReceivedDecreases(), CreateGLAccount.PaymentToleranceReceived(), ForeignVendorsLbl, false);
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
        DomesticTok: Label 'Domestic', MaxLength = 20;
        EUTok: Label 'EU', MaxLength = 20;
        ForeignTok: Label 'FOREIGN', MaxLength = 20;
        DomesticVendorsLbl: Label 'Domestic vendors', MaxLength = 100;
        EUVendorsLbl: Label 'Vendors in EU', MaxLength = 100;
        ForeignVendorsLbl: Label 'Foreign vendors (not EU)', MaxLength = 100;
}