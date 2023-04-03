codeunit 4792 "Create Whse Demo Accounts"
{
    TableNo = "Whse. Demo Account";

    trigger OnRun()
    begin
        Rec.ReturnAccountKey(true);

        WhseDemoAccounts.AddAccount(Rec.CustDomestic(), '2310', CustDomesticTok);
        WhseDemoAccounts.AddAccount(Rec.Resale(), '2110', ResaleTok);
        WhseDemoAccounts.AddAccount(Rec.ResaleInterim(), '2111', ResaleInterimTok);
        WhseDemoAccounts.AddAccount(Rec.VendDomestic(), '5410', VendDomesticTok);
        WhseDemoAccounts.AddAccount(Rec.SalesDomestic(), '6110', SalesDomesticTok);
        WhseDemoAccounts.AddAccount(Rec.PurchDomestic(), '7110', PurchDomesticTok);
        WhseDemoAccounts.AddAccount(Rec.SalesVAT(), '5610', SalesVATTok);
        WhseDemoAccounts.AddAccount(Rec.PurchaseVAT(), '5630', PurchaseVATTok);

        OnAfterCreateDemoAccounts();
    end;

    var
        WhseDemoAccounts: Codeunit "Whse. Demo Accounts";
        ResaleTok: Label 'Resale', MaxLength = 50;
        ResaleInterimTok: Label 'Resale (Interim)', MaxLength = 50;
        CustDomesticTok: Label 'Customers Domestic', MaxLength = 50;
        VendDomesticTok: Label 'Vendors, Domestic', MaxLength = 50;
        SalesDomesticTok: Label 'Sales, Retail - Dom.', MaxLength = 50;
        PurchDomesticTok: Label 'Purch., Retail - Dom.', MaxLength = 50;
        SalesVATTok: Label 'Sales VAT 25 %', MaxLength = 50;
        PurchaseVATTok: Label 'Purchase VAT 25 %', MaxLength = 50;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDemoAccounts()
    begin
    end;
}
