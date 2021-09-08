// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This page shows the retention policy setup lines. Each line defines a subset of records in a table for which you can set a separate retention period.
/// </summary>
page 3902 "Retention Policy Setup Lines"
{
    PageType = ListPart;
    SourceTable = "Retention Policy Setup Line";
    DelayedInsert = true;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Table Filter Text"; Rec."Table Filter Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the filter in text format that defines a subset of records.';
                    Editable = false;
                    AssistEdit = true;
                    Style = Subordinate;
                    StyleExpr = Rec.Locked;

                    trigger OnAssistEdit()
                    begin
                        if not Rec.IsLocked() then
                            Rec.SetTableFilter();
                    end;
                }
                field("Retention Period"; Rec."Retention Period")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an identifier for the retention period.';
                    Editable = not Rec.Locked;
                    Style = Subordinate;
                    StyleExpr = Rec.Locked;
                    ShowMandatory = true;
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the retention policy is enabled for this subset.';
                    Editable = not Rec.Locked;
                    Style = Subordinate;
                    StyleExpr = Rec.Locked;
                }
                field(Locked; Rec.Locked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specified whether the retention policy is editable for this subset.';
                    Editable = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Locked;
                }
                field("Date Field No."; Rec."Date Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the date or datetime field on the table used to determine the age of a record.';
                    Importance = Additional;
                    Editable = not Rec.Locked;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Locked;
                    ShowMandatory = true;
                }
                field("Date Field Name"; Rec."Date Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the date or datetime field on the table used to determine the age of a record.';
                    Importance = Additional;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Locked;
                }
                field("Date Field Caption"; Rec."Date Field Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the caption of the date or datetime field on the table used to determine the age of a record. The caption is the translated name of the field.';
                    Importance = Additional;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Locked;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
    begin
        RetentionPolicySetup.Get(Rec."Table ID");
        Rec."Date Field No." := RetentionPolicySetup."Date Field No.";
    end;
}