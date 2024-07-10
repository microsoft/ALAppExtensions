// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Upgrade;

using Microsoft;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Setup;
using Microsoft.Inventory.Transfer;
using Microsoft.Manufacturing.Setup;
using System.Environment.Configuration;

codeunit 31251 "Upgrade Application CZA"
{
    Subtype = Upgrade;
    Permissions = tabledata "Detailed G/L Entry CZA" = im,
                  tabledata "G/L Entry" = m,
                  tabledata "Inventory Setup" = m,
                  tabledata "Manufacturing Setup" = m,
                  tabledata "Transfer Shipment Line" = m,
                  tabledata "Item Entry Relation" = m,
                  tabledata "Standard Item Journal Line" = m;

    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitionsCZA: Codeunit "Upgrade Tag Definitions CZA";
        InstallApplicationsMgtCZL: Codeunit "Install Applications Mgt. CZL";
        AppInfo: ModuleInfo;

    trigger OnUpgradePerDatabase()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();
        UpgradePermission();
        SetDatabaseUpgradeTags();
    end;

    trigger OnUpgradePerCompany()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();
        BindSubscription(InstallApplicationsMgtCZL);
        UpgradeUsage();
        UpgradeData();
        UnbindSubscription(InstallApplicationsMgtCZL);
        SetCompanyUpgradeTags();
    end;

    local procedure UpgradePermission()
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerDatabaseUpgradeTag()) then
            exit;

        NavApp.GetCurrentModuleInfo(AppInfo);
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Detailed G/L Entry", Database::"Detailed G/L Entry CZA");
        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerDatabaseUpgradeTag());
    end;

    local procedure UpgradeUsage()
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerDatabaseUpgradeTag()) then
            exit;

        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Detailed G/L Entry", Database::"Detailed G/L Entry CZA");
    end;

    local procedure UpgradeData()
    begin
        UpgradeDetailedGLEntry();
        UpgradeGLEntry();
        UpgradeDefaultDimension();
        UpgradeInventorySetup();
        UpgradeManufacturingSetup();
        UpgradeTransferShipmentLine();
        UpgradeItemEntryRelation();
        UpgradeStandardItemJournalLine();
    end;

    local procedure UpgradeDetailedGLEntry()
    var
        DetailedGLEntry: Record "Detailed G/L Entry";
        DetailedGLEntryCZA: Record "Detailed G/L Entry CZA";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerCompanyUpgradeTag()) then
            exit;

        if DetailedGLEntry.FindSet() then
            repeat
                if not DetailedGLEntryCZA.Get(DetailedGLEntry."Entry No.") then begin
                    DetailedGLEntryCZA.Init();
                    DetailedGLEntryCZA."Entry No." := DetailedGLEntry."Entry No.";
                    DetailedGLEntryCZA.SystemId := DetailedGLEntry.SystemId;
                    DetailedGLEntryCZA.Insert(false, true);
                end;
                DetailedGLEntryCZA."G/L Entry No." := DetailedGLEntry."G/L Entry No.";
                DetailedGLEntryCZA."Applied G/L Entry No." := DetailedGLEntry."Applied G/L Entry No.";
                DetailedGLEntryCZA."G/L Account No." := DetailedGLEntry."G/L Account No.";
                DetailedGLEntryCZA."Posting Date" := DetailedGLEntry."Posting Date";
                DetailedGLEntryCZA."Document No." := DetailedGLEntry."Document No.";
                DetailedGLEntryCZA."Transaction No." := DetailedGLEntry."Transaction No.";
                DetailedGLEntryCZA.Amount := DetailedGLEntry.Amount;
                DetailedGLEntryCZA.Unapplied := DetailedGLEntry.Unapplied;
                DetailedGLEntryCZA."Unapplied by Entry No." := DetailedGLEntry."Unapplied by Entry No.";
                DetailedGLEntryCZA."User ID" := DetailedGLEntry."User ID";
                DetailedGLEntryCZA.Modify(false);
            until DetailedGLEntry.Next() = 0;
    end;

    local procedure UpgradeGLEntry();
    var
        GLEntry: Record "G/L Entry";
        GLEntryDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerCompanyUpgradeTag()) then
            exit;

        GLEntryDataTransfer.SetTables(Database::"G/L Entry", Database::"G/L Entry");
        GLEntryDataTransfer.AddFieldValue(GLEntry.FieldNo(Closed), GLEntry.FieldNo("Closed CZA"));
        GLEntryDataTransfer.AddFieldValue(GLEntry.FieldNo("Closed at Date"), GLEntry.FieldNo("Closed at Date CZA"));
        GLEntryDataTransfer.AddSourceFilter(GLEntry.FieldNo(Closed), '%1', true);
        GLEntryDataTransfer.CopyFields();
    end;

    local procedure UpgradeDefaultDimension();
    var
        DefaultDimension: Record "Default Dimension";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion183PerCompanyUpgradeTag()) then
            exit;

        DefaultDimension.SetLoadFields("Automatic Create", "Dimension Description Field ID", "Dimension Description Format", "Dimension Description Update", "Automatic Cr. Value Posting");
        DefaultDimension.SetRange("Automatic Create", true);
        if DefaultDimension.FindSet(true) then
            repeat
                DefaultDimension."Automatic Create CZA" := DefaultDimension."Automatic Create";
                DefaultDimension."Dim. Description Field ID CZA" := DefaultDimension."Dimension Description Field ID";
                DefaultDimension."Dim. Description Format CZA" := DefaultDimension."Dimension Description Format";
                DefaultDimension."Dim. Description Update CZA" := DefaultDimension."Dimension Description Update";
                case DefaultDimension."Automatic Cr. Value Posting" of
                    DefaultDimension."Automatic Cr. Value Posting"::" ":
                        DefaultDimension."Auto. Create Value Posting CZA" := DefaultDimension."Auto. Create Value Posting CZA"::" ";
                    DefaultDimension."Automatic Cr. Value Posting"::"No Code":
                        DefaultDimension."Auto. Create Value Posting CZA" := DefaultDimension."Auto. Create Value Posting CZA"::"No Code";
                    DefaultDimension."Automatic Cr. Value Posting"::"Same Code":
                        DefaultDimension."Auto. Create Value Posting CZA" := DefaultDimension."Auto. Create Value Posting CZA"::"Same Code";
                    DefaultDimension."Automatic Cr. Value Posting"::"Code Mandatory":
                        DefaultDimension."Auto. Create Value Posting CZA" := DefaultDimension."Auto. Create Value Posting CZA"::"Code Mandatory";
                end;
                Clear(DefaultDimension."Automatic Create");
                Clear(DefaultDimension."Dimension Description Field ID");
                Clear(DefaultDimension."Dimension Description Format");
                Clear(DefaultDimension."Dimension Description Update");
                Clear(DefaultDimension."Automatic Cr. Value Posting");
                DefaultDimension.Modify(false);
            until DefaultDimension.Next() = 0;
    end;

    local procedure UpgradeInventorySetup();
    var
        InventorySetup: Record "Inventory Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerCompanyUpgradeTag()) then
            exit;

        if InventorySetup.Get() then begin
            InventorySetup."Exact Cost Revers. Mandat. CZA" := InventorySetup."Exact Cost Reversing Mandatory";
            InventorySetup.Modify(false);
        end;
    end;

    local procedure UpgradeManufacturingSetup();
    var
        ManufacturingSetup: Record "Manufacturing Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerCompanyUpgradeTag()) then
            exit;

        if ManufacturingSetup.Get() then begin
            ManufacturingSetup."Exact Cost Rev.Mand. Cons. CZA" := ManufacturingSetup."Exact Cost Rev.Manda. (Cons.)";
            ManufacturingSetup.Modify(false);
        end;
    end;

    local procedure UpgradeTransferShipmentLine();
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
        TransferShipmentLineDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion200PerCompanyUpgradeTag()) then
            exit;

        TransferShipmentLineDataTransfer.SetTables(Database::"Transfer Shipment Line", Database::"Transfer Shipment Line");
        TransferShipmentLineDataTransfer.AddFieldValue(TransferShipmentLine.FieldNo(Correction), TransferShipmentLine.FieldNo("Correction CZA"));
        TransferShipmentLineDataTransfer.AddFieldValue(TransferShipmentLine.FieldNo("Transfer Order Line No."), TransferShipmentLine.FieldNo("Transfer Order Line No. CZA"));
        TransferShipmentLineDataTransfer.CopyFields();
    end;

    local procedure UpgradeItemEntryRelation();
    var
        ItemEntryRelation: Record "Item Entry Relation";
        ItemEntryRelationDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion200PerCompanyUpgradeTag()) then
            exit;

        ItemEntryRelationDataTransfer.SetTables(Database::"Item Entry Relation", Database::"Item Entry Relation");
        ItemEntryRelationDataTransfer.AddFieldValue(ItemEntryRelation.FieldNo(Undo), ItemEntryRelation.FieldNo("Undo CZA"));
        ItemEntryRelationDataTransfer.CopyFields();
    end;

    local procedure UpgradeStandardItemJournalLine();
    var
        StandardItemJournalLine: Record "Standard Item Journal Line";
        StandardItemJournalLineDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion210PerCompanyUpgradeTag()) then
            exit;

        StandardItemJournalLineDataTransfer.SetTables(Database::"Standard Item Journal Line", Database::"Standard Item Journal Line");
        StandardItemJournalLineDataTransfer.AddFieldValue(StandardItemJournalLine.FieldNo("New Location Code"), StandardItemJournalLine.FieldNo("New Location Code CZA"));
        StandardItemJournalLineDataTransfer.CopyFields();
    end;

    local procedure SetDatabaseUpgradeTags();
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion180PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion180PerDatabaseUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerDatabaseUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion183PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion183PerDatabaseUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion200PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion200PerDatabaseUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion220PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion220PerDatabaseUpgradeTag());
    end;

    local procedure SetCompanyUpgradeTags();
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion180PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion180PerCompanyUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerCompanyUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion183PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion183PerCompanyUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion200PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion200PerCompanyUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion220PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion220PerCompanyUpgradeTag());
    end;
}
