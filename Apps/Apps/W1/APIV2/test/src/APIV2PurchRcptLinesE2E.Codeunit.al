codeunit 139850 "APIV2 - Purch. Rcpt. Lines E2E"
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
        ReceiptServiceLinesNameTxt: Label 'purchaseReceiptLines';

    [Test]
    procedure TestGetLineDirectly()
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchaseHeader: Record "Purchase Header";
        ResponseText: Text;
        TargetURL: Text;
        ReceiptNo: Text;
        LineNo: Integer;
        SequenceValue: Text;
    begin
        // [SCENARIO] Call GET on the Line of a purchase receipt
        // [GIVEN] A receipt with a line.
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);
        ReceiptNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);

        PurchRcptLine.SetRange("Document No.", ReceiptNo);
        PurchRcptLine.FindFirst();
        LineNo := PurchRcptLine."Line No.";

        // [WHEN] we GET all the lines with the purchase receipt ID from the web service
        TargetURL := GetLinesURL(PurchRcptLine.SystemId, Page::"APIV2 - Purchase Receipts", ReceiptServiceNameTxt, ReceiptServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the line returned should be valid (numbers and integration id)
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'documentId');
        LibraryGraphMgt.GetPropertyValueFromJSON(ResponseText, 'sequence', SequenceValue);
        Assert.AreEqual(SequenceValue, Format(LineNo), 'The sequence value is wrong.');
    end;

    [Test]
    procedure TestGetReceiptLines()
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchaseHeader: Record "Purchase Header";
        ResponseText: Text;
        TargetURL: Text;
        DocumentId: Text;
        ReceiptNo: Text;
        LineNo1: Text;
        LineNo2: Text;
    begin
        // [SCENARIO] Call GET on the Lines of a Purchase Receipt
        // [GIVEN] A purchase receipt with lines.
        CreatePurchaseOrderMultipleLines(PurchaseHeader);
        ReceiptNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);

        PurchRcptHeader.SetRange("No.", ReceiptNo);
        PurchRcptHeader.FindFirst();
        DocumentId := PurchRcptHeader.SystemId;

        PurchRcptLine.SetRange("Document No.", ReceiptNo);
        PurchRcptLine.FindFirst();
        LineNo1 := Format(PurchRcptLine."Line No.");
        PurchRcptLine.FindLast();
        LineNo2 := Format(PurchRcptLine."Line No.");

        // [WHEN] we GET all the lines with the purchase receipt ID from the web service
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            DocumentId,
            Page::"APIV2 - Purchase Receipts",
            ReceiptServiceNameTxt,
            ReceiptServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the lines returned should be valid
        VerifyReceiptLines(ResponseText, LineNo1, LineNo2);
    end;

    [Test]
    procedure TestGetReceiptLinesDirectlyWithDocumentIdFilter()
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchaseHeader: Record "Purchase Header";
        ResponseText: Text;
        TargetURL: Text;
        DocumentId: Text;
        ReceiptNo: Text;
        LineNo1: Text;
        LineNo2: Text;
    begin
        // [SCENARIO] Call GET on the Lines of a purchase receipt
        // [GIVEN] A purchase receipt with lines.
        CreatePurchaseOrderMultipleLines(PurchaseHeader);
        ReceiptNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);

        PurchRcptHeader.SetRange("No.", ReceiptNo);
        PurchRcptHeader.FindFirst();
        DocumentId := PurchRcptHeader.SystemId;

        PurchRcptLine.SetRange("Document No.", ReceiptNo);
        PurchRcptLine.FindFirst();
        LineNo1 := Format(PurchRcptLine."Line No.");
        PurchRcptLine.FindLast();
        LineNo2 := Format(PurchRcptLine."Line No.");

        // [WHEN] we GET all the lines with the purchase receipt ID from the web service
        TargetURL := GetLinesURLWithDocumentIdFilter(DocumentId, Page::"APIV2 - Purchase Receipts", ReceiptServiceNameTxt, ReceiptServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the lines returned should be valid (numbers and integration ids)
        VerifyReceiptLines(ResponseText, LineNo1, LineNo2);
    end;

    [Test]
    procedure TestExpandDimensions()
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        ResponseText: Text;
        TargetURL: Text;
        LineIdTxt: Text;
        DimensionSetValue: Text;
    begin
        // [SCENARIO] Call GET on the Line of a purchase receipt and expand the dimension set lines
        // [GIVEN] A receipt with a line.
        PurchRcptHeader.FindFirst();
        PurchRcptLine.SetRange("Document No.", PurchRcptHeader."No.");
        PurchRcptLine.FindFirst();
        LineIdTxt := LowerCase(Format(PurchRcptLine.SystemId));

        // [WHEN] we GET all the lines with the purchase receipt ID from the web service
        TargetURL := GetLinesURLWithExpandedDimensions(PurchRcptLine.SystemId, Page::"APIV2 - Purchase Receipts", ReceiptServiceNameTxt, ReceiptServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the dimension set lines of the response must have a parent id the same as the line id
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');

        LibraryGraphMgt.GetPropertyValueFromJSON(ResponseText, 'dimensionSetLines', DimensionSetValue);
        VerifyDimensions(DimensionSetValue, LineIdTxt);
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

    local procedure CreatePurchaseOrderMultipleLines(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, LibraryPurchase.CreateVendorNo());
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(100));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 100, 2));
        PurchaseLine.Modify(true);
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(50));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 100, 2));
        PurchaseLine.Modify(true);
    end;

    local procedure VerifyReceiptLines(ResponseText: Text; LineNo1: Text; LineNo2: Text)
    var
        LineJSON1: Text;
        LineJSON2: Text;
        ItemNo1: Text;
        ItemNo2: Text;
    begin
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(
            ResponseText, 'sequence', LineNo1, LineNo2, LineJSON1, LineJSON2),
          'Could not find the lines in JSON');
        LibraryGraphMgt.VerifyIDFieldInJson(LineJSON1, 'documentId');
        LibraryGraphMgt.VerifyIDFieldInJson(LineJSON2, 'documentId');
        LibraryGraphMgt.GetObjectIDFromJSON(LineJSON1, 'lineObjectNumber', ItemNo1);
        LibraryGraphMgt.GetObjectIDFromJSON(LineJSON2, 'lineObjectNumber', ItemNo2);
        Assert.AreNotEqual(ItemNo1, ItemNo2, 'Item Ids should be different for different items');
    end;

    procedure GetLinesURL(Id: Text; PageNumber: Integer; ServiceName: Text; ServiceLinesName: Text): Text
    var
        TargetURL: Text;
    begin
        if Id <> '' then
            TargetURL := LibraryGraphMgt.CreateTargetURL(Id, PageNumber, ServiceName)
        else
            TargetURL := LibraryGraphMgt.CreateTargetURL('', PageNumber, '');
        TargetURL := LibraryGraphMgt.StrReplace(TargetURL, ServiceName, ServiceLinesName);
        exit(TargetURL);
    end;

    procedure GetLinesURLWithDocumentIdFilter(DocumentId: Text; PageNumber: Integer; ServiceName: Text; ServiceLinesName: Text): Text
    var
        TargetURL: Text;
        URLFilter: Text;
    begin
        TargetURL := GetLinesURL('', PageNumber, ServiceName, ServiceLinesName);
        URLFilter := '$filter=documentId eq ' + LowerCase(LibraryGraphMgt.StripBrackets(DocumentId));

        if StrPos(TargetURL, '?') <> 0 then
            TargetURL := TargetURL + '&' + UrlFilter
        else
            TargetURL := TargetURL + '?' + UrlFilter;

        exit(TargetURL);
    end;

    local procedure GetLinesURLWithExpandedDimensions(DocumentId: Text; PageNumber: Integer; ServiceName: Text; ServiceLinesName: Text): Text
    var
        TargetURL: Text;
        URLFilter: Text;
    begin
        TargetURL := GetLinesURL(LowerCase(LibraryGraphMgt.StripBrackets(DocumentId)), PageNumber, ServiceName, ServiceLinesName);
        URLFilter := '$expand=dimensionSetLines';

        if StrPos(TargetURL, '?') <> 0 then
            TargetURL := TargetURL + '&' + UrlFilter
        else
            TargetURL := TargetURL + '?' + UrlFilter;

        exit(TargetURL);
    end;

}