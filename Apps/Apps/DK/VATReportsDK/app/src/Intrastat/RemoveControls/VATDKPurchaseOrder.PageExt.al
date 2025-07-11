﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Document;

pageextension 13695 "VATDK-Purchase Order" extends "Purchase Order"
{
    layout
    {
        modify("Transaction Specification") { Visible = false; }
        modify("Transport Method") { Visible = false; }
        modify("Entry Point") { Visible = false; }
        modify("Area") { Visible = false; }
    }
}
