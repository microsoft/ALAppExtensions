// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Sales.History;
using Microsoft.Inventory.Item;
using Microsoft.Foundation.UOM;

codeunit 7286 SalesInvoiceLookup implements DocumentLookupSubType
{
    Access = Internal;

    var
        NoDocumentFound1Err: Label 'Copilot could not find the requested Posted Sales Invoice for %1. Please rephrase the description and try again.', Comment = '%1 = Customer Name';
        NoDocumentFound2Err: Label 'Copilot could not find the requested Posted Sales Invoice %1. Please rephrase the description and try again.', Comment = '%1 = Document No.';
        NoLinesFoundInTheDocumentErr: Label 'Copilot found the Posted Sales Invoice %1, but it does not have any relevant lines.', Comment = '%1 = Document No.';

    procedure SearchSalesDocument(CustomDimension: Dictionary of [Text, Text]; var TempSalesLineAiSuggestion: Record "Sales Line AI Suggestions" temporary)
    var
        SourceSalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DocumentLookup: Codeunit "Document Lookup Function";
        DocumentNo: Text;
        StartDateStr: Text;
        EndDateStr: Text;
        FoundDocNo: Code[20];
    begin
        DocumentLookup.GetParametersFromCustomDimension(CustomDimension, SourceSalesHeader, DocumentNo, StartDateStr, EndDateStr);
        SalesInvoiceHeader.SetLoadFields("No.");
        // setup SecurityFilter
        SalesInvoiceHeader.SetSecurityFilterOnRespCenter();
        FoundDocNo := SearchPossibleNo(DocumentNo);
        // Set up date range
        SetFilterOnDateForPostedSalesInvoiceHeader(StartDateStr, EndDateStr, SalesInvoiceHeader);
        if FoundDocNo <> '' then
            SalesInvoiceHeader.SetRange("No.", FoundDocNo)
        else
            SalesInvoiceHeader.SetRange("Sell-to Customer No.", SourceSalesHeader."Sell-to Customer No.");

        SalesInvoiceHeader.SetCurrentKey("Document Date");
        if SalesInvoiceHeader.FindLast() then
            FoundDocNo := SalesInvoiceHeader."No."
        else
            if FoundDocNo = '' then
                Error(NoDocumentFound1Err, SourceSalesHeader."Sell-to Customer Name")
            else
                Error(NoDocumentFound2Err, FoundDocNo);

        GetPostedSalesInvoiceLinesIntoTempTable(FoundDocNo, TempSalesLineAiSuggestion);
    end;

    local procedure SetFilterOnDateForPostedSalesInvoiceHeader(StartDateStr: Text; EndDateStr: Text; var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        StartDate: Date;
        EndDate: Date;
    begin
        // Set up date
        Evaluate(StartDate, StartDateStr);
        Evaluate(EndDate, EndDateStr);

        if (EndDate = 0D) then EndDate := dmy2date(31, 12, 9999);
        SalesInvoiceHeader.SetRange("Document Date", StartDate, EndDate);
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
            if SearchAmbiguousNo(DocumentNo, DocNoLen, Result) then
                exit(Result)
            else
                Error(NoDocumentFound2Err, DocumentNo);
    end;

    local procedure SearchAmbiguousNo(DocumentNo: Text; DocNoLen: Integer; var Result: Code[20]): Boolean
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if DocNoLen <= MaxStrLen(SalesInvoiceHeader."No.") then begin
            // 1. Check if it is document no 
            SalesInvoiceHeader.Reset();
            SalesInvoiceHeader.SetLoadFields("No.");
            SalesInvoiceHeader.SetFilter("No.", StrSubstNo('*%1*', DocumentNo));

            if (SalesInvoiceHeader.FindLast()) then begin
                Result := SalesInvoiceHeader."No.";
                exit(true);
            end;
        end;
        if DocNoLen <= MaxStrLen(SalesInvoiceHeader."External Document No.") then begin
            //2. Check if it is external document no
            SalesInvoiceHeader.Reset();
            SalesInvoiceHeader.SetLoadFields("No.");
            SalesInvoiceHeader.SetFilter("External Document No.", StrSubstNo('*%1*', DocumentNo));

            if (SalesInvoiceHeader.FindLast()) then begin
                Result := SalesInvoiceHeader."No.";
                exit(true);
            end;
        end;
        if DocNoLen <= MaxStrLen(SalesInvoiceHeader."Order No.") then begin
            //3. Check if it is order no
            SalesInvoiceHeader.Reset();
            SalesInvoiceHeader.SetLoadFields("No.");
            SalesInvoiceHeader.SetFilter("Order No.", StrSubstNo('*%1*', DocumentNo));

            if (SalesInvoiceHeader.FindLast()) then begin
                Result := SalesInvoiceHeader."No.";
                exit(true);
            end;
        end;
        if DocNoLen <= MaxStrLen(SalesInvoiceHeader."Quote No.") then begin
            //4. Check if it is quote no
            SalesInvoiceHeader.Reset();
            SalesInvoiceHeader.SetLoadFields("No.");
            SalesInvoiceHeader.SetFilter("Quote No.", StrSubstNo('*%1*', DocumentNo));

            if (SalesInvoiceHeader.FindLast()) then begin
                Result := SalesInvoiceHeader."No.";
                exit(true);
            end;
        end;
        if DocNoLen <= MaxStrLen(SalesInvoiceHeader."Your Reference") then begin
            //5. Check if it is reference no
            SalesInvoiceHeader.Reset();
            SalesInvoiceHeader.SetLoadFields("No.");
            SalesInvoiceHeader.SetFilter("Your Reference", StrSubstNo('*%1*', DocumentNo));

            if (SalesInvoiceHeader.FindLast()) then begin
                Result := SalesInvoiceHeader."No.";
                exit(true);
            end;
        end;
        exit(false);
    end;

    local procedure SearchPreciseNo(DocumentNo: Text; DocNoLen: Integer; var Result: Code[20]): Boolean
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if DocNoLen <= MaxStrLen(SalesInvoiceHeader."No.") then begin
            // 1. Check if it is document no 
            SalesInvoiceHeader.Reset();
            SalesInvoiceHeader.SetLoadFields("No.");
            SalesInvoiceHeader.SetRange("No.", DocumentNo);

            if (SalesInvoiceHeader.FindLast()) then begin
                Result := SalesInvoiceHeader."No.";
                exit(true);
            end;
        end;
        if DocNoLen <= MaxStrLen(SalesInvoiceHeader."External Document No.") then begin
            //2. Check if it is external document no
            SalesInvoiceHeader.Reset();
            SalesInvoiceHeader.SetLoadFields("No.");
            SalesInvoiceHeader.SetRange("External Document No.", DocumentNo);

            if (SalesInvoiceHeader.FindLast()) then begin
                Result := SalesInvoiceHeader."No.";
                exit(true);
            end;
        end;
        if DocNoLen <= MaxStrLen(SalesInvoiceHeader."Order No.") then begin
            //3. Check if it is order no
            SalesInvoiceHeader.Reset();
            SalesInvoiceHeader.SetLoadFields("No.");
            SalesInvoiceHeader.SetRange("Order No.", DocumentNo);

            if (SalesInvoiceHeader.FindLast()) then begin
                Result := SalesInvoiceHeader."No.";
                exit(true);
            end;
        end;
        if DocNoLen <= MaxStrLen(SalesInvoiceHeader."Quote No.") then begin
            //4. Check if it is quote no
            SalesInvoiceHeader.Reset();
            SalesInvoiceHeader.SetLoadFields("No.");
            SalesInvoiceHeader.SetRange("Quote No.", DocumentNo);

            if (SalesInvoiceHeader.FindLast()) then begin
                Result := SalesInvoiceHeader."No.";
                exit(true);
            end;
        end;
        if DocNoLen <= MaxStrLen(SalesInvoiceHeader."Your Reference") then begin
            //5. Check if it is reference no
            SalesInvoiceHeader.Reset();
            SalesInvoiceHeader.SetLoadFields("No.");
            SalesInvoiceHeader.SetRange("Your Reference", DocumentNo);

            if (SalesInvoiceHeader.FindLast()) then begin
                Result := SalesInvoiceHeader."No.";
                exit(true);
            end;
        end;
        exit(false);
    end;

    local procedure GetPostedSalesInvoiceLinesIntoTempTable(DocumentNo: Code[20]; var TempSalesLineAiSuggestion: Record "Sales Line AI Suggestions" temporary)
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        Item: Record Item;
        UoMMgt: Codeunit "Unit of Measure Management";
        LineNumber: Integer;
    begin
        if not TempSalesLineAiSuggestion.FindLast() then
            LineNumber := 0
        else
            LineNumber := TempSalesLineAiSuggestion."Line No.";

        Item.SetLoadFields("No.", "Sales Unit of Measure");
        SalesInvoiceLine.SetLoadFields("No.", "Description", "Type", "Quantity", "Quantity (Base)", "Unit of Measure Code", "Qty. per Unit of Measure", "Variant Code");
        SalesInvoiceLine.SetRange("Document No.", DocumentNo);
        SalesInvoiceLine.SetRange("Type", SalesInvoiceLine.Type::Item);
        if SalesInvoiceLine.FindSet() then begin
            repeat
                Item.SetRange("No.", SalesInvoiceLine."No.");
                Item.SetRange(Blocked, false);
                Item.SetRange("Sales Blocked", false);
                if Item.FindFirst() then begin
                    TempSalesLineAiSuggestion.Init();
                    LineNumber := LineNumber + 1;
                    TempSalesLineAiSuggestion."Line No." := LineNumber;
                    TempSalesLineAiSuggestion.Type := SalesInvoiceLine.Type;
                    TempSalesLineAiSuggestion."No." := SalesInvoiceLine."No.";
                    TempSalesLineAiSuggestion.Description := SalesInvoiceLine.Description;
                    TempSalesLineAiSuggestion."Variant Code" := SalesInvoiceLine."Variant Code";
                    if Item."Sales Unit of Measure" <> '' then
                        if SalesInvoiceLine."Unit of Measure Code" = Item."Sales Unit of Measure" then
                            TempSalesLineAiSuggestion.Quantity := SalesInvoiceLine.Quantity
                        else
                            TempSalesLineAiSuggestion.Quantity := UoMMgt.CalcQtyFromBase(SalesInvoiceLine."Quantity (Base)", UoMMgt.GetQtyPerUnitOfMeasure(Item, Item."Sales Unit of Measure"))
                    else
                        TempSalesLineAiSuggestion.Quantity := SalesInvoiceLine."Quantity (Base)";
                    TempSalesLineAiSuggestion.SetSourceDocument(SalesInvoiceLine.RecordId());
                    TempSalesLineAiSuggestion.Insert();
                end;
            until SalesInvoiceLine.Next() = 0;
            if TempSalesLineAiSuggestion.IsEmpty() then
                Error(NoLinesFoundInTheDocumentErr, DocumentNo);
        end
        else
            Error(NoLinesFoundInTheDocumentErr, DocumentNo);
    end;
}