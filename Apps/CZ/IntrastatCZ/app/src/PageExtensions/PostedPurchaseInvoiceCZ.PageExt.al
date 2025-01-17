// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Purchases.History;

pageextension 31379 "Posted Purchase Invoice CZ" extends "Posted Purchase Invoice"
{
    layout
    {
        addafter("EU 3-Party Intermed. Role CZL")
        {
            field("Intrastat Exclude CZ"; Rec."Intrastat Exclude CZ")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Intrastat Exclude';
                Editable = false;
                ToolTip = 'Specifies that entry will be excluded from intrastat.';
            }
        }
    }
}