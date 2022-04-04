// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 478 "Business Chart Impl."
{
    Access = Internal;

    var
        DotNetBusinessChartData: DotNet BusinessChartData;
        DotNetDataTable: DotNet DataTable;
        MeasureNameToValueMap: Dictionary of [Text, Text];
        IsInitialized: Boolean;
        InvalidDataTypeForMeasureErr: Label 'Data Type must be Integer or Decimal for Measure %1.', Comment = '%1 - name of the measure';

    procedure Initialize()
    var
        DotNetCultureInfo: DotNet CultureInfo;
    begin
        if not IsInitialized then begin
            DotNetDataTable := DotNetDataTable.DataTable('DataTable');
            DotNetCultureInfo := DotNetCultureInfo.CultureInfo(WindowsLanguage);
            DotNetDataTable.Locale := DotNetCultureInfo.InvariantCulture;

            DotNetBusinessChartData := DotNetBusinessChartData.BusinessChartData();
            IsInitialized := true;
        end;
        DotNetDataTable.Clear();
        DotNetDataTable.Columns.Clear();
        DotNetBusinessChartData.ClearMeasures();
        Clear(MeasureNameToValueMap);
    end;

    procedure SetShowChartCondensed(ShowChartCondensed: Boolean)
    begin
        DotNetBusinessChartData.ShowChartCondensed := ShowChartCondensed;
    end;

    procedure SetXDimension(Caption: Text; DataColumnType: Enum "Business Chart Data Type")
    begin
        AddDataColumn(Caption, DataColumnType);
        DotNetBusinessChartData.XDimension := Caption;
    end;

    procedure GetXDimension(): Text
    begin
        exit(DotNetBusinessChartData.XDimension);
    end;

    procedure GetXDimensionDataType(): Enum "Business Chart Data Type"
    var
        DotNetTypeName: Text;
    begin
        DotNetTypeName := Format(DotNetDataTable.Columns.Item(0).DataType);
        exit(GetBusinessChartDataType(DotNetTypeName));
    end;

    procedure AddMeasure(Caption: Text; MeasureVariant: Variant; DataColumnType: Enum "Business Chart Data Type"; ChartType: Enum "Business Chart Type")
    var
        DotNetDataMeasureType: DotNet DataMeasureType;
    begin
        if not (DataColumnType in [DataColumnType::Integer, DataColumnType::Decimal]) then
            Error(InvalidDataTypeForMeasureErr, Caption);
        AddDataColumn(Caption, DataColumnType);
        DotNetDataMeasureType := ChartType.AsInteger();
        DotNetBusinessChartData.AddMeasure(Caption, DotNetDataMeasureType);
        AddEntryToMapSafely(MeasureNameToValueMap, Caption, Format(MeasureVariant, 0, 9));
    end;

    procedure AddDataRowWithXDimension(XDimensionColumnValue: Text)
    var
        DotNetDataRow: DotNet DataRow;
    begin
        DotNetDataRow := DotNetDataTable.NewRow();
        DotNetDataRow.Item(GetXDimension(), XDimensionColumnValue);
        DotNetDataTable.Rows.Add(DotNetDataRow);
    end;

    procedure AddDataColumn(Caption: Text; ValueType: Enum "Business Chart Data Type")
    var
        DotNetDataColumn: DotNet DataColumn;
        DotNetSystemType: DotNet Type;
    begin
        DotNetDataColumn := DotNetDataColumn.DataColumn(Caption);
        DotNetDataColumn.Caption := Caption;
        DotNetDataColumn.ColumnName(Caption);
        DotNetDataColumn.DataType(DotNetSystemType.GetType(GetDotNetTypeName(ValueType)));
        DotNetDataTable.Columns.Add(DotNetDataColumn);
    end;

    procedure SetValue(MeasureName: Text; XAxisIndex: Integer; MeasureValueVariant: Variant)
    var
        DotNetDataRow: DotNet DataRow;
    begin
        DotNetDataRow := DotNetDataTable.Rows.Item(XAxisIndex);
        DotNetDataRow.Item(MeasureName, MeasureValueVariant);
    end;

    procedure SetValue(MeasureIndex: Integer; XAxisIndex: Integer; ValueVariant: Variant)
    var
        DotNetDataRow: DotNet DataRow;
        ColumnName: Text;
    begin
        DotNetDataRow := DotNetDataTable.Rows.Item(XAxisIndex);
        ColumnName := MeasureNameToValueMap.Keys().Get(MeasureIndex + 1);
        DotNetDataRow.Item(ColumnName, ValueVariant);
    end;

    procedure GetValue(MeasureName: Text; XAxisIndex: Integer; var MeasureValueVariant: Variant)
    var
        DotNetDataRow: DotNet DataRow;
    begin
        DotNetDataRow := DotNetDataTable.Rows.Item(XAxisIndex);
        MeasureValueVariant := DotNetDataRow.Item(MeasureName);
    end;

    procedure GetMaxNumberOfMeasures(): Integer
    var
        MaximumNumberOfColoursInChart: Integer;
    begin
        MaximumNumberOfColoursInChart := 6;
        exit(MaximumNumberOfColoursInChart);
    end;

    procedure Update(DotNetBusinessChartAddIn: DotNet BusinessChartAddIn)
    begin
        DotNetBusinessChartData.DataTable := DotNetDataTable;
        DotNetBusinessChartAddIn.Update(DotNetBusinessChartData);
    end;

    procedure GetMeasureNameToValueMap(): Dictionary of [Text, Text];
    begin
        exit(MeasureNameToValueMap)
    end;

    procedure WriteToXMLDocument(DotNetXMLDocument: DotNet XmlDocument)
    var
        TempBlob: Codeunit "Temp Blob";
        XMLElement: DotNet XmlElement;
        OutStream: OutStream;
        InStream: InStream;
        XMLLine: Text;
        XMLText: Text;
    begin
        TempBlob.CreateOutStream(OutStream);
        DotNetDataTable.WriteXml(OutStream);
        TempBlob.CreateInStream(InStream);
        while not InStream.EOS do begin
            InStream.ReadText(XMLLine);
            XMLText := XMLText + XMLLine;
        end;
        XMLElement := DotNetXMLDocument.CreateElement('DataTable', 'test', '');
        XMLElement.InnerXml(XMLText);
        DotNetXMLDocument.AppendChild(XMLElement);
    end;

    local procedure GetDotNetTypeName(BusinessChartDataType: Enum "Business Chart Data Type"): Text
    begin
        case BusinessChartDataType of
            BusinessChartDataType::String:
                exit('System.String');
            BusinessChartDataType::Integer:
                exit('System.Int32');
            BusinessChartDataType::Decimal:
                exit('System.Decimal');
            BusinessChartDataType::DateTime:
                exit('System.DateTime');
        end;
    end;

    local procedure GetBusinessChartDataType(DotNetTypeName: Text): Enum "Business Chart Data Type"
    begin
        case DotNetTypeName of
            'System.String':
                exit(Enum::"Business Chart Data Type"::String);
            'System.Int32':
                exit(Enum::"Business Chart Data Type"::Integer);
            'System.Decimal':
                exit(Enum::"Business Chart Data Type"::Decimal);
            'System.DateTime':
                exit(Enum::"Business Chart Data Type"::DateTime);
        end;
    end;

    local procedure AddEntryToMapSafely(Map: Dictionary of [Text, Text]; KeyText: Text; ValueText: Text)
    var
        KeyTextToAdd: Text;
        Index: Integer;
    begin
        KeyTextToAdd := KeyText;
        Index := 2;
        while (Map.ContainsKey(KeyTextToAdd)) do begin
            KeyTextToAdd := KeyText + '_' + Format(Index);
            Index += 1;
        end;

        Map.Add(KeyTextToAdd, ValueText);
    end;
}