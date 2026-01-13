
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Assembly.Document;
using Microsoft.Finance.Dimension;
using Microsoft.Integration.Entity;
using Microsoft.Inventory.Requisition;
using Microsoft.Inventory.Availability;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Attribute;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Planning;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Comment;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.RoleCenters;
using Microsoft.Utilities;
using System.Agents;
using System.Diagnostics;
using System.Environment.Configuration;
using System.Security.AccessControl;
using System.Utilities;
using Microsoft.Foundation.Attachment;

permissionset 4405 "SOA - Edit"
{
    Caption = 'Sales Order Agent - Edit';
    Assignable = true;
    IncludedPermissionSets = "D365 Basic - Read",
                             "D365 READ",
                             "D365 CUSTOMER, VIEW",
                             "D365 ITEM, VIEW",
                             "D365 ITEM AVAIL CALC",
                             "D365 SALES DOC, EDIT",
                             "D365 SALES DOC, POST",
                             "LOCAL",
                             "SOA - Read";

    Permissions = tabledata "Agent Task Message" = r,
                  tabledata "Agent Task Message Attachment" = RM,
                  tabledata "Agent Task File" = R,
                  tabledata "Document Attachment" = IMD,
                  tabledata "Assemble-to-Order Link" = IMD,
                  tabledata "Assembly Header" = IMD,
                  tabledata "Assembly Line" = IMD,
                  tabledata "Aggregate Permission Set" = imd,
                  tabledata "All Profile Page Metadata" = imd,
                  tabledata "Change Log Entry" = i,
                  tabledata "Dimension Set Entry" = im,
                  tabledata "Dimension Set Tree Node" = im,
                  tabledata "Error Buffer" = IMD,
                  tabledata "Error Handling Parameters" = IMD,
                  tabledata "Error Message" = IMD,
                  tabledata "Error Message Register" = IMD,
                  tabledata "My Customer" = IMD,
                  tabledata "My Item" = IMD,
                  tabledata "My Vendor" = IMD,
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
                  tabledata "Requisition Line" = IMD,
                  tabledata "Sales Comment Line" = IMD,
                  tabledata "Sales Cue" = IMD,
                  tabledata "Sales Invoice Entity Aggregate" = IMD,
                  tabledata "Sales Invoice Line Aggregate" = IMD,
                  tabledata "Sales Line" = im,
                  tabledata "Sales Order Entity Buffer" = IMD,
                  tabledata "Sales Quote Entity Buffer" = IMD,
                  tabledata "Value Entry" = im;
}