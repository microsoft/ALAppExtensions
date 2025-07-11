// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Sales;

enum 18143 "Sale Return Type"
{
    Extensible = true;
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Sales Cancellation")
    {
        Caption = 'Sales Cancellation';
    }
}
