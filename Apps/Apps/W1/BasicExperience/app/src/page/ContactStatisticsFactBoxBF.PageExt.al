﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.CRM.Contact;

pageextension 20613 "Contact Statistics FactBox BF" extends "Contact Statistics FactBox"
{
    layout
    {
        modify("No. of Opportunities")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Calcd. Current Value (LCY)")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("No. of Job Responsibilities")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("No. of Industry Groups")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("No. of Business Relations")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("No. of Mailing Groups")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
}
