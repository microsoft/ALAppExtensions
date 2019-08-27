// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 9822 "User Plan Members"
{
    Caption = 'User Plan Members';
    Extensible = false;
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "User Plan";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User Name"; "User Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the short name for the user.';
                }
                field("User Full Name"; "User Full Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the full name of the user.';
                }
                field("Plan Name"; "Plan Name")
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

