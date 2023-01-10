// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 132618 "Views Page Action Test"
{
    PageType = List;
    SourceTable = "Page Action Provider Test";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(TestBoolean; Rec.TestBoolean)
                {
                    ApplicationArea = All;
                    ToolTip = 'Test boolean field';
                }
                field(TestDecimal; Rec.TestDecimal)
                {
                    ApplicationArea = All;
                    ToolTip = 'Test decimal field';
                }
                field("Test Spaces"; Rec."Field With Spaces")
                {
                    ApplicationArea = All;
                    ToolTip = 'Field with spaces';
                }
            }
        }
    }

    views
    {
        view(BooleanView)
        {
            Caption = 'TestBoolean';
            Filters = where(TestBoolean = Const(true));
        }
        view(BooleanDecimalView)
        {
            Caption = 'TestBoolean TestDecimal';
            Filters = where(TestBoolean = const(true), TestDecimal = const(10));
        }
        view(SpacesView)
        {
            Caption = 'TestSpaces';
            Filters = where("Field With Spaces" = const(20));
        }
    }
}