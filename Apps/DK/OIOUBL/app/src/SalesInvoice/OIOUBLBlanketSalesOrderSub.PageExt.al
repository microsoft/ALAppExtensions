// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

pageextension 13671 "OIOUBL-BlanketSalesOrderSub" extends "Blanket Sales Order Subform"
{
    layout
    {
        addafter("ShortcutDimCode[8]")
        {
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                ApplicationArea = Advanced;
                Tooltip = 'Specifies the account code of the customer. This is used in the exported electronic document.';
                Visible = False;
            }
        }
    }
}
