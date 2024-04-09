// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using System.Telemetry;

codeunit 7283 "Document Lookup Function" implements SalesAzureOpenAITools
{
    Access = Internal;

    var
        DocumentLookUpLbl: Label 'function_call: lookup_from_document', Locked = true;
        SourceDocumentRecordIDLbl: Label 'SourceDocumentRecordID', Locked = true;

    [NonDebuggable]
    procedure GetToolPrompt(): JsonObject
    var
        Prompt: Codeunit "SLS Prompts";
        PromptJson: JsonObject;
    begin
        PromptJson.ReadFrom(Prompt.GetSLSDocumentLookupPrompt());
        exit(PromptJson);
    end;

    [NonDebuggable]
    procedure ToolCall(Arguments: JsonObject; CustomDimension: Dictionary of [Text, Text]): Variant
    var
        TempSalesLineAiSuggestion: Record "Sales Line AI Suggestions" temporary;
        SalesLineAISuggestionImpl: Codeunit "Sales Lines Suggestions Impl.";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        NotificationManager: Codeunit "Notification Manager";
        FeatureTelemetryCD: Dictionary of [Text, Text];
        DocLookupType: Enum "Document Lookup Types";
        DocumentLookupSubType: Interface DocumentLookupSubType;
        ItemResults: JsonToken;
        ItemResultsArray: JsonArray;
        DocumentNo: Text;
        StartDateTxt: Text;
        EndDateTxt: Text;
        SourceDocumentRecIdTxt: Text;
        SearchQuery: Text;
    begin
        if Arguments.Get('results', ItemResults) then begin
            ItemResultsArray := ItemResults.AsArray();

            if not GetDetailsFromUserQuery(DocumentNo, StartDateTxt, EndDateTxt, DocLookupType, ItemResultsArray) then begin
                FeatureTelemetry.LogError('0000MDX', SalesLineAISuggestionImpl.GetFeatureName(), DocumentLookUpLbl, 'Error in retrieving filters from user query', GetLastErrorCallStack());
                NotificationManager.SendNotification(GetLastErrorText());
                exit(TempSalesLineAiSuggestion);
            end;

            CustomDimension.Get(SourceDocumentRecordIDLbl, SourceDocumentRecIdTxt);
            CustomDimension.Get('SearchQuery', SearchQuery);

            DocumentLookupSubType := DocLookupType;
            FeatureTelemetryCD.Add('Document Type', DocLookupType.Names().Get(DocLookupType.Ordinals.IndexOf(DocLookupType.AsInteger())));

            if SearchSalesDocument(TempSalesLineAiSuggestion, DocumentLookupSubType, SourceDocumentRecIdTxt, DocumentNo, StartDateTxt, EndDateTxt) then begin
                FeatureTelemetry.LogUsage('0000ME0', SalesLineAISuggestionImpl.GetFeatureName(), DocumentLookUpLbl, FeatureTelemetryCD);
                if TempSalesLineAiSuggestion.Count = 0 then
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
        exit(TempSalesLineAiSuggestion);
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