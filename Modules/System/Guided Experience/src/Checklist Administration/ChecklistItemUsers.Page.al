// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Lists the users that a checklist item should be displayed to.
/// </summary>
page 1995 "Checklist Item Users"
{
    Caption = 'Checklist Users';
    PageType = ListPart;
    SourceTable = "Checklist Item User";
    Editable = true;
    Permissions = tabledata "Checklist Item User" = rimd;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("User Name"; "User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user.';
                    Caption = 'User ID';
                    Visible = true;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        ChecklistItemUser: Record "Checklist Item User";
    begin
        if ChecklistItemUser.Get(Code, "User ID") then begin
            ChecklistItemUser."Assigned to User" := true;
            ChecklistItemUser.Modify();
            exit(false);
        end else
            ChecklistItemUser."Assigned to User" := true;
    end;
}