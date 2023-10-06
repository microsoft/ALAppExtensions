// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Archive;

pageextension 20646 "Sales Order Archive BF" extends "Sales Order Archive"
{
    layout
    {
        modify("Sell-to Contact No.")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
}
