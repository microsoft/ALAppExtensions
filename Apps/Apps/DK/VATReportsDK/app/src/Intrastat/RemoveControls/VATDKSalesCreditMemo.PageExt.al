// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Sales.Document;

pageextension 13693 "VATDK-Sales Credit Memo" extends "Sales Credit Memo"
{
    layout
    {
        modify("Transaction Specification") { Visible = false; }
        modify("Transport Method") { Visible = false; }
        modify("Exit Point") { Visible = false; }
        modify("Area") { Visible = false; }
    }
}
