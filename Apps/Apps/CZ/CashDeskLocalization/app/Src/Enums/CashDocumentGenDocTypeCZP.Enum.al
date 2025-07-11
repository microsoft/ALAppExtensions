// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

enum 11732 "Cash Document Gen.Doc.Type CZP"
{
    Extensible = false;

    value(0; " ")
    {
    }
    value(1; Payment)
    {
        Caption = 'Payment';
    }
    value(6; Refund)
    {
        Caption = 'Refund';
    }
}
