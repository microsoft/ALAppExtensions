// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Implements functionality to get action data for a given page.
/// </summary>
codeunit 2916 "Page Action Provider Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Page Action" = r,
                  tabledata "User Personalization" = r,
                  tabledata "All Profile" = r;

    procedure GetCurrentRoleCenterHomeItems(IncludeViews: Boolean): Text
    var
        CurrentRoleCenterId: Integer;
        ResultJsonObject: JsonObject;
    begin
        // Add version 
        ResultJsonObject.Add('version', GetVersion());

        // Add current role center Id
        CurrentRoleCenterId := GetCurrentRoleCenterId();

        if CurrentRoleCenterId = 0 then begin
            Session.LogMessage('0000HXE', UnableToGetRoleCenterTelemetryTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PageActionCategoryLbl);
            AddErrorMessage(ResultJsonObject, UnableToGetRoleCenterErrorCodeTok, UnableToGetRoleCenterMessageTxt);
        end;

        ResultJsonObject.Add('roleCenterId', CurrentRoleCenterId);

        // Add home items actions
        AppendHomeItemsActions(CurrentRoleCenterId, ResultJsonObject, IncludeViews);

        exit(Format(ResultJsonObject));
    end;

    local procedure GetCurrentRoleCenterId(): Integer
    var
        AllProfile: Record "All Profile";
        UserPersonalization: Record "User Personalization";
        AzureADPlan: Codeunit "Azure AD Plan";
        EnvironmentInfo: Codeunit "Environment Information";
        RoleCenterID: Integer;
    begin
        // Try to find the current profile
        if UserPersonalization.Get(UserSecurityId()) then
            if UserPersonalization."Profile ID" <> '' then
                if AllProfile.Get(UserPersonalization.Scope, UserPersonalization."App ID", UserPersonalization."Profile ID") then
                    exit(AllProfile."Role Center ID");

        // otherwise it means we are using the default one for this user
        if EnvironmentInfo.IsSaaS() then
            if AzureADPlan.TryGetAzureUserPlanRoleCenterId(RoleCenterID, UserSecurityId()) then;

        exit(RoleCenterID);
    end;

    internal procedure AppendHomeItemsActions(PageId: Integer; var ResultJsonObject: JsonObject; IncludeViews: Boolean)
    var
        HomeItemsJsonArray: JsonArray;
    begin
        // Get home items
        if not TryGetHomeItemsActions(PageId, HomeItemsJsonArray, IncludeViews) then
            AddErrorMessage(ResultJsonObject, FailedGetActionsCodeTok, GetLastErrorText())
        else
            if HomeItemsJsonArray.Count() > 0 then
                ResultJsonObject.Add('items', HomeItemsJsonArray);
    end;

    [TryFunction]
    local procedure TryGetHomeItemsActions(PageId: Integer; var ItemsJsonArray: JsonArray; IncludeViews: Boolean)
    var
        PageAction: Record "Page Action";
        PageActionProvider: Codeunit "Page Action Provider";
        NavPageActionALFunctions: DotNet NavPageActionALFunctions;
        NavPageActionALResponse: DotNet NavPageActionALResponse;
        NavPageActionAL: DotNet NavPageActionAL;
        ErrorMessage: Text;
        HomeItemContainerActionId: Integer;
    begin
        NavPageActionALResponse := NavPageActionALFunctions.GetActions(PageId);

        if not NavPageActionALResponse.Success then begin
            Session.LogMessage('0000HXG', StrSubstNo(ActionsFailureTelemetryTxt, PageId), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PageActionCategoryLbl);
            ErrorMessage := NavPageActionALResponse.ErrorMessage;
            Error(ErrorMessage);
        end;

        // Get home item action container
        HomeItemContainerActionId := GetActionIdByType(NavPageActionALResponse, PageAction."Action Type"::ActionContainer, Enum::"Action Container Type"::HomeItems.AsInteger());

        foreach NavPageActionAL in NavPageActionALResponse.PageActions do
            if (NavPageActionAL.ParentActionId = HomeItemContainerActionId) and (NavPageActionAL.ActionType = PageAction."Action Type"::Action) then
                if ShouldActionBeAdded(NavPageActionAL) then
                    // Add the actual home item action
                    AddHomeItemAction(ItemsJsonArray, NavPageActionAL, IncludeViews);

        // Allow partner to finally override item values
        PageActionProvider.OnAfterGetPageActions(PageId, IncludeViews, ItemsJsonArray);
    end;

    local procedure AddHomeItemAction(var JsonArray: JsonArray; NavPageActionAL: DotNet NavPageActionAL; IncludeViews: Boolean)
    var
        HomeItemActionJsonObject: JsonObject;
        ViewsJsonArray: JsonArray;
    begin
        HomeItemActionJsonObject.Add('caption', NavPageActionAL.Caption.ToString());

        if IncludeViews then
            if TryGetViews(NavPageActionAL.RunObjectId, ViewsJsonArray) then
                if ViewsJsonArray.Count() > 0 then
                    HomeItemActionJsonObject.Add('views', ViewsJsonArray);

        HomeItemActionJsonObject.Add('url', GetUrl(ClientType::Web, CompanyName, ObjectType::Page, NavPageActionAL.RunObjectId));
        JsonArray.Add(HomeItemActionJsonObject);
    end;

    local procedure ShouldActionBeAdded(NavPageActionAL: DotNet NavPageActionAL): Boolean
    begin
        if NavPageActionAL.RunObjectId = 0 then
            exit(false);

        // 1 = Page Object Type
        if NavPageActionAL.RunObjectType <> 1 then
            exit(false);

        exit(true);
    end;

    [TryFunction]
    local procedure TryGetViews(PageId: Integer; var ViewsJsonArray: JsonArray)
    var
        PageAction: Record "Page Action";
        NavPageActionALFunctions: DotNet NavPageActionALFunctions;
        NavPageActionALResponse: DotNet NavPageActionALResponse;
        NavPageActionAL: DotNet NavPageActionAL;
        ErrorMessage: Text;
        ViewContainerActionId: Integer;
    begin
        NavPageActionALResponse := NavPageActionALFunctions.GetActions(PageId);

        if not NavPageActionALResponse.Success then begin
            Session.LogMessage('0000HXH', StrSubstNo(ActionsFailureTelemetryTxt, PageId), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PageActionCategoryLbl);
            ErrorMessage := NavPageActionALResponse.ErrorMessage;
            Error(ErrorMessage);
        end;

        // Get views action container
        ViewContainerActionId := GetActionIdByType(NavPageActionALResponse, PageAction."Action Type"::ActionContainer, Enum::"Action Container Type"::ViewActions.AsInteger());

        foreach NavPageActionAL in NavPageActionALResponse.PageActions do
            if (NavPageActionAL.ParentActionId = ViewContainerActionId) and (NavPageActionAL.ActionType = PageAction."Action Type"::Action) then
                // Add the actual view action
                AddViewAction(ViewsJsonArray, NavPageActionAL);
    end;

    local procedure GetActionIdByType(NavPageActionALResponse: DotNet NavPageActionALResponse; ActionType: Integer; ActionSubtype: Integer): Integer
    var
        NavPageActionAL: DotNet NavPageActionAL;
    begin
        foreach NavPageActionAL in NavPageActionALResponse.PageActions do
            if (NavPageActionAL.ActionType = ActionType) and (NavPageActionAL.ActionSubtype = ActionSubtype) then
                exit(NavPageActionAL.ActionId);
    end;

    local procedure AddViewAction(var JsonArray: JsonArray; NavPageActionAL: DotNet NavPageActionAL)
    var
        PageViewActionJsonObject: JsonObject;
        viewsUrl: Text;
    begin
        PageViewActionJsonObject.Add('caption', NavPageActionAL.Caption.ToString());
        viewsUrl := GetUrl(ClientType::Web, CompanyName, ObjectType::Page, NavPageActionAL.RunObjectId);
        viewsUrl += '&view=' + NavPageActionAL.RunObjectView;
        viewsUrl += '&filter=' + NavPageActionAL.RunObjectViewFilter; // RunObjectViewFilter is url encoded.
        PageViewActionJsonObject.Add('url', viewsUrl);
        JsonArray.Add(PageViewActionJsonObject);
    end;

    local procedure AddErrorMessage(var ResultJsonObject: JsonObject; ErrorCode: Text; ErrorMessage: Text)
    var
        ErrorJsonObject: JsonObject;
    begin
        Session.LogMessage('0000HXI', ErrorCode, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PageActionCategoryLbl);
        ErrorJsonObject.Add('code', ErrorCode);
        ErrorJsonObject.Add('message', ErrorMessage);
        ResultJsonObject.Add('error', ErrorJsonObject);
    end;

    procedure GetVersion(): Text[30]
    begin
        exit('1.0');
    end;

    var
        PageActionCategoryLbl: Label 'Page Action Provider', Locked = true;
        ActionsFailureTelemetryTxt: Label 'Failure to get actions for page %1.', Locked = true;
        FailedGetActionsCodeTok: Label 'FailedGettingPageActions', Locked = true;
        UnableToGetRoleCenterTelemetryTxt: Label 'Cannot get current role center for the user.', Locked = true;
        UnableToGetRoleCenterErrorCodeTok: Label 'UnableToGetRoleCenter', Locked = true;
        UnableToGetRoleCenterMessageTxt: Label 'Cannot get current role center for the user.';

}