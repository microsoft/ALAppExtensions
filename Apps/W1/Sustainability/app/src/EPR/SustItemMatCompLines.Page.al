// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.EPR;

page 6264 "Sust. Item Mat. Comp. Lines"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DataCaptionFields = "Item Material Composition No.";
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SaveValues = true;
    SourceTable = "Sust. Item Mat. Comp. Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Material Type No."; Rec."Material Type No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Material Type No. field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Weight field.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Unit of Measure Code field.';
                }
                field("EPR Fee Rate"; Rec."EPR Fee Rate")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the EPR Fee Rate field.';
                }
                field("Collection Fee"; Rec."Collection Fee")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Collection Fee field.';
                }
                field("Sorting Fee"; Rec."Sorting Fee")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Sorting Fee field.';
                }
                field("Admin Fee"; Rec."Admin Fee")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Admin Fee field.';
                }
                field("Environ. Fee"; Rec."Environ. Fee")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Environ. Fee field.';
                }
            }
        }
    }
}