// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 148005 "C5 Item Migrator Test"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        ItemDataMigrationFacade: Codeunit "Item Data Migration Facade";
        C5HelperFunctions: Codeunit "C5 Helper Functions";
        ItemNumTxt: Label 'MYC5ITEM', Locked = true;
        ComponentNumTxt: Label 'COMPONENT', Locked = true;
        ComponentDescriptionTxt: Label 'Component Descriptiuon', Locked = true;
        AltItemNumTxt: Label 'MYC5ITEM2', Locked = true;
        LotNumberTxt: Label 'B1', Locked = true;
        MyDepartmentTxt: Label 'SmartNAV', Locked = true;
        MyCenterTxt: Label 'C5 Migrate', Locked = true;
        MyPurposeTxt: Label 'AchieveMor', Locked = true;
        MyDepartment2Txt: Label 'UnSmartNAV', Locked = true;
        MyCenter2Txt: Label 'C6 Migrate', Locked = true;
        MyPurpose2Txt: Label 'AchieveLes', Locked = true;

    trigger OnRun();
    begin
        // [FEATURE] [C5 Data Migration]
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestC5ItemMigration()
    var
        C5InvenTable: Record "C5 InvenTable";
        InvenItemGroupCode: Text[10];
    begin
        // [SCENARIO] Import an item and check everything is set as expected
        Initialize();

        // [WITH] Data from C5 in the staging tables
        CreateC5UnitOfMeasure();
        CreateC5ItemDiscountGroup();
        CreateC5CustDiscountGroup();
        CreateC5InvenCustDisc();
        CreateNavVendor('45823445');
        CreateC5Tariff();
        CreateC5ProductPostingGroup();
        CreateC5VatProductPostingGroup();
        CreateC5Department();
        CreateC5Project();
        CreateC5Purpose();
        CreateC5InvenPrice();
        CreateC5InvenPriceGroup();
        InvenItemGroupCode := CreateC5InvenItemGroup();
        CreateC5InvenTrans('');

        CreateAltItem();
        CreateC5ItemEntry(C5InvenTable);
        C5InvenTable.Group := InvenItemGroupCode;
        C5InvenTable.Modify();
        CreateInvenBOM();

        // [WHEN] We trigger the item sync
        Migrate(C5InvenTable, true);

        // [THEN] The item is created as expected
        CheckMigrationItem('45823445', true);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestC5ItemMigrationWithLocation()
    var
        C5InvenTable: Record "C5 InvenTable";
        Item: Record Item;
        InvenItemGroupCode: Text[10];
    begin
        // [SCENARIO] Import an item and check everything is set as expected
        Initialize();

        // [WITH] Data from C5 in the staging tables
        CreateC5UnitOfMeasure();
        CreateC5ItemDiscountGroup();
        CreateC5CustDiscountGroup();
        CreateC5InvenCustDisc();
        CreateNavVendor('45823445');
        CreateC5Tariff();
        CreateC5ProductPostingGroup();
        CreateC5VatProductPostingGroup();
        CreateC5Department();
        CreateC5Project();
        CreateC5Purpose();
        CreateC5InvenPrice();
        CreateC5InvenPriceGroup();
        InvenItemGroupCode := CreateC5InvenItemGroup();
        CreateC5InvenLocation('HL', 'Hoved lager');
        CreateC5InvenLocation('LH', 'Hoved lager2');
        CreateC5InvenTrans('HL');
        CreateC5InvenTrans('LH');

        CreateAltItem();
        CreateC5ItemEntry(C5InvenTable);
        C5InvenTable.Group := InvenItemGroupCode;
        C5InvenTable.Modify();

        // [WHEN] We trigger the item sync
        Migrate(C5InvenTable, true);

        // [THEN] The item is created as expected
        CheckMigrationItem('45823445', false);
        Assert.IsTrue(Item.Get(ItemNumTxt), 'Expected to find an item with Code ' + ItemNumTxt);
        CheckLocationMigrationItem(Item, 'HL', 'Hoved lager');
        CheckLocationMigrationItem(Item, 'LH', 'Hoved lager2');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestC5ItemMigrationWithoutMigratingVendors()
    var
        C5InvenTable: Record "C5 InvenTable";
        InvenItemGroupCode: Text[10];
    begin
        // [SCENARIO] Import an item and check everything is set as expected
        Initialize();

        // [WITH] Data from C5 in the staging tables
        CreateC5UnitOfMeasure();
        CreateC5ItemDiscountGroup();
        CreateC5CustDiscountGroup();
        CreateC5InvenCustDisc();
        CreateC5Tariff();
        CreateC5ProductPostingGroup();
        CreateC5VatProductPostingGroup();
        CreateC5Department();
        CreateC5Project();
        CreateC5Purpose();
        CreateC5InvenPrice();
        CreateC5InvenPriceGroup();
        InvenItemGroupCode := CreateC5InvenItemGroup();
        CreateC5InvenTrans('');

        CreateAltItem();
        CreateC5ItemEntry(C5InvenTable);
        C5InvenTable.Group := InvenItemGroupCode;
        C5InvenTable.Modify();

        // [WHEN] We trigger the item sync
        Migrate(C5InvenTable, true);

        // [THEN] The item is created as expected
        CheckMigrationItem('', false);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestC5MinimalItemMigration()
    var
        C5InvenTable: Record "C5 InvenTable";
    begin
        // [SCENARIO] Import an item and check everything is set as expected
        Initialize();

        // [WITH] Data from C5 in the staging tables
        CreateC5MinimalItemEntry(C5InvenTable);
        CreateC5InvenTrans('');

        // [WHEN] We trigger the item sync without migrating GL Accounts
        Migrate(C5InvenTable, false);

        // [THEN] The item is created as expected and tyhe transactions are not migrated
        CheckMinimalMigrationItem();
    end;

    local procedure Migrate(C5InvenTable: Record "C5 InvenTable"; MigrateTransactions: Boolean)
    var
        C5ItemMigrator: Codeunit "C5 Item Migrator";
    begin
        C5ItemMigrator.MigrateItem(ItemDataMigrationFacade, C5InvenTable.RecordId());

        C5ItemMigrator.MigrateItemTrackingCode(ItemDataMigrationFacade, C5InvenTable.RecordId());
        C5ItemMigrator.MigrateCostingMethod(ItemDataMigrationFacade, C5InvenTable.RecordId());
        C5ItemMigrator.MigrateItemUnitOfMeasure(ItemDataMigrationFacade, C5InvenTable.RecordId());
        C5ItemMigrator.MigrateItemDiscountGroup(ItemDataMigrationFacade, C5InvenTable.RecordId());
        C5ItemMigrator.MigrateItemSalesLineDiscount(ItemDataMigrationFacade, C5InvenTable.RecordId());
        C5ItemMigrator.MigrateItemPrices(ItemDataMigrationFacade, C5InvenTable.RecordId());
        C5ItemMigrator.MigrateItemTariffNo(ItemDataMigrationFacade, C5InvenTable.RecordId());
        C5ItemMigrator.MigrateItemDimensions(ItemDataMigrationFacade, C5InvenTable.RecordId());
        C5ItemMigrator.MigrateItemPostingGroups(ItemDataMigrationFacade, C5InvenTable.RecordId(), MigrateTransactions);
        C5ItemMigrator.MigrateInventoryTransactions(ItemDataMigrationFacade, C5InvenTable.RecordId(), MigrateTransactions);
    end;

    local procedure CleanupStagingTables()
    var
        C5InvenCustDisc: Record "C5 InvenCustDisc";
        C5InvenPrice: Record "C5 InvenPrice";
        C5InvenPriceGroup: Record "C5 InvenPriceGroup";
        C5InvenTable: Record "C5 InvenTable";
        C5CustDiscGroup: Record "C5 CustDiscGroup";
        C5Centre: Record "C5 Centre";
        C5Department: Record "C5 Department";
        C5CN8Code: Record "C5 CN8Code";
        C5InvenItemGroup: Record "C5 InvenItemGroup";
        C5VatGroup: Record "C5 VatGroup";
        C5Purpose: Record "C5 Purpose";
        C5UnitCode: Record "C5 UnitCode";
        C5InvenDiscGroup: Record "C5 InvenDiscGroup";
        C5InvenTrans: Record "C5 InvenTrans";
        C5InvenLocation: Record "C5 InvenLocation";
    begin
        C5InvenTable.DeleteAll();
        C5UnitCode.DeleteAll();
        C5InvenDiscGroup.DeleteAll();
        C5CN8Code.DeleteAll();
        C5InvenItemGroup.DeleteAll();
        C5VatGroup.DeleteAll();
        C5Centre.DeleteAll();
        C5Department.DeleteAll();
        C5Purpose.DeleteAll();
        C5CustDiscGroup.DeleteAll();
        C5InvenCustDisc.DeleteAll();
        C5InvenPrice.DeleteAll();
        C5InvenPriceGroup.DeleteAll();
        C5InvenLocation.DeleteAll();
        C5InvenTrans.DeleteAll();
    end;

    local procedure Initialize()
    var
        Item: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        ItemDiscountGroup: Record "Item Discount Group";
        Vendor: Record Vendor;
        TariffNumber: Record "Tariff Number";
        ItemTrackingCode: Record "Item Tracking Code";
        DefaultDimension: Record "Default Dimension";
        DimensionValue: Record "Dimension Value";
        CustomerDiscountGroup: Record "Customer Discount Group";
