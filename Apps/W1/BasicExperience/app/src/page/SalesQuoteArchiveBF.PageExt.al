// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Environment.Configuration;

using Microsoft.Sales.Archive;

pageextension 20651 "Sales Quote Archive BF" extends "Sales Quote Archive"
{
    layout
    {
        modify("Bill-to Contact No.")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
}