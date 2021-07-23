// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132548 "Page Summary Provider Test"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;

    var
        LibraryAssert: Codeunit "Library Assert";
        PageSummaryProvider: Codeunit "Page Summary Provider";
        PageSummaryProviderTest: Codeunit "Page Summary Provider Test";
        PermissionsMock: Codeunit "Permissions Mock";
        OverrideFields: List of [Integer];
        HandleOnAfterGetSummaryFields: Boolean;
        HandleOnBeforeGetPageSummary: Boolean;
        HandleOnAfterGetPageSummary: Boolean;
        InvalidBookmarkErrorCodeTok: Label 'InvalidBookmark', Locked = true;
        InvalidBookmarkErrorMessageTxt: Label 'The bookmark is invalid.';
        InvalidSystemIdErrorCodeTok: Label 'InvalidSystemId', Locked = true;
        InvalidSystemIdErrorMessageTxt: Label 'The system ID is invalid.';
        FailedGetSummaryFieldsCodeTok: Label 'FailedGettingPageSummaryFields', Locked = true;
        CannotOpenSpecifiedRecordTxt: Label 'Cannot open the specified record because it is from a different table than the Page Provider Summary Test table, which the current page is based on.';

    [Test]
    procedure FieldsArePopulated()
    var
        PageProviderSummaryTest: Record "Page Provider Summary Test";
        PageSummaryJsonObject: JsonObject;
        Bookmark: Text;
    begin
        PermissionsMock.Set('Page Summary Read');
        Init();

        // [Given] A record
        PageProviderSummaryTest.TestInteger := 1;
        PageProviderSummaryTest.TestText := 'Page Summary';
        PageProviderSummaryTest.TestCode := 'PROVIDER';
        PageProviderSummaryTest.TestDateTime := CurrentDateTime();
        PageProviderSummaryTest.Insert();

        Bookmark := ExtractBookmarkForPageProviderTestCard(PageProviderSummaryTest.RecordId());

        // [When] We get the summary for a page for that record
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummary(Page::"Page Summary Test Card", Bookmark));

        // [Then] The summary reflects the page and record
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page summary', 'Card', 'Brick');
        LibraryAssert.AreEqual('132549', ReadJsonString(PageSummaryJsonObject, 'cardPageId'), 'Incorrect cardPageId');
        LibraryAssert.AreEqual(4, GetNumberOfFields(PageSummaryJsonObject), 'Incorrect number of fields returned.');
        ValidateSummaryField(PageSummaryJsonObject, 0, 'TestText', PageProviderSummaryTest.TestText, 'Text');
        ValidateSummaryField(PageSummaryJsonObject, 1, 'TestInteger', format(PageProviderSummaryTest.TestInteger), 'Integer');
        ValidateSummaryField(PageSummaryJsonObject, 2, 'TestCode', PageProviderSummaryTest.TestCode, 'Code');
        ValidateSummaryField(PageSummaryJsonObject, 3, 'TestDateTime', format(PageProviderSummaryTest.TestDateTime), 'DateTime');

        // [Then] There are no error object
        LibraryAssert.IsFalse(PageSummaryJsonObject.Contains('error'), 'Page summary json should not contain an error object');
    end;

    [Test]
    procedure FieldsArePopulatedBySystemId()
    var
        PageProviderSummaryTest: Record "Page Provider Summary Test";
        PageSummaryJsonObject: JsonObject;
    begin
        PermissionsMock.Set('Page Summary Read');
        Init();

        // [Given] A record
        PageProviderSummaryTest.TestInteger := 1;
        PageProviderSummaryTest.TestText := 'Page Summary';
        PageProviderSummaryTest.TestCode := 'PROVIDER';
        PageProviderSummaryTest.TestDateTime := CurrentDateTime();
        PageProviderSummaryTest.Insert();
        PageProviderSummaryTest.FindFirst();
        // [When] We get the summary for a page by system id for that record
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummaryBySystemId(Page::"Page Summary Test Card", PageProviderSummaryTest.SystemId));

        // [Then] The summary reflects the page and record
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page summary', 'Card', 'Brick');
        LibraryAssert.IsTrue(UrlExist(PageSummaryJsonObject), 'Page summary json should have a url to the object.');
        LibraryAssert.AreEqual(4, GetNumberOfFields(PageSummaryJsonObject), 'Incorrect number of fields returned.');
        ValidateSummaryField(PageSummaryJsonObject, 0, 'TestText', PageProviderSummaryTest.TestText, 'Text');
        ValidateSummaryField(PageSummaryJsonObject, 1, 'TestInteger', format(PageProviderSummaryTest.TestInteger), 'Integer');
        ValidateSummaryField(PageSummaryJsonObject, 2, 'TestCode', PageProviderSummaryTest.TestCode, 'Code');
        ValidateSummaryField(PageSummaryJsonObject, 3, 'TestDateTime', format(PageProviderSummaryTest.TestDateTime), 'DateTime');

        // [Then] There are no error object
        LibraryAssert.IsFalse(PageSummaryJsonObject.Contains('error'), 'Page summary json should not contain an error object');
    end;

    [Test]
    procedure InvalidPage()
    var
        PageProviderSummaryTest: Record "Page Provider Summary Test";
        PageProviderSummaryTest2: Record "Page Provider Summary Test2";
        PageSummaryJsonObject: JsonObject;
        Bookmark: Text;
        Bookmark2: Text;
    begin
        PermissionsMock.Set('Page Summary Read');
        Init();

        // [Given] A record
        PageProviderSummaryTest.TestInteger := 1;
        PageProviderSummaryTest.TestText := 'Page Summary';
        PageProviderSummaryTest.TestCode := 'PROVIDER';
        PageProviderSummaryTest.TestDateTime := CurrentDateTime;
        PageProviderSummaryTest.Insert();
        PageProviderSummaryTest2.TestInteger := 1;
        PageProviderSummaryTest2.Insert();

        Bookmark := ExtractBookmarkForPageProviderTestCard(PageProviderSummaryTest.RecordId);
        Bookmark2 := ExtractBookmarkForPageProviderTestCard(PageProviderSummaryTest2.RecordId);

        // [When] We get the summary for a page that does not exist
        // [Then] An error is thrown
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummary(0, Bookmark));
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page 0', 'Card', 'Caption');
        LibraryAssert.IsFalse(FieldsExist(PageSummaryJsonObject), 'Page 0 should not have any fields.');

        // [When] We get the summary for a page that does not exist
        // [Then] An error is thrown
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummary(-100, Bookmark));
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page -100', 'Card', 'Caption');
        LibraryAssert.IsFalse(FieldsExist(PageSummaryJsonObject), 'Page -100 should not have any fields.');

        // [When] We get the summary for a page with no source table
        // [Then] An error is thrown
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummary(Page::"Page Summary Empty Page", Bookmark));
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page Summary Empty Page', 'Card', 'Caption');
        LibraryAssert.AreEqual('0', ReadJsonString(PageSummaryJsonObject, 'cardPageId'), 'Incorrect cardPageId');
        LibraryAssert.IsFalse(FieldsExist(PageSummaryJsonObject), 'Page Summary Empty Page should not have any fields.');

        // [When] We get the summary for a page where the bookmark is invalid
        // [Then] An error is thrown
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummary(Page::"Page Summary Test Card", Bookmark2));
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page summary', 'Card', 'Caption');
        ValidateErrorObject(PageSummaryJsonObject, FailedGetSummaryFieldsCodeTok, CannotOpenSpecifiedRecordTxt);

        // [When] We get the summary for a page with no bookmark
        // [Then] A summary containing just the page information is returned
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummary(Page::"Page Summary Test Card", ''));
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page summary', 'Card', 'Caption');

        // [When] We get the summary for a page with invalid bookmark
        // [Then] An error is thrown
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummary(Page::"Page Summary Empty Page", 'fdsfjsdfjsdklj'));
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page Summary Empty Page', 'Card', 'Caption');
        ValidateErrorObject(PageSummaryJsonObject, InvalidBookmarkErrorCodeTok, InvalidBookmarkErrorMessageTxt);
    end;

    [Test]
    procedure InvalidPageBySystemId()
    var
        PageProviderSummaryTest: Record "Page Provider Summary Test";
        PageSummaryJsonObject: JsonObject;
        SystemId: Guid;
    begin
        PermissionsMock.Set('Page Summary Read');
        Init();

        // [Given] 2 records
        PageProviderSummaryTest.TestInteger := 1;
        PageProviderSummaryTest.TestText := 'Page Summary';
        PageProviderSummaryTest.TestCode := 'PROVIDER';
        PageProviderSummaryTest.TestDateTime := CurrentDateTime;
        PageProviderSummaryTest.Insert();

        PageProviderSummaryTest.FindFirst();
        SystemId := PageProviderSummaryTest.SystemId;

        // [When] We get the summary by system Id for a page that does not exist
        // [Then] An error is thrown
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummaryBySystemID(0, SystemId));
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page 0', 'Card', 'Caption');
        LibraryAssert.IsFalse(FieldsExist(PageSummaryJsonObject), 'Page 0 should not have any fields.');
        LibraryAssert.IsFalse(UrlExist(PageSummaryJsonObject), 'Page -100 should not have url.');

        // [When] We get the summary by system Id for a page that does not exist
        // [Then] An error is thrown
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummaryBySystemID(-100, SystemId));
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page -100', 'Card', 'Caption');
        LibraryAssert.IsFalse(UrlExist(PageSummaryJsonObject), 'Page -100 should not have url.');
        LibraryAssert.IsFalse(FieldsExist(PageSummaryJsonObject), 'Page -100 should not have any fields.');

        // [When] We get the summary by system Id for a page with no source table
        // [Then] An error is thrown
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummaryBySystemID(Page::"Page Summary Empty Page", SystemId));
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page Summary Empty Page', 'Card', 'Caption');
        LibraryAssert.IsFalse(UrlExist(PageSummaryJsonObject), 'Response should not have url.');
        LibraryAssert.IsFalse(FieldsExist(PageSummaryJsonObject), 'Page Summary Empty Page should not have any fields.');
        ValidateErrorObject(PageSummaryJsonObject, InvalidSystemIdErrorCodeTok, InvalidSystemIdErrorMessageTxt);

        // [When] We get the summary for a page with invalid system Id
        // [Then] An error is thrown
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummaryBySystemID(Page::"Page Summary Test Card", CreateGuid()));
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page summary', 'Card', 'Caption');
        LibraryAssert.IsFalse(UrlExist(PageSummaryJsonObject), 'Response should not have url.');
        ValidateErrorObject(PageSummaryJsonObject, InvalidSystemIdErrorCodeTok, InvalidSystemIdErrorMessageTxt);

        // [When] We get the summary by system Id for a page empty system Id
        // [Then] An error is thrown
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummaryBySystemID(Page::"Page Summary Test Card", '00000000-0000-0000-0000-000000000000'));
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page summary', 'Card', 'Caption');
        LibraryAssert.IsFalse(UrlExist(PageSummaryJsonObject), 'Response should not have url.');
        ValidateErrorObject(PageSummaryJsonObject, InvalidSystemIdErrorCodeTok, InvalidSystemIdErrorMessageTxt);
    end;

    [Test]
    procedure EmptyFields()
    var
        PageProviderSummaryTest: Record "Page Provider Summary Test";
        PageSummaryJsonObject: JsonObject;
        Bookmark: Text;
    begin
        PermissionsMock.Set('Page Summary Read');
        Init();

        // [Given] A record
        PageProviderSummaryTest.TestInteger := 1;
        PageProviderSummaryTest.TestText := '';
        PageProviderSummaryTest.TestCode := '';
        PageProviderSummaryTest.Insert();

        Bookmark := ExtractBookmarkForPageProviderTestCard(PageProviderSummaryTest.RecordId);

        // [When] We get the summary for a page for that record
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummary(Page::"Page Summary Test Card", Bookmark));

        // [Then] The summary reflects the page and record
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page summary', 'Card', 'Brick');
        LibraryAssert.AreEqual(4, GetNumberOfFields(PageSummaryJsonObject), 'Incorrect number of fields returned.');
        ValidateSummaryField(PageSummaryJsonObject, 0, 'TestText', PageProviderSummaryTest.TestText, 'Text');
        ValidateSummaryField(PageSummaryJsonObject, 1, 'TestInteger', format(PageProviderSummaryTest.TestInteger), 'Integer');
        ValidateSummaryField(PageSummaryJsonObject, 2, 'TestCode', PageProviderSummaryTest.TestCode, 'Code');
        ValidateSummaryField(PageSummaryJsonObject, 3, 'TestDateTime', '', 'DateTime');

        // [Then] There are no error object
        LibraryAssert.IsFalse(PageSummaryJsonObject.Contains('error'), 'Page summary json should not contain an error object');
    end;

    [Test]
    procedure OverrideBrickFields()
    var
        PageProviderSummaryTest: Record "Page Provider Summary Test";
        PageSummaryJsonObject: JsonObject;
        Bookmark: Text;
    begin
        PermissionsMock.Set('Page Summary Read');
        // Verifies whether strings are translated or not
        Init();

        // [Given] A record
        PageProviderSummaryTest.TestInteger := 1;
        PageProviderSummaryTest.TestDateTime := CreateDateTime(DMY2Date(23, 1, 2020), 0T);
        PageProviderSummaryTest.TestDecimal := 123456789.987654321;
        PageProviderSummaryTest.Insert();
        OverrideFields.Add(PageProviderSummaryTest.FieldNo(TestDateTime));
        OverrideFields.Add(PageProviderSummaryTest.FieldNo(TestDecimal));
        BindSubscription(PageSummaryProviderTest);
        PageSummaryProviderTest.SetHandleOnAfterGetSummaryFields(true, OverrideFields);

        Bookmark := ExtractBookmarkForPageProviderTestCard(PageProviderSummaryTest.RecordId);

        // [When] We get the summary for a page for that record
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummary(Page::"Page Summary Test Card", Bookmark));

        // [Then] The summary reflects the page and record
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page summary', 'Card', 'Brick');
        LibraryAssert.AreEqual(2, GetNumberOfFields(PageSummaryJsonObject), 'Incorrect number of fields returned.');
        ValidateSummaryField(PageSummaryJsonObject, 0, 'TestDateTime', format(PageProviderSummaryTest.TestDateTime), 'DateTime');
        ValidateSummaryField(PageSummaryJsonObject, 1, 'TestDecimal', format(PageProviderSummaryTest.TestDecimal), 'Decimal');

        // [Then] There are no error object
        LibraryAssert.IsFalse(PageSummaryJsonObject.Contains('error'), 'Page summary json should not contain an error object');

        // Cleanup
        UnbindSubscription(PageSummaryProviderTest);
    end;

    [Test]
    procedure CaptionSummaryType()
    var
        PageProviderSummaryTest: Record "Page Provider Summary Test";
        PageSummaryJsonObject: JsonObject;
        Bookmark: Text;
    begin
        PermissionsMock.Set('Page Summary Read');
        // Verifies whether strings are translated or not
        Init();

        // [Given] A record and no fields are being returned
        PageProviderSummaryTest.TestInteger := 1;
        PageProviderSummaryTest.Insert();
        BindSubscription(PageSummaryProviderTest); // Override with no fields
        PageSummaryProviderTest.SetHandleOnAfterGetSummaryFields(true, OverrideFields);

        Bookmark := ExtractBookmarkForPageProviderTestCard(PageProviderSummaryTest.RecordId);

        // [When] We get the summary for a page for that record
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummary(Page::"Page Summary Test Card", Bookmark));

        // [Then] The summary is of type caption when there are no fields
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page summary', 'Card', 'Caption');
        LibraryAssert.IsFalse(FieldsExist(PageSummaryJsonObject), 'Incorrect number of fields returned.');

        // [Then] There are no error object
        LibraryAssert.IsFalse(PageSummaryJsonObject.Contains('error'), 'Page summary json should not contain an error object');

        // Cleanup
        UnbindSubscription(PageSummaryProviderTest);
    end;

    [Test]
    procedure OnAfterGetSummaryFieldsAddAllFields()
    var
        PageProviderSummaryTest: Record "Page Provider Summary Test";
        RecordRef: RecordRef;
        PageSummaryJsonObject: JsonObject;
        Bookmark: Text;
        fieldNo: Integer;
        fieldsSkipped: Integer;
    begin
        PermissionsMock.Set('Page Summary Read');
        // Verifies whether strings are translated or not
        Init();

        // [Given] A record
        PageProviderSummaryTest.TestInteger := 1;
        PageProviderSummaryTest.TestDateTime := CreateDateTime(DMY2Date(23, 1, 2020), 0T);
        PageProviderSummaryTest.TestDecimal := 123456789.987654321;
        PageProviderSummaryTest.Insert();
        RecordRef.GetTable(PageProviderSummaryTest);
        for fieldNo := 1 to RecordRef.FieldCount do
            OverrideFields.Add(RecordRef.Field(fieldNo).Number); // Add all fields to the page summary
        BindSubscription(PageSummaryProviderTest);
        PageSummaryProviderTest.SetHandleOnAfterGetSummaryFields(true, OverrideFields);

        Bookmark := ExtractBookmarkForPageProviderTestCard(PageProviderSummaryTest.RecordId);

        // [When] We get the summary for a page for that record
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummary(Page::"Page Summary Test Card", Bookmark));

        // [Then] The summary reflects the page and record
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page summary', 'Card', 'Brick');
        LibraryAssert.AreEqual(RecordRef.FieldCount - 1, GetNumberOfFields(PageSummaryJsonObject), 'Incorrect number of fields returned.');
        for fieldNo := 1 to RecordRef.FieldCount - 1 do
            if not (RecordRef.Field(fieldNo).Type in [FieldType::Media, FieldType::MediaSet]) then // Ignore Mediaset fields for now since they have value '', not '<empty guid>' which requires a bit more hardcoding for testing
                if RecordRef.Field(fieldNo).Type <> FieldType::Blob then // Blob fields are not added
                    ValidateSummaryField(PageSummaryJsonObject, fieldNo - 1 - fieldsSkipped, RecordRef.Field(fieldNo).Caption, format(RecordRef.Field(fieldNo).Value), format(RecordRef.Field(fieldNo).Type))
                else
                    fieldsSkipped += 1;

        // [Then] There are no error object
        LibraryAssert.IsFalse(PageSummaryJsonObject.Contains('error'), 'Page summary json should not contain an error object');

        // Cleanup
        UnbindSubscription(PageSummaryProviderTest);
    end;

    [Test]
    procedure OnBeforeGetPageSummaryReadRecord()
    var
        PageProviderSummaryTest: Record "Page Provider Summary Test";
        PageSummaryJsonObject: JsonObject;
        Bookmark: Text;
    begin
        PermissionsMock.Set('Page Summary Read');
        // Verifies whether strings are translated or not
        Init();

        // [Given] A record
        PageProviderSummaryTest.TestInteger := 1;
        PageProviderSummaryTest.TestDateTime := CreateDateTime(DMY2Date(23, 1, 2020), 0T);
        PageProviderSummaryTest.TestDecimal := 123456789.987654321;
        PageProviderSummaryTest.Insert();
        BindSubscription(PageSummaryProviderTest);
        PageSummaryProviderTest.SetHandleOnBeforeGetPageSummary(true);

        Bookmark := ExtractBookmarkForPageProviderTestCard(PageProviderSummaryTest.RecordId);

        // [When] We get the summary for a page for that record
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummary(Page::"Page Summary Test Card", Bookmark));

        // [Then] The summary reflects the page and record
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page summary', 'Card', 'Brick');
        LibraryAssert.AreEqual(3, GetNumberOfFields(PageSummaryJsonObject), 'Incorrect number of fields returned.');
        ValidateSummaryField(PageSummaryJsonObject, 0, 'TestCaption', 'FieldValue', 'Text');
        ValidateSummaryField(PageSummaryJsonObject, 1, 'TestDateTime', format(PageProviderSummaryTest.TestDateTime), 'DateTime');
        ValidateSummaryField(PageSummaryJsonObject, 2, 'TestDecimal', format(PageProviderSummaryTest.TestDecimal) + '10', 'Decimal');

        // [Then] There are no error object
        LibraryAssert.IsFalse(PageSummaryJsonObject.Contains('error'), 'Page summary json should not contain an error object');

        // Cleanup
        UnbindSubscription(PageSummaryProviderTest);
    end;

    [Test]
    procedure OnAfterGetPageSummaryModifyAndAddValues()
    var
        PageProviderSummaryTest: Record "Page Provider Summary Test";
        PageSummaryJsonObject: JsonObject;
        Bookmark: Text;
    begin
        PermissionsMock.Set('Page Summary Read');
        // Verifies whether strings are translated or not
        Init();

        // [Given] A record
        PageProviderSummaryTest.TestInteger := 1;
        PageProviderSummaryTest.TestDateTime := CreateDateTime(DMY2Date(23, 1, 2020), 0T);
        PageProviderSummaryTest.TestDecimal := 123456789.987654321;
        PageProviderSummaryTest.Insert();
        BindSubscription(PageSummaryProviderTest);
        PageSummaryProviderTest.SetHandleOnAfterGetPageSummary(true);

        Bookmark := ExtractBookmarkForPageProviderTestCard(PageProviderSummaryTest.RecordId);

        // [When] We get the summary for a page for that record
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummary(Page::"Page Summary Test Card", Bookmark));

        // [Then] The summary reflects the page and record
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page summary', 'Card', 'Brick');
        LibraryAssert.AreEqual(5, GetNumberOfFields(PageSummaryJsonObject), 'Incorrect number of fields returned.');
        ValidateSummaryField(PageSummaryJsonObject, 0, 'TestText', PageProviderSummaryTest.TestText, 'Text');
        ValidateSummaryField(PageSummaryJsonObject, 1, 'TestInteger', 'ModifiedValue', 'Integer');
        ValidateSummaryField(PageSummaryJsonObject, 2, 'TestCode', PageProviderSummaryTest.TestCode, 'Code');
        ValidateSummaryField(PageSummaryJsonObject, 3, 'TestDateTime', format(PageProviderSummaryTest.TestDateTime), 'DateTime');
        ValidateSummaryField(PageSummaryJsonObject, 4, 'TestDecimal', format(PageProviderSummaryTest.TestDecimal) + '10', 'Decimal');

        // [Then] There are no error object
        LibraryAssert.IsFalse(PageSummaryJsonObject.Contains('error'), 'Page summary json should not contain an error object');

        // Cleanup
        UnbindSubscription(PageSummaryProviderTest);
    end;

    procedure SetHandleOnAfterGetSummaryFields(HandleOnAfterGetSummaryFields_: Boolean; OverrideFields_: List of [Integer])
    begin
        HandleOnAfterGetSummaryFields := HandleOnAfterGetSummaryFields_;
        OverrideFields := OverrideFields_;
    end;

    procedure SetHandleOnBeforeGetPageSummary(HandleOnBeforeGetPageSummary_: Boolean)
    begin
        HandleOnBeforeGetPageSummary := HandleOnBeforeGetPageSummary_;
    end;

    procedure SetHandleOnAfterGetPageSummary(HandleOnAfterGetPageSummary_: Boolean)
    begin
        HandleOnAfterGetPageSummary := HandleOnAfterGetPageSummary_;
    end;

    local procedure Init()
    var
        PageProviderSummaryTest: Record "Page Provider Summary Test";
    begin
        PageProviderSummaryTest.DeleteAll();
        Clear(OverrideFields);
        UnbindSubscription(PageSummaryProviderTest);
        Clear(PageSummaryProviderTest);
    end;

    local procedure ValidateSummaryHeader(PageSummaryJsonObject: JsonObject; ExpectedPageCaption: Text; ExpectedPageType: Text; ExpectedSummaryType: Text)
    begin
        LibraryAssert.AreEqual(ExpectedPageCaption, ReadJsonString(PageSummaryJsonObject, 'pageCaption'), 'Incorrect pageCaption');
        LibraryAssert.AreEqual(ExpectedPageType, ReadJsonString(PageSummaryJsonObject, 'pageType'), 'Incorrect pageType');
        LibraryAssert.AreEqual(ExpectedSummaryType, ReadJsonString(PageSummaryJsonObject, 'summaryType'), 'Incorrect summaryType');
    end;

    local procedure ValidateErrorObject(PageSummaryJsonObject: JsonObject; ExpectedErrorCode: Text; ExpectedErrorMessage: Text)
    var
        errorObjectJsonToken: JsonToken;
        errorJsonObject: JsonObject;
    begin
        PageSummaryJsonObject.Get('error', errorObjectJsonToken);
        errorJsonObject := errorObjectJsonToken.AsObject();

        LibraryAssert.AreEqual(ExpectedErrorCode, ReadJsonString(errorJsonObject, 'code'), 'Incorrect error code');
        LibraryAssert.AreEqual(ExpectedErrorMessage, ReadJsonString(errorJsonObject, 'message'), 'Incorrect error message');
    end;

    local procedure ValidateSummaryField(PageSummaryJsonObject: JsonObject; FieldNumber: Integer; ExpectedFieldCaption: Text; ExpectedFieldValue: Text; ExpectedFieldtype: Text)
    var
        fieldsArrayJsonToken: JsonToken;
        fieldJsonToken: JsonToken;
        fieldJsonObject: JsonObject;
    begin
        PageSummaryJsonObject.Get('fields', fieldsArrayJsonToken);
        LibraryAssert.IsTrue(fieldsArrayJsonToken.AsArray().Get(FieldNumber, fieldJsonToken), 'Could not find field number ' + format(FieldNumber));
        fieldJsonObject := fieldJsonToken.AsObject();

        LibraryAssert.AreEqual(ExpectedFieldCaption, ReadJsonString(fieldJsonObject, 'caption'), 'Incorrect field caption');
        LibraryAssert.AreEqual(ExpectedFieldValue, ReadJsonString(fieldJsonObject, 'fieldValue'), 'Incorrect fieldValue');
        LibraryAssert.AreEqual(ExpectedFieldtype, ReadJsonString(fieldJsonObject, 'fieldType'), 'Incorrect fieldType');
    end;

    local procedure GetNumberOfFields(PageSummaryJsonObject: JsonObject): Integer
    var
        fieldsArrayJsonToken: JsonToken;
    begin
        PageSummaryJsonObject.Get('fields', fieldsArrayJsonToken);
        exit(fieldsArrayJsonToken.AsArray().Count());
    end;

    local procedure FieldsExist(PageSummaryJsonObject: JsonObject): Boolean
    var
        fieldsArrayJsonToken: JsonToken;
    begin
        if (PageSummaryJsonObject.Get('fields', fieldsArrayJsonToken)) then
            exit(fieldsArrayJsonToken.AsArray().Count() > 0);
        exit(false);
    end;

    local procedure UrlExist(PageSummaryJsonObject: JsonObject): Boolean
    var
        urlJsonToken: JsonToken;
    begin
        exit(PageSummaryJsonObject.Get('url', urlJsonToken));
    end;

    local procedure ReadJsonString(JsonObject: JsonObject; KeyValue: Text) FieldValue: Text
    var
        JsonToken: JsonToken;
    begin
        JsonObject.Get(KeyValue, JsonToken);
        FieldValue := JsonToken.AsValue().AsText();
    end;

    local procedure ExtractBookmarkForPageProviderTestCard(RecordId: RecordId): Text
    begin
        exit(format(RecordId, 0, 10))
    end;

    local procedure AddField(var FieldsJsonArray: JsonArray; Caption: Text; FieldValue: Text; FieldType: Text)
    var
        FieldsJsonObject: JsonObject;
    begin
        FieldsJsonObject.Add('caption', Caption);
        FieldsJsonObject.Add('fieldValue', FieldValue);
        FieldsJsonObject.Add('fieldType', FieldType);
        FieldsJsonArray.Add(FieldsJsonObject);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Summary Provider", 'OnAfterGetSummaryFields', '', false, false)]
    local procedure OnAfterGetSummaryFields(PageId: Integer; RecId: RecordId; var FieldList: List of [Integer])
    begin
        if not HandleOnAfterGetSummaryFields then
            exit;

        FieldList := OverrideFields;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Summary Provider", 'OnBeforeGetPageSummary', '', false, false)]
    local procedure OnBeforeGetPageSummary(PageId: Integer; RecId: RecordId; var FieldsJsonArray: JsonArray; var Handled: Boolean)
    var
        PageProviderSummaryTest: Record "Page Provider Summary Test";
        RecordRef: RecordRef;
    begin
        if not HandleOnBeforeGetPageSummary then
            exit;

        RecordRef.Get(RecId);
        if PageId = Page::"Page Summary Test Card" then begin
            AddField(FieldsJsonArray, 'TestCaption', 'FieldValue', 'Text');
            AddField(FieldsJsonArray, RecordRef.Field(PageProviderSummaryTest.FieldNo(TestDateTime)).Caption, RecordRef.Field(PageProviderSummaryTest.FieldNo(TestDateTime)).Value, format(RecordRef.Field(PageProviderSummaryTest.FieldNo(TestDateTime)).Type));
            AddField(FieldsJsonArray, RecordRef.Field(PageProviderSummaryTest.FieldNo(TestDecimal)).Caption, format(RecordRef.Field(PageProviderSummaryTest.FieldNo(TestDecimal)).Value) + '10', format(RecordRef.Field(PageProviderSummaryTest.FieldNo(TestDecimal)).Type));
        end;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Summary Provider", 'OnAfterGetPageSummary', '', false, false)]
    local procedure OnAfterGetPageSummary(PageId: Integer; RecId: RecordId; var FieldsJsonArray: JsonArray)
    var
        PageProviderSummaryTest: Record "Page Provider Summary Test";
        RecordRef: RecordRef;
        FieldJsonToken: JsonToken;
        CaptionToken: JsonToken;
        fieldNo: Integer;
    begin
        if not HandleOnAfterGetPageSummary then
            exit;

        RecordRef.Get(RecId);
        if PageId = Page::"Page Summary Test Card" then begin
            AddField(FieldsJsonArray, RecordRef.Field(PageProviderSummaryTest.FieldNo(TestDecimal)).Caption, format(RecordRef.Field(PageProviderSummaryTest.FieldNo(TestDecimal)).Value) + '10', format(RecordRef.Field(PageProviderSummaryTest.FieldNo(TestDecimal)).Type));

            // Change value of field caption
            for fieldNo := 0 to FieldsJsonArray.Count() - 1 do begin
                FieldsJsonArray.Get(fieldNo, FieldJsonToken);
                FieldJsonToken.AsObject().Get('caption', CaptionToken);
                if CaptionToken.AsValue().AsText() = PageProviderSummaryTest.FieldCaption(TestInteger) then begin
                    FieldJsonToken.AsObject().Replace('fieldValue', 'ModifiedValue');
                    FieldsJsonArray.Set(fieldNo, FieldJsonToken);
                end;
            end;
        end;
    end;
}
