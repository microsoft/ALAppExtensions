#if not CLEAN28
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

report 10063 "Upgrade IRS 1099 Data"
{
    Caption = 'Upgrade IRS 1099 Data';
    ProcessingOnly = true;
    ObsoleteState = Pending;
    ObsoleteReason = 'This report will be removed in a future release as the IRS 1099 data upgrade is no longer needed.';
    ObsoleteTag = '28.0';

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(IRSReportingPeriodCodeField; IRSReportingPeriodCode)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Reporting Period Code';
                        ToolTip = 'Specifies the code of the tax reporting period to upgrade the data from the old IRS 1099 feature to the new one.';
                        TableRelation = "IRS Reporting Period";
                        ShowMandatory = true;
                    }
                }
            }

        }
    }

    var
        IRSReportingPeriodCode: Code[20];
}
#endif