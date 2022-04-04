// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This codeunit provides an interface for creating, showing and approving Privacy Notices
/// </summary>
codeunit 1563 "Privacy Notice"
{
    Access = Public;

    /// <summary>
    /// Creates a privacy notice.
    /// </summary>
    /// <param name="Id">Identification of the privacy notice.</param>
    /// <param name="IntegrationName">The name of the integration.</param>
    /// <param name="Link">Link to the privacy terms.</param>
    /// <returns>Whether the privacy notice was created.</returns>
    procedure CreatePrivacyNotice(Id: Code[50]; IntegrationName: Text[250]; Link: Text[2048]): Boolean
    var
        PrivacyNoticeImpl: Codeunit "Privacy Notice Impl.";
    begin
        exit(PrivacyNoticeImpl.CreatePrivacyNotice(Id, IntegrationName, Link));
    end;
    
    /// <summary>
    /// Creates a privacy notice.
    /// </summary>
    /// <param name="Id">Identification of the privacy notice.</param>
    /// <param name="IntegrationName">The name of the integration.</param>
    /// <param name="Link">Link to the privacy terms.</param>
    /// <returns>Whether the privacy notice was created.</returns>
    procedure CreatePrivacyNotice(Id: Code[50]; IntegrationName: Text[250]): Boolean
    var
        PrivacyNoticeImpl: Codeunit "Privacy Notice Impl.";
    begin
        exit(PrivacyNoticeImpl.CreatePrivacyNotice(Id, IntegrationName));
    end;
    
    /// <summary>
    /// After this the step-through depends on whether the user is admin or normal user (admin means they have the Priv. Notice - Admin permission set):
    /// Admin:
    ///     If admin has agreed that will be returned
    ///     Privacy Notice will be shown and the response (Agree/Disagree) will be stored and takes precedence for all users.
    ///     If the Privacy Notice was simply closed, we return false and nothing is stored.
    /// User:
    ///     If admin has agreed or disagreed, that will be returned
    ///     If user has agreed, that will be returned
    ///     Privacy Notice will be shown and any agreement will be stored.
    ///     If the Privacy Notice was simply closed, we return false and nothing is stored.
    /// 
    /// <remark>This function will open a modal dialog to confirm approval and must hence be run outside a write transaction.</remark>
    /// <remark>The privacy notice referenced must exist.</remark>
    /// </summary>
    /// <param name="Id">Identification of an existing privacy notice.</param>
    /// <returns>Whether the privacy notice was agreed to.</returns>
    procedure ConfirmPrivacyNoticeApproval(Id: Code[50]): Boolean
    var
        PrivacyNoticeImpl: Codeunit "Privacy Notice Impl.";
    begin
        exit(PrivacyNoticeImpl.ConfirmPrivacyNoticeApproval(Id));
    end;

    /// <summary>
    /// Returns the state of the privacy notice for the current user without showing any privacy notice to the user.
    /// 
    /// An error is thrown if the privacy notice does not exist.
    /// </summary>
    /// <param name="Id">Identification of an existing privacy notice.</param>
    /// <returns>The state of the privacy notice for the current user.</returns>
    procedure GetPrivacyNoticeApprovalState(Id: Code[50]): Enum "Privacy Notice Approval State"
    var
        PrivacyNoticeImpl: Codeunit "Privacy Notice Impl.";
    begin
        exit(PrivacyNoticeImpl.CheckPrivacyNoticeApprovalState(Id));
    end;

    /// <summary>
    /// Shows a Privacy Notice for the specified integration name.
    /// This call does not require any Privacy Notice to exist, nor will it create one or store the content.
    /// This function is purely to show a privacy notice and let the caller handle the consent flow.
    /// </summary>
    /// <param name="IntegrationName">The name of the integration.</param>
    /// <returns>The state of the privacy notice for the current user.</returns>
    procedure ShowOneTimePrivacyNotice(IntegrationName: Text[250]): Enum "Privacy Notice Approval State"
    var
        PrivacyNoticeImpl: Codeunit "Privacy Notice Impl.";
    begin
        exit(PrivacyNoticeImpl.ShowOneTimePrivacyNotice(IntegrationName));
    end;

    /// <summary>
    /// Shows a Privacy Notice for the specified integration name.
    /// This call does not require any Privacy Notice to exist, nor will it create one or store the content.
    /// This function is purely to show a privacy notice and let the caller handle the consent flow.
    /// </summary>
    /// <param name="IntegrationName">The name of the integration.</param>
    /// <returns>The state of the privacy notice for the current user.</returns>
    procedure ShowOneTimePrivacyNotice(IntegrationName: Text[250]; Link: Text[2048]): Enum "Privacy Notice Approval State"
    var
        PrivacyNoticeImpl: Codeunit "Privacy Notice Impl.";
    begin
        exit(PrivacyNoticeImpl.ShowOneTimePrivacyNotice(IntegrationName, Link));
    end;

    /// <summary>
    /// Determines whether the admin or user has disagreed with the Privacy Notice.
    /// </summary>
    /// <param name="Id">Identification of an existing privacy notice.</param>
    /// <returns>Whether the Privacy Notice was disagreed to.</returns>
    procedure IsApprovalStateDisagreed(Id: Code[50]): Boolean
    var
        PrivacyNoticeImpl: Codeunit "Privacy Notice Impl.";
    begin
        exit(PrivacyNoticeImpl.CheckPrivacyNoticeApprovalState(Id) = "Privacy Notice Approval State"::Disagreed);
    end;

    /// <summary>
    /// Sets the approval state for the specified Privacy Notice.
    /// If the user is an admin, the approval will be set for the entire organization otherwise it will only be set for the current user.
    /// </summary>
    /// <param name="PrivacyNoticeId">Id of the privacy notice.</param>
    /// <param name="Approved">Whether the privacy notice is approved.</param>
    procedure SetApprovalState(PrivacyNoticeId: Code[50]; PrivacyNoticeApprovalState: Enum "Privacy Notice Approval State")
    var
        PrivacyNoticeImpl: Codeunit "Privacy Notice Impl.";
    begin
        PrivacyNoticeImpl.SetApprovalState(PrivacyNoticeId, PrivacyNoticeApprovalState);
    end;

    /// <summary>
    /// Checks whether the current user can approve for the entire organization.
    /// This function basically returns whether the user has the permissions of the Priv. Notice - Admin.
    /// </summary>
    /// <returns>Whether the current user can approve for the entire organization.</returns>
    procedure CanCurrentUserApproveForOrganization() : Boolean
    var
        PrivacyNoticeImpl: Codeunit "Privacy Notice Impl.";
    begin
        exit(PrivacyNoticeImpl.CanCurrentUserApproveForOrganization());
    end;

    /// <summary>
    /// Adds all Privacy Notices from extensions using the event OnAddPrivacyNotices.
    /// </summary>
    procedure CreateDefaultPrivacyNotices()
    var
        PrivacyNoticeImpl: Codeunit "Privacy Notice Impl.";
    begin
        PrivacyNoticeImpl.CreateDefaultPrivacyNotices();
    end;

    /// <summary>
    /// This event is called when we are confirming approval to the privacy notice but no decision has been made. Just before calling any UI to show a dialog to the user.
    /// This allows overriding of individual privacy notices in case of custom wizards.
    /// </summary>
    /// <param name="PrivacyNotice">The privacy notice to be shown.</param>
    /// <param name="Handled">Specifies whether the event has been handled and no further execution should occur.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeShowPrivacyNotice(PrivacyNotice: Record "Privacy Notice"; var Handled: Boolean)
    begin
    end;

    /// <summary>
    /// This event is called when we are adding all Privacy Notices to the list.
    /// This will happen during demotool, upgrade and using the action on the Privacy Notices list.
    /// If a Privacy Notice with the same Id already exist, the entry is ignored.
    /// </summary>
    /// <param name="PrivacyNotice">The privacy notice to be shown.</param>
    /// <param name="Handled">Specifies whether the event has been handled and no further execution should occur.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnRegisterPrivacyNotices(var TempPrivacyNotice: Record "Privacy Notice" temporary)
    begin
    end;
}
