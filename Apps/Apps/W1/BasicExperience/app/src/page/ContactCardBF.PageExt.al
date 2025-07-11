// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.CRM.Contact;

pageextension 20611 "Contact Card BF" extends "Contact Card"
{
    layout
    {
        modify("Salesperson Code")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
    actions
    {
        modify("Business Relations")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify(Statistics)
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
}
