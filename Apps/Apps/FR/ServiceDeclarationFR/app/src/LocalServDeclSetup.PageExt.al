// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

pageextension 10890 "Local Serv. Decl. Setup" extends "Service Declaration Setup"
{
    layout
    {
        modify("Enable VAT Registration No.")
        {
            Visible = false;
        }
        modify("Def. Customer/Vendor VAT No.")
        {
            Visible = true;
        }
        modify("Def. Private Person VAT No.")
        {
            Visible = true;
        }
    }
}
