// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

profile "Sales Order Taker Agent"
{
    Caption = 'Sales Order Taker Agent';
    Description = 'Page customizations for Sales Order Taker Agent';
    RoleCenter = "SOA Role Center";
    Customizations = "SOA Customer Card",
                     "SOA Customer List",
                     "SOA Item List",
                     "SOA Item Lookup",
                     "SOA Sales Quote",
                     "SOA Sales Quotes",
                     "SOA Sales Quote Subform",
                     "SOA Contact Card",
                     "SOA Contact List";
}