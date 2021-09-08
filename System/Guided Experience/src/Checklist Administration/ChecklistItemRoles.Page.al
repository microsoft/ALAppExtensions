// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Lists the roles that a checklist item should be displayed to.
/// </summary>
page 1994 "Checklist Item Roles"
{
    Caption = 'Checklist Item Roles';
    PageType = ListPart;
    SourceTable = "Checklist Item Role";
    Editable = true;
    Permissions = tabledata "Checklist Item Role" = rimd;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Role ID"; "Role ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the role.';
                }
            }
        }
    }
}