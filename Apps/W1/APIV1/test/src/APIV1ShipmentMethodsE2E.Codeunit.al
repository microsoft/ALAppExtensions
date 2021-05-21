codeunit 139705 "APIV1 - Shipment Methods E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Shipment Method]
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        Assert: Codeunit "Assert";
        IsInitialized: Boolean;
        DescriptionTxt: Label 'My description.';
        ServiceNameTxt: Label 'shipmentMethods';


    local procedure Initialize()
    begin
        IF IsInitialized THEN
            EXIT;

        IsInitialized := TRUE;
        COMMIT();
    end;

    [Test]
    procedure TestVerifyIDandLastDateModified()
    var
        ShipmentMethod: Record "Shipment Method";
        ShipmentMethodCode: Code[10];
        ShipmentMethodId: Guid;
    begin
        // [SCENARIO] Create a Shipment Method and verify it has Id and Last Modified Date Time
        // [GIVEN] a modified Shipment Method record
        Initialize();
        CreateShipmentMethod(ShipmentMethod);
        ShipmentMethodCode := ShipmentMethod.Code;
        COMMIT();

        // [WHEN] we retrieve the Shipment Method from the database
        ShipmentMethod.RESET();
        ShipmentMethod.GET(ShipmentMethodCode);
        ShipmentMethodId := ShipmentMethod.SystemId;

        // [THEN] the Shipment Method should have last date time modified
        ShipmentMethod.TESTFIELD("Last Modified Date Time");
    end;

    [Test]
    procedure TestGetShipmentMethods()
    var
        ShipmentMethod: Record "Shipment Method";
        ShipmentMethodCode: array[2] of Code[10];
        ShipmentMethodJSON: array[2] of Text;
        TargetURL: Text;
        ResponseText: Text;
        "Count": Integer;
    begin
        // [SCENARIO] Create Shipment Methods and use a GET method to retrieve them
        // [GIVEN] 2 Shipment Methods in the Shipment Method Table
        Initialize();
        FOR Count := 1 TO 2 DO BEGIN
            CreateShipmentMethod(ShipmentMethod);
            ShipmentMethodCode[Count] := ShipmentMethod.Code;
        END;
        COMMIT();

        // [WHEN] we GET all the payment terms from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Shipment Methods", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the 2 payment terms should exist in the response
        FOR Count := 1 TO 2 DO
            GetAndVerifyIDFromJSON(ResponseText, ShipmentMethodCode[Count], ShipmentMethodJSON[Count]);
    end;

    [Normal]
    local procedure GetAndVerifyIDFromJSON(ResponseText: Text; ShipmentMethodCode: Text; var ShipmentMethodJSON: Text)
    begin
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(
            ResponseText, 'code', ShipmentMethodCode, ShipmentMethodCode, ShipmentMethodJSON, ShipmentMethodJSON),
          'Could not find the Shipment Method in JSON');
        LibraryGraphMgt.VerifyIDInJson(ShipmentMethodJSON);
    end;

    local procedure CreateShipmentMethod(var ShipmentMethod: Record "Shipment Method")
    begin
        WITH ShipmentMethod DO BEGIN
            INIT();
            Code := LibraryUtility.GenerateRandomCode(FIELDNO(Code), DATABASE::"Shipment Method");
            Description := DescriptionTxt;
            INSERT(TRUE);
        END;
    end;
}








