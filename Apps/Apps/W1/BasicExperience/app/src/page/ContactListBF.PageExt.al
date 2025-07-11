// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.CRM.Contact;

pageextension 20612 "Contact List BF" extends "Contact List"
{
    actions
    {
        modify("Industry Groups")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Job Responsibilities")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
}
