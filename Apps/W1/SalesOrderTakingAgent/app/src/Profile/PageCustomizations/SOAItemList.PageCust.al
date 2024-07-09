// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

using Microsoft.Inventory.Item;

pagecustomization "SOA Item List" customizes "Item List"
{
    ClearActions = true;
    ClearLayout = true;
    ClearViews = true;

    layout
    {
        modify("No.")
        {
            Visible = true;
        }
        modify(Description)
        {
            Visible = true;
        }
        modify("Description 2")
        {
            Visible = true;
        }
        modify(Type)
        {
            Visible = true;
        }
        modify("Substitutes Exist")
        {
            Visible = true;
        }
        modify("Stockkeeping Unit Exists")
        {
            Visible = true;
        }
        modify("Base Unit of Measure")
        {
            Visible = true;
        }
        modify("Unit Cost")
        {
            Visible = true;
        }
        modify("Unit Price")
        {
            Visible = true;
        }
        modify(InventoryField)
        {
            Visible = true;
        }
        modify("Inventory Posting Group")
        {
            Visible = true;
        }
        modify("Gen. Prod. Posting Group")
        {
            Visible = true;
        }
        modify("VAT Prod. Posting Group")
        {
            Visible = true;
        }
        modify("Item Disc. Group")
        {
            Visible = true;
        }
        modify("Item Category Code")
        {
            Visible = true;
        }
        modify(Blocked)
        {
            Visible = true;
            Editable = false;
        }
        modify("Sales Unit of Measure")
        {
            Visible = true;
        }
        modify("Item Tracking Code")
        {
            Visible = true;
        }
    }

    actions
    {

    }
}