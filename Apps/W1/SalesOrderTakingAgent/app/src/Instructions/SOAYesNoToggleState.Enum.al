// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker.Instructions;

enum 4305 "SOA Yes/No Toggle State"
{
    Extensible = false;
    Caption = 'Sales Order Taking Agent Yes/No Toggle State';

    value(0; No)
    {
        Caption = 'No';
    }
    value(1; Yes)
    {
        Caption = 'Yes';
    }
    value(2; "Yes (Read-only)")
    {
        Caption = 'Yes (Read-only)';
    }
}