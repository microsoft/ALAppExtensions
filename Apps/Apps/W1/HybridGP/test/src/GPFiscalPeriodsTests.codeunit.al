codeunit 139680 "GP Fiscal Periods Tests"
{
    // [FEATURE] [GP Data Migration]

    EventSubscriberInstance = Manual;
    Subtype = Test;
    Permissions = tableData "Accounting Period" = rimd;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPFiscalPeriodsCalanderYears()
    var
        AccountingPeriod: Record "Accounting Period";
        GPSY40101: Record "GP SY40101";
        GPSY40100: Record "GP SY40100";
    begin
        // [SCENARIO] Fiscal Periods are migrated from GP
        // [GIVEN] There are no records in the Accounting Period table
        ClearTables();

        // [GIVEN] Some records are created in the staging tables
        CreateCalendarYearPeriodData(GPSY40101, GPSY40100);

        // [WHEN] Fiscal Period migration code is called
        MigrateData();

        // [THEN] Accounting Periods are created
        //     9 years with 12 periods per year = 108
        AccountingPeriod.Reset();
        Assert.RecordCount(AccountingPeriod, 108);

        // [THEN] Accounting Periods are created as Open
        AccountingPeriod.Reset();
        AccountingPeriod.SetFilter(Closed, '1');
        Assert.RecordCount(AccountingPeriod, 0);

        AccountingPeriod.Reset();
        AccountingPeriod.SetFilter(Closed, '0');
        Assert.RecordCount(AccountingPeriod, 108);

        // [THEN] Accounting Periods are created with proper settings
        AccountingPeriod.Reset();
        AccountingPeriod.SetFilter("New Fiscal Year", '1');
        Assert.RecordCount(AccountingPeriod, 9);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPFiscalPeriodsNonCalendarYears()
    var
        AccountingPeriod: Record "Accounting Period";
        GPSY40101: Record "GP SY40101";
        GPSY40100: Record "GP SY40100";
    begin
        // [SCENARIO] Fiscal Periods are migrated from GP
        // [GIVEN] There are no records in the Accounting Period table
        ClearTables();

        // [GIVEN] Some records are created in the staging table
        CreateNonCalendarPeriods(GPSY40101, GPSY40100);

        // [WHEN] Fiscal Period migration code is called
        MigrateData();

        // [THEN] Accounting Periods are created
        //     6 years with 12 periods per year = 72
        AccountingPeriod.Reset();
        Assert.RecordCount(AccountingPeriod, 72);

        // [THEN] Accounting Periods are created as Open
        AccountingPeriod.Reset();
        AccountingPeriod.SetFilter(Closed, '1');
        Assert.RecordCount(AccountingPeriod, 0);

        AccountingPeriod.Reset();
        AccountingPeriod.SetFilter(Closed, '0');
        Assert.RecordCount(AccountingPeriod, 72);

        // [THEN] Accounting Periods are created with proper settings
        AccountingPeriod.Reset();
        AccountingPeriod.SetFilter("New Fiscal Year", '1');
        Assert.RecordCount(AccountingPeriod, 6);
    end;


    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPFiscalPeriodsNonTypicalYears()
    var
        AccountingPeriod: Record "Accounting Period";
        GPSY40101: Record "GP SY40101";
        GPSY40100: Record "GP SY40100";
    begin
        // [SCENARIO] Fiscal Periods are migrated from GP
        // [GIVEN] There are no records in the Accounting Period table
        ClearTables();

        // [GIVEN] Some records are created in the staging table
        CreateNonTypicalPeriods(GPSY40101, GPSY40100);

        // [WHEN] Fiscal Period migration code is called
        MigrateData();

        // [THEN] Accounting Periods are created
        //     40 periods (6, 6, 24, 4) over 4 years 
        AccountingPeriod.Reset();
        Assert.RecordCount(AccountingPeriod, 40);

        // [THEN] Accounting Periods are created as Open
        AccountingPeriod.Reset();
        AccountingPeriod.SetFilter(Closed, '1');
        Assert.RecordCount(AccountingPeriod, 0);

        AccountingPeriod.Reset();
        AccountingPeriod.SetFilter(Closed, '0');
        Assert.RecordCount(AccountingPeriod, 40);

        // [THEN] Accounting Periods are created with proper settings
        AccountingPeriod.Reset();
        AccountingPeriod.SetFilter("New Fiscal Year", '1');
        Assert.RecordCount(AccountingPeriod, 4);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPLimitFiscalPeriods()
    var
        AccountingPeriod: Record "Accounting Period";
        GPSY40101: Record "GP SY40101";
        GPSY40100: Record "GP SY40100";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        // [SCENARIO] Fiscal Periods are migrated from GP
        // [GIVEN] There are no records in the Accounting Period table
        ClearTables();

        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Oldest GL Year to Migrate", 2023);
        GPCompanyAdditionalSettings.Modify();

        // [GIVEN] Some records are created in the staging table
        CreateNonCalendarPeriods(GPSY40101, GPSY40100);

        // [WHEN] Fiscal Period migration code is called
        MigrateData();

        // [THEN] Accounting Periods are created
        //     3 years with 12 periods per year = 36
        AccountingPeriod.Reset();
        Assert.RecordCount(AccountingPeriod, 36);

        // [THEN] Accounting Periods are created as Open
        AccountingPeriod.Reset();
        AccountingPeriod.SetFilter(Closed, '1');
        Assert.RecordCount(AccountingPeriod, 0);

        AccountingPeriod.Reset();
        AccountingPeriod.SetFilter(Closed, '0');
        Assert.RecordCount(AccountingPeriod, 36);
    end;

    local procedure ClearTables()
    var
        AccountingPeriod: Record "Accounting Period";
        GPSY40101: Record "GP SY40101";
        GPSY40100: Record "GP SY40100";
    begin
        AccountingPeriod.DeleteAll();
        GPSY40101.DeleteAll();
        GPSY40100.DeleteAll();
    end;

    local procedure MigrateData()
    var
        FiscalPeriods: Codeunit FiscalPeriods;
    begin
        FiscalPeriods.MoveStagingData();
    end;


    local procedure CreateCalendarYearPeriodData(var GPSY40101: Record "GP SY40101"; var GPSY40100: Record "GP SY40100")
    begin
        GPSY40101.Init();
        GPSY40101.YEAR1 := 2020;
        GPSY40101.NUMOFPER := 12;
        GPSY40101.FSTFSCDY := CreateDateTime(20200101D, 0T);
        GPSY40101.LSTFSCDY := CreateDateTime(20201231D, 0T);
        GPSY40101.HISTORYR := true;
        GPSY40101.Insert(true);

        GPSY40101.Init();
        GPSY40101.YEAR1 := 2021;
        GPSY40101.NUMOFPER := 12;
        GPSY40101.FSTFSCDY := CreateDateTime(20210101D, 0T);
        GPSY40101.LSTFSCDY := CreateDateTime(20211231D, 0T);
        GPSY40101.HISTORYR := true;
        GPSY40101.Insert(true);

        GPSY40101.Init();
        GPSY40101.YEAR1 := 2022;
        GPSY40101.NUMOFPER := 12;
        GPSY40101.FSTFSCDY := CreateDateTime(20220101D, 0T);
        GPSY40101.LSTFSCDY := CreateDateTime(20221231D, 0T);
        GPSY40101.HISTORYR := true;
        GPSY40101.Insert(true);

        GPSY40101.Init();
        GPSY40101.YEAR1 := 2023;
        GPSY40101.NUMOFPER := 12;
        GPSY40101.FSTFSCDY := CreateDateTime(20230101D, 0T);
        GPSY40101.LSTFSCDY := CreateDateTime(20231231D, 0T);
        GPSY40101.HISTORYR := false;
        GPSY40101.Insert(true);

        GPSY40101.Init();
        GPSY40101.YEAR1 := 2024;
        GPSY40101.NUMOFPER := 12;
        GPSY40101.FSTFSCDY := CreateDateTime(20240101D, 0T);
        GPSY40101.LSTFSCDY := CreateDateTime(20241231D, 0T);
        GPSY40101.HISTORYR := false;
        GPSY40101.Insert(true);

        GPSY40101.Init();
        GPSY40101.YEAR1 := 2025;
        GPSY40101.NUMOFPER := 12;
        GPSY40101.FSTFSCDY := CreateDateTime(20250101D, 0T);
        GPSY40101.LSTFSCDY := CreateDateTime(20251231D, 0T);
        GPSY40101.HISTORYR := false;
        GPSY40101.Insert(true);

        GPSY40101.Init();
        GPSY40101.YEAR1 := 2026;
        GPSY40101.NUMOFPER := 12;
        GPSY40101.FSTFSCDY := CreateDateTime(20260101D, 0T);
        GPSY40101.LSTFSCDY := CreateDateTime(20261231D, 0T);
        GPSY40101.HISTORYR := false;
        GPSY40101.Insert(true);

        GPSY40101.Init();
        GPSY40101.YEAR1 := 2027;
        GPSY40101.NUMOFPER := 12;
        GPSY40101.FSTFSCDY := CreateDateTime(20270101D, 0T);
        GPSY40101.LSTFSCDY := CreateDateTime(20271231D, 0T);
        GPSY40101.HISTORYR := true;
        GPSY40101.Insert(true);

        GPSY40101.Init();
        GPSY40101.YEAR1 := 2028;
        GPSY40101.NUMOFPER := 12;
        GPSY40101.FSTFSCDY := CreateDateTime(20280101D, 0T);
        GPSY40101.LSTFSCDY := CreateDateTime(20281231D, 0T);
        GPSY40101.HISTORYR := true;
        GPSY40101.Insert(true);

        CreatePeriodSetupData(GPSY40100);
    end;

    local procedure CreateNonCalendarPeriods(var GPSY40101: Record "GP SY40101"; var GPSY40100: Record "GP SY40100")
    var
        year: Integer;
    begin
        GPSY40101.Init();
        GPSY40101.YEAR1 := 2020;
        GPSY40101.NUMOFPER := 12;
        GPSY40101.FSTFSCDY := CreateDateTime(20200601D, 0T);
        GPSY40101.LSTFSCDY := CreateDateTime(20210531D, 0T);
        GPSY40101.HISTORYR := true;
        GPSY40101.Insert(true);

        GPSY40101.Init();
        GPSY40101.YEAR1 := 2021;
        GPSY40101.NUMOFPER := 12;
        GPSY40101.FSTFSCDY := CreateDateTime(20210601D, 0T);
        GPSY40101.LSTFSCDY := CreateDateTime(20220531D, 0T);
        GPSY40101.HISTORYR := true;
        GPSY40101.Insert(true);

        GPSY40101.Init();
        GPSY40101.YEAR1 := 2022;
        GPSY40101.NUMOFPER := 12;
        GPSY40101.FSTFSCDY := CreateDateTime(20220601D, 0T);
        GPSY40101.LSTFSCDY := CreateDateTime(20230531D, 0T);
        GPSY40101.HISTORYR := false;
        GPSY40101.Insert(true);

        GPSY40101.Init();
        GPSY40101.YEAR1 := 2023;
        GPSY40101.NUMOFPER := 12;
        GPSY40101.FSTFSCDY := CreateDateTime(20230601D, 0T);
        GPSY40101.LSTFSCDY := CreateDateTime(20240531D, 0T);
        GPSY40101.HISTORYR := false;
        GPSY40101.Insert(true);

        GPSY40101.Init();
        GPSY40101.YEAR1 := 2024;
        GPSY40101.NUMOFPER := 12;
        GPSY40101.FSTFSCDY := CreateDateTime(20240601D, 0T);
        GPSY40101.LSTFSCDY := CreateDateTime(20250531D, 0T);
        GPSY40101.HISTORYR := false;
        GPSY40101.Insert(true);

        GPSY40101.Init();
        GPSY40101.YEAR1 := 2025;
        GPSY40101.NUMOFPER := 12;
        GPSY40101.FSTFSCDY := CreateDateTime(20250601D, 0T);
        GPSY40101.LSTFSCDY := CreateDateTime(20260531D, 0T);
        GPSY40101.HISTORYR := false;
        GPSY40101.Insert(true);

        // Period Setup Data
        year := 2020;
        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 1;
        GPSY40100.PERIODDT := CreateDateTime(20200601D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20200630D, 0T);
        GPSY40100.ODESCTN := 'Period1';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 2;
        GPSY40100.PERIODDT := CreateDateTime(20200701D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20200731D, 0T);
        GPSY40100.ODESCTN := 'Period2';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 3;
        GPSY40100.PERIODDT := CreateDateTime(20200801D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20200831D, 0T);
        GPSY40100.ODESCTN := 'Period3';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 4;
        GPSY40100.PERIODDT := CreateDateTime(20200901D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20200930D, 0T);
        GPSY40100.ODESCTN := 'Period4';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 5;
        GPSY40100.PERIODDT := CreateDateTime(20201001D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20201031D, 0T);
        GPSY40100.ODESCTN := 'Period5';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 6;
        GPSY40100.PERIODDT := CreateDateTime(20201101D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20201130D, 0T);
        GPSY40100.ODESCTN := 'Period6';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 7;
        GPSY40100.PERIODDT := CreateDateTime(20201201D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20201231D, 0T);
        GPSY40100.ODESCTN := 'Period7';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 8;
        GPSY40100.PERIODDT := CreateDateTime(20210101D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20210131D, 0T);
        GPSY40100.ODESCTN := 'Period8';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 9;
        GPSY40100.PERIODDT := CreateDateTime(20210201D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20210228D, 0T);
        GPSY40100.ODESCTN := 'Period9';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 10;
        GPSY40100.PERIODDT := CreateDateTime(20210301D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20210331D, 0T);
        GPSY40100.ODESCTN := 'Period10';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 11;
        GPSY40100.PERIODDT := CreateDateTime(20210401D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20210430D, 0T);
        GPSY40100.ODESCTN := 'Period11';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 12;
        GPSY40100.PERIODDT := CreateDateTime(20210501D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20210531D, 0T);
        GPSY40100.ODESCTN := 'Period12';
        GPSY40100.Insert(true);

        year := 2021;
        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 1;
        GPSY40100.PERIODDT := CreateDateTime(20210601D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20210630D, 0T);
        GPSY40100.ODESCTN := 'Period1';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 2;
        GPSY40100.PERIODDT := CreateDateTime(20210701D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20210731D, 0T);
        GPSY40100.ODESCTN := 'Period2';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 3;
        GPSY40100.PERIODDT := CreateDateTime(20210801D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20210831D, 0T);
        GPSY40100.ODESCTN := 'Period3';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 4;
        GPSY40100.PERIODDT := CreateDateTime(20210901D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20210930D, 0T);
        GPSY40100.ODESCTN := 'Period4';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 5;
        GPSY40100.PERIODDT := CreateDateTime(20211001D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20211031D, 0T);
        GPSY40100.ODESCTN := 'Period5';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 6;
        GPSY40100.PERIODDT := CreateDateTime(20211101D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20211130D, 0T);
        GPSY40100.ODESCTN := 'Period6';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 7;
        GPSY40100.PERIODDT := CreateDateTime(20211201D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20211231D, 0T);
        GPSY40100.ODESCTN := 'Period7';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 8;
        GPSY40100.PERIODDT := CreateDateTime(20220101D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20220131D, 0T);
        GPSY40100.ODESCTN := 'Period8';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 9;
        GPSY40100.PERIODDT := CreateDateTime(20220201D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20220228D, 0T);
        GPSY40100.ODESCTN := 'Period9';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 10;
        GPSY40100.PERIODDT := CreateDateTime(20220301D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20220331D, 0T);
        GPSY40100.ODESCTN := 'Period10';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 11;
        GPSY40100.PERIODDT := CreateDateTime(20220401D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20220430D, 0T);
        GPSY40100.ODESCTN := 'Period11';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 12;
        GPSY40100.PERIODDT := CreateDateTime(20220501D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20220531D, 0T);
        GPSY40100.ODESCTN := 'Period12';
        GPSY40100.Insert(true);

        year := 2022;
        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 1;
        GPSY40100.PERIODDT := CreateDateTime(20220601D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20220630D, 0T);
        GPSY40100.ODESCTN := 'Period1';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 2;
        GPSY40100.PERIODDT := CreateDateTime(20220701D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20220731D, 0T);
        GPSY40100.ODESCTN := 'Period2';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 3;
        GPSY40100.PERIODDT := CreateDateTime(20220801D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20220831D, 0T);
        GPSY40100.ODESCTN := 'Period3';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 4;
        GPSY40100.PERIODDT := CreateDateTime(20220901D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20220930D, 0T);
        GPSY40100.ODESCTN := 'Period4';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 5;
        GPSY40100.PERIODDT := CreateDateTime(20221001D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20221031D, 0T);
        GPSY40100.ODESCTN := 'Period5';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 6;
        GPSY40100.PERIODDT := CreateDateTime(20221101D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20221130D, 0T);
        GPSY40100.ODESCTN := 'Period6';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 7;
        GPSY40100.PERIODDT := CreateDateTime(20221201D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20221231D, 0T);
        GPSY40100.ODESCTN := 'Period7';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 8;
        GPSY40100.PERIODDT := CreateDateTime(20230101D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20230131D, 0T);
        GPSY40100.ODESCTN := 'Period8';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 9;
        GPSY40100.PERIODDT := CreateDateTime(20230201D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20230228D, 0T);
        GPSY40100.ODESCTN := 'Period9';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 10;
        GPSY40100.PERIODDT := CreateDateTime(20230301D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20230331D, 0T);
        GPSY40100.ODESCTN := 'Period10';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 11;
        GPSY40100.PERIODDT := CreateDateTime(20230401D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20230430D, 0T);
        GPSY40100.ODESCTN := 'Period11';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 12;
        GPSY40100.PERIODDT := CreateDateTime(20230501D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20230531D, 0T);
        GPSY40100.ODESCTN := 'Period12';
        GPSY40100.Insert(true);

        year := 2023;
        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 1;
        GPSY40100.PERIODDT := CreateDateTime(20230601D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20230630D, 0T);
        GPSY40100.ODESCTN := 'Period1';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 2;
        GPSY40100.PERIODDT := CreateDateTime(20230701D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20230731D, 0T);
        GPSY40100.ODESCTN := 'Period2';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 3;
        GPSY40100.PERIODDT := CreateDateTime(20230801D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20230831D, 0T);
        GPSY40100.ODESCTN := 'Period3';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 4;
        GPSY40100.PERIODDT := CreateDateTime(20230901D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20230930D, 0T);
        GPSY40100.ODESCTN := 'Period4';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 5;
        GPSY40100.PERIODDT := CreateDateTime(20231001D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20231031D, 0T);
        GPSY40100.ODESCTN := 'Period5';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 6;
        GPSY40100.PERIODDT := CreateDateTime(20231101D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20231130D, 0T);
        GPSY40100.ODESCTN := 'Period6';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 7;
        GPSY40100.PERIODDT := CreateDateTime(20231201D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20231231D, 0T);
        GPSY40100.ODESCTN := 'Period7';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 8;
        GPSY40100.PERIODDT := CreateDateTime(20240101D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20240131D, 0T);
        GPSY40100.ODESCTN := 'Period8';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 9;
        GPSY40100.PERIODDT := CreateDateTime(20240201D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20240228D, 0T);
        GPSY40100.ODESCTN := 'Period9';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 10;
        GPSY40100.PERIODDT := CreateDateTime(20240301D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20240331D, 0T);
        GPSY40100.ODESCTN := 'Period10';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 11;
        GPSY40100.PERIODDT := CreateDateTime(20240401D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20240430D, 0T);
        GPSY40100.ODESCTN := 'Period11';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 12;
        GPSY40100.PERIODDT := CreateDateTime(20240501D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20240531D, 0T);
        GPSY40100.ODESCTN := 'Period12';
        GPSY40100.Insert(true);

        year := 2024;
        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 1;
        GPSY40100.PERIODDT := CreateDateTime(20240601D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20240630D, 0T);
        GPSY40100.ODESCTN := 'Period1';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 2;
        GPSY40100.PERIODDT := CreateDateTime(20240701D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20240731D, 0T);
        GPSY40100.ODESCTN := 'Period2';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 3;
        GPSY40100.PERIODDT := CreateDateTime(20240801D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20240831D, 0T);
        GPSY40100.ODESCTN := 'Period3';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 4;
        GPSY40100.PERIODDT := CreateDateTime(20240901D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20240930D, 0T);
        GPSY40100.ODESCTN := 'Period4';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 5;
        GPSY40100.PERIODDT := CreateDateTime(20241001D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20241031D, 0T);
        GPSY40100.ODESCTN := 'Period5';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 6;
        GPSY40100.PERIODDT := CreateDateTime(20241101D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20241130D, 0T);
        GPSY40100.ODESCTN := 'Period6';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 7;
        GPSY40100.PERIODDT := CreateDateTime(20241201D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20241231D, 0T);
        GPSY40100.ODESCTN := 'Period7';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 8;
        GPSY40100.PERIODDT := CreateDateTime(20250101D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20250131D, 0T);
        GPSY40100.ODESCTN := 'Period8';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 9;
        GPSY40100.PERIODDT := CreateDateTime(20250201D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20250228D, 0T);
        GPSY40100.ODESCTN := 'Period9';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 10;
        GPSY40100.PERIODDT := CreateDateTime(20250301D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20250331D, 0T);
        GPSY40100.ODESCTN := 'Period10';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 11;
        GPSY40100.PERIODDT := CreateDateTime(20250401D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20250430D, 0T);
        GPSY40100.ODESCTN := 'Period11';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 12;
        GPSY40100.PERIODDT := CreateDateTime(20250501D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20250531D, 0T);
        GPSY40100.ODESCTN := 'Period12';
        GPSY40100.Insert(true);

        year := 2025;
        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 1;
        GPSY40100.PERIODDT := CreateDateTime(20250601D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20250630D, 0T);
        GPSY40100.ODESCTN := 'Period1';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 2;
        GPSY40100.PERIODDT := CreateDateTime(20250701D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20250731D, 0T);
        GPSY40100.ODESCTN := 'Period2';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 3;
        GPSY40100.PERIODDT := CreateDateTime(20250801D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20250831D, 0T);
        GPSY40100.ODESCTN := 'Period3';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 4;
        GPSY40100.PERIODDT := CreateDateTime(20250901D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20250930D, 0T);
        GPSY40100.ODESCTN := 'Period4';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 5;
        GPSY40100.PERIODDT := CreateDateTime(20251001D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20251031D, 0T);
        GPSY40100.ODESCTN := 'Period5';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 6;
        GPSY40100.PERIODDT := CreateDateTime(20251101D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20251130D, 0T);
        GPSY40100.ODESCTN := 'Period6';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 7;
        GPSY40100.PERIODDT := CreateDateTime(20251201D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20251231D, 0T);
        GPSY40100.ODESCTN := 'Period7';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 8;
        GPSY40100.PERIODDT := CreateDateTime(20260101D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20260131D, 0T);
        GPSY40100.ODESCTN := 'Period8';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 9;
        GPSY40100.PERIODDT := CreateDateTime(20260201D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20260228D, 0T);
        GPSY40100.ODESCTN := 'Period9';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 10;
        GPSY40100.PERIODDT := CreateDateTime(20260301D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20260331D, 0T);
        GPSY40100.ODESCTN := 'Period10';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 11;
        GPSY40100.PERIODDT := CreateDateTime(20260401D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20260430D, 0T);
        GPSY40100.ODESCTN := 'Period11';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 12;
        GPSY40100.PERIODDT := CreateDateTime(20260501D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20260531D, 0T);
        GPSY40100.ODESCTN := 'Period12';
        GPSY40100.Insert(true);
    end;

    local procedure CreateNonTypicalPeriods(var GPSY40101: Record "GP SY40101"; var GPSY40100: Record "GP SY40100")
    var
        year: Integer;
    begin
        GPSY40101.Init();
        GPSY40101.YEAR1 := 2022;
        GPSY40101.NUMOFPER := 6;
        GPSY40101.FSTFSCDY := CreateDateTime(20210601D, 0T);
        GPSY40101.LSTFSCDY := CreateDateTime(20221231D, 0T);
        GPSY40101.HISTORYR := false;
        GPSY40101.Insert(true);

        GPSY40101.Init();
        GPSY40101.YEAR1 := 2023;
        GPSY40101.NUMOFPER := 6;
        GPSY40101.FSTFSCDY := CreateDateTime(20230101D, 0T);
        GPSY40101.LSTFSCDY := CreateDateTime(20230531D, 0T);
        GPSY40101.HISTORYR := false;
        GPSY40101.Insert(true);

        GPSY40101.Init();
        GPSY40101.YEAR1 := 2024;
        GPSY40101.NUMOFPER := 24;
        GPSY40101.FSTFSCDY := CreateDateTime(20230601D, 0T);
        GPSY40101.LSTFSCDY := CreateDateTime(20240531D, 0T);
        GPSY40101.HISTORYR := false;
        GPSY40101.Insert(true);

        GPSY40101.Init();
        GPSY40101.YEAR1 := 2025;
        GPSY40101.NUMOFPER := 4;
        GPSY40101.FSTFSCDY := CreateDateTime(20250601D, 0T);
        GPSY40101.LSTFSCDY := CreateDateTime(20251231D, 0T);
        GPSY40101.HISTORYR := false;
        GPSY40101.Insert(true);

        year := 2022;
        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 1;
        GPSY40100.PERIODDT := CreateDateTime(20210601D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20210904D, 0T);
        GPSY40100.ODESCTN := 'Period1';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 2;
        GPSY40100.PERIODDT := CreateDateTime(20210905D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20211209D, 0T);
        GPSY40100.ODESCTN := 'Period2';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 3;
        GPSY40100.PERIODDT := CreateDateTime(20211210D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20220315D, 0T);
        GPSY40100.ODESCTN := 'Period3';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 4;
        GPSY40100.PERIODDT := CreateDateTime(20220316D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20220619D, 0T);
        GPSY40100.ODESCTN := 'Period4';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 5;
        GPSY40100.PERIODDT := CreateDateTime(20220620D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20220923D, 0T);
        GPSY40100.ODESCTN := 'Period5';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 6;
        GPSY40100.PERIODDT := CreateDateTime(20220924D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20221231D, 0T);
        GPSY40100.ODESCTN := 'Period6';
        GPSY40100.Insert(true);

        year := 2023;
        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 1;
        GPSY40100.PERIODDT := CreateDateTime(20230101D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20230125D, 0T);
        GPSY40100.ODESCTN := 'Period1';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 2;
        GPSY40100.PERIODDT := CreateDateTime(20230126D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20230219D, 0T);
        GPSY40100.ODESCTN := 'Period2';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 3;
        GPSY40100.PERIODDT := CreateDateTime(20230220D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20230316D, 0T);
        GPSY40100.ODESCTN := 'Period3';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 4;
        GPSY40100.PERIODDT := CreateDateTime(20230317D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20230410D, 0T);
        GPSY40100.ODESCTN := 'Period4';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 5;
        GPSY40100.PERIODDT := CreateDateTime(20230411D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20230505D, 0T);
        GPSY40100.ODESCTN := 'Period5';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 6;
        GPSY40100.PERIODDT := CreateDateTime(20230506D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20230531D, 0T);
        GPSY40100.ODESCTN := 'Period6';
        GPSY40100.Insert(true);

        year := 2024;
        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 1;
        GPSY40100.PERIODDT := CreateDateTime(20230601D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20230615D, 0T);
        GPSY40100.ODESCTN := 'Period1';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 2;
        GPSY40100.PERIODDT := CreateDateTime(20230616D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20230630D, 0T);
        GPSY40100.ODESCTN := 'Period2';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 3;
        GPSY40100.PERIODDT := CreateDateTime(20230701D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20230715D, 0T);
        GPSY40100.ODESCTN := 'Period3';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 4;
        GPSY40100.PERIODDT := CreateDateTime(20230716D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20230730D, 0T);
        GPSY40100.ODESCTN := 'Period4';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 5;
        GPSY40100.PERIODDT := CreateDateTime(20230731D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20230814D, 0T);
        GPSY40100.ODESCTN := 'Period5';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 6;
        GPSY40100.PERIODDT := CreateDateTime(20230815D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20230829D, 0T);
        GPSY40100.ODESCTN := 'Period6';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 7;
        GPSY40100.PERIODDT := CreateDateTime(20230830D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20230913D, 0T);
        GPSY40100.ODESCTN := 'Period7';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 8;
        GPSY40100.PERIODDT := CreateDateTime(20230914D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20230928D, 0T);
        GPSY40100.ODESCTN := 'Period8';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 9;
        GPSY40100.PERIODDT := CreateDateTime(20230929D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20231013D, 0T);
        GPSY40100.ODESCTN := 'Period9';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 10;
        GPSY40100.PERIODDT := CreateDateTime(20231014D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20231028D, 0T);
        GPSY40100.ODESCTN := 'Period10';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 11;
        GPSY40100.PERIODDT := CreateDateTime(20231029D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20231112D, 0T);
        GPSY40100.ODESCTN := 'Period11';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 12;
        GPSY40100.PERIODDT := CreateDateTime(20231113D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20231127D, 0T);
        GPSY40100.ODESCTN := 'Period12';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 13;
        GPSY40100.PERIODDT := CreateDateTime(20231128D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20231212D, 0T);
        GPSY40100.ODESCTN := 'Period13';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 14;
        GPSY40100.PERIODDT := CreateDateTime(20231213D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20231227D, 0T);
        GPSY40100.ODESCTN := 'Period14';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 15;
        GPSY40100.PERIODDT := CreateDateTime(20231228D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20240111D, 0T);
        GPSY40100.ODESCTN := 'Period15';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 16;
        GPSY40100.PERIODDT := CreateDateTime(20240112D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20240126D, 0T);
        GPSY40100.ODESCTN := 'Period16';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 17;
        GPSY40100.PERIODDT := CreateDateTime(20240127D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20240210D, 0T);
        GPSY40100.ODESCTN := 'Period17';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 18;
        GPSY40100.PERIODDT := CreateDateTime(20240211D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20240225D, 0T);
        GPSY40100.ODESCTN := 'Period18';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 19;
        GPSY40100.PERIODDT := CreateDateTime(20240226D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20240312D, 0T);
        GPSY40100.ODESCTN := 'Period19';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 20;
        GPSY40100.PERIODDT := CreateDateTime(20240313D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20240327D, 0T);
        GPSY40100.ODESCTN := 'Period20';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 21;
        GPSY40100.PERIODDT := CreateDateTime(20240328D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20240411D, 0T);
        GPSY40100.ODESCTN := 'Period21';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 22;
        GPSY40100.PERIODDT := CreateDateTime(20240412D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20240426D, 0T);
        GPSY40100.ODESCTN := 'Period22';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 23;
        GPSY40100.PERIODDT := CreateDateTime(20240427D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20240511D, 0T);
        GPSY40100.ODESCTN := 'Period23';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 24;
        GPSY40100.PERIODDT := CreateDateTime(20240512D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20240531D, 0T);
        GPSY40100.ODESCTN := 'Period24';
        GPSY40100.Insert(true);

        year := 2025;
        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 1;
        GPSY40100.PERIODDT := CreateDateTime(20250601D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20250723D, 0T);
        GPSY40100.ODESCTN := 'Period1';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 2;
        GPSY40100.PERIODDT := CreateDateTime(20250724D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20250914D, 0T);
        GPSY40100.ODESCTN := 'Period2';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 3;
        GPSY40100.PERIODDT := CreateDateTime(20250915D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20251106D, 0T);
        GPSY40100.ODESCTN := 'Period3';
        GPSY40100.Insert(true);

        GPSY40100.Init();
        GPSY40100.FORIGIN := false;
        GPSY40100.YEAR1 := year;
        GPSY40100.SERIES := 2;
        GPSY40100.PERIODID := 4;
        GPSY40100.PERIODDT := CreateDateTime(20251107D, 0T);
        GPSY40100.PERDENDT := CreateDateTime(20251231D, 0T);
        GPSY40100.ODESCTN := 'Period4';
        GPSY40100.Insert(true);
    end;

    local procedure CreatePeriodSetupData(var GPSY40100: Record "GP SY40100")
    begin
        CreateSY40100Records(GPSY40100, 2020, 2, 12);
        CreateSY40100Records(GPSY40100, 2021, 2, 12);
        CreateSY40100Records(GPSY40100, 2022, 2, 12);
        CreateSY40100Records(GPSY40100, 2023, 2, 12);
        CreateSY40100Records(GPSY40100, 2024, 2, 12);
        CreateSY40100Records(GPSY40100, 2025, 2, 12);
        CreateSY40100Records(GPSY40100, 2026, 2, 12);
        CreateSY40100Records(GPSY40100, 2027, 2, 12);
        CreateSY40100Records(GPSY40100, 2028, 2, 12);
    end;

    local procedure CreateSY40100Records(var GPSY40100: Record "GP SY40100"; Year: Integer; Series: Integer; NumberOfPeriods: Integer)
    var
        i: Integer;
        myDay: Integer;
        LeapYear: Boolean;
    begin
        LeapYear := false;
        if IsLeapYear(Year) then
            LeapYear := true;

        for i := 1 to NumberOfPeriods do begin
            case i of
                2:
                    if LeapYear then
                        myDay := 29
                    else
                        myDay := 28;
                4, 6, 9, 11:
                    myDay := 30;
                else
                    myDay := 31;
            end;

            GPSY40100.Init();
            GPSY40100.FORIGIN := false;
            GPSY40100.YEAR1 := Year;
            GPSY40100.SERIES := Series;
            GPSY40100.PERIODID := i;
            GPSY40100.PERIODDT := CreateDateTime(DMY2Date(1, i, Year), 0T);
            GPSY40100.PERDENDT := CreateDateTime(DMY2Date(myDay, i, Year), 0T);
            GPSY40100.ODESCTN := 'Period' + Format(i);
            GPSY40100.Insert(true);
        end;
    end;

    [TryFunction]
    local procedure IsLeapYear(Year: Integer)
    var
        d: date;
    begin
        d := DMY2Date(29, 2, Year); // Error should be thrown here if it is not
        Clear(d);
    end;
}