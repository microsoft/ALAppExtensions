// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality for working with the business chart control add-in.
/// </summary>
codeunit 479 "Business Chart"
{
    Access = Public;

    var
        BusinessChartImpl: Codeunit "Business Chart Impl.";

    /// <summary>
    /// Initializes all the underlying objects needed for working with business charts.
    /// </summary>
    procedure Initialize()
    begin
        BusinessChartImpl.Initialize();
    end;

    /// <summary>
    /// Sets the x dimension on the business chart.
    /// </summary>
    /// <param name="Caption">x dimension caption.</param>
    /// <param name="BusinessChartDataType">The data type of the column.</param>
    procedure SetXDimension(Caption: Text; BusinessChartDataType: Enum "Business Chart Data Type")
    begin
        BusinessChartImpl.SetXDimension(Caption, BusinessChartDataType);
    end;

    /// <summary>
    /// Gets the x dimension caption.
    /// </summary>
    /// <returns>The x dimension caption.</returns>
    procedure GetXDimension(): Text
    begin
        exit(BusinessChartImpl.GetXDimension());
    end;

    /// <summary>
    /// Gets the x dimension data type.
    /// </summary>
    /// <returns>The x dimension data type.</returns>
    procedure GetXDimensionDataType(): Enum "Business Chart Data Type"
    begin
        exit(BusinessChartImpl.GetXDimensionDataType());
    end;

    /// <summary>
    /// Adds a new measure to the business chart.
    /// </summary>
    /// <param name="Caption">Measure caption.</param>
    /// <param name="MeasureValueVariant">The value of the measure.</param>
    /// <param name="DataColumnType">The data type of the measure.</param>
    /// <param name="BusinessChartType">The type of the business chart.</param>
    procedure AddMeasure(Caption: Text; MeasureValueVariant: Variant; DataColumnType: Enum "Business Chart Data Type"; BusinessChartType: Enum "Business Chart Type")
    begin
        BusinessChartImpl.AddMeasure(Caption, MeasureValueVariant, DataColumnType, BusinessChartType);
    end;

    /// <summary>
    /// Adds a new data row and sets the value of the x dimension column in this row to the specified value.
    /// </summary>
    /// <param name="XDimensionColumnValue">The value to assign to the x dimension column in the new row.</param>
    procedure AddDataRowWithXDimension(XDimensionColumnValue: Text)
    begin
        BusinessChartImpl.AddDataRowWithXDimension(XDimensionColumnValue);
    end;

    /// <summary>
    /// Adds the data column to the data table that the business chart is based on.
    /// </summary>
    /// <param name="Caption">Column caption.</param>
    /// <param name="ValueType">The data type of the column.</param>
    procedure AddDataColumn(Caption: Text; ValueType: Enum "Business Chart Data Type")
    begin
        BusinessChartImpl.AddDataColumn(Caption, ValueType);
    end;

    /// <summary>
    /// Sets the value of the scpecified measure at the specified index.
    /// </summary>
    /// <param name="MeasureName">The name of the measure</param>
    /// <param name="XAxisIndex">The X axis index.</param>
    /// <param name="MeasureValueVariant">The value of the measure to set.</param>
    procedure SetValue(MeasureName: Text; XAxisIndex: Integer; MeasureValueVariant: Variant)
    begin
        BusinessChartImpl.SetValue(MeasureName, XAxisIndex, MeasureValueVariant);
    end;

    /// <summary>
    /// Sets the value of the scpecified measure index at the specified x axis index.
    /// </summary>
    /// <param name="MeasureIndex">The index of the measure</param>
    /// <param name="XAxisIndex">The X axis index.</param>
    /// <param name="MeasureValueVariant">The value of the measure to set.</param>
    procedure SetValue(MeasureIndex: Integer; XAxisIndex: Integer; MeasureValueVariant: Variant)
    begin
        BusinessChartImpl.SetValue(MeasureIndex, XAxisIndex, MeasureValueVariant);
    end;

    /// <summary>
    /// Gets the value of the scpecified measure at the specified index.
    /// </summary>
    /// <param name="MeasureName">The name of the measure</param>
    /// <param name="XAxisIndex">The X axis index.</param>
    /// <param name="MeasureValueVariant">The returned value of the measure.</param>
    procedure GetValue(MeasureName: Text; XAxisIndex: Integer; var MeasureValueVariant: Variant)
    begin
        BusinessChartImpl.GetValue(MeasureName, XAxisIndex, MeasureValueVariant);
    end;

    /// <summary>
    /// Gets the maximum number of measures that the business chart can display.
    /// </summary>
    /// <returns>The maximum number of measures that the business chart can display.</returns>
    procedure GetMaxNumberOfMeasures(): Integer
    begin
        exit(BusinessChartImpl.GetMaxNumberOfMeasures());
    end;

    /// <summary>
    /// Updates the provided business chart control add-in.
    /// </summary>
    /// <param name="DotNetBusinessChartAddIn">The business chart add-in to update.</param>
    procedure Update(DotNetBusinessChartAddIn: DotNet BusinessChartAddIn)
    begin
        BusinessChartImpl.Update(DotNetBusinessChartAddIn);
    end;

    /// <summary>
    /// Gets the dictionary of measure names and values.
    /// </summary>
    /// <returns>The dictionary of measure names and values.</returns>
    procedure GetMeasureNameToValueMap(): Dictionary of [Text, Text];
    begin
        exit(BusinessChartImpl.GetMeasureNameToValueMap())
    end;

    /// <summary>
    /// Sets a value indicating whether the XAxis Margin is visible or not.
    /// </summary>
    /// <param name="ShowChartCondensed">Indicates whether the XAxis Margin is visible or not.</param>
    procedure SetShowChartCondensed(ShowChartCondensed: Boolean)
    begin
        BusinessChartImpl.SetShowChartCondensed(ShowChartCondensed);
    end;

    /// <summary>
    /// Exports the underlying data table to the provided XML document for testing purposes.
    /// </summary>
    /// <param name="DotNetXMLDocument">The resulting XML document.</param>
    internal procedure WriteToXMLDocument(DotNetXMLDocument: DotNet XmlDocument)
    begin
        BusinessChartImpl.WriteToXMLDocument(DotNetXMLDocument);
    end;
}