// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18014 "Detail Ledger Transaction Type"
{
    value(0; Purchase)
    {
        Caption = 'Purchase';
    }
    value(1; Sales)
    {
        Caption = 'Sales';
    }
    value(2; Transfer)
    {
        Caption = 'Transfer';
    }
    value(3; Settlement)
    {
        Caption = 'Settlement';
    }
}
