codeunit 139712 "APIV1 - UofM E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Unit of Measure]
    end;

    var
        Assert: Codeunit "Assert";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryUtility: Codeunit "Library - Utility";
        WrongPropertyValueErr: Label 'Incorrect property value for %1', Comment = '%1=Incorrect property value';
        ServiceNameTxt: Label 'unitsOfMeasure';

    [Test]
    procedure TestGetUnitOfMeasure()
    var
        UnitOfMeasure: Record "Unit of Measure";
        Response: Text;
    begin
        // [SCENARIO] User can get the units of measure.

        // [GIVEN] Units of measure.
        GenerateUnitsOfMeasure(UnitOfMeasure, 5);

        // [WHEN] A GET request is made of the service.
        LibraryGraphMgt.GetFromWebService(Response, GetServiceUrlForEntity(UnitOfMeasure.SystemId));

        // [THEN] The response contains the entity requested.
        ValidateUnitOfMeasure(UnitOfMeasure, Response);
    end;

    [Test]
    procedure TestModifyUnitOfMeasure()
    var
        UnitOfMeasure: Record "Unit of Measure";
        Request: Text;
        Response: Text;
        OldDescription: Text;
    begin
        // [SCENARIO] User can update a unit of measure.

        // [GIVEN] Units of measure.
        GenerateUnitsOfMeasure(UnitOfMeasure, 5);

        // [GIVEN] One is modified with a new description.
        OldDescription := UnitOfMeasure.Description;
        Request := CreateModifyUnitOfMeasureRequest(UnitOfMeasure);

        // [GIVEN] The request contains a different description from the original Unit of Measure.
        Assert.AreNotEqual(UnitOfMeasure.Description, OldDescription, STRSUBSTNO(WrongPropertyValueErr, 'displayName'));

        // [WHEN] A PATCH is made against the entity.
        LibraryGraphMgt.PatchToWebService(GetServiceUrlForEntity(UnitOfMeasure.SystemId), Request, Response);

        // [THEN] The response matches the data given in the request.
        ValidateUnitOfMeasure(UnitOfMeasure, Response);

        // [THEN] The response matches the latest data in the database.
        UnitOfMeasure.GET(UnitOfMeasure.Code);
        ValidateUnitOfMeasure(UnitOfMeasure, Response);
    end;

    [Test]
    procedure TestDeleteUnitOfMeasure()
    var
        UnitOfMeasure: Record "Unit of Measure";
        Response: Text;
    begin
        // [SCENARIO] User can delete a unit of measure.

        // [GIVEN] Units of measure.
        GenerateUnitsOfMeasure(UnitOfMeasure, 5);

        // [WHEN] A DEELTE is made against an entity.
        LibraryGraphMgt.DeleteFromWebService(GetServiceUrlForEntity(UnitOfMeasure.SystemId), '', Response);

        // [THEN] The response is empty and the data is no longer in the table.
        Assert.AreEqual('', Response, 'Expected empty response for DELETE.');
        Assert.IsFalse(UnitOfMeasure.GET(), 'Expected data in table to be missing.');
    end;

    [Test]
    procedure TestInsertUnitOfMeasure()
    var
        UnitOfMeasure: Record "Unit of Measure";
        Response: Text;
        Request: Text;
        "Code": Text;
    begin
        // [SCENARIO] User can insert a unit of measure.

        // [GIVEN] A new unit of measure.
        GenerateUnitOfMeasure(UnitOfMeasure);
        Request := CreateInsertUnitOfMeasureRequest(UnitOfMeasure);

        // [WHEN] A POST is made against an entity.
        LibraryGraphMgt.PostToWebService(GetServiceUrl(), Request, Response);

        // [THEN] The entity is in the table.
        UnitOfMeasure.INIT();
        LibraryGraphMgt.GetObjectIDFromJSON(Response, 'code', Code);
        UnitOfMeasure.GET(Code);

        ValidateUnitOfMeasure(UnitOfMeasure, Response);
    end;

    local procedure GenerateUnitsOfMeasure(var UnitOfMeasure: Record "Unit of Measure"; "Count": Integer)
    var
        i: Integer;
    begin
        FOR i := 0 TO Count DO BEGIN
            GenerateUnitOfMeasure(UnitOfMeasure);
            UnitOfMeasure.INSERT(TRUE);
        END;
        COMMIT();
    end;

    local procedure GenerateUnitOfMeasure(var UnitOfMeasure: Record "Unit of Measure")
    begin
        UnitOfMeasure.INIT();
        UnitOfMeasure.VALIDATE(Code, LibraryUtility.GenerateRandomCode(UnitOfMeasure.FIELDNO(Code), DATABASE::"Unit of Measure"));
        UnitOfMeasure.VALIDATE(Description, LibraryUtility.GenerateRandomAlphabeticText(10, 1));
        UnitOfMeasure.VALIDATE(
          "International Standard Code",
          LibraryUtility.GenerateRandomCode(UnitOfMeasure.FIELDNO("International Standard Code"), DATABASE::"Unit of Measure"));
        UnitOfMeasure.VALIDATE(Symbol, LibraryUtility.GenerateRandomCode(UnitOfMeasure.FIELDNO(Symbol), DATABASE::"Unit of Measure"));
    end;

    local procedure CreateModifyUnitOfMeasureRequest(var UnitOfMeasure: Record "Unit of Measure") RequestJSON: Text
    var
        NewName: Text[10];
    begin
        NewName := FORMAT(LibraryUtility.GenerateRandomAlphabeticText(10, 1), 10);
        RequestJSON := LibraryGraphMgt.AddPropertytoJSON('', 'id', UnitOfMeasure.SystemId);
        RequestJSON := LibraryGraphMgt.AddPropertytoJSON(RequestJSON, 'displayName', NewName);

        UnitOfMeasure.VALIDATE(Description, NewName);
    end;

    local procedure CreateInsertUnitOfMeasureRequest(var UnitOfMeasure: Record "Unit of Measure") RequestJSON: Text
    begin
        RequestJSON := LibraryGraphMgt.AddPropertytoJSON('', 'displayName', UnitOfMeasure.Description);
        RequestJSON := LibraryGraphMgt.AddPropertytoJSON(RequestJSON, 'code', UnitOfMeasure.Code);
        RequestJSON := LibraryGraphMgt.AddPropertytoJSON(RequestJSON, 'internationalStandardCode', UnitOfMeasure."International Standard Code");
    end;

    local procedure GetServiceUrlForEntity(Id: Guid) Url: Text
    begin
        Url := LibraryGraphMgt.CreateTargetURL(Id, PAGE::"APIV1 - Units of Measure", ServiceNameTxt);
    end;

    local procedure GetServiceUrl() Url: Text
    begin
        Url := LibraryGraphMgt.GetODataTargetURL(ObjectType::Page, PAGE::"APIV1 - Units of Measure")
    end;

    local procedure ValidateUnitOfMeasure(var UnitOfMeasure: Record "Unit of Measure"; Response: Text)
    var
        Id: Text;
    begin
        LibraryGraphMgt.GetObjectIDFromJSON(Response, 'id', Id);
        Assert.AreNotEqual('00000000-0000-0000-000000000000', Id, STRSUBSTNO(WrongPropertyValueErr, 'id'));
        ValidateUserSettableProperties(UnitOfMeasure, Response);
    end;

    local procedure ValidateUserSettableProperties(var UnitOfMeasure: Record "Unit of Measure"; Response: Text)
    var
        "Code": Text;
        DisplayName: Text;
        InternationalStandardCode: Text;
    begin
        LibraryGraphMgt.GetObjectIDFromJSON(Response, 'code', Code);
        LibraryGraphMgt.GetObjectIDFromJSON(Response, 'displayName', DisplayName);
        LibraryGraphMgt.GetObjectIDFromJSON(Response, 'internationalStandardCode', InternationalStandardCode);

        Assert.AreEqual(FORMAT(UnitOfMeasure.Code), Code, STRSUBSTNO(WrongPropertyValueErr, 'code'));
        Assert.AreEqual(FORMAT(UnitOfMeasure.Description), DisplayName, STRSUBSTNO(WrongPropertyValueErr, 'displayName'));
        Assert.AreEqual(
          FORMAT(UnitOfMeasure."International Standard Code"), InternationalStandardCode,
          STRSUBSTNO(WrongPropertyValueErr, 'internationalStandardCode'));
    end;
}
















