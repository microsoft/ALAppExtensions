codeunit 139882 "APIV2 - Salesperson/Purch E2E"
{
    Subtype = Test;
    RequiredTestIsolation = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        IsInitialized: Boolean;
        EmptyJSONErr: Label 'JSON should not be empty.', Locked = true;
        ServiceNameTxt: Label 'salespeoplePurchasers', Locked = true;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        IsInitialized := true;
        Commit();
    end;

    [Test]
    procedure GetSalespersonPurchaser()
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can get a salesperson/purchaser with a GET request to the service.
        Initialize();

        // [GIVEN] A salesperson/purchaser exists in the system.
        CreateSalespersonPurchaser(SalespersonPurchaser);

        // [WHEN] The user makes a GET request for a given salesperson/purchaser.
        TargetURL := LibraryGraphMgt.CreateTargetURL(SalespersonPurchaser.SystemId, Page::"APIV2 - Salesperson/Purchaser", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(Response, TargetURL);

        // [THEN] The response text contains the information about salesperson/purchaser.
        VerifyProperties(Response, SalespersonPurchaser);
    end;

    [Test]
    procedure CreateSalespersonPurchaser()
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        TempSalespersonPurchaser: Record "Salesperson/Purchaser" temporary;
        SalespersonPurchaserJSON: Text;
        TargetURL: Text;
        Response: Text;
    begin
        // [SCENARIO] User can create a new salesperson/purchaser through a POST method.
        Initialize();

        // [GIVEN] The user has constructed a salesperson/purchaser JSON object to send to the service.
        CreateSalespersonPurchaser(TempSalespersonPurchaser);
        SalespersonPurchaserJSON := GetSalespersonPurchaserJSON(TempSalespersonPurchaser);

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Salesperson/Purchaser", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, SalespersonPurchaserJSON, Response);

        // [THEN] The salesperson/purchaser has been created in the database with all the details.
        SalespersonPurchaser.Get(TempSalespersonPurchaser.Code);
        VerifyProperties(Response, SalespersonPurchaser);
    end;

    [Test]
    procedure ModifySalespersonPurchaserJobTitle()
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        TempSalespersonPurchaser: Record "Salesperson/Purchaser" temporary;
        RequestBody: Text;
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can modify a salesperson/purchaser through a PATCH request.
        Initialize();

        // [GIVEN] A salesperson/purchaser exists.
        CreateSalespersonPurchaser(SalespersonPurchaser);
        TempSalespersonPurchaser.TransferFields(SalespersonPurchaser);
        TempSalespersonPurchaser."Job Title" := LibraryUtility.GenerateGUID();
        RequestBody := GetSalespersonPurchaserJSON(TempSalespersonPurchaser);

        // [WHEN] The user makes a patch request to the service and specifies Job Title field.
        TargetURL := LibraryGraphMgt.CreateTargetURL(SalespersonPurchaser.SystemId, Page::"APIV2 - Salesperson/Purchaser", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, RequestBody, Response);

        // [THEN] The response contains the new values.
        VerifyProperties(Response, TempSalespersonPurchaser);

        // [THEN] The salesperson/purchaser in the database contains the updated values.
        SalespersonPurchaser.Get(SalespersonPurchaser.Code);
        Assert.AreEqual(SalespersonPurchaser."Job Title", TempSalespersonPurchaser."Job Title", 'Job Title should be equal.');
    end;

    [Test]
    procedure DeleteSalespersonPurchaser()
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SalespersonPurchaserCode: Code[10];
        TargetURL: Text;
        Response: Text;
    begin
        // [SCENARIO] User can delete a salesperson/purchaser by making a DELETE request.
        Initialize();

        // [GIVEN] A salesperson/purchaser exists.
        CreateSalespersonPurchaser(SalespersonPurchaser);
        SalespersonPurchaserCode := SalespersonPurchaser.Code;

        // [WHEN] The user makes a DELETE request to the endpoint for the salesperson/purchaser.
        TargetURL := LibraryGraphMgt.CreateTargetURL(SalespersonPurchaser.SystemId, Page::"APIV2 - Salesperson/Purchaser", ServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', Response);

        // [THEN] The response is empty.
        Assert.AreEqual('', Response, 'DELETE response should be empty.');

        // [THEN] The salesperson/purchaser is no longer in the database.
        SalespersonPurchaser.SetRange(Code, SalespersonPurchaserCode);
        Assert.IsTrue(SalespersonPurchaser.IsEmpty(), 'Salesperson/Purchaser should be deleted.');
    end;

    local procedure CreateSalespersonPurchaser(var SalespersonPurchaser: Record "Salesperson/Purchaser"): Code[20]
    begin
        SalespersonPurchaser.Init();
        SalespersonPurchaser.Validate(
          Code, LibraryUtility.GenerateRandomCode(SalespersonPurchaser.FieldNo(Code), DATABASE::"Salesperson/Purchaser"));
        SalespersonPurchaser.Name := LibraryUtility.GenerateRandomText(50);
        SalespersonPurchaser."E-Mail" := LibraryUtility.GenerateRandomEmail();
        SalespersonPurchaser."E-Mail 2" := LibraryUtility.GenerateRandomEmail();
        SalespersonPurchaser."Phone No." := LibraryUtility.GenerateRandomPhoneNo();
        SalespersonPurchaser."Job Title" := LibraryUtility.GenerateRandomText(30);
        SalespersonPurchaser."Commission %" := LibraryRandom.RandDec(100, 2);
        SalespersonPurchaser."Privacy Blocked" := true;
        SalespersonPurchaser.Blocked := true;
        SalespersonPurchaser."Coupled to Dataverse" := true;
        SalespersonPurchaser.Insert(true);
        Commit();
        exit(SalespersonPurchaser.Code);
    end;

    local procedure GetSalespersonPurchaserJSON(var SalespersonPurchaser: Record "Salesperson/Purchaser") SalespersonPurchaserJSON: Text
    begin
        SalespersonPurchaserJSON := LibraryGraphMgt.AddPropertytoJSON(SalespersonPurchaserJSON, 'code', SalespersonPurchaser.Code);
        SalespersonPurchaserJSON := LibraryGraphMgt.AddPropertytoJSON(SalespersonPurchaserJSON, 'displayName', SalespersonPurchaser.Name);
        SalespersonPurchaserJSON := LibraryGraphMgt.AddPropertytoJSON(SalespersonPurchaserJSON, 'email', SalespersonPurchaser."E-Mail");
        SalespersonPurchaserJSON := LibraryGraphMgt.AddPropertytoJSON(SalespersonPurchaserJSON, 'email2', SalespersonPurchaser."E-Mail 2");
        SalespersonPurchaserJSON := LibraryGraphMgt.AddPropertytoJSON(SalespersonPurchaserJSON, 'phoneNo', SalespersonPurchaser."Phone No.");
        SalespersonPurchaserJSON := LibraryGraphMgt.AddPropertytoJSON(SalespersonPurchaserJSON, 'jobTitle', SalespersonPurchaser."Job Title");
        SalespersonPurchaserJSON := LibraryGraphMgt.AddPropertytoJSON(SalespersonPurchaserJSON, 'commisionPercent', SalespersonPurchaser."Commission %");
        SalespersonPurchaserJSON := LibraryGraphMgt.AddPropertytoJSON(SalespersonPurchaserJSON, 'privacyBlocked', SalespersonPurchaser."Privacy Blocked");
        SalespersonPurchaserJSON := LibraryGraphMgt.AddPropertytoJSON(SalespersonPurchaserJSON, 'blocked', SalespersonPurchaser.Blocked);
        exit(SalespersonPurchaserJSON);
    end;

    local procedure VerifyProperties(JSON: Text; SalespersonPurchaser: Record "Salesperson/Purchaser")
    begin
        Assert.AreNotEqual('', JSON, EmptyJSONErr);
        LibraryGraphMgt.VerifyIDInJSON(JSON);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'code', SalespersonPurchaser.Code);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'displayName', SalespersonPurchaser.Name);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'email', SalespersonPurchaser."E-Mail");
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'email2', SalespersonPurchaser."E-Mail 2");
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'phoneNo', SalespersonPurchaser."Phone No.");
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'jobTitle', SalespersonPurchaser."Job Title");
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'commisionPercent', Format(SalespersonPurchaser."Commission %", 0, 9));
    end;
}
