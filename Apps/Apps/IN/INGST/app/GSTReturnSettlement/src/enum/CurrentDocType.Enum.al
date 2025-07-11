// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

Enum 18320 "Current Doc. Type"
{
    Extensible = true;
    value(0; Quote)
    {
        Caption = 'Quote';
    }
    value(1; Order)
    {
        Caption = 'Order';
    }
    value(2; Invoice)
    {
        Caption = 'Invoice';
    }
    value(3; "Credit Memo")
    {
        Caption = 'Credit Memo';
    }
    value(4; "Blanket Order")
    {
        Caption = 'Blanket Order';
    }
    value(5; "Return Order")
    {
        Caption = 'Return Order';
    }
    value(6; Payment)
    {
        Caption = 'Payment';
    }
    value(7; "Refund")
    {
        Caption = 'Refund';
    }
}
