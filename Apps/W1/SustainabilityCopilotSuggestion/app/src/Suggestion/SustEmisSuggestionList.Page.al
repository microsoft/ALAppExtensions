// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using System.Utilities;

page 6330 "Sust. Emis. Suggestion List"
{
    Caption = 'Lines proposed by Copilot';
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Sustain. Emission Suggestion";
    SourceTableTemporary = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    InherentPermissions = X;
    InherentEntitlements = X;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Line No."; Rec."Line No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Account No."; Rec."Account No.")
                {
                    Editable = false;
                    Visible = not ShowOnlyWarningDescription;
                }
                field("Account Category"; Rec."Account Category")
                {
                    Editable = false;
                    Visible = not ShowOnlyWarningDescription;
                }
                field(Description; Rec."Description")
                {
                    Visible = not ShowOnlyWarningDescription;
                    StyleExpr = StyleTxt;
                }
                field("Account Subcategory"; Rec."Account Subcategory")
                {
                    Editable = false;
                    Visible = not ShowOnlyWarningDescription;
                }
                field("Emission CO2"; Rec."Emission CO2")
                {
                    Style = Strong;
                    Editable = false;
                    Visible = not ShowOnlyWarningDescription;
                }
                field("Accept Emission Factor"; Rec."Accept Emission Factor")
                {
                    Editable = false;
                    Visible = not ShowOnlyWarningDescription;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    Visible = not ShowOnlyWarningDescription;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    Visible = not ShowOnlyWarningDescription;
                    trigger OnValidate()
                    begin
                        if not ConfirmMgt.GetResponse(StrSubstNo(ChangeValueQst, Rec.FieldCaption("Unit of Measure")), false) then
                            Error('');
                        IsPageUpdated := true;
                    end;
                }
                field("Fuel/Electricity"; Rec."Fuel/Electricity")
                {
                    Visible = not ShowOnlyWarningDescription;
                    trigger OnValidate()
                    begin
                        if not ConfirmMgt.GetResponse(StrSubstNo(ChangeValueQst, Rec.FieldCaption("Fuel/Electricity")), false) then
                            Error('');
                        IsPageUpdated := true;
                    end;
                }
                field(Distance; Rec.Distance)
                {
                    Visible = not ShowOnlyWarningDescription;
                    trigger OnValidate()
                    begin
                        if not ConfirmMgt.GetResponse(StrSubstNo(ChangeValueQst, Rec.FieldCaption(Distance)), false) then
                            Error('');
                        IsPageUpdated := true;
                    end;
                }
                field("Custom Amount"; Rec."Custom Amount")
                {
                    Visible = not ShowOnlyWarningDescription;
                    trigger OnValidate()
                    begin
                        if not ConfirmMgt.GetResponse(StrSubstNo(ChangeValueQst, Rec.FieldCaption("Custom Amount")), false) then
                            Error('');
                        IsPageUpdated := true;
                    end;
                }
                field("Installation Multiplier"; Rec."Installation Multiplier")
                {
                    Visible = not ShowOnlyWarningDescription;
                    trigger OnValidate()
                    begin
                        if not ConfirmMgt.GetResponse(StrSubstNo(ChangeValueQst, Rec.FieldCaption("Installation Multiplier")), false) then
                            Error('');
                        IsPageUpdated := true;
                    end;
                }
                field("Time Factor"; Rec."Time Factor")
                {
                    Visible = not ShowOnlyWarningDescription;
                    trigger OnValidate()
                    begin
                        if not ConfirmMgt.GetResponse(StrSubstNo(ChangeValueQst, Rec.FieldCaption("Time Factor")), false) then
                            Error('');
                        IsPageUpdated := true;
                    end;
                }
                field("No. of Warnings"; Rec."No. of Warnings")
                {
                    Editable = false;
                    Visible = not ShowOnlyWarningDescription;

                    trigger OnDrillDown()
                    var
                        SustainEmissionSuggestion: Record "Sustain. Emission Suggestion";
                        SustEmisSuggestionList: Page "Sust. Emis. Suggestion List";
                    begin
                        SustainEmissionSuggestion.Copy(Rec, true);
                        SustainEmissionSuggestion.SetRange("Line No.", Rec."Line No.");
                        SustEmisSuggestionList.SetWarningVisibility();
                        SustEmisSuggestionList.Load(SustainEmissionSuggestion);
                        SustEmisSuggestionList.SetTableView(SustainEmissionSuggestion);
                        SustEmisSuggestionList.RunModal();
                    end;
                }
                field("Warning Text"; Rec."Warning Text")
                {
                    Editable = false;
                    MultiLine = true;
                    Visible = ShowOnlyWarningDescription;
                }
            }
            group(Control30)
            {
                Caption = 'Emission Factor Calculation Explanation';
                field("Emission Calc. Explanation"; CalcExplanation)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    Editable = false;
                    MultiLine = true;
                    Visible = not ShowOnlyWarningDescription;
                    ToolTip = 'Specifies the explanation of the emission calculation';
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        IsPageUpdated := false;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CalcExplanation := Rec.GetFormulaText();
    end;

    trigger OnAfterGetRecord()
    begin
        StyleTxt := Rec.SetStyle();
    end;


    procedure SetWarningVisibility()
    begin
        ShowOnlyWarningDescription := true;
    end;

    procedure GetPageUpdated(): Boolean
    begin
        exit(IsPageUpdated);
    end;

    internal procedure Load(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion")
    begin
        Rec.Copy(SustainEmissionSuggestion, true);
        Rec.Reset();
    end;


    var
        ConfirmMgt: Codeunit "Confirm Management";
        CalcExplanation: Text;
        StyleTxt: Text;
        ShowOnlyWarningDescription: Boolean;
        IsPageUpdated: Boolean;
        ChangeValueQst: Label 'Are you sure you want to change the value of the field %1? The new value will be transferred to the journal if you keep this line and regenerate action will be executed automatically.', Comment = '%1 = Field name';
}