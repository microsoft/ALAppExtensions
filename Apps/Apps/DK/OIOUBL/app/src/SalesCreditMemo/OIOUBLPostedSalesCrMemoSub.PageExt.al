// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.History;

pageextension 13649 "OIOUBL-PostedSalesCrMemoSub" extends "Posted Sales Cr. Memo Subform"
{
    layout
    {
        addafter("Appl.-to Item Entry")
        {
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                Tooltip = 'Specifies the account code of the customer who you will send the credit memo to. This is used in the exported electronic document.';
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
        }
    }
}
