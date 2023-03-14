// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides methods for creating and modifying web services, accessing web service URLs, and getting and setting web service filters and clauses.
/// </summary>
codeunit 9750 "Web Service Management"
{
    Access = Public;

    var
        WebServiceManagementImpl: Codeunit "Web Service Management Impl.";

    /// <summary>
    /// Creates a web service for a given object. If the web service already exists, it modifies the web service accordingly.
    /// This method should be used for On-Prem scenarios only. Calling this method in SaaS will throw a runtime error.
    /// </summary>
    /// <param name="ObjectType">The type of the object.</param>
    /// <param name="ObjectId">The ID of the object.</param>
    /// <param name="ObjectName">The name of the object.</param>
    /// <param name="Published">Indicates whether the web service is published or not.</param>
    [Scope('OnPrem')]
    procedure CreateWebService(ObjectType: Option; ObjectId: Integer; ObjectName: Text; Published: Boolean)
    begin
        WebServiceManagementImpl.CreateWebService(ObjectType, ObjectId, ObjectName, Published);
    end;

    /// <summary>
    /// Creates a tenant web service for a given object. If the tenant web service already exists, it modifies the tenant web service accordingly.
    /// </summary>
    /// <param name="ObjectType">The type of the object.</param>
    /// <param name="ObjectId">The ID of the object.</param>
    /// <param name="ObjectName">The name of the object.</param>
    /// <param name="Published">Indicates whether the web service is published or not.</param>
    procedure CreateTenantWebService(ObjectType: Option; ObjectId: Integer; ObjectName: Text; Published: Boolean)
    begin
        WebServiceManagementImpl.CreateTenantWebService(ObjectType, ObjectId, ObjectName, Published);
    end;

    /// <summary>
    /// Gets the web service URL for a given Web Service Aggregate record and client type.
    /// </summary>
    /// <param name="WebServiceAggregate">The record for getting web service URL.</param>
    /// <param name="ClientType">The client type of the URL. Clients are SOAP, ODataV3 and ODataV4.</param>
    /// <returns>Web service URL for the given record.</returns>
    procedure GetWebServiceUrl(WebServiceAggregate: Record "Web Service Aggregate"; ClientType: Enum "Client Type"): Text
    begin
        exit(WebServiceManagementImpl.GetWebServiceUrl(WebServiceAggregate, ClientType));
    end;

    /// <summary>
    /// Creates tenant web service columns from temporary records.
    /// </summary>
    /// <param name="TenantWebServiceColumns">Record that the columns from temporary records are inserted to.</param>
    /// <param name="TempTenantWebServiceColumns">Temporary record that the columns are inserted from.</param>
    /// <param name="TenantWebServiceRecordId">The ID of the Tenant Web Service corresponding to columns.</param>
    procedure CreateTenantWebServiceColumnsFromTemp(var TenantWebServiceColumns: Record "Tenant Web Service Columns"; var TempTenantWebServiceColumns: Record "Tenant Web Service Columns" temporary; TenantWebServiceRecordId: RecordID)
    begin
        WebServiceManagementImpl.CreateTenantWebServiceColumnsFromTemp(TenantWebServiceColumns, TempTenantWebServiceColumns, TenantWebServiceRecordId);
    end;

    /// <summary>
    /// Creates a tenant web service filter from a record reference.
    /// </summary>
    /// <param name="TenantWebServiceFilter">Record that the filter from record reference is inserted to.</param>
    /// <param name="RecordRef">Record reference that the filter is inserted from.</param>
    /// <param name="TenantWebServiceRecordId">The ID of the Tenant Web Service corresponding to the filter.</param>
    procedure CreateTenantWebServiceFilterFromRecordRef(var TenantWebServiceFilter: Record "Tenant Web Service Filter"; var RecordRef: RecordRef; TenantWebServiceRecordId: RecordID)
    begin
        WebServiceManagementImpl.CreateTenantWebServiceFilterFromRecordRef(TenantWebServiceFilter, RecordRef, TenantWebServiceRecordId);
    end;

    /// <summary>
    /// Returns the tenant web service filter for a given record.
    /// </summary>
    /// <param name="TenantWebServiceFilter">The record for getting filter.</param>
    /// <returns>Tenant web service filter for the given record.</returns>
    procedure GetTenantWebServiceFilter(TenantWebServiceFilter: Record "Tenant Web Service Filter"): Text
    begin
        exit(WebServiceManagementImpl.GetTenantWebServiceFilter(TenantWebServiceFilter));
    end;

    /// <summary>
    /// Returns the tenant web service filter for a given record.
    /// </summary>
    /// <param name="TenantWebServiceFilter">The record for getting filter.</param>
    /// <returns>Tenant web service filter for the given record.</returns>
    procedure RetrieveTenantWebServiceFilter(var TenantWebServiceFilter: Record "Tenant Web Service Filter"): Text
    begin
        exit(WebServiceManagementImpl.RetrieveTenantWebServiceFilter(TenantWebServiceFilter));
    end;

    /// <summary>
    /// Sets the tenant web service filter for a given record.
    /// </summary>
    /// <param name="TenantWebServiceFilter">The record for setting tenant web service filter.</param>
    /// <param name="FilterText">The tenant web service filter that is set.</param>
    procedure SetTenantWebServiceFilter(var TenantWebServiceFilter: Record "Tenant Web Service Filter"; FilterText: Text)
    begin
        WebServiceManagementImpl.SetTenantWebServiceFilter(TenantWebServiceFilter, FilterText);
    end;

    /// <summary>
    /// Returns the OData select clause for a given record.
    /// </summary>
    /// <param name="TenantWebServiceOData">The record for getting OData select clause.</param>
    /// <returns>OData select clause for the given record.</returns>
    procedure GetODataSelectClause(TenantWebServiceOData: Record "Tenant Web Service OData"): Text
    begin
        exit(WebServiceManagementImpl.GetODataSelectClause(TenantWebServiceOData));
    end;

    /// <summary>
    /// Sets the OData select clause for a given record.
    /// </summary>
    /// <param name="TenantWebServiceOData">The record for setting OData select clause.</param>
    /// <param name="ODataText">The OData select clause that is set.</param>
    procedure SetODataSelectClause(var TenantWebServiceOData: Record "Tenant Web Service OData"; ODataText: Text)
    begin
        WebServiceManagementImpl.SetODataSelectClause(TenantWebServiceOData, ODataText);
    end;

    /// <summary>
    /// Returns the OData filter clause for a given record.
    /// </summary>
    /// <param name="TenantWebServiceOData">The record for getting OData filter clause.</param>
    /// <returns>OData filter clause for the given record.</returns>
    procedure GetODataFilterClause(TenantWebServiceOData: Record "Tenant Web Service OData"): Text
    begin
        exit(WebServiceManagementImpl.GetODataFilterClause(TenantWebServiceOData));
    end;

    /// <summary>
    /// Sets the OData filter clause for a given record.
    /// </summary>
    /// <param name="TenantWebServiceOData">The record for setting OData filter clause.</param>
    /// <param name="ODataText">The OData filter clause that is set.</param>
    procedure SetODataFilterClause(var TenantWebServiceOData: Record "Tenant Web Service OData"; ODataText: Text)
    begin
        WebServiceManagementImpl.SetODataFilterClause(TenantWebServiceOData, ODataText);
    end;

    /// <summary>
    /// Returns the OData V4 filter clause for a given record.
    /// </summary>
    /// <param name="TenantWebServiceOData">The record for getting OData V4 filter clause.</param>
    /// <returns>OData V4 filter clause for the given record.</returns>
    procedure GetODataV4FilterClause(TenantWebServiceOData: Record "Tenant Web Service OData"): Text
    begin
        exit(WebServiceManagementImpl.GetODataV4FilterClause(TenantWebServiceOData));
    end;

    /// <summary>
    /// Sets the OData V4 filter clause for a given record.
    /// </summary>
    /// <param name="TenantWebServiceOData">The record for setting OData V4 filter clause.</param>
    /// <param name="ODataText">The OData V4 filter clause that is set.</param>
    procedure SetODataV4FilterClause(var TenantWebServiceOData: Record "Tenant Web Service OData"; ODataText: Text)
    begin
        WebServiceManagementImpl.SetODataV4FilterClause(TenantWebServiceOData, ODataText);
    end;

    /// <summary>
    /// Gets the name of the object that will be exposed to the web service for a given record.
    /// </summary>
    /// <param name="WebServiceAggregate">The record for getting the name of the object.</param>
    /// <returns>Name of the object.</returns>
    procedure GetObjectCaption(WebServiceAggregate: Record "Web Service Aggregate"): Text[80]
    begin
        exit(WebServiceManagementImpl.GetObjectCaption(WebServiceAggregate));
    end;

    /// <summary>
    /// Loads records from Web Service and Tenant Web Service table into given Web Service Aggregate record.
    /// </summary>
    /// <param name="WebServiceAggregate">The variable that the records are loaded into.</param>
    procedure LoadRecords(var WebServiceAggregate: Record "Web Service Aggregate")
    begin
        WebServiceManagementImpl.LoadRecords(WebServiceAggregate);
    end;

    /// <summary>
    /// Loads records from Tenant Web Service table if there is a corresponding Tenant Web Service Column.
    /// </summary>
    /// <param name="TenantWebService">The variable that the records are loaded into.</param>
    procedure LoadRecordsFromTenantWebServiceColumns(var TenantWebService: Record "Tenant Web Service")
    begin
        WebServiceManagementImpl.LoadRecordsFromTenantWebServiceColumns(TenantWebService);
    end;

    /// <summary>
    /// Creates a tenant web service for a given page.
    /// </summary>
    /// <param name="TenantWebServiceRecordId">The ID of the given page.</param>
    /// <param name="FieldNumber">The field number of the tenant web service column.</param>
    /// <param name="DataItem">The data item of the tenant web service column.</param>
    [Scope('OnPrem')]
    procedure CreateTenantWebServiceColumnForPage(TenantWebServiceRecordId: RecordID; FieldNumber: Integer; DataItem: Integer)
    begin
        WebServiceManagementImpl.CreateTenantWebServiceColumnForPage(TenantWebServiceRecordId, FieldNumber, DataItem);
    end;

    /// <summary>
    /// Creates a tenant web service for a given query.
    /// </summary>
    /// <param name="TenantWebServiceRecordId">The ID of the given query.</param>
    /// <param name="FieldNumber">The field number of the tenant web service column.</param>
    /// <param name="DataItem">The data item of the tenant web service column.</param>
    /// <param name="MetaData">Metadata used to convert field name.</param>
    [Scope('OnPrem')]
    procedure CreateTenantWebServiceColumnForQuery(TenantWebServiceRecordId: RecordID; FieldNumber: Integer; DataItem: Integer; MetaData: DotNet QueryMetadataReader)
    begin
        WebServiceManagementImpl.CreateTenantWebServiceColumnForQuery(TenantWebServiceRecordId, FieldNumber, DataItem, MetaData);
    end;

    /// <summary>
    /// Inserts selected columns in a given dictionary to the tenant web service columns table.
    /// </summary>
    /// <param name="TenantWebService">The tenant web service corresponding to columns.</param>
    /// <param name="ColumnDictionary">Dictionary that contains selected columns to be inserted to the tenant web service columns table.</param>
    /// <param name="TargetTenantWebServiceColumns">Tenant web service columns table record that selected columns are inserted to.</param>
    /// <param name="DataItem">The data item of the tenant web service column.</param>
    procedure InsertSelectedColumns(var TenantWebService: Record "Tenant Web Service"; var ColumnDictionary: DotNet GenericDictionary2; var TargetTenantWebServiceColumns: Record "Tenant Web Service Columns"; DataItem: Integer)
    begin
        WebServiceManagementImpl.InsertSelectedColumns(TenantWebService, ColumnDictionary, TargetTenantWebServiceColumns, DataItem);
    end;

    /// <summary> 
    /// Removes filters that are not in the selected columns for the given service.
    /// </summary>
    /// <param name="TenantWebService">The tenant web service corresponding to columns.</param>
    /// <param name="DataItem">The data item of the tenant web service column.</param>
    /// <param name="DataItemView">The field name of the data item.</param>
    /// <returns>Filter text for unselected columns.</returns>
    procedure RemoveUnselectedColumnsFromFilter(var TenantWebService: Record "Tenant Web Service"; DataItem: Integer; DataItemView: Text): Text
    begin
        exit(WebServiceManagementImpl.RemoveUnselectedColumnsFromFilter(TenantWebService, DataItem, DataItemView));
    end;

    /// <summary> 
    /// Checks if given service name is valid.
    /// </summary>
    /// <param name="Value">The service name to be checked.</param>
    /// <returns>If given service name valid or not.</returns>
    procedure IsServiceNameValid(Value: Text): Boolean
    begin
        exit(WebServiceManagementImpl.IsServiceNameValid(Value));
    end;

    /// <summary> 
    /// Deletes a webservice.
    /// </summary>
    /// <param name="WebServiceAggregate">The record to be deleted.</param>
    procedure DeleteWebService(var WebServiceAggregate: Record "Web Service Aggregate")
    begin
        WebServiceManagementImpl.DeleteWebService(WebServiceAggregate);
    end;
}