codeunit 139906 "APIV2 - FA Locations E2E"
{
    // version Test,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Api] [Location]
    end;

    var
        Assert: Codeunit Assert;
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryUtility: Codeunit "Library - Utility";
        IsInitialized: Boolean;
        EmptyJSONErr: Label 'JSON should not be empty.';
        ServiceNameTxt: Label 'fixedAssetLocations';

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        IsInitialized := true;
        Commit();
    end;

    [Test]
    procedure TestGetFALocation()
    var
        FALocation: Record "FA Location";
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can get a Fixed Asset Location with a GET request to the service.
        Initialize();

        // [GIVEN] A Fixed Asset Location exists in the system.
        CreateFALocation(FALocation);

        // [WHEN] The user makes a GET request for a given Fixed Asset Location.
        TargetURL := LibraryGraphMgt.CreateTargetURL(FALocation.SystemId, Page::"APIV2 - FA Locations", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(Response, TargetURL);

        // [THEN] The response text contains the Fixed Asset Location information.
        VerifyProperties(Response, FALocation);
    end;

    [Test]
    procedure TestCreateFALocation()
    var
        FALocation: Record "FA Location";
        TempFALocation: Record "FA Location" temporary;
        FALocationJSON: Text;
        TargetURL: Text;
        Response: Text;
    begin
        // [SCENARIO] User can create a new Fixed Asset Location through a POST method.
        Initialize();

        // [GIVEN] The user has constructed a Fixed Asset Location JSON object to send to the service.
        CreateFALocation(TempFALocation);
        FALocationJSON := GetFALocationJSON(TempFALocation);

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - FA Locations", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, FALocationJSON, Response);

        // [THEN] The Fixed Asset Location has been created in the database with all the details.
        FALocation.Get(TempFALocation.Code);
        VerifyProperties(Response, FALocation);
    end;

    [Test]
    procedure TestModifyFALocation()
    var
        FALocation: Record "FA Location";
        TempFALocation: Record "FA Location" temporary;
        RequestBody: Text;
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can modify name in a Fixed Asset Location through a PATCH request.
        Initialize();

        // [GIVEN] A Fixed Asset Location exists with a name.
        CreateFALocation(FALocation);
        TempFALocation.TransferFields(FALocation);
        TempFALocation.Name := LibraryUtility.GenerateGUID();
        RequestBody := GetFALocationJSON(TempFALocation);

        // [WHEN] The user makes a patch request to the service and specifies name field.
        TargetURL := LibraryGraphMgt.CreateTargetURL(FALocation.SystemId, Page::"APIV2 - FA Locations", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, RequestBody, Response);

        // [THEN] The response contains the new values.
        VerifyProperties(Response, TempFALocation);

        // [THEN] The Fixed Asset Location in the database contains the updated value.
        FALocation.GetBySystemId(FALocation.SystemId);
        Assert.AreEqual(FALocation.Name, TempFALocation.Name, 'Names should be equal.');
    end;

    [Test]
    procedure TestDeleteFALocation()
    var
        FALocation: Record "FA Location";
        FALocationCode: Code[10];
        TargetURL: Text;
        Response: Text;
    begin
        // [SCENARIO] User can delete a Fixed Asset Location by making a DELETE request.
        Initialize();

        // [GIVEN] A Fixed Asset Location exists.
        CreateFALocation(FALocation);
        FALocationCode := FALocation.Code;

        // [WHEN] The user makes a DELETE request to the endpoint for the Fixed Asset Location.
        TargetURL := LibraryGraphMgt.CreateTargetURL(FALocation.SystemId, Page::"APIV2 - FA Locations", ServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', Response);

        // [THEN] The response is empty.
        Assert.AreEqual('', Response, 'DELETE response should be empty.');

        // [THEN] The Fixed Asset Location is no longer in the database.
        FALocation.SetRange(Code, FALocationCode);
        Assert.IsTrue(FALocation.IsEmpty(), 'Fixed Asset Location should be deleted.');
    end;

    local procedure CreateFALocation(var FALocation: Record "FA Location")
    begin
        FALocation.Init();
        FALocation.Code := LibraryUtility.GenerateRandomCodeWithLength(FALocation.FieldNo(Code), Database::"FA Location", 10);
        FALocation.Name := LibraryUtility.GenerateGUID();
        FALocation.Insert(true);
        Commit();
    end;

    local procedure GetFALocationJSON(var FALocation: Record "FA Location") FALocationJSON: Text
    begin
        if FALocation.Code = '' then
            FALocation.Code := LibraryUtility.GenerateRandomCodeWithLength(FALocation.FieldNo(Code), Database::"FA Location", 10);
        if FALocation.Name = '' then
            FALocation.Name := LibraryUtility.GenerateGUID();
        FALocationJSON := LibraryGraphMgt.AddPropertytoJSON(FALocationJSON, 'code', FALocation.Code);
        FALocationJSON := LibraryGraphMgt.AddPropertytoJSON(FALocationJSON, 'displayName', FALocation.Name);
        exit(FALocationJSON);
    end;

    local procedure VerifyProperties(JSON: Text; FALocation: Record "FA Location")
    begin
        Assert.AreNotEqual('', JSON, EmptyJSONErr);
        LibraryGraphMgt.VerifyIDInJSON(JSON);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'code', FALocation.Code);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'displayName', FALocation.Name);
    end;
}