// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item.Substitution;

using System.Telemetry;
using Microsoft.Inventory.Item;

page 7410 "Item Subst. Suggestion"
{
    Caption = 'Item Substitution Suggestion';
    DataCaptionExpression = PageCaptionTxt;
    PageType = PromptDialog;
    PromptMode = Generate;
    IsPreview = true;
    Extensible = false;
    ApplicationArea = All;
    Editable = true;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Prompt)
        {
            field(SearchQueryTxt; SearchQueryTxt)
            {
                ApplicationArea = All;
                MultiLine = true;
                ShowCaption = false;
                ToolTip = 'Enter your search query here. You can use natural language to describe what you are looking for.';
                Caption = 'Item Description';
                InstructionalText = 'Adjust item description to suggest item substitutions';
            }
        }
        area(Content)
        {
            part(ItemSubstLinesSub; "Item Subst. Suggestion Sub")
            {
                Caption = 'Suggested item substitutions';
                ShowFilter = false;
                ApplicationArea = All;
                Editable = true;
                Enabled = true;
            }
        }
        area(PromptOptions)
        {
            field(MatchingStyle; SearchStyle)
            {
                Caption = 'Matching';
                ApplicationArea = All;
                ToolTip = 'Specifies the search confidence to use when suggesting item substitutions.';
            }
            field(ViewOptions; ViewOptions)
            {
                Caption = 'View';
                ApplicationArea = All;
                ToolTip = 'Specifies whether to show lines or lines and confidence about the item substitution suggestions when possible.';
                OptionCaption = 'Lines only, Lines and Confidence';
            }
        }
    }

    actions
    {
        area(SystemActions)
        {
            systemaction(Generate)
            {
                Caption = 'Generate';
                ToolTip = 'Generate item substitution suggestions from Copilot.';

                trigger OnAction()
                var
                    NotificationManager: Codeunit "Notification Manager";
                    MaxSearchQueryLength: Decimal;
                    SearchQueryLengthExceededErr: Label 'You''ve exceeded the maximum number of allowed characters by %1. Please rephrase and try again.', Comment = '%1 = Integer';
                    SearchQueryNotProvidedErr: Label 'Please provide a query to generate item substitution suggestions.';
                begin
                    NotificationManager.RecallNotification();

                    MaxSearchQueryLength := 10000;
                    if StrLen(SearchQueryTxt) > MaxSearchQueryLength then
                        Error(SearchQueryLengthExceededErr, Format(StrLen(SearchQueryTxt) - MaxSearchQueryLength, 0));

                    if SearchQueryTxt.Trim() = '' then
                        Error(SearchQueryNotProvidedErr);

                    GenerateItemSubstitutions(SearchQueryTxt, SearchStyle, MainItemType);
                end;

            }
            systemaction(OK)
            {
                Caption = 'Insert';
                ToolTip = 'Keep item substitution suggestions proposed by Copilot.';
                Enabled = IsInsertEnabled;
            }
            systemaction(Cancel)
            {
                Caption = 'Discard';
                ToolTip = 'Discard item substitution suggestions proposed by Copilot.';
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ItemSubstSuggestUtility: Codeunit "Create Product Info. Utility";
        ItemSubstSuggestionImpl: Codeunit "Item Subst. Suggestion Impl.";
    begin
        TotalCopiedLines := 0;
        if CloseAction = CloseAction::OK then begin
            TotalCopiedLines := TempItemSubst.Count();
            if TotalCopiedLines > 0 then begin
                ItemSubstSuggestUtility.CopyItemSubstLines(Item, TempItemSubst);
                FeatureTelemetry.LogUptake('0000N2P', ItemSubstSuggestionImpl.GetFeatureName(), Enum::"Feature Uptake Status"::Used);
            end;
        end;

        // TotalCopiedLines will be zero in case none of the lines were inserted.
        // We don't want to log telemetry in case the user did not generate any suggestions.
        if Durations.Count() > 0 then
            FeatureTelemetry.LogUsage('0000N2Q', ItemSubstSuggestionImpl.GetFeatureName(), 'Statistics', GetFeatureTelemetryCustomDimensions());
    end;

    trigger OnOpenPage()
    begin
        SearchStyle := SearchStyle::Balanced;
        ViewOptions := ViewOptions::"Lines only";
    end;

    procedure SetItem(Item2: Record Item)
    begin
        Item := Item2;
        MainItemType := Item.Type;
        SearchQueryTxt := Item.Description;
    end;

    procedure GenerateItemSubstitutions(SearchQuery: Text; CurrSearchStyle: Enum "Search Style"; ItemType: Enum "Item Type")
    var
        ItemSubstitution: Record "Item Substitution";
        ItemSubstSuggestionImpl: Codeunit "Item Subst. Suggestion Impl.";
        StartDateTime: DateTime;
        ItemNoFilter: Text;
        CRLF: Text[2];
    begin
        ItemNoFilter := '<>' + Item."No.";

        ItemSubstitution.SetRange(Type, ItemSubstitution.Type::Item);
        ItemSubstitution.SetRange("No.", Item."No.");
        ItemSubstitution.SetRange("Substitute Type", ItemSubstitution."Substitute Type"::Item);
        if ItemSubstitution.FindSet() then
            repeat
                ItemNoFilter += '&<>' + ItemSubstitution."Substitute No.";
            until ItemSubstitution.Next() = 0;

        TempItemSubst.DeleteAll();
        Clear(TempItemSubst);
        StartDateTime := CurrentDateTime();
        ItemSubstSuggestionImpl.GenerateItemSubstitutionSuggestions(SearchQuery, CurrSearchStyle, ItemType, ItemNoFilter, TempItemSubst);
        Durations.Add(CurrentDateTime() - StartDateTime);
        TotalSuggestedLines.Add(TempItemSubst.Count());
        CRLF[1] := 13; // Carriage return, '\r'
        CRLF[2] := 10; // Line feed, '\n'
        PageCaptionTxt := SearchQuery.Replace(CRLF[1], ' ').Replace(CRLF[2], ' ');
        CurrPage.ItemSubstLinesSub.Page.Load(Item, TempItemSubst, ViewOptions);
        SetPageControls();
    end;

    local procedure SetPageControls()
    begin
        IsInsertEnabled := TempItemSubst.Count() > 0;
    end;

    local procedure GetFeatureTelemetryCustomDimensions() CustomDimension: Dictionary of [Text, Text]
    begin
        CustomDimension.Add('Durations', ConvertListOfDurationToString(Durations));
        CustomDimension.Add('TotalSuggestedLines', ConvertListOfIntegerToString(TotalSuggestedLines));
        CustomDimension.Add('TotalCopiedLines', Format(TotalCopiedLines));
    end;

    local procedure ConvertListOfDurationToString(ListOfDuration: List of [Duration]) Result: Text
    var
        Dur: Duration;
        DurationAsBigInt: BigInteger;
    begin
        foreach Dur in ListOfDuration do begin
            DurationAsBigInt := Dur;
            Result += Format(DurationAsBigInt) + ', ';
        end;
        Result := Result.TrimEnd(', ');
    end;

    local procedure ConvertListOfIntegerToString(ListOfInteger: List of [Integer]) Result: Text
    var
        Int: Integer;
    begin
        foreach Int in ListOfInteger do
            Result += Format(Int) + ', ';
        Result := Result.TrimEnd(', ');
    end;

    var
        Item: Record Item;
        TempItemSubst: Record "Item Substitution" temporary;
        SearchQueryTxt: Text;
        MainItemType: Enum "Item Type";
        SearchStyle: Enum "Search Style";
        ViewOptions: Option "Lines only","Lines and Confidence";
        PageCaptionTxt: Text;
        Durations: List of [Duration]; // Generate action can be triggered multiple times
        TotalSuggestedLines: List of [Integer]; // Generate action can be triggered multiple times
        TotalCopiedLines: Integer; // Lines can be inserted once
        IsInsertEnabled: Boolean;
}