// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

enum 11733 "Cash Document Status CZP"
{
    Extensible = true;

    value(0; Open)
    {
        Caption = 'Open';
    }
    value(1; Released)
    {
        Caption = 'Released';
    }
    value(2; "Pending Approval")
    {
        Caption = 'Pending Approval';
    }
    value(3; Approved)
    {
        Caption = 'Approved';
    }
}
