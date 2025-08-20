// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

page 6258 "Sust. Posted ESG Report Sub."
{
    AutoSplitKey = true;
    Caption = 'Lines';
    Editable = false;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "Sust. Posted ESG Report Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Grouping; Rec.Grouping)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Grouping field.';
                }
                field("Row No."; Rec."Row No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a number that identifies the line.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the ESG reporting line.';
                }
                field("Reporting Code"; Rec."Reporting Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Reporting Code field.';
                }
                field("Field Type"; Rec."Field Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Field Type field.';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec."Field Type" = Rec."Field Type"::"Table Field";
                    ToolTip = 'Specifies the value of the Table No. field.';
                }
                field(Source; Rec.Source)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Source field.';
                }

                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec."Field Type" = Rec."Field Type"::"Table Field";
                    ToolTip = 'Specifies the value of the Field No. field.';
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Value field.';
                }
                field("Value Settings"; Rec."Value Settings")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Value Settings field.';
                }
                field("Account Filter"; Rec."Account Filter")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Account Filter field.';
                }
                field("Reporting Unit"; Rec."Reporting Unit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Reporting Unit field.';
                }
                field("Row Type"; Rec."Row Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Row Type field.';
                }
                field("Row Totaling"; Rec."Row Totaling")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Row Totaling field.';
                }
                field("Calculate with"; Rec."Calculate With")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Calculate with field.';
                }
                field(Show; Rec.Show)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Show field.';
                }
                field("Show with"; Rec."Show With")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Show with field.';
                }
                field(Rounding; Rec.Rounding)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Rounding field.';
                }
                field("Posted Amount"; Rec."Posted Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Posted Amount field.';
                }
            }
        }
    }
}