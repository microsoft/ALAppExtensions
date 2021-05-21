codeunit 139848 "APIV2 - Sales Ship. Lines E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Sales] [Shipment]
    end;

    var
        Assert: Codeunit "Assert";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibrarySales: Codeunit "Library - Sales";
        ShipmentServiceNameTxt: Label 'salesShipments';
        ShipmentServiceLinesNameTxt: Label 'salesShipmentLines';

    [Test]
    procedure TestGetLineDirectly()
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        SalesHeader: Record "Sales Header";
        ResponseText: Text;
        TargetURL: Text;
        ShipmentNo: Text;
        LineNo: Integer;
        SequenceValue: Text;
    begin
        // [SCENARIO] Call GET on the Line of a sales shipment

        // [GIVEN] A shipment with a line.
        LibrarySales.CreateSalesOrder(SalesHeader);
        ShipmentNo := LibrarySales.PostSalesDocument(SalesHeader, true, false);

        SalesShipmentLine.SetRange("Document No.", ShipmentNo);
        SalesShipmentLine.FindFirst();
        LineNo := SalesShipmentLine."Line No.";

        // [WHEN] we GET all the lines with the sales shipment ID from the web service
        TargetURL := GetLinesURL(SalesShipmentLine.SystemId, Page::"APIV2 - Sales Shipments", ShipmentServiceNameTxt, ShipmentServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the line returned should be valid (numbers and integration id)
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'documentId');
        LibraryGraphMgt.GetPropertyValueFromJSON(ResponseText, 'sequence', SequenceValue);
        Assert.AreEqual(SequenceValue, Format(LineNo), 'The sequence value is wrong.');
    end;

    [Test]
    procedure TestGetShipmentLines()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        SalesHeader: Record "Sales Header";
        ResponseText: Text;
        TargetURL: Text;
        DocumentId: Text;
        ShipmentNo: Text;
        LineNo1: Text;
        LineNo2: Text;
    begin
        // [SCENARIO] Call GET on the Lines of Sales Shipment

        // [GIVEN] An sales shipment with lines.
        CreateSalesOrderMultipleLines(SalesHeader);
        ShipmentNo := LibrarySales.PostSalesDocument(SalesHeader, true, false);

        SalesShipmentHeader.SetRange("No.", ShipmentNo);
        SalesShipmentHeader.FindFirst();
        DocumentId := SalesShipmentHeader.SystemId;

        SalesShipmentLine.SetRange("Document No.", ShipmentNo);
        SalesShipmentLine.FindFirst();
        LineNo1 := Format(SalesShipmentLine."Line No.");
        SalesShipmentLine.FindLast();
        LineNo2 := Format(SalesShipmentLine."Line No.");

        // [WHEN] we GET all the lines with the sales shipment ID from the web service
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            DocumentId,
            Page::"APIV2 - Sales Shipments",
            ShipmentServiceNameTxt,
            ShipmentServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the lines returned should be valid
        VerifyShipmentLines(ResponseText, LineNo1, LineNo2);
    end;

    [Test]
    procedure TestGetShipmentLinesDirectlyWithDocumentIdFilter()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        SalesHeader: Record "Sales Header";
        ResponseText: Text;
        TargetURL: Text;
        DocumentId: Text;
        ShipmentNo: Text;
        LineNo1: Text;
        LineNo2: Text;
    begin
        // [SCENARIO] Call GET on the Lines of a sales shipment

        // [GIVEN] An sales shipment with lines.
        CreateSalesOrderMultipleLines(SalesHeader);
        ShipmentNo := LibrarySales.PostSalesDocument(SalesHeader, true, false);

        SalesShipmentHeader.SetRange("No.", ShipmentNo);
        SalesShipmentHeader.FindFirst();
        DocumentId := SalesShipmentHeader.SystemId;

        SalesShipmentLine.SetRange("Document No.", ShipmentNo);
        SalesShipmentLine.FindFirst();
        LineNo1 := Format(SalesShipmentLine."Line No.");
        SalesShipmentLine.FindLast();
        LineNo2 := Format(SalesShipmentLine."Line No.");

        // [WHEN] we GET all the lines with the sales shipment ID from the web service
        TargetURL := GetLinesURLWithDocumentIdFilter(DocumentId, Page::"APIV2 - Sales Shipments", ShipmentServiceNameTxt, ShipmentServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the lines returned should be valid (numbers and integration ids)
        VerifyShipmentLines(ResponseText, LineNo1, LineNo2);
    end;

    [Test]
    procedure TestExpandDimensions()
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        SalesShipmentHeader: Record "Sales Shipment Header";
        ResponseText: Text;
        TargetURL: Text;
        LineIdTxt: Text;
        DimensionSetValue: Text;
    begin
        // [SCENARIO] Call GET on the Line of a sales shipment and expand the dimension set lines

        // [GIVEN] A shipment with a line.
        SalesShipmentHeader.FindFirst();
        SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
        SalesShipmentLine.FindFirst();
        LineIdTxt := LowerCase(Format(SalesShipmentLine.SystemId));

        // [WHEN] we GET all the lines with the sales shipment ID from the web service
        TargetURL := GetLinesURLWithExpandedDimensions(SalesShipmentLine.SystemId, Page::"APIV2 - Sales Shipments", ShipmentServiceNameTxt, ShipmentServiceLinesNameTxt);
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

    local procedure CreateSalesOrderMultipleLines(var SalesHeader: Record "Sales Header")
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, LibrarySales.CreateCustomerNo());
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInRange(1, 100, 2), LibraryRandom.RandDecInRange(1, 100, 2));
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInRange(1, 100, 2), LibraryRandom.RandDecInRange(1, 100, 2));
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));
    end;

    local procedure VerifyShipmentLines(ResponseText: Text; LineNo1: Text; LineNo2: Text)
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