// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Environment.Configuration;

codeunit 13694 "SAF-T Notification Mgt. DK"
{
    Access = Internal;

    procedure OpenSAFTSetupPage(Notification: Notification)
    begin
        Page.RunModal(Page::"SAF-T Wizard");
        DisableNotificationInternal();
    end;

    procedure DisableStandardAccount2025Notification(Notification: Notification)
    begin
        DisableNotificationInternal();
    end;

    local procedure DisableNotificationInternal()
    var
        MyNotifications: Record "My Notifications";
    begin
        if not MyNotifications.Disable(GetStandardAccount2025NotificationId()) then
            MyNotifications.InsertDefault(GetStandardAccount2025NotificationId(), StandardAccount2025NotificationNameTxt, StandardAccount2025NotificationDescriptionTxt, false);
    end;

    local procedure GetStandardAccount2025NotificationId(): Guid
    begin
        exit('a1b0c3e4-d5f6-4a7b-8c9d-0e1f2a3b4c5d');
    end;

    var
        StandardAccount2025NotificationNameTxt: Label 'SAF-T Standard Account 2025 Available';
        StandardAccount2025NotificationDescriptionTxt: Label 'Show notification when standard accounts for 2025 are available but not configured.';
}
