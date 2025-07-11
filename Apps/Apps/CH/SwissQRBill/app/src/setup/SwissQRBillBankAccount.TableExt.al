// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.BankAccount;

tableextension 11515 "Swiss QR-Bill Bank Account" extends "Bank Account"
{
    fields
    {
        field(11510; "Swiss QR-Bill IBAN"; Code[50])
        {
            Caption = 'QR-IBAN';
        }
    }
}
