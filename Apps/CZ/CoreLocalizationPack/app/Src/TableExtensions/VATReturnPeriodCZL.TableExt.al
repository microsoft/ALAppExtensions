// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Environment.Configuration;
using Microsoft.Utilities;

tableextension 31066 "VAT Return Period CZL" extends "VAT Return Period"
{
    var
        DueDateForVATReportNameTxt: Label 'Due date for VAT report';
        DueDateForVATReportDescriptionTxt: Label 'Warn if VAT report is due.';

    procedure CheckVATReportDueDateCZL()
    var
        NotificationMessage: Text;
    begin
        NotificationMessage := CheckOpenOrOverdue();
        if NotificationMessage <> '' then
            ShowDueDateForVATReportNotification(NotificationMessage)
        else
            RecallDueDateForVATReportNotification();
    end;

    internal procedure SetDueDateForVATReportNotificationDefaultState()
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.InsertDefault(GetDueDateForVATReportNotificationId(),
          DueDateForVATReportNameTxt, DueDateForVATReportDescriptionTxt, true);
    end;

    internal procedure GetDueDateForVATReportNotificationId(): Guid
    begin
        exit('4f73ed48-6429-4a55-bd7a-4bad7530cf67');
    end;

    local procedure ShowDueDateForVATReportNotification(NotificationMessage: Text)
    var
        MyNotifications: Record "My Notifications";
        InstructionMgt: Codeunit "Instruction Mgt.";
        DueDateForVATReportNotification: Notification;
    begin
        if not MyNotifications.IsEnabled(GetDueDateForVATReportNotificationId()) then
            exit;
        InstructionMgt.CreateMissingMyNotificationsWithDefaultState(GetDueDateForVATReportNotificationId());

        DueDateForVATReportNotification.Id := GetDueDateForVATReportNotificationId();
        DueDateForVATReportNotification.Message := NotificationMessage;
        DueDateForVATReportNotification.Scope := NotificationScope::LocalScope;
        DueDateForVATReportNotification.Send();
    end;

    local procedure RecallDueDateForVATReportNotification()
    var
        MyNotifications: Record "My Notifications";
        DueDateForVATReportNotification: Notification;
    begin
        if not MyNotifications.IsEnabled(GetDueDateForVATReportNotificationId()) then
            exit;

        DueDateForVATReportNotification.Id := GetDueDateForVATReportNotificationId();
        DueDateForVATReportNotification.Recall();
    end;
}