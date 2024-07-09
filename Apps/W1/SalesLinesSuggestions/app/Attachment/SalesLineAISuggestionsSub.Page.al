// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Inventory.Item;

page 7276 "Sales Line AI Suggestions Sub"
{
    Caption = 'Lines proposed by Copilot';
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "Sales Line AI Suggestions";
    SourceTableTemporary = true;
    DeleteAllowed = true;
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
                FreezeColumn = "No.";
                field("No."; Rec."No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the item number of the suggested result.';
                    StyleExpr = Rec."Line Style";
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    ShowMandatory = IsVariantCodeMandatory;
                    Visible = IsVariantCodeVisible;
                    ToolTip = 'Specifies the variant code of the suggested result.';
                    StyleExpr = Rec."Line Style";

                    trigger OnValidate()
                    var
                        Item: Record Item;
                    begin
                        if Rec."Variant Code" = '' then
                            IsVariantCodeMandatory := Item.IsVariantMandatory(Rec.Type = Rec.Type::Item, Rec."No.");
                    end;
                }
                field("Line No."; Rec."Line No.")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the line number of the suggested result.';
                    StyleExpr = Rec."Line Style";
                }
                field("Description"; Rec."Description")
                {
                    ToolTip = 'Specifies the description of the suggested result.';
                    StyleExpr = Rec."Line Style";
                }
                field("Quantity"; Rec.Quantity)
                {
                    ToolTip = 'Specifies the quantity of the suggested result.';
                    StyleExpr = Rec."Line Style";
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ToolTip = 'Specifies the unit of measure code of the suggested result.';
                    StyleExpr = Rec."Line Style";
                }
                field(Confidence; Rec.Confidence)
                {
                    StyleExpr = StyleExprText;
                    Visible = AdditionalInformationVisible;
                    Editable = false;
                    ToolTip = 'Specifies the confidence level of the suggested result.';
                }
                field("Search Terms"; SearchTerms)
                {
                    Editable = false;
                    Caption = 'Search Terms';
                    ToolTip = 'Specifies the search terms that were used to find the suggested results.';
                    Visible = AdditionalInformationVisible;
                    StyleExpr = Rec."Line Style";
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        Item: Record Item;
    begin
        Clear(StyleExprText);
        Clear(SearchTerms);
        IsVariantCodeMandatory := false;

        if AdditionalInformationVisible then begin
            if Rec.Confidence = Rec.Confidence::High then
                StyleExprText := 'Favorable';

            if Rec.Confidence = Rec.Confidence::Medium then
                StyleExprText := 'Ambiguous';

            if Rec.Confidence = Rec.Confidence::Low then
                StyleExprText := 'Unfavorable';

            SearchTerms := GetSearchTerms();
        end;

        if IsVariantCodeVisible and (Rec."No." <> '') then
            IsVariantCodeMandatory := Item.IsVariantMandatory(Rec.Type = Rec.Type::Item, Rec."No.");
    end;

    internal procedure Load(var TempSalesLineAISuggestion: Record "Sales Line AI Suggestions" temporary; ViewOptions: Option "Lines only","Lines and Confidence")
    var
        Item: Record Item;
        TempSalesLineAISuggestionForVariant: Record "Sales Line AI Suggestions" temporary;
    begin
        Rec.Copy(TempSalesLineAISuggestion, true);
        Rec.Reset();
        if Rec.Confidence = Rec.Confidence::None then
            AdditionalInformationVisible := false
        else
            AdditionalInformationVisible := ViewOptions = ViewOptions::"Lines and Confidence";

        IsVariantCodeVisible := false;
        TempSalesLineAISuggestionForVariant.Copy(TempSalesLineAISuggestion, true);
        TempSalesLineAISuggestionForVariant.SetRange("Variant Code", '');
        if TempSalesLineAISuggestionForVariant.FindSet() then
            repeat
                IsVariantCodeVisible := Item.IsVariantMandatory(TempSalesLineAISuggestionForVariant.Type = Rec.Type::Item, TempSalesLineAISuggestionForVariant."No.") or (TempSalesLineAISuggestion."Variant Code" <> ''); // If one of the items requires or has a variant code, then show the column
            until (TempSalesLineAISuggestionForVariant.Next() = 0) or IsVariantCodeVisible;
    end;

    local procedure GetSearchTerms(): Text
    var
        PrimarySearchTerms: Text;
        AdditionalSearchTerms: Text;
        CombinesSearchTerms: Text;
    begin
        PrimarySearchTerms := Rec.GetPrimarySearchTerms();
        AdditionalSearchTerms := Rec.GetAdditionalSearchTerms();
        CombinesSearchTerms := PrimarySearchTerms.Replace('|', ', ');
        if AdditionalSearchTerms <> '' then
            CombinesSearchTerms := CombinesSearchTerms + ', ' + AdditionalSearchTerms;
        exit(CombinesSearchTerms);
    end;

    var
        AdditionalInformationVisible: Boolean;
        IsVariantCodeMandatory: Boolean;
        IsVariantCodeVisible: Boolean;
        SearchTerms: Text;
        StyleExprText: Text;
}