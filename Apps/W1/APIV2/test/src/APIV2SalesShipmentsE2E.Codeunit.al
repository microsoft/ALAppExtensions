codeunit 139847 "APIV2 - Sales Shipments E2E"
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

    [Test]
    procedure TestGetSalesShipments()
    var
        SalesHeader: Record "Sales Header";
        ShipmentNo: array[2] of Text;
        ShipmentJSON: array[2] of Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create 2 sales shipments (post sales order) and use a GET method to retrieve them

        // [GIVEN] 2 posted sales shipments
        LibrarySales.CreateSalesOrder(SalesHeader);
        ShipmentNo[1] := LibrarySales.PostSalesDocument(SalesHeader, true, false);
        LibrarySales.CreateSalesOrder(SalesHeader);
        ShipmentNo[2] := LibrarySales.PostSalesDocument(SalesHeader, true, false);
        Commit();

        // [WHEN] we GET all the shipments from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Sales Shipments", ShipmentServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The sales shipments should exist in the response
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(
            ResponseText, 'number', ShipmentNo[1], ShipmentNo[2], ShipmentJSON[1], ShipmentJSON[2]),
          'Could not find the shipments in JSON');
        LibraryGraphMgt.VerifyIDInJson(ShipmentJSON[1]);
        LibraryGraphMgt.VerifyIDInJson(ShipmentJSON[2]);
    end;

    [Test]
    procedure TestExpandDimensions()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        ResponseText: Text;
        TargetURL: Text;
        ShipmentIdTxt: Text;
        DimensionSetValue: Text;
    begin
        // [SCENARIO] Call GET on a sales shipment and expand the dimension set lines

        // [GIVEN] A sales shipment.
        SalesShipmentHeader.FindFirst();
        ShipmentIdTxt := LowerCase(Format(SalesShipmentHeader.SystemId));

        // [WHEN] we GET a shipment from the web service with expanded dimension set lines
        TargetURL := GetTargetURLWithExpandDimensions(SalesShipmentHeader);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the dimension set lines of the response must have a parent id the same as the receipt id
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');

        LibraryGraphMgt.GetPropertyValueFromJSON(ResponseText, 'dimensionSetLines', DimensionSetValue);
        VerifyDimensions(DimensionSetValue, ShipmentIdTxt);
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

    local procedure GetTargetURLWithExpandDimensions(SalesShipmentHeader: Record "Sales Shipment Header"): Text;
    var
        TargetURL: Text;
        URLFilter: Text;
    begin
        TargetURL := LibraryGraphMgt.CreateTargetURL(SalesShipmentHeader.SystemId, Page::"APIV2 - Sales Shipments", ShipmentServiceNameTxt);
        URLFilter := '$expand=dimensionSetLines';

        if StrPos(TargetURL, '?') <> 0 then
            TargetURL := TargetURL + '&' + UrlFilter
        else
            TargetURL := TargetURL + '?' + UrlFilter;

        exit(TargetURL);
    end;

}