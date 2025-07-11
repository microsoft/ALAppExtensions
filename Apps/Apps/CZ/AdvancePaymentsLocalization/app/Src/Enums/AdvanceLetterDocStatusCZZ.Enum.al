// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

enum 31011 "Advance Letter Doc. Status CZZ"
{
    Extensible = true;

    value(0; New)
    {
        Caption = 'New';
    }
    value(1; "To Pay")
    {
        Caption = 'To Pay';
    }
    value(2; "To Use")
    {
        Caption = 'To Use';
    }
    value(3; Closed)
    {
        Caption = 'Closed';
    }
    value(9; "Pending Approval")
    {
        Caption = 'Pending Approval';
    }
}
