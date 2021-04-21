codeunit 139849 "APIV2 - Purchase Receipts E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Purchase] [Receipt]
    end;

    var
        Assert: Codeunit "Assert";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryPurchase: Codeunit "Library - Purchase";
        ReceiptServiceNameTxt: Label 'purchaseReceipts';

    [Test]
    procedure TestGetPurchaseReceipts()
    var
        PurchaseHeader: Record "Purchase Header";
        ReceiptNo: array[2] of Text;
        ReceiptJSON: array[2] of Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create 2 purchase receipts (post sales order) and use a GET method to retrieve them
        // [GIVEN] 2 posted purchase receipts
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);
        ReceiptNo[1] := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);
        ReceiptNo[2] := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);
        Commit();

        // [WHEN] we GET all the receipt from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Purchase Receipts", ReceiptServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The purchase receipts should exist in the response
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(
            ResponseText, 'number', ReceiptNo[1], ReceiptNo[2], ReceiptJSON[1], ReceiptJSON[2]),
          'Could not find the shipments in JSON');
        LibraryGraphMgt.VerifyIDInJson(ReceiptJSON[1]);
        LibraryGraphMgt.VerifyIDInJson(ReceiptJSON[2]);
    end;

    [Test]
    procedure TestExpandDimensions()
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        ResponseText: Text;
        TargetURL: Text;
        ReceiptIdTxt: Text;
        DimensionSetValue: Text;
    begin
        // [SCENARIO] Call GET on purchase receipt and expand the dimension set lines
        // [GIVEN] A purchase receipt.

        PurchRcptHeader.FindFirst();
        ReceiptIdTxt := LowerCase(Format(PurchRcptHeader.SystemId));

        // [WHEN] we GET a receipt from the web service with expanded dimension set lines
        TargetURL := GetTargetURLWithExpandDimensions(PurchRcptHeader);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the dimension set lines of the response must have a parent id the same as the receipt id
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');

        LibraryGraphMgt.GetPropertyValueFromJSON(ResponseText, 'dimensionSetLines', DimensionSetValue);
        VerifyDimensions(DimensionSetValue, ReceiptIdTxt);
    end;

    local procedure VerifyDimensions(DimensionSetValue: Text; IdTxt: Text)
    var
        Index: Integer;
        DimensionTxt: Text;
        ParentIdValue: Text;
    begin
        Index := 0;
        repeat
            DimensionTxt := LibraryGraphMgt.GetObjectFromCollectionByIndex(DimensionSetValue, Index);

            LibraryGraphMgt.GetPropertyValueFromJSON(DimensionTxt, 'parentId', ParentIdValue);
            LibraryGraphMgt.VerifyIDFieldInJson(DimensionTxt, 'parentId');
            ParentIdValue := '{' + ParentIdValue + '}';
            Assert.AreEqual(ParentIdValue, IdTxt, 'The parent ID value is wrong.');
            Index := Index + 1;
        until (Index = LibraryGraphMgt.GetCollectionCountFromJSON(DimensionSetValue))
    end;

    local procedure GetTargetURLWithExpandDimensions(PurchRcptHeader: Record "Purch. Rcpt. Header"): Text;
    var
        TargetURL: Text;
        URLFilter: Text;
    begin
        TargetURL := LibraryGraphMgt.CreateTargetURL(PurchRcptHeader.SystemId, Page::"APIV2 - Purchase Receipts", ReceiptServiceNameTxt);
        URLFilter := '$expand=dimensionSetLines';

        if StrPos(TargetURL, '?') <> 0 then
            TargetURL := TargetURL + '&' + UrlFilter
        else
            TargetURL := TargetURL + '?' + UrlFilter;

        exit(TargetURL);
    end;
}