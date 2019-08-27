// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 9824 Plans
{
    Caption = 'Plans';
    Editable = false;
    Extensible = false;
    LinksAllowed = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = Plan;

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
        area(factboxes) { }
    }

    actions
    {
        area(navigation) { }
    }
}

