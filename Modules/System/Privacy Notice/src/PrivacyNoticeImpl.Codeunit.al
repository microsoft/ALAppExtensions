// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1565 "Privacy Notice Impl."
{
    Access = Internal;
    Permissions = tabledata "Privacy Notice" = im;

    var
        EmptyGuid: Guid;
        MicrosoftPrivacyLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=521839';
        AdminDisabledIntegrationMsg: Label 'Your admin has disabled the integration with %1, please contact your administrator to approve this integration.', Comment = '%1 = a service name such as Microsoft Teams';
        MissingLinkErr: Label 'No privacy notice link was specified';
        PrivacyNoticeDoesNotExistErr: Label 'The privacy notice %1 does not exist.', Comment = '%1 = the identifier of a privacy notice';
        TelemetryCategoryTxt: Label 'Privacy Notice', Locked = true;
        CreatePrivacyNoticeTelemetryTxt: Label 'Creating privacy notice', Locked = true;
        ConfirmPrivacyNoticeTelemetryTxt: Label 'Confirming privacy notice', Locked = true;
        PrivacyNoticeAutoApprovedByAdminTelemetryTxt: Label 'The privacy notice was auto-approved by the admin', Locked = true;
        PrivacyNoticeAutoRejectedByAdminTelemetryTxt: Label 'The privacy notice was auto-rejected by the admin', Locked = true;
        PrivacyNoticeAutoApprovedByUserTelemetryTxt: Label 'The privacy notice was auto-approved by the user', Locked = true;
        ShowingPrivacyNoticeTelemetryTxt: Label 'Showing privacy notice', Locked = true;
        PrivacyNoticeApprovalResultTelemetryTxt: Label 'Approval State after showing privacy notice: %1', Locked = true;
        CheckPrivacyNoticeApprovalStateTelemetryTxt: Label 'Checking privacy approval state', Locked = true;
        AdminPrivacyApprovalStateTelemetryTxt: Label 'Admin privacy approval state: %1', Locked = true;
        UserPrivacyApprovalStateTelemetryTxt: Label 'User privacy approval state: %1', Locked = true;
        RegisteringPrivacyNoticesFailedTelemetryErr: Label 'Privacy notices could not be registered', Locked = true;
        PrivacyNoticeNotCreatedTelemetryErr: Label 'A privacy notice could not be created', Locked = true;
        PrivacyNoticeDoesNotExistTelemetryErr: Label 'The Privacy Notice does not exist.', Locked = true;
        SystemEventPrivacyNoticeNotCreatedTelemetryErr: Label 'System event privacy notice could be created.', Locked = true;

    trigger OnRun()
    begin
        CreateDefaultPrivacyNotices();
    end;

    procedure CreatePrivacyNotice(Id: Code[50]; IntegrationName: Text[250]; Link: Text[2048]): Boolean
    var
        PrivacyNotice: Record "Privacy Notice";
    begin
        exit(CreatePrivacyNotice(PrivacyNotice, Id, IntegrationName, Link));
    end;

    procedure CreatePrivacyNotice(Id: Code[50]; IntegrationName: Text[250]): Boolean
    begin
        exit(CreatePrivacyNotice(Id, IntegrationName, MicrosoftPrivacyLinkTxt));
    end;

    procedure ConfirmPrivacyNoticeApproval(PrivacyNoticeId: Code[50]): Boolean
    var
        PrivacyNotice: Record "Privacy Notice";
    begin
        Session.LogMessage('0000GK8', ConfirmPrivacyNoticeTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);

        PrivacyNotice.SetAutoCalcFields(Enabled, Disabled);
        PrivacyNotice.SetRange("User SID Filter", EmptyGuid);

        // If the Privacy Notice does not exist then re-initialize all Privacy Notices
        if not PrivacyNotice.Get(PrivacyNoticeId) then begin
            CreateDefaultPrivacyNoticesInSeparateThread();
            if not PrivacyNotice.Get(PrivacyNoticeId) then
                Error(PrivacyNoticeDoesNotExistErr, PrivacyNoticeId);
        end;

        // First check if admin has made decision on this privacy notice and return that
        if PrivacyNotice.Enabled then begin
            Session.LogMessage('0000GK9', PrivacyNoticeAutoApprovedByAdminTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);
            exit(true);
        end;
        if PrivacyNotice.Disabled then begin
            Session.LogMessage('0000GKA', PrivacyNoticeAutoRejectedByAdminTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);
            if CanCurrentUserApproveForOrganization() then
                exit(ShowPrivacyNotice(PrivacyNotice)); // User is admin so show the privacy notice again for them to re-approve
            Message(AdminDisabledIntegrationMsg, PrivacyNotice."Integration Service Name");
            exit(false);
        end;

        // If admin did not make a decision, check if user made a decision and if so, return that
        PrivacyNotice.SetRange("User SID Filter", UserSecurityId());
        PrivacyNotice.CalcFields(Enabled, Disabled);
        if PrivacyNotice.Enabled then begin
            Session.LogMessage('0000GKB', PrivacyNoticeAutoApprovedByUserTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);
            exit(true); // If user clicked no, they will still be notified until admin makes a decision
        end;

        // Show privacy notice and store user decision
        // if the user is admin then show an approval message for everyone
        // if the user is not admin then show an approval message for this specific user
        exit(ShowPrivacyNotice(PrivacyNotice));
    end;

    procedure CheckPrivacyNoticeApprovalState(PrivacyNoticeId: Code[50]): Enum "Privacy Notice Approval State"
    var
        PrivacyNotice: Record "Privacy Notice";
    begin
        Session.LogMessage('0000GKC', CheckPrivacyNoticeApprovalStateTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);

        PrivacyNotice.SetAutoCalcFields(Enabled, Disabled);
        PrivacyNotice.SetRange("User SID Filter", EmptyGuid);

        // If the Privacy Notice does not exist then re-initialize all Privacy Notices
        if not PrivacyNotice.Get(PrivacyNoticeId) then begin
            Session.LogMessage('0000GN7', PrivacyNoticeDoesNotExistTelemetryErr, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);
            exit("Privacy Notice Approval State"::"Not set"); // If there are no Privacy Notice then it is by default "Not set".
        end;

        // First check if admin has made decision on this privacy notice and return that
        if PrivacyNotice.Enabled then begin
            Session.LogMessage('0000GKD', StrSubstNo(AdminPrivacyApprovalStateTelemetryTxt, "Privacy Notice Approval State"::Agreed), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);
            exit("Privacy Notice Approval State"::Agreed);
        end;
        if PrivacyNotice.Disabled then begin
            Session.LogMessage('0000GKE', StrSubstNo(AdminPrivacyApprovalStateTelemetryTxt, "Privacy Notice Approval State"::Disagreed), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);
            exit("Privacy Notice Approval State"::Disagreed);
        end;

        // If admin did not make a decision, check if user made a decision and if so, return that
        PrivacyNotice.SetRange("User SID Filter", UserSecurityId());
        PrivacyNotice.CalcFields(Enabled);
        if PrivacyNotice.Enabled then begin
            Session.LogMessage('0000GKF', StrSubstNo(UserPrivacyApprovalStateTelemetryTxt, "Privacy Notice Approval State"::Agreed), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);
            exit("Privacy Notice Approval State"::Agreed); // If user clicked no, they will still be notified until admin makes a decision
        end;
        Session.LogMessage('0000GKG', StrSubstNo(UserPrivacyApprovalStateTelemetryTxt, "Privacy Notice Approval State"::"Not set"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);
        exit("Privacy Notice Approval State"::"Not set");
    end;

    procedure CanCurrentUserApproveForOrganization(): Boolean
    var
        PrivacyNoticeApproval: Record "Privacy Notice Approval";
    begin
        exit(PrivacyNoticeApproval.WritePermission());
    end;

    procedure SetApprovalState(PrivacyNoticeId: Code[50]; PrivacyNoticeApprovalState: Enum "Privacy Notice Approval State")
    var
        PrivacyNoticeApproval: Codeunit "Privacy Notice Approval";
    begin
        CreateDefaultPrivacyNotices(); // Ensure all default Privacy Notices are created
        if CanCurrentUserApproveForOrganization() then
            PrivacyNoticeApproval.SetApprovalState(PrivacyNoticeId, EmptyGuid, PrivacyNoticeApprovalState)
        else
            if PrivacyNoticeApprovalState <> "Privacy Notice Approval State"::Disagreed then // We do not store rejected user approvals
                PrivacyNoticeApproval.SetApprovalState(PrivacyNoticeId, UserSecurityId(), PrivacyNoticeApprovalState);
    end;

    procedure ShowOneTimePrivacyNotice(IntegrationName: Text[250]): Enum "Privacy Notice Approval State"
    begin
        exit(ShowOneTimePrivacyNotice(IntegrationName, MicrosoftPrivacyLinkTxt));
    end;

    procedure ShowOneTimePrivacyNotice(IntegrationName: Text[250]; Link: Text[2048]): Enum "Privacy Notice Approval State"
    var
        TempPrivacyNotice: Record "Privacy Notice" temporary;
        PrivacyNoticePage: Page "Privacy Notice";
    begin
        CreatePrivacyNotice(TempPrivacyNotice, '', IntegrationName, Link);

        PrivacyNoticePage.SetRecord(TempPrivacyNotice);
        PrivacyNoticePage.RunModal();
        PrivacyNoticePage.GetRecord(TempPrivacyNotice);
        exit(PrivacyNoticePage.GetUserApprovalState());
    end;

    procedure CreateDefaultPrivacyNoticesInSeparateThread()
    begin
        if Codeunit.Run(Codeunit::"Privacy Notice Impl.") then;
    end;

    procedure CreateDefaultPrivacyNotices()
    var
        TempPrivacyNotice: Record "Privacy Notice" temporary;
        PrivacyNotice: Record "Privacy Notice";
    begin
        if not TryGetAllPrivacyNotices(TempPrivacyNotice) then begin
            Session.LogMessage('0000GME', RegisteringPrivacyNoticesFailedTelemetryErr, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);
            exit;
        end;

        TempPrivacyNotice.Reset();
        if TempPrivacyNotice.FindSet() then
            repeat
                PrivacyNotice.SetRange(ID, TempPrivacyNotice.ID);
                if PrivacyNotice.IsEmpty() then begin
                    PrivacyNotice := TempPrivacyNotice;
                    if PrivacyNotice.Link = '' then
                        PrivacyNotice.Link := MicrosoftPrivacyLinkTxt;
                    if not PrivacyNotice.Insert() then
                        Session.LogMessage('0000GMF', PrivacyNoticeNotCreatedTelemetryErr, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);
                end;
            until TempPrivacyNotice.Next() = 0;
    end;

    [TryFunction]
    local procedure TryGetAllPrivacyNotices(var PrivacyNotice: Record "Privacy Notice" temporary)
    var
        PrivacyNoticeInterface: Codeunit "Privacy Notice";
    begin
        PrivacyNoticeInterface.OnRegisterPrivacyNotices(PrivacyNotice);
    end;

    local procedure CreatePrivacyNotice(var PrivacyNotice: Record "Privacy Notice"; Id: Code[50]; IntegrationName: Text[250]; Link: Text[2048]): Boolean
    begin
        Session.LogMessage('0000GK7', CreatePrivacyNoticeTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);

        if Link = '' then
            Error(MissingLinkErr);

        PrivacyNotice.Id := Id;
        PrivacyNotice."Integration Service Name" := IntegrationName;
        PrivacyNotice.Link := Link;
        exit(PrivacyNotice.Insert());
    end;

    local procedure ShowPrivacyNotice(PrivacyNotice: Record "Privacy Notice"): Boolean
    var
        PrivacyNoticeCodeunit: Codeunit "Privacy Notice";
        PrivacyNoticePage: Page "Privacy Notice";
        Handled: Boolean;
    begin
        Session.LogMessage('0000GKH', ShowingPrivacyNoticeTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);
        // Allow overriding of the privacy notice
        PrivacyNoticeCodeunit.OnBeforeShowPrivacyNotice(PrivacyNotice, Handled);
        if Handled then begin
            PrivacyNotice.CalcFields(Enabled); // Refresh the enabled field from the database
            exit(PrivacyNotice.Enabled); // The user either accepted, rejected or cancelled the privacy notice. No matter the case we only return true if the privacy notice was accepted.
        end;

        PrivacyNoticePage.SetRecord(PrivacyNotice);
        PrivacyNoticePage.RunModal();
        PrivacyNoticePage.GetRecord(PrivacyNotice);
        Session.LogMessage('0000GKI', StrSubstNo(PrivacyNoticeApprovalResultTelemetryTxt, PrivacyNoticePage.GetUserApprovalState()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);
        exit(PrivacyNoticePage.GetUserApprovalState() = "Privacy Notice Approval State"::Agreed); // The user either accepted, rejected or cancelled the privacy notice. No matter the case we only return true if the privacy notice was accepted.
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", 'ConfirmPrivacyNoticeApproval', '', false, false)]
    local procedure ConfirmSystemPrivacyNoticeApproval(PrivacyNoticeIntegrationName: Text; var IsApproved: Boolean)
    var
        PrivacyNotice: Record "Privacy Notice";
        PrivacyNoticeId: Code[50];
        PrivacyNoticeName: Text[250];
    begin
        if IsApproved then
            exit;

        PrivacyNoticeId := CopyStr(PrivacyNoticeIntegrationName, 1, 50);
        PrivacyNoticeName := CopyStr(PrivacyNoticeIntegrationName, 1, 250);
        PrivacyNotice.SetRange(ID, PrivacyNoticeId);
        if not PrivacyNotice.IsEmpty() then begin
            IsApproved := ConfirmPrivacyNoticeApproval(PrivacyNoticeId);
            exit;
        end;
        
        CreateDefaultPrivacyNoticesInSeparateThread(); // First attempt creating the system privacy notice by creating default privacy notices
        if not PrivacyNotice.IsEmpty() then begin
            IsApproved := ConfirmPrivacyNoticeApproval(PrivacyNoticeId);
            exit;
        end;

        if CreatePrivacyNotice(PrivacyNoticeId, PrivacyNoticeName) then begin // Manually create the privacy notice.
            Commit(); // Below may show a privacy notice, so make sure we are not in a write transaction.
            IsApproved := ConfirmPrivacyNoticeApproval(PrivacyNoticeId);
            exit;
        end;

        Session.LogMessage('0000GP9', SystemEventPrivacyNoticeNotCreatedTelemetryErr, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);
        IsApproved := false;
    end;
}
