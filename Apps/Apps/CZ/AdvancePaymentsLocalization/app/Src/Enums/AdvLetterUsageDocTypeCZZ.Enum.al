// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

enum 31012 "Adv. Letter Usage Doc.Type CZZ"
{
    Extensible = true;

    value(0; "Sales Order")
    {
        Caption = 'Sales Order';
    }
    value(1; "Sales Invoice")
    {
        Caption = 'Sales Invoice';
    }
    value(2; "Posted Sales Invoice")
    {
        Caption = 'Posted Sales Invoice';
    }
    value(3; "Purchase Order")
    {
        Caption = 'Purchase Order';
    }
    value(4; "Purchase Invoice")
    {
        Caption = 'Purchase Invoice';
    }
    value(5; "Posted Purchase Invoice")
    {
        Caption = 'Posted Purchase Invoice';
    }
}
