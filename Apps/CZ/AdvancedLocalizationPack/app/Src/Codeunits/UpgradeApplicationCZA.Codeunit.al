// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Upgrade;

using Microsoft;
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

    trigger OnUpgradePerDatabase()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();
        SetDatabaseUpgradeTags();
    end;

    trigger OnUpgradePerCompany()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();
        BindSubscription(InstallApplicationsMgtCZL);
        UpgradeData();
        UnbindSubscription(InstallApplicationsMgtCZL);
        SetCompanyUpgradeTags();
    end;

    local procedure UpgradeData()
    begin
        UpgradeTransferShipmentLine();
        UpgradeItemEntryRelation();
        UpgradeStandardItemJournalLine();
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