#if not CLEAN25
        SalesLineDiscount: Record "Sales Line Discount";
        SalesPrice: Record "Sales Price";
#else
        PriceListLine: Record "Price List Line";
#endif
        CustomerPriceGroup: Record "Customer Price Group";
        GenJournalLine: Record "Gen. Journal Line";
        C5InvenBom: Record "C5 InvenBOM";
        Currency: Record Currency;
    begin
        CleanupStagingTables();

        Item.DeleteAll();
        UnitOfMeasure.DeleteAll();
        ItemDiscountGroup.DeleteAll();
        CustomerDiscountGroup.DeleteAll();
        Vendor.DeleteAll();
        TariffNumber.DeleteAll();
#if not CLEAN25
        SalesLineDiscount.DeleteAll();
#endif
        ItemTrackingCode.DeleteAll();
        DefaultDimension.DeleteAll();
        DimensionValue.DeleteAll();
#if not CLEAN25
        SalesPrice.DeleteAll();
#else
        PriceListLine.DeleteAll();
#endif
        CustomerPriceGroup.DeleteAll();
        GenJournalLine.DeleteAll();
        C5InvenBom.DeleteAll();
        Currency.DeleteAll();

        Currency.Init();
        Currency.Code := 'EUR';
        Currency.Description := 'EURO';
        Currency.Insert();
    end;

    local procedure CreateC5Purpose()
    var
        C5Purpose: Record "C5 Purpose";
    begin
        C5Purpose.Init();
        C5Purpose.Purpose := CopyStr(MyPurposeTxt, 1, 10);
        C5Purpose.Name := 'Achieve more!';
        C5Purpose.Insert();
    end;

    local procedure CreateC5Project()
    var
        C5Centre: Record "C5 Centre";
    begin
        C5Centre.Init();
        C5Centre.Centre := CopyStr(MyCenterTxt, 1, 10);
        C5Centre.Name := 'Migrating C5 Data Project';
        C5Centre.Insert();
    end;

    local procedure CreateC5Department()
    var
        C5Department: Record "C5 Department";
    begin
        C5Department.Init();
        C5Department.Department := CopyStr(MyDepartmentTxt, 1, 10);
        C5Department.Name := 'Data migration team';
        C5Department.Insert();
    end;

    local procedure CreateC5VatProductPostingGroup()
    var
        C5VatGroup: Record "C5 VatGroup";
    begin
        C5VatGroup.Init();
        C5VatGroup.Group := 'High++';
        C5VatGroup.Description := 'High VAT for Skat';
        C5VatGroup.Insert();
    end;

    local procedure CreateC5ProductPostingGroup()
    var
        C5InvenItemGroup: Record "C5 InvenItemGroup";
    begin
        C5InvenItemGroup.Init();
        C5InvenItemGroup.Group := 'Borde';
        C5InvenItemGroup.GroupName := 'Golden oak tables';
        C5InvenItemGroup.Insert();
    end;

    local procedure CreateC5Tariff()
    var
        C5CN8Code: Record "C5 CN8Code";
    begin
        C5CN8Code.Init();
        C5CN8Code.CN8Code := '94033011';
        C5CN8Code.Txt := 'Very good Tariff';
        C5CN8Code.SupplementaryUnits := 'More units!';
        C5CN8Code.Insert();
    end;

    local procedure CreateNavVendor(VendorNo: Code[20])
    var
        Vendor: Record Vendor;
        LibraryPurchase: Codeunit "Library - Purchase";
    begin
        LibraryPurchase.CreateVendor(Vendor);

        Vendor.Rename(VendorNo);
    end;

    local procedure CreateC5UnitOfMeasure()
    var
        C5UnitCode: Record "C5 UnitCode";
    begin
        C5UnitCode.Init();
        C5UnitCode.UnitCode := 'Stk';
        C5UnitCode.Txt := 'Piece';
        C5UnitCode.Insert();
    end;

    local procedure CreateC5ItemDiscountGroup()
    var
        C5InvenDiscGroup: Record "C5 InvenDiscGroup";
    begin
        C5InvenDiscGroup.Init();
        C5InvenDiscGroup.DiscGroup := 'SuperI';
        C5InvenDiscGroup.Comment := 'Super amazing discount items';
        C5InvenDiscGroup.Insert();
    end;

    local procedure CreateC5CustDiscountGroup()
    var
        C5CustDiscGroup: Record "C5 CustDiscGroup";
    begin
        C5CustDiscGroup.Init();
        C5CustDiscGroup.DiscGroup := 'SuperC';
        C5CustDiscGroup.Comment := 'Super amazing discount cust';
        C5CustDiscGroup.Insert();
    end;

    local procedure CreateC5InvenCustDisc()
    var
        C5InvenCustDisc: Record "C5 InvenCustDisc";
    begin
        C5InvenCustDisc.Init();
        C5InvenCustDisc.ItemCode := C5InvenCustDisc.ItemCode::Specific;
        C5InvenCustDisc.AccountCode := C5InvenCustDisc.AccountCode::Group;
        C5InvenCustDisc.ItemRelation := CopyStr(ItemNumTxt, 1, 20);
        C5InvenCustDisc.AccountRelation := 'SuperC';
        C5InvenCustDisc.Type := C5InvenCustDisc.Type::Percent;
        C5InvenCustDisc.Rate_ := 12.1;
        C5InvenCustDisc.Insert();
    end;

    local procedure CreateC5InvenPrice()
    var
        C5InvenPrice: Record "C5 InvenPrice";
    begin
        C5InvenPrice.Init();
        C5InvenPrice.ItemNumber := CopyStr(ItemNumTxt, 1, 20);
        C5InvenPrice.Price := 1600.80;
        C5InvenPrice.Currency := 'EUR';
        C5InvenPrice.PriceGroup := 'Premium';
        C5InvenPrice.Insert();
    end;

    local procedure CreateC5InvenPriceGroup()
    var
        C5InvenPriceGroup: Record "C5 InvenPriceGroup";
    begin
        C5InvenPriceGroup.Init();
        C5InvenPriceGroup.Group := 'Premium';
        C5InvenPriceGroup.GroupName := 'For premium customers';
        C5InvenPriceGroup.InclVat := C5InvenPriceGroup.InclVat::Yes;
        C5InvenPriceGroup.Insert();
    end;

    local procedure CreateC5InvenItemGroup(): Text[10]
    var
        C5InvenItemGroup: Record "C5 InvenItemGroup";
        C5LedTable: Record "C5 LedTable";
    begin
        C5InvenItemGroup.Init();
        C5InvenItemGroup.RecId := 987654;
        C5InvenItemGroup.Group := 'ItemGrp';
        C5InvenItemGroup.GroupName := 'Full group name';

        C5LedTable.DeleteAll();
        C5InvenItemGroup.InventoryInflowAcc := '82020';
        C5LedTable.RecId := C5InvenItemGroup.RecId;
        C5LedTable.Account := C5InvenItemGroup.InventoryInflowAcc;
        C5LedTable.Insert();
        C5HelperFunctions.CreateGLAccount(C5InvenItemGroup.InventoryInflowAcc);

        C5InvenItemGroup.InventoryOutflowAcc := '82021';
        C5LedTable.RecId := C5InvenItemGroup.RecId + 1;
        C5LedTable.Account := C5InvenItemGroup.InventoryOutflowAcc;
        C5LedTable.Insert();
        C5HelperFunctions.CreateGLAccount(C5InvenItemGroup.InventoryOutflowAcc);
        C5InvenItemGroup.Insert();
        exit(C5InvenItemGroup.Group);
    end;

    local procedure CreateC5InvenLocation(LocationCode: Text; LocationName: Text)
    var
        C5InvenLocation: Record "C5 InvenLocation";
    begin
        C5InvenLocation.Init();
        IF C5InvenLocation.FindLast() THEN
            C5InvenLocation.RecId := C5InvenLocation.RecId + 1;
        C5InvenLocation.InvenLocation := CopyStr(LocationCode, 1, 10);
        C5InvenLocation.Name := CopyStr(LocationName, 1, 30);
        C5InvenLocation.Insert();
    end;

    local procedure CreateC5InvenTrans(LocationCode: Text)
    var
        C5InvenTrans: Record "C5 InvenTrans";
    begin
        C5InvenTrans.Init();
        IF C5InvenTrans.FindLast() THEN
            C5InvenTrans.RecId := C5InvenTrans.RecId + 1;
        C5InvenTrans.ItemNumber := CopyStr(ItemNumTxt, 1, 20);
        C5InvenTrans.Open := C5InvenTrans.Open::Yes;
        C5InvenTrans.BudgetCode := C5InvenTrans.BudgetCode::Actual;
        C5InvenTrans.Qty := 100;
        C5InvenTrans.SettledQty := 32;
        C5InvenTrans.Voucher := 352533;
        C5InvenTrans.InvoiceNumber := 'MyInvoice';
        C5InvenTrans.Txt := 'Some text';
        C5InvenTrans.Date_ := DMY2Date(10, 4, 2014);
        C5InvenTrans.CostAmount := 1000;
        C5InvenTrans.SettledAmount := 320;
        C5InvenTrans.SerialNumber := CopyStr(LotNumberTxt, 1, 10);
        C5InvenTrans.InvenLocation := CopyStr(LocationCode, 1, 10);
        C5InvenTrans.Department := CopyStr(MyDepartment2Txt, 1, 10);
        C5InvenTrans.Centre := CopyStr(MyCenter2Txt, 1, 10);
        C5InvenTrans.Purpose := CopyStr(MyPurpose2Txt, 1, 10);
        C5InvenTrans.Insert();
    end;

    local procedure CheckMigrationItem(VendorNo: Text; CheckBOM: Boolean)
    var
        Item: Record Item;
        TariffNumber: Record "Tariff Number";
        UnitOfMeasure: Record "Unit of Measure";
        ItemDiscountGroup: Record "Item Discount Group";
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
        ItemTrackingCode: Record "Item Tracking Code";
        DefaultDimension: Record "Default Dimension";
        CustomerDiscountGroup: Record "Customer Discount Group";
