// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 2027 "Image Analyzer Ext. Mgt."
{

    var
        TooManyCallsNotificationErrorNameTxt: Label 'Image analysis usage limit already reached';
        TooManyCallsNotificationWarningNameTxt: Label 'Image analysis usage limit reached';
        TooManyCallsErrorNotificationDescriptionTxt: Label 'Notify me that the maximum number of image analyses allowed in the period is already reached.';
        TooManyCallsWarningNotificationDescriptionTxt: Label 'Notify me when I reach the maximum number of image analyses allowed in the period.';
        TooManyCallsWarningMsg: Label 'You just reached the limit of analyzed images. You can analyze %1 images per %2. You''ll have to wait until the beginning of the next %2 to analyze more images.', Comment = '%1 is the number of calls per time unit allowed, %2 is the time unit duration (year, month, day, or hour)';
        SetupNotificationMsg: Label 'If you want, we can assign attributes based on the images you import for items and contacts.';
        SetupNotificationNameTxt: Label 'Image Analyzer setup';
        SetupNotificationDescriptionTxt: Label 'Notify me that the Image Analyzer extension can suggest attributes detected in imported images.';
        ContactQuestionnairePopulatedNameTxt: Label 'Image Analyzer profile questionnaire completed';
        ContactQuestionnairePopulatedNotificationDescriptionTxt: Label 'Notify me when Image Analyzer has been used in profile questionnaire to analyze a picture of a contact.';
        AnalyzerDisabledMsg: Label 'Looks like the Image Analyzer extension is disabled. Do you want to learn more and enable it?';
        DeactivateActionTxt: Label 'Don''t ask again';
        SetupActionTxt: Label 'Enable';
        GotItTxt: Label 'Got it';
        NeverShowAgainTxt: Label 'Don''t tell me again';
        ImageAnalysisCategoryLbl: Label 'Image Analysis', Locked = true;
        ImageAnalysisEnabledLbl: Label 'Image Analysis enabled.', Locked = true;
        EnableNotificationSentLbl: Label 'Enable notification sent.', Locked = true;
        ImageAnalysisSuccesfulLbl: Label 'Image successfully analyzed.', Locked = true;
        CategoryAssignedLbl: Label 'Category was assigned.', Locked = true;
        AttributeAssignedLbl: Label 'Attribute was assigned.', Locked = true;
        OpenSetupTxt: Label 'Open setup';

    [EventSubscriber(ObjectType::Page, Page::"Item Card", 'OnAfterGetCurrRecordEvent', '', false, false)]
    local procedure OnOpenItemCard(var Rec: Record Item)
    var
        OnRecord: Option " ",Item,Contact;
    begin
        EnablePictureAnalyzerNotification(rec."No.", OnRecord::Item);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Contact Card", 'OnAfterGetCurrRecordEvent', '', false, false)]
    local procedure OnOpenContactCard(var rec: Record Contact)
    var
        OnRecord: Option " ",Item,Contact;
    begin
        if IsSaasAndCannotUseRelationshipMgmt() then
            exit;

        EnablePictureAnalyzerNotification(rec."No.", OnRecord::Contact);
    end;

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

    procedure SendEnableNotification(CodeToSet: Code[20]; OnRecord: Option " ",Item,Contact)
    var
        SetupNotification: Notification;
    begin
        SetupNotification.Id := GetEnabledNotificationId();
        SetupNotification.Message := AnalyzerDisabledMsg;

        case OnRecord of
            OnRecord::Contact:
                SetupNotification.SetData(GetContactNoForNotificationData(), Format(CodeToSet));

            OnRecord::Item:
                SetupNotification.SetData(GetItemNoForNotificationData(), Format(CodeToSet));
        end;

        SetupNotification.AddAction(SetupActionTxt, Codeunit::"Image Analyzer Ext. Mgt.", 'OpenSetupWizard');
        SetupNotification.Send();

        OnSendEnableNotification();
    end;

    local procedure EnablePictureAnalyzerNotification(CodeToSet: Code[20]; OnRecord: Option " ",Item,Contact)
    var
        SetupNotification: Notification;
    begin
        if not IsSetupNotificationEnabled() then
            exit;

        SetupNotification.Id := GetSetupNotificationId();
        SetupNotification.Message := SetupNotificationMsg;
        SetupNotification.SetData('NotificationId', GetSetupNotificationId());

        case OnRecord of
            OnRecord::Contact:
                SetupNotification.SetData(GetContactNoForNotificationData(), Format(CodeToSet));

            OnRecord::Item:
                SetupNotification.SetData(GetItemNoForNotificationData(), Format(CodeToSet));
        end;
        SetupNotification.AddAction(SetupActionTxt, Codeunit::"Image Analyzer Ext. Mgt.", 'OpenSetupWizard');
        SetupNotification.AddAction(DeactivateActionTxt, Codeunit::"Image Analyzer Ext. Mgt.", 'HandleDeactivateNotification');
        SetupNotification.Send();
    end;

    procedure OpenSetupWizard(var SetupNotification: Notification)
    var
        Item: Record Item;
        Contact: Record Contact;
        ImageAnalyzerWizard: Page "Image Analyzer Wizard";
        ItemNoCode: Code[20];
        ContactNoCode: Code[20];
    begin
        if SetupNotification.HasData(GetItemNoForNotificationData()) then begin
            ItemNoCode := CopyStr(SetupNotification.GetData(GetItemNoForNotificationData()), 1, MaxStrLen(ItemNoCode));
            if Item.get(ItemNoCode) then
                ImageAnalyzerWizard.SetItem(item);
        end;

        if SetupNotification.HasData(GetContactNoForNotificationData()) then begin
            ContactNoCode := CopyStr(SetupNotification.GetData(GetContactNoForNotificationData()), 1, MaxStrLen(ContactNoCode));
            if Contact.get(ContactNoCode) then
                ImageAnalyzerWizard.SetContact(Contact);
        end;

        ImageAnalyzerWizard.RunModal();
    end;

    procedure HandleSetupAndEnable()
    var
        ImageAnalyzerSetup: Record "Image Analysis Setup";
    begin
        ImageAnalyzerSetup.GetSingleInstance();
        ImageAnalyzerSetup."Image-Based Attribute Recognition Enabled" := true;
        ImageAnalyzerSetup.Modify(true);
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
