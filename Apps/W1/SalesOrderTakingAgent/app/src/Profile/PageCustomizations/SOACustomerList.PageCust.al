// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

using Microsoft.Sales.Customer;

pagecustomization "SOA Customer List" customizes "Customer List"
{
    ClearActions = true;
    ClearLayout = true;
    ClearViews = true;

    layout
    {
        modify("No.")
        {
            Visible = true;
            Editable = false;
        }
        modify(Name)
        {
            Visible = true;
        }
        modify("Name 2")
        {
            Visible = true;
        }
        modify(Blocked)
        {
            Visible = true;
            Editable = false;
        }
        modify("Country/Region Code")
        {
            Visible = true;
        }
        modify("Post Code")
        {
            Visible = true;
        }
        modify("Phone No.")
        {
            Visible = true;
        }
        modify("Gen. Bus. Posting Group")
        {
            Visible = true;
        }
        modify("VAT Bus. Posting Group")
        {
            Visible = true;
        }
        modify("Customer Posting Group")
        {
            Visible = true;
        }
        modify("Payment Terms Code")
        {
            Visible = true;
        }
        addafter(Name)
        {
            field("E-Mail"; Rec."E-Mail")
            {
                ApplicationArea = All;
                Caption = 'E-Mail';
            }
        }
    }

    actions
    {
        modify(ApplyTemplate)
        {
            Visible = true;
        }
        modify(ApplyTemplate_Promoted)
        {
            Visible = true;
        }
        modify(NewSalesQuote)
        {
            Visible = true;
        }
        modify(NewSalesQuote_Promoted)
        {
            Visible = true;
        }
        modify(Quotes)
        {
            Visible = true;
        }
    }
}