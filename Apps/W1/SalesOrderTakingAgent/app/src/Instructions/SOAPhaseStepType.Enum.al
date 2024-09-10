// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker.Instructions;

enum 4308 "SOA Phase Step Type"
{
    Extensible = false;
    Caption = 'Sales Order Taking Agent Phase Step Type';

    value(0; "Task")
    {
        Caption = 'Task';
    }
    value(1; "Policy")
    {
        Caption = 'Policy';
    }
}