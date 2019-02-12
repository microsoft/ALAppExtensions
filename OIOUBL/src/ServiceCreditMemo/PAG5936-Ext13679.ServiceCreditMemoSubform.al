// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 13679 "OIOUBL-Service Credit Memo Sub" extends "Service Credit Memo Subform"
{
    layout
    {
        addafter("ShortcutDimCode[8]")
        {
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                ApplicationArea = Service;
                Visible = false;
                ToolTip = 'Specifies the account code of the customer.';
            }
        }
    }
}