// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document.Attachment;

using Microsoft.Sales.Document;
using System.Utilities;

page 7290 "Sales Line From Attachment"
{
    Caption = 'Suggest sales lines from file';
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
            label(AttachmentMappingLbl)
            {
                CaptionClass = GeneratedCaption;
                ApplicationArea = All;
            }
            part(AttachmentMappingPart; "Attachment Mapping Part")
            {
                Caption = 'Column Mapping';
                ApplicationArea = All;
            }
        }
        area(Content)
        {
            label(SuggestionStatusLbl)
            {
                CaptionClass = SuggestionStatusTxt;
                Style = Strong;
                ApplicationArea = All;
            }

            part(SalesLinesSub; "Sales Line AI Suggestions Sub")
            {
                Caption = 'Suggested sales lines';
                ShowFilter = false;
                ApplicationArea = All;
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
                begin
                    NotificationManager.RecallNotification();
                    GenerateSalesLineSuggestions();
                end;
            }
            systemaction(OK)
            {
                Caption = 'Insert';
                ToolTip = 'Keep sales line suggestions proposed by Copilot.';
            }
            systemaction(Cancel)
            {
                Caption = 'Discard';
                ToolTip = 'Discard sales line suggestions proposed by Copilot.';
            }
        }
    }

    trigger OnOpenPage()
    var
        ProgressDialog: Dialog;
    begin
        SearchStyle := Enum::"Search Style"::Balanced;
        GlobalTempBlob.CreateInStream(GlobalFileInstream, TextEncoding::UTF8);

        ProgressDialog.Open(FetchingSearchTermsProgressLbl);
        // LLM call or loading from cache to fetch the FileHandlerResult
        GlobalFileHandlerResult := GlobalFileHandler.Process(GlobalFileInstream);
        GlobalFileData := GlobalFileHandler.GetFileData(GlobalFileHandlerResult); // Read file data based on the FileHandlerResult
        CurrPage.AttachmentMappingPart.Page.LoadCSVAndGetProductInfo(GlobalFileData, GlobalFileHandlerResult);
        ProgressDialog.Close();

        SummarizePromptAndPageCaption();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        SalesLineUtility: Codeunit "Sales Line Utility";
        TotalCopiedLines: Integer;
    begin
        TotalCopiedLines := 0;
        if CloseAction = CloseAction::OK then begin
            TotalCopiedLines := TempGlobalSalesLineAISuggestion.Count();
            if TotalCopiedLines > 0 then
                SalesLineUtility.CopySalesLineToDoc(GlobalSalesHeader, TempGlobalSalesLineAISuggestion);
            // Save the mapping used for generating the sales lines
            GlobalFileHandler.Finalize(GlobalFileHandlerResult);
        end;
    end;

    local procedure GenerateSalesLineSuggestions()
    var
        SalesLinesSuggestionsImpl: Codeunit "Sales Lines Suggestions Impl.";
        NewProductInformationColumns: List of [Integer];
        NewQuantityColumn: Integer;
        NewUoMColumn: Integer;
        ProgressDialog: Dialog;
        SearchQuery: Text;
        NoOfDataLinesInFile: Integer;
    begin
        TempGlobalSalesLineAISuggestion.DeleteAll();
        Clear(TempGlobalSalesLineAISuggestion);
        if CurrPage.AttachmentMappingPart.Page.ColumnMappingHasChanged(NewProductInformationColumns, NewQuantityColumn, NewUoMColumn) then begin
            GlobalFileHandlerResult.SetProductColumnIndex(NewProductInformationColumns);
            GlobalFileHandlerResult.SetQuantityColumnIndex(NewQuantityColumn);
            GlobalFileHandlerResult.SetUoMColumnIndex(NewUoMColumn);
        end;
        if GlobalFileHandlerResult.GetContainsHeaderRow() then
            NoOfDataLinesInFile := GlobalFileData.Count() - 1
        else
            NoOfDataLinesInFile := GlobalFileData.Count();

        if GlobalFileHandlerResult.GetProductColumnIndex().Count = 0 then
            Error(ProdInfoColumnNotFoundErr);
        ProgressDialog.Open(FetchingSearchTermsProgressLbl);
        SearchQuery := BuildSearchQuery(GlobalFileData, GlobalFileHandlerResult);
        ProgressDialog.Close();
        ProgressDialog.Open(GeneratingSalesLinesProgressLbl);
        SalesLinesSuggestionsImpl.GenerateSalesLineSuggestions(SearchQuery, SearchStyle, GlobalSalesHeader, TempGlobalSalesLineAISuggestion);
        SuggestionStatusTxt := StrSubstNo(SuggestionStatusTok, TempGlobalSalesLineAISuggestion.Count(), NoOfDataLinesInFile);
        CurrPage.SalesLinesSub.Page.Load(TempGlobalSalesLineAISuggestion, ViewOptions);
        ProgressDialog.Close();
        SummarizePromptAndPageCaption();
    end;

    [NonDebuggable]
    local procedure BuildSearchQuery(FileData: List of [List of [Text]]; FileParserResult: Codeunit "File Handler Result"): Text
    var
        SLSPrompts: Codeunit "SLS Prompts";
        ProductInfoAsText: Text;
        HeaderRow: List of [Text];
        SearchQuery: Text;
        Rows: Text;
        StartIndex, Index1, Index2 : Integer;
    begin
        // Add header row
        if FileParserResult.GetContainsHeaderRow() then begin
            HeaderRow := FileData.Get(1);
            StartIndex := 2
        end else begin
            HeaderRow := FileParserResult.GetColumnNames();
            StartIndex := 1;
        end;

        // Add header row
        ProductInfoAsText := ProductInfoTok;
        if FileParserResult.GetQuantityColumnIndex() <> 0 then
            ProductInfoAsText := StrSubstNo('%1%2%3', ProductInfoAsText, FileParserResult.GetColumnDelimiter(), QuantityTok);
        if FileParserResult.GetUoMColumnIndex() <> 0 then
            ProductInfoAsText := StrSubstNo('%1%2%3', ProductInfoAsText, FileParserResult.GetColumnDelimiter(), UoMTok);

        // Add new line character
        ProductInfoAsText := StrSubstNo('%1%2', ProductInfoAsText, '\n');
        Rows := ProductInfoAsText;
        // Add data to the list
        Clear(ProductInfoAsText);
        for Index1 := StartIndex to FileData.Count() do begin
            Clear(ProductInfoAsText);
            foreach Index2 in FileParserResult.GetProductColumnIndex() do
                if ProductInfoAsText = '' then
                    ProductInfoAsText := FileData.Get(Index1).Get(Index2)
                else
                    ProductInfoAsText := StrSubstNo('%1 %2', ProductInfoAsText, FileData.Get(Index1).Get(Index2));

            if FileParserResult.GetQuantityColumnIndex() <> 0 then
                ProductInfoAsText := StrSubstNo('%1%2%3', ProductInfoAsText, FileParserResult.GetColumnDelimiter(), FileData.Get(Index1).Get(FileParserResult.GetQuantityColumnIndex()));

            if FileParserResult.GetUoMColumnIndex() <> 0 then
                ProductInfoAsText := StrSubstNo('%1%2%3', ProductInfoAsText, FileParserResult.GetColumnDelimiter(), FileData.Get(Index1).Get(FileParserResult.GetUoMColumnIndex()));
            ProductInfoAsText := StrSubstNo('%1%2', ProductInfoAsText, '\n');
            Rows += ProductInfoAsText;
            if StrLen(Rows) > SalesLineFromAttachment.GetMaxPromptSize() then
                Error(DataTooLargeErr);
        end;

        SearchQuery := StrSubstNo(SLSPrompts.GetProductFromCsvTemplateUserInputPrompt().Unwrap(), Rows);
        exit(SearchQuery);
    end;

    internal procedure LoadData(var FileHandler: interface "File Handler"; FileName: Text; var LoadedTempBlob: Codeunit "Temp Blob"; SalesHeader: Record "Sales Header")
    begin
        GlobalFileHandler := FileHandler;
        GlobalFileName := FileName;
        GlobalTempBlob := LoadedTempBlob;
        GlobalSalesHeader := SalesHeader;
    end;

    internal procedure SetPromptMode(NewMode: PromptMode)
    begin
        CurrPage.PromptMode := NewMode;
    end;

    local procedure SummarizePromptAndPageCaption()
    var
        ProductInfoColumnCaption: Text;
        QuantityColumnCaption: Text;
        UoMColumnCaption: Text;
        LoopIndex: Integer;
        TabLbl: Label '<TAB>', Comment = 'Tab character.', Locked = true;
        TabChar: Char;
    begin
        // GeneratedCaption will be of the format "Suggest sales lines from Sample.csv. Use ; as a column separator."
        TabChar := 9;
        GeneratedCaption := StrSubstNo(PromptPart1Lbl, GlobalFileName);
        if GlobalFileHandlerResult.GetColumnDelimiter() <> '' then
            if GlobalFileHandlerResult.GetColumnDelimiter() = TabChar then
                GeneratedCaption := GeneratedCaption + StrSubstNo(PromptPart2Lbl, TabLbl)
            else
                GeneratedCaption := GeneratedCaption + StrSubstNo(PromptPart2Lbl, GlobalFileHandlerResult.GetColumnDelimiter());

        PageCaptionTxt := GeneratedCaption;
        if GlobalFileHandlerResult.GetProductColumnIndex().Count > 0 then begin
            for LoopIndex := 1 to GlobalFileHandlerResult.GetProductColumnIndex().Count do
                if ProductInfoColumnCaption = '' then
                    ProductInfoColumnCaption := GlobalFileHandlerResult.GetColumnNames().Get(GlobalFileHandlerResult.GetProductColumnIndex().Get(LoopIndex))
                else
                    ProductInfoColumnCaption := StrSubstNo('%1, %2', ProductInfoColumnCaption, GlobalFileHandlerResult.GetColumnNames().Get(GlobalFileHandlerResult.GetProductColumnIndex().Get(LoopIndex)));
            // ProductInfoColumnCaption will be of the format "Product Information: Product Name, Product No."        
            ProductInfoColumnCaption := StrSubstNo(MappedInfoLbl, ProductInfoTok, ProductInfoColumnCaption);

            if not (GlobalFileHandlerResult.GetQuantityColumnIndex() in [0, -1]) then begin
                QuantityColumnCaption := StrSubstNo(MappedInfoLbl, QuantityTok, GlobalFileHandlerResult.GetColumnNames().Get(GlobalFileHandlerResult.GetQuantityColumnIndex()));
                // ProductInfoColumnCaption will be of the format "Product Information: Product Name, Product No. Quantity: Quantity"
                ProductInfoColumnCaption := StrSubstNo('%1 %2', ProductInfoColumnCaption, QuantityColumnCaption);
            end;

            if not (GlobalFileHandlerResult.GetUoMColumnIndex() in [0, -1]) then begin
                UoMColumnCaption := StrSubstNo(MappedInfoLbl, UoMTok, GlobalFileHandlerResult.GetColumnNames().Get(GlobalFileHandlerResult.GetUoMColumnIndex()));
                ProductInfoColumnCaption := StrSubstNo('%1 %2', ProductInfoColumnCaption, UoMColumnCaption);
            end;
            // ProductInfoColumnCaption will be of the format "Mapped columns Product Information: Product Name, Product No. Quantity: Quantity UoM: UoM"
            ProductInfoColumnCaption := StrSubstNo(AttachmentMappingLbl, ProductInfoColumnCaption);
            // PageCaptionTxt will be of the format "Suggest sales lines from Sample.csv. Use ; as a column separator. Mapped columns Product Information: Product Name, Product No. Quantity: Quantity UoM: UoM"
            PageCaptionTxt := StrSubstNo('%1 %2', PageCaptionTxt, ProductInfoColumnCaption);
        end;
    end;

    var
        TempGlobalSalesLineAISuggestion: Record "Sales Line AI Suggestions" temporary;
        GlobalSalesHeader: Record "Sales Header";
        GlobalFileHandlerResult: Codeunit "File Handler Result";
        GlobalTempBlob: Codeunit "Temp Blob";
        SalesLineFromAttachment: Codeunit "Sales Line From Attachment";
        GlobalFileHandler: interface "File Handler";
        PageCaptionTxt: Text;
        GlobalFileName: Text;
        GlobalFileInstream: Instream;
        GlobalFileData: List of [List of [Text]];
        FetchingSearchTermsProgressLbl: Label 'Fetching search terms from file...';
        GeneratingSalesLinesProgressLbl: Label 'Generating sales line suggestions from the search terms...';
        SuggestionStatusTok: Label '%1 suggestions were generated from %2 lines in the file.', Comment = '%1 = number of suggestions, %2 = number of lines in the file.';
        SuggestionStatusTxt: Text;
        SearchStyle: Enum "Search Style";
        ViewOptions: Option "Lines only","Lines and Confidence";
        GeneratedCaption: Text;
        PromptPart1Lbl: Label 'Suggest sales lines from data in %1. ', Comment = '%1 = file name.';
        PromptPart2Lbl: Label 'Use %1 as the column separator.', Comment = '%1 = column separator.';
        AttachmentMappingLbl: Label 'Mapped columns %1.', Comment = '%1 = all mapped column captions.';
        MappedInfoLbl: Label '%1: %2', Comment = '%1 = column caption, %2 = column value.';
        ProductInfoTok: Label 'Product Information';
        ProdInfoColumnNotFoundErr: Label 'Column with Product information not found in the input data.';
        DataTooLargeErr: Label 'Data is too large to process. Please reduce the number of rows in the file.';
        QuantityTok: Label 'Quantity';
        UoMTok: Label 'Unit of Measure';
}