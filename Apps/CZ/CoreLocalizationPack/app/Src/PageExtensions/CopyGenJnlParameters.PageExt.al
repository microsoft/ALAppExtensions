// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

pageextension 31140 "Copy Gen. Jnl. Parameters CZL" extends "Copy Gen. Journal Parameters"
{
    layout
    {
        addafter("Replace Posting Date")
        {
            field("Replace VAT Date CZL"; Rec."Replace VAT Date CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Replace VAT Date';
                ToolTip = 'Specifies if the VAT date will be replaced with the value of current field while copy posted journal lines. If you leave this field blank original VAT Date will be used in Target Journal.';
            }
        }
    }
}
