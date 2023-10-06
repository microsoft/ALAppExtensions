// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Environment.Configuration;

using Microsoft.CRM.Team;

pageextension 20649 "Salesperson Statistics BF" extends "Salesperson Statistics"
{
    layout
    {
        modify("No. of Interactions")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Cost (LCY)")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify(AvgCostPerResp)
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Duration (Min.)")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify(AvgDurationPerResp)
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
}
