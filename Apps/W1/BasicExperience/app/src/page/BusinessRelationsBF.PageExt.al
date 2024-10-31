// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.CRM.BusinessRelation;

pageextension 20608 "Business Relations BF" extends "Business Relations"
{
    layout
    {
        modify("No. of Contacts")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
    actions
    {
        modify("C&ontacts")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }

}
