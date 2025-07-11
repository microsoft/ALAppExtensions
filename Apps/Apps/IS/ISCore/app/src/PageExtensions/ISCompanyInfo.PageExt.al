// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Company;

pageextension 14608 "IS Company Info" extends "Company Information"
{
    layout
    {
        modify("EORI Number")
        {
            Visible = false;
        }
        modify("Payment Routing No.")
        {
            Visible = false;
        }
        modify("Giro No.")
        {
            Visible = false;
        }
        movebefore("VAT Registration No."; "Registration No.")
    }
}