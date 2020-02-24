// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// List page that contains all plans that can be assigned to users.
/// </summary>
page 9824 Plans
{
    Caption = 'Plans';
    Editable = false;
    Extensible = false;
    LinksAllowed = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = Plan;
    ContextSensitiveHelpPage = 'ui-how-users-permissions';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the plan.';
                }
            }
        }
        area(factboxes)
        {
            part("Users in the Plan"; "User Plan Members FactBox")
            {
                Caption = 'Users in Plan';
                ApplicationArea = All;
                SubPageLink = "Plan ID" = field("Plan ID");
            }
        }
    }
}

