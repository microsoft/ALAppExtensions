codeunit 132525 "Edit in Excel Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;

    var
        LibraryAssert: Codeunit "Library Assert";
        EditInExcelTest: Codeunit "Edit in Excel Test";
        EditInExcel: Codeunit "Edit in Excel";
        IsInitialized: Boolean;
        EventServiceName: Text[240];
        WebServiceHasBeenDisabledErr: Label 'You can''t edit this page in Excel because it''s not set up for it. To use the Edit in Excel feature, you must publish the web service called ''%1''. Contact your system administrator for help.', Comment = '%1 = Web service name';

    [Test]
    procedure TestEditInExcelCreatesWebService()
    var
        TenantWebService: Record "Tenant Web Service";
        EditInExcelList: Page "Edit in Excel List";
    begin
        TenantWebService.SetRange("Object Type", TenantWebService."Object Type"::Page);
        TenantWebService.SetRange("Object ID", Page::"Edit in Excel List");
        TenantWebService.DeleteAll();

        EditInExcel.EditPageInExcel(CopyStr(EditInExcelList.Caption, 1, 240), EditInExcelList.ObjectId(false), '');

        LibraryAssert.RecordCount(TenantWebService, 1);
        TenantWebService.FindFirst();
        LibraryAssert.AreEqual(EditInExcelList.Caption + '_Excel', TenantWebService."Service Name", 'The tenant web service has incorrect name');
    end;

    [Test]
    procedure TestEditInExcelDisabledWebService()
    var
        TenantWebService: Record "Tenant Web Service";
        EditInExcelList: Page "Edit in Excel List";
        PageName: Text[100];
    begin
        Init();

        TenantWebService.SetRange("Object Type", TenantWebService."Object Type"::Page);
        TenantWebService.SetRange("Object ID", Page::"Edit in Excel List");
        TenantWebService.DeleteAll();
        PageName := 'TestServiceName';
        InsertTenantWebService(Page::"Edit in Excel List", PageName + '_Excel', false, false, false);

        asserterror EditInExcel.EditPageInExcel(PageName, EditInExcelList.ObjectId(false), '');
        LibraryAssert.ExpectedError(StrSubstNo(WebServiceHasBeenDisabledErr, PageName + '_Excel'));
    end;

    [Test]
    procedure TestEditInExcelReuseWebService()
    var
        TenantWebService: Record "Tenant Web Service";
        EditInExcelList: Page "Edit in Excel List";
        PageName: Text[100];
    begin
        Init();

        TenantWebService.SetRange("Object Type", TenantWebService."Object Type"::Page);
        TenantWebService.SetRange("Object ID", Page::"Edit in Excel List");
        TenantWebService.DeleteAll();
        PageName := 'TestServiceName';
        InsertTenantWebService(Page::"Edit in Excel List", PageName + '_Excel', false, false, true);

        EditInExcel.EditPageInExcel(PageName, EditInExcelList.ObjectId(false), '');

        LibraryAssert.RecordCount(TenantWebService, 1);
        TenantWebService.FindFirst();
        LibraryAssert.AreEqual(PageName + '_Excel', TenantWebService."Service Name", 'The tenant web service name has changed');
        LibraryAssert.AreEqual(PageName + '_Excel', EditInExcelTest.GetServiceName(), 'The service name given to the edit in excel event is incorrect');
    end;

    [Test]
    procedure TestEditInExcelReuseSpecificWebService()
    var
        TenantWebService: Record "Tenant Web Service";
        EditInExcelList: Page "Edit in Excel List";
        ServiceName: Text[100];
    begin
        Init();

        TenantWebService.SetRange("Object Type", TenantWebService."Object Type"::Page);
        TenantWebService.SetRange("Object ID", Page::"Edit in Excel List");
        TenantWebService.DeleteAll();
        ServiceName := EditInExcelList.Caption + '_Excel';
        InsertTenantWebService(Page::"Edit in Excel List", 'aaa', true, true, true);
        InsertTenantWebService(Page::"Edit in Excel List", ServiceName, false, false, true);
        InsertTenantWebService(Page::"Edit in Excel List", 'zzz', true, true, true);

        EditInExcel.EditPageInExcel(CopyStr(EditInExcelList.Caption, 1, 240), EditInExcelList.ObjectId(false), '');

        LibraryAssert.RecordCount(TenantWebService, 3);
        LibraryAssert.AreEqual(ServiceName, EditInExcelTest.GetServiceName(), 'The service name used is wrong'); // if there's a service called pageCaption_Excel then always use that one
    end;

    procedure GetServiceName(): Text[240]
    begin
        exit(EventServiceName);
    end;

    local procedure Init()
    begin
        if IsInitialized then
            exit;

        LibraryAssert.IsTrue(BindSubscription(EditInExcelTest), 'Could not bind events');
        IsInitialized := true;
    end;

    local procedure InsertTenantWebService(PageId: Integer; ServiceName: Text[240]; ExcludeFieldsOutsideRepeater: Boolean; ExcludeNonEditableFlowFields: Boolean; Publish: Boolean)
    var
        TenantWebService: Record "Tenant Web Service";
    begin
        TenantWebService.Validate("Object Type", TenantWebService."Object Type"::Page);
        TenantWebService.Validate("Object ID", PageId);
        TenantWebService.Validate(ExcludeFieldsOutsideRepeater, ExcludeFieldsOutsideRepeater);
        TenantWebService.Validate(ExcludeNonEditableFlowFields, ExcludeNonEditableFlowFields);
        TenantWebService.Validate("Service Name", ServiceName);
        TenantWebService.Validate(Published, Publish);
        TenantWebService.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Edit in Excel", 'OnEditInExcel', '', false, false)]
    local procedure OnEditInExcelWithSearch(ServiceName: Text[240])
    begin
        EventServiceName := ServiceName;
    end;
}

