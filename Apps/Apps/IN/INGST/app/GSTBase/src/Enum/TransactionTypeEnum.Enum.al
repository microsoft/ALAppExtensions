// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18048 "Transaction Type Enum"
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
    value(3; Service)
    {
        Caption = 'Service';
    }
    value(4; "Service Transfer")
    {
        Caption = 'Service Transfer';
    }
    value(5; Production)
    {
        Caption = 'Production';
    }
}
