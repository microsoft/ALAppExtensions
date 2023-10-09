// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Excel;

using System;

/// <summary>
/// This codeunit provides an interface to create filters for Edit in Excel.
/// </summary>
codeunit 1490 "Edit in Excel Filters"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        EditinExcelFiltersImpl: Codeunit "Edit in Excel Filters Impl.";

    /// <summary>
    /// Add the specified field using 'and' collection type.
    /// </summary>
    /// <param name="ODataFieldName">The OData name of the field referenced.</param>
    /// <param name="EditInExcelEdmType">The Edm type of the OData field as specified in the $metadata document.</param>
    procedure AddField(ODataFieldName: Text; EditInExcelEdmType: Enum "Edit in Excel Edm Type"): Interface "Edit in Excel Field Filter"
    begin
        exit(EditinExcelFiltersImpl.AddField(ODataFieldName, "Edit in Excel Filter Collection Type"::"and", EditInExcelEdmType));
    end;

    /// <summary>
    /// Add the specified field with a specified collection type.
    /// </summary>
    /// <param name="ODataFieldName">The OData name of the field referenced.</param>
    /// <param name="EditInExcelFilterOperatorType">Specifies whether filters for this field have 'and' or 'or', such as Field1 = a|b|c (or operator) or Field1 = &lt;a&amp;>b&gt;amp;>c (and operator). Both operators for the same field is currently not supported.</param>
    /// <param name="EditInExcelEdmType">The Edm type of the OData field as specified in the $metadata document.</param>
    procedure AddField(ODataFieldName: Text; EditInExcelFilterOperatorType: Enum "Edit in Excel Filter Collection Type"; EditInExcelEdmType: Enum "Edit in Excel Edm Type"): Interface "Edit in Excel Field Filter"
    begin
        exit(EditinExcelFiltersImpl.AddField(ODataFieldName, EditInExcelFilterOperatorType, EditInExcelEdmType));
    end;

    /// <summary>
    /// Add the specified field with an initial value using 'and' collection type.
    /// This is mainly intended for fields that only filter on a single value.
    /// </summary>
    /// <param name="ODataFieldName">The OData name of the field referenced.</param>
    /// <param name="EditInExcelFilterType">The filter type, such as Equal, Greater than etc.</param>
    /// <param name="FilterValue">The value which the field should be Equal to, Greater than etc.</param>
    /// <param name="EditInExcelEdmType">The Edm type of the OData field as specified in the $metadata document.</param>
    procedure AddField(ODataFieldName: Text; EditInExcelFilterType: Enum "Edit in Excel Filter Type"; FilterValue: Text; EditInExcelEdmType: Enum "Edit in Excel Edm Type")
    begin
        EditinExcelFiltersImpl.AddField(ODataFieldName, EditInExcelFilterType, FilterValue, EditInExcelEdmType);
    end;

    /// <summary>
    /// Get the field filters for the specified field.
    /// </summary>
    /// <param name="ODataFieldName">The OData name of the field referenced.</param>
    /// <returns></returns>
    procedure Get(ODataFieldName: Text): Interface "Edit in Excel Field Filter"
    begin
        exit(EditinExcelFiltersImpl.Get(ODataFieldName));
    end;

    /// <summary>
    /// Removes the filter for the specified field.
    /// </summary>
    /// <param name="ODataFieldName">The OData name of the field referenced.</param>
    /// <returns>Whether the field was removed.</returns>
    procedure Remove(ODataFieldName: Text): Boolean
    begin
        exit(EditinExcelFiltersImpl.Remove(ODataFieldName));
    end;

    /// <summary>
    /// Check whether there is a filter for the specified field.
    /// </summary>
    /// <param name="ODataFieldName">The OData name of the field referenced.</param>
    /// <returns>Whether the field has been added. Note this returns true even if there are no filters.</returns>
    procedure Contains(ODataFieldName: Text): Boolean
    begin
        exit(EditinExcelFiltersImpl.Contains(ODataFieldName));
    end;

    internal procedure GetFilters(var SpecifiedFieldFilters: DotNet GenericDictionary2)
    begin
        EditinExcelFiltersImpl.GetFilters(SpecifiedFieldFilters);
    end;

    internal procedure ReadFromJsonFilters(JsonFilter: JsonObject; JsonPayload: JsonObject; PageId: Integer)
    begin
        EditinExcelFiltersImpl.ConvertFromJsonFilters(JsonFilter, JsonPayload, PageId);
    end;
}
