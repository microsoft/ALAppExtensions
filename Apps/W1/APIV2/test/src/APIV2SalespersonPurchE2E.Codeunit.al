codeunit 139870 "APIV2 - Salesperson/Purch E2E"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryUtility: Codeunit "Library - Utility";
        IsInitialized: Boolean;
        EmptyJSONErr: Label 'JSON should not be empty.';
        ServiceNameTxt: Label 'salespeoplePurchasers';

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
        SalespersonPurchaser.Validate(Name, SalespersonPurchaser.Code);  // Validating Name as Code because value is not important.
        SalespersonPurchaser."E-Mail" := 'a@b.com';
        SalespersonPurchaser.Insert(true);
        exit(SalespersonPurchaser.Code);
    end;

    local procedure GetSalespersonPurchaserJSON(var SalespersonPurchaser: Record "Salesperson/Purchaser") SalespersonPurchaserJSON: Text
    begin
        SalespersonPurchaserJSON := LibraryGraphMgt.AddPropertytoJSON(SalespersonPurchaserJSON, 'code', SalespersonPurchaser.Code);
        SalespersonPurchaserJSON := LibraryGraphMgt.AddPropertytoJSON(SalespersonPurchaserJSON, 'displayName', SalespersonPurchaser.Name);
        SalespersonPurchaserJSON := LibraryGraphMgt.AddPropertytoJSON(SalespersonPurchaserJSON, 'eMail', SalespersonPurchaser."E-Mail");
        exit(SalespersonPurchaserJSON);
    end;

    local procedure VerifyProperties(JSON: Text; SalespersonPurchaser: Record "Salesperson/Purchaser")
    begin
        Assert.AreNotEqual('', JSON, EmptyJSONErr);
        LibraryGraphMgt.VerifyIDInJSON(JSON);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'code', SalespersonPurchaser.Code);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'displayName', SalespersonPurchaser.Name);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'eMail', 'a@b.com');
    end;
}
