// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Integration.Excel;

using System.TestLibraries.Integration.Excel;
using System.Integration.Excel;
using System;
using System.TestLibraries.Utilities;
codeunit 132526 "Edit in Excel Filters Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;

    var
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure TestEditInExcelStructuredFiltersDateTime()
    var
        EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
        EditinExcelFilters: Codeunit "Edit in Excel Filters";
        JsonFilter: Text;
        JsonPayload: Text;
        DateText: Text;
        FilterJsonObject: JsonObject;
        PayloadJsonObject: JsonObject;
        FieldFilters: DotNet GenericDictionary2;
        FilterCollectionNode: DotNet FilterCollectionNode;
        FilterBinaryNode: DotNet FilterBinaryNode;
    begin
        // [Scenario] User clicks "Edit in Excel" without choosing additional filters. BC sends the default date filter

        // [Given] A Json Structured filter and Payload, TenantWebservice exist and is enabled
        JsonFilter := '{"type":"and","childNodes":[{"type":"and","childNodes":[{"type":"ge","leftNode":{"type":"var","name":"Date_Filter"},"rightNode":{"type":"Edm.DateTimeOffset constant","value":"0001-01-01T00:00:00"}},{"type":"le","leftNode":{"type":"var","name":"Date_Filter"},"rightNode":{"type":"Edm.DateTimeOffset constant","value":"2024-01-25T00:00:00"}}]}]}';
        JsonPayload := '{ "fieldPayload": {"Date_Filter": {"alName": "Date Filter","validInODataFilter": true,"edmType": "Edm.DateTimeOffset"}}}';
        LibraryAssert.IsTrue(FilterJsonObject.ReadFrom(JsonFilter), 'Could not read json filter');
        LibraryAssert.IsTrue(PayloadJsonObject.ReadFrom(JsonPayload), 'Could not read json payload');

        // [When] Edit in Excel filters are created
        EditinExcelTestLibrary.ReadFromJsonFilters(EditinExcelFilters, FilterJsonObject, PayloadJsonObject, Page::"Edit in Excel List");

        // [Then] The filters match expectations
        EditinExcelTestLibrary.GetFilters(EditinExcelFilters, FieldFilters);
        LibraryAssert.IsFalse(IsNull(FieldFilters), 'No field filters created.');
        LibraryAssert.AreEqual(1, FieldFilters.Count(), 'Incorrect number of fields being filtered.');
        FilterCollectionNode := FieldFilters.Item('Date_Filter');
        LibraryAssert.AreEqual(2, FilterCollectionNode.Collection.Count(), 'Incorrect number of filters for field 0');
        LibraryAssert.AreEqual('and', FilterCollectionNode.Operator, 'Incorrect operator for field 0');

        FilterBinaryNode := FilterCollectionNode.Collection.Item(0);
        LibraryAssert.AreEqual('Date_Filter', FilterBinaryNode.Left.Field, 'Incorrect field name for field 0 filter 0');
        LibraryAssert.AreEqual('Edm.DateTimeOffset', FilterBinaryNode.Left.Type, 'Incorrect type for field 0 filter 0');
        LibraryAssert.AreEqual('ge', FilterBinaryNode.Operator, 'Incorrect operator for field 0 filter 0');
        DateText := '0001-01-01T00:00:00';
        LibraryAssert.AreEqual(DateText, FilterBinaryNode.Right, 'Incorrect Right value for field 0 filter 0');

        FilterBinaryNode := FilterCollectionNode.Collection.Item(1);
        LibraryAssert.AreEqual('Date_Filter', FilterBinaryNode.Left.Field, 'Incorrect field name for field 0 filter 1');
        LibraryAssert.AreEqual('Edm.DateTimeOffset', FilterBinaryNode.Left.Type, 'Incorrect type for field 0 filter 1');
        LibraryAssert.AreEqual('le', FilterBinaryNode.Operator, 'Incorrect operator for field 0 filter 1');
        DateText := '2024' + '-01-25T00:00:00';
        LibraryAssert.AreEqual(DateText, FilterBinaryNode.Right, 'Incorrect Right value for field 0 filter 1');
    end;

    [Test]
    procedure TestEditInExcelStructuredFilterOneChosenFilter()
    var
        EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
        EditinExcelFilters: Codeunit "Edit in Excel Filters";
        JsonFilter: Text;
        JsonPayload: Text;
        DateText: Text;
        FilterJsonObject: JsonObject;
        PayloadJsonObject: JsonObject;
        FieldFilters: DotNet GenericDictionary2;
        FilterCollectionNode: DotNet FilterCollectionNode;
        FilterBinaryNode: DotNet FilterBinaryNode;
    begin
        // [Scenario] User chooses one filter, with BC appending the default date filter as well

        // [Given] Filter and Payload JSON Objects, containing the date filter and the filter chosen by the user
        JsonFilter := '{"type":"and","childNodes":[{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"01121212"}},{"type":"or","childNodes":[{"type":"ge","leftNode":{"type":"var","name":"Date_Filter"},"rightNode":{"type":"Edm.DateTimeOffset constant","value":"0001-01-01T00:00:00"}},{"type":"le","leftNode":{"type":"var","name":"Date_Filter"},"rightNode":{"type":"Edm.DateTimeOffset constant","value":"2024-01-25T00:00:00"}}]}]}';
        JsonPayload := '{ "fieldPayload": { "No": { "alName": "No.", "validInODataFilter": true, "edmType": "Edm.String" }, "Date_Filter": { "alName": "Date Filter", "validInODataFilter": true, "edmType": "Edm.DateTimeOffset" }}}';
        LibraryAssert.IsTrue(FilterJsonObject.ReadFrom(JsonFilter), 'Could not read json filter');
        LibraryAssert.IsTrue(PayloadJsonObject.ReadFrom(JsonPayload), 'Could not read json payload');

        // [When] Edit in Excel filters are created
        EditinExcelTestLibrary.ReadFromJsonFilters(EditinExcelFilters, FilterJsonObject, PayloadJsonObject, Page::"Edit in Excel List");

        // [Then] The filters match expectations
        EditinExcelTestLibrary.GetFilters(EditinExcelFilters, FieldFilters);
        LibraryAssert.IsFalse(IsNull(FieldFilters), 'No field filters created.');
        LibraryAssert.AreEqual(2, FieldFilters.Count(), 'Incorrect number of fields being filtered.');

        // Date_Filter filter
        FilterCollectionNode := FieldFilters.Item('Date_Filter');
        LibraryAssert.AreEqual(2, FilterCollectionNode.Collection.Count(), 'Incorrect number of filters for field 0');
        LibraryAssert.AreEqual('or', FilterCollectionNode.Operator, 'Incorrect operator for field 0');

        FilterBinaryNode := FilterCollectionNode.Collection.Item(0);
        LibraryAssert.AreEqual('Date_Filter', FilterBinaryNode.Left.Field, 'Incorrect field name for field 0 filter 0');
        LibraryAssert.AreEqual('Edm.DateTimeOffset', FilterBinaryNode.Left.Type, 'Incorrect type for field 0 filter 0');
        LibraryAssert.AreEqual('ge', FilterBinaryNode.Operator, 'Incorrect operator for field 0 filter 0');
        DateText := '0001-01-01T00:00:00';
        LibraryAssert.AreEqual(DateText, FilterBinaryNode.Right, 'Incorrect Right value for field 0 filter 0');

        FilterBinaryNode := FilterCollectionNode.Collection.Item(1);
        LibraryAssert.AreEqual('Date_Filter', FilterBinaryNode.Left.Field, 'Incorrect field name for field 0 filter 1');
        LibraryAssert.AreEqual('Edm.DateTimeOffset', FilterBinaryNode.Left.Type, 'Incorrect type for field 0 filter 1');
        LibraryAssert.AreEqual('le', FilterBinaryNode.Operator, 'Incorrect operator for field 0 filter 1');
        DateText := '2024' + '-01-25T00:00:00';
        LibraryAssert.AreEqual(DateText, FilterBinaryNode.Right, 'Incorrect Right value for field 0 filter 1');

        // No filter
        FilterCollectionNode := FieldFilters.Item('No');
        LibraryAssert.AreEqual(1, FilterCollectionNode.Collection.Count(), 'Incorrect number of filters for field 1');
        LibraryAssert.AreEqual('and', FilterCollectionNode.Operator, 'Incorrect operator for field 1');

        FilterBinaryNode := FilterCollectionNode.Collection.Item(0);
        LibraryAssert.AreEqual('No', FilterBinaryNode.Left.Field, 'Incorrect field name for field 1 filter 1');
        LibraryAssert.AreEqual('Edm.String', FilterBinaryNode.Left.Type, 'Incorrect type for field 1 filter 1');
        LibraryAssert.AreEqual('eq', FilterBinaryNode.Operator, 'Incorrect operator for field 1 filter 1');
        LibraryAssert.AreEqual('01121212', FilterBinaryNode.Right, 'Incorrect Right value for field 1 filter 1');
    end;

    [Test]
    procedure TestEditInExcelStructuredFilterSingleFilter()
    var
        EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
        EditinExcelFilters: Codeunit "Edit in Excel Filters";
        JsonFilter: Text;
        JsonPayload: Text;
        FilterJsonObject: JsonObject;
        PayloadJsonObject: JsonObject;
        FieldFilters: DotNet GenericDictionary2;
        FilterCollectionNode: DotNet FilterCollectionNode;
        FilterBinaryNode: DotNet FilterBinaryNode;
    begin
        // [Scenario] Edit in Excel API is called with only a single filter passed

        // [Given] A Filter object with one filter, Payload object
        JsonFilter := '{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"01121212"}}';
        JsonPayload := '{ "fieldPayload": { "No": { "alName": "No.", "validInODataFilter": true, "edmType": "Edm.String" }}}';
        LibraryAssert.IsTrue(FilterJsonObject.ReadFrom(JsonFilter), 'Could not read json filter');
        LibraryAssert.IsTrue(PayloadJsonObject.ReadFrom(JsonPayload), 'Could not read json payload');

        // [When] Edit in Excel filters are created
        EditinExcelTestLibrary.ReadFromJsonFilters(EditinExcelFilters, FilterJsonObject, PayloadJsonObject, Page::"Edit in Excel List");

        // [Then] The filters match expectations
        EditinExcelTestLibrary.GetFilters(EditinExcelFilters, FieldFilters);
        LibraryAssert.IsFalse(IsNull(FieldFilters), 'No field filters created.');
        LibraryAssert.AreEqual(1, FieldFilters.Count(), 'Incorrect number of fields being filtered.');

        // No filter
        FilterCollectionNode := FieldFilters.Item('No');
        LibraryAssert.AreEqual(1, FilterCollectionNode.Collection.Count(), 'Incorrect number of filters for field 0');
        LibraryAssert.AreEqual('and', FilterCollectionNode.Operator, 'Incorrect operator for field 0');

        FilterBinaryNode := FilterCollectionNode.Collection.Item(0);
        LibraryAssert.AreEqual('No', FilterBinaryNode.Left.Field, 'Incorrect field name for field 0 filter 1');
        LibraryAssert.AreEqual('Edm.String', FilterBinaryNode.Left.Type, 'Incorrect type for field 0 filter 1');
        LibraryAssert.AreEqual('eq', FilterBinaryNode.Operator, 'Incorrect operator for field 0 filter 1');
        LibraryAssert.AreEqual('01121212', FilterBinaryNode.Right, 'Incorrect Right value for field 0 filter 1');
    end;

    [Test]
    procedure TestEditInExcelStructuredFilterNoFilter()
    var
        EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
        EditinExcelFilters: Codeunit "Edit in Excel Filters";
        JsonFilter: Text;
        JsonPayload: Text;
        FilterJsonObject: JsonObject;
        PayloadJsonObject: JsonObject;
        FieldFilters: DotNet GenericDictionary2;
    begin
        // [Scenario] Empty JSON filter object is passed when calling Edit in Excel

        // [Given] An empty object is passed in filter and payload
        JsonFilter := '{}';
        JsonPayload := '{}';
        LibraryAssert.IsTrue(FilterJsonObject.ReadFrom(JsonFilter), 'Could not read json filter');
        LibraryAssert.IsTrue(PayloadJsonObject.ReadFrom(JsonPayload), 'Could not read json payload');

        // [When] Edit in Excel filters are created
        EditinExcelTestLibrary.ReadFromJsonFilters(EditinExcelFilters, FilterJsonObject, PayloadJsonObject, Page::"Edit in Excel List");

        // [Then] The filters match expectations
        EditinExcelTestLibrary.GetFilters(EditinExcelFilters, FieldFilters);
        LibraryAssert.IsTrue(IsNull(FieldFilters), 'Field filters were created.');
    end;

    [Test]
    procedure TestEditInExcelStructuredFilterIllegalFilter()
    var
        EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
        EditinExcelFilters: Codeunit "Edit in Excel Filters";
        JsonFilter: Text;
        JsonPayload: Text;
        FilterJsonObject: JsonObject;
        PayloadJsonObject: JsonObject;
        FieldFilters: DotNet GenericDictionary2;
        FilterCollectionNode: DotNet FilterCollectionNode;
        FilterBinaryNode: DotNet FilterBinaryNode;
    begin
        // [Scenario] API is called with a json filter that contains bor "OR" and "AND" operators, which is not supported by OData

        // [Given] A Json filter with both or and and operator on the Date field, Json Payload
        JsonFilter := '{"type":"and","childNodes":[{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"1000"}},{"type":"or","childNodes":[{"type":"ge","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"0"}},{"type":"le","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"100"}}]}]}';
        JsonPayload := '{ "fieldPayload": { "No": { "alName": "No.", "validInODataFilter": true, "edmType": "Edm.String" }}}';
        LibraryAssert.IsTrue(FilterJsonObject.ReadFrom(JsonFilter), 'Could not read json filter');
        LibraryAssert.IsTrue(PayloadJsonObject.ReadFrom(JsonPayload), 'Could not read json payload');

        // [When] Edit in Excel filters are created
        EditinExcelTestLibrary.ReadFromJsonFilters(EditinExcelFilters, FilterJsonObject, PayloadJsonObject, Page::"Edit in Excel List");

        // [Then] The filters match expectations
        EditinExcelTestLibrary.GetFilters(EditinExcelFilters, FieldFilters);
        LibraryAssert.IsFalse(IsNull(FieldFilters), 'No field filters created.');
        LibraryAssert.AreEqual(1, FieldFilters.Count(), 'Incorrect number of fields being filtered.');

        // No filter
        FilterCollectionNode := FieldFilters.Item('No');
        LibraryAssert.AreEqual(1, FilterCollectionNode.Collection.Count(), 'Incorrect number of filters for field 0');
        LibraryAssert.AreEqual('and', FilterCollectionNode.Operator, 'Incorrect operator for field 0');

        FilterBinaryNode := FilterCollectionNode.Collection.Item(0);
        LibraryAssert.AreEqual('No', FilterBinaryNode.Left.Field, 'Incorrect field name for field 0 filter 1');
        LibraryAssert.AreEqual('Edm.String', FilterBinaryNode.Left.Type, 'Incorrect type for field 0 filter 1');
        LibraryAssert.AreEqual('eq', FilterBinaryNode.Operator, 'Incorrect operator for field 0 filter 1');
        LibraryAssert.AreEqual('1000', FilterBinaryNode.Right, 'Incorrect Right value for field 0 filter 1');
    end;
}
