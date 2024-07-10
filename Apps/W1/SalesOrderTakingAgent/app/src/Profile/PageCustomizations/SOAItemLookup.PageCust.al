// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

using Microsoft.Inventory.Item;

pagecustomization "SOA Item Lookup" customizes "Item Lookup"
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
        modify(InventoryCtrl)
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
    }

    actions
    {
        modify(ItemList)
        {
            Visible = true;
        }
        modify(ItemList_Promoted)
        {
            Visible = true;
        }
    }
}