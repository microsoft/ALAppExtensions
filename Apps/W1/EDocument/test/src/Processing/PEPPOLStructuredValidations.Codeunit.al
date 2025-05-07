codeunit 139896 "PEPPOL Structured Validations"
{
    var
        Assert: Codeunit Assert;

    internal procedure AssertFullEDocumentContentExtracted(EDocumentEntryNo: Integer)
    var
        GLSetup: Record "General Ledger Setup";
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
    begin
        GLSetup.Get();
        EDocumentPurchaseHeader.Get(EDocumentEntryNo);
        Assert.AreEqual('103033', EDocumentPurchaseHeader."Sales Invoice No.", 'The sales invoice number does not allign with the mock data.');
        Assert.AreEqual(DMY2Date(22, 01, 2026), EDocumentPurchaseHeader."Document Date", 'The invoice date does not allign with the mock data.');
        Assert.AreEqual(DMY2Date(22, 02, 2026), EDocumentPurchaseHeader."Due Date", 'The due date does not allign with the mock data.');
        Assert.AreEqual('XYZ', EDocumentPurchaseHeader."Currency Code", 'The currency code does not allign with the mock data.');
        Assert.AreEqual('2', EDocumentPurchaseHeader."Purchase Order No.", 'The purchase order number does not allign with the mock data.');
        // Assert.AreEqual('', EDocumentPurchaseHeader."Vendor GLN", 'The endpoint schema is not provided to populate the GLN.');
        Assert.AreEqual('CRONUS International', EDocumentPurchaseHeader."Vendor Company Name", 'The vendor name does not allign with the mock data.');
        Assert.AreEqual('Main Street, 14', EDocumentPurchaseHeader."Vendor Address", 'The vendor street does not allign with the mock data.');
        Assert.AreEqual('GB123456789', EDocumentPurchaseHeader."Vendor VAT Id", 'The vendor VAT id does not allign with the mock data.');
        Assert.AreEqual('Jim Olive', EDocumentPurchaseHeader."Vendor Contact Name", 'The vendor contact name does not allign with the mock data.');
        Assert.AreEqual('The Cannon Group PLC', EDocumentPurchaseHeader."Customer Company Name", 'The customer name does not allign with the mock data.');
        Assert.AreEqual('GB789456278', EDocumentPurchaseHeader."Customer VAT Id", 'The customer VAT id does not allign with the mock data.');
        Assert.AreEqual('192 Market Square', EDocumentPurchaseHeader."Customer Address", 'The customer address does not allign with the mock data.');

        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocumentEntryNo);
        EDocumentPurchaseLine.FindSet();
        Assert.AreEqual(1, EDocumentPurchaseLine."Quantity", 'The quantity in the purchase line does not allign with the mock data.');
        Assert.AreEqual('PCS', EDocumentPurchaseLine."Unit of Measure", 'The unit of measure in the purchase line does not allign with the mock data.');
        Assert.AreEqual(4000, EDocumentPurchaseLine."Sub Total", 'The total amount before taxes in the purchase line does not allign with the mock data.');
        Assert.AreEqual('XYZ', EDocumentPurchaseLine."Currency Code", 'The currency code in the purchase line does not allign with the mock data.');
        Assert.AreEqual(0, EDocumentPurchaseLine."Total Discount", 'The total discount in the purchase line does not allign with the mock data.');
        Assert.AreEqual('Bicycle', EDocumentPurchaseLine.Description, 'The product description in the purchase line does not allign with the mock data.');
        Assert.AreEqual('1000', EDocumentPurchaseLine."Product Code", 'The product code in the purchase line does not allign with the mock data.');
        Assert.AreEqual(25, EDocumentPurchaseLine."VAT Rate", 'The VAT rate in the purchase line does not allign with the mock data.');
        Assert.AreEqual(4000, EDocumentPurchaseLine."Unit Price", 'The unit price in the purchase line does not allign with the mock data.');

        EDocumentPurchaseLine.Next();
        Assert.AreEqual(2, EDocumentPurchaseLine."Quantity", 'The quantity in the purchase line does not allign with the mock data.');
        Assert.AreEqual('PCS', EDocumentPurchaseLine."Unit of Measure", 'The unit of measure in the purchase line does not allign with the mock data.');
        Assert.AreEqual(10000, EDocumentPurchaseLine."Sub Total", 'The total amount before taxes in the purchase line does not allign with the mock data.');
        Assert.AreEqual('XYZ', EDocumentPurchaseLine."Currency Code", 'The currency code in the purchase line does not allign with the mock data.');
        Assert.AreEqual(0, EDocumentPurchaseLine."Total Discount", 'The total discount in the purchase line does not allign with the mock data.');
        Assert.AreEqual('Bicycle v2', EDocumentPurchaseLine.Description, 'The product description in the purchase line does not allign with the mock data.');
        Assert.AreEqual('2000', EDocumentPurchaseLine."Product Code", 'The product code in the purchase line does not allign with the mock data.');
        Assert.AreEqual(25, EDocumentPurchaseLine."VAT Rate", 'The VAT rate in the purchase line does not allign with the mock data.');
        Assert.AreEqual(5000, EDocumentPurchaseLine."Unit Price", 'The unit price in the purchase line does not allign with the mock data.');

    end;

}