// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Inventory.Item;
using Microsoft.Sales.History;

codeunit 7289 SalesShipmentLookup implements DocumentLookupSubType
{
    Access = Internal;

    var
        NoDocumentFound1Err: Label 'Copilot could not find the requested Posted Sales Shipment for %1. Please rephrase the description and try again.', Comment = '%1 = Customer Name';
        NoDocumentFound2Err: Label 'Copilot could not find the requested Posted Sales Shipment %1. Please rephrase the description and try again.', Comment = '%1 = Document No.';
        NoLinesFoundInTheDocumentErr: Label 'Copilot found the Posted Sales Shipment %1, but it does not have any relevant lines.', Comment = '%1 = Document No.';

    procedure SearchSalesDocument(CustomDimension: Dictionary of [Text, Text]; var TempSalesLineAiSuggestion: Record "Sales Line AI Suggestions" temporary)
    var
        SourceSalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SearchItemsWithFiltersFunc: Codeunit "Search Items With Filters Func";
        DocumentNo: Text;
        StartDateStr: Text;
        EndDateStr: Text;
        FoundDocNo: Code[20];
    begin
        SearchItemsWithFiltersFunc.GetParametersFromCustomDimension(CustomDimension, SourceSalesHeader, DocumentNo, StartDateStr, EndDateStr);
        SalesShipmentHeader.SetLoadFields("No.");
        // setup SecurityFilter
        SalesShipmentHeader.SetSecurityFilterOnRespCenter();
        FoundDocNo := SearchPossibleNo(DocumentNo);
        // Set up date range
        SetFilterOnDateForPostedSalesShipmentHeader(StartDateStr, EndDateStr, SalesShipmentHeader);
        if FoundDocNo <> '' then
            SalesShipmentHeader.SetRange("No.", FoundDocNo)
        else
            SalesShipmentHeader.SetRange("Sell-to Customer No.", SourceSalesHeader."Sell-to Customer No.");

        SalesShipmentHeader.SetCurrentKey("Document Date");
        if SalesShipmentHeader.FindLast() then
            FoundDocNo := SalesShipmentHeader."No."
        else
            if FoundDocNo = '' then
                Error(NoDocumentFound1Err, SourceSalesHeader."Sell-to Customer Name")
            else
                Error(NoDocumentFound2Err, FoundDocNo);

        GetPostedSalesShipmentLinesIntoTempTable(FoundDocNo, TempSalesLineAiSuggestion);
    end;

    local procedure SetFilterOnDateForPostedSalesShipmentHeader(StartDateStr: Text; EndDateStr: Text; var SalesShipmentHeader: Record "Sales Shipment Header")
    var
        StartDate: Date;
        EndDate: Date;
    begin
        // Set up date
        Evaluate(StartDate, StartDateStr);
        Evaluate(EndDate, EndDateStr);

        if (EndDate = 0D) then EndDate := dmy2date(31, 12, 9999);
        SalesShipmentHeader.SetRange("Document Date", StartDate, EndDate);
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
        SalesShipmentHeader: Record "Sales Shipment Header";
        DocumentNoFilter: Text;
    begin
        DocumentNoFilter := StrSubstNo('*%1*', DocumentNo);

        SalesShipmentHeader.SetLoadFields("No.");
        SalesShipmentHeader.FilterGroup := -1;
        SalesShipmentHeader.SetFilter("No.", DocumentNoFilter);
        SalesShipmentHeader.SetFilter("External Document No.", DocumentNoFilter);
        SalesShipmentHeader.SetFilter("Order No.", DocumentNoFilter);
        SalesShipmentHeader.SetFilter("Quote No.", DocumentNoFilter);
        SalesShipmentHeader.SetFilter("Your Reference", DocumentNoFilter);
        if SalesShipmentHeader.FindLast() then begin
            Result := SalesShipmentHeader."No.";
            exit(true);
        end;
        exit(false);
    end;

    local procedure SearchPreciseNo(DocumentNo: Text; DocNoLen: Integer; var Result: Code[20]): Boolean
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
    begin
        SalesShipmentHeader.SetLoadFields("No.");
        SalesShipmentHeader.FilterGroup := -1;
        if DocNoLen <= MaxStrLen(SalesShipmentHeader."No.") then
            SalesShipmentHeader.SetRange("No.", DocumentNo);
        if DocNoLen <= MaxStrLen(SalesShipmentHeader."External Document No.") then
            SalesShipmentHeader.SetRange("External Document No.", DocumentNo);
        if DocNoLen <= MaxStrLen(SalesShipmentHeader."Order No.") then
            SalesShipmentHeader.SetRange("Order No.", DocumentNo);
        if DocNoLen <= MaxStrLen(SalesShipmentHeader."Quote No.") then
            SalesShipmentHeader.SetRange("Quote No.", DocumentNo);
        if DocNoLen <= MaxStrLen(SalesShipmentHeader."Your Reference") then
            SalesShipmentHeader.SetRange("Your Reference", DocumentNo);
        if SalesShipmentHeader.GetFilter("No.") + SalesShipmentHeader.GetFilter("External Document No.") + SalesShipmentHeader.GetFilter("Order No.") + SalesShipmentHeader.GetFilter("Quote No.") + SalesShipmentHeader.GetFilter("Your Reference") <> '' then
            if SalesShipmentHeader.FindLast() then begin
                Result := SalesShipmentHeader."No.";
                exit(true);
            end;
        exit(false);
    end;

    local procedure GetPostedSalesShipmentLinesIntoTempTable(DocumentNo: Code[20]; var TempSalesLineAiSuggestion: Record "Sales Line AI Suggestions" temporary)
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        Item: Record Item;
        LineNumber: Integer;
    begin
        if not TempSalesLineAiSuggestion.FindLast() then
            LineNumber := 1
        else
            LineNumber := TempSalesLineAiSuggestion."Line No.";

        SalesShipmentLine.SetLoadFields("No.", "Description", "Type", "Quantity", "Quantity (Base)", "Unit of Measure Code", "Qty. per Unit of Measure", "Variant Code");
        SalesShipmentLine.SetRange("Document No.", DocumentNo);
        SalesShipmentLine.SetRange("Type", SalesShipmentLine.Type::Item);
        if SalesShipmentLine.FindSet() then begin
            repeat
                Item.SetRange("No.", SalesShipmentLine."No.");
                Item.SetRange(Blocked, false);
                Item.SetRange("Sales Blocked", false);
                if not Item.IsEmpty() then begin
                    TempSalesLineAiSuggestion.Init();
                    LineNumber := LineNumber + 1;
                    TempSalesLineAiSuggestion."Line No." := LineNumber;
                    TempSalesLineAiSuggestion.Type := SalesShipmentLine.Type;
                    TempSalesLineAiSuggestion."No." := SalesShipmentLine."No.";
                    TempSalesLineAiSuggestion.Description := SalesShipmentLine.Description;
                    TempSalesLineAiSuggestion."Variant Code" := SalesShipmentLine."Variant Code";
                    TempSalesLineAiSuggestion."Unit of Measure Code" := SalesShipmentLine."Unit of Measure Code";
                    TempSalesLineAiSuggestion.Quantity := SalesShipmentLine.Quantity;
                    TempSalesLineAiSuggestion.SetSourceDocument(SalesShipmentLine.RecordId());
                    TempSalesLineAiSuggestion.Insert();
                end;
            until SalesShipmentLine.Next() = 0;
            if TempSalesLineAiSuggestion.IsEmpty() then
                Error(NoLinesFoundInTheDocumentErr, DocumentNo);
        end
        else
            Error(NoLinesFoundInTheDocumentErr, DocumentNo);
    end;
}