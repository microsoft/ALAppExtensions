// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 132617 "Home Items Page Action Test"
{
    Caption = 'Role Center';
    PageType = RoleCenter;

    layout
    {
    }

    actions
    {
        area(embedding)
        {
            action(PageWithViews)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Page with views';
                RunObject = Page "Views Page Action Test";
                ToolTip = 'Test page with views';
            }
            action(EmptyPage)
            {
                ApplicationArea = All;
                Caption = 'Empty card page';
                RunObject = Page "Empty Card Page Action Test";
                ToolTip = 'Test empty card page';
            }
        }
        area(processing)
        {
            action(PageWithViewsInProcesing)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Page with views';
                RunObject = Page "Views Page Action Test";
                ToolTip = 'Test page with views';
            }
        }
    }
}

