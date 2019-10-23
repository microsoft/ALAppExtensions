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