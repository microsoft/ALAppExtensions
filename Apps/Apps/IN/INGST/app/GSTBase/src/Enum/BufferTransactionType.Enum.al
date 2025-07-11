// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18005 "Buffer Transaction Type"
{
    value(0; Sales)
    {
        Caption = 'Sales';
    }
    value(1; Purchase)
    {
        Caption = 'Purchase';
    }
    value(2; Charge)
    {
        Caption = 'Charge';
    }
}
