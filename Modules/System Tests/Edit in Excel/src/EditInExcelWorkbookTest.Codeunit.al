// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Integration.Excel;

using System.Integration.Excel;
using System.Integration;
using System.TestLibraries.Utilities;
codeunit 132527 "Edit in Excel Workbook Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;

    var
        LibraryAssert: Codeunit "Library Assert";
        EditinExcelWorkbook: Codeunit "Edit in Excel Workbook";
        WebServiceHasBeenDisabledErr: Label 'You can''t edit this page in Excel because it''s not set up for it. To use the Edit in Excel feature, you must publish the web service called ''%1''. Contact your system administrator for help.', Comment = '%1 = Web service name';
        WebServiceDoesNotExistErr: Label 'Cannot initialize Edit in Excel workbook since the web service ''%1'' does not exist.', Comment = '%1 = name of the web service';
        NoColumnsExistErr: Label 'No columns were added to the workbook.';

    [Test]
    procedure WebServiceDoesNotExist()
    var
        TenantWebService: Record "Tenant Web Service";
    begin
        TenantWebService.SetRange("Object Type", TenantWebService."Object Type"::Page);
        TenantWebService.SetRange("Object ID", Page::"Edit in Excel List");
        TenantWebService.DeleteAll();

        asserterror EditinExcelWorkbook.Initialize('InvalidServiceName');
        LibraryAssert.ExpectedError(StrSubstNo(WebServiceDoesNotExistErr, 'InvalidServiceName'));
    end;

    [Test]
    procedure DisabledWebService()
    var
        TenantWebService: Record "Tenant Web Service";
        ServiceName: Text[240];
    begin
        TenantWebService.SetRange("Object Type", TenantWebService."Object Type"::Page);
        TenantWebService.SetRange("Object ID", Page::"Edit in Excel List");
        TenantWebService.DeleteAll();
        ServiceName := 'TestServiceName';
        InsertTenantWebService(Page::"Edit in Excel List", ServiceName, false);

        asserterror EditinExcelWorkbook.Initialize(ServiceName);
        LibraryAssert.ExpectedError(StrSubstNo(WebServiceHasBeenDisabledErr, ServiceName));
    end;

    [Test]
    procedure ExportEmptyWorkbook()
    var
        TenantWebService: Record "Tenant Web Service";
        ServiceName: Text[240];
    begin
        TenantWebService.SetRange("Object Type", TenantWebService."Object Type"::Page);
        TenantWebService.SetRange("Object ID", Page::"Edit in Excel List");
        TenantWebService.DeleteAll();
        ServiceName := 'ExportEmptyWorkbook';
        InsertTenantWebService(Page::"Edit in Excel List", ServiceName, true);

        EditinExcelWorkbook.Initialize(ServiceName);
        asserterror EditinExcelWorkbook.ExportToStream();
        LibraryAssert.ExpectedError(NoColumnsExistErr);
    end;

    local procedure InsertTenantWebService(PageId: Integer; ServiceName: Text[250]; Publish: Boolean)
    var
        TenantWebService: Record "Tenant Web Service";
    begin
        TenantWebService.Validate("Object Type", TenantWebService."Object Type"::Page);
        TenantWebService.Validate("Object ID", PageId);
        TenantWebService.Validate("Service Name", ServiceName);
        TenantWebService.Validate(Published, Publish);
        TenantWebService.Insert(true);
    end;
}
