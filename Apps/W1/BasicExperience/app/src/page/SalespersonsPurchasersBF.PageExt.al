// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.CRM.Team;

pageextension 20648 "Salespersons/Purchasers BF" extends "Salespersons/Purchasers"
{
    layout
    {
        modify(Name)
        {
            ApplicationArea = Suite, RelationshipMgmt, BFBasic;
        }
        modify("Commission %")
        {
            ApplicationArea = Suite, RelationshipMgmt, BFBasic;
        }
        modify("Phone No.")
        {
            ApplicationArea = Suite, RelationshipMgmt, BFBasic;
        }
        modify("Privacy Blocked")
        {
            ApplicationArea = Suite, RelationshipMgmt, BFBasic;
        }
    }
    actions
    {
        modify("Con&tacts")
        {
            ApplicationArea = Suite, RelationshipMgmt, BFBasic;
        }
    }
}
