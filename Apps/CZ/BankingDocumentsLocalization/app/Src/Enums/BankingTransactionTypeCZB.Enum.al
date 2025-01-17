// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

enum 31250 "Banking Transaction Type CZB"
{
    Extensible = false;

    value(0; Both)
    {
        Caption = 'Both';
    }
    value(1; Credit)
    {
        Caption = 'Credit';
    }
    value(2; Debit)
    {
        Caption = 'Debit';
    }
}
