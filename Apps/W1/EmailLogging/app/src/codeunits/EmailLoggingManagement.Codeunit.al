codeunit 1681 "Email Logging Management"
{
    Access = Internal;
    Permissions = tabledata "Email Logging Setup" = rimd;

    var
        EmailLoggingUsingGraphApiFeatureIdTok: Label 'EmailLoggingUsingGraphApi', Locked = true;
        EmailLoggingSetupHelpTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2115467', Locked = true;
        CategoryTok: Label 'Email Logging', Locked = true;
        ActivityLogRelatedRecordCodeTxt: Label 'EMLLOGGING', Locked = true;
        ActivityLogContextTxt: Label 'Email Logging', Locked = true;
        NoPermissionsTxt: Label 'No permissions.';
        NoPermissionsForJobTxt: Label 'No permissions to schedule the email logging task.', Locked = true;
        NoPermissionsForJobErr: Label 'Your license does not allow you to schedule the email logging task or register interaction log entries. To view details about your permissions, see the Effective Permissions page.';
        EmailLoggingSetupTitleTxt: Label 'Set up the Email Logging Using the Microsoft Graph API feature.';
        EmailLoggingSetupShortTitleTxt: Label 'Set up email logging', MaxLength = 50;
        FeatureDisabledTxt: Label 'The Email Logging Using the Microsoft Graph API feature is not enabled.', Locked = true;
        FeatureDisabledErr: Label 'The Email Logging Using the Microsoft Graph API feature is not enabled.';
        EmailLoggingDisabledTxt: Label 'The Email Logging Using the Microsoft Graph API feature is not enabled.', Locked = true;
        EmailLoggingDisabledErr: Label 'The Email Logging Using the Microsoft Graph API feature is not enabled.';
        EmptyEmailAddressTxt: Label 'Email address is empty.', Locked = true;
        EmptyEmailAddressErr: Label 'Email address is empty.';
        ZeroEmailBatchSizeTxt: Label 'Email batch size is not specified.', Locked = true;
        ZeroEmailBatchSizeErr: Label 'You must specify a size for the email batch.';
        EmailLoggingSetupDescriptionTxt: Label 'Track email exchanges between your sales team and your customers and prospects, and then turn the emails into actionable opportunities.';
        InteractionTemplateSetupEmailNotSetTxt: Label 'Field E-mails on Interaction Template Setup is not set.', Locked = true;
        InteractionTemplateSetupNotFoundForEmailTxt: Label 'Interaction Template Setup is not found for email.', Locked = true;
        InteractionTemplateSetupEmailFoundTxt: Label 'Interaction Template Setup is found for email.', Locked = true;
        IgnoredClientCredentialsTxt: Label 'Ignored client credentials.', Locked = true;
        InvalidClientCredentialsTxt: Label 'Invalid client credentials.', Locked = true;
        EmptyRedirectUrlTxt: Label 'Redirect URL is empty, the default URL will be used.', Locked = true;
        EmailLoggingJobDescriptionTxt: Label 'Log email interactions between salespeople and contacts.';
        ClearEmailLoggingSetupTxt: Label 'Clear email logging setup.', Locked = true;
        CreateEmailLoggingJobTxt: Label 'Create email logging job.', Locked = true;
        DeleteEmailLoggingJobTxt: Label 'Delete email logging job.', Locked = true;
        RestartEmailLoggingJobTxt: Label 'Restart email logging job.', Locked = true;
        EmptyAccessTokenTxt: Label 'Access token is empty.', Locked = true;
        TenantIdExtractedTxt: Label 'Tenant ID has been extracted from token.', Locked = true;
        CannotExtractTenantIdTxt: Label 'Cannot extract the tenant ID from the access token.', Locked = true;
        CannotExtractTenantIdErr: Label 'Cannot extract the tenant ID from the access token.';

    internal procedure IsEmailLoggingUsingGraphApiFeatureEnabled() FeatureEnabled: Boolean;
    var
        FeatureManagementFacade: Codeunit "Feature Management Facade";
    begin
        FeatureEnabled := FeatureManagementFacade.IsEnabled(GetEmailLoggingUsingGraphApiFeatureKey());
        OnIsEmailLoggingUsingGraphApiFeatureEnabled(FeatureEnabled);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsEmailLoggingUsingGraphApiFeatureEnabled(var FeatureEnabled: Boolean)
    begin
    end;

    local procedure GetEmailLoggingUsingGraphApiFeatureKey(): Text[50]
    begin
        exit(EmailLoggingUsingGraphApiFeatureIdTok);
    end;

    internal procedure IsEmailLoggingEnabled(): Boolean
    var
        EmailLoggingSetup: Record "Email Logging Setup";
    begin
        if not IsEmailLoggingUsingGraphApiFeatureEnabled() then
            exit(false);

        if not EmailLoggingSetup.Get() then
            exit(false);

        if not EmailLoggingSetup.Enabled then
            exit(false);

        exit(true);
    end;

    internal procedure CheckEmailLoggingEnabled()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
    begin
        if not IsEmailLoggingUsingGraphApiFeatureEnabled() then
            exit;

        if IsEmailLoggingEnabled() then
            exit;

        if GuiAllowed() then begin
            RegisterAssistedSetup();
            GuidedExperience.Run(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"Email Logging Setup Wizard");
        end;
    end;

    internal procedure CheckEmailLoggingSetup()
    var
        EmailLoggingSetup: Record "Email Logging Setup";
    begin
        if not IsEmailLoggingUsingGraphApiFeatureEnabled() then
            Error(FeatureDisabledErr);

        if not EmailLoggingSetup.ReadPermission() then
            Error(NoPermissionsTxt);

        EmailLoggingSetup.Get();

        if not EmailLoggingSetup.Enabled then begin
            Session.LogMessage('0000FZP', EmailLoggingDisabledTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(EmailLoggingDisabledErr);
        end;

        if EmailLoggingSetup."Email Address" = '' then begin
            Session.LogMessage('0000FZQ', EmptyEmailAddressTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(EmptyEmailAddressErr);
        end;

        if EmailLoggingSetup."Email Batch Size" = 0 then begin
            Session.LogMessage('0000G23', ZeroEmailBatchSizeTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(ZeroEmailBatchSizeErr);
        end;

        CheckInteractionTemplateSetup();
    end;

    internal procedure CheckFeatureEnabled()
    begin
        if IsEmailLoggingUsingGraphApiFeatureEnabled() then
            exit;

        Session.LogMessage('0000FZR', FeatureDisabledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        Error(FeatureDisabledErr);
    end;

    internal procedure CheckInteractionTemplateSetup(): Boolean
    var
        InteractionTemplateSetup: Record "Interaction Template Setup";
        InteractionTemplate: Record "Interaction Template";
    begin
        // Emails cannot be automatically logged unless the field Emails on Interaction Template Setup is set.
        InteractionTemplateSetup.Get();
        if InteractionTemplateSetup."E-Mails" = '' then begin
            Session.LogMessage('0000FZS', InteractionTemplateSetupEmailNotSetTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        // Since we have no guarantees that the Interaction Template for Emails exists, we check for it here.
        InteractionTemplate.SetFilter(Code, '=%1', InteractionTemplateSetup."E-Mails");
        if InteractionTemplate.IsEmpty() then begin
            Session.LogMessage('0000FZT', InteractionTemplateSetupNotFoundForEmailTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        Session.LogMessage('0000FZU', InteractionTemplateSetupEmailFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        exit(true);
    end;

    internal procedure RegisterAssistedSetup(): Boolean
    var
        GuidedExperience: Codeunit "Guided Experience";
        Language: Codeunit Language;
        ModuleInfo: ModuleInfo;
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        GuidedExperienceType: Enum "Guided Experience Type";
        CurrentGlobalLanguage: Integer;
        NeedCommit: Boolean;
    begin
        if not IsEmailLoggingUsingGraphApiFeatureEnabled() then
            exit(false);

        if GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"Setup Email Logging") then begin
            GuidedExperience.Remove(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"Setup Email Logging");
            NeedCommit := true;
        end;

        if GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"Email Logging Setup Wizard") then begin
            if NeedCommit then
                Commit();
            exit(false);
        end;

        CurrentGlobalLanguage := GlobalLanguage;
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        GuidedExperience.InsertAssistedSetup(EmailLoggingSetupTitleTxt, EmailLoggingSetupShortTitleTxt, EmailLoggingSetupDescriptionTxt, 10, ObjectType::Page,
            Page::"Email Logging Setup Wizard", AssistedSetupGroup::ApprovalWorkflows, '', VideoCategory::Connect, EmailLoggingSetupHelpTxt);
        GlobalLanguage(Language.GetDefaultApplicationLanguageId());
        GuidedExperience.AddTranslationForSetupObjectTitle(GuidedExperienceType::"Assisted Setup", ObjectType::Page,
            Page::"Email Logging Setup Wizard", Language.GetDefaultApplicationLanguageId(), EmailLoggingSetupTitleTxt);
        GlobalLanguage(CurrentGlobalLanguage);
        Commit();
        exit(true);
    end;

    internal procedure ClearEmailLoggingSetup(var EmailLoggingSetup: Record "Email Logging Setup")
    var
        IsolatedStorageManagement: Codeunit "Isolated Storage Management";
    begin
        Session.LogMessage('0000FZV', ClearEmailLoggingSetupTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        Clear(EmailLoggingSetup."Email Address");
        EmailLoggingSetup."Email Batch Size" := EmailLoggingSetup.GetDefaultEmailBatchSize();
        Clear(EmailLoggingSetup."Client Id");
        Clear(EmailLoggingSetup."Redirect URL");
        Clear(EmailLoggingSetup.Enabled);
        Clear(EmailLoggingSetup."Consent Given");

        if not IsNullGuid(EmailLoggingSetup."Client Secret Key") then
            IsolatedStorageManagement.Delete(EmailLoggingSetup."Client Secret Key", DATASCOPE::Company);
        Clear(EmailLoggingSetup."Client Secret Key");

        EmailLoggingSetup.Modify();
    end;

    internal procedure CreateEmailLoggingJobQueueSetup()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        Session.LogMessage('0000FZW', CreateEmailLoggingJobTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Email Logging Job Runner");
        JobQueueEntry.DeleteTasks();
        JobQueueEntry.InitRecurringJob(10);
        JobQueueEntry."Earliest Start Date/Time" := CreateDateTime(Today, Time + 60000);
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"Email Logging Job Runner";
        JobQueueEntry."Maximum No. of Attempts to Run" := 3;
        JobQueueEntry.Description := CopyStr(EmailLoggingJobDescriptionTxt, 1, MaxStrLen(JobQueueEntry.Description));
        Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);
    end;

    internal procedure DeleteEmailLoggingJobQueueSetup()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        Session.LogMessage('0000FZX', DeleteEmailLoggingJobTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Email Logging Job Runner");
        JobQueueEntry.DeleteTasks();
    end;

    internal procedure UpdateEmailLoggingJobQueueSetup()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        Session.LogMessage('0000G8D', RestartEmailLoggingJobTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Email Logging Job Runner");
        if JobQueueEntry.FindSet() then
            repeat
                if JobQueueEntry."User ID" <> UserId() then begin
                    JobQueueEntry."User ID" := CopyStr(UserId(), 1, MaxStrLen(JobQueueEntry."User ID"));
                    JobQueueEntry.Restart();
                end;
            until JobQueueEntry.Next() = 0
        else
            CreateEmailLoggingJobQueueSetup();
    end;

    [NonDebuggable]
    internal procedure PromptClientCredentials(var ClientId: Text[250]; var ClientSecret: Text[250]; var RedirectURL: Text[2048]): Boolean
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        OAuth2: Codeunit OAuth2;
        DefaultRedirectURL: Text;
    begin
        TempNameValueBuffer.ID := 1;
        TempNameValueBuffer.Name := ClientId;
        TempNameValueBuffer.Value := ClientSecret;
        if RedirectURL = '' then begin
            OAuth2.GetDefaultRedirectUrl(DefaultRedirectURL);
            TempNameValueBuffer."Value Long" := CopyStr(DefaultRedirectURL, 1, MaxStrLen(TempNameValueBuffer."Value Long"));
        end else
            TempNameValueBuffer."Value Long" := RedirectURL;
        TempNameValueBuffer.Insert();
        Commit();
        if Page.RunModal(Page::"Exchange Client Credentials", TempNameValueBuffer) <> Action::LookupOK then begin
            Session.LogMessage('0000FZY', IgnoredClientCredentialsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;
        if (TempNameValueBuffer.Name = '') or (TempNameValueBuffer.Value = '') then begin
            Session.LogMessage('0000FZZ', InvalidClientCredentialsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;
        if TempNameValueBuffer."Value Long" = '' then
            Session.LogMessage('0000G00', EmptyRedirectUrlTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        ClientId := TempNameValueBuffer.Name;
        ClientSecret := TempNameValueBuffer.Value;
        RedirectURL := TempNameValueBuffer."Value Long";
        exit(true);
    end;

    [NonDebuggable]
    internal procedure ExtractTenantIdFromAccessToken(AccessToken: Text) TenantId: Text
    begin
        if AccessToken <> '' then begin
            if TryExtractTenantIdFromAccessToken(TenantId, AccessToken) then begin
                if TenantId <> '' then begin
                    Session.LogMessage('0000G01', TenantIdExtractedTxt, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                    exit;
                end;
                Session.LogMessage('0000G02', CannotExtractTenantIdTxt, Verbosity::Error, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            end else
                Session.LogMessage('0000G03', CannotExtractTenantIdTxt, Verbosity::Error, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
        end else
            Session.LogMessage('0000G04', EmptyAccessTokenTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        Error(CannotExtractTenantIdErr);
    end;

    [TryFunction]
    [NonDebuggable]
    internal procedure TryExtractTenantIdFromAccessToken(var TenantId: Text; AccessToken: Text)
    var
        JwtSecurityTokenHandler: DotNet JwtSecurityTokenHandler;
        JwtSecurityToken: DotNet JwtSecurityToken;
    begin
        JwtSecurityTokenHandler := JwtSecurityTokenHandler.JwtSecurityTokenHandler();
        JwtSecurityToken := JwtSecurityTokenHandler.ReadToken(AccessToken);
        JwtSecurityToken.Payload().TryGetValue('tid', TenantId);
    end;

    internal procedure InitializeAPIClient(var APIClient: interface "Email Logging API Client")
    var
        DefaultEmailLoggingAPIClient: Codeunit "Email Logging API Client";
    begin
        APIClient := DefaultEmailLoggingAPIClient;
        OnAfterInitializeAPIClient(APIClient);
    end;

    internal procedure InitializeOAuthClient(var OAuthClient: interface "Email Logging OAuth Client")
    var
        DefaultEmailLoggingOAuthClient: Codeunit "Email Logging OAuth Client";
    begin
        OAuthClient := DefaultEmailLoggingOAuthClient;
        OnAfterInitializeOAuthClient(OAuthClient);
    end;

    internal procedure LogActivityFailed(ActivityDescription: Text; ActivityMessage: Text)
    var
        ActivityLog: Record "Activity Log";
        RecordId: RecordId;
    begin
        GetActivityLogRelatedRecordId(RecordId);
        ActivityLog.LogActivity(RecordId, ActivityLog.Status::Failed,
            ActivityLogContextTxt, ActivityDescription, ActivityMessage);
        Commit();
    end;

    internal procedure GetActivityLogRelatedRecordId(var RecordId: RecordId)
    var
        TempMarketingSetup: Record "Marketing Setup" temporary;
    begin
        // Use a fake RecordId for Activity Log because cannot use RecordId for Email Logging Setup
        // as it is not available in Activity Log due to indirect permissions
        TempMarketingSetup."Primary Key" := ActivityLogRelatedRecordCodeTxt;
        RecordId := TempMarketingSetup.RecordId();
    end;

    local procedure IsEmailLoggingJob(var JobQueueEntry: Record "Job Queue Entry"): Boolean
    begin
        if JobQueueEntry."Object Type to Run" <> JobQueueEntry."Object Type to Run"::Codeunit then
            exit(false);
        if JobQueueEntry."Object ID to Run" <> Codeunit::"Email Logging Job Runner" then
            exit(false);
        exit(true);
    end;

    local procedure CanScheduleJob(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueLogEntry: Record "Job Queue Log Entry";
        ErrorMessageRegister: Record "Error Message Register";
        ErrorMessage: Record "Error Message";
        EmailLoggingSetup: Record "Email Logging Setup";
        InteractionLogEntry: Record "Interaction Log Entry";
        InterLogEntryCommentLine: Record "Inter. Log Entry Comment Line";
        Attachment: Record Attachment;
        ActivityLog: Record "Activity Log";
    begin
        if not EmailLoggingSetup.ReadPermission() then
            exit(false);
        if not (JobQueueEntry.WritePermission() and JobQueueEntry.ReadPermission()) then
            exit(false);
        if not JobQueueLogEntry.WritePermission() then
            exit(false);
        if not ErrorMessageRegister.WritePermission() then
            exit(false);
        if not ErrorMessage.WritePermission() then
            exit(false);
        if not TASKSCHEDULER.CanCreateTask() then
            exit(false);
        if not InteractionLogEntry.WritePermission() then
            exit(false);
        if not InterLogEntryCommentLine.WritePermission() then
            exit(false);
        if not Attachment.WritePermission() then
            exit(false);
        if not ActivityLog.WritePermission() then
            exit(false);
        exit(true);
    end;

    [InternalEvent(false)]
    local procedure OnAfterInitializeAPIClient(var EmailLoggngAPIClient: interface "Email Logging API Client")
    begin
    end;

    [InternalEvent(false)]
    local procedure OnAfterInitializeOAuthClient(var EmailLoggingOAuthClient: interface "Email Logging OAuth Client")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', false, false)]
    local procedure HandleOnRegisterAssistedSetup()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if not ApplicationAreaMgmtFacade.IsBasicOnlyEnabled() then
            RegisterAssistedSetup();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnBeforeSetStatusValue', '', false, false)]
    local procedure HandleOnBeforeSetStatusValue(var JobQueueEntry: Record "Job Queue Entry"; var xJobQueueEntry: Record "Job Queue Entry"; var NewStatus: Option)
    begin
        if NewStatus <> JobQueueEntry.Status::Ready then
            exit;
        if not IsEmailLoggingJob(JobQueueEntry) then
            exit;
        if not CanScheduleJob() then begin
            Session.LogMessage('0000GDE', NoPermissionsForJobTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(NoPermissionsForJobErr);
        end;
    end;
}