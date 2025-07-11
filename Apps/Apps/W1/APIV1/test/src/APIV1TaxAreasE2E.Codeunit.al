codeunit 139726 "APIV1 - Tax Areas E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Tax Area]
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit "Assert";
        IsInitialized: Boolean;
        ServiceNameTxt: Label 'taxAreas';
        EmptyJSONErr: Label 'The JSON should not be blank.';
        WrongPropertyValueErr: Label 'Incorrect property value for %1.', Comment = '%1=Property name';

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
        TempTaxAreaBuffer: Record "Tax Area Buffer" temporary;
        TaxAreaCode: Text;
        TaxAreaGUID: Text;
    begin
        // [SCENARIO] Create an Tax Area and verify it has Id and LastDateTimeModified
        // [GIVEN] a new Tax Area
        Initialize();
        CreateTaxArea(TaxAreaCode, TaxAreaGUID);
        COMMIT();

        // [THEN] the Tax Area should have last date time modified
        TempTaxAreaBuffer.LoadRecords();
        TempTaxAreaBuffer.GET(TaxAreaGUID);
        Assert.AreNotEqual(TempTaxAreaBuffer."Last Modified Date Time", 0DT, 'Last Modified Date Time should be updated');
    end;

    [Test]
    procedure TestGetTaxAreas()
    var
        TaxAreaCode: array[2] of Text;
        TaxAreaId: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Create Tax Areas and use a GET method to retrieve them
        // [GIVEN] 2 Tax Areas in the Tax Area Table
        Initialize();
        CreateTaxArea(TaxAreaCode[1], TaxAreaId);
        CreateTaxArea(TaxAreaCode[2], TaxAreaId);
        COMMIT();

        // [WHEN] we GET all the Tax Areas from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Tax Areas", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the 2 Tax Areas should exist in the response
        GetAndVerifyIDFromJSON(ResponseText, TaxAreaCode);
    end;

    [Test]
    procedure TestGetTaxArea()
    var
        TaxAreaCode: Text;
        TaxAreaId: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve the tax area record from the Tax Area API.
        Initialize();

        // [GIVEN] A tax area exists in the Tax Area Table
        CreateTaxArea(TaxAreaCode, TaxAreaId);
        COMMIT();

        // [WHEN] A GET request is made to the Tax Area API.
        TargetURL := LibraryGraphMgt.CreateTargetURL(TaxAreaId, PAGE::"APIV1 - Tax Areas", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the tax area should exist in the response
        LibraryGraphMgt.VerifyGUIDFieldInJson(ResponseText, 'id', TaxAreaId);
    end;

    [Test]
    procedure TestCreateTaxArea()
    var
        TaxAreaBuffer: Record "Tax Area Buffer";
        TaxAreaId: Text;
        ResponseText: Text;
        TargetURL: Text;
        TaxAreaJSON: Text;
    begin
        // [SCENARIO] Create a tax area through a POST method and check if it was created
        Initialize();

        // [GIVEN] The user has constructed a tax area JSON object to send to the service.
        TaxAreaBuffer.INIT();
        TaxAreaBuffer.Code := LibraryUtility.GenerateRandomCode(TaxAreaBuffer.FIELDNO(Code), DATABASE::"Tax Area Buffer");
        TaxAreaBuffer.Description := FORMAT(CREATEGUID());
        TaxAreaJSON := GetTaxAreaJSON(TaxAreaBuffer);
        COMMIT();

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Tax Areas", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, TaxAreaJSON, ResponseText);

        // [THEN] The tax area has been created in the database.
        LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'id', TaxAreaId);
        VerifyTaxAreaProperties(ResponseText, TaxAreaId);
    end;

    [Test]
    procedure TestModifyTaxArea()
    var
        TaxAreaBuffer: Record "Tax Area Buffer";
        TaxAreaCode: Text;
        TaxAreaId: Text;
        ResponseText: Text;
        TargetURL: Text;
        TaxAreaJSON: Text;
    begin
        // [SCENARIO] User can modify a tax area through a PATCH request.
        Initialize();

        // [GIVEN] An tax area exists.
        CreateTaxArea(TaxAreaCode, TaxAreaId);
        TaxAreaBuffer.Code := COPYSTR(TaxAreaCode, 1, MAXSTRLEN(TaxAreaBuffer.Code));
        TaxAreaBuffer.SystemId := TaxAreaId;
        TaxAreaBuffer.Description := FORMAT(CREATEGUID());
        TaxAreaJSON := GetTaxAreaJSON(TaxAreaBuffer);
        COMMIT();

        // [WHEN] The user makes a patch request to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL(TaxAreaId, PAGE::"APIV1 - Tax Areas", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, TaxAreaJSON, ResponseText);

        // [THEN] The record in the database contains the new values.
        LibraryGraphMgt.VerifyGUIDFieldInJson(ResponseText, 'id', TaxAreaId);

        // [THEN] The record in the database contains the new values.
        VerifyTaxAreaProperties(ResponseText, TaxAreaId);
    end;

    [Test]
    procedure TestDeleteTaxArea()
    var
        TaxAreaCode: Text;
        TaxAreaId: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can delete a tax area by making a DELETE request.
        Initialize();

        // [GIVEN] A tax area exists.
        CreateTaxArea(TaxAreaCode, TaxAreaId);
        COMMIT();

        // [WHEN] The user makes a DELETE request to the endpoint for the Tax Area.
        TargetURL := LibraryGraphMgt.CreateTargetURL(TaxAreaId, PAGE::"APIV1 - Tax Areas", ServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] The response is empty.
        Assert.AreEqual('', ResponseText, 'DELETE response should be empty.');

        // [THEN] The tax area is no longer in the database.
        VerifyTaxAreaWasDeleted(TaxAreaId);
    end;

    [Normal]
    local procedure CreateTaxArea(var TaxAreaCode: Text; var TaxAreaId: Text)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        TaxArea: Record "Tax Area";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
    begin
        IF GeneralLedgerSetup.UseVat() THEN BEGIN
            LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
            TaxAreaCode := VATBusinessPostingGroup.Code;
            TaxAreaId := VATBusinessPostingGroup.SystemId;
        END ELSE BEGIN
            LibraryERM.CreateTaxArea(TaxArea);
            TaxAreaCode := TaxArea.Code;
            TaxAreaId := TaxArea.SystemId;
        END;
    end;

    [Normal]
    local procedure GetAndVerifyIDFromJSON(ResponseText: Text; TaxCode: array[2] of Text)
    var
        TaxAreaJSON: array[2] of Text;
    begin
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(ResponseText, 'code', TaxCode[1], TaxCode[2], TaxAreaJSON[1], TaxAreaJSON[2]),
          'Could not find the TaxArea in JSON');
        LibraryGraphMgt.VerifyIDInJson(TaxAreaJSON[1]);
        LibraryGraphMgt.VerifyIDInJson(TaxAreaJSON[2]);
    end;

    local procedure GetTaxAreaJSON(var TaxAreaBuffer: Record "Tax Area Buffer") TaxAreaJSON: Text
    begin
        TaxAreaJSON := LibraryGraphMgt.AddPropertytoJSON('', 'id', FormatGuid(TaxAreaBuffer.SystemId));
        TaxAreaJSON := LibraryGraphMgt.AddPropertytoJSON(TaxAreaJSON, 'code', TaxAreaBuffer.Code);
        TaxAreaJSON := LibraryGraphMgt.AddPropertytoJSON(TaxAreaJSON, 'displayName', TaxAreaBuffer.Description);
    end;

    local procedure VerifyPropertyInJSON(JSON: Text; PropertyName: Text; ExpectedValue: Text)
    var
        PropertyValue: Text;
    begin
        LibraryGraphMgt.GetObjectIDFromJSON(JSON, PropertyName, PropertyValue);
        Assert.AreEqual(ExpectedValue, PropertyValue, STRSUBSTNO(WrongPropertyValueErr, PropertyName));
    end;

    local procedure VerifyTaxAreaProperties(TaxAreaJSON: Text; TaxAreaID: Text)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        TaxArea: Record "Tax Area";
        ExpectedCode: Text;
        ExpectedDecritpion: Text;
    begin
        Assert.AreNotEqual('', TaxAreaJSON, EmptyJSONErr);
        LibraryGraphMgt.VerifyIDInJson(TaxAreaJSON);

        IF GeneralLedgerSetup.UseVat() THEN BEGIN
            Assert.IsTrue(VATBusinessPostingGroup.GetBySystemId(TaxAreaID), 'VAT Business Group was not created for given ID');
            ExpectedCode := VATBusinessPostingGroup.Code;
            ExpectedDecritpion := VATBusinessPostingGroup.Description;
        END ELSE BEGIN
            Assert.IsTrue(TaxArea.GetBySystemId(TaxAreaID), 'Tax Area was not created for given ID');
            ExpectedCode := TaxArea.Code;
            ExpectedDecritpion := TaxArea.Description;
        END;

        VerifyPropertyInJSON(TaxAreaJSON, 'code', ExpectedCode);
        VerifyPropertyInJSON(TaxAreaJSON, 'displayName', ExpectedDecritpion);
    end;

    local procedure VerifyTaxAreaWasDeleted(TaxAreaId: Text)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        TaxArea: Record "Tax Area";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
    begin
        IF GeneralLedgerSetup.UseVat() THEN
            Assert.IsFalse(VATBusinessPostingGroup.GetBySystemId(TaxAreaId), 'VATBusinessPostingGroup should be deleted.')
        ELSE
            Assert.IsFalse(TaxArea.GetBySystemId(TaxAreaId), 'TaxArea should be deleted.');
    end;

    local procedure FormatGuid(Value: Guid): Text
    begin
        EXIT(LOWERCASE(LibraryGraphMgt.StripBrackets(Value)));
    end;
}




















