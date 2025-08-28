// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.EPR;

page 6261 "Sustainability EPR Materials"
{
    PageType = List;
    Caption = 'EPR Materials';
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Sustainability EPR Material";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Description field.';
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
                field("Effective Date"; Rec."Effective Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Effective Date field.';
                }
            }
        }
    }
}