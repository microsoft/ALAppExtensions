// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132548 "Page Summary Provider Test"
{
    EventSubscriberInstance = Manual;
    SingleInstance = true;
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit "Library Assert";
        PageSummaryProvider: Codeunit "Page Summary Provider";
        PageSummaryProviderTest: Codeunit "Page Summary Provider Test";
        OverrideFields: List of [Integer];

    [Test]
    procedure FieldsArePopulated()
    var
        PageProviderSummaryTest: Record "Page Provider Summary Test";
        PageSummaryJsonObject: JsonObject;
        Bookmark: Text;
    begin
        Init();

        // [Given] A record
        PageProviderSummaryTest.TestInteger := 1;
        PageProviderSummaryTest.TestText := 'Page Summary';
        PageProviderSummaryTest.TestCode := 'PROVIDER';
        PageProviderSummaryTest.TestDateTime := CurrentDateTime;
        PageProviderSummaryTest.Insert();

        Bookmark := ExtractBookmarkForPageProviderTestCard(PageProviderSummaryTest);

        // [When] We get the summary for a page for that record
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummary(Page::"Page Summary Test Card", Bookmark));

        // [Then] The summary reflects the page and record
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page summary', 'Card', 'Brick');
        Assert.AreEqual(4, GetNumberOfFields(PageSummaryJsonObject), 'Incorrect number of fields returned.');
        ValidateSummaryField(PageSummaryJsonObject, 0, 'TestText', PageProviderSummaryTest.TestText, 'Text');
        ValidateSummaryField(PageSummaryJsonObject, 1, 'TestInteger', format(PageProviderSummaryTest.TestInteger), 'Integer');
        ValidateSummaryField(PageSummaryJsonObject, 2, 'TestCode', PageProviderSummaryTest.TestCode, 'Code');
        ValidateSummaryField(PageSummaryJsonObject, 3, 'TestDateTime', format(PageProviderSummaryTest.TestDateTime), 'DateTime');
    end;

    // [Test]
    procedure InvalidPage()
    var
        PageProviderSummaryTest: Record "Page Provider Summary Test";
        Bookmark: Text;
    begin
        Init();

        // [Given] A record
        PageProviderSummaryTest.TestInteger := 1;
        PageProviderSummaryTest.TestText := 'Page Summary';
        PageProviderSummaryTest.TestCode := 'PROVIDER';
        PageProviderSummaryTest.TestDateTime := CurrentDateTime;
        PageProviderSummaryTest.Insert();

        Bookmark := ExtractBookmarkForPageProviderTestCard(PageProviderSummaryTest);

        // [When] We get the summary for a page that does not exist
        // [Then] An error is thrown
        asserterror PageSummaryProvider.GetPageSummary(0, Bookmark);
        Assert.ExpectedError('The metadata object Page 0 was not found.');

        // [When] We get the summary for a page that does not exist
        // [Then] An error is thrown
        asserterror PageSummaryProvider.GetPageSummary(-100, Bookmark);
        Assert.ExpectedError('The metadata object Page -100 was not found.');
        /* TODO: Fix tests
        // [When] We get the summary for a page with no source table
        // [Then] An error is thrown
        asserterror PageSummaryProvider.GetPageSummary(Page::"AutoFormat Test Page", Bookmark);
        Assert.ExpectedError('Object reference not set to an instance of an object.');

        // [When] We get the summary for a page where the bookmark is invalid
        // [Then] An error is thrown
        asserterror PageSummaryProvider.GetPageSummary(Page::"Extension Management", Bookmark);
        Assert.ExpectedError('The requested record cannot be located.');

        // [When] We get the summary for a page with no bookmark
        // [Then] An error is thrown
        asserterror PageSummaryProvider.GetPageSummary(Page::"Extension Management", '');
        Assert.ExpectedError('Value cannot be null.');

        // [When] We get the summary for a page with invalid bookmark
        // [Then] An error is thrown
        asserterror PageSummaryProvider.GetPageSummary(Page::"Extension Management", 'fdsfjsdfjsdklj');
        Assert.ExpectedError('The bookmark is not in a valid format.');
        */
    end;

    [Test]
    procedure EmptyFields()
    var
        PageProviderSummaryTest: Record "Page Provider Summary Test";
        PageSummaryJsonObject: JsonObject;
        Bookmark: Text;
    begin
        Init();

        // [Given] A record
        PageProviderSummaryTest.TestInteger := 1;
        PageProviderSummaryTest.TestText := '';
        PageProviderSummaryTest.TestCode := '';
        PageProviderSummaryTest.Insert();

        Bookmark := ExtractBookmarkForPageProviderTestCard(PageProviderSummaryTest);

        // [When] We get the summary for a page for that record
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummary(Page::"Page Summary Test Card", Bookmark));

        // [Then] The summary reflects the page and record
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page summary', 'Card', 'Brick');
        Assert.AreEqual(4, GetNumberOfFields(PageSummaryJsonObject), 'Incorrect number of fields returned.');
        ValidateSummaryField(PageSummaryJsonObject, 0, 'TestText', PageProviderSummaryTest.TestText, 'Text');
        ValidateSummaryField(PageSummaryJsonObject, 1, 'TestInteger', format(PageProviderSummaryTest.TestInteger), 'Integer');
        ValidateSummaryField(PageSummaryJsonObject, 2, 'TestCode', PageProviderSummaryTest.TestCode, 'Code');
        ValidateSummaryField(PageSummaryJsonObject, 3, 'TestDateTime', '', 'DateTime');
    end;

    [Test]
    procedure OverrideBrickFields()
    var
        PageProviderSummaryTest: Record "Page Provider Summary Test";
        PageSummaryJsonObject: JsonObject;
        Bookmark: Text;
    begin
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
        PageSummaryProviderTest.SetOverrideFields(OverrideFields);

        Bookmark := ExtractBookmarkForPageProviderTestCard(PageProviderSummaryTest);

        // [When] We get the summary for a page for that record
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummary(Page::"Page Summary Test Card", Bookmark));

        // [Then] The summary reflects the page and record
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page summary', 'Card', 'Brick');
        Assert.AreEqual(2, GetNumberOfFields(PageSummaryJsonObject), 'Incorrect number of fields returned.');
        ValidateSummaryField(PageSummaryJsonObject, 0, 'TestDateTime', format(PageProviderSummaryTest.TestDateTime), 'DateTime');
        ValidateSummaryField(PageSummaryJsonObject, 1, 'TestDecimal', format(PageProviderSummaryTest.TestDecimal), 'Decimal');

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
        // Verifies whether strings are translated or not
        Init();

        // [Given] A record and no fields are being returned
        PageProviderSummaryTest.TestInteger := 1;
        PageProviderSummaryTest.Insert();
        BindSubscription(PageSummaryProviderTest); // Override with no fields
        PageSummaryProviderTest.SetOverrideFields(OverrideFields);

        Bookmark := ExtractBookmarkForPageProviderTestCard(PageProviderSummaryTest);

        // [When] We get the summary for a page for that record
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummary(Page::"Page Summary Test Card", Bookmark));

        // [Then] The summary is of type brick (since summary type is currently not exposed to partner) and there are no fields
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page summary', 'Card', 'Brick');
        Assert.AreEqual(0, GetNumberOfFields(PageSummaryJsonObject), 'Incorrect number of fields returned.');

        // Cleanup
        UnbindSubscription(PageSummaryProviderTest);
    end;

    procedure SetOverrideFields(OverrideFields_: List of [Integer])
    begin
        OverrideFields := OverrideFields_;
    end;

    /* TODO:
        Validate picture
        Validate no picture
        Validate picture subtype
        Through event:
            - Remove all fields
            - add all fields on page
            - add fields which does not exist
            - add 1-10 fields
        Throw error on page
        permissions
        visibility?
    */

    local procedure Init()
    var
        PageProviderSummaryTest: Record "Page Provider Summary Test";
    begin
        PageProviderSummaryTest.DeleteAll();
        clear(OverrideFields);
        UnbindSubscription(PageSummaryProviderTest);
    end;

    local procedure ValidateSummaryHeader(PageSummaryJsonObject: JsonObject; ExpectedPageCaption: Text; ExpectedPageType: Text; ExpectedSummaryType: Text)
    begin
        Assert.AreEqual(ExpectedPageCaption, ReadJsonString(PageSummaryJsonObject, 'pageCaption'), 'Incorrect pageCaption');
        Assert.AreEqual(ExpectedPageType, ReadJsonString(PageSummaryJsonObject, 'pageType'), 'Incorrect pageType');
        Assert.AreEqual(ExpectedSummaryType, ReadJsonString(PageSummaryJsonObject, 'summaryType'), 'Incorrect summaryType');
    end;

    local procedure ValidateSummaryField(PageSummaryJsonObject: JsonObject; FieldNumber: Integer; ExpectedFieldCaption: Text; ExpectedFieldValue: Text; ExpectedFieldtype: Text)
    var
        fieldsArrayJsonToken: JsonToken;
        fieldJsonToken: JsonToken;
        fieldJsonObject: JsonObject;
    begin
        PageSummaryJsonObject.Get('fields', fieldsArrayJsonToken);
        Assert.IsTrue(fieldsArrayJsonToken.AsArray().Get(FieldNumber, fieldJsonToken), 'Could not find field number ' + format(FieldNumber));
        fieldJsonObject := fieldJsonToken.AsObject();

        Assert.AreEqual(ExpectedFieldCaption, ReadJsonString(fieldJsonObject, 'caption'), 'Incorrect field caption');
        Assert.AreEqual(ExpectedFieldValue, ReadJsonString(fieldJsonObject, 'fieldValue'), 'Incorrect fieldValue');
        Assert.AreEqual(ExpectedFieldtype, ReadJsonString(fieldJsonObject, 'fieldType'), 'Incorrect fieldType');
    end;

    local procedure GetNumberOfFields(PageSummaryJsonObject: JsonObject): Integer
    var
        fieldsArrayJsonToken: JsonToken;
    begin
        PageSummaryJsonObject.Get('fields', fieldsArrayJsonToken);
        exit(fieldsArrayJsonToken.AsArray().Count());
    end;

    local procedure ReadJsonString(JsonObject: JsonObject; KeyValue: Text) FieldValue: Text
    var
        JsonToken: JsonToken;
    begin
        JsonObject.Get(KeyValue, JsonToken);
        FieldValue := JsonToken.AsValue().AsText();
    end;

    local procedure ExtractBookmarkForPageProviderTestCard(PageProviderSummaryTest: Record "Page Provider Summary Test"): Text
    var
        HttpUtility: DotNet HttpUtility;
        Url: Text;
        BookmarkStartPos: Integer;
        BookmarkEndPos: Integer;
        Bookmark: Text;
    begin
        Url := GetUrl(ClientType::Web, CompanyName, ObjectType::Page, Page::"Page Summary Test Card", PageProviderSummaryTest);

        BookmarkStartPos := StrPos(Url, '&bookmark=') + 10;
        Bookmark := CopyStr(Url, BookmarkStartPos);
        BookmarkEndPos := StrPos(Bookmark, '&');
        if BookmarkEndPos <> 0 then
            Bookmark := CopyStr(Bookmark, 1, BookmarkEndPos - 1);
        exit(HttpUtility.UrlDecode(Bookmark));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Summary Provider", 'OnAfterGetSummaryFields', '', false, false)]
    local procedure OnBeforeGetSummaryValues(PageId: Integer; RecId: RecordId; var FieldList: List of [Integer])
    begin
        FieldList := OverrideFields;
    end;
}

