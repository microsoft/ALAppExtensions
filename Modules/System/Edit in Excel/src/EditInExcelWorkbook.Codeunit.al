// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Excel;

/// <summary>
/// This codeunit provides an interface to create workbooks using the Excel Add-in.
/// </summary>
codeunit 1488 "Edit in Excel Workbook"
{
    Access = Public;

    var
        EditinExcelWorkbookImpl: Codeunit "Edit in Excel Workbook Impl."; // Stateful reference to create a workbook

    /// <summary>
    /// Initialize the workbook. This will setup all required information for the add-in.
    /// </summary>
    /// <param name="ServiceName">The name of the service the Excel add-in should connect to. This service must exist and be published.</param>
    procedure Initialize(ServiceName: Text[250])
    begin
        EditinExcelWorkbookImpl.Initialize(ServiceName);
    end;

    /// <summary>
    /// Sets the filters in the Excel Add-in.
    /// </summary>
    /// <param name="EditInExcelFilters">Filters to be applied.</param>
    procedure SetFilters(EditInExcelFilters: Codeunit "Edit in Excel Filters")
    begin
        EditinExcelWorkbookImpl.SetFilters(EditInExcelFilters);
    end;

    /// <summary>
    /// Set the search text of the Excel Add-in. This works similar to searching on a page for the specified text.
    /// </summary>
    /// <param name="SearchText">The text that should be searched for.</param>
    procedure SetSearchText(SearchText: Text)
    begin
        EditinExcelWorkbookImpl.SetSearchText(SearchText);
    end;

    /// <summary>
    /// Add the specified OdataField with the given caption to the Excel file.
    /// </summary>
    /// <param name="Caption">Caption of the field.</param>
    /// <param name="ODataFieldName">The OData name of the field referenced.</param>
    procedure AddColumn(Caption: Text; OdataFieldName: Text)
    begin
        EditinExcelWorkbookImpl.AddColumn(Caption, OdataFieldName);
    end;

    /// <summary>
    /// Add the specified OdataField with the given caption to the Excel file at the specified location.
    /// </summary>
    /// <param name="Index">Location to insert.</param>
    /// <param name="Caption">Caption of the field.</param>
    /// <param name="ODataFieldName">The OData name of the field referenced.</param>
    procedure InsertColumn(Index: Integer; Caption: Text; OdataFieldName: Text)
    begin
        EditinExcelWorkbookImpl.InsertColumn(Index, Caption, OdataFieldName);
    end;

    /// <summary>
    /// When the Excel file is opened in Excel online, there are certain restrictions such as a column limit. This will trim additional columns and impose any future restrictions.
    /// </summary>
    procedure ImposeExcelOnlineRestrictions()
    begin
        EditinExcelWorkbookImpl.ImposeExcelOnlineRestrictions();
    end;

    /// <summary>
    /// Generate an Excel file and create an InStream with the content.
    /// </summary>
    /// <returns>An InStream containing the generated Excel file.</returns>
    procedure ExportToStream(): InStream
    begin
        exit(EditinExcelWorkbookImpl.ExportToStream())
    end;
}