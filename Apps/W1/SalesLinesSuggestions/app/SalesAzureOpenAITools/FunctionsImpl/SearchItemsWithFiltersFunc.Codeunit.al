// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using System.AI;
using System.Telemetry;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;
using System.Text;

codeunit 7291 "Search Items With Filters Func" implements "AOAI Function"
{
    Access = Internal;

    var
        SourceDocumentRecordId: RecordId;
        SearchQuery: Text;
        SearchStyle: Enum "Search Style";
        FunctionNameLbl: Label 'search_items_with_filters', Locked = true;
        SearchWithFiltersLbl: Label 'function_call: search_items_with_filters', Locked = true;
        SourceDocumentRecordIDLbl: Label 'SourceDocumentRecordID', Locked = true;

    [NonDebuggable]
    procedure GetPrompt(): JsonObject
    var
        UnitOfMeasure: Record "Unit of Measure";
        Prompt: Codeunit "SLS Prompts";
        PromptJson: JsonObject;
        UnitsOfMeasureText: Text;
    begin
        UnitsOfMeasureText := '';
        UnitOfMeasure.SetFilter(Description, '<>%1', '');
        if UnitOfMeasure.FindSet() then begin
            repeat
                UnitsOfMeasureText += '"' + UnitOfMeasure.Description + '",';
            until UnitOfMeasure.Next() = 0;
            UnitsOfMeasureText := UnitsOfMeasureText.TrimEnd(',');
        end;

        PromptJson.ReadFrom(StrSubstNo(Prompt.GetSLSSearchItemsWithFiltersPrompt().Unwrap(), UnitsOfMeasureText));
        exit(PromptJson);
    end;

    [NonDebuggable]
    procedure Execute(Arguments: JsonObject): Variant
    var
        TempSalesLineAiSuggestionFromDocLookup: Record "Sales Line AI Suggestions" temporary;
        TempSalesLineAiSuggestionFromItemSearch: Record "Sales Line AI Suggestions" temporary;
        TempSalesLineAiSuggestionFiltered: Record "Sales Line AI Suggestions" temporary;
        TempSalesLineEmpty: Record "Sales Line AI Suggestions" temporary;
        Item: Record Item;
        SalesLineAISuggestionImpl: Codeunit "Sales Lines Suggestions Impl.";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        NotificationManager: Codeunit "Notification Manager";
        SearchUtility: Codeunit "Search";
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        FeatureTelemetryCD: Dictionary of [Text, Text];
        DocLookupType: Enum "Document Lookup Types";
        DocumentLookupSubType: Interface DocumentLookupSubType;
        ItemsResults: JsonToken;
        ItemResultsArray: JsonArray;
        DocumentNo: Text;
        StartDateTxt: Text;
        EndDateTxt: Text;
        ItemNoFilter: Text;
        SearchIntentLbl: Label 'Add products to a sales order.', Locked = true;
        DocumentFound: Boolean;
    begin
        // Document lookup
        if Arguments.Get('results', ItemsResults) then begin
            ItemResultsArray := ItemsResults.AsArray();

            if ItemResultsArray.Count() > 1 then begin
                FeatureTelemetry.LogError('0000NG7', SalesLineAISuggestionImpl.GetFeatureName(), SearchWithFiltersLbl, 'Multiple documents found', '', FeatureTelemetryCD);
                NotificationManager.SendNotification(SalesLineAISuggestionImpl.GetCopyFromMultipleDocsMsg());
                exit(TempSalesLineEmpty);
            end;

            // Find document information from user input
            if GetDocumentFromUserInput(DocumentNo, StartDateTxt, EndDateTxt, DocLookupType, ItemResultsArray) then begin
                DocumentLookupSubType := DocLookupType;
                FeatureTelemetryCD.Add('Document Type', DocLookupType.Names().Get(DocLookupType.Ordinals.IndexOf(DocLookupType.AsInteger())));

                // Search for the sales document in the system
                if SearchSalesDocument(TempSalesLineAiSuggestionFromDocLookup, DocumentLookupSubType, Format(SourceDocumentRecordId), DocumentNo, StartDateTxt, EndDateTxt) then begin
                    FeatureTelemetry.LogUsage('0000N3I', SalesLineAISuggestionImpl.GetFeatureName(), SearchWithFiltersLbl, FeatureTelemetryCD);
                    if not TempSalesLineAiSuggestionFromDocLookup.IsEmpty() then
                        DocumentFound := true;
                end;
            end;

            if not DocumentFound then begin
                FeatureTelemetry.LogError('0000N3F', SalesLineAISuggestionImpl.GetFeatureName(), SearchWithFiltersLbl, 'Document lookup failed', GetLastErrorCallStack(), FeatureTelemetryCD);
                NotificationManager.SendNotification(GetLastErrorText());
                exit(TempSalesLineEmpty);
            end;
        end;

        // Item search
        if Arguments.Get('search_items', ItemsResults) then begin
            ItemResultsArray := ItemsResults.AsArray();
            if ItemResultsArray.Count() > 0 then begin
                FeatureTelemetry.LogUsage('0000N3J', SalesLineAISuggestionImpl.GetFeatureName(), SearchWithFiltersLbl + ': Item Search');

                // If document found, filter items based on the document
                if DocumentFound then begin
                    TempSalesLineAiSuggestionFromDocLookup.FindSet();
                    repeat
                        if Item.Get(TempSalesLineAiSuggestionFromDocLookup."No.") then
                            Item.Mark(true);
                    until TempSalesLineAiSuggestionFromDocLookup.Next() = 0;
                    Item.MarkedOnly(true);
                    ItemNoFilter := SelectionFilterManagement.GetSelectionFilterForItem(Item);
                end;

                if SearchUtility.SearchMultiple(ItemResultsArray, SearchStyle, SearchIntentLbl, SearchQuery, 1, 25, false, true, TempSalesLineAiSuggestionFromItemSearch, ItemNoFilter) then begin
                    if TempSalesLineAiSuggestionFromItemSearch.IsEmpty() then begin
                        FeatureTelemetry.LogError('0000N3G', SalesLineAISuggestionImpl.GetFeatureName(), SearchWithFiltersLbl, 'Item search returned no items.');
                        NotificationManager.SendNotification(SalesLineAISuggestionImpl.GetItemNotFoundMsg());
                        exit(TempSalesLineEmpty);
                    end;

                    // If document lookup returned results, find intersection of items from document and item search,
                    // otherwise return items from item search
                    if DocumentFound then begin
                        TempSalesLineAiSuggestionFromItemSearch.FindSet();
                        repeat
                            TempSalesLineAiSuggestionFromDocLookup.SetRange("No.", TempSalesLineAiSuggestionFromItemSearch."No.");
                            if TempSalesLineAiSuggestionFromDocLookup.FindSet() then
                                repeat
                                    TempSalesLineAiSuggestionFiltered.Init();
                                    TempSalesLineAiSuggestionFiltered.Copy(TempSalesLineAiSuggestionFromDocLookup);
                                    TempSalesLineAiSuggestionFiltered.Quantity := TempSalesLineAiSuggestionFromDocLookup.Quantity;
                                    TempSalesLineAiSuggestionFiltered.Insert();
                                until TempSalesLineAiSuggestionFromDocLookup.Next() = 0;
                        until TempSalesLineAiSuggestionFromItemSearch.Next() = 0;
                        TempSalesLineAiSuggestionFiltered.Reset();
                        FeatureTelemetry.LogUsage('0000N3K', SalesLineAISuggestionImpl.GetFeatureName(), SearchWithFiltersLbl + ': Item Search inside document returned items.');
                        exit(TempSalesLineAiSuggestionFiltered);
                    end else
                        exit(TempSalesLineAiSuggestionFromItemSearch);
                end
                else begin
                    FeatureTelemetry.LogError('0000N3H', SalesLineAISuggestionImpl.GetFeatureName(), SearchWithFiltersLbl, 'Item search failed.');
                    NotificationManager.SendNotification(SalesLineAISuggestionImpl.GetChatCompletionResponseErr());
                end;
            end;
        end;

        if DocumentFound then
            exit(TempSalesLineAiSuggestionFromDocLookup)
        else
            exit(TempSalesLineEmpty);
    end;

    procedure GetName(): Text
    begin
        exit(FunctionNameLbl);
    end;

    procedure SetSearchQuery(NewSearchQuery: Text)
    begin
        SearchQuery := NewSearchQuery;
    end;

    procedure SetSearchStyle(NewSearchStyle: Enum "Search Style")
    begin
        SearchStyle := NewSearchStyle;
    end;

    procedure SetSourceDocumentRecordId(NewSourceDocumentRecordId: RecordId)
    begin
        SourceDocumentRecordId := NewSourceDocumentRecordId;
    end;

    [TryFunction]
    local procedure SearchSalesDocument(var TempSalesLineAiSuggestion: Record "Sales Line AI Suggestions" temporary; var DocumentLookupSubType: Interface DocumentLookupSubType; SourceDocumentRecordIdText: Text; DocumentNo: Text; StartDateTxt: Text; EndDateTxt: Text)
    begin
        DocumentLookupSubType.SearchSalesDocument(AddParametersToCustomDimension(SourceDocumentRecordIdText, DocumentNo, StartDateTxt, EndDateTxt), TempSalesLineAiSuggestion);
    end;

    local procedure AddParametersToCustomDimension(SourceDocumentRecordIdText: Text; DocumentNo: Text; StartDateStr: Text; EndDateStr: Text): Dictionary of [Text, Text]
    var
        CustomDimension: Dictionary of [Text, Text];
    begin
        CustomDimension.Add(SourceDocumentRecordIDLbl, SourceDocumentRecordIdText);
        CustomDimension.Add('DocumentNo', DocumentNo);
        CustomDimension.Add('StartDateStr', StartDateStr);
        CustomDimension.Add('EndDateStr', EndDateStr);
        exit(CustomDimension);
    end;

    internal procedure GetParametersFromCustomDimension(CustomDimension: Dictionary of [Text, Text]; var SourceSalesHeader: Record "Sales Header"; var DocumentNo: Text; var StartDateStr: Text; var EndDateStr: Text)
    var
        SourceSalesHeaderRecId: RecordId;
        SourceDocumentRecIdTxt: Text;
    begin
        SourceDocumentRecIdTxt := CustomDimension.Get(SourceDocumentRecordIDLbl);
        if SourceDocumentRecIdTxt <> '' then begin
            SourceSalesHeader.SetLoadFields("No.", "Sell-to Customer No.", "Sell-to Customer Name");
            Evaluate(SourceSalesHeaderRecId, SourceDocumentRecIdTxt);
            if SourceSalesHeaderRecId.TableNo = Database::"Sales Header" then begin
                SourceSalesHeaderRecId.GetRecord().SetTable(SourceSalesHeader);
                SourceSalesHeader.Get(SourceSalesHeader."Document Type", SourceSalesHeader."No.");
            end;
        end;
        DocumentNo := CustomDimension.Get('DocumentNo');
        StartDateStr := CustomDimension.Get('StartDateStr');
        EndDateStr := CustomDimension.Get('EndDateStr');
    end;

    [TryFunction]
    local procedure GetDocumentFromUserInput(var DocumentNo: Text; var StartDate: Text; var EndDate: Text; var DocLookupSubType: Enum "Document Lookup Types"; ItemResultsArray: JsonArray)
    var
        SalesLineAISuggestionImpl: Codeunit "Sales Lines Suggestions Impl.";
        JsonItem: JsonToken;
        DocumentNoToken: JsonToken;
        DocumentTypeToken: JsonToken;
    begin
        if ItemResultsArray.Get(0, JsonItem) then
            if JsonItem.AsObject().Get('document_type', DocumentTypeToken) then begin
                case DocumentTypeToken.AsValue().AsText() of
                    'sales_order':
                        DocLookupSubType := DocLookupSubType::"Sales Order";
                    'sales_invoice':
                        DocLookupSubType := DocLookupSubType::"Posted Sales Invoice";
                    'sales_shipment':
                        DocLookupSubType := DocLookupSubType::"Posted Sales Shipment";
                    'sales_quote':
                        DocLookupSubType := DocLookupSubType::"Sales Quote";
                    'sales_blanket_order':
                        DocLookupSubType := DocLookupSubType::"Blanket Sales Order";
                    else
                        Error(SalesLineAISuggestionImpl.GetUnknownDocTypeMsg());
                end;

                if JsonItem.AsObject().Get('document_number', DocumentNoToken) then
                    DocumentNo := DocumentNoToken.AsValue().AsText();

                if JsonItem.AsObject().Get('start_date', DocumentTypeToken) then
                    StartDate := DocumentTypeToken.AsValue().AsText();

                if JsonItem.AsObject().Get('end_date', DocumentTypeToken) then
                    EndDate := DocumentTypeToken.AsValue().AsText();
            end else
                Error(SalesLineAISuggestionImpl.GetDocumentNotFoundMsg());
    end;
}