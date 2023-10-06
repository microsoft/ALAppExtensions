// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.CRM.Setup;

pageextension 20666 "Web Sources BF" extends "Web Sources"
{
    layout
    {
        modify(URL)
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
}
