// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135012 "Business Chart Test"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit "Library Assert";
        ExpectedValueTxt: Label 'Expected value: %1', Comment = '%1 - the expected value in the assertion.';
        MeasureTxt: Label 'Measure_%1', Comment = '%1 - the name of the measure.';
        ColumnTxt: Label 'col. %1', Comment = '%1 - the name of the column.';
        NotAllowedDataTypeTxt: Label 'Data Type must be Integer or Decimal for Measure %1.', Comment = '%1 - measure name.';
        ExpectedValueForIndexTxt: Label 'Expected value <%1> for index <%2>', Comment = '%1 - value; %2 - index.';

    [Test]
    procedure TestSetGetValue()
    var
        BusinessChart: Codeunit "Business Chart";
        ValueVariant: Variant;
        ExpectedInt: Integer;
        ActualInt: Integer;
    begin
        CreateChart(BusinessChart, 1, 1);
        ExpectedInt := Date2DMY(WorkDate(), 3);
        BusinessChart.SetValue(GetMeasureName(1), 0, ExpectedInt);

        BusinessChart.GetValue(GetMeasureName(1), 0, ValueVariant);
        Evaluate(ActualInt, Format(ValueVariant, 0, 9), 9);
        Assert.AreEqual(ExpectedInt, ActualInt, StrSubstNo(ExpectedValueTxt, ExpectedInt));
    end;

    [Test]
    procedure TestGetXValue()
    var
        BusinessChart: Codeunit "Business Chart";
        ValueVariant: Variant;
        ExpectedValue: Text[80];
        Index: Integer;
    begin
        CreateChart(BusinessChart, 0, 3);
        Index := 1;
        ExpectedValue := GetColumnName(Index + 1);

        BusinessChart.GetValue(BusinessChart.GetXDimension(), Index, ValueVariant);
        Assert.AreEqual(ExpectedValue, Format(ValueVariant, 0, 9), StrSubstNo(ExpectedValueTxt, ExpectedValue));
    end;

    [Test]
    procedure TestGetMeasureValueString()
    var
        BusinessChart: Codeunit "Business Chart";
        Index: Integer;
    begin
        CreateChart(BusinessChart, 4, 0);
        Index := 2;
        Assert.AreEqual(
          Format(Index + 1),
          BusinessChart.GetMeasureNameToValueMap().Values().Get(Index + 1),
          StrSubstNo(ExpectedValueForIndexTxt, Index + 1, Index));
    end;

    [Test]
    procedure TestMeasureDataTypeInteger()
    begin
        VerifyAllowedMeasureDateType(Enum::"Business Chart Data Type"::Integer);
    end;

    [Test]
    procedure TestMeasureDataTypeDecimal()
    begin
        VerifyAllowedMeasureDateType(Enum::"Business Chart Data Type"::Decimal);
    end;

    [Test]
    procedure TestNotAllowedMeasureDataTypeString()
    begin
        asserterror VerifyAllowedMeasureDateType(Enum::"Business Chart Data Type"::String);
        Assert.ExpectedError(StrSubstNo(NotAllowedDataTypeTxt, GetMeasureName(0)))
    end;

    [Test]
    procedure TestNotAllowedMeasureDataTypeDateTime()
    begin
        asserterror VerifyAllowedMeasureDateType(Enum::"Business Chart Data Type"::DateTime);
        Assert.ExpectedError(StrSubstNo(NotAllowedDataTypeTxt, GetMeasureName(0)))
    end;

    [Test]
    procedure TestSystemTypeString()
    begin
        VerifySystemTypeOnXAxis(Enum::"Business Chart Data Type"::String);
    end;

    [Test]
    procedure TestSystemTypeInteger()
    begin
        VerifySystemTypeOnXAxis(Enum::"Business Chart Data Type"::Integer);
    end;

    [Test]
    procedure TestSystemTypeDecimal()
    begin
        VerifySystemTypeOnXAxis(Enum::"Business Chart Data Type"::Decimal);
    end;

    [Test]
    procedure TestSystemTypeDateTime()
    begin
        VerifySystemTypeOnXAxis(Enum::"Business Chart Data Type"::DateTime);
    end;

    [Test]
    procedure TestOutOfIndex()
    var
        BusinessChart: Codeunit "Business Chart";
    begin
        CreateChart(BusinessChart, 1, 1);

        asserterror BusinessChart.SetValue(-1, -1, 1);
        asserterror BusinessChart.SetValue(1, 1, 1);
    end;

    [Test]
    procedure TestChartTableToXML()
    var
        BusinessChart: Codeunit "Business Chart";
        BusinessChartTestLibrary: Codeunit "Business Chart Test Library";
        DotNetXmlDocument: DotNet XmlDocument;
        DotNetXmlNode: DotNet XmlNode;
        DotNetXmlNodeSingle: DotNet XmlNode;
        DotNetXmlNodeList: DotNet XmlNodeList;
        DotNetXmlElement: DotNet XmlElement;
        i: Integer;
        j: Integer;
    begin
        CreateChart(BusinessChart, 2, 3);

        DotNetXmlDocument := DotNetXmlDocument.XmlDocument();
        BusinessChartTestLibrary.WriteToXMLDocument(BusinessChart, DotNetXmlDocument);

        DotNetXmlElement := DotNetXmlDocument.DocumentElement;
        DotNetXmlNodeList := DotNetXmlElement.SelectNodes('DocumentElement/DataTable');
        for i := 1 to DotNetXmlNodeList.Count do begin
            DotNetXmlNode := DotNetXmlNodeList.Item(i - 1);
            DotNetXmlNodeSingle := DotNetXmlNode.SelectSingleNode('Column_No.');
            Assert.AreEqual(DotNetXmlNodeSingle.InnerXml, GetColumnName(i), StrSubstNo(ExpectedValueTxt, GetColumnName(i)));
            for j := 1 to 2 do begin
                DotNetXmlNodeSingle := DotNetXmlNode.SelectSingleNode(GetMeasureName(j));
                Assert.AreEqual(DotNetXmlNodeSingle.InnerXml, Format(j * i), StrSubstNo(ExpectedValueTxt, j * i));
            end;
        end;
    end;

    local procedure VerifySystemTypeOnXAxis(DataType: Enum "Business Chart Data Type")
    var
        BusinessChart: Codeunit "Business Chart";
    begin
        BusinessChart.Initialize();
        BusinessChart.SetXDimension('Test', DataType);
        Assert.AreEqual(BusinessChart.GetXDimensionDataType(), DataType, 'Not expected data type.')
    end;

    local procedure CreateChart(var BusinessChart: Codeunit "Business Chart"; MeasuresCount: Integer; ColumnsCount: Integer)
    var
        i: Integer;
        j: Integer;
    begin
        BusinessChart.Initialize();
        BusinessChart.SetXDimension('Column_No.', Enum::"Business Chart Data Type"::String);
        for i := 1 to MeasuresCount do
            BusinessChart.AddMeasure(GetMeasureName(i), i, Enum::"Business Chart Data Type"::Integer, Enum::"Business Chart Type"::Point);
        for j := 1 to ColumnsCount do begin
            BusinessChart.AddDataRowWithXDimension(GetColumnName(j));
            for i := 1 to MeasuresCount do
                BusinessChart.SetValue(i - 1, j - 1, j * i);
        end;
    end;

    local procedure GetMeasureName(Index: Integer): Text[80]
    begin
        exit(StrSubstNo(MeasureTxt, Index));
    end;

    local procedure GetColumnName(Index: Integer): Text[80]
    begin
        exit(StrSubstNo(ColumnTxt, Index));
    end;

    local procedure VerifyAllowedMeasureDateType(DataType: Enum "Business Chart Data Type")
    var
        BusinessChart: Codeunit "Business Chart";
    begin
        BusinessChart.Initialize();
        BusinessChart.AddMeasure(GetMeasureName(0), 0, DataType, Enum::"Business Chart Type"::Point);
    end;
}

