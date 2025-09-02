
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.CRM.Contact;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;

permissionset 4406 "SOA - Objects"
{
    Caption = 'Sales Order Agent - Objects';
    Assignable = false;

    Permissions =
        page "Contact Card" = X,
        page "Contact List" = X,
        page "Customer Card" = X,
        page "Customer List" = X,
        page "Item List" = X,
        page "Item Lookup" = X,
        page "Sales Quote" = X,
        page "Sales Quotes" = X,
        page "Sales Quote Subform" = X,
        page "SOA Multi Items Availability" = X;
}