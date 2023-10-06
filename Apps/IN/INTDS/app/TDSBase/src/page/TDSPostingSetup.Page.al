// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

page 18693 "TDS Posting Setup"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    DelayedInsert = true;
    SourceTable = "TDS Posting Setup";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("TDS Section"; Rec."TDS Section")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the TDS section of the vendor account to link transactions made tor this Vendor with the appropriate general ledger account according to TDS posting setup.';
                }
                field("Effective Date"; Rec."Effective Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which the TDS rate on this line comes into effect.';
                }
                field("TDS Account"; Rec."TDS Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account number to post TDS for the TDS section.';
                }
                field("TDS Receivable Account"; Rec."TDS Receivable Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account number to post TDS for TDS section for Customer.';
                }
            }
        }
    }
}
