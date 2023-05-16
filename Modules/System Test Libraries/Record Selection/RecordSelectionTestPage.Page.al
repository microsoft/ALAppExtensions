// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 135536 "Record Selection Test Page"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Record Selection Test Table";
    Caption = 'Record Selection Test Page';

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(SomeInteger; Rec.SomeInteger)
                {
                    ApplicationArea = All;
                    ToolTip = 'Some Integer';
                }

                field(SomeCode; Rec.SomeCode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Some Code';
                }

                field(SomeText; Rec.SomeText)
                {
                    ApplicationArea = All;
                    ToolTip = 'Some Text';
                }

                field(SomeOtherText; Rec.SomeOtherText)
                {
                    ApplicationArea = All;
                    ToolTip = 'Some Other Text';
                }
            }
        }
    }
}