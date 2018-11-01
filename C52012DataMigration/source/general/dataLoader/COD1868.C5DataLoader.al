// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 1868 "C5 Data Loader"
{
    var
        NameValueBuffer: Record "Name/Value Buffer" temporary;
        HelperFunctions: Codeunit "C5 Helper Functions";


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnFillStagingTables', '', false, false)]
    procedure FillStagingTables()
    var
        DataMigrationStatus: Record "Data Migration Status";
        C5SchemaParameters: Record "C5 Schema Parameters";
        C5MigrDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
        AccountsLoaded: Boolean;
        VendorsLoaded: Boolean;
        CustomersLoaded: Boolean;
        DurationAsInt: BigInteger;
        StartTime: DateTime;
    begin
        StartTime := CurrentDateTime();
        OnFillStagingTablesStarted();

        if not Codeunit.Run(Codeunit::"C5 Unzip", NameValueBuffer) then
            StopPendingMigrationsAndSurfaceErrors();

        DataMigrationStatus.SetRange("Migration Type", C5MigrDashboardMgt.GetC5MigrationTypeTxt());
        DataMigrationStatus.SetRange(Status, DataMigrationStatus.Status::Pending);
        DataMigrationStatus.SetRange("Destination Table ID", Database::"G/L Account");
        if DataMigrationStatus.FindFirst() then begin
            LoadC5Accounts();
            AccountsLoaded := true;
        end;

        DataMigrationStatus.SetRange("Destination Table ID", Database::Vendor);
        if DataMigrationStatus.FindFirst() then begin
            if not AccountsLoaded then
                LoadC5Accounts();
            LoadCustomerVendorItemCommonTables();
            LoadCustomerVendorCommonTables();
            LoadVendorRelatedTables();
            LoadC5Vendors();
            LoadC5VendorGroups();
            LoadC5VendorTrans();
            VendorsLoaded := true;
        end;

        DataMigrationStatus.SetRange("Destination Table ID", Database::Customer);
        if DataMigrationStatus.FindFirst() then begin
            if not AccountsLoaded then
                LoadC5Accounts();
            if not VendorsLoaded then begin
                LoadCustomerVendorCommonTables();
                LoadCustomerVendorItemCommonTables();
            end;
            LoadCustomerRelatedTables();
            LoadCustomerItemCommonTables();
            LoadC5Customers();
            LoadC5CustomerGroups();
            LoadC5CustomerTrans();
            CustomersLoaded := true;
        end;

        DataMigrationStatus.SetRange("Destination Table ID", Database::Item);
        if DataMigrationStatus.FindFirst() then begin
            if not AccountsLoaded then
                LoadC5Accounts();
            if not (VendorsLoaded and CustomersLoaded) then
                LoadCustomerVendorItemCommonTables();

            if not CustomersLoaded then
                LoadCustomerItemCommonTables();

            LoadItemRelatedTables();
            LoadC5Items();
            LoadC5InvenBOM();
        end;

        DataMigrationStatus.SetRange("Destination Table ID", Database::"C5 LedTrans");
        if DataMigrationStatus.FindFirst() then begin
            if not AccountsLoaded then
                LoadC5Accounts();
            LoadC5LedTrans();
        end;

        // Delete the blob we no longer need it
        C5SchemaParameters.GetSingleInstance();
        Clear(C5SchemaParameters."Zip File Blob");
        C5SchemaParameters.Modify();

        DurationAsInt := CurrentDateTime() - StartTime;
        OnFillStagingTablesFinished(DurationAsInt);
    end;

    local procedure LoadVendorRelatedTables()
    begin
        LoadC5VendorDiscGroups();
        LoadC5VendContact();
    end;

    local procedure LoadItemRelatedTables()
    begin
        LoadC5UnitCode();
        LoadC5CN8Code();
        LoadC5InvenCustDisc();
        LoadC5InvenPrice();
        LoadC5InvenItemGroups();
        LoadC5InvenLocation();
        LoadC5InvenTrans();
    end;

    local procedure LoadCustomerVendorItemCommonTables()
    begin
        LoadC5ExchangeRates();
        LoadC5Centre();
        LoadC5Department();
        LoadC5Purpose();
    end;

    local procedure LoadCustomerItemCommonTables()
    begin
        LoadC5InvenPriceGroups();
    end;

    local procedure LoadCustomerVendorCommonTables()
    begin
        LoadC5Payments();
        LoadC5Employees();
        LoadC5Deliveries();
        LoadC5Countries();
    end;

    local procedure LoadCustomerRelatedTables()
    begin
        LoadC5CustDiscGroups();
        LoadC5ProcCodes();
        LoadC5CustContact();
    end;

    local procedure LoadC5InvenPrice()
    var
        C5InvenPrice: Record "C5 InvenPrice";
        TempBlob: Record TempBlob temporary;
        C5InvenPriceXmlPort: XmlPort "C5 InvenPrice";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5InvenPrice, CsvProcessedStream, TempBlob) then
            exit;

        C5InvenPriceXmlPort.SetSource(CsvProcessedStream);
        C5InvenPriceXmlPort.Import();
    end;

    local procedure LoadC5InvenItemGroups()
    var
        C5InvenItemGroup: Record "C5 InvenItemGroup";
        TempBlob: Record TempBlob temporary;
        C5InvenItemGroupXmlPort: XmlPort "C5 InvenItemGroup";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5InvenItemGroup, CsvProcessedStream, TempBlob) then
            exit;

        C5InvenItemGroupXmlPort.SetSource(CsvProcessedStream);
        C5InvenItemGroupXmlPort.Import();
    end;

    local procedure LoadC5InvenTrans()
    var
        C5InvenTrans: Record "C5 InvenTrans";
        TempBlob: Record TempBlob temporary;
        C5InvenTransXmlPort: XmlPort "C5 InvenTrans";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5InvenTrans, CsvProcessedStream, TempBlob) then
            exit;

        C5InvenTransXmlPort.SetSource(CsvProcessedStream);
        C5InvenTransXmlPort.Import();
    end;

    local procedure LoadC5InvenLocation()
    var
        C5InvenLocation: Record "C5 InvenLocation";
        TempBlob: Record TempBlob temporary;
        InvenLocationXmlPort: XmlPort InvenLocationXmlPort;
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5InvenLocation, CsvProcessedStream, TempBlob) then
            exit;

        InvenLocationXmlPort.SetSource(CsvProcessedStream);
        InvenLocationXmlPort.Import();
    end;

    local procedure LoadC5Countries()
    var
        C5Country: Record "C5 Country";
        TempBlob: Record TempBlob temporary;
        C5CountryXmlPort: XmlPort "C5 Country";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5Country, CsvProcessedStream, TempBlob) then
            exit;

        C5CountryXmlPort.SetSource(CsvProcessedStream);
        C5CountryXmlPort.Import();
    end;

    local procedure LoadC5InvenCustDisc()
    var
        C5InvenCustDisc: Record "C5 InvenCustDisc";
        TempBlob: Record TempBlob temporary;
        C5InvenCustDiscXmlPort: XmlPort "C5 InvenCustDisc";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5InvenCustDisc, CsvProcessedStream, TempBlob) then
            exit;

        C5InvenCustDiscXmlPort.SetSource(CsvProcessedStream);
        C5InvenCustDiscXmlPort.Import();
    end;

    local procedure LoadC5InvenPriceGroups()
    var
        C5InvenPriceGroup: Record "C5 InvenPriceGroup";
        TempBlob: Record TempBlob temporary;
        C5InvenPrcGroupXmlPort: XmlPort "C5 InvenPrcGroup";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5InvenPriceGroup, CsvProcessedStream, TempBlob) then
            exit;

        C5InvenPrcGroupXmlPort.SetSource(CsvProcessedStream);
        C5InvenPrcGroupXmlPort.Import();
    end;

    local procedure LoadC5CN8Code()
    var
        C5CN8Code: Record "C5 CN8Code";
        TempBlob: Record TempBlob temporary;
        C5CN8CodeXmlPort: XmlPort "C5 CN8Code";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5CN8Code, CsvProcessedStream, TempBlob) then
            exit;

        C5CN8CodeXmlPort.SetSource(CsvProcessedStream);
        C5CN8CodeXmlPort.Import();
    end;

    local procedure LoadC5ProcCodes()
    var
        C5ProcCode: Record "C5 ProcCode";
        TempBlob: Record TempBlob temporary;
        C5ProcCodeXmlPort: XmlPort "C5 ProcCode";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5ProcCode, CsvProcessedStream, TempBlob) then
            exit;

        C5ProcCodeXmlPort.SetSource(CsvProcessedStream);
        C5ProcCodeXmlPort.Import();
    end;

    local procedure LoadC5UnitCode()
    var
        C5UnitCode: Record "C5 UnitCode";
        TempBlob: Record TempBlob temporary;
        C5UnitCodeXmlPort: XmlPort "C5 UnitCode";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5UnitCode, CsvProcessedStream, TempBlob) then
            exit;

        C5UnitCodeXmlPort.SetSource(CsvProcessedStream);
        C5UnitCodeXmlPort.Import();
    end;

    local procedure LoadC5Centre()
    var
        C5Centre: Record "C5 Centre";
        TempBlob: Record TempBlob temporary;
        C5CentreXmlPort: XmlPort "C5 Centre";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5Centre, CsvProcessedStream, TempBlob) then
            exit;

        C5CentreXmlPort.SetSource(CsvProcessedStream);
        C5CentreXmlPort.Import();
    end;

    local procedure LoadC5Department()
    var
        C5Department: Record "C5 Department";
        TempBlob: Record TempBlob temporary;
        C5DepartmentXmlPort: XmlPort "C5 Department";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5Department, CsvProcessedStream, TempBlob) then
            exit;

        C5DepartmentXmlPort.SetSource(CsvProcessedStream);
        C5DepartmentXmlPort.Import();
    end;

    local procedure LoadC5Purpose()
    var
        C5Purpose: Record "C5 Purpose";
        TempBlob: Record TempBlob temporary;
        C5PurposeXmlPort: XmlPort "C5 Purpose";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5Purpose, CsvProcessedStream, TempBlob) then
            exit;

        C5PurposeXmlPort.SetSource(CsvProcessedStream);
        C5PurposeXmlPort.Import();
    end;


    local procedure LoadC5CustDiscGroups()
    var
        C5CustDiscGroup: Record "C5 CustDiscGroup";
        TempBlob: Record TempBlob temporary;
        C5CustDiscGroupXmlPort: XmlPort "C5 CustDiscGroup";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5CustDiscGroup, CsvProcessedStream, TempBlob) then
            exit;

        C5CustDiscGroupXmlPort.SetSource(CsvProcessedStream);
        C5CustDiscGroupXmlPort.Import();
    end;

    local procedure LoadC5VendorDiscGroups()
    var
        C5VendDiscGroup: Record "C5 VendDiscGroup";
        TempBlob: Record TempBlob temporary;
        C5VendDiscGroupXmlPort: XmlPort "C5 VendDiscGroup";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5VendDiscGroup, CsvProcessedStream, TempBlob) then
            exit;

        C5VendDiscGroupXmlPort.SetSource(CsvProcessedStream);
        C5VendDiscGroupXmlPort.Import();
    end;

    local procedure LoadC5Employees()
    var
        C5Employee: Record "C5 Employee";
        TempBlob: Record TempBlob temporary;
        C5EmployeeXmlPort: XmlPort "C5 Employee";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5Employee, CsvProcessedStream, TempBlob) then
            exit;

        C5EmployeeXmlPort.SetSource(CsvProcessedStream);
        C5EmployeeXmlPort.Import();
    end;

    local procedure LoadC5Customers()
    var
        C5CustTable: Record "C5 CustTable";
        TempBlob: Record TempBlob temporary;
        C5CustTableXmlPort: XmlPort "C5 CustTable";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5CustTable, CsvProcessedStream, TempBlob) then
            exit;

        C5CustTableXmlPort.SetSource(CsvProcessedStream);
        C5CustTableXmlPort.Import();
    end;

    local procedure LoadC5CustomerGroups()
    var
        C5CustGroup: Record "C5 CustGroup";
        TempBlob: Record TempBlob temporary;
        C5CustGroupXmlPort: XmlPort "C5 CustGroup";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5CustGroup, CsvProcessedStream, TempBlob) then
            exit;

        C5CustGroupXmlPort.SetSource(CsvProcessedStream);
        C5CustGroupXmlPort.Import();
    end;

    local procedure LoadC5CustomerTrans()
    var
        C5CustTrans: Record "C5 CustTrans";
        TempBlob: Record TempBlob temporary;
        C5CustTransXmlPort: XmlPort "C5 CustTrans";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5CustTrans, CsvProcessedStream, TempBlob) then
            exit;

        C5CustTransXmlPort.SetSource(CsvProcessedStream);
        C5CustTransXmlPort.Import();
    end;

    local procedure LoadC5Accounts()
    var
        C5LedTable: Record "C5 LedTable";
        TempBlob: Record TempBlob temporary;
        C5LedTableXmlPort: XmlPort "C5 LedTable";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5LedTable, CsvProcessedStream, TempBlob) then
            exit;

        C5LedTableXmlPort.SetSource(CsvProcessedStream);
        C5LedTableXmlPort.Import();
    end;

    local procedure LoadC5Items()
    var
        C5InvenTable: Record "C5 InvenTable";
        TempBlob: Record TempBlob temporary;
        C5InvenTableXmlPort: XmlPort "C5 InvenTable";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5InvenTable, CsvProcessedStream, TempBlob) then
            exit;

        C5InvenTableXmlPort.SetSource(CsvProcessedStream);
        C5InvenTableXmlPort.Import();
    end;

    local procedure LoadC5Vendors()
    var
        C5VendTable: Record "C5 VendTable";
        TempBlob: Record TempBlob temporary;
        C5VendTableXmlPort: XmlPort "C5 VendTable";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5VendTable, CsvProcessedStream, TempBlob) then
            exit;

        C5VendTableXmlPort.SetSource(CsvProcessedStream);
        C5VendTableXmlPort.Import();
    end;

    local procedure LoadC5VendorGroups()
    var
        C5VendGroup: Record "C5 VendGroup";
        TempBlob: Record TempBlob temporary;
        C5VendGroupXmlPort: XmlPort "C5 VendGroup";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5VendGroup, CsvProcessedStream, TempBlob) then
            exit;

        C5VendGroupXmlPort.SetSource(CsvProcessedStream);
        C5VendGroupXmlPort.Import();
    end;

    local procedure LoadC5VendorTrans()
    var
        C5VendTrans: Record "C5 VendTrans";
        TempBlob: Record TempBlob temporary;
        C5VendTransXmlPort: XmlPort "C5 VendTrans";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5VendTrans, CsvProcessedStream, TempBlob) then
            exit;

        C5VendTransXmlPort.SetSource(CsvProcessedStream);
        C5VendTransXmlPort.Import();
    end;

    local procedure LoadC5Deliveries()
    var
        C5Delivery: Record "C5 Delivery";
        TempBlob: Record TempBlob temporary;
        C5DeliveryXmlPort: XmlPort "C5 Delivery";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5Delivery, CsvProcessedStream, TempBlob) then
            exit;

        C5DeliveryXmlPort.SetSource(CsvProcessedStream);
        C5DeliveryXmlPort.Import();
    end;

    local procedure LoadC5Payments()
    var
        C5Payment: Record "C5 Payment";
        TempBlob: Record TempBlob temporary;
        C5PaymentXmlPort: XmlPort "C5 Payment";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5Payment, CsvProcessedStream, TempBlob) then
            exit;

        C5PaymentXmlPort.SetSource(CsvProcessedStream);
        C5PaymentXmlPort.Import();
    end;

    local procedure LoadC5ExchangeRates()
    var
        C5ExchRate: Record "C5 ExchRate";
        TempBlob: Record TempBlob temporary;
        C5ExchRateXmlPort: XmlPort "C5 Exch. Rate";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5ExchRate, CsvProcessedStream, TempBlob) then
            exit;

        C5ExchRateXmlPort.SetSource(CsvProcessedStream);
        C5ExchRateXmlPort.Import();
    end;

    procedure LoadC5LedTrans()
    var
        C5LedTrans: Record "C5 LedTrans";
        TempBlob: Record TempBlob temporary;
        C5LedTransXmlPort: XmlPort "C5 LedTrans";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5LedTrans, CsvProcessedStream, TempBlob) then
            exit;

        C5LedTransXmlPort.SetSource(CsvProcessedStream);
        C5LedTransXmlPort.Import();
    end;

    local procedure LoadC5InvenBOM()
    var
        C5InvenBOM: Record "C5 InvenBOM";
        TempBlob: Record TempBlob temporary;
        C5InvenBOMXmlPort: XmlPort "C5 InvenBOM";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5InvenBOM, CsvProcessedStream, TempBlob) then
            exit;

        C5InvenBOMXmlPort.SetSource(CsvProcessedStream);
        C5InvenBOMXmlPort.Import();
    end;

    local procedure LoadC5CustContact()
    var
        C5CustContact: Record "C5 CustContact";
        TempBlob: Record TempBlob temporary;
        C5CustContactXmlPort: XmlPort "C5 CustContact";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5CustContact, CsvProcessedStream, TempBlob) then
            exit;

        C5CustContactXmlPort.SetSource(CsvProcessedStream);
        C5CustContactXmlPort.Import();
    end;

    local procedure LoadC5VendContact()
    var
        C5VendContact: Record "C5 VendContact";
        TempBlob: Record TempBlob temporary;
        C5VendContactXmlPort: XmlPort "C5 VendContact";
        CsvProcessedStream: InStream;
    begin
        if not OpenRecordFileAndProcessSubsts(C5VendContact, CsvProcessedStream, TempBlob) then
            exit;

        C5VendContactXmlPort.SetSource(CsvProcessedStream);
        C5VendContactXmlPort.Import();
    end;

    local procedure GetFileNameForRecord(RecordVariant: Variant; var FileNameOut: Text)
    var
        C5SchemaParameters: Record "C5 Schema Parameters";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        C5SchemaParameters.GetSingleInstance();
        DataTypeManagement.GetRecordRef(RecordVariant, RecRef);
        RecRef.DeleteAll();
        case RecRef.Number() of
            Database::"C5 Centre":
                FileNameOut := 'exp00182.kom';
            Database::"C5 CN8Code":
                FileNameOut := 'exp00207.kom';
            Database::"C5 Country":
                FileNameOut := 'exp00007.kom';
            Database::"C5 CustDiscGroup":
                FileNameOut := 'exp00040.kom';
            Database::"C5 CustTable":
                FileNameOut := 'exp00033.kom';
            Database::"C5 CustGroup":
                FileNameOut := 'exp00034.kom';
            Database::"C5 CustTrans":
                FileNameOut := 'exp00037.kom';
            Database::"C5 Delivery":
                FileNameOut := 'exp00019.kom';
            Database::"C5 Department":
                FileNameOut := 'exp00017.kom';
            Database::"C5 Employee":
                FileNameOut := 'exp00011.kom';
            Database::"C5 InvenCustDisc":
                FileNameOut := 'exp00061.kom';
            Database::"C5 InvenDiscGroup":
                FileNameOut := 'exp00060.kom';
            Database::"C5 InvenItemGroup":
                FileNameOut := 'exp00050.kom';
            Database::"C5 InvenTrans":
                FileNameOut := 'exp00055.kom';
            Database::"C5 InvenLocation":
                FileNameOut := 'exp00018.kom';
            Database::"C5 InvenPrice":
                FileNameOut := 'exp00063.kom';
            Database::"C5 InvenPriceGroup":
                FileNameOut := 'exp00064.kom';
            Database::"C5 InvenTable":
                FileNameOut := 'exp00049.kom';
            Database::"C5 ItemTrackGroup":
                FileNameOut := 'exp00181.kom';
            Database::"C5 LedTable":
                FileNameOut := 'exp00025.kom';
            Database::"C5 LedTrans":
                FileNameOut := 'exp00030.kom';
            Database::"C5 Payment":
                FileNameOut := 'exp00021.kom';
            Database::"C5 ProcCode":
                FileNameOut := 'exp00094.kom';
            Database::"C5 Purpose":
                FileNameOut := 'exp00183.kom';
            Database::"C5 UnitCode":
                FileNameOut := 'exp00020.kom';
            Database::"C5 VatGroup":
                FileNameOut := 'exp00201.kom';
            Database::"C5 VendDiscGroup":
                FileNameOut := 'exp00048.kom';
            Database::"C5 VendTable":
                FileNameOut := 'exp00041.kom';
            Database::"C5 VendGroup":
                FileNameOut := 'exp00042.kom';
            Database::"C5 VendTrans":
                FileNameOut := 'exp00045.kom';
            Database::"C5 ExchRate":
                FileNameOut := 'exp00016.kom';
            Database::"C5 InvenBOM":
                FileNameOut := 'exp00059.kom';
            Database::"C5 CustContact":
                FileNameOut := 'exp00177.kom';
            Database::"C5 VendContact":
                FileNameOut := 'exp00178.kom';
        end;
    end;

    local procedure OpenRecordFileAndProcessSubsts(RecordVariant: Variant; var ProcessedStream: InStream; var TempBlob: Record TempBlob temporary): Boolean
    var
        HelperFunction: Codeunit "C5 Helper Functions";
        Filename: Text;
        FileContentStream: InStream;
    begin
        GetFileNameForRecord(RecordVariant, Filename);
        if not HelperFunction.GetFileContentAsStream(Filename, NameValueBuffer, FileContentStream) then
            exit(false);

        HelperFunctions.ProcessStreamForSubstitutions(TempBlob, FileContentStream, ProcessedStream);
        exit(true);
    end;

    local procedure StopPendingMigrationsAndSurfaceErrors()
    var
        DataMigrationStatus: Record "Data Migration Status";
        DataMigrationError: Record "Data Migration Error";
        C5DataMigrDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
    begin
        DataMigrationStatus.SetRange("Migration Type", C5DataMigrDashboardMgt.GetC5MigrationTypeTxt());
        DataMigrationStatus.SetRange(Status, DataMigrationStatus.Status::Pending);
        if DataMigrationStatus.FindSet() then
            repeat
                DataMigrationStatus.Validate(Status, DataMigrationStatus.Status::Stopped);
                DataMigrationStatus.Modify(true);
                DataMigrationError.CreateEntryNoStagingTable(DataMigrationStatus."Migration Type", DataMigrationStatus."Destination Table ID");
            until DataMigrationStatus.Next() = 0;
        // Fail the background session
        Commit();
        Error('');
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFillStagingTablesStarted()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFillStagingTablesFinished(DurationAsInt: Integer)
    begin
    end;


}
