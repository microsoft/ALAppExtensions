codeunit 4792 "Create Whse Demo Accounts"
{
    TableNo = "Whse. Demo Account";

    trigger OnRun()
    begin
        Rec.ReturnAccountKey(true);

        //Examples
        // WhseDemoAccounts.AddAccount(Rec.InventoryAdjRawMat(), '7270', XInventoryAdjRawMatTok);
        // WhseDemoAccounts.AddAccount(Rec.InventoryAdjRetail(), '7170', XInventoryAdjRetailTok);

        WhseDemoAccounts.AddAccount(Rec.Finished(), '2120', XFinishedTok);
        WhseDemoAccounts.AddAccount(Rec.FinishedInterim(), '2121', XFinishedInterimTok);
        WhseDemoAccounts.AddAccount(Rec.FinishedWIP(), '2140', XFinishedWIPTok);
        WhseDemoAccounts.AddAccount(Rec.CustDomestic(), '2310', XCustDomesticTok);
        WhseDemoAccounts.AddAccount(Rec.VendDomestic(), '5410', XVendDomesticTok);
        WhseDemoAccounts.AddAccount(Rec.SalesDomestic(), '6110', XSalesDomesticTok);
        WhseDemoAccounts.AddAccount(Rec.PurchDomestic(), '7110', XPurchDomesticTok);
        WhseDemoAccounts.AddAccount(Rec.CostOfRetailSold(), '7190', XCostOfRetailSoldTok);
        WhseDemoAccounts.AddAccount(Rec.SalesVAT(), '5610', XSalesVATTok);
        WhseDemoAccounts.AddAccount(Rec.PurchaseVAT(), '5630', XPurchaseVATTok);

        OnAfterCreateDemoAccounts();
    end;

    var
        WhseDemoAccounts: Codeunit "Whse. Demo Accounts";
        XFinishedTok: Label 'Finished Goods', MaxLength = 50;
        XFinishedInterimTok: Label 'Finished Goods (Interim)', MaxLength = 50;
        XFinishedWIPTok: Label 'WIP Account, Finished goods', MaxLength = 50;
        XCustDomesticTok: Label 'Customers Domestic', MaxLength = 50;
        XVendDomesticTok: Label 'Vendors, Domestic', MaxLength = 50;
        XSalesDomesticTok: Label 'Sales, Retail - Dom.', MaxLength = 50;
        XPurchDomesticTok: Label 'Purch., Retail - Dom.', MaxLength = 50;
        XCostOfRetailSoldTok: Label 'Cost of Retail Sold', MaxLength = 50;
        XSalesVATTok: Label 'Sales VAT 25 %', MaxLength = 50;
        XPurchaseVATTok: Label 'Purchase VAT 25 %', MaxLength = 50;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDemoAccounts()
    begin
    end;
}
