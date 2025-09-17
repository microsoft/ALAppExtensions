// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Inventory.Item;

pagecustomization "SOA Item Lookup" customizes "Item Lookup"
{
    ClearActions = true;
    ClearLayout = true;
    ClearViews = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

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
        }
        modify("Sales Unit of Measure")
        {
            Visible = true;
        }
    }

    actions
    {
        modify(ItemList_Promoted)
        {
            Visible = true;
        }
    }
}