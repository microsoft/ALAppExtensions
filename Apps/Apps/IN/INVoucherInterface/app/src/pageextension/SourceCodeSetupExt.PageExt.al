// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.AuditCodes;

pageextension 18929 "Source Code Setup Ext." extends "Source Code Setup"
{
    layout
    {
        addafter("Payment Reconciliation Journal")
        {
            field("Cash Receipt Voucher"; "Cash Receipt Voucher")
            {
                Caption = 'Cash Receipt Voucher';
                ToolTip = 'Specifies the code linked to entries that are posted from a cash receipt voucher.';
                ApplicationArea = Basic, Suite;
            }
            field("Bank Receipt Voucher"; "Bank Receipt Voucher")
            {
                Caption = 'Bank Receipt Voucher';
                ToolTip = 'Specifies the code linked to entries that are posted from a bak receipt voucher.';
                ApplicationArea = Basic, Suite;
            }
            field("Cash Paymrnt Voucher"; "Cash Payment Voucher")
            {
                Caption = 'Cash Payment Voucher';
                ToolTip = 'Specifies the code linked to entries that are posted from a cash payment voucher.';
                ApplicationArea = Basic, Suite;
            }
            field("Bank Payment Voucher"; "Bank Payment Voucher")
            {
                Caption = 'Bank Payment Voucher';
                ToolTip = 'Specifies the code linked to entries that are posted from a bank payment voucher.';
                ApplicationArea = Basic, Suite;
            }
            field("Contra Voucher"; "Contra Voucher")
            {
                Caption = 'Contra Voucher';
                ToolTip = 'Specifies the code linked to entries that are posted from a contra voucher.';
                ApplicationArea = Basic, Suite;
            }
            field("Journal Voucher"; "Journal Voucher")
            {
                Caption = 'Journal Voucher';
                ToolTip = 'Specifies the code linked to entries that are posted from a journal voucher.';
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
