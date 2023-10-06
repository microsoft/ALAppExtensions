// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Integration;

using System.Integration;
using System.TestLibraries.Integration;
using System.TestLibraries.Utilities;
using System.TestLibraries.Security.AccessControl;

codeunit 132616 "Page Action Provider Test"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;

    var
        LibraryAssert: Codeunit "Library Assert";
        PageActionProviderImpl: Codeunit "Page Action Provider Impl.";
        PageActionProviderTest: Codeunit "Page Action Provider Test";
        PermissionsMock: Codeunit "Permissions Mock";
        HandleOnAfterGetPageAction: Boolean;

    [Test]
    procedure ActionsArePopulatedWithoutViews()
    var
        ResultJsonObject: JsonObject;
    begin
        PermissionsMock.Set('Page Action Read');
        Init();

        // [When] We get the actions for a role center
        PageActionProviderImpl.AppendHomeItemsActions(Page::"Home Items Page Action Test", ResultJsonObject, false);

        // [Then] The result reflects the page actions
        LibraryAssert.AreEqual(2, GetNumberOfItems(ResultJsonObject), 'Incorrect number of home items returned.');
        ValidateHomeItemAction(ResultJsonObject, 0, 'Page with views', GetUrl(ClientType::Web, CompanyName, ObjectType::Page, Page::"Views Page Action Test"));
        ValidateHomeItemAction(ResultJsonObject, 1, 'Empty card page', GetUrl(ClientType::Web, CompanyName, ObjectType::Page, Page::"Empty Card Page Action Test"));

        // [Then] There are no error object
        LibraryAssert.IsFalse(ResultJsonObject.Contains('error'), 'Page Action json should not contain an error object');
    end;

    [Test]
    procedure ActionsArePopulatedWithViews()
    var
        ResultJsonObject: JsonObject;
        ActionWithViewsJsonObject: JsonObject;
    begin
        PermissionsMock.Set('Page Action Read');
        Init();

        // [When] We get the actions for a role center
        PageActionProviderImpl.AppendHomeItemsActions(Page::"Home Items Page Action Test", ResultJsonObject, true);

        // [Then] The result reflects the page actions
        LibraryAssert.AreEqual(2, GetNumberOfItems(ResultJsonObject), 'Incorrect number of home items returned.');
        ValidateHomeItemAction(ResultJsonObject, 0, 'Page with views', GetUrl(ClientType::Web, CompanyName, ObjectType::Page, Page::"Views Page Action Test"));
        ActionWithViewsJsonObject := GetActionObject(ResultJsonObject, 'items', 0);
        ValidateViewAction(ActionWithViewsJsonObject, 0, 'TestBoolean', GetUrl(ClientType::Web, CompanyName, ObjectType::Page, Page::"Views Page Action Test"), 'BooleanView', '%27Page%20Action%20Provider%20Test%27.TestBoolean%20IS%20%271%27');
        ValidateViewAction(ActionWithViewsJsonObject, 1, 'TestBoolean TestDecimal', GetUrl(ClientType::Web, CompanyName, ObjectType::Page, Page::"Views Page Action Test"), 'BooleanDecimalView', '&filter=%27Page%20Action%20Provider%20Test%27.TestBoolean%20IS%20%271%27%20AND%20%27Page%20Action%20Provider%20Test%27.TestDecimal%20IS%20%2710%27');
        // Validating filter string with spaces in table and field name
        ValidateViewAction(ActionWithViewsJsonObject, 2, 'TestSpaces', GetUrl(ClientType::Web, CompanyName, ObjectType::Page, Page::"Views Page Action Test"), 'SpacesView', '&filter=%27Page%20Action%20Provider%20Test%27.%27Field%20With%20Spaces%27%20IS%20%2720%27');
        ValidateHomeItemAction(ResultJsonObject, 1, 'Empty card page', GetUrl(ClientType::Web, CompanyName, ObjectType::Page, Page::"Empty Card Page Action Test"));

        // [Then] There are no error object
        LibraryAssert.IsFalse(ResultJsonObject.Contains('error'), 'Page Action json should not contain an error object');
    end;

    [Test]
    procedure EmptyActions()
    var
        ResultJsonObject: JsonObject;
    begin
        PermissionsMock.Set('Page Action Read');
        Init();

        // [When] We get the actions for an empty page
        PageActionProviderImpl.AppendHomeItemsActions(Page::"Empty Card Page Action Test", ResultJsonObject, false);

        // [Then] There are no error object
        LibraryAssert.IsFalse(ResultJsonObject.Contains('error'), 'Page Action json should not contain an error object');

        // [Then] There are no home items
        LibraryAssert.AreEqual(false, ItemsExist(ResultJsonObject), 'There should be no home items.');
    end;

    [Test]
    procedure OnAfterGetPageActionModifyAndAddValues()
    var
        ResultJsonObject: JsonObject;
    begin
        PermissionsMock.Set('Page Action Read');
        Init();

        // [Given] OnAfterGetPageActions is subscribed
        BindSubscription(PageActionProviderTest);
        PageActionProviderTest.SetHandleOnAfterGetPageAction(true);

        // [When] We get the actions for a role center
        PageActionProviderImpl.AppendHomeItemsActions(Page::"Home Items Page Action Test", ResultJsonObject, false);

        // [Then] The result reflects the modified actions
        LibraryAssert.AreEqual(3, GetNumberOfItems(ResultJsonObject), 'Incorrect number of home items returned.');
        ValidateHomeItemAction(ResultJsonObject, 0, 'Page with views', GetUrl(ClientType::Web, CompanyName, ObjectType::Page, 22));
        ValidateHomeItemAction(ResultJsonObject, 1, 'Empty card page', GetUrl(ClientType::Web, CompanyName, ObjectType::Page, Page::"Empty Card Page Action Test"));
        ValidateHomeItemAction(ResultJsonObject, 2, 'Customers', GetUrl(ClientType::Web, CompanyName, ObjectType::Page, 22));

        // [Then] There are no error object
        LibraryAssert.IsFalse(ResultJsonObject.Contains('error'), 'Page Action json should not contain an error object');

    end;

    procedure SetHandleOnAfterGetPageAction(NewValue: Boolean)
    begin
        HandleOnAfterGetPageAction := NewValue;
    end;

    local procedure Init()
    begin
        UnbindSubscription(PageActionProviderTest);
        PageActionProviderTest.SetHandleOnAfterGetPageAction(false);
    end;

    local procedure GetActionObject(ResultJsonObject: JsonObject; ActionTypeTokenString: Text; ActionIndex: Integer): JsonObject
    var
        ActionsArrayJsonToken: JsonToken;
        ActionJsonToken: JsonToken;
    begin
        ResultJsonObject.Get(ActionTypeTokenString, ActionsArrayJsonToken);
        LibraryAssert.IsTrue(ActionsArrayJsonToken.AsArray().Get(ActionIndex, ActionJsonToken), 'Could not find action number ' + format(ActionIndex));
        exit(actionJsonToken.AsObject());
    end;

    local procedure ValidateHomeItemAction(ResultJsonObject: JsonObject; ActionIndex: Integer; ExpectedActionCaption: Text; ExpectedActionUrl: Text)
    var
        ActionJsonObject: JsonObject;
    begin
        ActionJsonObject := GetActionObject(ResultJsonObject, 'items', ActionIndex);

        LibraryAssert.AreEqual(ExpectedActionCaption, ReadJsonString(ActionJsonObject, 'caption'), 'Incorrect  caption');
        LibraryAssert.AreEqual(ExpectedActionUrl, ReadJsonString(ActionJsonObject, 'url'), 'Incorrect url');
    end;

    local procedure ValidateViewAction(ResultJsonObject: JsonObject; ActionIndex: Integer; ExpectedActionCaption: Text; ExpectedBaseUrl: Text; ExpectedViewName: Text; ExpectedFilterUrl: Text)
    var
        ActionJsonObject: JsonObject;
        ActualUrl: Text;
    begin
        ActionJsonObject := GetActionObject(ResultJsonObject, 'views', ActionIndex);

        LibraryAssert.AreEqual(ExpectedActionCaption, ReadJsonString(ActionJsonObject, 'caption'), 'Incorrect  caption');
        ActualUrl := ReadJsonString(ActionJsonObject, 'url');
        LibraryAssert.IsTrue(ActualUrl.Contains(ExpectedBaseUrl), 'Incorrect base url');
        LibraryAssert.IsTrue(ActualUrl.Contains(ExpectedViewName), 'Incorrect view name');
        LibraryAssert.IsTrue(ActualUrl.Contains(ExpectedFilterUrl), 'Incorrect filters in the url');
    end;

    local procedure ReadJsonString(JsonObject: JsonObject; KeyValue: Text) FieldValue: Text
    var
        JsonToken: JsonToken;
    begin
        JsonObject.Get(KeyValue, JsonToken);
        FieldValue := JsonToken.AsValue().AsText();
    end;

    local procedure AddAction(var ActionsJsonArray: JsonArray; Caption: Text; Url: Text)
    var
        ActionsJsonObject: JsonObject;
    begin
        ActionsJsonObject.Add('caption', Caption);
        ActionsJsonObject.Add('url', Url);
        ActionsJsonArray.Add(ActionsJsonObject);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Action Provider", 'OnAfterGetPageActions', '', false, false)]
    local procedure OnAfterGetPageActions(PageId: Integer; IncludeViews: Boolean; var ItemsJsonArray: JsonArray)
    var
        ItemJsonToken: JsonToken;
        CaptionToken: JsonToken;
        actionNo: Integer;
    begin
        if not HandleOnAfterGetPageAction then
            exit;

        if PageId = Page::"Home Items Page Action Test" then begin
            AddAction(ItemsJsonArray, 'Customers', GetUrl(ClientType::Web, CompanyName, ObjectType::Page, 22));

            // Change url of action caption
            for actionNo := 0 to ItemsJsonArray.Count() - 1 do begin
                ItemsJsonArray.Get(actionNo, ItemJsonToken);
                ItemJsonToken.AsObject().Get('caption', CaptionToken);
                if CaptionToken.AsValue().AsText() = 'Page with views' then begin
                    ItemJsonToken.AsObject().Replace('url', GetUrl(ClientType::Web, CompanyName, ObjectType::Page, 22));
                    ItemsJsonArray.Set(actionNo, ItemJsonToken);
                end;
            end;
        end;
    end;

    local procedure GetNumberOfItems(ResultJsonObject: JsonObject): Integer
    var
        actionsArrayJsonToken: JsonToken;
    begin
        ResultJsonObject.Get('items', actionsArrayJsonToken);
        exit(actionsArrayJsonToken.AsArray().Count());
    end;

    local procedure ItemsExist(ResultJsonObject: JsonObject): Boolean
    var
        actionsArrayJsonToken: JsonToken;
    begin
        if (ResultJsonObject.Get('items', actionsArrayJsonToken)) then
            exit(actionsArrayJsonToken.AsArray().Count() > 0);
        exit(false);
    end;

}
