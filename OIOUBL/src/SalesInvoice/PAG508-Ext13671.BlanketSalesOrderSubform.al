// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 13671 "OIOUBL-BlanketSalesOrderSub" extends "Blanket Sales Order Subform"
{
    layout
    {
        addafter("ShortcutDimCode[8]")
        {
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                ApplicationArea = Advanced;
                Tooltip = 'Specifies the account code of the customer.';
                Visible = False;
            }
        }
    }
}