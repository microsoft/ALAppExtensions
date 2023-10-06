// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Sales.Document;

pageextension 13691 "VATDK-Sales Order" extends "Sales Order"
{
    layout
    {
        modify("Transaction Specification") { Visible = false; }
        modify("Transport Method") { Visible = false; }
        modify("Exit Point") { Visible = false; }
        modify("Area") { Visible = false; }
    }
}
