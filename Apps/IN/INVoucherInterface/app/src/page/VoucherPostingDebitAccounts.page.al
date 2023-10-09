// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.VoucherInterface;

page 18929 "Voucher Posting Debit Accounts"
{
    Caption = 'Voucher Posting Debit Accounts';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Voucher Posting Debit Account";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Type"; "Account Type")
                {
                    Caption = 'Type';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of account that a balancing entry is posted to, such as BANK or a cash account.';
                }
                field("Account No."; "Account No.")
                {
                    Caption = 'Account No.';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the general ledger or bank account that the balancing entry is posted to, such as a cash account.';
                }
                field("For UPI Payments"; "For UPI Payments")
                {
                    Caption = 'For UPI Payments';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the UPI ID should have a value in bank account.';
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if ("Type" = "Type"::"Cash Receipt Voucher") or ("Type" = "Type"::"Cash Payment Voucher") then
            "Account Type" := "Account Type"::"G/L Account";

        if ("Type" = "Type"::"Bank Receipt Voucher") or ("Type" = "Type"::"Bank Payment Voucher") then
            "Account Type" := "Account Type"::"Bank Account";
    end;
}
