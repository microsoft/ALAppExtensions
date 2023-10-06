// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Document;

pageextension 18466 "Subcon ProdOrder Line Ext" extends "Released Prod. Order Lines"
{
    layout
    {
        addafter("Cost Amount")
        {
            field("Subcontracting Order No."; Rec."Subcontracting Order No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the subcontracting order number.';
            }
            field("Subcontractor Code"; Rec."Subcontractor Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the subcontracting vendor number the order belongs to.';
            }
        }
    }
}
