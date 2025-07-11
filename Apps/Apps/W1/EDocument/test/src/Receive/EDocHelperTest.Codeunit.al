codeunit 139799 "E-Doc. Helper Test"
{
    Subtype = Test;
    Access = Internal;

    var
        Assert: Codeunit "Assert";

    trigger OnRun()
    begin
        // [FEATURE] [E-Document]
    end;

    [Test]
    procedure ValidateLineDiscountTest()
    var
        EDocument: Record "E-Document";
        TempPurchaseLine: Record "Purchase Line" temporary;
        EDocumentImportHelper: Codeunit "E-Document Import Helper";
        RecordRef: RecordRef;
    begin
        TempPurchaseLine."Direct Unit Cost" := 0.99;
        TempPurchaseLine.Amount := 0.88 * 5;
        TempPurchaseLine.Quantity := 5;

        RecordRef.GetTable(TempPurchaseLine);
        EDocumentImportHelper.ValidateLineDiscount(EDocument, RecordRef);
        RecordRef.SetTable(TempPurchaseLine);
        Assert.AreEqual(TempPurchaseLine."Line Discount Amount", 0.55, 'Line Discount Amount does not equal');
    end;


    [Test]
    procedure ValidateDonotFindVendor()
    var
        EDocumentImportHelper: Codeunit "E-Document Import Helper";
        VendorNo: Code[20];
    begin
        VendorNo := EDocumentImportHelper.FindVendor('', '', '');
        Assert.IsTrue(VendorNo = '', 'Vendor No. should be empty');
    end;
}