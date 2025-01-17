﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Sales.History;

pageextension 13647 "OIOUBL-Posted Sales Inv Sub" extends "Posted Sales Invoice Subform"
{
    layout
    {
        addafter("Shortcut Dimension 2 Code")
        {
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                Tooltip = 'Specifies the account code of the customer who you will send the invoice to. This is used in the exported electronic document.';
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
        }
    }
}
