// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 13685 "OIOUBL-Sales Return Order Sub" extends "Sales Return Order Subform"
{
    layout
    {
        addafter("Appl.-to Item Entry")
        {
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                Tooltip = 'Specifies the account code of the customer.';
                ApplicationArea = SalesReturnOrder;
                Visible = false;
            }
        }
    }
}