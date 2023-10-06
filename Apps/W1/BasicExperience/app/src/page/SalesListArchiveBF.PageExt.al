// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Archive;

pageextension 20644 "Sales List Archive BF" extends "Sales List Archive"
{
    layout
    {
        modify("Bill-to Contact No.")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
}