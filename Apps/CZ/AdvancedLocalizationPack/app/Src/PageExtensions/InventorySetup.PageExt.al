// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Setup;

pageextension 31250 "Inventory Setup CZA" extends "Inventory Setup"
{
    layout
    {
        addlast(General)
        {
            field("Use GPPG from SKU CZA"; Rec."Use GPPG from SKU CZA")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the General Product Posting Group from the Stock keeping Unit is transferred to the documents.';
            }
            field("Skip Update SKU on Posting CZA"; Rec."Skip Update SKU on Posting CZA")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies skiping Update SKU on Posting';
            }
            field("Exact Cost Revers. Mandat. CZA"; Rec."Exact Cost Revers. Mandat. CZA")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies that a storno transaction cannot be posted unless the Applies-from Entry field on the item journal line specifies an entry.';
            }
            field("Def.G.Bus.P.Gr.-Dir.Trans. CZA"; Rec."Def.G.Bus.P.Gr.-Dir.Trans. CZA")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the default general business posting group for direct transfer.';
            }
        }
    }
}
