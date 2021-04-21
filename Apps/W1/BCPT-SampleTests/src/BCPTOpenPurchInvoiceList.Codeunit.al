codeunit 149112 "BCPT Open Purch. Invoice List"
{
    // Test codeunits can only run in foreground (UI)
    Subtype = Test;

    trigger OnRun();
    begin
    end;

    [Test]
    procedure OpenPurchaseInvoices()
    var
        PurchaseInvoices: testpage "Purchase Invoices";
    begin
        PurchaseInvoices.OpenView();
        PurchaseInvoices.Close();
    end;
}