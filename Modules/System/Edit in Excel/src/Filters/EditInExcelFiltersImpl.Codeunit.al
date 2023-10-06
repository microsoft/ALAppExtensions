// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Excel;

using System;

/// <summary>
/// This codeunit provides an interface to running Edit in Excel for a specific page.
/// </summary>
codeunit 1491 "Edit in Excel Filters Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        FieldFilters: DotNet GenericDictionary2; // Dictionary of [Text, DotNet FilterCollectionNode];
        FieldTypes: Dictionary of [Text, Text];
        FilterAlreadyExistErr: Label 'A filter for field %1 already exist, please use the existing entry.', Comment = '%1 = ODataFieldName, ex.: No_';
        FilterDoesNotExistErr: Label 'No filter exists for field %1.', Comment = '%1 = ODataFieldName, ex.: No_';
        EditInExcelTelemetryCategoryTxt: Label 'Edit in Excel Filters', Locked = true;
        ChildNodesJsonTok: Label 'childNodes', Locked = true;
        TypeJsonTok: Label 'type', Locked = true;
        LeftNodeJsonTok: Label 'leftNode', Locked = true;
        RightNodeJsonTok: Label 'rightNode', Locked = true;
        NameJsonTok: Label 'name', Locked = true;
        ValueJsonTok: Label 'value', Locked = true;
        TypeNotFoundTxt: Label 'The %1 json token was not found.', Locked = true;
        NodeTypeNotRecognizedTxt: Label 'Node type %1 was not recognized.', Locked = true;
        FilterContainsMultipleOperatorsTxt: Label 'The page filter contains multiple operators, the latter was removed.', Locked = true;
        FieldPayloadEdmTypeTok: Label 'fieldPayload.%1.edmType', Locked = true;

    procedure AddField(ODataFieldName: Text; EditinExcelFilterCollectionType: Enum "Edit in Excel Filter Collection Type"; EditInExcelEdmType: Enum "Edit in Excel Edm Type"): Interface "Edit in Excel Field Filter"
    begin
        TryAdd(ODataFieldName, EditinExcelFilterCollectionType, format(EditInExcelEdmType));
        exit(Get(ODataFieldName));
    end;

    procedure AddField(ODataFieldName: Text; EditInExcelFilterType: Enum "Edit in Excel Filter Type"; FilterValue: Text; EditInExcelEdmType: Enum "Edit in Excel Edm Type") EditinExcelFieldFilter: Interface "Edit in Excel Field Filter"
    begin
        EditinExcelFieldFilter := AddField(ODataFieldName, "Edit in Excel Filter Collection Type"::"and", EditInExcelEdmType);
        Get(ODataFieldName).AddFilterValue(EditInExcelFilterType, FilterValue);
    end;

    procedure Get(ODataFieldName: Text): Interface "Edit in Excel Field Filter"
    var
        EditinExcelFldFilterImpl: Codeunit "Edit in Excel Fld Filter Impl.";
        FilterCollectionNode: DotNet FilterCollectionNode;
        EdmType: Text;
    begin
        if not (FieldFilters.TryGetValue(ODataFieldName, FilterCollectionNode) or FieldTypes.Get(ODataFieldName, EdmType)) then
            Error(FilterDoesNotExistErr, ODataFieldName);

        EditinExcelFldFilterImpl.Initialize(ODataFieldName, EdmType, FilterCollectionNode, EditinExcelFldFilterImpl);
        exit(EditinExcelFldFilterImpl);
    end;

    procedure Remove(ODataFieldName: Text): Boolean
    begin
        exit(FieldFilters.Remove(ODataFieldName) and FieldTypes.Remove(ODataFieldName))
    end;

    procedure Contains(ODataFieldName: Text): Boolean
    begin
        exit(FieldFilters.ContainsKey(ODataFieldName) and FieldTypes.ContainsKey(ODataFieldName))
    end;

    internal procedure ConvertFromJsonFilters(JsonFilter: JsonObject; JsonPayload: JsonObject; PageId: Integer)
    var
        FieldFilterGroupingOperator: Dictionary of [Text, Enum "Edit in Excel Filter Collection Type"];
    begin
        ConvertStructuredFiltersToEntityFilterCollection(JsonFilter, JsonPayload, FieldFilterGroupingOperator, "Edit in Excel Filter Collection Type"::"and");
    end;

    internal procedure GetFilters(var SpecifiedFieldFilters: DotNet GenericDictionary2)
    begin
        SpecifiedFieldFilters := FieldFilters;
    end;

    procedure ConvertStructuredFiltersToEntityFilterCollection(StructuredFilterObject: JsonObject; ODataJsonPayload: JsonObject; var FieldFilterGroupingOperator: Dictionary of [Text, Enum "Edit in Excel Filter Collection Type"]; ParentGroupingOperator: Enum "Edit in Excel Filter Collection Type")
    var
        ChildNodesJsonFilterArray: JsonArray;
        TypeJsonToken: JsonToken;
        ChildNodesJsonToken: JsonToken;
        ExcelFilterNodeType: Enum "Excel Filter Node Type";
        FieldGroupingOperator: Enum "Edit in Excel Filter Collection Type";
        EditinExcelFilterType: Enum "Edit in Excel Filter Type";
        FilterValue: Text;
        NodeType: Text;
        ODataFieldName: Text;
        EdmType: Text;
    begin
        if not StructuredFilterObject.Get(TypeJsonTok, TypeJsonToken) then begin
            Session.LogMessage('0000I3U', StrSubstNo(TypeNotFoundTxt, TypeJsonTok), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
            exit;
        end;

        NodeType := TypeJsonToken.AsValue().AsText().ToLower();
        if not Enum::"Excel Filter Node Type".Names().Contains(NodeType) then begin
            Session.LogMessage('0000I3V', StrSubstNo(NodeTypeNotRecognizedTxt, NodeType), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
            exit;
        end;

        ExcelFilterNodeType := "Excel Filter Node Type".FromInteger("Excel Filter Node Type".Ordinals().Get("Excel Filter Node Type".Names().IndexOf(NodeType)));
        case ExcelFilterNodeType of
            "Excel Filter Node Type"::"and", "Excel Filter Node Type"::"or":
                begin
                    if not StructuredFilterObject.Get(ChildNodesJsonTok, ChildNodesJsonToken) then begin
                        Session.LogMessage('0000I3W', StrSubstNo(TypeNotFoundTxt, ChildNodesJsonTok), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
                        exit;
                    end;

                    ChildNodesJsonFilterArray := ChildNodesJsonToken.AsArray();

                    foreach ChildNodesJsonToken in ChildNodesJsonFilterArray do
                        ConvertStructuredFiltersToEntityFilterCollection(
                            ChildNodesJsonToken.AsObject(),
                            ODataJsonPayload,
                            FieldFilterGroupingOperator,
                            "Edit in Excel Filter Collection Type".FromInteger(ExcelFilterNodeType.AsInteger()));
                end;
            "Excel Filter Node Type"::lt, "Excel Filter Node Type"::le, "Excel Filter Node Type"::eq, "Excel Filter Node Type"::ge, "Excel Filter Node Type"::gt, "Excel Filter Node Type"::ne:
                begin
                    if not ReadNodeValues(StructuredFilterObject, ODataJsonPayload, ODataFieldName, EdmType, FilterValue) then
                        exit;

                    EditinExcelFilterType := "Edit in Excel Filter Type".FromInteger(ExcelFilterNodeType.AsInteger());

                    if not FieldFilterGroupingOperator.Get(ODataFieldName, FieldGroupingOperator) then begin
                        FieldFilterGroupingOperator.Add(ODataFieldName, ParentGroupingOperator);
                        TryAdd(ODataFieldName, "Edit in Excel Filter Collection Type".FromInteger(ParentGroupingOperator.AsInteger()), EdmType);
                    end else
                        if FieldGroupingOperator <> ParentGroupingOperator then begin
                            Session.LogMessage('0000I3X', FilterContainsMultipleOperatorsTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
                            exit; // OData does not support filtering on a field with both 'and' and 'or' hence if we see both, ignore the second type
                        end;
                    Get(ODataFieldName).AddFilterValue(EditInExcelFilterType, FilterValue);
                end;
        end;
    end;

    local procedure ReadNodeValues(JsonFilterObject: JsonObject; ODataJsonPayload: JsonObject; var ODataFieldName: Text;
                                    var EdmType: Text; var FilterValue: Text): Boolean
    var
        LeftNodeJsonToken: JsonToken;
        RightNodeJsonToken: JsonToken;
        NameJsonToken: JsonToken;
        TypeJsonToken: JsonToken;
    begin
        if not JsonFilterObject.Get(LeftNodeJsonTok, LeftNodeJsonToken) then begin
            Session.LogMessage('0000I3Y', StrSubstNo(TypeNotFoundTxt, LeftNodeJsonTok), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
            exit(false);
        end;

        // Get ODataFieldName
        if not LeftNodeJsonToken.AsObject().Get(NameJsonTok, NameJsonToken) then begin
            Session.LogMessage('0000I3Z', StrSubstNo(TypeNotFoundTxt, NameJsonTok), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
            exit(false);
        end;

        ODataFieldName := NameJsonToken.AsValue().AsText();

        // Get EdmType
        if not ODataJsonPayload.SelectToken(StrSubstNo(FieldPayloadEdmTypeTok, ODataFieldName), TypeJsonToken) then begin
            Session.LogMessage('0000I40', StrSubstNo(TypeNotFoundTxt, LeftNodeJsonTok), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
            exit(false);
        end;

        EdmType := TypeJsonToken.AsValue().AsText();

        // Get FilterValue
        if not JsonFilterObject.Get(RightNodeJsonTok, RightNodeJsonToken) then begin
            Session.LogMessage('0000I41', StrSubstNo(TypeNotFoundTxt, RightNodeJsonTok), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
            exit(false);
        end;
        if not RightNodeJsonToken.AsObject().Get(ValueJsonTok, NameJsonToken) then begin
            Session.LogMessage('0000I42', StrSubstNo(TypeNotFoundTxt, ValueJsonTok), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
            exit(false);
        end;

        FilterValue := NameJsonToken.AsValue().AsText();
        exit(true);
    end;

    local procedure TryAdd(ODataFieldName: Text; EditInExcelFilterOperatorType: Enum "Edit in Excel Filter Collection Type"; EdmType: Text)
    var
        FilterCollectionNode: DotNet FilterCollectionNode;
    begin
        if IsNull(FieldFilters) then
            FieldFilters := FieldFilters.Dictionary();

        if FieldFilters.ContainsKey(ODataFieldName) then
            Error(FilterAlreadyExistErr, ODataFieldName);

        FilterCollectionNode := FilterCollectionNode.FilterCollectionNode();
        FilterCollectionNode.Operator := format(EditInExcelFilterOperatorType);
        FieldFilters.Add(ODataFieldName, FilterCollectionNode);
        FieldTypes.Add(ODataFieldName, EdmType);
    end;

}
