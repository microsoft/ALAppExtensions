// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

enum 11512 "Swiss QR-Bill Payment Reference Type"
{
    Extensible = false;

    value(0; "Without Reference")
    {
        Caption = 'Without Reference';
    }
    value(1; "Creditor Reference (ISO 11649)")
    {
        Caption = 'Creditor Reference';
    }
    value(2; "QR Reference")
    {
        Caption = 'QR Reference';
    }
}
