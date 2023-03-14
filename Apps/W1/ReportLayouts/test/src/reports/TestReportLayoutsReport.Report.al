// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

report 139595 TestReportLayoutsReport
{
    UsageCategory = Administration;
    ApplicationArea = All;
    DefaultRenderingLayout = MYLAYOUT;

    dataset
    {
        dataitem(DataItemName; "Test Table A")
        {
            column(ColumnName; MyField)
            {

            }
        }
    }

    rendering
    {
        layout(MYLAYOUT)
        {
            Type = RDLC;
            LayoutFile = 'mylayout.rdl';
        }
    }
}