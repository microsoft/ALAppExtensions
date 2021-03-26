codeunit 20237 "Tax Rates Export Mgmt."
{
    procedure ExportTaxRates(TaxType: Code[20])
    begin
        CreateHeading(TaxType);
        LoopTaxRateRows(TaxType);
        ExportToFile(TaxType);
    end;

    local procedure CreateHeading(TaxType: Code[20])
    var
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
    begin
        TaxRateColumnSetup.SetCurrentKey(Sequence);
        TaxRateColumnSetup.SetRange("Tax Type", TaxType);
        if TaxRateColumnSetup.FindSet() then
            repeat
                WriteHeading(TaxRateColumnSetup);
            until TaxRateColumnSetup.Next() = 0;
    end;

    local procedure WriteHeading(TaxRateColumnSetup: Record "Tax Rate Column Setup")
    var
        ColumnName: Text;
        ColumnName2: Text;
    begin
        case TaxRateColumnSetup."Column Type" of
            TaxRateColumnSetup."Column Type"::Component:
                ColumnName := TaxRateColumnSetup."Column Name" + ' %';
            TaxRateColumnSetup."Column Type"::"Range From and Range To":
                begin
                    ColumnName := TaxRateColumnSetup."Column Name" + ' From';
                    ColumnName2 := TaxRateColumnSetup."Column Name" + ' To';
                end;
            else
                ColumnName := TaxRateColumnSetup."Column Name";
        end;
        TempExcelBuffer.AddColumn(ColumnName, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);

        if ColumnName2 <> '' then
            TempExcelBuffer.AddColumn(ColumnName2, false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure LoopTaxRateRows(TaxType: Code[20])
    var
        TaxRate: Record "Tax Rate";
    begin
        TaxRate.SetRange("Tax Type", TaxType);
        if TaxRate.FindSet() then
            repeat
                TempExcelBuffer.NewRow();
                ExportRateRow(TaxRate);
            until TaxRate.Next() = 0;
    end;

    local procedure ExportRateRow(TaxRate: Record "Tax Rate")
    var
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
    begin
        TaxRateColumnSetup.SetCurrentKey(Sequence);
        TaxRateColumnSetup.SetRange("Tax Type", TaxRate."Tax Type");
        if TaxRateColumnSetup.FindSet() then
            repeat
                ExportRowValue(TaxRateColumnSetup, TaxRate."ID");
            until TaxRateColumnSetup.next() = 0;
    end;

    local procedure ExportRowValue(TaxRateColumnSetup: Record "Tax Rate Column Setup"; RowID: Guid)
    var
        TaxRateValue: Record "Tax Rate Value";
        CellType: Option Number,Text,Date,Time;
        Value: Text;
    begin
        TaxRateValue.SetRange("Config ID", RowID);
        TaxRateValue.SetRange("Column ID", TaxRateColumnSetup."Column ID");
        if TaxRateValue.FindFirst() then
            repeat
                ConvertRateToExcelCellType(TaxRateColumnSetup, CellType);

                GetRateColumnValue(TaxRateValue, TaxRateColumnSetup, Value, false);
                TempExcelBuffer.AddColumn(
                    Value,
                    false,
                    '',
                    false,
                    false,
                    false,
                    GetFormat(TaxRateColumnSetup),
                    CellType);

                if TaxRateColumnSetup."Column Type" = TaxRateColumnSetup."Column Type"::"Range From and Range To" then begin
                    GetRateColumnValue(TaxRateValue, TaxRateColumnSetup, Value, true);
                    TempExcelBuffer.AddColumn(
                        Value,
                        false,
                        '',
                        false,
                        false,
                        false,
                        GetFormat(TaxRateColumnSetup),
                        CellType);
                end;
            until TaxRateValue.Next() = 0;
    end;

    local procedure GetRateColumnValue(TaxRateValue: Record "Tax Rate Value"; TaxRateColumnSetup: Record "Tax Rate Column Setup"; var Value: Text; Range: Boolean)
    var
        DataType: Enum "Symbol Data Type";
        TableValue: Variant;
    begin
        Value := '';

        DataType := UseCaseDataTypeMgmt.GetAttributeDataTypeToVariableDataType(TaxRateColumnSetup.Type);
        if RangeTypeColumn(TaxRateColumnSetup) then
            UpdateRangeValue(TaxRateValue, TaxRateColumnSetup, TableValue, Range)
        else
            TableValue := TaxRateValue.Value;

        Value := format(TableValue, 0, 9);
    end;

    local procedure RangeTypeColumn(TaxRateColumnSetup: Record "Tax Rate Column Setup"): Boolean
    begin
        if TaxRateColumnSetup."Column Type" in
                [TaxRateColumnSetup."Column Type"::"Range From",
                TaxRateColumnSetup."Column Type"::"Range From and Range To",
                TaxRateColumnSetup."Column Type"::"Range To"]
        then
            exit(true);

        exit(false);
    end;

    local procedure GetFormat(TaxRateColumnSetup: Record "Tax Rate Column Setup"): Text
    begin
        case TaxRateColumnSetup.Type of
            TaxRateColumnSetup.Type::Integer:
                exit('0');
            TaxRateColumnSetup.Type::Decimal:
                exit('0.00');
            else
                exit('');
        end
    end;

    local procedure UpdateRangeValue(TaxRateValue: Record "Tax Rate Value"; TaxRateColumnSetup: Record "Tax Rate Column Setup"; var Value: Variant; Range: Boolean)
    begin
        if TaxRateColumnSetup.Type = TaxRateColumnSetup.Type::Date then begin
            if not Range then
                Value := TaxRateValue."Date Value"
            else
                Value := TaxRateValue."Date Value To";
        end else
            if not Range then
                Value := TaxRateValue."Decimal Value"
            else
                Value := TaxRateValue."Decimal Value To";
    end;

    local procedure ConvertRateToExcelCellType(TaxRateColumnSetup: Record "Tax Rate Column Setup"; var CellType: Option Number,Text,Date,Time)
    begin
        case TaxRateColumnSetup.Type of
            TaxRateColumnSetup.Type::Date:
                CellType := CellType::Date;
            TaxRateColumnSetup.Type::Decimal, TaxRateColumnSetup.Type::Integer:
                CellType := CellType::Number;
            else
                CellType := CellType::Text;
        end;
    end;

    local procedure ExportToFile(TaxType: Code[20])
    var
        TempBlob: Codeunit "Temp Blob";
        FileNameLbl: Label 'Tax Rate - %1.xlsx', Comment = '%1 = Tax Type';
        OStream: OutStream;
        IStream: InStream;
        FileName: Text;
    begin
        FileName := StrSubstNo(FileNameLbl, TaxType);
        TempBlob.CreateOutStream(Ostream);

        TempExcelBuffer.CreateNewBook(TaxType);
        TempExcelBuffer.WriteSheet(TaxType, CompanyName, UserId);
        TempExcelBuffer.CloseBook();
        TempExcelBuffer.SaveToStream(OStream, true);

        TempBlob.CreateInStream(IStream);
        DownloadFromStream(IStream, '', '', '', FileName);
    end;

    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        UseCaseDataTypeMgmt: Codeunit "Use Case Data Type Mgmt.";
}