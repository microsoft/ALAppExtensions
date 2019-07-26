// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 132584 "AutoFormat Test Page"
{
    layout
    {
        area(content)
        {
            field("Case0"; Amount)
            {
                ApplicationArea = All;
                AutoFormatExpression = '';
                AutoFormatType = 0;
            }
            field("Case11"; Amount)
            {
                ApplicationArea = All;
                AutoFormatExpression = '<Precision,4:4><Standard Format,0>';
                AutoFormatType = 11;
            }
            field("Case1000"; Amount)
            {
                ApplicationArea = All;
                AutoFormatExpression = '';
                AutoFormatType = 1000;
            }
            field("CaseNoMatch"; Amount)
            {
                ApplicationArea = All;
                AutoFormatExpression = '';
                AutoFormatType = 100;
            }
        }
    }

    var
        Amount: Decimal;
}