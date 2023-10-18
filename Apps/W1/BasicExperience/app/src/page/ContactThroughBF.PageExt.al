// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.CRM.Contact;

pageextension 20614 "Contact Through BF" extends "Contact Through"
{
    layout
    {
        modify(Number)
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("E-Mail")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
}
