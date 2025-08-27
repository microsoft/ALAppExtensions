// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

profile "Sales Order Agent"
{
    Caption = 'Sales Order Agent (Copilot)';
    Description = 'Page customizations for Sales Order Agent';
    RoleCenter = "SOA Role Center";
    Customizations = "SOA Customer Card",
                     "SOA Customer List",
                     "SOA Item List",
                     "SOA Item Card",
                     "SOA Item Lookup",
                     "SOA Sales Quote",
                     "SOA Sales Quotes",
                     "SOA Sales Quote Subform",
                     "SOA Sales Order",
                     "SOA Sales Orders",
                     "SOA Sales Order Subform",
                     "SOA Contact Card",
                     "SOA Contact List",
                     "SOA Multi Item Avail.",
                     "SOA Ship-to Address List";
}