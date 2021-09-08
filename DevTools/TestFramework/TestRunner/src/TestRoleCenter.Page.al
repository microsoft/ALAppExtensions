// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 130456 "Test Role Center"
{
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
        }
    }

    actions
    {
        area(creation)
        {
            action(TestRunner)
            {
                ApplicationArea = All;
                Caption = 'Test Runner';
                RunObject = Page "AL Test Tool";
                ToolTip = 'Specifies the action for invoking Test Runner page';
            }
        }
    }
}

