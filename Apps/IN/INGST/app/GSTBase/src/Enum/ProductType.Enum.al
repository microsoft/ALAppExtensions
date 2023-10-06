// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18042 "Product Type"
{
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Item)
    {
        Caption = 'Item';
    }
    value(2; "Capital Goods")
    {
        Caption = 'Capital Goods';
    }
}
