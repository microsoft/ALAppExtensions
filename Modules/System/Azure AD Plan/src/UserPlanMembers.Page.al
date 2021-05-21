// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// List page that contains all users and the plans that they are assigned to.
/// </summary>
page 9822 "User Plan Members"
{
    Caption = 'User Plan Members';
    Extensible = false;
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "User Plan";
    ContextSensitiveHelpPage = 'ui-how-users-permissions';
    permissions = tabledata "User Plan" = r;

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
                field("User Full Name"; Rec."User Full Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the full name of the user.';
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

