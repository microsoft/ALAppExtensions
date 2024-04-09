// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.GeneralLedger.Setup;

pageextension 31155 "General Ledger Setup CZP" extends "General Ledger Setup"
{
    layout
    {
        addafter(General)
        {
            group(CashDeskCZP)
            {
                Caption = 'Cash Desk';
                field("Cash Payment Limit (LCY) CZP"; Rec."Cash Payment Limit (LCY) CZP")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the maximum daily limit for the partner''s cash payments in the local currency.';
                }
                field("Cash Desk Nos. CZP"; Rec."Cash Desk Nos. CZP")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to cash desk.';
                }
            }
        }
    }
}
