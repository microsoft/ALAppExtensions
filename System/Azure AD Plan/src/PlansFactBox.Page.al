// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// ListPart page that contains all the plans.
/// </summary>
page 9825 "Plans FactBox"
{
    Caption = 'Plans';
    Editable = false;
    LinksAllowed = false;
    PageType = ListPart;
    ShowFilter = false;
    SourceTable = Plan;
    ContextSensitiveHelpPage = 'ui-how-users-permissions';
    Permissions = tabledata Plan = r;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the record.';
                }
            }
        }
    }

    actions
    {
    }
}

