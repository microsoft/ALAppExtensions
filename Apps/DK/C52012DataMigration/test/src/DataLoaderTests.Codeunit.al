// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 148006 "C5 Data Loader Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        DataMigrationFacade: Codeunit "Data Migration Facade";
        C5MigrationTypeTxt: Label 'C5 2012', Locked = true;

    trigger OnRun();
    begin
        // [FEATURE] [C5 Data Migration]
    end;

    local procedure Initialize()
    var
        DataMigrationStatus: Record "Data Migration Status";
    begin
        ClearStagingTables();
        DataMigrationStatus.DeleteAll();
    end;

    [Test]
    procedure TestStagingTablesLoadingForItemsOnly()
    begin
        // [SCENARIO] Migration for Items should fill only Items related staging tables
        Initialize();
        // [GIVEN] Only Items are Selected
        InitialiazeDataMigrationStatus(0, 0, 0, 10, 0);

        // [GIVEN] The files are stored in a blob
        CopyZipFileInBlob();

        // [WHEN] OnFillStagingTables is fired
        DataMigrationFacade.OnFillStagingTables();

        // [THEN] All Staging Tables are filled
        VerifyStagingTablesForNotCustomers();
        VerifyStagingTablesForNotCustomersAndNotVendors();
        VerifyStagingTablesForNotHistory();
        VerifyStagingTablesForItems();
    end;

    [Test]
    procedure TestStagingTablesLoadingForVendorsOnly()
    begin
        // [SCENARIO] Migration for Vendors should fill only Vendors related staging tables
        Initialize();
        // [GIVEN] Only Vendors are Selected
        InitialiazeDataMigrationStatus(0, 0, 10, 0, 0);

        // [GIVEN] The files are stored in a blob
        CopyZipFileInBlob();

        // [WHEN] OnFillStagingTables is fired
        DataMigrationFacade.OnFillStagingTables();

        // [THEN] All Staging Tables are filled
        VerifyStagingTablesForNotItems();
        VerifyStagingTablesForNotCustomers();
        VerifyStagingTablesForNotCustomersAndNotItems();
        VerifyStagingTablesForNotHistory();
        VerifyStagingTablesForVendors();
    end;

    [Test]
    procedure TestStagingTablesLoadingForCustomersOnly()
    begin
        // [SCENARIO] Migration for Customers should fill only Customers related staging tables
        Initialize();
        // [GIVEN] Only Customers are Selected
        InitialiazeDataMigrationStatus(0, 10, 0, 0, 0);

        // [GIVEN] The files are stored in a blob
        CopyZipFileInBlob();

        // [WHEN] OnFillStagingTables is fired
        DataMigrationFacade.OnFillStagingTables();

        // [THEN] All Staging Tables are filled
        VerifyStagingTablesForNotItems();
        VerifyStagingTablesForNotVendors();
        VerifyStagingTablesForNotHistory();
        VerifyStagingTablesForCustomers();
    end;

    [Test]
    procedure TestStagingTablesLoadingForAccountsOnly()
    begin
        // [SCENARIO] Migration for Accounts should fill only Accounts related staging tables
        Initialize();
        // [GIVEN] Only Accounts are Selected
        InitialiazeDataMigrationStatus(10, 0, 0, 0, 0);

        // [GIVEN] The files are stored in a blob
        CopyZipFileInBlob();

        // [WHEN] OnFillStagingTables is fired
        DataMigrationFacade.OnFillStagingTables();

        // [THEN] All Staging Tables are filled
        VerifyStagingTablesForNotItems();
        VerifyStagingTablesForNotVendors();
        VerifyStagingTablesForNotCustomers();
        VerifyStagingTablesForNotCustomersAndNotVendorsAndNotItems();
        VerifyStagingTablesForNotHistory();
        VerifyStagingTablesForAccounts();
    end;

    [Test]
    procedure TestStagingTablesLoadingForHistoryOnly()
    begin
        // [SCENARIO] Migration for History should fill only Accounts related staging tables
        Initialize();
        // [GIVEN] Only History are Selected
        InitialiazeDataMigrationStatus(0, 0, 0, 0, 10);

        // [GIVEN] The files are stored in a blob
        CopyZipFileInBlob();

        // [WHEN] OnFillStagingTables is fired
        DataMigrationFacade.OnFillStagingTables();

        // [THEN] All Staging Tables are filled
        VerifyStagingTablesForNotItems();
        VerifyStagingTablesForNotVendors();
        VerifyStagingTablesForNotCustomers();
        VerifyStagingTablesForNotCustomersAndNotVendorsAndNotItems();
        VerifyStagingTablesForHistory();
    end;

    [Test]
    procedure TestStagingTablesLoadingForAllMasterData()
    begin
        // [SCENARIO] Migration for all Master Data tables should fill all related staging tables
        Initialize();
        // [GIVEN] All Master Data Tables are Selected
        InitialiazeDataMigrationStatus(10, 10, 10, 10, 0);

        // [GIVEN] The files are stored in a blob
        CopyZipFileInBlob();

        // [WHEN] OnFillStagingTables is fired
        DataMigrationFacade.OnFillStagingTables();

        // [THEN] All Staging Tables are filled
        VerifyStagingTablesForNotHistory();
        VerifyStagingTablesForItems();
        VerifyStagingTablesForVendors();
        VerifyStagingTablesForCustomers();
        VerifyStagingTablesForAccounts();
    end;

    [Test]
    procedure TestStagingTablesLoadingForAllData()
    var
        DataMigrationStatus: Record "Data Migration Status";
        DataMIgrationError: Record "Data Migration Error";
    begin
        // [SCENARIO] Migration for all Data tables should fill all related staging tables
        Initialize();
        // [GIVEN] All Tables are Selected
        InitialiazeDataMigrationStatus(10, 10, 10, 10, 10);

        // [GIVEN] The files are not stored in blob
        DeleteZipFileBlobFromC5SchemaParametersIntance();

        // [WHEN] OnFillStagingTables is fired
        // [THEN] An error is fired
        AssertError DataMigrationFacade.OnFillStagingTables();

        // [THEN] All Staging Tables are filled
        DataMigrationStatus.FindSet();
        repeat
            Assert.AreEqual(DataMigrationStatus.Status, DataMigrationStatus.Status::Stopped, 'Status was expected to be Stopped');
            DataMIgrationError.SetRange("Destination Table ID", DataMigrationStatus."Destination Table ID");
            Assert.RecordIsNotEmpty(DataMIgrationError);
        until DataMigrationStatus.Next() = 0;
    end;

    [Test]
    procedure TestOnFailToUnzipFile()
    begin
        // [SCENARIO] If the unziping of the file fails then all migrations are stopped and the error is logged
        Initialize();
        // [GIVEN] All Tables are Selected
        InitialiazeDataMigrationStatus(10, 10, 10, 10, 10);

        // [GIVEN] An empty zip file is stored on the blob
        CopyZipFileInBlob();

        // [WHEN] OnFillStagingTables is fired
        DataMigrationFacade.OnFillStagingTables();

        // [THEN] All Staging Tables are filled
        VerifyStagingTablesForItems();
        VerifyStagingTablesForVendors();
        VerifyStagingTablesForCustomers();
        VerifyStagingTablesForAccounts();
        VerifyStagingTablesForHistory();
    end;

    local procedure VerifyStagingTablesForItems()
    var
        C5InvenTable: Record "C5 InvenTable";
        C5CN8Code: Record "C5 CN8Code";
        C5UnitCode: Record "C5 UnitCode";
        C5InvenPrice: Record "C5 InvenPrice";
        C5InvenCustDisc: Record "C5 InvenCustDisc";
        C5InvenPriceGroup: Record "C5 InvenPriceGroup";
        C5Centre: Record "C5 Centre";
        C5Department: Record "C5 Department";
        C5Purpose: Record "C5 Purpose";
        C5InvenTrans: Record "C5 InvenTrans";
    begin
        // Item only Tables
        Assert.RecordCount(C5InvenTable, 5);
        Assert.RecordCount(C5CN8Code, 5);
        Assert.RecordCount(C5UnitCode, 3);
        Assert.RecordCount(C5InvenPrice, 5);
        Assert.RecordCount(C5InvenCustDisc, 5);
        Assert.RecordCount(C5InvenTrans, 5);

        // Customer and Item tables
        Assert.RecordCount(C5InvenPriceGroup, 5);

        // Customer Vendor and Item tables
        Assert.RecordCount(C5Centre, 2);
        Assert.RecordCount(C5Department, 4);
        Assert.RecordCount(C5Purpose, 3);
    end;

    local procedure VerifyStagingTablesForHistory()
    var
        C5LedTrans: Record "C5 LedTrans";
    begin
        // Item only Tables
        Assert.RecordCount(C5LedTrans, 5);
    end;

    local procedure VerifyStagingTablesForNotHistory()
    var
        C5LedTrans: Record "C5 LedTrans";
    begin
        // Item only Tables
        Assert.RecordIsEmpty(C5LedTrans);
    end;

    local procedure VerifyStagingTablesForNotItems()
    var
        C5InvenTable: Record "C5 InvenTable";
        C5CN8Code: Record "C5 CN8Code";
        C5UnitCode: Record "C5 UnitCode";
        C5InvenPrice: Record "C5 InvenPrice";
        C5InvenCustDisc: Record "C5 InvenCustDisc";
        C5InvenTrans: Record "C5 InvenTrans";
    begin
        Assert.RecordIsEmpty(C5InvenTable);
        Assert.RecordIsEmpty(C5CN8Code);
        Assert.RecordIsEmpty(C5UnitCode);
        Assert.RecordIsEmpty(C5InvenPrice);
        Assert.RecordIsEmpty(C5InvenCustDisc);
        Assert.RecordIsEmpty(C5InvenTrans);
    end;

    local procedure VerifyStagingTablesForVendors()
    var
        C5VendTable: Record "C5 VendTable";
        C5VendDiscGroup: Record "C5 VendDiscGroup";
        C5Payment: Record "C5 Payment";
        C5Employee: Record "C5 Employee";
        C5Delivery: Record "C5 Delivery";
        C5Country: Record "C5 Country";
        C5Centre: Record "C5 Centre";
        C5Department: Record "C5 Department";
        C5Purpose: Record "C5 Purpose";
        C5VendTrans: Record "C5 VendTrans";
    begin
        // Vendor only Tables
        Assert.RecordCount(C5VendTable, 5);
        Assert.RecordCount(C5VendDiscGroup, 2);
        Assert.RecordCount(C5VendTrans, 2);

        // Customer and Vendor Tables
        Assert.RecordCount(C5Payment, 5);
        Assert.RecordCount(C5Employee, 5);
        Assert.RecordCount(C5Delivery, 5);
        Assert.RecordCount(C5Country, 5);

        // Customer Vendor and Item tables
        Assert.RecordCount(C5Centre, 2);
        Assert.RecordCount(C5Department, 4);
        Assert.RecordCount(C5Purpose, 3);
    end;

    local procedure VerifyStagingTablesForNotVendors()
    var
        C5VendTable: Record "C5 VendTable";
        C5VendDiscGroup: Record "C5 VendDiscGroup";
        C5VendTrans: Record "C5 VendTrans";
    begin
        Assert.RecordIsEmpty(C5VendTable);
        Assert.RecordIsEmpty(C5VendDiscGroup);
        Assert.RecordIsEmpty(C5VendTrans);
    end;

    local procedure VerifyStagingTablesForCustomers()
    var
        C5CustTable: Record "C5 CustTable";
        C5CustDiscGroup: Record "C5 CustDiscGroup";
        C5ProcCode: Record "C5 ProcCode";
        C5InvenPriceGroup: Record "C5 InvenPriceGroup";
        C5Payment: Record "C5 Payment";
        C5Employee: Record "C5 Employee";
        C5Delivery: Record "C5 Delivery";
        C5Country: Record "C5 Country";
        C5Centre: Record "C5 Centre";
        C5Department: Record "C5 Department";
        C5Purpose: Record "C5 Purpose";
        C5CustTrans: Record "C5 CustTrans";
    begin
        // Customer Only tables
        Assert.RecordCount(C5CustTable, 5);
        Assert.RecordCount(C5CustDiscGroup, 3);
        Assert.RecordCount(C5ProcCode, 5);
        Assert.RecordCount(C5CustTrans, 5);

        // Customer and Item tables
        Assert.RecordCount(C5InvenPriceGroup, 5);

        // Customer and Vendor Tables
        Assert.RecordCount(C5Payment, 5);
        Assert.RecordCount(C5Employee, 5);
        Assert.RecordCount(C5Delivery, 5);
        Assert.RecordCount(C5Country, 5);

        // Customer Vendor and Item tables
        Assert.RecordCount(C5Centre, 2);
        Assert.RecordCount(C5Department, 4);
        Assert.RecordCount(C5Purpose, 3);
    end;

    local procedure VerifyStagingTablesForNotCustomers()
    var
        C5CustTable: Record "C5 CustTable";
        C5CustDiscGroup: Record "C5 CustDiscGroup";
        C5ProcCode: Record "C5 ProcCode";
        C5CustTrans: Record "C5 CustTrans";
    begin
        Assert.RecordIsEmpty(C5CustTable);
        Assert.RecordIsEmpty(C5CustDiscGroup);
        Assert.RecordIsEmpty(C5ProcCode);
        Assert.RecordIsEmpty(C5CustTrans);
    end;

    local procedure VerifyStagingTablesForAccounts()
    var
        C5LedTable: Record "C5 LedTable";
    begin
        Assert.RecordCount(C5LedTable, 5);
    end;

    local procedure VerifyStagingTablesForNotCustomersAndNotVendors()
    var
        C5Payment: Record "C5 Payment";
        C5Employee: Record "C5 Employee";
        C5Delivery: Record "C5 Delivery";
        C5Country: Record "C5 Country";
    begin
        VerifyStagingTablesForNotCustomers();
        VerifyStagingTablesForNotVendors();

        Assert.RecordIsEmpty(C5Payment);
        Assert.RecordIsEmpty(C5Employee);
        Assert.RecordIsEmpty(C5Delivery);
        Assert.RecordIsEmpty(C5Country);
    end;

    local procedure VerifyStagingTablesForNotCustomersAndNotVendorsAndNotItems()
    var
        C5Centre: Record "C5 Centre";
        C5Department: Record "C5 Department";
        C5Purpose: Record "C5 Purpose";
    begin
        VerifyStagingTablesForNotCustomersAndNotVendors();
        VerifyStagingTablesForNotCustomersAndNotItems();

        Assert.RecordIsEmpty(C5Centre);
        Assert.RecordIsEmpty(C5Department);
        Assert.RecordIsEmpty(C5Purpose);
    end;

    local procedure VerifyStagingTablesForNotCustomersAndNotItems()
    var
        C5InvenPriceGroup: Record "C5 InvenPriceGroup";
    begin
        VerifyStagingTablesForNotCustomers();
        VerifyStagingTablesForNotItems();

        Assert.RecordIsEmpty(C5InvenPriceGroup);
    end;

    local procedure InitialiazeDataMigrationStatus(TotalAccounts: Integer; TotalCustomers: Integer; TotalVendors: Integer; TotalItems: Integer; TotalHistory: Integer)
    var
        DataMigrationStatusFacade: Codeunit "Data Migration Status Facade";
    begin
        DataMigrationStatusFacade.InitStatusLine(CopyStr(C5MigrationTypeTxt, 1, 250), Database::Item, TotalItems, Database::"C5 InvenTable", Codeunit::"C5 Item Migrator");
        DataMigrationStatusFacade.InitStatusLine(CopyStr(C5MigrationTypeTxt, 1, 250), Database::Customer, TotalCustomers, Database::"C5 CustTable", Codeunit::"C5 CustTable Migrator");
        DataMigrationStatusFacade.InitStatusLine(CopyStr(C5MigrationTypeTxt, 1, 250), Database::Vendor, TotalVendors, Database::"C5 VendTable", Codeunit::"C5 VendTable Migrator");
        DataMigrationStatusFacade.InitStatusLine(CopyStr(C5MigrationTypeTxt, 1, 250), Database::"G/L Account", TotalAccounts, Database::"C5 LedTable", Codeunit::"C5 LedTable Migrator");
        DataMigrationStatusFacade.InitStatusLine(CopyStr(C5MigrationTypeTxt, 1, 250), Database::"C5 LedTrans", TotalHistory, 0, Codeunit::"C5 Migr. Dashboard Mgt");
    end;

    local procedure CopyZipFileInBlob()
    var
        C5SchemaParameters: Record "C5 Schema Parameters";
        ZipFile: File;
        FileInStream: InStream;
        BlobOutStream: OutStream;
    begin
        ZipFile.Open(GetHardcodedPathToArchives() + 'Data.zip');
        ZipFile.CreateInStream(FileInStream);

        C5SchemaParameters.GetSingleInstance();
        C5SchemaParameters."Zip File Blob".CreateOutStream(BlobOutStream);
        CopyStream(BlobOutStream, FileInStream);
        C5SchemaParameters.Modify();
        Commit();
        ZipFile.Close();
    end;

    local procedure DeleteZipFileBlobFromC5SchemaParametersIntance()
    var
        C5SchemaParameters: Record "C5 Schema Parameters";
    begin
        C5SchemaParameters.GetSingleInstance();
        Clear(C5SchemaParameters."Zip File Blob");
        C5SchemaParameters.Modify();
        Commit();
    end;


    local procedure ClearStagingTables()
    var
        C5InvenTable: Record "C5 InvenTable";
        C5CN8Code: Record "C5 CN8Code";
        C5UnitCode: Record "C5 UnitCode";
        C5InvenPrice: Record "C5 InvenPrice";
        C5InvenCustDisc: Record "C5 InvenCustDisc";
        C5InvenPriceGroup: Record "C5 InvenPriceGroup";
        C5Centre: Record "C5 Centre";
        C5Department: Record "C5 Department";
        C5Purpose: Record "C5 Purpose";
        C5CustTable: Record "C5 CustTable";
        C5CustDiscGroup: Record "C5 CustDiscGroup";
        C5ProcCode: Record "C5 ProcCode";
        C5Payment: Record "C5 Payment";
        C5Employee: Record "C5 Employee";
        C5Delivery: Record "C5 Delivery";
        C5Country: Record "C5 Country";
        C5LedTable: Record "C5 LedTable";
        C5VendTable: Record "C5 VendTable";
        C5VendDiscGroup: Record "C5 VendDiscGroup";
        C5LedTrans: Record "C5 LedTrans";
        C5InvenTrans: Record "C5 InvenTrans";
        C5CustTrans: Record "C5 CustTrans";
        C5VendTrans: Record "C5 VendTrans";
    begin
        C5InvenTable.DeleteAll();
        C5CN8Code.DeleteAll();
        C5UnitCode.DeleteAll();
        C5InvenPrice.DeleteAll();
        C5InvenCustDisc.DeleteAll();
        C5InvenPriceGroup.DeleteAll();
        C5Centre.DeleteAll();
        C5Department.DeleteAll();
        C5Purpose.DeleteAll();
        C5CustTable.DeleteAll();
        C5CustDiscGroup.DeleteAll();
        C5ProcCode.DeleteAll();
        C5Payment.DeleteAll();
        C5Employee.DeleteAll();
        C5Delivery.DeleteAll();
        C5Country.DeleteAll();
        C5LedTable.DeleteAll();
        C5VendTable.DeleteAll();
        C5VendDiscGroup.DeleteAll();
        C5LedTrans.DeleteAll();
        C5InvenTrans.DeleteAll();
        C5CustTrans.DeleteAll();
        C5VendTrans.DeleteAll();
    end;

    procedure GetHardcodedPathToArchives(): Text
    var
        NavRootPath: Text;
        NavRootPosition: Integer;
    begin
        NavRootPosition := STRPOS(ApplicationPath(), '\Run\NST\');
        NavRootPath := DELSTR(ApplicationPath(), NavRootPosition);
        exit(NavRootPath + '\App\Apps\DK\C52012DataMigration\test\resources\');
    end;
}