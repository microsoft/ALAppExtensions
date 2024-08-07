// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using System.AI;
using System.Telemetry;
using Microsoft.Inventory.Item;
using System.Text;

codeunit 7283 "Document Lookup Function" implements "AOAI Function"
{
    Access = Internal;

    var
        SourceDocumentRecordId: RecordId;
        SearchQuery: Text;
        SearchStyle: Enum "Search Style";
        FunctionNameLbl: Label 'lookup_from_document', Locked = true;
        DocumentLookUpLbl: Label 'function_call: lookup_from_document', Locked = true;
        SourceDocumentRecordIDLbl: Label 'SourceDocumentRecordID', Locked = true;

    [NonDebuggable]
    procedure GetPrompt(): JsonObject
    var
        Prompt: Codeunit "SLS Prompts";
        PromptJson: JsonObject;
    begin
        PromptJson.ReadFrom(Prompt.GetSLSDocumentLookupPrompt().Unwrap());
        exit(PromptJson);
    end;

    [NonDebuggable]
    procedure Execute(Arguments: JsonObject): Variant
    var
        TempSalesLineAiSuggestionFromDocLookup: Record "Sales Line AI Suggestions" temporary;
        TempSalesLineAiSuggestionFromItemSearch: Record "Sales Line AI Suggestions" temporary;
        TempSalesLineAiSuggestionFiltered: Record "Sales Line AI Suggestions" temporary;
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
    begin
        if Arguments.Get('results', ItemsResults) then begin
            ItemResultsArray := ItemsResults.AsArray();

            if not GetDetailsFromUserQuery(DocumentNo, StartDateTxt, EndDateTxt, DocLookupType, ItemResultsArray) then begin
                FeatureTelemetry.LogError('0000MDX', SalesLineAISuggestionImpl.GetFeatureName(), DocumentLookUpLbl, 'Error in retrieving filters from user query', GetLastErrorCallStack());
                NotificationManager.SendNotification(GetLastErrorText());
                exit(TempSalesLineAiSuggestionFromDocLookup);
            end;

            DocumentLookupSubType := DocLookupType;
            FeatureTelemetryCD.Add('Document Type', DocLookupType.Names().Get(DocLookupType.Ordinals.IndexOf(DocLookupType.AsInteger())));

            if SearchSalesDocument(TempSalesLineAiSuggestionFromDocLookup, DocumentLookupSubType, Format(SourceDocumentRecordId), DocumentNo, StartDateTxt, EndDateTxt) then begin
                FeatureTelemetry.LogUsage('0000ME0', SalesLineAISuggestionImpl.GetFeatureName(), DocumentLookUpLbl, FeatureTelemetryCD);
                if TempSalesLineAiSuggestionFromDocLookup.Count = 0 then
                    NotificationManager.SendNotification(SalesLineAISuggestionImpl.GetNoSalesLinesSuggestionsMsg());
            end
            else begin
                FeatureTelemetry.LogError('0000MDZ', SalesLineAISuggestionImpl.GetFeatureName(), DocumentLookUpLbl, 'Document lookup resulted in an error', GetLastErrorCallStack(), FeatureTelemetryCD);
                NotificationManager.SendNotification(GetLastErrorText());
            end;
        end
        else begin
            FeatureTelemetry.LogError('0000MML', SalesLineAISuggestionImpl.GetFeatureName(), 'Process Document Lookup', 'results not found in tools object.');
            NotificationManager.SendNotification(SalesLineAISuggestionImpl.GetChatCompletionResponseErr());
        end;

        // Check to see if there is a need to do a item search as well
        if Arguments.Get('search_items', ItemsResults) then begin
            FeatureTelemetry.LogUsage('0000MVF', SalesLineAISuggestionImpl.GetFeatureName(), DocumentLookUpLbl + ' Item Search in document.');

            ItemResultsArray := ItemsResults.AsArray();

            if not TempSalesLineAiSuggestionFromDocLookup.IsEmpty() then begin
                if TempSalesLineAiSuggestionFromDocLookup.FindSet() then
                    repeat
                        if Item.Get(TempSalesLineAiSuggestionFromDocLookup."No.") then
                            Item.Mark(true);
                    until TempSalesLineAiSuggestionFromDocLookup.Next() = 0;
                Item.MarkedOnly(true);
                ItemNoFilter := SelectionFilterManagement.GetSelectionFilterForItem(Item);
            end;
            if SearchUtility.SearchMultiple(ItemResultsArray, SearchStyle, SearchIntentLbl, SearchQuery, 1, 25, false, true, TempSalesLineAiSuggestionFromItemSearch, ItemNoFilter) then begin
                if TempSalesLineAiSuggestionFromItemSearch.Count = 0 then begin
                    FeatureTelemetry.LogError('0000MVH', SalesLineAISuggestionImpl.GetFeatureName(), 'Process Document Lookup', 'Item search inside document returned no items.');
                    NotificationManager.SendNotification(SalesLineAISuggestionImpl.GetNoSalesLinesSuggestionsMsg());
                    exit(TempSalesLineAiSuggestionFromItemSearch);
                end;
                TempSalesLineAiSuggestionFromItemSearch.FindSet();
                repeat
                    TempSalesLineAiSuggestionFromDocLookup.SetRange("No.", TempSalesLineAiSuggestionFromItemSearch."No.");
                    if TempSalesLineAiSuggestionFromDocLookup.FindSet() then
                        repeat
                            TempSalesLineAiSuggestionFiltered.Init();
                            TempSalesLineAiSuggestionFiltered.Copy(TempSalesLineAiSuggestionFromDocLookup);
                            TempSalesLineAiSuggestionFiltered.Quantity := TempSalesLineAiSuggestionFromItemSearch.Quantity;
                            TempSalesLineAiSuggestionFiltered.Insert();
                        until TempSalesLineAiSuggestionFromDocLookup.Next() = 0;
                until TempSalesLineAiSuggestionFromItemSearch.Next() = 0;
                TempSalesLineAiSuggestionFiltered.Reset();
                FeatureTelemetry.LogUsage('0000MVG', SalesLineAISuggestionImpl.GetFeatureName(), 'Process Document Lookup' + ': Item Search inside document returned items.');
                exit(TempSalesLineAiSuggestionFiltered);
            end
            else begin
                FeatureTelemetry.LogError('0000MVE', SalesLineAISuggestionImpl.GetFeatureName(), 'Process Document Lookup', 'Item search inside document returned no items.');
                NotificationManager.SendNotification(SalesLineAISuggestionImpl.GetChatCompletionResponseErr());
            end;
        end;

        exit(TempSalesLineAiSuggestionFromDocLookup);
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
    local procedure GetDetailsFromUserQuery(var DocumentNo: Text; var StartDate: Text; var EndDate: Text; var DocLookupSubType: Enum "Document Lookup Types"; ItemResultsArray: JsonArray)
    var
        JsonItem: JsonToken;
        DocumentNoToken: JsonToken;
        DocumentTypeToken: JsonToken;
        UnknownDocTypeErr: Label 'Copilot does not support the specified document type. Please rephrase the description';
        NoDocumentFoundErr: Label 'Copilot could not find the document. Please rephrase the description';
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
                    else
                        Error(UnknownDocTypeErr);
                end;

                if JsonItem.AsObject().Get('document_no', DocumentNoToken) then
                    DocumentNo := DocumentNoToken.AsValue().AsText();

                if JsonItem.AsObject().Get('start_date', DocumentTypeToken) then
                    StartDate := DocumentTypeToken.AsValue().AsText();

                if JsonItem.AsObject().Get('end_date', DocumentTypeToken) then
                    EndDate := DocumentTypeToken.AsValue().AsText();
            end else
                Error(NoDocumentFoundErr);
    end;

}