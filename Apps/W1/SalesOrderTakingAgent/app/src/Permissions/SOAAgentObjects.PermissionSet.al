
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

using Agent.SalesOrderTaker.Instructions;
using Microsoft.CRM.Contact;
using Microsoft.Sales.Document;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;

permissionset 4406 "SOA Agent - Objects"
{
    Caption = 'Sales Order Taker Agent - Objects';
    Assignable = false;

    Permissions =
        codeunit "SOA Instructions Mgt." = X,
        page "Contact Card" = X,
        page "Contact List" = X,
        page "Customer Card" = X,
        page "Customer List" = X,
        page "Item List" = X,
        page "Item Lookup" = X,
        page "Sales Quote" = X,
        page "Sales Quotes" = X,
        page "Sales Quote Subform" = X,
        page "SOA Instruction Phases" = X,
        page "SOA Instruction Phase Steps" = X,
        page "SOA Instruction Prompt Card" = X,
        page "SOA Instruction Prompt List" = X,
        page "SOA Instructions" = X,
        page "SOA Instruction Templates" = X,
        page "SOA Instruct. Tasks/Policies" = X;
}