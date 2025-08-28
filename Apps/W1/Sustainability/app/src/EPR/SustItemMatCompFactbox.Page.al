// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.EPR;

page 6289 "Sust. Item Mat. Comp. Factbox"
{
    Caption = 'Material Composition';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    RefreshOnActivate = true;
    SourceTable = "Sust. Item Mat. Comp. Line";

    layout
    {
        area(content)
        {
            repeater(Control2)
            {
                field("Material Type No."; Rec."Material Type No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the Material Type No..';
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Weight.';
                }
            }
        }
    }
}