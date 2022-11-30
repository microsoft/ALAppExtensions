codeunit 4792 "Create Whse Demo Accounts"
{
    TableNo = "Whse. Demo Account";

    trigger OnRun()
    begin
        Rec.ReturnAccountKey(true);

        WhseDemoAccounts.AddAccount(Rec.CustDomestic(), '2310', XCustDomesticTok);
        WhseDemoAccounts.AddAccount(Rec.Resale(), '2110', XResaleTok);
        WhseDemoAccounts.AddAccount(Rec.ResaleInterim(), '2111', XResaleInterimTok);
        WhseDemoAccounts.AddAccount(Rec.VendDomestic(), '5410', XVendDomesticTok);
        WhseDemoAccounts.AddAccount(Rec.SalesDomestic(), '6110', XSalesDomesticTok);
        WhseDemoAccounts.AddAccount(Rec.PurchDomestic(), '7110', XPurchDomesticTok);
        WhseDemoAccounts.AddAccount(Rec.SalesVAT(), '5610', XSalesVATTok);
        WhseDemoAccounts.AddAccount(Rec.PurchaseVAT(), '5630', XPurchaseVATTok);

        OnAfterCreateDemoAccounts();
    end;

    var
        WhseDemoAccounts: Codeunit "Whse. Demo Accounts";
        XResaleTok: Label 'Resale', MaxLength = 50;
        XResaleInterimTok: Label 'Resale (Interim)', MaxLength = 50;
        XCustDomesticTok: Label 'Customers Domestic', MaxLength = 50;
        XVendDomesticTok: Label 'Vendors, Domestic', MaxLength = 50;
        XSalesDomesticTok: Label 'Sales, Retail - Dom.', MaxLength = 50;
        XPurchDomesticTok: Label 'Purch., Retail - Dom.', MaxLength = 50;
        XSalesVATTok: Label 'Sales VAT 25 %', MaxLength = 50;
        XPurchaseVATTok: Label 'Purchase VAT 25 %', MaxLength = 50;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDemoAccounts()
    begin
    end;
}
