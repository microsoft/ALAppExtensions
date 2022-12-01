// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132524 "Edit in Excel Test Library"
{
    /// <summary>    
    /// Calls the CreateDataEntityExportInfo function of the Edit in Excel Impl. codeunit. This function exists purely 
    /// for test purposes.
    /// </summary>
    /// <param name="TenantWebService">The tenant web service to create data entity export info for.</param>
    /// <param name="DataEntityExportInfoParam">The data entity export info created.</param>
    /// <param name="TenantWebServiceColumns">The columns in the webservice that should be added to the entity info.</param>
    /// <param name="SearchText">The search text of the user.</param>
    /// <param name="FilterClause">The filter on the page.</param>
    [Scope('OnPrem')]
    procedure CreateDataEntityExportInfo(var TenantWebService: Record "Tenant Web Service"; var DataEntityExportInfoParam: DotNet DataEntityExportInfo; var TenantWebServiceColumns: Record "Tenant Web Service Columns"; SearchText: Text; FilterClause: Text)
    var
        EditinExcelImpl: Codeunit "Edit in Excel Impl.";
    begin
        EditinExcelImpl.CreateDataEntityExportInfo(TenantWebService, DataEntityExportInfoParam, TenantWebServiceColumns, SearchText, FilterClause);
    end;

    /// <summary>    
    /// Calls the AssembleFilter function of the Edit in Excel Impl. codeunit. This function exists purely 
    /// for test purposes.
    /// </summary>
    /// <param name="EntityFilterCollectionNode">The main collection node that represents the whole filter</param>
    /// <param name="ODataJsonFilter">Structured filter json object</param>
    /// <param name="ODataJsonPayload">Structured filter payload</param>
    /// <param name="PageNumber">The page number filtering applies to.</param>
    [Scope('OnPrem')]
    procedure AssembleFilter(var EntityFilterCollectionNode: DotNet FilterCollectionNode; ODataJsonFilter: JsonObject; ODataJsonPayload: JsonObject; PageNumber: Integer)
    var
        EditinExcelImpl: Codeunit "Edit in Excel Impl.";
    begin
        EditinExcelImpl.AssembleFilter(EntityFilterCollectionNode, ODataJsonFilter, ODataJsonPayload, PageNumber);
    end;

    /// <summary>    
    /// Calls the ExternalizeODataObjectName function of the Edit in Excel Impl. codeunit. This function exists purely 
    /// for test purposes.
    /// </summary>
    /// <param name="Name">The name to convert to OData field</param>
    [Scope('OnPrem')]
    procedure ExternalizeODataObjectName(Name: Text) ConvertedName: Text
    var
        EditinExcelImpl: Codeunit "Edit in Excel Impl.";
    begin
        ConvertedName := EditinExcelImpl.ExternalizeODataObjectName(Name);
    end;

    /// <summary>
    /// Calls the ConvertStructuredFiltersToEntityFilterCollection function of the Edit in Excel Impl. codeunit. This function exists purely 
    /// for test purposes.
    /// </summary>
    /// <param name="StructuredFilterObject">Filter json object</param>
    /// <param name="ODataJsonPayload">Payload json binding edm types with al names of fields</param>
    /// <param name="FieldFilterGroupingOperator">The dictionary of already used operators on fields</param>
    /// <param name="PageNumber">Number of the filtered page</param>
    /// <param name="Excel Filter Node Type">Type of filtered applied on the node</param>
    /// <param name="FilterNodes">The dictionary of filtered field names and their filter collection nodes</param>
    [Scope('OnPrem')]
    procedure ConvertStructuredFiltersToEntityFilterCollection(StructuredFilterObject: JsonObject; var ODataJsonPayload: JsonObject; var EntityFilterCollectionNode: DotNet FilterCollectionNode; var FieldFilterGroupingOperator: Dictionary of [Text, Text]; PageNumber: Integer; ParentGroupingOperator: Enum "Excel Filter Node Type"; var FilterNodes: DotNet GenericDictionary2)
    var
        EditinExcelImpl: Codeunit "Edit in Excel Impl.";
    begin
        EditinExcelImpl.ConvertStructuredFiltersToEntityFilterCollection(StructuredFilterObject, ODataJsonPayload, FieldFilterGroupingOperator, PageNumber, ParentGroupingOperator, FilterNodes);
    end;

    /// <summary>
    /// Calls the GetEndPointAndCreateWorkbookJson function of the Edit in Excel Impl. codeunit. This function exists purely 
    /// for test purposes.
    /// </summary>
    /// <param name="ServiceName">The name of the web service</param>
    /// <param name="ODataJsonFilter">Filter json object</param>
    /// <param name="ODataJsonPayload">Payload json binding edm types with al names of fields</param>
    /// <param name="SearchFilter">The search parameter</param>
    [Scope('OnPrem')]
    procedure GetEndPointAndCreateWorkbookWStructuredFilter(ServiceName: Text[240]; ODataJsonFilter: JsonObject; ODataJsonPayload: JsonObject; SearchFilter: Text)
    var
        EditInExcelImpl: Codeunit "Edit in Excel Impl.";
    begin
        EditInExcelImpl.GetEndPointAndCreateWorkbookWStructuredFilter(ServiceName, ODataJsonFilter, ODataJsonPayload, SearchFilter);
    end;

    /// <summary>
    /// Calls the ReduceRedundantFilterCollectionNodes function of the Edit in Excel Impl. codeunit. This function exists purely 
    /// for test purposes.
    /// </summary>
    /// <param name="EntityfilterCollectionNode">The filter collection node to reduce</param>
    [Scope('OnPrem')]
    procedure ReduceRedundantFilterCollectionNodes(var EntityfilterCollectionNode: DotNet FilterCollectionNode)
    var
        EditInExcelImpl: Codeunit "Edit in Excel Impl.";
    begin
        EditInExcelImpl.ReduceRedundantFilterCollectionNodes(EntityfilterCollectionNode);
    end;

}
