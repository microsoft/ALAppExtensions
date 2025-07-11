// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Purchases.History;

pageextension 31349 "Posted Purch. Credit Memo CZ" extends "Posted Purchase Credit Memo"
{
    layout
    {
        addlast("Foreign Trade CZL")
        {
            field("Intrastat Exclude CZ"; Rec."Intrastat Exclude CZ")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Intrastat Exclude';
                Editable = false;
                ToolTip = 'Specifies that entry will be excluded from intrastat.';
            }
            field("Physical Transfer CZ"; Rec."Physical Transfer CZ")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Physical Transfer';
                ToolTip = 'Specifies if there is physical transfer of the item.';
                Editable = false;
            }
        }
    }
}