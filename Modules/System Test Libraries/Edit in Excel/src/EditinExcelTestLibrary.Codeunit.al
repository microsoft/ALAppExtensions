// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132524 "Edit in Excel Test Library"
{
#if not CLEAN22
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
#endif

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
    /// Calls the ReadFromJsonFilters function of the Edit in Excel Filters codeunit. This function exists purely 
    /// for test purposes.
    /// </summary>
    /// <param name="EditinExcelFilters">The excel filter codeunit onto which the filters are applied.</param>
    /// <param name="JsonFilter">Filter json object.</param>
    /// <param name="JsonPayload">Payload json binding edm types with al names of fields.</param>
    /// <param name="PageId">The ID of the page being filtered on.</param>
    [Scope('OnPrem')]
    procedure ReadFromJsonFilters(var EditinExcelFilters: Codeunit "Edit in Excel Filters"; JsonFilter: JsonObject; JsonPayload: JsonObject; PageId: Integer)
    begin
        EditinExcelFilters.ReadFromJsonFilters(JsonFilter, JsonPayload, PageId);
    end;

    /// <summary>
    /// Calls the GetFilters function of the Edit in Excel Filters codeunit. This function exists purely 
    /// for test purposes.
    /// </summary>
    /// <param name="EditinExcelFilters">The excel filter codeunit onto which the filters are applied.</param>
    /// <param name="FieldFilters">Dictionary of [Text, DotNet FilterCollectionNode], (FieldName, FiltersForField).</param>
    [Scope('OnPrem')]
    procedure GetFilters(var EditinExcelFilters: Codeunit "Edit in Excel Filters"; var FieldFilters: DotNet GenericDictionary2)
    begin
        EditinExcelFilters.GetFilters(FieldFilters);
    end;

    /// <summary>
    /// Calls the ReduceRedundantFilterCollectionNodes function of the Edit in Excel Impl. codeunit. This function exists purely 
    /// for test purposes.
    /// </summary>
    /// <param name="EntityfilterCollectionNode">The filter collection node to reduce</param>
    [Scope('OnPrem')]
    procedure ReduceRedundantFilterCollectionNodes(var EntityfilterCollectionNode: DotNet FilterCollectionNode)
    var
        EditinExcelWorkbookImpl: Codeunit "Edit in Excel Workbook Impl.";
    begin
        EditinExcelWorkbookImpl.ReduceRedundantFilterCollectionNodes(EntityfilterCollectionNode);
    end;

}
