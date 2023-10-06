// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Document;

pageextension 13677 "OIOUBL-Service Invoice Subform" extends "Service Invoice Subform"
{
    layout
    {
        addafter("ShortcutDimCode[8]")
        {
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                ApplicationArea = Service;
                Visible = false;
                ToolTip = 'Specifies the account code of the customer. This is used in the exported electronic document.';
            }
        }
    }
}
