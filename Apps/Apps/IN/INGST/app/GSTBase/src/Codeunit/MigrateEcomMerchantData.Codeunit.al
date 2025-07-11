// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Sales.Archive;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using System.Reflection;

codeunit 18025 "Migrate Ecom Merchant Data"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        InitDataMigrationProgressWindow();
        MoveECommerceData();
        MoveSalesHeaderData();
        MoveSalesInvoiceHeaderData();
        MoveSalesCrMemoHeaderData();
        MoveSalesShipmentHeaderData();
        MoveSalesArchivalHeaderData();
        MoveJournalLineData();
        CloseMigrationProgressWindow();
    end;

    local procedure MoveECommerceData()
    var
        FromECommerceMerchant: Record "E-Commerce Merchant";
        ToECommMerchant: Record "E-Comm. Merchant";
    begin
        if FromECommerceMerchant.FindSet() then begin
            UpdateMigrationProgressWindow(Database::"E-Commerce Merchant", FromECommerceMerchant.Count());
            repeat
                ToECommMerchant.Init();
                ToECommMerchant.TransferFields(FromECommerceMerchant);
                ToECommMerchant.Insert();
                UpdateRecordID(FromECommerceMerchant.RecordId)
            until FromECommerceMerchant.Next() = 0;

            FromECommerceMerchant.DeleteAll();
        end;
    end;

    local procedure MoveSalesHeaderData()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetFilter("E-Commerce Merchant Id", '<>%1', '');
        if SalesHeader.FindSet() then begin
            UpdateMigrationProgressWindow(Database::"Sales Header", SalesHeader.Count());
            repeat
                SalesHeader."E-Comm. Merchant Id" := SalesHeader."E-Commerce Merchant Id";
                SalesHeader."E-Commerce Merchant Id" := '';
                SalesHeader.Modify();
                UpdateRecordID(SalesHeader.RecordId);
            until SalesHeader.Next() = 0;
        end;
    end;

    local procedure MoveSalesInvoiceHeaderData()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.SetFilter("E-Commerce Merchant Id", '<>%1', '');
        if SalesInvoiceHeader.FindSet() then begin
            UpdateMigrationProgressWindow(Database::"Sales Invoice Header", SalesInvoiceHeader.Count());
            repeat
                SalesInvoiceHeader."E-Comm. Merchant Id" := SalesInvoiceHeader."E-Commerce Merchant Id";
                SalesInvoiceHeader."E-Commerce Merchant Id" := '';
                SalesInvoiceHeader.Modify();
                UpdateRecordID(SalesInvoiceHeader.RecordId);
            until SalesInvoiceHeader.Next() = 0;
        end;
    end;

    local procedure MoveSalesCrMemoHeaderData()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        SalesCrMemoHeader.SetFilter("E-Commerce Merchant Id", '<>%1', '');
        if SalesCrMemoHeader.FindSet() then begin
            UpdateMigrationProgressWindow(Database::"Sales Cr.Memo Header", SalesCrMemoHeader.Count());
            repeat
                SalesCrMemoHeader."E-Comm. Merchant Id" := SalesCrMemoHeader."E-Commerce Merchant Id";
                SalesCrMemoHeader."E-Commerce Merchant Id" := '';
                SalesCrMemoHeader.Modify();
                UpdateRecordID(SalesCrMemoHeader.RecordId);
            until SalesCrMemoHeader.Next() = 0;
        end;
    end;

    local procedure MoveSalesShipmentHeaderData()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
    begin
        SalesShipmentHeader.SetFilter("E-Commerce Merchant Id", '<>%1', '');
        if SalesShipmentHeader.FindSet() then begin
            UpdateMigrationProgressWindow(Database::"Sales Shipment Header", SalesShipmentHeader.Count());
            repeat
                SalesShipmentHeader."E-Comm. Merchant Id" := SalesShipmentHeader."E-Commerce Merchant Id";
                SalesShipmentHeader."E-Commerce Merchant Id" := '';
                SalesShipmentHeader.Modify();
                UpdateRecordID(SalesShipmentHeader.RecordId);
            until SalesShipmentHeader.Next() = 0;
        end;
    end;

    local procedure MoveSalesArchivalHeaderData()
    var
        SalesHeaderArchive: Record "Sales Header Archive";
    begin
        SalesHeaderArchive.SetFilter("E-Commerce Merchant Id", '<>%1', '');
        if SalesHeaderArchive.FindSet() then begin
            UpdateMigrationProgressWindow(Database::"Sales Header Archive", SalesHeaderArchive.Count());
            repeat
                SalesHeaderArchive."E-Comm. Merchant Id" := SalesHeaderArchive."E-Commerce Merchant Id";
                SalesHeaderArchive."E-Commerce Merchant Id" := '';
                SalesHeaderArchive.Modify();
                UpdateRecordID(SalesHeaderArchive.RecordId);
            until SalesHeaderArchive.Next() = 0;
        end;
    end;

    local procedure MoveJournalLineData()
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetFilter("E-Commerce Merchant Id", '<>%1', '');
        if GenJournalLine.FindSet() then begin
            UpdateMigrationProgressWindow(Database::"Gen. Journal Line", GenJournalLine.Count());
            repeat
                GenJournalLine."E-Comm. Merchant Id" := GenJournalLine."E-Commerce Merchant Id";
                GenJournalLine."E-Commerce Merchant Id" := '';
                GenJournalLine.Modify();
                UpdateRecordID(GenJournalLine.RecordId);
            until GenJournalLine.Next() = 0;
        end;
    end;

    local procedure InitDataMigrationProgressWindow()
    begin
        if not GuiAllowed() then
            exit;

        MigrationDialog.Open(MigratingTableLbl + RecordCountLbl + ProcessingRecordLbl);
    end;

    local procedure UpdateMigrationProgressWindow(TableID: Integer; RecordCount: Integer)
    var
        AllObj: Record AllObjWithCaption;
        TableName: Text;
    begin
        if not GuiAllowed() then
            exit;

        if TableID <> 0 then begin
            AllObj.Get(AllObj."Object Type"::Table, TableID);
            TableName := AllObj."Object Name";
        end;

        MigrationDialog.Update(1, TableName);
        MigrationDialog.Update(2, RecordCount);
    end;

    local procedure UpdateRecordID(TableRecID: RecordID)
    begin
        if not GuiAllowed() then
            exit;

        MigrationDialog.Update(3, TableRecID);
    end;

    local procedure CloseMigrationProgressWindow()
    begin
        if not GuiAllowed() then
            exit;

        MigrationDialog.close();
    end;

    var
        MigrationDialog: Dialog;
        MigratingTableLbl: Label 'Migarting Table :               #1######\', Comment = 'Table Name', Locked = true;
        RecordCountLbl: Label 'Total No. of Records to be Migrated              #2######\', Comment = 'Total No. of Records to be Migrated', Locked = true;
        ProcessingRecordLbl: Label 'Record ID            #3######\', Comment = 'Record ID Processing', Locked = true;
}
