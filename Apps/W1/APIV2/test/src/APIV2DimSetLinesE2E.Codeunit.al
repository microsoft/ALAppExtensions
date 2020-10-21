codeunit 139825 "APIV2 - Dim. Set Lines E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Dimension Line]
    end;

    var
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryDimension: Codeunit "Library - Dimension";
        Assert: Codeunit "Assert";
        GraphMgtJournal: Codeunit "Graph Mgt - Journal";
        GraphMgtJournalLines: Codeunit "Graph Mgt - Journal Lines";
        LibraryGraphJournalLines: Codeunit "Library - Graph Journal Lines";
        JournalLinesServiceNameTxt: Label 'journalLines';
        ServiceNameTxt: Label 'dimensionSetLines';
        ParentIdNameTxt: Label 'parentId';
        DimensionIdNameTxt: Label 'id';
        DimensionCodeNameTxt: Label 'code';
        DimensionValueIdNameTxt: Label 'valueId';
        DimensionValueCodeNameTxt: Label 'valueCode';

    procedure Initialize()
    begin
    end;

    [Test]
    procedure TestCreateDimensionSetLine()
    var
        GenJournalLine: Record "Gen. Journal Line";
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        JournalName: Code[10];
        JournalLineGUID: Guid;
        LineNo: Integer;
        LineJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Create a dimension line in journal through a POST method and check if it was created
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateJournal();

        // [GIVEN] a line in the journal
        LineNo := LibraryGraphJournalLines.GetNextJournalLineNo(JournalName);
        JournalLineGUID := CreateJournalLine(JournalName);

        // [GIVEN] a dimension with a value
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        LineJSON := CreateDimensionJSON(Dimension.Code, DimensionValue.Code);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, DimensionIdNameTxt, LibraryGraphMgt.StripBrackets(Format(Dimension.SystemId)));
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, DimensionValueIdNameTxt, LibraryGraphMgt.StripBrackets(Format(DimensionValue.SystemId)));
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(JournalLineGUID, Page::"APIV2 - JournalLines", JournalLinesServiceNameTxt, ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);

        // [THEN] the response text should contain the dimension information and the journal should have the new dimension
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
        VerifyJSONContainsDimensionValues(ResponseText, Dimension.Code, DimensionValue.Code);

        GenJournalLine.SetRange("Journal Template Name", GraphMgtJournal.GetDefaultJournalLinesTemplateName());
        GenJournalLine.SetRange("Line No.", LineNo);
        GenJournalLine.FindFirst();
        Assert.IsTrue(
          DimensionSetIDContainsDimension(GenJournalLine."Dimension Set ID", Dimension.Code, DimensionValue.Code),
          'The dimension line should exist in the SetID of the journal line.');
    end;

    [Test]
    procedure TestCreateDimensionSetLineFailsWithoutParentId()
    var
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        LineJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Creating a dimension line through a POST method without specifying a parent Id fails
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a dimension with a value
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON('', DimensionCodeNameTxt, Dimension.Code);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, DimensionValueCodeNameTxt, DimensionValue.Code);
        Commit();

        // [WHEN] we POST the JSON to the web service
        // [THEN] the request fails because it doesn't have a parent Id
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Dimension Set Lines", ServiceNameTxt);
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);
    end;

    [Test]
    procedure TestCreateDoesntWorkWithAlreadyExistingCode()
    var
        GenJournalLine: Record "Gen. Journal Line";
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        JournalName: Code[10];
        JournalLineGUID: Guid;
        LineNo: Integer;
        LineJSON: array[2] of Text;
        DimensionCode: Code[20];
        DimensionValueCode: array[2] of Code[20];
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Try to create a dimension line with an already existing code
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateJournal();

        // [GIVEN] a journal in the General Journal Table
        LineNo := LibraryGraphJournalLines.GetNextJournalLineNo(JournalName);
        JournalLineGUID := CreateJournalLine(JournalName);

        // [GIVEN] 2 dimension json texts
        LibraryDimension.CreateDimension(Dimension);
        DimensionCode := Dimension.Code;
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        DimensionValueCode[1] := DimensionValue.Code;
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        DimensionValueCode[2] := DimensionValue.Code;
        LineJSON[1] := CreateDimensionJSON(DimensionCode, DimensionValueCode[1]);
        LineJSON[2] := CreateDimensionJSON(DimensionCode, DimensionValueCode[2]);
        Commit();

        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(JournalLineGUID, Page::"APIV2 - JournalLines", JournalLinesServiceNameTxt, ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[1], ResponseText);

        // [WHEN] we POST the JSON to the web service, with the journal filter
        ResponseText := '';
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[2], ResponseText);

        // [THEN] the POST should fail and the dimension should stay the same
        Assert.AreEqual('', ResponseText, 'The POST should fail.');

        GenJournalLine.SetRange("Journal Template Name", GraphMgtJournal.GetDefaultJournalLinesTemplateName());
        GenJournalLine.SetRange("Line No.", LineNo);
        GenJournalLine.FindFirst();
        Assert.IsTrue(
          DimensionSetIDContainsDimension(GenJournalLine."Dimension Set ID", DimensionCode, DimensionValueCode[1]),
          'The dimension line should exist in the SetID of the journal line.');
    end;

    [Test]
    procedure TestGetDimensionSetLinesOfJournalLines()
    var
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        JournalName: Code[10];
        JournalLineGUID: Guid;
        LineJSON: array[2] of Text;
        DimensionCode: array[2] of Code[20];
        DimensionValueCode: array[2] of Code[20];
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create dimension lines in a journal line and use a GET method to retrieve them
        // [GIVEN] a journal in the General Journal Table
        LibraryGraphJournalLines.Initialize();

        JournalName := LibraryGraphJournalLines.CreateJournal();
        JournalLineGUID := CreateJournalLine(JournalName);

        // [GIVEN] 2 dimensions with dimension values
        LibraryDimension.CreateDimension(Dimension);
        DimensionCode[2] := Dimension.Code;
        LibraryDimension.CreateDimension(Dimension);
        DimensionCode[1] := Dimension.Code;
        LibraryDimension.CreateDimensionValue(DimensionValue, DimensionCode[2]);
        DimensionValueCode[2] := DimensionValue.Code;
        LibraryDimension.CreateDimensionValue(DimensionValue, DimensionCode[1]);
        DimensionValueCode[1] := DimensionValue.Code;

        LineJSON[2] := CreateDimensionJSON(DimensionCode[2], DimensionValueCode[2]);
        LineJSON[1] := CreateDimensionJSON(DimensionCode[1], DimensionValueCode[1]);
        Commit();

        // [GIVEN] the dimension lines are added in the journal
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(JournalLineGUID, Page::"APIV2 - JournalLines", JournalLinesServiceNameTxt, ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[2], ResponseText);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[1], ResponseText);

        // [WHEN] we POST the JSON to the web service
        ResponseText := '';
        TargetURL := CreateDimensionSetLinesURLWithFilter(JournalLineGUID, 'Journal Line');
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the 2 dimension lines should exist in the response
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(
            ResponseText, DimensionCodeNameTxt, DimensionCode[2], DimensionCode[1], LineJSON[2], LineJSON[1]),
          'Could not find the lines in JSON');
        VerifyJSONContainsDimensionValues(LineJSON[2], DimensionCode[2], DimensionValueCode[2]);
        VerifyJSONContainsDimensionValues(LineJSON[1], DimensionCode[1], DimensionValueCode[1]);
    end;

    [Test]
    procedure TestGetDimensionSetLinesFailsWithoutFilter()
    var
        GLAccount: Record "G/L Account";
        AccountNo: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Using a GET request to retrieve dimension lines without a filter fails
        LibraryGraphJournalLines.Initialize();

        AccountNo := LibraryGraphJournalLines.CreateAccount();
        GLAccount.Get(AccountNo);

        // [GIVEN] a Target URL without filters
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Dimension Set Lines", ServiceNameTxt);

        // [WHEN] we GET from the web service
        // [THEN] the request fails
        asserterror LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);
    end;

    [Test]
    procedure TestModifyDimensionSetLine()
    var
        GenJournalLine: Record "Gen. Journal Line";
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        JournalName: Code[10];
        JournalLineGUID: Guid;
        DimensionGUID: Guid;
        LineJSON: array[2] of Text;
        DimensionCode: Code[20];
        DimensionValueCode: array[2] of Code[20];
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create a dimension line, use a PATCH method to change it and then verify the changes
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal and a journal line
        JournalName := LibraryGraphJournalLines.CreateJournal();
        JournalLineGUID := CreateJournalLine(JournalName);

        // [GIVEN] 2 dimension json texts
        LibraryDimension.CreateDimension(Dimension);
        DimensionCode := Dimension.Code;
        DimensionGUID := Dimension.SystemId;
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        DimensionValueCode[1] := DimensionValue.Code;
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        DimensionValueCode[2] := DimensionValue.Code;
        LineJSON[1] := CreateDimensionJSON(DimensionCode, DimensionValueCode[1]);

        // [GIVEN] a json text with the new dimension value
        LineJSON[2] := LibraryGraphMgt.AddPropertytoJSON('', DimensionValueCodeNameTxt, DimensionValueCode[2]);
        Commit();

        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(JournalLineGUID, Page::"APIV2 - JournalLines", JournalLinesServiceNameTxt, ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[1], ResponseText);

        // [WHEN] we PATCH the JSON to the web service, with the corresponding keys
        ResponseText := '';
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(JournalLineGUID, Page::"APIV2 - JournalLines", JournalLinesServiceNameTxt, ServiceNameTxt) + '(' + LibraryGraphMgt.StripBrackets(Format(DimensionGUID)) + ')';
        LibraryGraphMgt.PatchToWebService(TargetURL, LineJSON[2], ResponseText);

        // [THEN] the dimension lines in the journal should have the values that were given
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
        VerifyJSONContainsDimensionValues(ResponseText, DimensionCode, DimensionValueCode[2]);

        GenJournalLine.GetBySystemId(JournalLineGUID);
        Assert.IsTrue(
          DimensionSetIDContainsDimension(GenJournalLine."Dimension Set ID", DimensionCode, DimensionValueCode[2]),
          'The dimension line should exist in the SetID of the journal line.');
    end;

    [Test]
    procedure TestModifyOfDimensionCodeDoesntWork()
    var
        GenJournalLine: Record "Gen. Journal Line";
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        JournalName: Code[10];
        JournalLineGUID: Guid;
        DimensionGUID: Guid;
        LineJSON: array[2] of Text;
        DimensionCode: array[2] of Code[20];
        DimensionValueCode: array[2] of Code[20];
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Try to change the code of an existing dimension line
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal and a journal line
        JournalName := LibraryGraphJournalLines.CreateJournal();
        JournalLineGUID := CreateJournalLine(JournalName);

        // [GIVEN] 2 dimensions with dimension values
        LibraryDimension.CreateDimension(Dimension);
        DimensionCode[1] := Dimension.Code;
        DimensionGUID := Dimension.SystemId;
        LibraryDimension.CreateDimension(Dimension);
        DimensionCode[2] := Dimension.Code;
        LibraryDimension.CreateDimensionValue(DimensionValue, DimensionCode[1]);
        DimensionValueCode[1] := DimensionValue.Code;
        LibraryDimension.CreateDimensionValue(DimensionValue, DimensionCode[2]);
        DimensionValueCode[2] := DimensionValue.Code;

        LineJSON[1] := CreateDimensionJSON(DimensionCode[1], DimensionValueCode[1]);
        LineJSON[2] := CreateDimensionJSON(DimensionCode[2], DimensionValueCode[2]);
        Commit();

        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(JournalLineGUID, Page::"APIV2 - JournalLines", JournalLinesServiceNameTxt, ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[1], ResponseText);

        // [WHEN] we PATCH the JSON to the web service, with the new dimension code
        ResponseText := '';
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(JournalLineGUID, Page::"APIV2 - JournalLines", JournalLinesServiceNameTxt, ServiceNameTxt) + '(' + LibraryGraphMgt.StripBrackets(Format(DimensionGUID)) + ')';
        asserterror LibraryGraphMgt.PatchToWebService(TargetURL, LineJSON[2], ResponseText);

        // [THEN] the patch should fail and the dimension line should remain the same
        Assert.AreEqual('', ResponseText, 'The PATCH should fail.');

        GenJournalLine.GetBySystemId(JournalLineGUID);
        Assert.IsTrue(
          DimensionSetIDContainsDimension(GenJournalLine."Dimension Set ID", DimensionCode[1], DimensionValueCode[1]),
          'The dimension line should exist in the SetID of the journal line.');
    end;

    [Test]
    procedure TestDeleteDimensionSetLine()
    var
        GenJournalLine: Record "Gen. Journal Line";
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        JournalName: Code[10];
        JournalLineGUID: Guid;
        LineJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create a dimension line, use a DELETE method to remove it and then verify the deletion
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal and a journal line
        JournalName := LibraryGraphJournalLines.CreateJournal();
        JournalLineGUID := CreateJournalLine(JournalName);

        // [GIVEN] a dimension line in the journal line
        LibraryDimension.CreateDimension(Dimension);
        DimensionValue.Reset();
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        LineJSON := CreateDimensionJSON(Dimension.Code, DimensionValue.Code);
        Commit();

        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(JournalLineGUID, Page::"APIV2 - JournalLines", JournalLinesServiceNameTxt, ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);

        // [WHEN] we DELETE the dimension line from the web service, with the corresponding keys
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(JournalLineGUID, Page::"APIV2 - JournalLines", JournalLinesServiceNameTxt, ServiceNameTxt) + '(' + LibraryGraphMgt.StripBrackets(Format(Dimension.SystemId)) + ')';
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] the dimension line shouldn't exist in the table
        GenJournalLine.GetBySystemId(JournalLineGUID);
        Assert.IsFalse(
          DimensionSetIDContainsDimension(GenJournalLine."Dimension Set ID", Dimension.Code, DimensionValue.Code),
          'The dimension line shouldn''t exist in the SetID of the journal line.');
    end;

    local procedure CreateDimensionJSON(DimensionCode: Code[20]; DimensionValueCode: Code[20]): Text
    var
        LineJSON: Text;
    begin
        LineJSON := LibraryGraphMgt.AddPropertytoJSON('', DimensionCodeNameTxt, DimensionCode);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, DimensionValueCodeNameTxt, DimensionValueCode);

        exit(LineJSON);
    end;

    local procedure CreateJournalLine(JournalName: Code[10]): Guid
    var
        GenJournalLine: Record "Gen. Journal Line";
        LineNo: Integer;
    begin
        LineNo := LibraryGraphJournalLines.CreateSimpleJournalLine(JournalName);
        GraphMgtJournalLines.SetJournalLineTemplateAndBatch(GenJournalLine, JournalName);
        GraphMgtJournalLines.SetJournalLineFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo);
        GenJournalLine.FindFirst();
        exit(GenJournalLine.SystemId);
    end;

    local procedure CreateDimensionSetLinesURLWithFilter(ParentIDFilter: Guid; ParentTypeFilter: Text): Text
    var
        TargetURL: Text;
        UrlFilter: Text;
    begin
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Dimension Set Lines", ServiceNameTxt);

        UrlFilter := '$filter=parentId eq ' + LibraryGraphMgt.StripBrackets(Format(ParentIDFilter)) + ' and parentType eq ''' + ParentTypeFilter + '''';

        if STRPOS(TargetURL, '?') <> 0 then
            TargetURL := TargetURL + '&' + UrlFilter
        else
            TargetURL := TargetURL + '?' + UrlFilter;

        exit(TargetURL);
    end;

    local procedure VerifyJSONContainsDimensionValues(JSONTxt: Text; ExpectedDimensionCode: Text; ExpectedDimensionValueCode: Text)
    var
        DimensionCodeValue: Text;
        DimensionValueCodeValue: Text;
    begin
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(JSONTxt, DimensionCodeNameTxt, DimensionCodeValue), 'Could not find dimension code.');
        Assert.AreEqual(ExpectedDimensionCode, DimensionCodeValue, 'Dimension code does not match.');

        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(JSONTxt, DimensionValueCodeNameTxt, DimensionValueCodeValue),
          'Could not find dimension value code.');
        Assert.AreEqual(ExpectedDimensionValueCode, DimensionValueCodeValue, 'Dimension value code does not match.');
    end;

    local procedure DimensionSetIDContainsDimension(DimensionSetID: Integer; DimensionCode: Code[20]; DimensionValueCode: Code[20]): Boolean
    var
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        DimensionSetEntry.SetRange("Dimension Set ID", DimensionSetID);
        DimensionSetEntry.SetRange("Dimension Code", DimensionCode);
        DimensionSetEntry.SetRange("Dimension Value Code", DimensionValueCode);

        exit(not DimensionSetEntry.IsEmpty());
    end;
}