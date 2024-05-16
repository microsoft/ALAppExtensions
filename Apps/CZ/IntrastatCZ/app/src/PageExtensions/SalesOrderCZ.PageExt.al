// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Sales.Document;

pageextension 31400 "Sales Order CZ" extends "Sales Order"
{
    layout
    {
        addafter(IsIntrastatTransactionCZL)
        {
            field("Intrastat Exclude CZ"; Rec."Intrastat Exclude CZ")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Intrastat Exclude';
                ToolTip = 'Specifies that entry will be excluded from intrastat.';
            }
        }
    }
}