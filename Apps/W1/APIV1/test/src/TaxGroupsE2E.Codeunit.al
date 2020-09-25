codeunit 139708 "Tax Groups E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Tax Group]
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit "Assert";
        IsInitialized: Boolean;
        ServiceNameTxt: Label 'taxGroups';
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
        TempTaxGroupBuffer: Record "Tax Group Buffer" temporary;
        TaxGroupCode: Text;
        TaxGroupGUID: Text;
    begin
        // [SCENARIO] Create an Tax Group and verify it has Id and LastDateTimeModified
        // [GIVEN] a new Tax Group
        Initialize();
        CreateTaxGroup(TaxGroupCode, TaxGroupGUID);
        COMMIT();

        // [THEN] the Tax Group should have last date time modified
        TempTaxGroupBuffer.LoadRecords();
        TempTaxGroupBuffer.GET(TaxGroupGUID);
        Assert.AreNotEqual(TempTaxGroupBuffer."Last Modified DateTime", 0DT, 'Last Modified Date Time should be updated');
    end;

    [Test]
    procedure TestGetTaxGroups()
    var
        TaxGroupCode: array[2] of Text;
        TaxGroupId: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Create Tax Groups and use a GET method to retrieve them
        // [GIVEN] 2 Tax Groups in the Tax Group Table
        Initialize();
        CreateTaxGroup(TaxGroupCode[1], TaxGroupId);
        CreateTaxGroup(TaxGroupCode[2], TaxGroupId);
        COMMIT();

        // [WHEN] we GET all the Tax Groups from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Tax Groups", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the 2 Tax Groups should exist in the response
        GetAndVerifyIDFromJSON(ResponseText, TaxGroupCode);
    end;

    [Test]
    procedure TestGetTaxGroup()
    var
        TaxGroupCode: Text;
        TaxGroupId: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve the Tax Group record from the Tax Group API.
        Initialize();

        // [GIVEN] A Tax Group exists in the Tax Group Table
        CreateTaxGroup(TaxGroupCode, TaxGroupId);
        COMMIT();

        // [WHEN] A GET request is made to the Tax Group API.
        TargetURL := LibraryGraphMgt.CreateTargetURL(TaxGroupId, PAGE::"APIV1 - Tax Groups", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the Tax Group should exist in the response
        LibraryGraphMgt.VerifyGUIDFieldInJson(ResponseText, 'id', TaxGroupId);
    end;

    [Test]
    procedure TestCreateTaxGroup()
    var
        TaxGroupBuffer: Record "Tax Group Buffer";
        TaxGroupId: Text;
        ResponseText: Text;
        TargetURL: Text;
        TaxGroupJSON: Text;
    begin
        // [SCENARIO] Create a Tax Group through a POST method and check if it was created
        Initialize();

        // [GIVEN] The user has constructed a Tax Group JSON object to send to the service.
        TaxGroupBuffer.INIT();
        TaxGroupBuffer.Code := LibraryUtility.GenerateRandomCode(TaxGroupBuffer.FIELDNO(Code), DATABASE::"Tax Group Buffer");
        TaxGroupBuffer.Description := FORMAT(CREATEGUID());
        TaxGroupJSON := GetTaxGroupJSON(TaxGroupBuffer);
        COMMIT();

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Tax Groups", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, TaxGroupJSON, ResponseText);

        // [THEN] The tax group has been created in the database.
        LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'id', TaxGroupId);
        VerifyTaxGroupProperties(ResponseText, TaxGroupId);
    end;

    [Test]
    procedure TestModifyTaxGroup()
    var
        TaxGroupBuffer: Record "Tax Group Buffer";
        TaxGroupCode: Text;
        TaxGroupId: Text;
        ResponseText: Text;
        TargetURL: Text;
        TaxGroupJSON: Text;
    begin
        // [SCENARIO] User can modify a Tax Group through a PATCH request.
        Initialize();

        // [GIVEN] An Tax Group exists.
        CreateTaxGroup(TaxGroupCode, TaxGroupId);
        TaxGroupBuffer.Code := COPYSTR(TaxGroupCode, 1, MAXSTRLEN(TaxGroupBuffer.Code));
        TaxGroupBuffer.SystemId := TaxGroupId;
        TaxGroupBuffer.Description := FORMAT(CREATEGUID());
        TaxGroupJSON := GetTaxGroupJSON(TaxGroupBuffer);
        COMMIT();

        // [WHEN] The user makes a patch request to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL(TaxGroupId, PAGE::"APIV1 - Tax Groups", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, TaxGroupJSON, ResponseText);

        // [THEN] The record in the database contains the new values.
        LibraryGraphMgt.VerifyGUIDFieldInJson(ResponseText, 'id', TaxGroupId);

        // [THEN] The record in the database contains the new values.
        VerifyTaxGroupProperties(ResponseText, TaxGroupId);
    end;

    [Test]
    procedure TestDeleteTaxGroup()
    var
        TaxGroupCode: Text;
        TaxGroupId: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can delete a Tax Group by making a DELETE request.
        Initialize();

        // [GIVEN] A Tax Group exists.
        CreateTaxGroup(TaxGroupCode, TaxGroupId);
        COMMIT();

        // [WHEN] The user makes a DELETE request to the endpoint for the Tax Group.
        TargetURL := LibraryGraphMgt.CreateTargetURL(TaxGroupId, PAGE::"APIV1 - Tax Groups", ServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] The response is empty.
        Assert.AreEqual('', ResponseText, 'DELETE response should be empty.');

        // [THEN] The tax area is no longer in the database.
        VerifyTaxGroupWasDeleted(TaxGroupId);
    end;

    [Normal]
    local procedure CreateTaxGroup(var TaxGroupCode: Text; var TaxGroupId: Text)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        TaxGroup: Record "Tax Group";
        VATProductPostingGroup: Record "VAT Product Posting Group";
    begin
        IF GeneralLedgerSetup.UseVat() THEN BEGIN
            LibraryERM.CreateVATProductPostingGroup(VATProductPostingGroup);
            TaxGroupCode := VATProductPostingGroup.Code;
            TaxGroupId := VATProductPostingGroup.SystemId;
        END ELSE BEGIN
            LibraryERM.CreateTaxGroup(TaxGroup);
            TaxGroupCode := TaxGroup.Code;
            TaxGroupId := TaxGroup.SystemId;
        END;
    end;

    [Normal]
    local procedure GetAndVerifyIDFromJSON(ResponseText: Text; TaxCode: array[2] of Text)
    var
        TaxGroupJSON: array[2] of Text;
    begin
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(ResponseText, 'code', TaxCode[1], TaxCode[2], TaxGroupJSON[1], TaxGroupJSON[2]),
          'Could not find the TaxGroup in JSON');
        LibraryGraphMgt.VerifyIDInJson(TaxGroupJSON[1]);
        LibraryGraphMgt.VerifyIDInJson(TaxGroupJSON[2]);
    end;

    local procedure GetTaxGroupJSON(var TaxGroupBuffer: Record "Tax Group Buffer") TaxGroupJSON: Text
    begin
        TaxGroupJSON := LibraryGraphMgt.AddPropertytoJSON('', 'id', FormatGuid(TaxGroupBuffer.SystemId));
        TaxGroupJSON := LibraryGraphMgt.AddPropertytoJSON(TaxGroupJSON, 'code', TaxGroupBuffer.Code);
        TaxGroupJSON := LibraryGraphMgt.AddPropertytoJSON(TaxGroupJSON, 'displayName', TaxGroupBuffer.Description);

    end;

    local procedure VerifyPropertyInJSON(JSON: Text; PropertyName: Text; ExpectedValue: Text)
    var
        PropertyValue: Text;
    begin
        LibraryGraphMgt.GetObjectIDFromJSON(JSON, PropertyName, PropertyValue);
        Assert.AreEqual(ExpectedValue, PropertyValue, STRSUBSTNO(WrongPropertyValueErr, PropertyName));
    end;

    local procedure VerifyTaxGroupProperties(TaxGroupJSON: Text; TaxGroupID: Text)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        TaxGroup: Record "Tax Group";
        ExpectedCode: Text;
        ExpectedDecritpion: Text;
    begin
        Assert.AreNotEqual('', TaxGroupJSON, EmptyJSONErr);
        LibraryGraphMgt.VerifyIDInJson(TaxGroupJSON);

        IF GeneralLedgerSetup.UseVat() THEN BEGIN
            Assert.IsTrue(VATProductPostingGroup.GetBySystemId(TaxGroupID), 'VAT Product Group was not created for given ID');
            ExpectedCode := VATProductPostingGroup.Code;
            ExpectedDecritpion := VATProductPostingGroup.Description;
        END ELSE BEGIN
            Assert.IsTrue(TaxGroup.GetBySystemId(TaxGroupID), 'Tax Group was not created for given ID');
            ExpectedCode := TaxGroup.Code;
            ExpectedDecritpion := TaxGroup.Description;
        END;

        VerifyPropertyInJSON(TaxGroupJSON, 'code', ExpectedCode);
        VerifyPropertyInJSON(TaxGroupJSON, 'displayName', ExpectedDecritpion);
    end;

    local procedure VerifyTaxGroupWasDeleted(TaxGroupId: Text)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        TaxGroup: Record "Tax Group";
        VATProductPostingGroup: Record "VAT Product Posting Group";
    begin
        IF GeneralLedgerSetup.UseVat() THEN
            Assert.IsFalse(VATProductPostingGroup.GetBySystemId(TaxGroupId), 'VATProductPostingGroup should be deleted.')
        ELSE
            Assert.IsFalse(TaxGroup.GetBySystemId(TaxGroupId), 'TaxGroup should be deleted.');
    end;

    local procedure FormatGuid(Value: Guid): Text
    begin
        EXIT(LOWERCASE(LibraryGraphMgt.StripBrackets(Value)));
    end;
}




















