// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using System.Telemetry;
using Microsoft.Sales.Document.Attachment;

page 7275 "Sales Line AI Suggestions"
{
    Caption = 'Suggest Sales Lines';
    DataCaptionExpression = PageCaptionTxt;
    PageType = PromptDialog;
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
                Caption = 'Search Query';
                InstructionalText = 'Describe items and quantities or refer to existing documents to copy from';
            }
        }

        area(Content)
        {
            fixed("Fixed Controls")
            {
                ShowCaption = false;
                group(StatusLineGroup)
                {
                    ShowCaption = false;
                    Visible = ShowStatusLine;
                    Editable = false;

                    field("Status Line"; StatusLine)
                    {
                        ShowCaption = false;
                        Editable = false;

                        trigger OnDrillDown()
                        begin
                            TempSalesLineAISuggestion.ShowSourceHeaderDocument();
                        end;
                    }
                }
            }
            part(SalesLinesSub; "Sales Line AI Suggestions Sub")
            {
                Caption = 'Suggested sales lines';
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
                ToolTip = 'Specifies the search confidence to use when generating sales line suggestions.';
                trigger OnValidate()
                begin
                    if SearchStyle = SearchStyle::Permissive then
                        ViewOptions := ViewOptions::"Lines and Confidence";
                end;
            }
            field(ViewOptions; ViewOptions)
            {
                Caption = 'View';
                ApplicationArea = All;
                ToolTip = 'Specifies whether to show lines or lines and confidence about the sales line suggestions when possible.';
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
                ToolTip = 'Generate sales line suggestions from Copilot.';

                trigger OnAction()
                var
                    NotificationManager: Codeunit "Notification Manager";
                    MaxSearchQueryLength: Decimal;
                begin
                    NotificationManager.RecallNotification();

                    MaxSearchQueryLength := 10000;
                    if StrLen(SearchQueryTxt) > MaxSearchQueryLength then
                        Error(SearchQueryLengthExceededErr, Format(StrLen(SearchQueryTxt) - MaxSearchQueryLength, 0));

                    if SearchQueryTxt.Trim() = '' then
                        Error(SearchQueryNotProvidedErr);

                    GenerateSalesLineSuggestions(SearchQueryTxt, SearchStyle);
                end;
            }
            systemaction(OK)
            {
                Caption = 'Insert';
                ToolTip = 'Keep sales line suggestions proposed by Copilot.';
                Enabled = IsInsertEnabled;
            }
            systemaction(Cancel)
            {
                Caption = 'Discard';
                ToolTip = 'Discard sales line suggestions proposed by Copilot.';
            }
            systemaction(Attach)
            {
                Caption = 'Attach';
                ToolTip = 'Attach a file to get sales line suggestions from Copilot.';

                trigger OnAction()
                var
                    SalesLineFromAttachment: Codeunit "Sales Line From Attachment";
                begin
                    CurrPage.Close();
                    SalesLineFromAttachment.AttachAndSuggest(GlobalSalesHeader, PromptMode::Prompt);
                end;
            }
        }
        area(PromptGuide)
        {

            group(CopyFromOrderPrompts)
            {
                Caption = 'Copy line items';
#pragma warning disable AW0005
                action(DocumentSearchCopyFromOrderPrompt)
                {
#pragma warning restore AW0005

                    Caption = 'Copy from order [No.]';
                    ToolTip = 'Sample prompt for copying line items from another sales order. Text in brackets refers to the order.';

                    trigger OnAction()
                    var
                        CopyFromLbl: Label 'Copy from sales order ';
                    begin
                        SearchQueryTxt := CopyFromLbl;
                        CurrPage.Update(false);
                    end;
                }
#pragma warning disable AW0005
                action(DocumentSearchCopyFromInvoicePrompt)
                {
#pragma warning restore AW0005

                    Caption = 'Copy from posted invoice [No.]';
                    ToolTip = 'Sample prompt for copying line items from a posted sales invoice. Text in brackets refers to the invoice.';

                    trigger OnAction()
                    var
                        CopyFromLbl: Label 'Copy from sales invoice ';
                    begin
                        SearchQueryTxt := CopyFromLbl;
                        CurrPage.Update(false);
                    end;
                }
#pragma warning disable AW0005
                action(DocumentSearchCopyFromLastInvoicePrompt)
                {
#pragma warning restore AW0005
                    Caption = 'Copy from the last posted invoice';
                    ToolTip = 'Sample prompt for copying line items from the customer''s latest posted sales invoice.';

                    trigger OnAction()
                    var
                        CopyFromLbl: Label 'Copy from the last sales invoice';
                    begin
                        SearchQueryTxt := CopyFromLbl;
                        CurrPage.Update(false);
                    end;
                }
#pragma warning disable AW0005
                action(CopyItemsFromDocumentPrompt)
#pragma warning restore AW0005
                {
                    Caption = 'Copy items [description] from posted invoice [No.]';
                    ToolTip = 'Sample prompt for copying specific items from another posted sales invoice. Texts in brackets specify item description and invoice number.';

                    trigger OnAction()
                    var
                        CopyFromLbl: Label 'Copy specific items from sales invoice ';
                    begin
                        SearchQueryTxt := CopyFromLbl;
                        CurrPage.Update(false);
                    end;
                }
            }

            group(AddLinesPrompts)
            {
                Caption = 'Add line items';
#pragma warning disable AW0005
                action(ItemSearchAddItemDescPrompt)
                {
#pragma warning restore AW0005
                    Caption = 'Add item: [description]';
                    ToolTip = 'Sample prompt for adding a line item by description. Text in brackets describes the item to add.';

                    trigger OnAction()
                    var
                        AddItemsLbl: Label 'Add item: ';
                    begin
                        SearchQueryTxt := AddItemsLbl;
                        CurrPage.Update(false);
                    end;
                }
#pragma warning disable AW0005
                action(ItemSearchAddItemNoPrompt2)
                {
#pragma warning restore AW0005
                    Caption = 'Add item: [internal/external no.]';
                    ToolTip = 'Sample prompt for adding a line item by item no. Text in brackets specifies the item to add.';

                    trigger OnAction()
                    var
                        AddItemsLbl: Label 'Add item: ';
                    begin
                        SearchQueryTxt := AddItemsLbl;
                        CurrPage.Update(false);
                    end;
                }
#pragma warning disable AW0005
                action(ItemSearchAddItemQtyDescPrompt)
                {
#pragma warning restore AW0005
                    Caption = 'Add item: [quantity] [description]';
                    ToolTip = 'Sample prompt for adding a line item by quantity and description. Text in brackets describes the quantity and item to add.';
                    trigger OnAction()
                    var
                        AddItemsLbl: Label 'Add item: ';
                    begin
                        SearchQueryTxt := AddItemsLbl;
                        CurrPage.Update(false);
                    end;
                }
#pragma warning disable AW0005
                action(ItemSearchAddItemDescriptionPrompt)
                {
#pragma warning restore AW0005
                    Caption = 'Add items: [description 1, description 2, ...]';
                    ToolTip = 'Sample prompt for adding multiple line items. Text in brackets describes the items, separated by comma.';
                    trigger OnAction()
                    var
                        AddItemsLbl: Label 'Add item: ';
                    begin
                        SearchQueryTxt := AddItemsLbl;
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    var
        SearchQueryLengthExceededErr: Label 'You''ve exceeded the maximum number of allowed characters by %1. Please rephrase and try again.', Comment = '%1 = Integer';
        SearchQueryNotProvidedErr: Label 'Please provide a query to generate sales lines suggestions.';

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        SalesLineUtility: Codeunit "Sales Line Utility";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SalesLineAISuggestionImpl: Codeunit "Sales Lines Suggestions Impl.";
    begin
        TotalCopiedLines := 0;
        if CloseAction = CloseAction::OK then begin
            TotalCopiedLines := TempSalesLineAISuggestion.Count();
            if TotalCopiedLines > 0 then begin
                SalesLineUtility.CopySalesLineToDoc(GlobalSalesHeader, TempSalesLineAISuggestion);
                if CheckIfSuggestedLinesContainErrors() then begin
                    CurrPage.Update(false);
                    exit(false);
                end;
                FeatureTelemetry.LogUptake('0000ME4', SalesLineAISuggestionImpl.GetFeatureName(), Enum::"Feature Uptake Status"::Used);
            end;
        end;

        // TotalCopiedLines will be zero in case none of the lines were inserted.
        // We don't want to log telemetry in case the user did not generate any suggestions.
        if Durations.Count() > 0 then
            FeatureTelemetry.LogUsage('0000ME5', SalesLineAISuggestionImpl.GetFeatureName(), 'Statistics', GetFeatureTelemetryCustomDimensions());
    end;

    trigger OnOpenPage()
    begin
        SearchStyle := SearchStyle::Balanced;
    end;

    local procedure GenerateSalesLineSuggestions(SearchQuery: Text; CurrSearchStyle: Enum "Search Style")
    var
        SalesLineAISuggestionImpl: Codeunit "Sales Lines Suggestions Impl.";
        StartDateTime: DateTime;
        CRLF: Text[2];
    begin
        TempSalesLineAISuggestion.DeleteAll();
        Clear(TempSalesLineAISuggestion);
        StartDateTime := CurrentDateTime();
        SalesLineAISuggestionImpl.GenerateSalesLineSuggestions(SearchQuery, CurrSearchStyle, GlobalSalesHeader, TempSalesLineAISuggestion);
        Durations.Add(CurrentDateTime() - StartDateTime);
        TotalSuggestedLines.Add(TempSalesLineAISuggestion.Count());
        CRLF[1] := 13; // Carriage return, '\r'
        CRLF[2] := 10; // Line feed, '\n'
        PageCaptionTxt := SearchQuery.Replace(CRLF[1], ' ').Replace(CRLF[2], ' ');
        CurrPage.SalesLinesSub.Page.Load(TempSalesLineAISuggestion, ViewOptions);
        SetPageControls();
    end;

    local procedure SetPageControls()
    begin
        IsInsertEnabled := TempSalesLineAISuggestion.Count() > 0;
        SetStatusLine();
    end;

    procedure SetSalesHeader(OriginSalesHeader: Record "Sales Header")
    begin
        GlobalSalesHeader := OriginSalesHeader;
    end;

    local procedure SetStatusLine()
    var
        DocumentType: Text;
        DocumentNo: Text;
        DocumentDate: Date;
        CustomerName: Text;
        StatusLineDocSearchTxt: Label '%1 %2', Comment = '%1 = Document Type, %2 = Document No.';
        StatusLineFromCustomerTxt: Label 'for %1', Comment = '%1 = Customer Name, example: 1) Sales Order 1234 for Adatum 2) Sales Order 1234 for Adatum from 31/01/2021';
        StatusLineDocWithDocDateTxt: Label 'from %1', Comment = '%1 = Document Date, example: 1) Sales Order 1234 from 31/01/2021 2) Sales Order 1234 for Adatum from 31/01/2021';
    begin
        if TempSalesLineAISuggestion."Source Line Record ID".TableNo <> 0 then begin
            TempSalesLineAISuggestion.GetSourceDocumentInfo(DocumentType, DocumentNo, DocumentDate, CustomerName);

            if DocumentNo <> '' then begin
                StatusLine := StrSubstNo(StatusLineDocSearchTxt, DocumentType, DocumentNo);
                if CustomerName <> '' then
                    StatusLine += ' ' + StrSubstNo(StatusLineFromCustomerTxt, CustomerName);
                if DocumentDate > 0D then
                    StatusLine += ' ' + StrSubstNo(StatusLineDocWithDocDateTxt, DocumentDate);
                ShowStatusLine := true;
            end
            else begin
                StatusLine := '';
                ShowStatusLine := false;
            end;
        end
        else begin
            StatusLine := '';
            ShowStatusLine := false;
        end;
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

    local procedure CheckIfSuggestedLinesContainErrors(): Boolean
    var
        TempSalesLineSuggestion: Record "Sales Line AI Suggestions" temporary;
    begin
        TempSalesLineSuggestion.Copy(TempSalesLineAISuggestion, true);
        TempSalesLineSuggestion.Reset();
        TempSalesLineSuggestion.SetRange("Line Style", 'Unfavorable');
        if not TempSalesLineSuggestion.IsEmpty() then
            exit(true);
    end;

    var
        TempSalesLineAISuggestion: Record "Sales Line AI Suggestions" temporary;
        GlobalSalesHeader: Record "Sales Header";
        SearchQueryTxt: Text;
        SearchStyle: Enum "Search Style";
        ViewOptions: Option "Lines only","Lines and Confidence";
        PageCaptionTxt: Text;
        StatusLine: Text;
        ShowStatusLine: Boolean;
        Durations: List of [Duration]; // Generate action can be triggered multiple times
        TotalSuggestedLines: List of [Integer]; // Generate action can be triggered multiple times
        TotalCopiedLines: Integer; // Lines can be inserted once
        IsInsertEnabled: Boolean;
}