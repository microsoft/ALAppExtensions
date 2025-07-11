// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18029 "GST Ledger Transaction Type"
{
    value(0; Purchase)
    {
        Caption = 'Purchase';
    }
    value(1; Sales)
    {
        Caption = 'Sales';
    }
}
