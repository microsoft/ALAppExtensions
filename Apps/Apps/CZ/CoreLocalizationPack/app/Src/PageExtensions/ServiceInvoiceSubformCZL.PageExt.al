// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Document;

pageextension 31005 "Service Invoice Subform CZL" extends "Service Invoice Subform"
{
    layout
    {
        addafter("Appl.-to Item Entry")
        {
            field("Tariff No. CZL"; Rec."Tariff No. CZL")
            {
                ApplicationArea = Service;
                ToolTip = 'Specifies a code for the item''s tariff number.';
                Visible = false;
            }
        }
    }
}
