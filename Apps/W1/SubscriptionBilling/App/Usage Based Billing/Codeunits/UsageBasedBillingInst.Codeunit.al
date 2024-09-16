namespace Microsoft.SubscriptionBilling;

using System.IO;

codeunit 8031 "Usage Based Billing Inst."
{
    Subtype = Install;
    Access = Internal;

    trigger OnInstallAppPerCompany()
    begin
        InstallUsageBasedGenericDataExchangeDefinition();
    end;

    local procedure InstallUsageBasedGenericDataExchangeDefinition()
    begin
        if DataExchDef.Get(UsageBasedDataExchDefCodeTxt) then
            exit;
        CreateDataExchangeDefinition(UsageBasedDataExchDefCodeTxt, UsageBasedDataExchDefNameTxt, XmlPort::"Data Exch. Import - CSV", DataExchDef."File Type"::"Variable Text", DataExchDef.Type::"Generic Import", DataExchDef."File Encoding"::"UTF-8", DataExchDef."Column Separator"::Semicolon, '', 1);
        CreateDataExchDefinitionLine(UsageBasedDataExchDefCodeTxt, UsageBasedDataExchDefLineCodeTxt, UsageBasedDataExchDefLineNameTxt, 16);
        InitializeUsageBasedGenericDataExchangeColumns();
        InitializeUsageBasedGenericDataExchangeFields();
        CreateUsageBasedGenericDataExchColumnDefinition(UsageBasedDataExchDefCodeTxt, UsageBasedDataExchDefLineCodeTxt);
        CreateUsageBasedDataExchangeMapping(UsageBasedDataExchDefCodeTxt, UsageBasedDataExchDefLineCodeTxt, RRef.Number, UsageBasedDataExchMappingTxt, Codeunit::"Generic Import Mappings", 0, 0);
        CreateUsageBasedGenericDataExchangeFieldMapping(UsageBasedDataExchDefCodeTxt, UsageBasedDataExchDefLineCodeTxt, RRef.Number);
    end;

    local procedure InitializeUsageBasedGenericDataExchangeColumns()
    begin
        GenericColumnArr[1] := 2;
        GenericColumnArr[2] := 3;
        GenericColumnArr[3] := 7;
        GenericColumnArr[4] := 8;
        GenericColumnArr[5] := 10;
        GenericColumnArr[6] := 11;
        GenericColumnArr[7] := 12;
        GenericColumnArr[8] := 13;
        GenericColumnArr[9] := 14;
        GenericColumnArr[10] := 16;
        GenericColumnArr[11] := 17;
        GenericColumnArr[12] := 18;
        GenericColumnArr[13] := 19;
        GenericColumnArr[14] := 23;
        GenericColumnArr[15] := 22;
        GenericColumnArr[16] := 24;
    end;

    local procedure InitializeUsageBasedGenericDataExchangeFields()
    begin
        GenericFieldArr[1] := 7;
        GenericFieldArr[2] := 8;
        GenericFieldArr[3] := 10;
        GenericFieldArr[4] := 17;
        GenericFieldArr[5] := 18;
        GenericFieldArr[6] := 13;
        GenericFieldArr[7] := 14;
        GenericFieldArr[8] := 15;
        GenericFieldArr[9] := 16;
        GenericFieldArr[10] := 19;
        GenericFieldArr[11] := 21;
        GenericFieldArr[12] := 20;
        GenericFieldArr[13] := 24;
        GenericFieldArr[14] := 25;
        GenericFieldArr[15] := 27;
        GenericFieldArr[16] := 50;
    end;

    procedure CreateDataExchangeDefinition(DataExchDefCode: Code[20]; DataExchDefName: Text[100]; ReadingWritingXMLPort: Integer; FileType: Option Xml,"Variable Text","Fixed Text",Json; DefinitionType: Enum "Data Exchange Definition Type"; FileEncoding: Option "MS-DOS","UTF-8","UTF-16",WINDOWS; ColumnSeparator: Option " ",Tab,Semicolon,Comma,Space,Custom; CustomColumnSeparator: Text[10]; HeaderLines: Integer)
    begin
        DataExchDef.Init();
        DataExchDef.Code := DataExchDefCode;
        DataExchDef.Name := DataExchDefName;
        DataExchDef."File Type" := FileType;
        DataExchDef.Type := DefinitionType;
        DataExchDef."Reading/Writing XMLport" := ReadingWritingXMLPort;
        DataExchDef."File Encoding" := FileEncoding;
        DataExchDef."Column Separator" := ColumnSeparator;
        DataExchDef."Custom Column Separator" := CustomColumnSeparator;
        DataExchDef."Header Lines" := HeaderLines;
        DataExchDef.Insert(false);
    end;

    procedure CreateDataExchDefinitionLine(DataExchDefCode: Code[20]; DataExchDefLine: Code[20]; DataExchDefLineName: Text[100]; ColumnCount: Integer)
    begin
        if DataExchLineDef.Get(DataExchDefCode, DataExchDefLine) then
            exit;
        DataExchLineDef.InsertRec(DataExchDefCode, DataExchDefLine, DataExchDefLineName, ColumnCount);
    end;

    procedure CreateUsageBasedGenericDataExchColumnDefinition(DataExchDefCode: Code[20]; DataExchDefLineCode: Code[20])
    var
        DataType: Option Text,Date,Decimal,DateTime;
        i: Integer;
        DataFormat: Text[100];
        CultureInfo: Text[10];
    begin
        RRef.GetTable(UsageDataGenericImport);
        for i := 1 to ArrayLen(GenericColumnArr) do
            if RRef.FieldExist(GenericFieldArr[1]) then begin
                FRef := RRef.Field(GenericFieldArr[i]);
                case FRef.Type of
                    FRef.Type::Text:
                        begin
                            DataFormat := '';
                            CultureInfo := '';
                            Evaluate(DataType, Format(FRef.Type));
                        end;
                    FRef.Type::Decimal:
                        begin
                            DataFormat := '';
                            CultureInfo := CultureInfoLbl;
                            Evaluate(DataType, Format(FRef.Type));
                        end;
                    FRef.Type::Code:
                        begin
                            DataFormat := '';
                            CultureInfo := '';
                            Evaluate(DataType, Format(FRef.Type::Text));
                        end;
                    FRef.Type::Date:
                        begin
                            DataFormat := DateFormatLbl;
                            CultureInfo := CultureInfoLbl;
                            Evaluate(DataType, Format(FRef.Type));
                        end;
                end;
                if not DataExchColumnDef.Get(DataExchDefCode, DataExchDefLineCode, GenericColumnArr[i]) then begin
                    DataExchColumnDef.InsertRecordForImport(DataExchDefCode, DataExchDefLineCode, GenericColumnArr[i], CopyStr(FRef.Name, 1, MaxStrLen(DataExchColumnDef.Name)), '', true, DataType, DataFormat, CultureInfo);
                    DataExchColumnDef.ValidateRec();
                end;
            end;
    end;

    procedure CreateUsageBasedDataExchangeMapping(DataExchDefCode: Code[20]; DataExchLineDefCode: Code[20]; TableId: Integer; NewName: Text[250]; MappingCodeunit: Integer; DataExchNoFieldId: Integer; DataExchLineFieldId: Integer)
    begin
        //TODO: Check in BC21 if OnPrem scope has been removed from InsertRec function in DataExchMapping table
        // DataExchMapping.InsertRec(DataExchDefCode, DataExchLineDefCode, TableId, NewName, MappingCodeunit, 0, 0);

        DataExchMapping.Init();
        DataExchMapping.Validate("Data Exch. Def Code", DataExchDefCode);
        DataExchMapping.Validate("Data Exch. Line Def Code", DataExchLineDefCode);
        DataExchMapping.Validate("Table ID", TableId);
        DataExchMapping.Validate(Name, NewName);
        DataExchMapping.Validate("Mapping Codeunit", MappingCodeunit);
        DataExchMapping.Validate("Data Exch. No. Field ID", DataExchNoFieldId);
        DataExchMapping.Validate("Data Exch. Line Field ID", DataExchLineFieldId);
        DataExchMapping.Insert(false);
    end;

    procedure CreateUsageBasedGenericDataExchangeFieldMapping(DataExchDefCode: Code[20]; DataExchDefLineCode: Code[20]; TableId: Integer)
    var
        i: Integer;
    begin
        for i := 1 to ArrayLen(GenericFieldArr) do
            if RRef.FieldExist(GenericFieldArr[i]) then begin
                FRef := RRef.Field(GenericFieldArr[i]);
                if FRef.Type in [FRef.Type::Text, FRef.Type::Decimal, FRef.Type::Date, FRef.Type::Code] then begin
                    DataExchFieldMapping.InsertRec(DataExchDefCode, DataExchDefLineCode, TableId, GenericColumnArr[i], GenericFieldArr[i], false, 1);
                    if FRef.Name in [UsageDataGenericImport.FieldName("Subscription ID"), UsageDataGenericImport.FieldName("Product ID"),
                                     UsageDataGenericImport.FieldName("Product Name"), UsageDataGenericImport.FieldName(Quantity)] then begin
                        DataExchFieldMapping."Overwrite Value" := true;
                        DataExchFieldMapping.Modify(false);
                    end;
                end;
            end;
    end;

    var
        UsageDataGenericImport: Record "Usage Data Generic Import";
        DataExchDef: Record "Data Exch. Def";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchColumnDef: Record "Data Exch. Column Def";
        DataExchMapping: Record "Data Exch. Mapping";
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
        RRef: RecordRef;
        FRef: FieldRef;
        UsageBasedDataExchDefCodeTxt: Label 'UsageBased', Locked = true;
        UsageBasedDataExchDefNameTxt: Label 'Usage Based Billing', Locked = true;
        UsageBasedDataExchDefLineCodeTxt: Label 'LINES', Locked = true;
        UsageBasedDataExchDefLineNameTxt: Label 'Usage data', Locked = true;
        CultureInfoLbl: Label 'de-DE', Locked = true;
        DateFormatLbl: Label 'dd.MM.yyyy', Locked = true;
        UsageBasedDataExchMappingTxt: Label 'UsageBased - Imported lines', Locked = true;
        GenericColumnArr: array[16] of Integer;
        GenericFieldArr: array[16] of Integer;
}
