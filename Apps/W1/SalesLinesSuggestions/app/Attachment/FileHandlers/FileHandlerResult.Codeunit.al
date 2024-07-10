// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document.Attachment;

codeunit 7295 "File Handler Result"
{
    Access = Internal;

    var
        ColumnDelimiter: Text;
        ColumnDelimiterLbl: Label 'Column_Delimiter', Locked = true;
        DecimalSeparator: Text;
        ProductColumnIndex: List of [Integer];
        ProductColumnIndexLbl: Label 'Product_Column_Index', Locked = true;
        QuantityColumnIndex: Integer;
        QuantityColumnIndexLbl: Label 'Quantity_Column_Index', Locked = true;
        UoMColumnIndex: Integer;
        UoMColumnIndexLbl: Label 'UoM_Column_Index', Locked = true;
        ContainsHeaderRow: Boolean;
        ContainsHeaderRowLbl: Label 'Contains_Header_Row', Locked = true;
        ColumnNames: List of [Text];
        ColumnNamesLbl: Label 'Column_Names', Locked = true;
        ColumnTypes: List of [Text];
        ColumnTypesLbl: Label 'Column_Types', Locked = true;

    internal procedure AddProductColumnIndex(ColumnIndex: Integer)
    begin
        ProductColumnIndex.Add(ColumnIndex);
    end;

    internal procedure SetProductColumnIndex(ColumnIndex: Integer)
    begin
        Clear(ProductColumnIndex);
        ProductColumnIndex.Add(ColumnIndex);
    end;

    internal procedure SetProductColumnIndex(ColumnIndex: List of [Integer])
    begin
        Clear(ProductColumnIndex);
        ProductColumnIndex := ColumnIndex;
    end;

    internal procedure SetQuantityColumnIndex(ColumnIndex: Integer)
    begin
        QuantityColumnIndex := ColumnIndex;
    end;

    internal procedure SetUoMColumnIndex(ColumnIndex: Integer)
    begin
        UoMColumnIndex := ColumnIndex;
    end;

    internal procedure GetProductColumnIndex(): List of [Integer]
    begin
        exit(ProductColumnIndex);
    end;

    internal procedure GetQuantityColumnIndex(): Integer
    begin
        exit(QuantityColumnIndex);
    end;

    internal procedure GetUoMColumnIndex(): Integer
    begin
        exit(UoMColumnIndex);
    end;

    internal procedure SetColumnDelimiter(Delimiter: Text)
    begin
        ColumnDelimiter := Delimiter;
    end;

    internal procedure GetColumnDelimiter(): Text
    begin
        exit(ColumnDelimiter);
    end;

    internal procedure SetDecimalSeparator(Separator: Text)
    begin
        DecimalSeparator := Separator;
    end;

    internal procedure GetDecimalSeparator(): Text
    begin
        exit(DecimalSeparator);
    end;

    internal procedure SetContainsHeaderRow(ContainsHeader: Boolean)
    begin
        ContainsHeaderRow := ContainsHeader;
    end;

    internal procedure GetContainsHeaderRow(): Boolean
    begin
        exit(ContainsHeaderRow);
    end;

    internal procedure SetColumnNames(Names: List of [Text])
    begin
        ColumnNames := Names;
    end;

    internal procedure GetColumnNames(): List of [Text]
    begin
        exit(ColumnNames);
    end;

    internal procedure SetColumnTypes(Types: List of [Text])
    begin
        ColumnTypes := Types;
    end;

    internal procedure GetColumnTypes(): List of [Text]
    begin
        exit(ColumnTypes);
    end;

    internal procedure ToJson(): JsonObject
    var
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        ColumnIndex: Integer;
        ColumnValue: Text;

    begin
        // ColumnDelimiter
        JsonObject.Add(ColumnDelimiterLbl, ColumnDelimiter);

        // ProductColumnIndex
        foreach ColumnIndex in ProductColumnIndex do
            JsonArray.Add(ColumnIndex);
        JsonObject.Add(ProductColumnIndexLbl, JsonArray);

        // QuantityColumnIndex
        JsonObject.Add(QuantityColumnIndexLbl, QuantityColumnIndex);

        // UoMColumnIndex
        JsonObject.Add(UoMColumnIndexLbl, UoMColumnIndex);

        // ContainsHeaderRow
        if ContainsHeaderRow then
            JsonObject.Add(ContainsHeaderRowLbl, 1)
        else
            JsonObject.Add(ContainsHeaderRowLbl, 0);

        // ColumnNames
        Clear(JsonArray);
        foreach ColumnValue in ColumnNames do
            JsonArray.Add(ColumnValue);
        JsonObject.Add(ColumnNamesLbl, JsonArray);

        // ColumnTypes
        Clear(JsonArray);
        foreach ColumnValue in ColumnTypes do
            JsonArray.Add(ColumnValue);
        JsonObject.Add(ColumnTypesLbl, JsonArray);

        exit(JsonObject);
    end;

    internal procedure FromJson(JsonObject: JsonObject)
    var
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        Index: Integer;
    begin
        // Clear existing values
        Clear(ColumnDelimiter);
        Clear(ProductColumnIndex);
        Clear(QuantityColumnIndex);
        Clear(UoMColumnIndex);
        Clear(ContainsHeaderRow);
        Clear(ColumnNames);
        Clear(ColumnTypes);

        // ColumnDelimiter
        JsonObject.Get(ColumnDelimiterLbl, JsonToken);
        ColumnDelimiter := JsonToken.AsValue().AsText();

        // ProductColumnIndex
        JsonObject.Get(ProductColumnIndexLbl, JsonToken);
        JsonArray := JsonToken.AsArray();
        for Index := 0 to JsonArray.Count - 1 do begin
            JsonArray.Get(Index, JsonToken);
            ProductColumnIndex.Add(JsonToken.AsValue().AsInteger());
        end;

        // QuantityColumnIndex
        JsonObject.Get(QuantityColumnIndexLbl, JsonToken);
        QuantityColumnIndex := JsonToken.AsValue().AsInteger();

        // UoMColumnIndex
        JsonObject.Get(UoMColumnIndexLbl, JsonToken);
        UoMColumnIndex := JsonToken.AsValue().AsInteger();

        // ContainsHeaderRow
        JsonObject.Get(ContainsHeaderRowLbl, JsonToken);
        if JsonToken.AsValue().AsInteger() = 1 then
            ContainsHeaderRow := true
        else
            ContainsHeaderRow := false;

        // ColumnNames
        JsonObject.Get(ColumnNamesLbl, JsonToken);
        JsonArray := JsonToken.AsArray();
        for Index := 0 to JsonArray.Count - 1 do begin
            JsonArray.Get(Index, JsonToken);
            ColumnNames.Add(JsonToken.AsValue().AsText());
        end;

        // ColumnTypes
        JsonObject.Get(ColumnTypesLbl, JsonToken);
        JsonArray := JsonToken.AsArray();
        for Index := 0 to JsonArray.Count - 1 do begin
            JsonArray.Get(Index, JsonToken);
            ColumnTypes.Add(JsonToken.AsValue().AsText());
        end;
    end;
}