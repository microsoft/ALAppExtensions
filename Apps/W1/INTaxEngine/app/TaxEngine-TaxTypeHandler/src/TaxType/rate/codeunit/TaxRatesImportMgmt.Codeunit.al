codeunit 20238 "Tax Rates Import Mgmt."
{
    procedure ReadAndImportTaxRates(TaxType: Code[20])
    var
        TempBlob: Codeunit "Temp Blob";
        IStream: Instream;
        FileText: Text;
    begin
        TempBlob.CreateInStream(IStream);
        UploadIntoStream('', '', '', FileText, IStream);
        if FileText = '' then
            exit;
        TempExcelBuffer.OpenBookStream(IStream, TaxType);
        TempExcelBuffer.ReadSheetContinous(TaxType, true);

        TempExcelBuffer.reset();
        if not TempExcelBuffer.FindLast() then
            exit;

        ImportRecords(TaxType, TempExcelBuffer."Row No.");
    end;

    local procedure ImportRecords(TaxType: Code[20]; LastRowNo: Integer)
    var
        RowNo: Integer;
    begin
        for RowNo := 1 to LastRowNo do
            ProcessExcelRow(TaxType, RowNo);
    end;

    local procedure ProcessExcelRow(TaxType: Code[20]; RowNo: Integer)
    var
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
        RowID: Guid;
        ColNo: Integer;
        Value: Text;
    begin
        if RowNo = 1 then
            exit;

        TaxRateColumnSetup.SetCurrentKey(Sequence);
        TaxRateColumnSetup.SetRange("Tax Type", TaxType);
        if TaxRateColumnSetup.FindSet() then begin
            PrepareRow(TaxType, RowID);

            repeat
                ColNo += 1;
                Value := GetCellValue(Rowno, ColNo);
                UpdateRateColumnValue(TaxRateColumnSetup, RowID, Value, false);
                if TaxRateColumnSetup."Column Type" = TaxRateColumnSetup."Column Type"::"Range From and Range To" then begin
                    ColNo += 1;
                    Value := GetCellValue(Rowno, ColNo);
                    UpdateRateColumnValue(TaxRateColumnSetup, RowID, Value, true);
                end
            until TaxRateColumnSetup.Next() = 0;

            TaxRateColumnSetup.UpdateTransactionKeys();
        end;
    end;

    local procedure PrepareRow(TaxType: Code[20]; var RowID: Guid)
    var
        TaxRate: Record "Tax Rate";
    begin
        TaxRate.Init();
        TaxRate."Tax Type" := TaxType;
        TaxRate.Insert(true);

        RowID := TaxRate.ID;
        TaxSetupMatrixMgmt.InitializeRateValue(TaxRate, TaxType);
    end;

    local procedure UpdateRateColumnValue(TaxRateSetup: Record "Tax Rate Column Setup"; RowID: Guid; Value: Text; Range: Boolean)
    var
        TaxRateValue: Record "Tax Rate Value";
        DataType: Enum "Symbol Data Type";
        XmlValue: Text;
    begin
        TaxSetupMatrixMgmt.ValidateColumnValue(TaxRateSetup, Value);
        TaxRateValue.SetRange("Config ID", RowID);
        TaxRateValue.SetRange("Tax Type", TaxRateSetup."Tax Type");
        TaxRateValue.SetRange("Column ID", TaxRateSetup."Column ID");
        TaxRateValue.FindFirst();

        DataType := UseCaseDataTypeMgmt.GetAttributeDataTypeToVariableDataType(TaxRateSetup.Type);
        if TaxRateSetup.Type <> TaxRateSetup.Type::Boolean then
            XmlValue := ScriptDataTypeMgmt.ConvertLocalToXmlFormat(Value, DataType)
        else
            XmlValue := Value;

        TaxSetupMatrixMgmt.UpdateAndValidateRateValue(TaxRateValue, TaxRateSetup, XmlValue, Range);
        TaxRateValue.Modify();
    end;

    local procedure GetCellValue(RowID: Integer; ColID: Integer): Text
    begin
        if TempExcelBuffer.Get(RowID, ColID) then
            exit(TempExcelBuffer."Cell Value as Text");

        exit('');
    end;

    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        UseCaseDataTypeMgmt: Codeunit "Use Case Data Type Mgmt.";
        TaxSetupMatrixMgmt: Codeunit "Tax Setup Matrix Mgmt.";
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
}