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
        InitTaxTypeProgressWindow();
        FillBuffer(TaxType);

        for RowNo := 1 to LastRowNo do
            ProcessExcelRow(TaxType, RowNo);

        CloseTaxTypeProgressWindow();
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
            UpdateTaxTypeProgressWindow(TaxRateColumnSetup."Tax Type", StrSubstNo(ImportingValuesStageLbl, RowNo));

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

            UpdateTaxTypeProgressWindow(TaxRateColumnSetup."Tax Type", StrSubstNo(ValidatingValuesStageLbl, RowNo));
            UpdateTransactionKeys(TaxRateColumnSetup."Tax Type", RowID);
            TransferRateValueToMainRecord(TaxType, RowID);
        end;
    end;

    local procedure FillBuffer(TaxType: Code[20])
    var
        TaxRate: Record "Tax Rate";
    begin
        TaxRate.SetRange("Tax Type", TaxType);
        if TaxRate.FindSet() then
            repeat
                TempTaxRate.Init();
                TempTaxRate := TaxRate;
                TempTaxRate.Insert();
            until TaxRate.Next() = 0;
    end;

    local procedure TransferRateValueToMainRecord(TaxType: Code[20]; ConfigID: Guid)
    var
        TaxRate: Record "Tax Rate";
        TaxRateValue: Record "Tax Rate Value";
    begin
        TempTaxRate.Get(TaxType, ConfigID);

        TaxRate := TempTaxRate;
        TaxRate.Insert();

        TempTaxRateValue.Reset();
        if TempTaxRateValue.FindSet() then
            repeat
                TaxRateValue.Init();
                TaxRateValue := TempTaxRateValue;
                TaxRateValue.Insert();
                TempTaxRateValue.Delete();
            until TempTaxRateValue.Next() = 0;
    end;

    local procedure GenerateTaxSetupID(ConfigID: Guid; TaxType: Code[20]) TaxSetupID: Text[2000]
    var
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
    begin
        TempTaxRateValue.SetRange("Config ID", ConfigID);
        if TempTaxRateValue.IsEmpty() then
            exit;

        TaxRateColumnSetup.SetCurrentKey(Sequence);
        TaxRateColumnSetup.SetRange("Tax Type", TaxType);
        TaxRateColumnSetup.SetFilter("Column Type", '%1|%2|%3|%4|%5',
            TaxRateColumnSetup."Column Type"::"Tax Attributes",
            TaxRateColumnSetup."Column Type"::Value,
            TaxRateColumnSetup."Column Type"::"Range From",
            TaxRateColumnSetup."Column Type"::"Range From and Range To",
            TaxRateColumnSetup."Column Type"::"Range To");

        if TaxRateColumnSetup.FindSet() then
            repeat
                TempTaxRateValue.Reset();
                TempTaxRateValue.SetRange("Config ID", ConfigID);
                TempTaxRateValue.SetRange("Column ID", TaxRateColumnSetup."Column ID");
                if TempTaxRateValue.FindFirst() then
                    TaxSetupID += TempTaxRateValue.Value + '|';
            until TaxRateColumnSetup.Next() = 0;

        CheckForDuplicateSetID(ConfigID, TaxType, TaxSetupID);
    end;

    local procedure GenerateTaxRateID(ConfigID: Guid; TaxType: Code[20]) TaxRateID: Text[2000]
    var
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
    begin
        TempTaxRateValue.SetRange("Config ID", ConfigID);
        if TempTaxRateValue.IsEmpty() then
            exit;

        TaxRateColumnSetup.SetCurrentKey(Sequence);
        TaxRateColumnSetup.SetRange("Tax Type", TaxType);
        TaxRateColumnSetup.SetFilter("Column Type", '%1|%2',
            TaxRateColumnSetup."Column Type"::"Tax Attributes",
            TaxRateColumnSetup."Column Type"::Value);
        TaxRateColumnSetup.SetRange("Allow Blank", false);
        if TaxRateColumnSetup.FindSet() then
            repeat
                TempTaxRateValue.Reset();
                TempTaxRateValue.SetRange("Config ID", ConfigID);
                TempTaxRateValue.SetRange("Column ID", TaxRateColumnSetup."Column ID");
                if TempTaxRateValue.FindFirst() then
                    TaxRateID += TempTaxRateValue.Value + '|';
            until TaxRateColumnSetup.Next() = 0;
    end;

    local procedure CheckForDuplicateSetID(ConfigID: Guid; TaxType: Code[20]; TaxSetID: Text)
    begin
        TempTaxRate.Reset();
        TempTaxRate.SetRange("Tax Type", TaxType);
        TempTaxRate.SetFilter(ID, '<>%1', ConfigID);
        TempTaxRate.SetRange("Tax Setup ID", TaxSetID);
        if not TempTaxRate.IsEmpty() then
            Error(TaxConfigurationAlreadyExistErr);
    end;

    local procedure UpdateTransactionKeys(TaxType: Code[20]; RowID: Guid)
    begin
        TempTaxRate.Get(TaxType, RowID);
        TempTaxRate."Tax Setup ID" := GenerateTaxSetupID(TempTaxRate.ID, TempTaxRate."Tax Type");
        TempTaxRate."Tax Rate ID" := GenerateTaxRateID(TempTaxRate.ID, TempTaxRate."Tax Type");
        TempTaxRate.Modify();

        UpdateRateIDOnRateValue(TempTaxRate.ID, TempTaxRate."Tax Rate ID");
    end;

    local procedure UpdateRateIDOnRateValue(ConfigId: Guid; KeyValue: Text[2000])
    begin
        TempTaxRateValue.SetRange("Config ID", ConfigId);
        if not TempTaxRateValue.IsEmpty() then
            TempTaxRateValue.ModifyAll("Tax Rate ID", KeyValue);
    end;

    local procedure PrepareRow(TaxType: Code[20]; var RowID: Guid)
    begin
        TempTaxRate.Init();
        TempTaxRate."Tax Type" := TaxType;
        TempTaxRate.Mark(true);
        TempTaxRate.Insert(true);

        RowID := TempTaxRate.ID;
    end;

    local procedure UpdateRateColumnValue(TaxRateSetup: Record "Tax Rate Column Setup"; RowID: Guid; Value: Text; Range: Boolean)
    var
        DataType: Enum "Symbol Data Type";
        XmlValue: Text;
    begin
        TaxSetupMatrixMgmt.ValidateColumnValue(TaxRateSetup, Value);

        TempTaxRateValue.Reset();
        TempTaxRateValue.SetRange("Tax Type", TaxRateSetup."Tax Type");
        TempTaxRateValue.SetRange("Config ID", RowID);
        TempTaxRateValue.SetRange("Column ID", TaxRateSetup."Column ID");
        if not TempTaxRateValue.FindFirst() then begin
            TempTaxRateValue.Init();
            TempTaxRateValue."Config ID" := RowID;
            TempTaxRateValue.ID := CreateGuid();
            TempTaxRateValue."Tax Type" := TaxRateSetup."Tax Type";
            TempTaxRateValue."Column ID" := TaxRateSetup."Column ID";
            TempTaxRateValue."Column Type" := TaxRateSetup."Column Type";
            TaxSetupMatrixMgmt.SetDefaultRateValues(TaxRateSetup, TempTaxRateValue);
            TempTaxRateValue.Insert();
        end;
        DataType := UseCaseDataTypeMgmt.GetAttributeDataTypeToVariableDataType(TaxRateSetup.Type);
        if TaxRateSetup.Type <> TaxRateSetup.Type::Boolean then
            XmlValue := ScriptDataTypeMgmt.ConvertLocalToXmlFormat(Value, DataType)
        else
            XmlValue := Value;

        TaxSetupMatrixMgmt.UpdateAndValidateRateValue(TempTaxRateValue, TaxRateSetup, XmlValue, Range);
        TempTaxRateValue.Modify();
    end;

    local procedure GetCellValue(RowID: Integer; ColID: Integer): Text
    begin
        if TempExcelBuffer.Get(RowID, ColID) then
            exit(TempExcelBuffer."Cell Value as Text");

        exit('');
    end;

    procedure InitTaxTypeProgressWindow()
    begin
        if not GuiAllowed() then
            exit;

        TaxTypeDialog.Open(
             ImportingLbl +
             ValueLbl +
             TaxTypeImportStageLbl);
    end;

    local procedure UpdateTaxTypeProgressWindow(TaxType: Code[20]; Stage: Text)
    begin
        if not GuiAllowed() then
            exit;
        TaxTypeDialog.Update(1, TaxTypesLbl);
        TaxTypeDialog.Update(2, TaxType);
        TaxTypeDialog.Update(3, Stage);
    end;

    local procedure CloseTaxTypeProgressWindow()
    begin
        if not GuiAllowed() then
            exit;
        TaxTypeDialog.close();
    end;

    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        TempTaxRate: Record "Tax Rate" temporary;
        TempTaxRateValue: Record "Tax Rate Value" temporary;
        UseCaseDataTypeMgmt: Codeunit "Use Case Data Type Mgmt.";
        TaxSetupMatrixMgmt: Codeunit "Tax Setup Matrix Mgmt.";
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TaxTypeDialog: Dialog;
        TaxConfigurationAlreadyExistErr: Label 'Tax Rate already exist with the same setup value.';
        ImportingLbl: Label 'Importing              #1######\', Comment = 'Tax Rates';
        TaxTypeImportStageLbl: Label 'Stage      #3######\', Comment = 'Stage of Import for Tax Rate';
        TaxTypesLbl: Label 'Tax Rates';
        ValueLbl: Label 'Tax Type :              #2######\', Comment = 'Tax Type Code';
        ImportingValuesStageLbl: Label 'Importing Values for Row No. %1', Comment = 'Row No.';
        ValidatingValuesStageLbl: Label 'Validating Values for Row No. %1', Comment = 'Row No.';
}