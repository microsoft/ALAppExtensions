// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

enum 11511 "Swiss QR-Bill IBAN Type"
{
    Extensible = false;

    value(0; IBAN)
    {
        Caption = 'IBAN';
    }
    value(1; "QR-IBAN")
    {
        Caption = 'QR-IBAN';
    }
}
