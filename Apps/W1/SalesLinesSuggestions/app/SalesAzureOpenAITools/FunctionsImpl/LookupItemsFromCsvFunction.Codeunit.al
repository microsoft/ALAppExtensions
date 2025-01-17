// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document.Attachment;

using System.AI;
using Microsoft.Sales.Document;

codeunit 7296 "Lookup Items From Csv Function" implements "AOAI Function"
{
    Access = Internal;

    var
        FunctionNameLbl: Label 'extract_information_from_csv', Locked = true;

    [NonDebuggable]
    procedure GetPrompt(): JsonObject
    var
        Prompt: Codeunit "SLS Prompts";
        PromptJson: JsonObject;
    begin
        PromptJson.ReadFrom(Prompt.GetParsingCsvPrompt().Unwrap());
        exit(PromptJson);
    end;

    [NonDebuggable]
    procedure Execute(Arguments: JsonObject): Variant
    var
        FileHandlerResult: Codeunit "File Handler Result";
        ColumnDelimiter: Text;
        DecimalSeparator: Text;
        ContainsHeaderRow: Boolean;
        ProductInfoColumnIndex: List of [Integer];
        QuantityColumnIndex: Integer;
        UoMColumnIndex: Integer;
        ColumnNames: List of [Text];
        ColumnTypes: List of [Text];
    begin
        if GetDetailsFromUserQuery(ColumnDelimiter, DecimalSeparator, ContainsHeaderRow, ProductInfoColumnIndex, QuantityColumnIndex, UoMColumnIndex, ColumnNames, ColumnTypes, Arguments) then begin
            FileHandlerResult.SetColumnDelimiter(ColumnDelimiter);
            FileHandlerResult.SetDecimalSeparator(DecimalSeparator);
            FileHandlerResult.SetContainsHeaderRow(ContainsHeaderRow);
            FileHandlerResult.SetProductColumnIndex(ProductInfoColumnIndex);
            FileHandlerResult.SetQuantityColumnIndex(QuantityColumnIndex);
            FileHandlerResult.SetUoMColumnIndex(UoMColumnIndex);
            FileHandlerResult.SetColumnNames(ColumnNames);
            FileHandlerResult.SetColumnTypes(ColumnTypes);
        end;
        exit(FileHandlerResult);
    end;

    procedure GetName(): Text
    begin
        exit(FunctionNameLbl);
    end;

    [TryFunction]
    local procedure GetDetailsFromUserQuery(var ColumnDelimiter: Text; var DecimalSeparator: Text; var ContainsHeaderRow: Boolean; var ProductInfoColumnIndex: List of [Integer]; var QuantityColumnIndex: Integer; var UoMColumnIndex: Integer; var ColumnNames: List of [Text]; var ColumnTypes: List of [Text]; Arguments: JsonObject)
    var
        JsonItem: JsonToken;
        DecimalSeparatorToken: JsonToken;
        ColumnDelimiterToken: JsonToken;
        ContainsHeaderRowToken: JsonToken;
        ProductInfoColumnIndexArrayToken: JsonArray;
        ProductInfoColumnIndexToken: JsonToken;
        ProductInfoColumnIndexChildToken: JsonToken;
        QuantityColumnIndexToken: JsonToken;
        UoMColumnIndexToken: JsonToken;
        ColumnsToken: JsonToken;
        ColumnArrayToken: JsonArray;
        ColumnToken: JsonToken;
        ColumnNameToken: JsonToken;
        ColumnTypeToken: JsonToken;
        LoopIndex: Integer;
    begin
        JsonItem := Arguments.AsToken();
        if JsonItem.AsObject().Get('column_delimiter', ColumnDelimiterToken) then
            ColumnDelimiter := ColumnDelimiterToken.AsValue().AsText();

        if JsonItem.AsObject().Get('decimal_separator', DecimalSeparatorToken) then
            DecimalSeparator := DecimalSeparatorToken.AsValue().AsText();

        if JsonItem.AsObject().Get('csv_has_header_row', ContainsHeaderRowToken) then
            ContainsHeaderRow := ContainsHeaderRowToken.AsValue().AsBoolean();

        if JsonItem.AsObject().Get('product_info_column_index', ProductInfoColumnIndexToken) then begin
            ProductInfoColumnIndexArrayToken := ProductInfoColumnIndexToken.AsArray();
            for LoopIndex := 0 to ProductInfoColumnIndexArrayToken.Count() - 1 do begin
                ProductInfoColumnIndexArrayToken.Get(LoopIndex, ProductInfoColumnIndexChildToken);
                ProductInfoColumnIndex.Add(ProductInfoColumnIndexChildToken.AsValue().AsInteger());
            end;
        end;

        if JsonItem.AsObject().Get('quantity_column_index', QuantityColumnIndexToken) then
            QuantityColumnIndex := QuantityColumnIndexToken.AsValue().AsInteger();

        if JsonItem.AsObject().Get('unit_of_measure_column_index', UoMColumnIndexToken) then
            if not UoMColumnIndexToken.AsValue().IsNull then
                UoMColumnIndex := UoMColumnIndexToken.AsValue().AsInteger();

        if JsonItem.AsObject().Get('csv_columns', ColumnsToken) then begin
            ColumnArrayToken := ColumnsToken.AsArray();
            for LoopIndex := 0 to ColumnArrayToken.Count() - 1 do begin
                ColumnArrayToken.Get(LoopIndex, ColumnToken);
                if ColumnToken.AsObject().Get('column_name', ColumnNameToken) then
                    ColumnNames.Add(ColumnNameToken.AsValue().AsText());
                if ColumnToken.AsObject().Get('column_type', ColumnTypeToken) then
                    ColumnTypes.Add(ColumnTypeToken.AsValue().AsText());
            end;
        end;
    end;
}