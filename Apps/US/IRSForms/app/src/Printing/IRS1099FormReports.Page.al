// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10048 "IRS 1099 Form Reports"
{
    PageType = List;
    SourceTable = "IRS 1099 Form Report";
    ApplicationArea = BasicUS;
    Editable = true;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Report Type"; Rec."Report Type")
                {
                    Tooltip = 'Specifies the report type.';
                    trigger OnDrillDown()
                    begin
                        Rec.DownloadReportFile();
                    end;
                }
            }
        }
    }
}
