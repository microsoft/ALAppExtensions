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
}
