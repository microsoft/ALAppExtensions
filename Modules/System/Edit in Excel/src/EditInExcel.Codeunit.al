// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This codeunit provides an interface to running Edit in Excel for a specific page.
/// </summary>
codeunit 1481 "Edit in Excel"
{
    Access = Public;

    /// <summary>
    /// Creates web service for the specified page, and uses the web service to prepare and download an Excel file for the Edit in Excel functionality.
    /// </summary>
    /// <param name="PageCaption">The name of the page. This will be used for the name of the downloaded excel file, additionally the web service will be called [PageCaption]_Excel. Note if the PageCaption starts with a digit, the web service name will be WS[PageCaption]_Excel.</param>
    /// <param name="PageId">The ID of the page, for example, "21".</param>
    /// <param name="Filter">The Business Central filter to be applied in Edit in Excel.</param>
    procedure EditPageInExcel(PageCaption: Text[240]; PageId: Text; Filter: Text)
    var
        EditInExcelImpl: Codeunit "Edit in Excel Impl.";
    begin
        EditInExcelImpl.EditPageInExcel(PageCaption, PageId, Filter);
    end;

    /// <summary>
    /// Creates web service for the specified page, and uses the web service to prepare and download an Excel file for the Edit in Excel functionality.
    /// </summary>
    /// <param name="PageCaption">The name of the page. This will be used for the name of the downloaded excel file, if the FileName parameter is not set. Additionally, the web service will be called [PageCaption]_Excel. Note if the PageCaption starts with a digit, the web service name will be WS[PageCaption]_Excel.</param>
    /// <param name="PageId">The ID of the page, for example, "21".</param>
    /// <param name="Filter">The Business Central filter to be applied in Edit in Excel.</param>
    /// <param name="FileName">The name of the downloaded excel file.</param>
    procedure EditPageInExcel(PageCaption: Text[240]; PageId: Text; Filter: Text; FileName: Text)
    var
        EditInExcelImpl: Codeunit "Edit in Excel Impl.";
    begin
        EditInExcelImpl.EditPageInExcel(PageCaption, PageId, Filter, FileName);
    end;

    /// <summary>
    /// Prepares an Excel file for the Edit in Excel functionality by using the specified web service, and downloads the file.
    /// </summary>
    /// <param name="TenantWebService">The web service referenced through Edit in Excel.</param>
    /// <param name="SearchFilter">The search filter of the user.</param>
    procedure GenerateExcelWorkBook(TenantWebService: Record "Tenant Web Service"; SearchFilter: Text)
    var
        EditInExcelImpl: Codeunit "Edit in Excel Impl.";
    begin
        EditInExcelImpl.GenerateExcelWorkBook(TenantWebService, SearchFilter);
    end;

    /// <summary>
    /// This event is called when Edit in Excel is invoked and allows overriding the Edit in Excel functionality.
    /// </summary>
    /// <param name="ServiceName">The name of the web service already created for use with Edit in Excel.</param>
    /// <param name="Filter">The Business Central filter to be applied in Edit in Excel.</param>
    /// <param name="SearchFilter">The search filter of the user.</param>
    //  <param name="Handled">Specifies whether the event has been handled and no further execution should occur.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnEditInExcel(ServiceName: Text[240]; ODataFilter: Text; SearchFilter: Text; var Handled: Boolean)
    begin
    end;
}

