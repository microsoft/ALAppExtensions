// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;

query 6610 "FS Item Avail. by Location"
{
    elements
    {
        dataitem(Item_Ledger_Entry; "Item Ledger Entry")
        {
            DataItemTableFilter = "Location Code" = filter(<> ''), Open = filter(true);
            column(locationCode; "Location Code")
            {
                Caption = 'Location Code';
            }
            column(itemNo; "Item No.")
            {
                Caption = 'Item No.';
            }
            column(unitOfMeasureCode; "Unit of Measure Code")
            {
                Caption = 'Unit of Measure Code';
            }
            column(remainingQuantity; "Remaining Quantity")
            {
                Caption = 'Remaining Quantity';
                Method = Sum;
            }
            dataitem(Item; Item)
            {
                DataItemLink = "No." = Item_Ledger_Entry."Item No.";
                SqlJoinType = InnerJoin;
                column(itemDescription; Description)
                {
                }
                filter(coupledToDataverse; "Coupled to Dataverse")
                {
                    ColumnFilter = coupledToDataverse = const(true);
                }
                dataitem(Location; Location)
                {
                    DataItemLink = Code = Item_Ledger_Entry."Location COde";
                    SqlJoinType = InnerJoin;
                    column(locationName; Name)
                    {
                    }
                    filter(coupledToFS; "Coupled to FS")
                    {
                        ColumnFilter = coupledToFS = const(true);
                    }
                }
            }
        }
    }
}