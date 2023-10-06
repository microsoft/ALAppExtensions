// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Environment.Configuration;

using Microsoft.CRM.Team;

pageextension 20647 "Salesperson/Purchaser Card BF" extends "Salesperson/Purchaser Card"
{
    layout
    {
        modify("Job Title")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Commission %")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Phone No.")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("E-Mail")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Next Task Date")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Privacy Blocked")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
    actions
    {
        modify("Con&tacts")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
}
