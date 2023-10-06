// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Visualization;

/// <summary>
/// List page that contains settings that define the appearance of cues for the current user and page.
/// </summary>
page 9702 "Cue Setup End User"
{
    Caption = 'Cue Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    Permissions = TableData "Cue Setup" = rimd;
    SourceTable = "Cue Setup";
    SourceTableTemporary = true;
    ContextSensitiveHelpPage = 'admin-how-set-up-colored-indicator-on-cues';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    QuickEntry = false;
                    ToolTip = 'Specifies the name that is assigned to the Cue.';

                    trigger OnValidate()
                    begin
                        Rec.Personalized := true;
                    end;
                }
                field("Low Range Style"; Rec."Low Range Style")
                {
                    ApplicationArea = All;
                    StyleExpr = LowRangeStyleExpr;
                    ToolTip = 'Specifies the color of the indicator when the value of data in the Cue is less than the value that is specified by the Threshold 1 field.';

                    trigger OnValidate()
                    begin
                        LowRangeStyleExpr := CuesAndKPIsImpl.ConvertStyleToStyleText(Rec."Low Range Style");
                        Rec.Personalized := true;
                    end;
                }
                field("Threshold 1"; Rec."Threshold 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value in the Cue below which the indicator has the color that is specified by the Low Range Style field.';

                    trigger OnValidate()
                    begin
                        Rec.Personalized := true;
                    end;
                }
                field("Middle Range Style"; Rec."Middle Range Style")
                {
                    ApplicationArea = All;
                    StyleExpr = MiddleRangeStyleExpr;
                    ToolTip = 'Specifies the color of the indicator when the value of data in the Cue is greater than or equal to the value that is specified by the Threshold 1 field but less than or equal to the value that is specified by the Threshold 2 field.';

                    trigger OnValidate()
                    begin
                        MiddleRangeStyleExpr := CuesAndKPIsImpl.ConvertStyleToStyleText(Rec."Middle Range Style");
                        Rec.Personalized := true;
                    end;
                }
                field("Threshold 2"; Rec."Threshold 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value in the Cue above which the indicator has the color that is specified by the High Range Style field.';

                    trigger OnValidate()
                    begin
                        Rec.Personalized := true;
                    end;
                }
                field("High Range Style"; Rec."High Range Style")
                {
                    ApplicationArea = All;
                    StyleExpr = HighRangeStyleExpr;
                    ToolTip = 'Specifies the color of the indicator when the value in the Cue is greater than the value of the Threshold 2 field.';

                    trigger OnValidate()
                    begin
                        HighRangeStyleExpr := CuesAndKPIsImpl.ConvertStyleToStyleText(Rec."High Range Style");
                        Rec.Personalized := true;
                    end;
                }
                field(Personalized; Rec.Personalized)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the colored indicator settings for the Cue have been modified to differ from the company default settings. You also use this field to revert to the default settings.';

                    trigger OnValidate()
                    begin
                        CuesAndKPIsImpl.ValidatePersonalizedField(Rec);
                        UpdateThresholdStyles();
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

    trigger OnClosePage()
    begin
        CuesAndKPIsImpl.CopyTempCueSetupRecordsToTable(Rec);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        UpdateThresholdStyles();
    end;

    trigger OnOpenPage()
    begin
        CuesAndKPIsImpl.PopulateTempCueSetupRecords(Rec);
    end;

    var
        CuesAndKPIsImpl: Codeunit "Cues And KPIs Impl.";
        LowRangeStyleExpr: Text;
        MiddleRangeStyleExpr: Text;
        HighRangeStyleExpr: Text;

    local procedure UpdateThresholdStyles()
    begin
        LowRangeStyleExpr := CuesAndKPIsImpl.ConvertStyleToStyleText(Rec."Low Range Style");
        MiddleRangeStyleExpr := CuesAndKPIsImpl.ConvertStyleToStyleText(Rec."Middle Range Style");
        HighRangeStyleExpr := CuesAndKPIsImpl.ConvertStyleToStyleText(Rec."High Range Style");
    end;
}

