// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.History;

pageextension 13683 "OIOUBL-Posted Serv Invoice Sub" extends "Posted Service Invoice Subform"
{
    layout
    {
        addafter("Shortcut Dimension 2 Code")
        {
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                Visible = false;
                ApplicationArea = Service;
                ToolTip = 'Specifies the account code of the customer. This is used in the exported electronic document.';
            }
        }
    }
}
