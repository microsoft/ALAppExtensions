// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Setup;

pageextension 18817 "General Ledger Setup TCS" extends "General Ledger Setup"
{
    layout
    {
        addlast(content)
        {
            group(TCS)
            {
                field("TCS Debit Note No."; Rec."TCS Debit Note No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number series for TCS debit note journal.';
                }
            }
        }
    }
}
