
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

using System.Security.AccessControl;
using Microsoft.Inventory.Planning;
using Microsoft.Assembly.Document;
using System.Environment.Configuration;
using Microsoft.Integration.Entity;
using Microsoft.Utilities;
using System.Utilities;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Item.Attribute;
using Microsoft.Inventory.Availability;
using Microsoft.Sales.Comment;
using Microsoft.Sales.Document;
using Microsoft.Sales.RoleCenters;
using Microsoft.Finance.Dimension;
using Microsoft.Sales.Customer;

permissionset 4405 "SOA Agent - Edit"
{
    Caption = 'Sales Order Taker Agent - Edit';
    Assignable = true;
    IncludedPermissionSets = "D365 Basic - Read",
                             "D365 CUSTOMER, VIEW",
                             "D365 ITEM, VIEW",
                             "D365 ITEM AVAIL CALC",
                             "D365 SALES DOC, EDIT",
                             "D365 SALES DOC, POST",
                             "SOA Agent - Read";

    Permissions = tabledata "Assemble-to-Order Link" = IMD,
                  tabledata "Assembly Header" = IMD,
                  tabledata "Assembly Line" = IMD,
                  tabledata "Aggregate Permission Set" = imd,
                  tabledata "All Profile Page Metadata" = imd,
                  tabledata "Dimension Set Entry" = im,
                  tabledata "Dimension Set Tree Node" = im,
                  tabledata "Error Buffer" = IMD,
                  tabledata "Error Handling Parameters" = IMD,
                  tabledata "Error Message" = IMD,
                  tabledata "Error Message Register" = IMD,
                  tabledata "My Customer" = IMD,
                  tabledata "Item Amount" = IMD,
                  tabledata "Item Application Entry" = imd,
                  tabledata "Item Application Entry History" = imd,
                  tabledata "Item Attr. Value Translation" = IMD,
                  tabledata "Item Attribute" = IMD,
                  tabledata "Item Attribute Translation" = IMD,
                  tabledata "Item Attribute Value" = IMD,
                  tabledata "Item Attribute Value Mapping" = IMD,
                  tabledata "Item Attribute Value Selection" = IMD,
                  tabledata "Item Availability Buffer" = IMD,
                  tabledata "Planning Assignment" = im,
                  tabledata "Sales Comment Line" = IMD,
                  tabledata "Sales Cue" = IMD,
                  tabledata "Sales Invoice Entity Aggregate" = IMD,
                  tabledata "Sales Invoice Line Aggregate" = IMD,
                  tabledata "Sales Line" = im,
                  tabledata "Sales Order Entity Buffer" = IMD,
                  tabledata "Sales Quote Entity Buffer" = IMD,
                  tabledata "Value Entry" = im;
}