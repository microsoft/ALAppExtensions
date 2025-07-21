// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Inventory.Transfer;

pageextension 31377 "Posted Direct Transfer CZ" extends "Posted Direct Transfer"
{
    layout
    {
        addafter("Transfer-from")
        {
            group("Foreign Trade CZ")
            {
                Caption = 'Foreign Trade';

                field(IsIntrastatTransactionCZ; Rec.IsIntrastatTransactionCZ())
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
                    Editable = false;
                    ToolTip = 'Specifies that entry will be excluded from intrastat.';
                }
            }
        }
    }
}