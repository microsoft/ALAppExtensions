// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 13692 "VATDK-Sales Invoice" extends "Sales Invoice"
{
    layout
    {
        modify("Transaction Specification") { Visible = false; }
        modify("Transport Method") { Visible = false; }
        modify("Exit Point") { Visible = false; }
        modify("Area") { Visible = false; }
    }
}