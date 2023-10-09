// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Visualization;

using System.Security.User;

/// <summary>
/// List page that contains settings that define the appearance of cues on all pages.
/// Administrators can use this page to define a general style, which users can customize from the Cue Setup End User page.
/// </summary>
page 9701 "Cue Setup Administrator"
{
    ApplicationArea = All;
    Caption = 'Cue Setup';
    PageType = List;
    Permissions = TableData "Cue Setup" = rimd;
    SourceTable = "Cue Setup";
    UsageCategory = Administration;
    ContextSensitiveHelpPage = 'admin-how-set-up-colored-indicator-on-cues';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User Name"; Rec."User Name")
                {
                    ApplicationArea = All;
                    LookupPageID = "User Lookup";
                    ToolTip = 'Specifies which Business Central user the indicator setup for the Cue pertains to. If you leave this field blank, then the indicator setup will pertain to all users.';
                }
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the Business Central table that contains the Cue.';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    QuickEntry = false;
                    ToolTip = 'Specifies the name of the table that contains the field that defines the Cue.';
                }
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                    NotBlank = true;
                    ToolTip = 'Specifies the ID that is assigned the Cue.';
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    QuickEntry = false;
                    ToolTip = 'Specifies the name that is assigned to the Cue.';
                }
                field("Low Range Style"; Rec."Low Range Style")
                {
                    ApplicationArea = All;
                    StyleExpr = LowRangeStyleExpr;
                    ToolTip = 'Specifies the color of the indicator when the value of data in the Cue is less than the value that is specified by the Threshold 1 field.';

                    trigger OnValidate()
                    var
                        CuesAndKPIsImpl: Codeunit "Cues And KPIs Impl.";
                    begin
                        LowRangeStyleExpr := CuesAndKPIsImpl.ConvertStyleToStyleText(Rec."Low Range Style");
                    end;
                }
                field("Threshold 1"; Rec."Threshold 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value in the Cue below which the indicator has the color that is specified by the Low Range Style field.';
                }
                field("Middle Range Style"; Rec."Middle Range Style")
                {
                    ApplicationArea = All;
                    StyleExpr = MiddleRangeStyleExpr;
                    ToolTip = 'Specifies the color of the indicator when the value of data in the Cue is greater than or equal to the value that is specified by the Threshold 1 field but less than or equal to the value that is specified by the Threshold 2 field.';

                    trigger OnValidate()
                    var
                        CuesAndKPIsImpl: Codeunit "Cues And KPIs Impl.";
                    begin
                        MiddleRangeStyleExpr := CuesAndKPIsImpl.ConvertStyleToStyleText(Rec."Middle Range Style");
                    end;
                }
                field("Threshold 2"; Rec."Threshold 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value in the Cue above which the indicator has the color that is specified by the High Range Style field.';
                }
                field("High Range Style"; Rec."High Range Style")
                {
                    ApplicationArea = All;
                    StyleExpr = HighRangeStyleExpr;
                    ToolTip = 'Specifies the color of the indicator when the value in the Cue is greater than the value of the Threshold 2 field.';

                    trigger OnValidate()
                    var
                        CuesAndKPIsImpl: Codeunit "Cues And KPIs Impl.";
                    begin
                        HighRangeStyleExpr := CuesAndKPIsImpl.ConvertStyleToStyleText(Rec."High Range Style");
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        UpdateThresholdStyles();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        UpdateThresholdStyles();
    end;

    var
        LowRangeStyleExpr: Text;
        MiddleRangeStyleExpr: Text;
        HighRangeStyleExpr: Text;

    local procedure UpdateThresholdStyles()
    var
        CuesAndKPIsImpl: Codeunit "Cues And KPIs Impl.";
    begin
        LowRangeStyleExpr := CuesAndKPIsImpl.ConvertStyleToStyleText(Rec."Low Range Style");
        MiddleRangeStyleExpr := CuesAndKPIsImpl.ConvertStyleToStyleText(Rec."Middle Range Style");
        HighRangeStyleExpr := CuesAndKPIsImpl.ConvertStyleToStyleText(Rec."High Range Style");
    end;
}

