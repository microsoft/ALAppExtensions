// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Sales.Reminder;

codeunit 13665 "OIOUBL-Reminder Issue Sub"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reminder-Issue", 'OnBeforeIssueReminder', '', false, false)]
    procedure OnBeforeIssueReminderRunCheck(var ReminderHeader: Record "Reminder Header");
    var
        OIOXMLCheckReminder: Codeunit "OIOUBL-Check Reminder";
    begin
        OIOXMLCheckReminder.RUN(ReminderHeader);
    end;
}
