// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker.Instructions;

enum 4307 "SOA Phases"
{
    Extensible = false;
    Caption = 'Sales Order Taking Agent Phases';

    value(1; "Identify Business Partner")
    {
        Caption = 'Identify business partner';
    }
    value(2; "Create Sales Document")
    {
        Caption = 'Create sales document';
    }
    value(3; "Add Details to Sales Document")
    {
        Caption = 'Add details to sales document';
    }
    value(4; "Send Sales Document")
    {
        Caption = 'Send sales document';
    }
    value(5; "Process Response")
    {
        Caption = 'Process response';
    }
}