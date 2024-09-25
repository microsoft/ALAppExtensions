namespace Microsoft.Utility.ImageAnalysis;

using System.AI;
using System.Environment.Configuration;
using System.Environment;
using Microsoft.Utilities;
using System.Security.User;
using System.Globalization;
using System.Media;
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 2027 "Image Analyzer Ext. Mgt."
{
    Permissions = tabledata "Image Analysis Scenario" = RIMD;

    var
        TooManyCallsNotificationErrorNameTxt: Label 'Image analysis usage limit already reached';
        TooManyCallsNotificationWarningNameTxt: Label 'Image analysis usage limit reached';
        TooManyCallsErrorNotificationDescriptionTxt: Label 'Notify me that the maximum number of image analyses allowed in the period is already reached.';
        TooManyCallsWarningNotificationDescriptionTxt: Label 'Notify me when I reach the maximum number of image analyses allowed in the period.';
        TooManyCallsWarningMsg: Label 'You just reached the limit of analyzed images. You can analyze %1 images per %2. You''ll have to wait until the beginning of the next %2 to analyze more images.', Comment = '%1 is the number of calls per time unit allowed, %2 is the time unit duration (year, month, day, or hour)';
        SetupNotificationNameTxt: Label 'Image Analyzer setup';
        SetupNotificationDescriptionTxt: Label 'Notify me that the Image Analyzer extension can suggest attributes detected in imported images.';
        ContactQuestionnairePopulatedNameTxt: Label 'Image Analyzer profile questionnaire completed';
        ContactQuestionnairePopulatedNotificationDescriptionTxt: Label 'Notify me when Image Analyzer has been used in profile questionnaire to analyze a picture of a contact.';
        GotItTxt: Label 'Got it';
        NeverShowAgainTxt: Label 'Don''t tell me again';
        ImageAnalysisCategoryLbl: Label 'Image Analysis', Locked = true;
        ImageAnalysisEnabledLbl: Label 'Image Analysis enabled.', Locked = true;
        EnableNotificationSentLbl: Label 'Enable notification sent.', Locked = true;
        ImageAnalysisSuccesfulLbl: Label 'Image successfully analyzed.', Locked = true;
        CategoryAssignedLbl: Label 'Category was assigned.', Locked = true;
        AttributeAssignedLbl: Label 'Attribute was assigned.', Locked = true;
        OpenSetupTxt: Label 'Open setup';
        ImageAnalysisWizardTitleTxt: Label 'Set up the Image Analyzer';
        ImageAnalysisWizardShortTitleTxt: Label 'Image Analyzer';
        ImageAnalysisWizardDescriptionTxt: Label 'The Image Analyzer extension uses powerful image analytics to detect attributes in the images that you add to items and contact persons, so you can easily review and assign them. Set it up now.';


    procedure IsSaasAndCannotUseRelationshipMgmt(): Boolean
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        EnvironmentInfo: Codeunit "Environment Information";
        CanUseRelationshipMgmt: Boolean;
    begin
        CanUseRelationshipMgmt := ApplicationAreaMgmtFacade.IsRelationshipMgmtEnabled() or ApplicationAreaMgmtFacade.IsAdvancedEnabled() or ApplicationAreaMgmtFacade.IsAllDisabled();
        exit(EnvironmentInfo.IsSaaS() and not CanUseRelationshipMgmt);
    end;

    [EventSubscriber(ObjectType::Page, Page::"My Notifications", 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure OnInitializingNotificationWithDefaultStateRegisterNotifs()
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.InsertDefault(
            GetSetupNotificationId(),
            SetupNotificationNameTxt,
            SetupNotificationDescriptionTxt,
            true);

        MyNotifications.InsertDefault(
            GetTooManyCallsErrorNotificationId(),
            TooManyCallsNotificationErrorNameTxt,
            TooManyCallsErrorNotificationDescriptionTxt,
            true);

        MyNotifications.InsertDefault(
            GetTooManyCallsWarningNotificationId(),
            TooManyCallsNotificationWarningNameTxt,
            TooManyCallsWarningNotificationDescriptionTxt,
            true);

        MyNotifications.InsertDefault(
            GetContactQuestionnairePopulatedNotificationId(),
            ContactQuestionnairePopulatedNameTxt,
            ContactQuestionnairePopulatedNotificationDescriptionTxt,
            true);
    end;

    procedure AnalyzePicture(MediaID: GUID; var ImageAnalysisResult: Codeunit "Image Analysis Result"; AnalysisType: Option Tags,Faces): Boolean
    var
        ImageAnalysisSetup: Record "Image Analysis Setup";
        ImageAnalysisManagement: Codeunit "Image Analysis Management";
        ErrorMessage: Text;
        LimitType: Option Year,Month,Day,Hour;
        LimitValue: Integer;
        IsUsageLimitError: Boolean;
        AnalysisSuccessful: Boolean;
    begin
        if not ImageAnalysisSetup.Get() then
            exit;

        if not ImageAnalysisSetup."Image-Based Attribute Recognition Enabled" then
            exit;

        ImageAnalysisManagement.Initialize();
        ImageAnalysisManagement.SetMedia(MediaId);

        case AnalysisType of
            AnalysisType::Tags:
                AnalysisSuccessful := ImageAnalysisManagement.AnalyzeTags(ImageAnalysisResult);

            AnalysisType::Faces:
                AnalysisSuccessful := ImageAnalysisManagement.AnalyzeFaces(ImageAnalysisResult);
        end;

        if not AnalysisSuccessful then begin
            if ImageAnalysisManagement.GetLastError(ErrorMessage, IsUsageLimitError) then
                if IsUsageLimitError then
                    SendInformationNotification(ErrorMessage, GetTooManyCallsErrorNotificationId())
                else
                    SendNotificationError(ErrorMessage);
            exit(false);
        end;

        ImageAnalysisManagement.GetLimitParams(LimitType, LimitValue);
        if ImageAnalysisSetup.IsUsageLimitReached(ErrorMessage, LimitValue, LimitType) then
            SendInformationNotification(StrSubstNo(TooManyCallsWarningMsg, LimitValue, Format(LimitType)), GetTooManyCallsErrorNotificationId());

        OnSuccessfullyAnalyseImage();
        exit(true);
    end;

    procedure HandleDeactivateNotification(var Notification: Notification)
    var
        MyNotifications: Record "My Notifications";
        MyNotificationsPage: Page "My Notifications";
        NotificationId: Guid;
    begin
        Evaluate(NotificationId, Notification.GetData('NotificationId'));

        MyNotificationsPage.InitializeNotificationsWithDefaultState();
        if MyNotifications.Get(UserId(), NotificationId) then begin
            MyNotifications.Enabled := false;
            MyNotifications.Modify(true);
        end;
    end;

    procedure IsInformationNotificationEnabled(NotificationId: Guid): Boolean;
    var
        MyNotifications: Record "My Notifications";
    begin
        exit(MyNotifications.IsEnabled(NotificationId));
    end;

    procedure SendInformationNotification(Message: Text; NotificationId: Guid)
    var
        Notification: Notification;
    begin
        if not IsInformationNotificationEnabled(NotificationId) then
            exit;
        Notification.Id := NotificationId;
        Notification.Message := Message;
        Notification.SetData('NotificationId', NotificationId);
        Notification.AddAction(GotItTxt, Codeunit::"Image Analyzer Ext. Mgt.", 'DoNothing');
        Notification.AddAction(NeverShowAgainTxt, Codeunit::"Image Analyzer Ext. Mgt.", 'HandleDeactivateNotification');
        Notification.Send();
    end;

    local procedure SendNotificationError(Message: Text)
    var
        ImageAnalysisManagement: Codeunit "Image Analysis Management";
        Notification: Notification;
    begin
        Notification.Id := GetAnyErrorNotificationId();
        Notification.Message := Message;
        if Message <> ImageAnalysisManagement.GetNoImageErr() then
            Notification.AddAction(OpenSetupTxt, Codeunit::"Image Analyzer Ext. Mgt.", 'OpenSetup');
        Notification.Send();
    end;

    procedure HandleSetupAndEnable()
    var
        ImageAnalyzerSetup: Record "Image Analysis Setup";
        ImageAnalysisScenario: Record "Image Analysis Scenario";
    begin
        ImageAnalyzerSetup.GetSingleInstance();
        ImageAnalyzerSetup."Image-Based Attribute Recognition Enabled" := true;
        ImageAnalyzerSetup.Modify(true);

        if ImageAnalysisScenario.WritePermission() then
            ImageAnalysisScenario.EnableAllKnownAllCompanies();

        OnEnableImageAnalysis();
    end;

    procedure IsSetupNotificationEnabled(): Boolean
    var
        MyNotifications: Record "My Notifications";
        ImageAnalyzerSetup: Record "Image Analysis Setup";
        UserPermissions: Codeunit "User Permissions";
    begin
        if not UserPermissions.IsSuper(UserSecurityId()) then
            exit(false);

        if not MyNotifications.IsEnabled(GetSetupNotificationId()) then
            exit(false);

        ImageAnalyzerSetup.GetSingleInstance();
        if ImageAnalyzerSetup."Image-Based Attribute Recognition Enabled" then
            exit(false);

        exit(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Connection", 'OnRegisterServiceConnection', '', false, false)]
    local procedure OnRegisterServiceConnection(var ServiceConnection: Record "Service Connection")
    var
        ImageAnalysisSetup: Record "Image Analysis Setup";
        ImageAnalysisSetupPage: Page "Image Analysis Setup";
    begin
        ImageAnalysisSetup.GetSingleInstance();
        if ImageAnalysisSetup."Image-Based Attribute Recognition Enabled" then
            ServiceConnection.Status := ServiceConnection.Status::Enabled;
        ServiceConnection.InsertServiceConnection(
        ServiceConnection,
        ImageAnalysisSetup.RecordId(),
        ImageAnalysisSetupPage.Caption(),
        ImageAnalysisSetup."Api Uri",
        Page::"Image Analysis Setup");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', true, true)]
    local procedure InsertIntoAssistedSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
        Language: Codeunit Language;
        CurrentGlobalLanguage: Integer;
    begin
        GuidedExperience.InsertAssistedSetup(ImageAnalysisWizardTitleTxt, CopyStr(ImageAnalysisWizardShortTitleTxt, 1, 50), ImageAnalysisWizardDescriptionTxt, 2, ObjectType::Page, Page::"Image Analyzer Wizard", "Assisted Setup Group"::DoMoreWithBC,
                                            '', "Video Category"::DoMoreWithBC, '', true);

        CurrentGlobalLanguage := GlobalLanguage();
        GlobalLanguage(Language.GetDefaultApplicationLanguageId());
        GuidedExperience.AddTranslationForSetupObjectTitle("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"Image Analyzer Wizard", Language.GetDefaultApplicationLanguageId(), ImageAnalysisWizardTitleTxt);
        GuidedExperience.AddTranslationForSetupObjectDescription("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"Image Analyzer Wizard", Language.GetDefaultApplicationLanguageId(), ImageAnalysisWizardDescriptionTxt);
        GlobalLanguage(CurrentGlobalLanguage);
    end;

    procedure DoNothing(Notification: Notification)
    begin
    end;

    procedure OpenSetup(Notification: Notification)
    var
        ImageAnalysisSetup: Page "Image Analysis Setup";
    begin
        ImageAnalysisSetup.RunModal();
    end;

    local procedure GetTooManyCallsErrorNotificationId(): Guid
    begin
        exit('e6fd1a12-6d79-4aec-bfff-404e0f0b21a7');
    end;

    local procedure GetContactNoForNotificationData(): Text
    begin
        exit('contactno');
    end;

    local procedure GetItemNoForNotificationData(): Text
    begin
        exit('itemno');
    end;


    local procedure GetEnabledNotificationId(): Guid
    begin
        exit('e54eb2c9-ebc2-4934-91d9-97af900e89b1');
    end;

    procedure GetSetupNotificationId(): Guid
    begin
        exit('e54eb2c9-ebc2-4934-91d9-97af900e89b2');
    end;

    local procedure GetTooManyCallsWarningNotificationId(): Guid
    begin
        exit('e54eb2c9-ebc2-4934-91d9-97af900e89b3');
    end;

    procedure GetContactQuestionnairePopulatedNotificationId(): Guid
    begin
        exit('e54eb2c9-ebc2-4934-91d9-97af900e89b4');
    end;

    local procedure GetAnyErrorNotificationId(): Guid
    begin
        exit('e54eb2c9-ebc2-4934-91d9-97af900e89b5');
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSendEnableNotification()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSuccessfullyAnalyseImage()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnEnableImageAnalysis()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Image Analyzer Ext. Mgt.", 'OnEnableImageAnalysis', '', false, false)]
    local procedure OnEnableImageAnalysisSubscriber()
    begin
        Session.LogMessage('00001K6', ImageAnalysisEnabledLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', ImageAnalysisCategoryLbl);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Image Analyzer Ext. Mgt.", 'OnSendEnableNotification', '', false, false)]
    local procedure OnSendEnableNotificationSubscriber()
    begin
        Session.LogMessage('00001K7', EnableNotificationSentLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', ImageAnalysisCategoryLbl);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Image Analyzer Ext. Mgt.", 'OnSuccessfullyAnalyseImage', '', false, false)]
    local procedure OnSuccessfullyAnalyseImageSubscriber()
    begin
        Session.LogMessage('00001K8', ImageAnalysisSuccesfulLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', ImageAnalysisCategoryLbl);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Image Analysis Tags", 'OnAssignCategory', '', false, false)]
    local procedure OnAssignCategorySubscriber()
    begin
        Session.LogMessage('00001K9', CategoryAssignedLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', ImageAnalysisCategoryLbl);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Image Analysis Tags", 'OnAssignAttribute', '', false, false)]
    local procedure OnAssignAttributeSubscriber()
    begin
        Session.LogMessage('00001KA', AttributeAssignedLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', ImageAnalysisCategoryLbl);
    end;
}
