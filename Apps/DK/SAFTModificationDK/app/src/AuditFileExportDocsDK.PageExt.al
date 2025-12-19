// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Environment.Configuration;

pageextension 13687 "Audit File Export Docs. DK" extends "Audit File Export Documents"
{
    trigger OnOpenPage()
    begin
        SendStandardAccount2025Notification();
    end;

    internal procedure SendStandardAccount2025Notification()
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
        MyNotifications: Record "My Notifications";
        StandardAccount2025Notification: Notification;
    begin
        if not AuditFileExportSetup.Get() then
            exit;

        if AuditFileExportSetup."Standard Account Type" = AuditFileExportSetup."Standard Account Type"::"Standard Account 2025" then
            exit;

        if not MyNotifications.IsEnabled(GetStandardAccount2025NotificationId()) then
            exit;

        StandardAccount2025Notification.Id(GetStandardAccount2025NotificationId());
        StandardAccount2025Notification.Message(StandardAccount2025AvailableMsg);
        StandardAccount2025Notification.AddAction(OpenSAFTSetupGuideTxt, Codeunit::"SAF-T Notification Mgt. DK", 'OpenSAFTSetupPage');
        StandardAccount2025Notification.AddAction(DontShowAgainTxt, Codeunit::"SAF-T Notification Mgt. DK", 'DisableStandardAccount2025Notification');
        StandardAccount2025Notification.Send();
    end;

    local procedure GetStandardAccount2025NotificationId(): Guid
    begin
        exit('a1b0c3e4-d5f6-4a7b-8c9d-0e1f2a3b4c5d');
    end;

    var
        StandardAccount2025AvailableMsg: Label 'New standard account type is available for year 2025.';
        OpenSAFTSetupGuideTxt: Label 'Open SAF-T Setup Guide';
        DontShowAgainTxt: Label 'Don''t show this again';
}
