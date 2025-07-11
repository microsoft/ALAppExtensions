// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18023 "GST Group Type"
{
    value(0; Goods)
    {
        Caption = 'Goods';
    }
    value(1; Service)
    {
        Caption = 'Service';
    }
}
