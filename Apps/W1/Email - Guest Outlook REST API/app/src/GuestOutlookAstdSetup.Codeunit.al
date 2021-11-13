codeunit 89002 "Guest Outlook Astd. Setup"
{
    var
        GuestOutlookConnectionSetupTxt: Label 'Set up a connection to guest outlook';
        EmailAccountSetupDescriptionTxt: Label 'Set up guest Outlook connection. After that guest users can send out invoices and other documents';
        EmailSetupShortTxt: Label 'Outgoing email';
        SetupAlreadyDoneQst: Label 'This guest Outlook integrtion setup is already done. Do you want to change configuration?';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', false, false)]
    local procedure AddGuestOutlookConnection_OnRegisterAssistedSetup();
    var
        GuidedExperience: Codeunit "Guided Experience";
        CurrentGlobalLanguage: Integer;
        EmailFeature: Codeunit "Email Feature";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        GuidedExperienceType: Enum "Guided Experience Type";
        VideoCategory: Enum "Video Category";
        Language: Codeunit Language;
    begin
        if not EmailFeature.IsEnabled() then
            exit;

        CurrentGlobalLanguage := GLOBALLANGUAGE;
        GuidedExperience.InsertAssistedSetup(GuestOutlookConnectionSetupTxt, CopyStr(EmailSetupShortTxt, 1, 50), EmailAccountSetupDescriptionTxt, 5, ObjectType::Page,
            GetPageId(), AssistedSetupGroup::Connect, '', VideoCategory::FirstInvoice, '');
        GlobalLanguage(Language.GetDefaultApplicationLanguageId());
        GuidedExperience.AddTranslationForSetupObjectTitle(GuidedExperienceType::"Assisted Setup", ObjectType::Page,
            GetPageId(), Language.GetDefaultApplicationLanguageId(), GuestOutlookConnectionSetupTxt);
        GlobalLanguage(CurrentGlobalLanguage);

        UpdateStatus();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnReRunOfCompletedAssistedSetup', '', false, false)]
    local procedure OnReRunOfCompletedSetup(ExtensionId: Guid; ObjectType: ObjectType; ObjectID: Integer; var Handled: Boolean)
    begin
        if ExtensionId <> GetAppId() then
            exit;

        if ObjectID <> GetPageId() then
            exit;

        if not GuestEmailAPIIsSetup() then
            exit;

        if Confirm(SetupAlreadyDoneQst, true) then
            Page.Run(GetPageId());

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnAfterRunAssistedSetup', '', false, false)]
    local procedure CompleteGuestEmailAssistedSetup(ExtensionID: Guid; ObjectType: ObjectType; ObjectID: Integer)
    var
        GuidedExperience: Codeunit "Guided Experience";

    begin
        if ExtensionId <> GetAppId() then
            exit;
        if ObjectID <> GetPageId() then
            exit;

        if not GuestEmailAPIIsSetup() then
            exit;

        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, GetPageId());
    end;

    procedure UpdateStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        if not GuestEmailAPIIsSetup() then
            exit;

        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, GetPageId());
    end;

    local procedure GetAppId(): Guid
    var
        EmptyGuid: Guid;
        Info: ModuleInfo;
    begin
        if Info.Id() = EmptyGuid then
            NavApp.GetCurrentModuleInfo(Info);
        exit(Info.Id());
    end;

    local procedure GetPageId(): Integer
    begin
        exit(Page::"Guest Outlook - API Setup");
    end;

    local procedure GuestEmailAPIIsSetup(): Boolean
    var
        GuestOutlookAPIHelper: Codeunit "Guest Outlook - API Helper";
    begin
        exit(GuestOutlookAPIHelper.IsAzureAppRegistrationSetup());
    end;

}
