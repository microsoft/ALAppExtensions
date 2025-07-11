// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document.Attachment;

page 7289 "Attachment Mapping Part"
{
    Caption = 'Attachment Mapping';
    PageType = ListPart;
    ApplicationArea = All;
    ModifyAllowed = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    InherentPermissions = X;
    InherentEntitlements = X;
    SourceTable = "Attachment Mapping";
    SourceTableTemporary = true;
    Extensible = false;

    layout
    {
        area(Content)
        {
            field(ColumnSeparator; GlobalColumnSeparator)
            {
                Caption = 'Column Separator';
                ToolTip = 'Specifies the character that separates each column in the attached file.';
                Importance = Additional;
                Visible = false;
            }
            field(DecimalSeparator; GlobalDecimalSeparator)
            {
                Caption = 'Decimal Separator';
                ToolTip = 'Specifies the character that separates integer and fractional part of number.';
                Importance = Additional;
                Visible = false;
            }
            repeater(PreviewRepeater)
            {
                field("Entry No"; Rec."Entry No.")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    ShowCaption = false;
                    Visible = false;
                    ToolTip = 'Specifies the line number from the attached file.';
                }
                field(PreviewColumnName; Rec."Column Name")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    Style = Strong;
                    Caption = 'Column Name';
                    ToolTip = 'Specifies the column name from the attached file.';
                }
                field(ColumnAction; Rec."Column Action")
                {
                    ApplicationArea = Suite;
                    Caption = 'Column action';
                    ToolTip = 'Specifies the sample row data for each column from the attached file.';
                    Style = Strong;
                    StyleExpr = Rec."Column Action" <> Rec."Column Action"::Ignore;
                }
                field(SampleValue; SampleValue)
                {
                    ApplicationArea = Suite;
                    Caption = 'Sample Value';
                    ToolTip = 'Specifies whether the column contains the quantity.';
                    Editable = false;
                }
                field(ColumnValues; ColumnValuesCaptionTok)
                {
                    ApplicationArea = Suite;
                    Caption = 'Column values';
                    ToolTip = 'Specifies whether the column contains product information.';

                    trigger OnDrillDown()
                    var
                        TempItemInfoFromFile: Page "Item Info. From  File";
                        SelectedColumns: List of [Integer];
                    begin
                        Clear(SelectedColumns);
                        SelectedColumns.AddRange(GlobalProductInformationColumns);
                        SelectedColumns.Add(GlobalQuantityColumn);
                        SelectedColumns.Add(GlobalUoMColumn);
                        TempItemInfoFromFile.LoadData(GlobalFileContentAsTable, GlobalFileParserResult, SelectedColumns, Rec."Entry No.");
                        TempItemInfoFromFile.RunModal();
                    end;
                }
                field(ColumnType; Rec."Column Type")
                {
                    ApplicationArea = Suite;
                    Caption = 'Column Type';
                    ToolTip = 'Specifies the data type of the column from the attached file.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        LoadSampleRowDataForPreview();
    end;

    local procedure BuildRecordForPreview(var FileDataAsTable: List of [List of [Text]]; var ProductInformationColumns: List of [Integer]; QuantityColumn: Integer; UoMColumn: Integer)
    var
        ColumnHeader: Text;
        ColumnHeaderRow: List of [Text];
    begin
        Rec.Reset();
        Rec.DeleteAll();

        if FileDataAsTable.Count() > 0 then begin
            if GlobalFileParserResult.GetContainsHeaderRow() then
                ColumnHeaderRow := FileDataAsTable.Get(1)
            else
                ColumnHeaderRow := GlobalFileParserResult.GetColumnNames();
            foreach ColumnHeader in ColumnHeaderRow do begin // Considering the first line is header. Change the logic to make it more generic to handle lines without header.
                Rec.Init();
                Rec.IncrementEntryNumber();
                Rec."Column Name" := CopyStr(ColumnHeader, 1, MaxStrLen(Rec."Column Name"));
                // Set the boolean values by reading the mapping
                if ProductInformationColumns.Contains(Rec."Entry No.") then
                    Rec."Column Action" := Rec."Column Action"::"Product Info.";

                if QuantityColumn = Rec."Entry No." then
                    Rec."Column Action" := Rec."Column Action"::"Quantity Info.";

                if UoMColumn = Rec."Entry No." then
                    Rec."Column Action" := Rec."Column Action"::"UoM Info.";

                Rec."Column Type" := GlobalColumnType.Get(Rec."Entry No.");

                Rec.Insert();
            end;
        end;
    end;

    internal procedure LoadCSVAndGetProductInfo(var FileContentAsTable: List of [List of [Text]]; var FileParserResult: Codeunit "File Handler Result")
    begin
        GlobalFileParserResult := FileParserResult;
        GlobalProductInformationColumns := GlobalFileParserResult.GetProductColumnIndex();
        GlobalQuantityColumn := GlobalFileParserResult.GetQuantityColumnIndex();
        GlobalUoMColumn := GlobalFileParserResult.GetUoMColumnIndex();
        GlobalColumnType := GetColumnTypesFromText(GlobalFileParserResult.GetColumnTypes());

        GlobalFileContentAsTable := FileContentAsTable;
        BuildRecordForPreview(GlobalFileContentAsTable, GlobalProductInformationColumns, GlobalQuantityColumn, GlobalUoMColumn);
    end;

    internal procedure ColumnMappingHasChanged(var NewProductInformationColumns: List of [Integer]; var NewQuantityColumn: Integer; var NewUoMColumn: Integer): Boolean
    var
        ColumnIndex: Integer;
    begin
        GetMappingSetup(NewProductInformationColumns, NewQuantityColumn, NewUoMColumn);

        if GlobalProductInformationColumns.Count() <> NewProductInformationColumns.Count() then begin
            SaveColumnMapping(NewProductInformationColumns, NewQuantityColumn, NewUoMColumn);
            exit(true);
        end;

        foreach ColumnIndex in GlobalProductInformationColumns do
            if not NewProductInformationColumns.Contains(ColumnIndex) then begin
                SaveColumnMapping(NewProductInformationColumns, NewQuantityColumn, NewUoMColumn);
                exit(true);
            end;

        if GlobalQuantityColumn <> NewQuantityColumn then begin
            SaveColumnMapping(NewProductInformationColumns, NewQuantityColumn, NewUoMColumn);
            exit(true);
        end;

        if GlobalUoMColumn <> NewUoMColumn then begin
            SaveColumnMapping(NewProductInformationColumns, NewQuantityColumn, NewUoMColumn);
            exit(true);
        end;
    end;

    local procedure SaveColumnMapping(NewProductInformationColumns: List of [Integer]; NewQuantityColumn: Integer; NewUoMColumn: Integer)
    begin
        GlobalProductInformationColumns := NewProductInformationColumns;
        GlobalQuantityColumn := NewQuantityColumn;
        GlobalUoMColumn := NewUoMColumn;
    end;

    internal procedure GetMappingSetup(var ProductInformationColumns: List of [Integer]; var QuantityColumn: Integer; var UoMColumn: Integer)
    var
        TempAttachmentMapping: Record "Attachment Mapping" temporary;
    begin
        TempAttachmentMapping.Copy(Rec, true);
        TempAttachmentMapping.SetRange("Column Action", TempAttachmentMapping."Column Action"::"Product Info.");

        if TempAttachmentMapping.FindSet() then
            repeat
                ProductInformationColumns.Add(TempAttachmentMapping."Entry No.");
            until TempAttachmentMapping.Next() = 0;

        TempAttachmentMapping.Reset();
        TempAttachmentMapping.SetRange("Column Action", TempAttachmentMapping."Column Action"::"Quantity Info.");
        if TempAttachmentMapping.FindFirst() then
            QuantityColumn := TempAttachmentMapping."Entry No.";

        TempAttachmentMapping.Reset();
        TempAttachmentMapping.SetRange("Column Action", TempAttachmentMapping."Column Action"::"UoM Info.");
        if TempAttachmentMapping.FindFirst() then
            UoMColumn := TempAttachmentMapping."Entry No.";
    end;

    local procedure LoadSampleRowDataForPreview()
    begin
        if Rec."Entry No." > 0 then begin
            GlobalPreviewSampleDataTxt := '';

            if Rec."Entry No." > GlobalFileContentAsTable.Get(1).Count() then // ignore columns if their index is more than the content
                exit;

            if GlobalFileParserResult.GetContainsHeaderRow() then
                SampleValue := CopyStr(GlobalFileContentAsTable.Get(2).Get(Rec."Entry No."), 1, MaxStrLen(SampleValue))
            else
                SampleValue := CopyStr(GlobalFileContentAsTable.Get(1).Get(Rec."Entry No."), 1, MaxStrLen(SampleValue));
        end
    end;

    local procedure GetColumnTypesFromText(ColumnTypesAsText: List of [Text]) ColumnTypes: List of [Enum "Column Type"]
    var
        ColumnTypeTxt: Text;
    begin
        Clear(ColumnTypes);

        foreach ColumnTypeTxt in ColumnTypesAsText do
            case ColumnTypeTxt.ToLower() of
                'text', 'string':
                    ColumnTypes.Add(Enum::"Column Type"::Text);
                'number', 'numeric', 'num', 'integer', 'int', 'float', 'double', 'decimal':
                    ColumnTypes.Add(Enum::"Column Type"::Number);
                'date':
                    ColumnTypes.Add(Enum::"Column Type"::Date);
                'boolean', 'bool':
                    ColumnTypes.Add(Enum::"Column Type"::Boolean);
                else
                    ColumnTypes.Add(Enum::"Column Type"::Unknown);
            end;
        exit(ColumnTypes)

    end;

    var
        GlobalFileParserResult: Codeunit "File Handler Result";
        GlobalFileContentAsTable: List of [List of [Text]];
        GlobalColumnSeparator: Text;
        GlobalDecimalSeparator: Text;
        GlobalPreviewSampleDataTxt: Text;
        GlobalProductInformationColumns: List of [Integer];
        GlobalQuantityColumn: Integer;
        GlobalUoMColumn: Integer;
        GlobalColumnType: List of [Enum "Column Type"];
        SampleValue: Text[100];
        ColumnValuesCaptionTok: Label 'See all';
}