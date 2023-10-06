// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Purchases.Vendor;

pageextension 11514 "Swiss QR-Bill Vend.BankAccCard" extends "Vendor Bank Account Card"
{
    layout
    {
        modify(IBAN)
        {
            Caption = 'IBAN/QR-IBAN';
            ToolTip = 'Specifies the IBAN or QR-IBAN account of the vendor.';
        }
    }
}
