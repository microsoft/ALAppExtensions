// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.CRM.RoleCenters;

pageextension 20654 "Sales Relation ship Mgr RC BF" extends "Sales & Relationship Mgr. RC"
{
    actions
    {
        modify("Blanket Sales Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(Contacts)
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Sales Quotes")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify(Customers)
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify(Items)
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify(Action65) // Sales Quotes
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify(Action63) // Customers
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify(Action62) // Items
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Cust. Invoice Discounts")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Vend. Invoice Discounts")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Item Disc. Groups")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify(Action38) // Contacts
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify(Action21) // Customers
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify(NewContact)
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Sales Price &Worksheet")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
#if not CLEAN25
        modify("Sales &Prices")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Sales Line &Discounts")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
#else
        modify("Price Lists")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
#endif
    }
}
