// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Sales;

enum 18144 "e-Invoice Cancel Reason"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Duplicate)
    {
        Caption = 'Duplicate';
    }
    value(2; "Data Entry Mistake")
    {
        Caption = 'Data Entry Mistake';
    }
    value(3; "Order Canceled")
    {
        Caption = 'Order Canceled';
    }
    value(4; "Other")
    {
        Caption = 'Other';
    }
}
