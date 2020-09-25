// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 1870 "C5 Migr. Dashboard Mgt"
{
    var
        C5MigrationTypeTxt: Label 'C5 2012', Locked = true;
        C5HelptTopicUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=859310', Locked = true;

    procedure InitMigrationStatus(TotalItemNb: Integer; TotalCustomerNb: Integer; TotalVendorNb: Integer; TotalChartOfAccountNb: Integer; TotalLegacyNb: Integer)
    var
        C5SchemaParameters: Record "C5 Schema Parameters";
        DataMigrationStatus: Record "Data Migration Status";
        C5DataLoaderStatus: Record "C5 Data Loader Status";
        DataMigrationStatusFacade: Codeunit "Data Migration Status Facade";
        TotalRecords: Integer;
    begin
        DataMigrationStatusFacade.InitStatusLine(GetC5MigrationTypeTxt(), Database::Item, TotalItemNb, Database::"C5 InvenTable", Codeunit::"C5 Item Migrator");
        DataMigrationStatusFacade.InitStatusLine(GetC5MigrationTypeTxt(), Database::Customer, TotalCustomerNb, Database::"C5 CustTable", Codeunit::"C5 CustTable Migrator");
        DataMigrationStatusFacade.InitStatusLine(GetC5MigrationTypeTxt(), Database::Vendor, TotalVendorNb, Database::"C5 VendTable", Codeunit::"C5 VendTable Migrator");
        DataMigrationStatusFacade.InitStatusLine(GetC5MigrationTypeTxt(), Database::"G/L Account", TotalChartOfAccountNb, Database::"C5 LedTable", Codeunit::"C5 LedTable Migrator");
        DataMigrationStatusFacade.InitStatusLine(GetC5MigrationTypeTxt(), Database::"C5 LedTrans", TotalLegacyNb, 0, Codeunit::"C5 LedTrans Migrator");
        C5SchemaParameters.GetSingleInstance();
        TotalRecords := TotalCustomerNb + TotalVendorNb + TotalChartOfAccountNb + TotalLegacyNb + TotalItemNb;
        if (TotalChartOfAccountNb > 0) or DataMigrationStatus.Get(GetC5MigrationTypeTxt(), Database::"G/L Account") then begin
            if TotalCustomerNb > 0 then
                TotalRecords += C5SchemaParameters."Total Customer Entries";
            if TotalItemNb > 0 then
                TotalRecords += C5SchemaParameters."Total Item Entries";
            if TotalVendorNb > 0 then
                TotalRecords += C5SchemaParameters."Total Vendor Entries";
        end;
        C5DataLoaderStatus.Initialize(TotalRecords);
    end;

    procedure GetC5MigrationTypeTxt(): Text[250]
    begin
        exit(CopyStr(C5MigrationTypeTxt, 1, 250));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnFindBatchForItemTransactions', '', false, false)]
    local procedure OnFindBatchForItemTransactions(MigrationType: Text[250]; var ItemJournalBatchName: Code[10])
    var
        C5ItemMigrator: Codeunit "C5 Item Migrator";
    begin
        if MigrationType <> C5MigrationTypeTxt then
            exit;

        ItemJournalBatchName := C5ItemMigrator.GetHardCodedBatchName();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnFindBatchForCustomerTransactions', '', false, false)]
    local procedure OnFindBatchForCustomerTransactions(MigrationType: Text[250]; var GenJournalBatchName: Code[10])
    var
        C5CustTableMigrator: Codeunit "C5 CustTable Migrator";
    begin
        if MigrationType <> C5MigrationTypeTxt then
            exit;

        GenJournalBatchName := C5CustTableMigrator.GetHardCodedBatchName();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnFindBatchForVendorTransactions', '', false, false)]
    local procedure OnFindBatchForVendorTransactions(MigrationType: Text[250]; var GenJournalBatchName: Code[10])
    var
        C5VendTableMigrator: Codeunit "C5 VendTable Migrator";
    begin
        if MigrationType <> C5MigrationTypeTxt then
            exit;

        GenJournalBatchName := C5VendTableMigrator.GetHardCodedBatchName();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnFindBatchForAccountTransactions', '', false, false)]
    local procedure OnFindBatchForAccountTransactions(DataMigrationStatus: Record "Data Migration Status"; var GenJournalBatchName: Code[10])
    var
        C5LedTransMigrator: Codeunit "C5 LedTrans Migrator";
    begin
        if DataMigrationStatus."Migration Type" <> C5MigrationTypeTxt then
            exit;

        if DataMigrationStatus."Destination Table ID" <> Database::"C5 LedTrans" then
            exit;

        GenJournalBatchName := C5LedTransMigrator.GetHardCodedBatchName();
    end;

    [EventSubscriber(ObjectType::CodeUnit, CodeUnit::"Data Migration Facade", 'OnSelectRowFromDashboard', '', false, false)]
    local procedure OnSelectRecordSubscriber(var DataMigrationStatus: Record "Data Migration Status")
    var
        C5LedTrans: Record "C5 LedTrans";
        C5CustTable: Record "C5 CustTable";
        C5LedTable: Record "C5 LedTable";
        C5InvenTable: Record "C5 InvenTable";
        C5VendTable: Record "C5 VendTable";
    begin
        if not (DataMigrationStatus."Migration Type" = C5MigrationTypeTxt) then
            exit;

        case DataMigrationStatus."Destination Table ID" of
            Database::"C5 LedTrans":
                if not C5LedTrans.IsEmpty() then
                    Page.Run(Page::"C5 LedTrans List");
            Database::Customer:
                if not C5CustTable.IsEmpty() then
                    Page.Run(Page::"C5 CustTable List");
            Database::"G/L Account":
                if not C5LedTable.IsEmpty() then
                    Page.Run(Page::"C5 LedTable List");
            Database::Item:
                if not C5InvenTable.IsEmpty() then
                    Page.Run(Page::"C5 InvenTable List");
            Database::Vendor:
                if not C5VendTable.IsEmpty() then
                    Page.Run(Page::"C5 VendTable List");
        end;
    end;

    [EventSubscriber(ObjectType::CodeUnit, CodeUnit::"Data Migration Facade", 'OnGetMigrationHelpTopicUrl', '', false, false)]
    local procedure OnGetMigrationHelpTopicUrl(MigrationType: Text; var Url: Text)
    begin
        if MigrationType = C5MigrationTypeTxt Then
            Url := C5HelptTopicUrlTxt;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnMigrationCompleted', '', false, false)]
    local procedure OnAllStepsCompletedSubscriber(DataMigrationStatus: Record "Data Migration Status")
    begin
        if not (DataMigrationStatus."Migration Type" = C5MigrationTypeTxt) then
            exit;

        ClearStagingTables();
    end;

    local procedure ClearStagingTables()
    var
        C5LedTrans: Record "C5 LedTrans";
        C5LedTable: Record "C5 LedTable";
        C5CustDiscGroup: Record "C5 CustDiscGroup";
        C5ProcCode: Record "C5 ProcCode";
        C5CustContact: Record "C5 CustContact";
        C5CustGroup: Record "C5 CustGroup";
        C5CustRrans: Record "C5 CustTrans";
        C5CustTable: Record "C5 CustTable";
        C5Department: Record "C5 Department";
        C5Centre: Record "C5 Centre";
        C5Purpose: Record "C5 Purpose";
        C5Payment: Record "C5 Payment";
        C5Employee: Record "C5 Employee";
        C5Delivery: Record "C5 Delivery";
        C5Country: Record "C5 Country";
        C5ExchRate: Record "C5 ExchRate";
        C5CN8Code: Record "C5 CN8Code";
        C5InvenDiscGroup: Record "C5 InvenDiscGroup";
        C5UnitCode: Record "C5 UnitCode";
        C5ItemTrackGroup: Record "C5 ItemTrackGroup";
        C5InvenPriceGroup: Record "C5 InvenPriceGroup";
        C5InvenCustDisc: Record "C5 InvenCustDisc";
        C5InvenPrice: Record "C5 InvenPrice";
        C5InvenLocation: Record "C5 InvenLocation";
        C5InvenItemGroup: Record "C5 InvenItemGroup";
        C5VatGroup: Record "C5 VatGroup";
        C5InvenTrans: Record "C5 InvenTrans";
        C5InvenTable: Record "C5 InvenTable";
        C5InvenBOM: Record "C5 InvenBOM";
        C5VendDiscGroup: Record "C5 VendDiscGroup";
        C5VendContact: Record "C5 VendContact";
        C5VendGroup: Record "C5 VendGroup";
        C5VendTrans: Record "C5 VendTrans";
        C5VendTable: Record "C5 VendTable";
    begin
        C5LedTrans.DeleteAll();
        C5LedTable.DeleteAll();
        C5CustDiscGroup.DeleteAll();
        C5ProcCode.DeleteAll();
        C5CustContact.DeleteAll();
        C5CustGroup.DeleteAll();
        C5CustRrans.DeleteAll();
        C5CustTable.DeleteAll();
        C5Department.DeleteAll();
        C5Centre.DeleteAll();
        C5Purpose.DeleteAll();
        C5Payment.DeleteAll();
        C5Employee.DeleteAll();
        C5Delivery.DeleteAll();
        C5Country.DeleteAll();
        C5ExchRate.DeleteAll();
        C5CN8Code.DeleteAll();
        C5InvenDiscGroup.DeleteAll();
        C5UnitCode.DeleteAll();
        C5ItemTrackGroup.DeleteAll();
        C5InvenPriceGroup.DeleteAll();
        C5InvenCustDisc.DeleteAll();
        C5InvenPrice.DeleteAll();
        C5InvenLocation.DeleteAll();
        C5InvenItemGroup.DeleteAll();
        C5VatGroup.DeleteAll();
        C5InvenTrans.DeleteAll();
        C5InvenTable.DeleteAll();
        C5InvenBOM.DeleteAll();
        C5VendDiscGroup.DeleteAll();
        C5VendContact.DeleteAll();
        C5VendGroup.DeleteAll();
        C5VendTrans.DeleteAll();
        C5VendTable.DeleteAll();
    end;

    [EventSubscriber(ObjectType::CodeUnit, CodeUnit::"Data Migration Facade", 'OnInitDataMigrationError', '', false, false)]
    local procedure OnInitDataMigrationError(MigrationType: Text[250]; var BulkFixErrorsButtonEnabled: Boolean)
    begin
        if MigrationType <> C5MigrationTypeTxt then
            exit;
        BulkFixErrorsButtonEnabled := true;
    end;

    [EventSubscriber(ObjectType::CodeUnit, CodeUnit::"Data Migration Facade", 'OnBatchEditFromErrorView', '', false, false)]
    local procedure OnBatchEditFromErrorView(MigrationType: Text[250]; DestinationTableId: Integer)
    var
        C5LedTrans: Record "C5 LedTrans";
        C5CustTable: Record "C5 CustTable";
        C5LedTable: Record "C5 LedTable";
        C5InventTable: Record "C5 InvenTable";
        C5VendTable: Record "C5 VendTable";
        DataMigrationError: Record "Data Migration Error";
        C5LedTransList: Page "C5 LedTrans List";
        C5CustTableList: Page "C5 CustTable List";
        C5LedTableList: Page "C5 LedTable List";
        C5InventTableList: Page "C5 InvenTable List";
        C5VendTableList: Page "C5 VendTable List";
    begin
        if MigrationType <> C5MigrationTypeTxt Then
            exit;

        case DestinationTableId of
            Database::"C5 LedTrans":
                if C5LedTrans.FindSet() then begin
                    repeat
                        if DataMigrationError.ExistsEntry(MigrationType, DestinationTableId, C5LedTrans.RecordId()) then
                            C5LedTrans.Mark(true);
                    until C5LedTrans.Next() = 0;
                    C5LedTrans.MarkedOnly(true);
                    C5LedTransList.SetTableView(C5LedTrans);
                    C5LedTransList.RunModal();
                end;
            Database::Customer:
                if C5CustTable.FindSet() then begin
                    repeat
                        if DataMigrationError.ExistsEntry(MigrationType, DestinationTableId, C5CustTable.RecordId()) then
                            C5CustTable.Mark(true);
                    until C5CustTable.Next() = 0;
                    C5CustTable.MarkedOnly(true);
                    C5CustTableList.SetTableView(C5CustTable);
                    C5CustTableList.RunModal();
                end;
            Database::"G/L Account":
                if C5LedTable.FindSet() then begin
                    repeat
                        if DataMigrationError.ExistsEntry(MigrationType, DestinationTableId, C5LedTable.RecordId()) then
                            C5LedTable.Mark(true);
                    until C5LedTable.Next() = 0;
                    C5LedTable.MarkedOnly(true);
                    C5LedTableList.SetTableView(C5LedTable);
                    C5LedTableList.RunModal();
                end;
            Database::Item:
                if C5InventTable.FindSet() then begin
                    repeat
                        if DataMigrationError.ExistsEntry(MigrationType, DestinationTableId, C5InventTable.RecordId()) then
                            C5InventTable.Mark(true);
                    until C5InventTable.Next() = 0;
                    C5InventTable.MarkedOnly(true);
                    C5InventTableList.SetTableView(C5InventTable);
                    C5InventTableList.RunModal();
                end;
            Database::Vendor:
                if C5VendTable.FindSet() then begin
                    repeat
                        if DataMigrationError.ExistsEntry(MigrationType, DestinationTableId, C5VendTable.RecordId()) then
                            C5VendTable.Mark(true);
                    until C5VendTable.Next() = 0;
                    C5VendTable.MarkedOnly(true);
                    C5VendTableList.SetTableView(C5VendTable);
                    C5VendTableList.RunModal();
                end;
        end;
    end;
}