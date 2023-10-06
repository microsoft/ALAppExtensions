// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Environment.Configuration;

using Microsoft.CRM.RoleCenters;


pageextension 20653 "Sales&Relationship Mgr Act BF" extends "Sales & Relationship Mgr. Act."
{
    layout
    {
        modify("Open Opportunities")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Opportunities Due in 7 Days")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Overdue Opportunities")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;

        }
        modify("Closed Opportunities")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Open Sales Quotes")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
}
