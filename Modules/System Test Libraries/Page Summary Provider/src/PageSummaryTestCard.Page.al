// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Integration;

page 132548 "Page Summary Test Card"
{
    PageType = Card;
    SourceTable = "Page Provider Summary Test";
    Caption = 'Page summary';
    CardPageId = "Page Summary Empty Page";

    layout
    {
        area(content)
        {
            field(TestBigInteger; Rec.TestBigInteger)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies a Test field';
            }
#pragma warning disable AW0004
            field(TestBlob; Rec.TestBlob)
#pragma warning restore AW0004
            {
                ApplicationArea = All;
                ToolTip = 'Specifies a Test field';
            }
            field(TestBoolean; Rec.TestBoolean)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies a Test field';
            }
            field(TestCode; Rec.TestCode)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies a Test field';
            }
            field(TestDate; Rec.TestDate)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies a Test field';
            }
            field(TestDateFormula; Rec.TestDateFormula)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies a Test field';
            }
            field(TestDateTime; Rec.TestDateTime)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies a Test field';
            }
            field(TestDecimal; Rec.TestDecimal)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies a Test field';
            }
            field(TestTime; Rec.TestTime)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies a Test field';
            }
            field(TestText; Rec.TestText)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies a Test field';
            }
            field(TestTableFilter; Rec.TestTableFilter)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies a Test field';
            }
            field(TestRecordId; Rec.TestRecordId)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies a Test field';
            }
            field(TestOption; Rec.TestOption)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies a Test field';
            }
            field(TestMediaSet; Rec.TestMediaSet)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies a Test field';
            }
            field(TestMedia; Rec.TestMedia)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies a Test field';
            }
            field(TestInteger; Rec.TestInteger)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies a Test field';
            }
            field(TestGuid; Rec.TestGuid)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies a Test field';
            }
            field(TestEnum; Rec.TestEnum)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies a Test field';
            }
            field(TestDuration; Rec.TestDuration)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies a Test field';
            }
        }
    }

    actions
    {
    }
}

