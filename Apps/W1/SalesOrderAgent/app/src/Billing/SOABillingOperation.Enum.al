// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

enum 4586 "SOA Billing Operation"
{
    Extensible = false;
    Access = Internal;

    value(1; "Inbound Message")
    {
        Caption = 'Inbound Message';
    }
    value(2; "Outbound Message")
    {
        Caption = 'Outbound Message';
    }
    value(3; "Quote Action")
    {
        Caption = 'Quote Action';
    }
    value(4; "Order Action")
    {
        Caption = 'Order Action';
    }
    value(5; "Relevant Attachment")
    {
        Caption = 'Relevant Attachment';
    }
    value(6; "Irrelevant Attachment")
    {
        Caption = 'Irrelevant Attachment';
    }
    value(7; "Item Availability")
    {
        Caption = 'Item Availability';
    }
}