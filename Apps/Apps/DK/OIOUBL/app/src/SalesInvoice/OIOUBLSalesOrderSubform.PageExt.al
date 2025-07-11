// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

pageextension 13667 "OIOUBL-Sales Order Subform" extends "Sales Order Subform"
{
    layout
    {
        addafter("Allow Item Charge Assignment")
        {
            field("OIOUBL-Amount Including VAT"; "Amount Including VAT")
            {
                Tooltip = 'Specifies the amount including VAT for the whole document. The field may be filled automatically. This is used in the exported electronic document.';
                Visible = false;
                ApplicationArea = Basic, Suite;
            }
        }

        addafter("Line No.")
        {
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                Tooltip = 'Specifies the account code of the customer. This is used in the exported electronic document.';
                Visible = false;
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
