// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item.Substitution;

using Microsoft.Inventory.Item;

page 7411 "Item Subst. Suggestion Sub"
{
    Caption = 'Lines proposed by Copilot';
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "Item Substitution";
    SourceTableTemporary = true;
    SourceTableView = sorting(Score) order(descending);
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
                FreezeColumn = SubstituteNo;
                field(SubstituteType; Rec."Substitute Type")
                {
                    Editable = false;
                    ToolTip = 'Specifies Substitute Type';
                }
                field(SubstituteNo; Rec."Substitute No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies Substitute No.';
                }
                field(SubstituteVariantCode; Rec."Substitute Variant Code")
                {
                    ApplicationArea = Planning;
                    ShowMandatory = IsVariantCodeMandatory;
                    Visible = IsVariantCodeVisible;
                    ToolTip = 'Specifies the variant code of the suggested result.';

                    trigger OnValidate()
                    var
                        Item: Record Item;
                    begin
                        if Rec."Substitute Variant Code" = '' then
                            IsVariantCodeMandatory := Item.IsVariantMandatory(Rec."Substitute Type" = Rec."Substitute Type"::Item, Rec."Substitute No.");
                    end;
                }
                field("Description"; Rec."Description")
                {
                    ToolTip = 'Specifies the description of the suggested result.';
                }
                field(Score; Rec.Score)
                {
                    StyleExpr = StyleExprText;
                    Visible = AdditionalInformationVisible;
                    Editable = false;
                    ToolTip = 'Specifies the score of the suggested result.';
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
                }
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.Update();
    end;

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

        if IsVariantCodeVisible and (Rec."Substitute No." <> '') then
            IsVariantCodeMandatory := Item.IsVariantMandatory(Rec."Substitute Type" = Rec."Substitute Type"::Item, Rec."Substitute No.");
    end;

    internal procedure Load(Item: Record Item; var TempItemSubst: Record "Item Substitution" temporary; ViewOptions: Option "Lines only","Lines and Confidence")
    var
        TempItemSubstitForVariant: Record "Item Substitution" temporary;
    begin
        TempItemSubst.Reset();
        Rec.Copy(TempItemSubst, true);

        AdditionalInformationVisible := ViewOptions = ViewOptions::"Lines and Confidence";

        IsVariantCodeVisible := false;
        TempItemSubstitForVariant.Copy(TempItemSubst, true);
        TempItemSubstitForVariant.SetRange("Substitute Variant Code", '');
        if TempItemSubstitForVariant.FindSet() then
            repeat
                IsVariantCodeVisible := Item.IsVariantMandatory(TempItemSubstitForVariant."Substitute Type" = Rec."Substitute Type"::Item, TempItemSubstitForVariant."Substitute No.") or (TempItemSubst."Substitute Variant Code" <> ''); // If one of the items requires or has a variant code, then show the column
            until (TempItemSubstitForVariant.Next() = 0) or IsVariantCodeVisible;
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