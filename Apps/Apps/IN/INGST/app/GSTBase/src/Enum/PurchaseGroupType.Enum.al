// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18043 "Purchase Group Type"
{
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Goods)
    {
        Caption = 'Goods';
    }
    value(2; Service)
    {
        Caption = 'Service';
    }
}
