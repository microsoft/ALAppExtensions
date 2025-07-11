// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Bank.BankAccount;

pageextension 11518 "Swiss QR-Bill Bank Account" extends "Bank Account Card"
{
    layout
    {
        addafter(IBAN)
        {
            field("Swiss QR-Bill IBAN"; Rec."Swiss QR-Bill IBAN")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the bank account''s QR-IBAN value.';
            }
        }
    }
}
