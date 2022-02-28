// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 132548 "Page Summary Test Card"
{
    PageType = Card;
    SourceTable = "Page Provider Summary Test";
    CaptionML = ENU = 'Page summary', DAN = 'Side opsummering';
    CardPageId = "Page Summary Empty Page";

    layout
    {
        area(content)
        {
            field(TestBigInteger; Rec.TestBigInteger)
            {
                ApplicationArea = All;
                ToolTip = 'Test field';
            }
            field(TestBlob; Rec.TestBlob)
            {
                ApplicationArea = All;
                ToolTip = 'Test field';
            }
            field(TestBoolean; Rec.TestBoolean)
            {
                ApplicationArea = All;
                ToolTip = 'Test field';
            }
            field(TestCode; Rec.TestCode)
            {
                ApplicationArea = All;
                ToolTip = 'Test field';
            }
            field(TestDate; Rec.TestDate)
            {
                ApplicationArea = All;
                ToolTip = 'Test field';
            }
            field(TestDateFormula; Rec.TestDateFormula)
            {
                ApplicationArea = All;
                ToolTip = 'Test field';
            }
            field(TestDateTime; Rec.TestDateTime)
            {
                ApplicationArea = All;
                ToolTip = 'Test field';
            }
            field(TestDecimal; Rec.TestDecimal)
            {
                ApplicationArea = All;
                ToolTip = 'Test field';
            }
            field(TestTime; Rec.TestTime)
            {
                ApplicationArea = All;
                ToolTip = 'Test field';
            }
            field(TestText; Rec.TestText)
            {
                ApplicationArea = All;
                ToolTip = 'Test field';
            }
            field(TestTableFilter; Rec.TestTableFilter)
            {
                ApplicationArea = All;
                ToolTip = 'Test field';
            }
            field(TestRecordId; Rec.TestRecordId)
            {
                ApplicationArea = All;
                ToolTip = 'Test field';
            }
            field(TestOption; Rec.TestOption)
            {
                ApplicationArea = All;
                ToolTip = 'Test field';
            }
            field(TestMediaSet; Rec.TestMediaSet)
            {
                ApplicationArea = All;
                ToolTip = 'Test field';
            }
            field(TestMedia; Rec.TestMedia)
            {
                ApplicationArea = All;
                ToolTip = 'Test field';
            }
            field(TestInteger; Rec.TestInteger)
            {
                ApplicationArea = All;
                ToolTip = 'Test field';
            }
            field(TestGuid; Rec.TestGuid)
            {
                ApplicationArea = All;
                ToolTip = 'Test field';
            }
            field(TestEnum; Rec.TestEnum)
            {
                ApplicationArea = All;
                ToolTip = 'Test field';
            }
            field(TestDuration; Rec.TestDuration)
            {
                ApplicationArea = All;
                ToolTip = 'Test field';
            }
        }
    }

    actions
    {
    }
}

