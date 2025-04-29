// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Purchases.Document;

pageextension 31397 "Purchase Quote CZ" extends "Purchase Quote"
{
    layout
    {
        addlast("Foreign Trade")
        {
            field(IsIntrastatTransactionCZ; Rec.IsIntrastatTransaction())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Intrastat Transaction';
                Editable = false;
                ToolTip = 'Specifies if the entry is an Intrastat transaction.';
            }
            field("Intrastat Exclude CZ"; Rec."Intrastat Exclude CZ")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Intrastat Exclude';
                ToolTip = 'Specifies that entry will be excluded from intrastat.';
            }
        }
    }
}