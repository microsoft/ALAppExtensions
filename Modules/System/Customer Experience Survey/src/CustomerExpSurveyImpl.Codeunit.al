// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Feedback;

using System;
using System.Globalization;
using System.Azure.Identity;
using System.Environment;
using System.Environment.Configuration;

codeunit 9261 "Customer Exp. Survey Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        CustExpSurveyReqHelper: Codeunit "Cust. Exp. Survey Req. Impl.";
        TeamNameLbl: Label 'd365bc', Locked = true;
        EuropePPEBaseUriLbl: Label 'https://europe.tip1.ces.microsoftcloud.com/api/v1', Locked = true;
        EuropeProdBaseUriLbl: Label 'https://europe.ces.microsoftcloud.com/api/v1', Locked = true;
        WorldPPEBaseUriLbl: Label 'https://world.tip1.ces.microsoftcloud.com/api/v1', Locked = true;
        WorldProdBaseUriLbl: Label 'https://world.ces.microsoftcloud.com/api/v1', Locked = true;
        GraphUriLbl: Label 'https://graph.microsoft.com', Locked = true;
        GraphPPEUriLbl: Label 'https://graph.microsoft-ppe.com', Locked = true;
        EligibilityUriLbl: Label 'Eligibilities', Locked = true;
        EventsUriLbl: Label 'Events', Locked = true;
        SurveyUriLbl: Label 'Surveys', Locked = true;
        CustomerExperienceSurveyTok: Label 'Customer Experience Survey', Locked = true;
        CallExternalErr: Label 'Customer Survey Experience module can only be used internally.';
        JsonFormatNotRecognizedLbl: Label 'Could not retrieve information from JSON.', Locked = true;
        TenantInfoNotFoundLbl: Label 'TenantInfo not found.', Locked = true;
        CouldNotGetLanguageIdLbl: Label 'Could not retrieve language ID', Locked = true;

    internal procedure RegisterEvent(EventName: Text): Boolean
    var
        RequestUri: Text;
        ErrorMessage: Text;
        ResponseJsonObject: JsonObject;
    begin
        if not IsSaaS() then
            exit(false);

        RequestUri := GetBaseUrl() + '/' + TeamNameLbl + '/' + EventsUriLbl + '?userId=' + GetUserId() + '&eventName=' + EventName;
        if CustExpSurveyReqHelper.TryPost(RequestUri, ResponseJsonObject, ErrorMessage) then
            exit(true);
        Session.LogMessage('0000J9G', RemoveUserIdFromMessage(ErrorMessage), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CustomerExperienceSurveyTok);
    end;

    internal procedure GetEligibility(SurveyName: Text; var FormsProId: Text; var FormsProEligibilityId: Text; var IsEligible: Boolean): Boolean
    var
        RequestUri: Text;
        ErrorMessage: Text;
        ResponseJsonObject: JsonObject;
    begin
        if not IsSaaS() then
            exit(false);

        RequestUri := GetBaseUrl() + '/' + TeamNameLbl + '/' + EligibilityUriLbl + '/' + SurveyName + '?userId=' + GetUserId() + '&tenantId=' + GetTenantId();
        if not CustExpSurveyReqHelper.TryGet(RequestUri, ResponseJsonObject, ErrorMessage, false) then begin
            Session.LogMessage('0000J9H', RemoveUserIdFromMessage(ErrorMessage), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CustomerExperienceSurveyTok);
            exit(false);
        end;
        if not TryGetEligibilityFromJson(ResponseJsonObject, FormsProId, FormsProEligibilityId, IsEligible) then begin
            ErrorMessage := GetLastErrorText();
            Session.LogMessage('0000J9I', JsonFormatNotRecognizedLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CustomerExperienceSurveyTok);
            exit(false);
        end;
        exit(true);
    end;

    internal procedure RegisterEventAndGetEligibility(EventName: Text; SurveyName: Text; var FormsProId: Text; var FormsProEligibilityId: Text; var IsEligible: Boolean): Boolean
    var
        RequestUri: Text;
        ErrorMessage: Text;
        ResponseJsonObject: JsonObject;
    begin
        if not IsSaaS() then
            exit(false);

        RequestUri := GetBaseUrl() + '/' + TeamNameLbl + '/' + EligibilityUriLbl + '/' + SurveyName + '?userId=' + GetUserId() + '&eventName=' + EventName + '&tenantId=' + GetTenantId();
        if not CustExpSurveyReqHelper.TryPost(RequestUri, ResponseJsonObject, ErrorMessage) then begin
            Session.LogMessage('0000J9J', RemoveUserIdFromMessage(ErrorMessage), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CustomerExperienceSurveyTok);
            exit(false);
        end;
        if not TryGetEligibilityFromJson(ResponseJsonObject, FormsProId, FormsProEligibilityId, IsEligible) then begin
            ErrorMessage := GetLastErrorText();
            Session.LogMessage('0000J9K', JsonFormatNotRecognizedLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CustomerExperienceSurveyTok);
            exit(false);
        end;
        exit(true);
    end;

    internal procedure GetSurvey(SurveyName: Text; var CustomerExperienceSurvey: Record "Customer Experience Survey"): Boolean
    var
        RequestUri: Text;
        ErrorMessage: Text;
        ResponseJsonObject: JsonObject;
    begin
        if not IsSaaS() then
            exit(false);

        RequestUri := GetBaseUrl() + '/' + TeamNameLbl + '/' + SurveyUriLbl + '/' + SurveyName;
        if not CustExpSurveyReqHelper.TryGet(RequestUri, ResponseJsonObject, ErrorMessage, false) then begin
            Session.LogMessage('0000J9L', ErrorMessage, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CustomerExperienceSurveyTok);
            exit(false);
        end;
        if not TryFillCustomerExperienceSurveyFromJson(ResponseJsonObject, CustomerExperienceSurvey) then begin
            ErrorMessage := GetLastErrorText();
            Session.LogMessage('0000J9M', JsonFormatNotRecognizedLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CustomerExperienceSurveyTok);
            exit(false);
        end;
        exit(true);
    end;

    internal procedure AssertInternalCall(CallerModuleInfo: ModuleInfo)
    begin
        if CallerModuleInfo.Publisher <> 'Microsoft' then
            Error(CallExternalErr);
    end;

    [NonDebuggable]
    internal procedure RenderSurvey(SurveyName: Text; FormsProId: Text; FormsProEligibilityId: Text)
    var
        UserPersonalization: Record "User Personalization";
        Language: Codeunit Language;
        CustomerExperienceSurveyPage: Page "Customer Experience Survey";
        CultureInfo: DotNet CultureInfo;
        LanguageId: Integer;
        Locale: Text;
    begin
        if UserPersonalization."Language ID" = 0 then begin
            if not UserPersonalization.Get(UserSecurityId()) then
                LanguageId := Language.GetDefaultApplicationLanguageId()
            else
                if UserPersonalization."Language ID" = 0 then
                    LanguageId := Language.GetDefaultApplicationLanguageId()
                else
                    LanguageId := UserPersonalization."Language ID";
        end else
            LanguageId := UserPersonalization."Language ID";

        if LanguageId = 0 then begin
            Session.LogMessage('0000JKX', CouldNotGetLanguageIdLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CustomerExperienceSurveyTok);
            exit;
        end;

        CultureInfo := CultureInfo.CultureInfo(LanguageId);
        Locale := CultureInfo.Name();

        CustomerExperienceSurveyPage.SetSurveyProperties(FormsProId, GetTenantId(), FormsProEligibilityId, Locale);
        CustomerExperienceSurveyPage.RunModal();
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TryGetEligibilityFromJson(ResponseJsonObject: JsonObject; var FormsProId: Text; var FormsProEligibilityId: Text; var IsEligible: Boolean)
    var
        JToken: JsonToken;
    begin
        ResponseJsonObject.Get('Eligibility', JToken);
        Evaluate(IsEligible, JToken.AsValue().AsText());
        ResponseJsonObject.Get('FormsProId', JToken);
        if not JToken.AsValue().IsNull() then
            FormsProId := JToken.AsValue().AsText();
        ResponseJsonObject.Get('FormsProEligibilityId', JToken);
        if not JToken.AsValue().IsNull() then
            FormsProEligibilityId := JToken.AsValue().AsText();
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TryFillCustomerExperienceSurveyFromJson(ResponseJsonObject: JsonObject; var CustomerExperienceSurvey: Record "Customer Experience Survey")
    var
        JToken: JsonToken;
        TriggerConditionJsonObject: JsonObject;
        PromptLimitsJsonObject: JsonObject;
        TotalSamplePerPeriodJsonObject: JsonObject;
    begin
        // First level
        ResponseJsonObject.Get('SurveyName', JToken);
        CustomerExperienceSurvey.Name := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(CustomerExperienceSurvey.Name));
        ResponseJsonObject.Get('SurveyDescription', JToken);
        CustomerExperienceSurvey.Description := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(CustomerExperienceSurvey.Description));
        ResponseJsonObject.Get('SurveyCoolingTime', JToken);
        Evaluate(CustomerExperienceSurvey."Survey Cooling Time", JToken.AsValue().AsText());
        ResponseJsonObject.Get('NPSCoolingTime', JToken);
        Evaluate(CustomerExperienceSurvey."NPS Cooling Time", JToken.AsValue().AsText());
        ResponseJsonObject.Get('CESCoolingTime', JToken);
        Evaluate(CustomerExperienceSurvey."CES Cooling Time", JToken.AsValue().AsText());
        ResponseJsonObject.Get('IsEnabled', JToken);
        Evaluate(CustomerExperienceSurvey.Enabled, JToken.AsValue().AsText());
        ResponseJsonObject.Get('FormsProId', JToken);
        CustomerExperienceSurvey."Forms Pro Id" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(CustomerExperienceSurvey."Forms Pro Id"));
        // TriggerCondition level
        ResponseJsonObject.Get('TriggerCondition', JToken);
        TriggerConditionJsonObject := JToken.AsObject();
        TriggerConditionJsonObject.Get('TriggerEventName', JToken);
        CustomerExperienceSurvey."Trigger Event Name" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(CustomerExperienceSurvey."Trigger Event Name"));
        TriggerConditionJsonObject.Get('TriggerType', JToken);
        Evaluate(CustomerExperienceSurvey."Trigger Type", JToken.AsValue().AsText());
        TriggerConditionJsonObject.Get('Period', JToken);
        Evaluate(CustomerExperienceSurvey."Trigger Period", JToken.AsValue().AsText());
        // PromptLimits level
        ResponseJsonObject.Get('PromptLimits', JToken);
        PromptLimitsJsonObject := JToken.AsObject();
        PromptLimitsJsonObject.Get('Probability', JToken);
        Evaluate(CustomerExperienceSurvey."Prompt Probability", JToken.AsValue().AsText());
        PromptLimitsJsonObject.Get('TotalSample', JToken);
        Evaluate(CustomerExperienceSurvey."Prompt Total Sample", JToken.AsValue().AsText());
        // TotalSamplePerPeriod level
        PromptLimitsJsonObject.Get('TotalSamplePerPeriod', JToken);
        TotalSamplePerPeriodJsonObject := JToken.AsObject();
        TotalSamplePerPeriodJsonObject.Get('Sample', JToken);
        Evaluate(CustomerExperienceSurvey."Prompt Sample", JToken.AsValue().AsText());
        TotalSamplePerPeriodJsonObject.Get('Period', JToken);
        Evaluate(CustomerExperienceSurvey."Prompt Period", JToken.AsValue().AsText());
    end;

    local procedure GetUserId(): Text
    var
        RequestUri: Text;
        ResponseJsonObject: JsonObject;
        JToken: JsonToken;
        ErrorMessage: Text;
    begin
        RequestUri := GetGraphUrl() + '/v1.0/me/';

        if CustExpSurveyReqHelper.TryGet(RequestUri, ResponseJsonObject, ErrorMessage, true) then
            if ResponseJsonObject.Get('id', JToken) then
                exit(JToken.AsValue().AsText());

        Session.LogMessage('0000J9N', ErrorMessage, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CustomerExperienceSurveyTok);
    end;

    local procedure GetTenantId(): Text
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        IsHandled: Boolean;
        Result: Text;
    begin
        OnGetTenantId(Result, IsHandled);
        if IsHandled then
            exit(Result);

        exit(AzureADTenant.GetAadTenantId());
    end;

    local procedure GetBaseUrl(): Text
    var
        IsEurope: Boolean;
    begin
        if TryGetIsEurope(IsEurope) then
            if not IsPPE() then
                if IsEurope then
                    exit(EuropeProdBaseUriLbl)
                else
                    exit(WorldProdBaseUriLbl)
            else
                if IsEurope then
                    exit(EuropePPEBaseUriLbl)
                else
                    exit(WorldPPEBaseUriLbl);
    end;

    local procedure GetGraphUrl(): Text
    begin
        if not IsPPE() then
            exit(GraphUriLbl)
        else
            exit(GraphPPEUriLbl);
    end;

    [TryFunction]
    local procedure TryGetIsEurope(var Result: Boolean)
    var
        AzureADGraph: Codeunit "Azure AD Graph";
        TenantInfo: DotNet TenantInfo;
        IsHandled: Boolean;
    begin
        OnTryGetIsEurope(Result, IsHandled);
        if IsHandled then
            exit;

        AzureADGraph.GetTenantDetail(TenantInfo);
        if not IsNull(TenantInfo) then
            if TenantInfo.CountryLetterCode <> '' then begin
                Result := TenantInfo.CountryLetterCode in ['AT', 'BE', 'BG', 'HR', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR', 'DE', 'GR', 'HU', 'IE', 'IT', 'LV', 'LT', 'LU', 'MT', 'NL', 'PL', 'PT', 'RO', 'SK', 'SI', 'ES', 'SE'];
                exit;
            end;
        Session.LogMessage('0000J9O', TenantInfoNotFoundLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CustomerExperienceSurveyTok);
        error('');
    end;

    internal procedure RemoveUserIdFromMessage(Message: Text): Text
    var
        Index: Integer;
    begin
        Index := Message.IndexOf('?userId=');
        if Index > 0 then
            exit(Message.Substring(1, Index + 7) + Message.Substring(Index + 44))
        else
            exit(Message);
    end;

    local procedure IsSaaS(): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
        Result: Boolean;
        IsHandled: Boolean;
    begin
        OnIsSaas(Result, IsHandled);
        if IsHandled then
            exit(Result);

        exit(EnvironmentInformation.IsSaaSInfrastructure());
    end;

    internal procedure IsPPE(): Boolean
    var
        Url: Text;
        Result: Boolean;
        IsHandled: Boolean;
    begin
        OnIsPPE(Result, IsHandled);
        if IsHandled then
            exit(Result);

        Url := LowerCase(GetUrl(ClientType::Web));
        exit(
          (StrPos(Url, 'projectmadeira-test') <> 0) or (StrPos(Url, 'projectmadeira-ppe') <> 0) or
          (StrPos(Url, 'financials.dynamics-tie.com') <> 0) or (StrPos(Url, 'financials.dynamics-ppe.com') <> 0) or
          (StrPos(Url, 'invoicing.officeppe.com') <> 0) or (StrPos(Url, 'businesscentral.dynamics-tie.com') <> 0) or
          (StrPos(Url, 'businesscentral.dynamics-ppe.com') <> 0));
    end;

    [InternalEvent(false)]
    local procedure OnTryGetIsEurope(var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    local procedure OnIsSaas(var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    local procedure OnIsPPE(var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    local procedure OnGetTenantId(var Result: Text; var IsHandled: Boolean)
    begin
    end;
}