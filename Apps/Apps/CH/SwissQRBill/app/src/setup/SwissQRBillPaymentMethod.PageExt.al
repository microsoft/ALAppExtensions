// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Bank.BankAccount;

pageextension 11513 "Swiss QR-Bill Payment Method" extends "Payment Methods"
{
    layout
    {
        addlast(Control1)
        {
            field("Swiss QR-Bill Layout"; "Swiss QR-Bill Layout")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the QR-Bill Layout code.';
                Caption = 'QR-Bill Layout';
            }
        }
        addafter("Bal. Account No.")
        {
            field("Swiss QR-Bill Bank Account No."; Rec."Swiss QR-Bill Bank Account No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the QR-bill bank account number. IBAN and QR-IBAN values from this bank account determine which IBAN or QR-IBAN number will be printed on the QR-bills that use this payment method. If no bank account is specified, the IBAN or QR-IBAN from the Company Information age is used.';
                Caption = 'QR-Bill Bank Account No.';
            }
        }
    }
}
