// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

enum 11510 "Swiss QR-Bill Address Type"
{
    Extensible = false;

    value(0; "Structured")
    {
        Caption = 'Structured';
    }
    value(1; "Combined")
    {
        Caption = 'Combined';
    }
}
