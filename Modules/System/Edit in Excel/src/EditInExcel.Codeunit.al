// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Excel;

using System.Integration;

/// <summary>
/// This codeunit provides an interface to running Edit in Excel for a specific page.
/// </summary>
codeunit 1481 "Edit in Excel"
{
    Access = Public;

#if not CLEAN22
    /// <summary>
    /// Creates web service for the specified page, and uses the web service to prepare and download an Excel file for the Edit in Excel functionality.
    /// </summary>
    /// <param name="PageCaption">The name of the page. This will be used for the name of the downloaded excel file, additionally the web service will be called [PageCaption]_Excel. Note if the PageCaption starts with a digit, the web service name will be WS[PageCaption]_Excel.</param>
    /// <param name="PageId">The ID of the page, for example, "21".</param>
    /// <param name="Filter">The Business Central filter to be applied in Edit in Excel.</param>
    [Obsolete('Filters are now provided through EditinExcelFilters', '22.0')]
    procedure EditPageInExcel(PageCaption: Text[240]; PageId: Text; Filter: Text)
    var
        EditInExcelImpl: Codeunit "Edit in Excel Impl.";
    begin
        EditInExcelImpl.EditPageInExcel(PageCaption, PageId, Filter, '');
    end;
#endif

    /// <summary>
    /// Creates web service for the specified page, and uses the web service to prepare and download an Excel file for the Edit in Excel functionality.
    /// </summary>
    /// <param name="PageCaption">The name of the page. This will be used for the name of the downloaded excel file, additionally the web service will be called [PageCaption]_Excel. Note if the PageCaption starts with a digit, the web service name will be WS[PageCaption]_Excel.</param>
    /// <param name="PageId">The ID of the page, for example, 21.</param>
    procedure EditPageInExcel(PageCaption: Text[240]; PageId: Integer)
    var
        EditInExcelImpl: Codeunit "Edit in Excel Impl.";
        EditinExcelFilters: Codeunit "Edit in Excel Filters";
    begin
        EditInExcelImpl.EditPageInExcel(PageCaption, PageId, EditinExcelFilters, '');
    end;

    /// <summary>
    /// Creates web service for the specified page, and uses the web service to prepare and download an Excel file for the Edit in Excel functionality.
    /// </summary>
    /// <param name="PageCaption">The name of the page. This will be used for the name of the downloaded excel file, additionally the web service will be called [PageCaption]_Excel. Note if the PageCaption starts with a digit, the web service name will be WS[PageCaption]_Excel.</param>
    /// <param name="PageId">The ID of the page, for example, 21.</param>
    /// <param name="EditinExcelFilters">The filters which will be applied to Edit in Excel.</param>
    procedure EditPageInExcel(PageCaption: Text[240]; PageId: Integer; EditinExcelFilters: Codeunit "Edit in Excel Filters")
    var
        EditInExcelImpl: Codeunit "Edit in Excel Impl.";
    begin
        EditInExcelImpl.EditPageInExcel(PageCaption, PageId, EditinExcelFilters, '');
    end;

#if not CLEAN22
    /// <summary>
    /// Creates web service for the specified page, and uses the web service to prepare and download an Excel file for the Edit in Excel functionality.
    /// </summary>
    /// <param name="PageCaption">The name of the page. This will be used for the name of the downloaded excel file, if the FileName parameter is not set. Additionally, the web service will be called [PageCaption]_Excel. Note if the PageCaption starts with a digit, the web service name will be WS[PageCaption]_Excel.</param>
    /// <param name="PageId">The ID of the page, for example, "21".</param>
    /// <param name="Filter">The Business Central filter to be applied in Edit in Excel.</param>
    /// <param name="FileName">The name of the downloaded excel file.</param>
    [Obsolete('Filters are now provided through EditinExcelFilters', '22.0')]
    procedure EditPageInExcel(PageCaption: Text[240]; PageId: Text; Filter: Text; FileName: Text)
    var
        EditInExcelImpl: Codeunit "Edit in Excel Impl.";
    begin
        EditInExcelImpl.EditPageInExcel(PageCaption, PageId, Filter, FileName);
    end;
#endif

    /// <summary>
    /// Creates web service for the specified page, and uses the web service to prepare and download an Excel file for the Edit in Excel functionality.
    /// </summary>
    /// <param name="PageCaption">The name of the page. This will be used for the name of the downloaded excel file, if the FileName parameter is not set. Additionally, the web service will be called [PageCaption]_Excel. Note if the PageCaption starts with a digit, the web service name will be WS[PageCaption]_Excel.</param>
    /// <param name="PageId">The ID of the page, for example, 21.</param>
    /// <param name="EditinExcelFilters">The filters which will be applied to Edit in Excel.</param>
    /// <param name="FileName">The name of the downloaded excel file.</param>
    procedure EditPageInExcel(PageCaption: Text[240]; PageId: Integer; EditinExcelFilters: Codeunit "Edit in Excel Filters"; FileName: Text)
    var
        EditInExcelImpl: Codeunit "Edit in Excel Impl.";
    begin
        EditInExcelImpl.EditPageInExcel(PageCaption, PageId, EditinExcelFilters, FileName);
    end;

    /// <summary>
    /// Prepares an Excel file for the Edit in Excel functionality by using the specified web service, and downloads the file.
    /// </summary>
    /// <param name="TenantWebService">The web service referenced through Edit in Excel.</param>
    /// <param name="SearchFilter">The search filter of the user.</param>
    procedure GenerateExcelWorkBook(TenantWebService: Record "Tenant Web Service"; SearchFilter: Text)
    var
        EditInExcelImpl: Codeunit "Edit in Excel Impl.";
        EditinExcelFilters: Codeunit "Edit in Excel Filters";
    begin
        EditInExcelImpl.GetEndPointAndCreateWorkbookWStructuredFilter(TenantWebService."Service Name", EditinExcelFilters, SearchFilter);
    end;

    /// <summary>
    /// Prepares an Excel file for the Edit in Excel functionality by using the specified web service, and downloads the file.
    /// </summary>
    /// <param name="TenantWebService">The web service referenced through Edit in Excel.</param>
    /// <param name="EditinExcelFilters">The filters which will be applied to Edit in Excel.</param>
    procedure GenerateExcelWorkBook(TenantWebService: Record "Tenant Web Service"; EditinExcelFilters: Codeunit "Edit in Excel Filters")
    var
        EditInExcelImpl: Codeunit "Edit in Excel Impl.";
    begin
        EditInExcelImpl.GetEndPointAndCreateWorkbookWStructuredFilter(TenantWebService."Service Name", EditinExcelFilters, '');
    end;

#if not CLEAN22
    /// <summary>
    /// This event is called when Edit in Excel is invoked, accepting Filter in Text format. It allows overriding the Edit in Excel functionality.
    /// </summary>
    /// <param name="ServiceName">The name of the web service already created for use with Edit in Excel.</param>
    /// <param name="Filter">The Business Central filter to be applied in Edit in Excel.</param>
    /// <param name="SearchFilter">The search filter of the user.</param>
    //  <param name="Handled">Specifies whether the event has been handled and no further execution should occur.</param>
    [IntegrationEvent(false, false)]
    [Obsolete('This event has been replaced by OnEditInExcelWithFilters', '22.0')]
    internal procedure OnEditInExcel(ServiceName: Text[240]; ODataFilter: Text; SearchFilter: Text; var Handled: Boolean)
    begin
    end;
#endif

    /// <summary>
    /// This event is called when Edit in Excel is invoked, handling JSON structured filters. It also allows overriding the Edit in Excel functionality.
    /// It is however recommended to use OnEditInExcelWithFilters below if possible to avoid taking dependency on a given structure.
    /// </summary>
    /// <param name="ServiceName">The name of the web service already created for use with Edit in Excel.</param>
    /// <param name="Filter">Business Central Filter to be applied in Edit in Excel.</param>
    /// <param name="Payload">Object binding the name of the filtered field with its EdmType</param>
    /// <param name="SearchFilter">The search filter of the user.</param>
    //  <param name="Handled">Specifies whether the event has been handled and no further execution should occur.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnEditInExcelWithStructuredFilter(ServiceName: Text[240]; Filter: JsonObject; Payload: JsonObject; SearchFilter: Text; var Handled: Boolean)
    begin
    end;

    /// <summary>
    /// This event is called when the Edit in Excel system action is invoked or EditInExcel is called in this codeunit.
    /// It allows modifying filters or overriding the Edit in Excel functionality completely.
    /// </summary>
    /// <param name="ServiceName">The name of the web service already created for use with Edit in Excel.</param>
    /// <param name="EditinExcelFilters">The filters which will be applied to Edit in Excel.</param>
    /// <param name="SearchFilter">The search filter of the user.</param>
    //  <param name="Handled">Specifies whether the event has been handled and no further execution should occur.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnEditInExcelWithFilters(ServiceName: Text[240]; var EditinExcelFilters: Codeunit "Edit in Excel Filters"; SearchFilter: Text; var Handled: Boolean)
    begin
    end;
}
