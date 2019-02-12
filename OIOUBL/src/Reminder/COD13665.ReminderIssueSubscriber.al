// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13665 "OIOUBL-Reminder Issue Sub"
{
    [EventSubscriber(ObjectType::Codeunit, 393, 'OnBeforeIssueReminder', '', false, false)]
    procedure OnBeforeIssueReminderRunCheck(var ReminderHeader: Record "Reminder Header");
    var
        OIOXMLCheckReminder: Codeunit "OIOUBL-Check Reminder";
    begin
        OIOXMLCheckReminder.RUN(ReminderHeader);
    end;
}