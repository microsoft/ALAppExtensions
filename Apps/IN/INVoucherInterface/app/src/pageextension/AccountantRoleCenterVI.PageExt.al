// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.RoleCenters;

using Microsoft.Bank.VoucherInterface;
using Microsoft.Finance.TaxBase;

pageextension 18949 "Accountant Role Center VI" extends "Accountant Role Center"
{
    actions
    {
        addafter("India Taxation")
        {
            group("Voucher Interface")
            {
                action("Bank Payment Voucher")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Register transactions which affect the Bank accounts while making payments to Vendors.';
                    Caption = 'Bank Payment Voucher';
                    Promoted = false;
                    Image = EditList;
                    RunObject = Page "Bank Payment Voucher";
                }

                action("Cash Payment Voucher")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Register transactions which affect the cash accounts while making cash payments to Vendors.';
                    Caption = 'Cash Payment Voucher';
                    Promoted = false;
                    Image = EditList;
                    RunObject = Page "Cash Payment Voucher";
                }

                action("Cash Receipt Voucher")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Register transactions hich affect the cash accounts while receiving cash payments from Customers.';
                    Caption = 'Cash Receipt Voucher';
                    Promoted = false;
                    Image = EditList;
                    RunObject = Page "Cash Receipt Voucher";
                }

                action("Bank Receipt Voucher")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Register transactions which affect the bank accounts while receiving payments from Customers.';
                    Caption = 'Bank Receipt Voucher';
                    Promoted = false;
                    Image = EditList;
                    RunObject = Page "Bank Receipt Voucher";
                }

                action("Journal Voucher")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Register transactions which are affecting neither the cash account nor the bank account are termed asÂ Journal Vouchers.';
                    Caption = 'Journal Voucher';
                    Promoted = false;
                    Image = EditList;
                    RunObject = Page "Journal Voucher";
                }

                action("Contra Voucher")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Register transactions which affect the cash and bank account together are termed as contra vouchers. For example, withdrawal from bank is one such transaction.';
                    Caption = 'Contra Voucher';
                    Promoted = false;
                    Image = EditList;
                    RunObject = Page "Contra Voucher";

                }

                action("Day Book")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Generate the Day Book for all types of vouchers for a specific date.';
                    Caption = 'Day Book';
                    Promoted = false;
                    Image = EditList;
                    RunObject = report "Day Book";
                }

                action("Bank Book")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Generate the Bank Book according to the locations for all types of bank transactions.';
                    Caption = 'Bank Book';
                    Promoted = false;
                    Image = EditList;
                    RunObject = report "Bank Book";
                }

                action("Cash Book")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Generate the Cash Book according to the locations for all types of cash transactions.';
                    Caption = 'Cash Book';
                    Promoted = false;
                    Image = EditList;
                    RunObject = report "Cash Book";
                }

                action(Ledger)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Generate the control accounts with sub-ledger details.';
                    Caption = 'Ledger';
                    Promoted = false;
                    Image = EditList;
                    RunObject = report Ledger;
                }

                action("Voucher Register")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Generate the vouchers for complete register.';
                    Caption = 'Voucher Register';
                    Promoted = false;
                    Image = EditList;
                    RunObject = report "Voucher Register";
                }
            }
        }
    }
}
