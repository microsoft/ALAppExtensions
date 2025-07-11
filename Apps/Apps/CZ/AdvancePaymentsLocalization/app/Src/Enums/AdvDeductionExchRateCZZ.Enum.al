// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

enum 31013 "Adv. Deduction Exch. Rate CZZ"
{
    Extensible = true;

    value(0; Invoice)
    {
        Caption = 'Invoice';
    }
    value(1; "Advance Letter")
    {
        Caption = 'Advance Letter';
    }
}