#if not CLEAN25
        SalesLineDiscount: Record "Sales Line Discount";
        SalesPrice: Record "Sales Price";
#else
        PriceListLine: Record "Price List Line";
#endif
        CustomerPriceGroup: Record "Customer Price Group";
        GenProductPostingSetup: Record "General Posting Setup";
        InventoryPostingSetup: Record "Inventory Posting Setup";
        ItemJournalLine: Record "Item Journal Line";
        ReservationEntry: Record "Reservation Entry";
        DimensionSetEntry: Record "Dimension Set Entry";
        BOMComponent: Record "BOM Component";
    begin
        Assert.IsTrue(Item.Get(ItemNumTxt), 'Expected to find an item with Code ' + ItemNumTxt);
        Assert.AreEqual(ItemNumTxt, Item."No.", 'No incorrect');
        Assert.AreEqual('Skrivebord', Item.Description, 'Description incorrect');
        Assert.AreEqual('med indstillelig bordplade', Item."Description 2", 'Description 2 incorrect');

        Assert.AreEqual('STK', Item."Base Unit of Measure", 'Base Unit of Measure incorrect');
        // check unit of measure
        UnitOfMeasure.Get('STK');
        Assert.AreEqual('Piece', UnitOfMeasure.Description, 'UnitOfMeasure.Description incorrect');

        Assert.AreEqual(Item.Type::Inventory, Item.Type, 'Type incorrect');

        Assert.AreEqual('SUPERI', Item."Item Disc. Group", 'Item Disc. Group incorrect');
        // check item discount group
        ItemDiscountGroup.Get('SUPERI');
        Assert.AreEqual('Super amazing discount items', ItemDiscountGroup.Description, 'ItemDiscountGroup.Description');

        //  check customer discount group
        CustomerDiscountGroup.Get('SUPERC');
        Assert.AreEqual('Super amazing discount cust', CustomerDiscountGroup.Description, 'CustomerDiscountGroup.Description');

        // check inven cust disc
