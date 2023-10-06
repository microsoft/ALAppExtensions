// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.CRM.Contact;

pageextension 20610 "Contact Alt. Address List BF" extends "Contact Alt. Address List"
{
    layout
    {
        modify("Company Name 2")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Address 2")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("City")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Post Code")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("County")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Country/Region Code")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Fax No.")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("E-Mail")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
}
