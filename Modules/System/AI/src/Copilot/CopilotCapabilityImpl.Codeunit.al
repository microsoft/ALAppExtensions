// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.AI;

using System.Globalization;
using System.Telemetry;
using System.Security.User;
using System.Azure.Identity;
using System.Privacy;

codeunit 7774 "Copilot Capability Impl"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Copilot Settings" = rimd;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        CopilotCategoryLbl: Label 'Copilot', Locked = true;
        AzureOpenAiTxt: Label 'Azure OpenAI', Locked = true;
        AlreadyRegisteredErr: Label 'Capability has already been registered.';
        NotRegisteredErr: Label 'Copilot capability has not been registered by the module.';
        ReviewPrivacyNoticeLbl: Label 'Review the privacy notice';
        PrivacyNoticeDisagreedNotificationMessageLbl: Label 'To enable Copilot, please review and accept the privacy notice.';
        CapabilitiesNotAvailableOnPremNotificationMessageLbl: Label 'Note that copilot and AI capabilities published by Microsoft are not available on-premises.';
        TelemetryRegisteredNewCopilotCapabilityLbl: Label 'New copilot capability has been registered.', Locked = true;
        TelemetryModifiedCopilotCapabilityLbl: Label 'Copilot capability has been modified.', Locked = true;
        TelemetryUnregisteredCopilotCapabilityLbl: Label 'Copilot capability has been unregistered.', Locked = true;
        TelemetryActivatedCopilotCapabilityLbl: Label 'Copilot capability activated.', Locked = true;
        TelemetryDeactivatedCopilotCapabilityLbl: Label 'Copilot capability deactivated.', Locked = true;

    procedure RegisterCapability(CopilotCapability: Enum "Copilot Capability"; LearnMoreUrl: Text[2048]; CallerModuleInfo: ModuleInfo)
    var
    begin
        RegisterCapability(CopilotCapability, Enum::"Copilot Availability"::Preview, LearnMoreUrl, CallerModuleInfo);
    end;

    procedure RegisterCapability(CopilotCapability: Enum "Copilot Capability"; CopilotAvailability: Enum "Copilot Availability"; LearnMoreUrl: Text[2048]; CallerModuleInfo: ModuleInfo)
    var
        CopilotSettings: Record "Copilot Settings";
        CustomDimensions: Dictionary of [Text, Text];
    begin
        if IsCapabilityRegistered(CopilotCapability, CallerModuleInfo) then
            Error(AlreadyRegisteredErr);

        CopilotSettings.Init();
        CopilotSettings.Capability := CopilotCapability;
        CopilotSettings."App Id" := CallerModuleInfo.Id();
        CopilotSettings.Publisher := CopyStr(CallerModuleInfo.Publisher, 1, MaxStrLen(CopilotSettings.Publisher));
        CopilotSettings."Availability" := CopilotAvailability;
        CopilotSettings."Learn More Url" := LearnMoreUrl;
        CopilotSettings.Status := Enum::"Copilot Status"::Active;
        CopilotSettings.Insert();
        Commit();

        AddTelemetryDimensions(CopilotCapability, CallerModuleInfo.Id(), CustomDimensions);
        FeatureTelemetry.LogUsage('0000LDV', CopilotCategoryLbl, TelemetryRegisteredNewCopilotCapabilityLbl, CustomDimensions);
    end;

    procedure ModifyCapability(CopilotCapability: Enum "Copilot Capability"; CopilotAvailability: Enum "Copilot Availability"; LearnMoreUrl: Text[2048]; CallerModuleInfo: ModuleInfo)
    var
        CopilotSettings: Record "Copilot Settings";
        CustomDimensions: Dictionary of [Text, Text];
    begin
        if not IsCapabilityRegistered(CopilotCapability, CallerModuleInfo) then
            Error(NotRegisteredErr);

        CopilotSettings.ReadIsolation(IsolationLevel::ReadCommitted);
        CopilotSettings.Get(CopilotCapability, CallerModuleInfo.Id());

        if CopilotSettings."Availability" <> CopilotAvailability then
            CopilotSettings.Status := Enum::"Copilot Status"::Active;

        CopilotSettings."Availability" := CopilotAvailability;
        CopilotSettings."Learn More Url" := LearnMoreUrl;
        CopilotSettings.Modify(true);
        Commit();

        AddTelemetryDimensions(CopilotCapability, CallerModuleInfo.Id(), CustomDimensions);
        FeatureTelemetry.LogUsage('0000LDW', CopilotCategoryLbl, TelemetryModifiedCopilotCapabilityLbl, CustomDimensions);
    end;

    procedure UnregisterCapability(CopilotCapability: Enum "Copilot Capability"; var CallerModuleInfo: ModuleInfo)
    var
        CopilotSettings: Record "Copilot Settings";
        CustomDimensions: Dictionary of [Text, Text];
    begin
        if not IsCapabilityRegistered(CopilotCapability, CallerModuleInfo) then
            Error(NotRegisteredErr);

        CopilotSettings.ReadIsolation(IsolationLevel::ReadCommitted);
        CopilotSettings.LockTable();
        CopilotSettings.Get(CopilotCapability, CallerModuleInfo.Id());
        CopilotSettings.Delete();
        Commit();

        AddTelemetryDimensions(CopilotCapability, CallerModuleInfo.Id(), CustomDimensions);
        FeatureTelemetry.LogUsage('0000LDX', CopilotCategoryLbl, TelemetryUnregisteredCopilotCapabilityLbl, CustomDimensions);
    end;

    procedure IsCapabilityRegistered(CopilotCapability: Enum "Copilot Capability"; CallerModuleInfo: ModuleInfo): Boolean
    begin
        exit(IsCapabilityRegistered(CopilotCapability, CallerModuleInfo.Id()));
    end;

    procedure IsCapabilityRegistered(CopilotCapability: Enum "Copilot Capability"; AppId: Guid): Boolean
    var
        CopilotSettings: Record "Copilot Settings";
    begin
        CopilotSettings.ReadIsolation(IsolationLevel::ReadCommitted);
        CopilotSettings.SetRange("Capability", CopilotCapability);
        CopilotSettings.SetRange("App Id", AppId);
        exit(not CopilotSettings.IsEmpty());
    end;

    procedure IsCapabilityActive(CopilotCapability: Enum "Copilot Capability"; CallerModuleInfo: ModuleInfo): Boolean
    begin
        exit(IsCapabilityActive(CopilotCapability, CallerModuleInfo.Id()));
    end;

    procedure IsCapabilityActive(CopilotCapability: Enum "Copilot Capability"; AppId: Guid): Boolean
    var
        CopilotSettings: Record "Copilot Settings";
    begin
        CopilotSettings.ReadIsolation(IsolationLevel::ReadCommitted);
        CopilotSettings.SetLoadFields("Status");
        if not CopilotSettings.Get(CopilotCapability, AppId) then
            exit(false);

        exit(CopilotSettings.Status = Enum::"Copilot Status"::Active);
    end;

    procedure SendActivateTelemetry(CopilotCapability: Enum "Copilot Capability"; AppId: Guid)
    var
        CustomDimensions: Dictionary of [Text, Text];
    begin
        AddTelemetryDimensions(CopilotCapability, AppId, CustomDimensions);
        FeatureTelemetry.LogUsage('0000LDY', CopilotCategoryLbl, TelemetryActivatedCopilotCapabilityLbl, CustomDimensions);
    end;

    procedure SendDeactivateTelemetry(CopilotCapability: Enum "Copilot Capability"; AppId: Guid; Reason: Option)
    var
        Language: Codeunit Language;
        SavedGlobalLanguageId: Integer;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        AddTelemetryDimensions(CopilotCapability, AppId, CustomDimensions);

        SavedGlobalLanguageId := GlobalLanguage();
        GlobalLanguage(Language.GetDefaultApplicationLanguageId());

        CustomDimensions.Add('Reason', Format(Reason));
        FeatureTelemetry.LogUsage('0000LDZ', CopilotCategoryLbl, TelemetryDeactivatedCopilotCapabilityLbl, CustomDimensions);

        GlobalLanguage(SavedGlobalLanguageId);
    end;

    procedure ShowPrivacyNoticeDisagreedNotification()
    var
        Notification: Notification;
    begin
        Notification.Id(CreateGuid());
        Notification.Message(PrivacyNoticeDisagreedNotificationMessageLbl);
        Notification.AddAction(ReviewPrivacyNoticeLbl, Codeunit::"Copilot Capability Impl", 'OpenPrivacyNotice');
        Notification.Send();
    end;

    procedure ShowCapabilitiesNotAvailableOnPremNotification()
    var
        Notification: Notification;
    begin
        Notification.Id(CreateGuid());
        Notification.Message(CapabilitiesNotAvailableOnPremNotificationMessageLbl);
        Notification.Send();
    end;

    procedure OpenPrivacyNotice(Notification: Notification)
    begin
        Page.Run(Page::"Privacy Notices");
    end;

    procedure GetAzureOpenAICategory(): Code[50]
    begin
        exit(AzureOpenAiTxt);
    end;

    procedure GetCopilotCategory(): Code[50]
    begin
        exit(CopilotCategoryLbl);
    end;

    procedure AddTelemetryDimensions(CopilotCapability: Enum "Copilot Capability"; AppId: Guid; var CustomDimensions: Dictionary of [Text, Text])
    var
        Language: Codeunit Language;
        SavedGlobalLanguageId: Integer;
    begin
        SavedGlobalLanguageId := GlobalLanguage();
        GlobalLanguage(Language.GetDefaultApplicationLanguageId());

        CustomDimensions.Add('Capability', Format(CopilotCapability));
        CustomDimensions.Add('AppId', Format(AppId));

        GlobalLanguage(SavedGlobalLanguageId);
    end;

    procedure IsAdmin() IsAdmin: Boolean
    var
        AzureADGraphUser: Codeunit "Azure AD Graph User";
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
        UserPermissions: Codeunit "User Permissions";
    begin
        IsAdmin := AzureADGraphUser.IsUserDelegatedAdmin() or AzureADPlan.IsPlanAssignedToUser(PlanIds.GetGlobalAdminPlanId()) or AzureADPlan.IsPlanAssignedToUser(PlanIds.GetD365AdminPlanId()) or AzureADGraphUser.IsUserDelegatedHelpdesk() or UserPermissions.IsSuper(UserSecurityId());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Privacy Notice", 'OnRegisterPrivacyNotices', '', false, false)]
    local procedure CreatePrivacyNoticeRegistrations(var TempPrivacyNotice: Record "Privacy Notice" temporary)
    begin
        TempPrivacyNotice.Init();
        TempPrivacyNotice.ID := AzureOpenAiTxt;
        TempPrivacyNotice."Integration Service Name" := AzureOpenAiTxt;
        if not TempPrivacyNotice.Insert() then;
    end;
}