#if not CLEAN25
        SalesLineDiscount.SetRange(Type, SalesLineDiscount.Type::Item);
        SalesLineDiscount.SetRange(Code, ItemNumTxt);
        SalesLineDiscount.SetRange("Sales Type", SalesLineDiscount."Sales Type"::"Customer Disc. Group");
        SalesLineDiscount.SetRange("Sales Code", 'SuperC');
        SalesLineDiscount.SetRange("Line Discount %", 12.1);
        Assert.IsFalse(SalesLineDiscount.IsEmpty(), 'The discount was not created.');
#else
        PriceListLine.SetRange("Asset Type", "Price Asset Type"::Item);
        PriceListLine.SetRange("Asset No.", ItemNumTxt);
        PriceListLine.SetRange("Source Type", "Price Source Type"::"Customer Disc. Group");
        PriceListLine.SetRange("Source No.", 'SuperC');
        PriceListLine.SetRange("Line Discount %", 12.1);
        Assert.IsFalse(PriceListLine.IsEmpty(), 'The discount was not created.');
#endif

        Assert.AreEqual(Item."Costing Method"::FIFO, Item."Costing Method", 'Costing Method incorrect');
        Assert.AreEqual(111.11, Item."Unit Cost", 'Unit Cost incorrect');
        Assert.AreEqual(111.11, Item."Standard Cost", 'Standard Cost incorrect');
        Assert.AreEqual(VendorNo, Item."Vendor No.", 'Vendor No. incorrect');
        Assert.AreEqual('Vendor ItemNo 42', Item."Vendor Item No.", 'Vendor Item No. incorrect');
        Assert.AreEqual(4214, Item."Reorder Quantity", 'Reorder Quantity incorrect');
        Assert.AreEqual(AltItemNumTxt, Item."Alternative Item No.", 'Alternative Item No. incorrect');
        Assert.AreEqual(81.5, Item."Net Weight", 'Net Weight incorrect');
        Assert.AreEqual(14.4, Item."Unit Volume", 'Unit Volume incorrect');

        Assert.AreEqual('94033011', Item."Tariff No.", 'Tariff No. incorrect');
        //check tariff
        TariffNumber.Get('94033011');
        Assert.AreEqual('Very good Tariff', TariffNumber.Description, 'TariffNumber.Description incorrect');
        Assert.IsTrue(TariffNumber."Supplementary Units", 'TariffNumber."Supplementary Units" incorrect');

        Assert.IsFalse(Item.Blocked, 'Blocked incorrect');

        // check deparment
        Dimension.Get('C5DEPARTMENT');
        DimensionValue.Get('C5DEPARTMENT', MyDepartmentTxt);
        Assert.AreEqual('Data migration team', DimensionValue.Name, 'DimensionValue.Name incorrect');
        DefaultDimension.Get(Database::Item, ItemNumTxt, 'C5DEPARTMENT');

        // check cost center
        Dimension.Get('C5COSTCENTRE');
        DimensionValue.Get('C5COSTCENTRE', MyCenterTxt);
        Assert.AreEqual('Migrating C5 Data Project', DimensionValue.Name, 'DimensionValue.Name incorrect');
        DefaultDimension.Get(Database::Item, ItemNumTxt, 'C5COSTCENTRE');

        // check purpose
        Dimension.Get('C5PURPOSE');
        DimensionValue.Get('C5PURPOSE', MyPurposeTxt);
        Assert.AreEqual('Achieve more!', DimensionValue.Name, 'DimensionValue.Name incorrect');
        DefaultDimension.Get(Database::Item, ItemNumTxt, 'C5PURPOSE');

        Assert.AreEqual(Item."Stockout Warning"::Yes, Item."Stockout Warning", 'Stockout Warning incorrect');
        Assert.IsTrue(Item.PreventNegativeInventory(), 'PreventNegativeInventory incorrect');

        // check price is created
