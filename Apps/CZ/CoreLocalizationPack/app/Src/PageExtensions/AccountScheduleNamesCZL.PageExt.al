// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

pageextension 11781 "Account Schedule Names CZL" extends "Account Schedule Names"
{
    layout
    {
        addlast(Control1)
        {
            field("Acc. Schedule Type CZL"; Rec."Acc. Schedule Type CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type of financial report (Balance Sheet or Income Statement).';
            }
        }
    }
}
