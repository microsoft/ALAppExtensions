// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// ListPart page that contains the plans assigned to users.
/// </summary>
page 9826 "User Plans FactBox"
{
    Caption = 'User Plans';
    Editable = false;
    LinksAllowed = false;
    PageType = ListPart;
    ShowFilter = false;
    SourceTable = "User Plan";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; "Plan Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the plan.';
                    Caption = 'Name';
                }
            }
        }
    }

    actions
    {
    }
}