#if not CLEAN25
        SalesPrice.SetRange("Sales Code", 'PREMIUM');
        SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::"Customer Price Group");
        SalesPrice.SetRange("Item No.", ItemNumTxt);
        SalesPrice.SetRange("Unit Price", 1600.80);
        SalesPrice.SetRange("Currency Code", 'EUR');
        Assert.IsFalse(SalesPrice.IsEmpty(), 'The price was not created.');
#else
        PriceListLine.SetRange("Source No.", 'PREMIUM');
        PriceListLine.SetRange("Source Type", "Price Source Type"::"Customer Price Group");
        PriceListLine.SetRange("Asset Type", "Price Asset Type"::Item);
        PriceListLine.SetRange("Asset No.", ItemNumTxt);
        PriceListLine.SetRange("Unit Price", 1600.80);
        PriceListLine.SetRange("Currency Code", 'EUR');
        Assert.IsFalse(PriceListLine.IsEmpty(), 'The discount was not created.');
#endif

        // check customer price group is created
        CustomerPriceGroup.Get('Premium');

        Assert.AreEqual('BATCH', Item."Item Tracking Code", 'Item."Item Tracking Code" incorrect');
        // check tracking code
        ItemTrackingCode.Get('BATCH');
        Assert.IsTrue(ItemTrackingCode."Lot Purchase Inbound Tracking", '"Lot Purchase Inbound Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Sales Inbound Tracking", '"Lot Sales Inbound Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Pos. Adjmt. Inb. Tracking", '"Lot Pos. Adjmt. Inb. Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Neg. Adjmt. Inb. Tracking", '"Lot Neg. Adjmt. Inb. Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Assembly Inbound Tracking", '"Lot Assembly Inbound Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Manuf. Inbound Tracking", '"Lot Manuf. Inbound Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Transfer Tracking", '"Lot Transfer Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Purchase Outbound Tracking", '"Lot Purchase Outbound Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Sales Outbound Tracking", '"Lot Sales Outbound Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Pos. Adjmt. Outb. Tracking", '"Lot Pos. Adjmt. Outb. Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Neg. Adjmt. Outb. Tracking", '"Lot Neg. Adjmt. Outb. Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Assembly Outbound Tracking", '"Lot Assembly Outbound Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Manuf. Outbound Tracking", '"Lot Manuf. Outbound Tracking" incorrect');

        // check posting groups
        Assert.AreEqual('ITEMGRP', Item."Gen. Prod. Posting Group", 'Gen. Prod. Posting group migrated from InvenItemGroup');
        GenProductPostingSetup.Get('', Item."Gen. Prod. Posting Group");
        Assert.AreEqual('82021', GenProductPostingSetup."Inventory Adjmt. Account", 'incorrect adjustment acc');
        Assert.AreEqual('ITEMGRP', Item."Inventory Posting Group", 'Inventory Posting group migrated from InvenItemGroup');
        InventoryPostingSetup.Get('', Item."Inventory Posting Group");
        Assert.AreEqual('82020', InventoryPostingSetup."Inventory Account", 'incorrect inventory acc');

        // check migration generated posting group created
        GenProductPostingSetup.Get('', 'MIGRATION' + Item."Gen. Prod. Posting Group");
        Assert.AreEqual(InventoryPostingSetup."Inventory Account", GenProductPostingSetup."Inventory Adjmt. Account", 'incorrect inventory Adjmt. acc');

        // check item journal line
        ItemJournalLine.SetRange("Item No.", Item."No.");
        ItemJournalLine.FindFirst();
        Assert.AreEqual(Item."No.", ItemJournalLine."Item No.", 'Bad item in item journal');
        Assert.AreEqual('ITEMMIGR', ItemJournalLine."Journal Batch Name", 'Hard coded batch name incorrect');
        Assert.AreEqual(100 - 32, ItemJournalLine.Quantity, 'Incorrect quantity');
        Assert.AreEqual(1000 - 320, ItemJournalLine.Amount, 'Incorrect amount');
        Assert.AreEqual(DMY2Date(10, 4, 2014), ItemJournalLine."Document Date", 'incorrect doc date');
        Assert.AreEqual(Format(352533), ItemJournalLine."Document No.", 'Incorrect document number');
        Assert.AreEqual(DMY2Date(10, 4, 2014), ItemJournalLine."Posting Date", 'incorrect posting date');
        Assert.AreEqual(StrSubstNo('%1 %2', 'MyInvoice', 'Some text'), ItemJournalLine.Description, 'incorrect description');
        Assert.AreEqual('MIGRATION' + Item."Gen. Prod. Posting Group", ItemJournalLine."Gen. Prod. Posting Group", 'incorrect Gen Prod Posting Group');
        Assert.AreEqual('', ItemJournalLine."Gen. Bus. Posting Group", 'incorrect Gen Bus. Posting Group');

        // check dimensions are migrated to the item journal line
        DimensionSetEntry.SetRange("Dimension Set ID", ItemJournalLine."Dimension Set ID");
        DimensionSetEntry.SetRange("Dimension Code", 'C5DEPARTMENT');
        DimensionSetEntry.FindFirst();
        Assert.AreEqual(Uppercase(MyDepartment2Txt), DimensionSetEntry."Dimension Value Code", 'Incorrect department code');
        DimensionSetEntry.SetRange("Dimension Code", 'C5COSTCENTRE');
        DimensionSetEntry.FindFirst();
        Assert.AreEqual(Uppercase(MyCenter2Txt), DimensionSetEntry."Dimension Value Code", 'Incorrect cost center code');
        DimensionSetEntry.SetRange("Dimension Code", 'C5PURPOSE');
        DimensionSetEntry.FindFirst();
        Assert.AreEqual(Uppercase(MyPurpose2Txt), DimensionSetEntry."Dimension Value Code", 'Incorrect purpose code');

        // check item tracking has come in
        ReservationEntry.SetRange("Source Type", Database::"Item Journal Line");
        ReservationEntry.SetRange("Source ID", ItemJournalLine."Journal Template Name");
        ReservationEntry.SetRange("Source Batch Name", ItemJournalLine."Journal Batch Name");
        ReservationEntry.SetRange("Source Ref. No.", ItemJournalLine."Line No.");
        ReservationEntry.FindFirst();
        Assert.AreEqual(Item."No.", Format(ReservationEntry."Item No."), 'Bad item in item tracking');
        Assert.AreEqual(LotNumberTxt, Format(ReservationEntry."Lot No."), 'Bad batch number');
        Assert.AreEqual(ReservationEntry."Reservation Status"::Prospect, ReservationEntry."Reservation Status", 'Needs to be prospect');
        if CheckBOM then begin
            BOMComponent.SetRange("Parent Item No.", CopyStr(ItemNumTxt, 1, 20));
            Assert.RecordCount(BOMComponent, 1);
            BOMComponent.FindFirst();
            Assert.AreEqual(ComponentNumTxt, BOMComponent."No.", 'A different BOM Component No was expected.');
            Assert.AreEqual(BOMComponent.Type::Item, BOMComponent.Type, 'A different BOM Component Type was expected.');
        end;
    end;

    local procedure CheckMinimalMigrationItem()
    var
        Item: Record Item;
        GenJournalLine: Record "Gen. Journal Line";
    begin
        Assert.IsTrue(Item.Get(ItemNumTxt), 'Expected to find an item with Code ' + ItemNumTxt);
        Assert.AreEqual(ItemNumTxt, Item."No.", 'No incorrect');
        Assert.AreEqual('Skrivebord', Item.Description, 'Description incorrect');
        Assert.AreEqual(999.99, Item."Unit Cost", 'Unit Cost incorrect');
        Assert.AreEqual(999.99, Item."Standard Cost", 'Standard Cost incorrect');
        Assert.RecordIsEmpty(GenJournalLine);
    end;

    local procedure CheckLocationMigrationItem(Item: Record Item; LocationCode: Text; LocationName: Text)
    var
        Location: Record Location;
        ItemJournalLine: Record "Item Journal Line";
        ReservationEntry: Record "Reservation Entry";
        InventoryPostingSetup: Record "Inventory Posting Setup";
    begin
        ItemJournalLine.SetRange("Item No.", ItemNumTxt);
        ItemJournalLine.SetRange("Location Code", LocationCode);
        ItemJournalLine.FindFirst();

        InventoryPostingSetup.Get(LocationCode, Item."Inventory Posting Group");
        Assert.AreEqual('82020', InventoryPostingSetup."Inventory Account", 'incorrect inventory acc');
        ReservationEntry.SetRange("Source Type", Database::"Item Journal Line");
        ReservationEntry.SetRange("Source ID", ItemJournalLine."Journal Template Name");
        ReservationEntry.SetRange("Source Batch Name", ItemJournalLine."Journal Batch Name");
        ReservationEntry.SetRange("Source Ref. No.", ItemJournalLine."Line No.");
        ReservationEntry.FindFirst();
        Assert.AreEqual(ReservationEntry."Reservation Status"::Prospect, ReservationEntry."Reservation Status", 'Needs to be prospect');
        Assert.AreEqual(ReservationEntry."Location Code", LocationCode, 'Hard coded location incorrect');
        Location.SetRange(Code, ItemJournalLine."Location Code");
        Location.FindFirst();
        Assert.AreEqual(Location.Name, LocationName, 'Hard coded location incorrect');
    end;

    local procedure CreateC5ItemEntry(var C5InvenTable: Record "C5 InvenTable")
    begin
        C5InvenTable.Init();
        C5InvenTable.RecId := 3879936;
        C5InvenTable.DEL_UserLock := 0;
        C5InvenTable.ItemNumber := CopyStr(ItemNumTxt, 1, 20);
        C5InvenTable.ItemName1 := 'Skrivebord';
        C5InvenTable.ItemName2 := 'med indstillelig bordplade';
        C5InvenTable.ItemName3 := '';
        C5InvenTable.ItemType := C5InvenTable.ItemType::BOM;
        C5InvenTable.DiscGroup := 'SuperI';
        C5InvenTable.CostCurrency := 'DKK';
        C5InvenTable.CostPrice := 999.99;
        C5InvenTable.CostPriceUnit := 9;
        C5InvenTable.Group := 'Borde';
        C5InvenTable.VatGroup := 'High++';
        C5InvenTable.SalesModel := C5InvenTable.SalesModel::Adjust;
        C5InvenTable.CostingMethod := C5InvenTable.CostingMethod::FIFO;
        C5InvenTable.PurchSeriesSize := 4214;
        C5InvenTable.PrimaryVendor := '45823445';
        C5InvenTable.VendItemNumber := 'Vendor ItemNo 42';
        C5InvenTable.Blocked := C5InvenTable.Blocked::No;
        C5InvenTable.Alternative := C5InvenTable.Alternative::Always;
        C5InvenTable.AltItemNumber := CopyStr(AltItemNumTxt, 1, 20);
        C5InvenTable.Decimals_ := 0;
        C5InvenTable.Commission := C5InvenTable.Commission::Yes;
        C5InvenTable.NetWeight := 81.5;
        C5InvenTable.Volume := 14.4;
        C5InvenTable.TariffNumber := '94033011';
        C5InvenTable.UnitCode := 'Stk';
        C5InvenTable.OneTimeItem := C5InvenTable.OneTimeItem::No;
        C5InvenTable.CostType := 'Materialer';
        C5InvenTable.ExtraCost := 0;
        C5InvenTable.PurchCostModel := C5InvenTable.PurchCostModel::Average;
        C5InvenTable.InvenLocation := C5InvenTable.InvenLocation::No;
        C5InvenTable.Inventory := 6;
        C5InvenTable.Delivered := 0;
        C5InvenTable.Reserved := 0;
        C5InvenTable.Received := 0;
        C5InvenTable.Ordered := 0;
        C5InvenTable.InventoryValue := 2950;
        C5InvenTable.DeliveredValue := 0;
        C5InvenTable.ReceivedValue := 0;

        C5InvenTable.Level := 0;
        C5InvenTable.Department := CopyStr(MyDepartmentTxt, 1, 10);
        C5InvenTable.Centre := CopyStr(MyCenterTxt, 1, 10);
        C5InvenTable.Purpose := CopyStr(MyPurposeTxt, 1, 10);
        C5InvenTable.Pulled := 0;
        C5InvenTable.WarnNegativeInventory := C5InvenTable.WarnNegativeInventory::Yes;
        C5InvenTable.NegativeInventory := C5InvenTable.NegativeInventory::Yes;
        C5InvenTable.IgnoreListCode := C5InvenTable.IgnoreListCode::No;
        C5InvenTable.ItemTracking := C5InvenTable.ItemTracking::Batch;
        C5InvenTable.ItemTrackGroup := 'Satellite';
        C5InvenTable.ProjCostFactor := 0;
        C5InvenTable.SupplFactor := 0;
        C5InvenTable.MarkedPhysical := 0;
        C5InvenTable.LastMovementDate := DMY2Date(16, 05, 2017);
        C5InvenTable.StdItemNumber := C5InvenTable.StdItemNumber::No;
        C5InvenTable.Insert();
    end;

    local procedure CreateAltItem()
    var
        Item: Record Item;
    begin
        Item.Init();
        Item."No." := CopyStr(AltItemNumTxt, 1, 20);
        Item.Insert();
    end;

    local procedure CreateInvenBOM()
    var
        C5InvenBOM: Record "C5 InvenBOM";
        C5InvenTable: Record "C5 InvenTable";
        Item: Record Item;
    begin
        Item.Init();
        Item."No." := CopyStr(ComponentNumTxt, 1, 20);
        Item.Type := Item.Type::Inventory;
        Item.Description := CopyStr(ComponentDescriptionTxt, 1, 50);
        Item.Insert();

        C5InvenTable.Init();
        C5InvenTable.RecId := 123;
        C5InvenTable.ItemNumber := CopyStr(ComponentNumTxt, 1, 20);
        C5InvenTable.Itemtype := C5InvenTable.Itemtype::Item;
        C5InvenTable.Insert();

        C5InvenBOM.Init();
        C5InvenBOM.BOMItemNumber := CopyStr(ItemNumTxt, 1, 20);
        C5InvenBOM.Qty := 3;
        C5InvenBOM.ItemNumber := CopyStr(ComponentNumTxt, 1, 20);
        C5InvenBOM.Insert();
    end;

    local procedure CreateC5MinimalItemEntry(var C5InvenTable: Record "C5 InvenTable")
    begin
        C5InvenTable.Init();
        C5InvenTable.RecId := 3879936;
        C5InvenTable.ItemNumber := CopyStr(ItemNumTxt, 1, 20);
        C5InvenTable.UnitCode := 'STK';
        C5InvenTable.ItemName1 := 'Skrivebord';
        C5InvenTable.CostPrice := 999.99;
        C5InvenTable.Insert();
    end;
}
