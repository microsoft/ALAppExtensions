codeunit 139907 "APIV2 - Fixed Assets E2E"
{
    // version Test,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Customer]
    end;

    var
        Assert: Codeunit Assert;
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
        IsInitialized: Boolean;
        FixedAssetNoPrefixTxt: Label 'FA';
        EmptyJSONErr: Label 'JSON should not be empty.';
        ServiceNameTxt: Label 'fixedAssets';

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        IsInitialized := true;
        Commit();
    end;

    [Test]
    procedure TestGetFixedAsset()
    var
        FixedAsset: Record "Fixed Asset";
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can get a Fixed Asset with a GET request to the service.
        Initialize();

        // [GIVEN] A Fixed Asset exists in the system.
        LibraryFixedAsset.CreateFixedAsset(FixedAsset);

        // [WHEN] The user makes a GET request for a given Fixed Asset.
        TargetURL := LibraryGraphMgt.CreateTargetURL(FixedAsset.SystemId, Page::"APIV2 - Fixed Assets", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(Response, TargetURL);

        // [THEN] The response text contains the Fixed Asset information.
        VerifyProperties(Response, FixedAsset);
    end;

    [Test]
    procedure TestCreateFixedAsset()
    var
        FixedAsset: Record "Fixed Asset";
        TempFixedAsset: Record "Fixed Asset" temporary;
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can create a new Fixed Asset through a POST method.
        Initialize();

        // [GIVEN] The user has constructed a Fixed Asset JSON object to send to the service.
        LibraryFixedAsset.CreateFixedAsset(TempFixedAsset);
        Commit();

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Fixed Assets", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, GetFixedAssetJSON(TempFixedAsset), Response);

        // [THEN] The Fixed Asset has been created in the database with all the details.
        FixedAsset.Get(TempFixedAsset."No.");
        VerifyProperties(Response, FixedAsset);
    end;

    [Test]
    procedure TestDeleteFixedAsset()
    var
        FixedAsset: Record "Fixed Asset";
        FixedAssetNo: Code[20];
        TargetURL: Text;
        Response: Text;
    begin
        // [SCENARIO] User can delete a Fixed Asset by making a DELETE request.
        Initialize();

        // [GIVEN] A Fixed Asset exists.
        LibraryFixedAsset.CreateFixedAsset(FixedAsset);
        Commit();
        FixedAssetNo := FixedAsset."No.";

        // [WHEN] The user makes a DELETE request to the endpoint for the Fixed Asset.
        TargetURL := LibraryGraphMgt.CreateTargetURL(FixedAsset.SystemId, Page::"APIV2 - Fixed Assets", ServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', Response);

        // [THEN] The response is empty.
        Assert.AreEqual('', Response, 'DELETE response should be empty.');

        // [THEN] The Fixed Asset is no longer in the database.
        FixedAsset.SetRange("No.", FixedAssetNo);
        Assert.IsTrue(FixedAsset.IsEmpty(), 'Fixed Asset should be deleted.');
    end;

    [Test]
    procedure TestModifyFixedAsset()
    var
        FixedAsset: Record "Fixed Asset";
        TempFixedAsset: Record "Fixed Asset" temporary;
        RequestBody: Text;
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can modify a Fixed Asset through a PATCH request.
        Initialize();

        // [GIVEN] A Fixed Asset exists.
        LibraryFixedAsset.CreateFixedAsset(FixedAsset);
        Commit();
        TempFixedAsset.TransferFields(FixedAsset);
        TempFixedAsset.Description := LibraryUtility.GenerateGUID();
        RequestBody := GetFixedAssetJSON(TempFixedAsset);

        // [WHEN] The user makes a patch request to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL(FixedAsset.SystemId, Page::"APIV2 - Fixed Assets", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, RequestBody, Response);

        // [THEN] The response text contains the new values.
        VerifyProperties(Response, TempFixedAsset);

        // [THEN] The record in the database contains the new values.
        FixedAsset.Get(FixedAsset."No.");
        VerifyProperties(Response, FixedAsset);
    end;

    local procedure GetFixedAssetJSON(var FixedAsset: Record "Fixed Asset"): Text
    var
        FixedAssetJson: Text;
    begin
        if FixedAsset."No." = '' then
            FixedAsset."No." := NextFixedAssetNo();
        if FixedAsset.Description = '' then
            FixedAsset.Description := LibraryUtility.GenerateGUID();
        FixedAssetJson := LibraryGraphMgt.AddPropertytoJSON(FixedAssetJson, 'number', FixedAsset."No.");
        FixedAssetJson := LibraryGraphMgt.AddPropertytoJSON(FixedAssetJson, 'displayName', FixedAsset.Description);
        FixedAssetJson := LibraryGraphMgt.AddPropertytoJSON(FixedAssetJson, 'fixedAssetLocationCode', FixedAsset."FA Location Code");
        FixedAssetJson := LibraryGraphMgt.AddPropertytoJSON(FixedAssetJson, 'fixedAssetLocationId', FormatGuid(FixedAsset."FA Location Id"));
        FixedAssetJson := LibraryGraphMgt.AddPropertytoJSON(FixedAssetJson, 'classCode', FixedAsset."FA Class Code");
        FixedAssetJson := LibraryGraphMgt.AddPropertytoJSON(FixedAssetJson, 'subclassCode', FixedAsset."FA Subclass Code");
        FixedAssetJson := LibraryGraphMgt.AddPropertytoJSON(FixedAssetJson, 'blocked', FixedAsset.Blocked);
        FixedAssetJson := LibraryGraphMgt.AddPropertytoJSON(FixedAssetJson, 'serialNumber', FixedAsset."Serial No.");
        FixedAssetJson := LibraryGraphMgt.AddPropertytoJSON(FixedAssetJson, 'employeeNumber', FixedAsset."Responsible Employee");
        FixedAssetJson := LibraryGraphMgt.AddPropertytoJSON(FixedAssetJson, 'employeeId', FormatGuid(FixedAsset."Responsible Employee Id"));
        FixedAssetJson := LibraryGraphMgt.AddPropertytoJSON(FixedAssetJson, 'underMaintenance', FixedAsset."Under Maintenance");
        exit(FixedAssetJson)
    end;

    local procedure NextFixedAssetNo(): Code[20]
    var
        FixedAsset: Record "Fixed Asset";
    begin
        FixedAsset.SetFilter("No.", StrSubstNo('%1*', FixedAssetNoPrefixTxt));
        if FixedAsset.FindLast() then
            exit(IncStr(FixedAsset."No."));

        exit(CopyStr(FixedAssetNoPrefixTxt + '0001', 1, 20));
    end;

    local procedure VerifyProperties(JSON: Text; FixedAsset: Record "Fixed Asset")
    begin
        Assert.AreNotEqual('', JSON, EmptyJSONErr);
        LibraryGraphMgt.VerifyIDInJson(JSON);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'number', FixedAsset."No.");
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'displayName', FixedAsset.Description);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'fixedAssetLocationCode', FixedAsset."FA Location Code");
        LibraryGraphMgt.VerifyGUIDFieldInJson(JSON, 'fixedAssetLocationId', FixedAsset."FA Location Id");
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'classCode', FixedAsset."FA Class Code");
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'subclassCode', FixedAsset."FA Subclass Code");
        Assert.AreEqual(false, FixedAsset.Blocked, 'Fixed Asset should have the correct ''blocked'' information.');
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'serialNumber', FixedAsset."Serial No.");
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'employeeNumber', FixedAsset."Responsible Employee");
        LibraryGraphMgt.VerifyGUIDFieldInJson(JSON, 'employeeId', FixedAsset."Responsible Employee Id");
        Assert.AreEqual(false, FixedAsset."Under Maintenance", 'Fixed Asset should have the correct ''under maintenance'' information.');
    end;

    local procedure FormatGuid(Value: Guid): Text
    begin
        exit(LowerCase(LibraryGraphMgt.StripBrackets(Format(Value, 0, 9))));
    end;
}