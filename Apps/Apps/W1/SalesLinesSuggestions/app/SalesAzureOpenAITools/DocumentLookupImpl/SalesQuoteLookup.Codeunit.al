// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Inventory.Item;

codeunit 7288 SalesQuoteLookup implements DocumentLookupSubType
{
    Access = Internal;

    var
        NoDocumentFound1Err: Label 'Copilot could not find the requested Sales Quote for %1. Please rephrase the description and try again.', Comment = '%1 = Customer Name';
        NoDocumentFound2Err: Label 'Copilot could not find the requested Sales Quote %1. Please rephrase the description and try again.', Comment = '%1 = Document No.';
        NoLinesFoundInTheDocumentErr: Label 'Copilot found the Sales Quote %1, but it does not have any relevant lines.', Comment = '%1 = Document No.';

    procedure SearchSalesDocument(CustomDimension: Dictionary of [Text, Text]; var TempSalesLineAiSuggestion: Record "Sales Line AI Suggestions" temporary)
    var
        SourceSalesHeader: Record "Sales Header";
        SalesHeader: Record "Sales Header";
        SearchItemsWithFiltersFunc: Codeunit "Search Items With Filters Func";
        DocumentNo: Text;
        StartDateStr: Text;
        EndDateStr: Text;
        FoundDocNo: Code[20];
    begin
        SearchItemsWithFiltersFunc.GetParametersFromCustomDimension(CustomDimension, SourceSalesHeader, DocumentNo, StartDateStr, EndDateStr);
        SalesHeader.SetLoadFields("No.");
        // Setup SecurityFilter
        SalesHeader.SetSecurityFilterOnRespCenter();
        // Remove the filter on date from RespCenter
        SalesHeader.SetFilter("Date Filter", '');
        FoundDocNo := SearchPossibleNo(DocumentNo);
        // Set up date range
        SetFilterOnDateForSalesHeader(StartDateStr, EndDateStr, SalesHeader);
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        if FoundDocNo <> '' then
            SalesHeader.SetRange("No.", FoundDocNo)
        else begin
            SalesHeader.SetRange("Sell-to Customer No.", SourceSalesHeader."Sell-to Customer No.");
            if SourceSalesHeader."Document Type" = SalesHeader."Document Type"::Quote then
                SalesHeader.SetFilter("No.", '<>%1', SourceSalesHeader."No."); // Do not use the same document as the source document when document number is not specified
        end;

        SalesHeader.SetCurrentKey("Document Date");
        if SalesHeader.FindLast() then
            FoundDocNo := SalesHeader."No."
        else
            if FoundDocNo = '' then
                Error(NoDocumentFound1Err, SourceSalesHeader."Sell-to Customer Name")
            else
                Error(NoDocumentFound2Err, FoundDocNo);

        GetSalesLinesIntoTempTable(FoundDocNo, TempSalesLineAiSuggestion);
    end;

    local procedure SetFilterOnDateForSalesHeader(StartDateStr: Text; EndDateStr: Text; var SalesHeader: Record "Sales Header")
    var
        StartDate: Date;
        EndDate: Date;
    begin
        // Set up date
        Evaluate(StartDate, StartDateStr);
        Evaluate(EndDate, EndDateStr);

        if (EndDate = 0D) then EndDate := dmy2date(31, 12, 9999);
        SalesHeader.SetRange("Document Date", StartDate, EndDate);
    end;

    local procedure SearchPossibleNo(DocumentNo: Text): Code[20]
    var
        DocNoLen: Integer;
        Result: Code[20];
    begin
        if DocumentNo = '' then
            exit('');

        DocNoLen := StrLen(DocumentNo);
        if SearchPreciseNo(DocumentNo, DocNoLen, Result) then
            exit(Result)
        else
            if SearchAmbiguousNo(DocumentNo, Result) then
                exit(Result)
            else
                Error(NoDocumentFound2Err, DocumentNo);
    end;

    local procedure SearchAmbiguousNo(DocumentNo: Text; var Result: Code[20]): Boolean
    var
        SalesHeader: Record "Sales Header";
        DocumentNoFilter: Text;
    begin
        DocumentNoFilter := StrSubstNo('*%1*', DocumentNo);

        SalesHeader.SetLoadFields("No.");
        SalesHeader.SetRange("Document Type", "Sales Document Type"::Quote);
        SalesHeader.FilterGroup := -1;
        SalesHeader.SetFilter("No.", DocumentNoFilter);
        SalesHeader.SetFilter("External Document No.", DocumentNoFilter);
        SalesHeader.SetFilter("Quote No.", DocumentNoFilter);
        SalesHeader.SetFilter("Your Reference", DocumentNoFilter);
        if SalesHeader.FindLast() then begin
            Result := SalesHeader."No.";
            exit(true);
        end;
        exit(false);
    end;

    local procedure SearchPreciseNo(DocumentNo: Text; DocNoLen: Integer; var Result: Code[20]): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetLoadFields("No.");
        SalesHeader.SetRange("Document Type", "Sales Document Type"::Quote);
        SalesHeader.FilterGroup := -1;
        if DocNoLen <= MaxStrLen(SalesHeader."No.") then
            SalesHeader.SetRange("No.", DocumentNo);
        if DocNoLen <= MaxStrLen(SalesHeader."External Document No.") then
            SalesHeader.SetRange("External Document No.", DocumentNo);
        if DocNoLen <= MaxStrLen(SalesHeader."Quote No.") then
            SalesHeader.SetRange("Quote No.", DocumentNo);
        if DocNoLen <= MaxStrLen(SalesHeader."Your Reference") then
            SalesHeader.SetRange("Your Reference", DocumentNo);
        if SalesHeader.GetFilter("No.") + SalesHeader.GetFilter("External Document No.") + SalesHeader.GetFilter("Quote No.") + SalesHeader.GetFilter("Your Reference") <> '' then
            if SalesHeader.FindLast() then begin
                Result := SalesHeader."No.";
                exit(true);
            end;
        exit(false);
    end;

    local procedure GetSalesLinesIntoTempTable(DocumentNo: Code[20]; var TempSalesLineAiSuggestion: Record "Sales Line AI Suggestions" temporary)
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
        LineNumber: Integer;
    begin
        if not TempSalesLineAiSuggestion.FindLast() then
            LineNumber := 1
        else
            LineNumber := TempSalesLineAiSuggestion."Line No.";

        SalesLine.SetLoadFields("No.", "Description", "Type", "Quantity", "Quantity (Base)", "Unit of Measure Code", "Qty. per Unit of Measure", "Variant Code");
        SalesLine.SetRange("Document Type", Enum::"Sales Document Type"::Quote);
        SalesLine.SetRange("Document No.", DocumentNo);
        SalesLine.SetRange("Type", SalesLine.Type::Item);
        if SalesLine.FindSet() then begin
            repeat
                Item.SetRange("No.", SalesLine."No.");
                Item.SetRange(Blocked, false);
                Item.SetRange("Sales Blocked", false);
                if not Item.IsEmpty() then begin
                    TempSalesLineAiSuggestion.Init();
                    LineNumber := LineNumber + 1;
                    TempSalesLineAiSuggestion."Line No." := LineNumber;
                    TempSalesLineAiSuggestion.Type := SalesLine.Type;
                    TempSalesLineAiSuggestion."No." := SalesLine."No.";
                    TempSalesLineAiSuggestion.Description := SalesLine.Description;
                    TempSalesLineAiSuggestion."Variant Code" := SalesLine."Variant Code";
                    TempSalesLineAiSuggestion."Unit of Measure Code" := SalesLine."Unit of Measure Code";
                    TempSalesLineAiSuggestion.Quantity := SalesLine.Quantity;
                    TempSalesLineAiSuggestion.SetSourceDocument(SalesLine.RecordId());
                    TempSalesLineAiSuggestion.Insert();
                end;
            until SalesLine.Next() = 0;
            if TempSalesLineAiSuggestion.IsEmpty() then
                Error(NoLinesFoundInTheDocumentErr, DocumentNo);
        end
        else
            Error(NoLinesFoundInTheDocumentErr, DocumentNo);
    end;
}