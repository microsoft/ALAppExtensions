// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Integration;

using System.Integration;
using System.TestLibraries.Integration;
using System.TestLibraries.Environment;
using System.TestLibraries.Utilities;
using System.TestLibraries.Security.AccessControl;

codeunit 132618 "Page Summary Setup Test"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;

    var
        LibraryAssert: Codeunit "Library Assert";
        PageSummaryProvider: Codeunit "Page Summary Provider";
        PageSummaryProviderTest: Codeunit "Page Summary Provider Test";
        PermissionsMock: Codeunit "Permissions Mock";

    [Test]
    procedure FieldsArePopulatedWhenShowSummaryIsEnabled()
    var
        PageProviderSummaryTest: Record "Page Provider Summary Test";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        PageSummarySettings: TestPage "Page Summary Settings";
        PageSummaryJsonObject: JsonObject;
        Bookmark: Text;
    begin
        PermissionsMock.Set('Page Sum Admin Test');
        Init();
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [Given] Page Summary Provider Setup is completed and Show Summary is enabled
        PageSummarySettings.Trap();
        Page.Run(Page::"Page Summary Settings");
        LibraryAssert.IsTrue(PageSummarySettings.ActionNext.Visible(), 'Next is not visible');
        LibraryAssert.IsFalse(PageSummarySettings.ActionBack.Visible(), 'Back is visible');
        PageSummarySettings.ActionNext.Invoke();
        LibraryAssert.IsTrue(PageSummarySettings.ActionNext.Visible(), 'Next is not visible');
        LibraryAssert.IsTrue(PageSummarySettings.ActionBack.Visible(), 'Back is not visible');
        PageSummarySettings.ShowRecordSummary.SetValue(true);
        PageSummarySettings.ActionNext.Invoke();
        LibraryAssert.IsFalse(PageSummarySettings.ActionNext.Visible(), 'Next is visible');
        LibraryAssert.IsTrue(PageSummarySettings.ActionBack.Visible(), 'Back is not visible');
        LibraryAssert.IsTrue(PageSummarySettings.ActionTryItOut.Visible(), 'Try it out is not visible');
        LibraryAssert.IsTrue(PageSummarySettings.ActionDone.Visible(), 'Done is not visible');


        // [Given] A record
        PageProviderSummaryTest.TestInteger := 1;
        PageProviderSummaryTest.TestText := 'Page Summary';
        PageProviderSummaryTest.TestCode := 'PROVIDER';
        PageProviderSummaryTest.TestDateTime := CurrentDateTime();
        PageProviderSummaryTest.Insert();

        Bookmark := ExtractBookmarkForPageProviderTestCard(PageProviderSummaryTest.RecordId());

        // [When] We get the summary for a page for that record
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummary(Page::"Page Summary Test Card", Bookmark));

        // [Then] The summary has the fields
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
    procedure FieldsArePopulatedBySystemIdWhenShowSummaryIsEnabled()
    var
        PageProviderSummaryTest: Record "Page Provider Summary Test";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        PageSummarySettings: TestPage "Page Summary Settings";
        PageSummaryJsonObject: JsonObject;
    begin
        PermissionsMock.Set('Page Sum Admin Test');
        Init();
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [Given] Page Summary Provider Setup is completed and Show Summary is enabled
        PageSummarySettings.Trap();
        Page.Run(Page::"Page Summary Settings");
        LibraryAssert.IsTrue(PageSummarySettings.ActionNext.Visible(), 'Next is not visible');
        LibraryAssert.IsFalse(PageSummarySettings.ActionBack.Visible(), 'Back is visible');
        PageSummarySettings.ActionNext.Invoke();
        LibraryAssert.IsTrue(PageSummarySettings.ActionNext.Visible(), 'Next is not visible');
        LibraryAssert.IsTrue(PageSummarySettings.ActionBack.Visible(), 'Back is not visible');
        PageSummarySettings.ShowRecordSummary.SetValue(true);
        PageSummarySettings.ActionNext.Invoke();
        LibraryAssert.IsFalse(PageSummarySettings.ActionNext.Visible(), 'Next is visible');
        LibraryAssert.IsTrue(PageSummarySettings.ActionBack.Visible(), 'Back is not visible');
        LibraryAssert.IsTrue(PageSummarySettings.ActionTryItOut.Visible(), 'Try it out is not visible');
        LibraryAssert.IsTrue(PageSummarySettings.ActionDone.Visible(), 'Done is not visible');


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
    procedure OnlyCaptionIsPopulatedWhenShowSummaryIsDisabled()
    var
        PageProviderSummaryTest: Record "Page Provider Summary Test";
        PageSummarySettings: Record "Page Summary Settings";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        PageSummarySettingsTestPage: TestPage "Page Summary Settings";
        PageSummaryJsonObject: JsonObject;
        Bookmark: Text;
    begin
        PermissionsMock.Set('Page Sum Admin Test');
        Init();
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [Given] Page Summary Provider Setup is completed and Show Summary is not enabled
        PageSummarySettingsTestPage.Trap();
        Page.Run(Page::"Page Summary Settings");
        LibraryAssert.IsTrue(PageSummarySettingsTestPage.ActionNext.Visible(), 'Next is not visible');
        LibraryAssert.IsFalse(PageSummarySettingsTestPage.ActionBack.Visible(), 'Back is visible');
        PageSummarySettingsTestPage.ActionNext.Invoke();
        LibraryAssert.IsTrue(PageSummarySettingsTestPage.ActionNext.Visible(), 'Next is not visible');
        LibraryAssert.IsTrue(PageSummarySettingsTestPage.ActionBack.Visible(), 'Back is not visible');
        PageSummarySettingsTestPage.ShowRecordSummary.SetValue(false);
        PageSummarySettingsTestPage.ActionNext.Invoke();
        LibraryAssert.IsFalse(PageSummarySettingsTestPage.ActionNext.Visible(), 'Next is visible');
        LibraryAssert.IsTrue(PageSummarySettingsTestPage.ActionBack.Visible(), 'Back is not visible');
        LibraryAssert.IsTrue(PageSummarySettingsTestPage.ActionTryItOut.Visible(), 'Try it out is not visible');
        LibraryAssert.IsTrue(PageSummarySettingsTestPage.ActionDone.Visible(), 'Done is not visible');


        // [Given] A record
        PageProviderSummaryTest.TestInteger := 1;
        PageProviderSummaryTest.Insert();

        Bookmark := ExtractBookmarkForPageProviderTestCard(PageProviderSummaryTest.RecordId);

        // [When] We get the summary for a page for that record
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummary(Page::"Page Summary Test Card", Bookmark));

        // [Then] The summary type caption is shown
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page summary', 'Card', 'Caption');
        LibraryAssert.IsFalse(FieldsExist(PageSummaryJsonObject), 'Fields should not exist.');

        // [Then] There are no error object
        LibraryAssert.IsFalse(PageSummaryJsonObject.Contains('error'), 'Page summary json should not contain an error object');

        // Cleanup
        PageSummarySettings.DeleteAll();
    end;

    [Test]
    procedure OnlyCaptionIsPopulatedBySystemIdWhenShowSummaryIsDisabled()
    var
        PageProviderSummaryTest: Record "Page Provider Summary Test";
        PageSummarySettings: Record "Page Summary Settings";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        PageSummarySettingsTestPage: TestPage "Page Summary Settings";
        PageSummaryJsonObject: JsonObject;
    begin
        PermissionsMock.Set('Page Sum Admin Test');
        Init();
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [Given] Page Summary Provider Setup is completed and Show Summary is not enabled
        PageSummarySettingsTestPage.Trap();
        Page.Run(Page::"Page Summary Settings");
        LibraryAssert.IsTrue(PageSummarySettingsTestPage.ActionNext.Visible(), 'Next is not visible');
        LibraryAssert.IsFalse(PageSummarySettingsTestPage.ActionBack.Visible(), 'Back is visible');
        PageSummarySettingsTestPage.ActionNext.Invoke();
        LibraryAssert.IsTrue(PageSummarySettingsTestPage.ActionNext.Visible(), 'Next is not visible');
        LibraryAssert.IsTrue(PageSummarySettingsTestPage.ActionBack.Visible(), 'Back is not visible');
        PageSummarySettingsTestPage.ShowRecordSummary.SetValue(false);
        PageSummarySettingsTestPage.ActionNext.Invoke();
        LibraryAssert.IsFalse(PageSummarySettingsTestPage.ActionNext.Visible(), 'Next is visible');
        LibraryAssert.IsTrue(PageSummarySettingsTestPage.ActionBack.Visible(), 'Back is not visible');
        LibraryAssert.IsTrue(PageSummarySettingsTestPage.ActionTryItOut.Visible(), 'Try it out is not visible');
        LibraryAssert.IsTrue(PageSummarySettingsTestPage.ActionDone.Visible(), 'Done is not visible');


        // [Given] A record and no fields are being returned
        PageProviderSummaryTest.TestInteger := 1;
        PageProviderSummaryTest.Insert();
        PageProviderSummaryTest.FindFirst();

        // [When] We get the summary for a page by system id for that record
        PageSummaryJsonObject.ReadFrom(PageSummaryProvider.GetPageSummaryBySystemId(Page::"Page Summary Test Card", PageProviderSummaryTest.SystemId));

        // [Then] The summary is of type caption when there are no fields
        ValidateSummaryHeader(PageSummaryJsonObject, 'Page summary', 'Card', 'Caption');
        LibraryAssert.IsTrue(UrlExist(PageSummaryJsonObject), 'Page summary json should have a url to the object.');
        LibraryAssert.IsFalse(FieldsExist(PageSummaryJsonObject), 'Fields should not exist.');

        // [Then] There are no error object
        LibraryAssert.IsFalse(PageSummaryJsonObject.Contains('error'), 'Page summary json should not contain an error object');

        // Cleanup
        PageSummarySettings.DeleteAll();
    end;

    local procedure Init()
    var
        PageProviderSummaryTest: Record "Page Provider Summary Test";
        PageSummarySettings: Record "Page Summary Settings";
    begin
        PageProviderSummaryTest.DeleteAll();
        PageSummarySettings.DeleteAll();
        UnbindSubscription(PageSummaryProviderTest);
        Clear(PageSummaryProviderTest);
    end;

    local procedure ValidateSummaryHeader(PageSummaryJsonObject: JsonObject; ExpectedPageCaption: Text; ExpectedPageType: Text; ExpectedSummaryType: Text)
    begin
        LibraryAssert.AreEqual(ExpectedPageCaption, ReadJsonString(PageSummaryJsonObject, 'pageCaption'), 'Incorrect pageCaption');
        LibraryAssert.AreEqual(ExpectedPageType, ReadJsonString(PageSummaryJsonObject, 'pageType'), 'Incorrect pageType');
        LibraryAssert.AreEqual(ExpectedSummaryType, ReadJsonString(PageSummaryJsonObject, 'summaryType'), 'Incorrect summaryType');
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
}
