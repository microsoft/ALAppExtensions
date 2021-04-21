// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Lists the entries in the Retention Policy Log.
/// </summary>
page 3904 "Retention Policy Log Entries"
{
    Caption = 'Retention Policy Log Entries';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Retention Policy Log Entry";
    Extensible = false;
    Editable = false;
    SourceTableView = order(descending);
    Permissions = tabledata "Retention Policy Log Entry" = r;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number that is assigned to the entry.';
                }
                field("Date/time"; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time the entry was created.';
                }
                field("Session Id"; Rec."Session Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the session in which the entry was created.';
                }
                field(Message; Rec.Message)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the content of the message in the log entry.';
                }
                field("Message Type"; Rec."Message Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the message is informational, a warning, or an error.';
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the aspect of the retention policy that created the log entry. This indicates where a user was working in Business Central, or what they were doing, when the entry was created. For example, this can be setup, retention period, and when the policy was applied.';
                }
                field("User Id"; Rec."User Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the user who ran the process that created the log entry.';
                }
            }
        }
    }
}