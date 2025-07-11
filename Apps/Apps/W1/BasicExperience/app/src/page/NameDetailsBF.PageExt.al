// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.CRM.Contact;

pageextension 20628 "Name Details BF" extends "Name Details"
{
    actions
    {
        modify("&Salutations")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}