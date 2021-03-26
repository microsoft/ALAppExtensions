// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// ListPart page that contains all the user plan members.
/// </summary>
page 9823 "User Plan Members FactBox"
{
    Caption = 'Users in Plan';
    Editable = false;
    PageType = ListPart;
    SourceTable = "User Plan";
    ContextSensitiveHelpPage = 'ui-how-users-permissions';
    Permissions = tabledata "User Plan" = r;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User Name"; Rec."User Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the short name for the user.';
                }
                field("Plan Name"; Rec."Plan Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the subscription plan.';
                }
            }
        }
    }

    actions
    {
    }
}