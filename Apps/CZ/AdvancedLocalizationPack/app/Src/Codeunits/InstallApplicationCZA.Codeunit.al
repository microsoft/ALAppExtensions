// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft;

using Microsoft.Assembly.Document;
using Microsoft.Assembly.History;
using Microsoft.Assembly.Setup;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Catalog;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Setup;
using Microsoft.Inventory.Transfer;
using Microsoft.Manufacturing.Capacity;
using Microsoft.Manufacturing.Setup;
using Microsoft.Utilities;
using System.Upgrade;

#pragma warning disable AL0432
codeunit 31250 "Install Application CZA"
{
    Subtype = Install;
    Permissions = tabledata "Inventory Setup" = m,
                  tabledata "Manufacturing Setup" = m,
                  tabledata "Assembly Setup" = m,
                  tabledata "Assembly Header" = m,
                  tabledata "Assembly Line" = m,
                  tabledata "Posted Assembly Header" = m,
                  tabledata "Posted Assembly Line" = m,
                  tabledata "Nonstock Item Setup" = m,
                  tabledata "Item Ledger Entry" = m,
                  tabledata "Value Entry" = m,
                  tabledata "Capacity Ledger Entry" = m,
                  tabledata "Item Journal Line" = m,
                  tabledata "Transfer Route" = m,
                  tabledata "Transfer Header" = m,
                  tabledata "Transfer Line" = m,
                  tabledata "Transfer Shipment Header" = m,
                  tabledata "Transfer Shipment Line" = m,
                  tabledata "Transfer Receipt Header" = m,
                  tabledata "Transfer Receipt Line" = m,
                  tabledata "Detailed G/L Entry CZA" = im,
                  tabledata "G/L Entry" = m,
                  tabledata "Item Entry Relation" = m,
                  tabledata "Default Dimension" = m,
                  tabledata "Standard Item Journal Line" = m;

    var
        InstallApplicationsMgtCZL: Codeunit "Install Applications Mgt. CZL";
        AppInfo: ModuleInfo;

    trigger OnInstallAppPerCompany()
    begin
        if not InitializeDone() then begin
            BindSubscription(InstallApplicationsMgtCZL);
            CopyData();
            UnbindSubscription(InstallApplicationsMgtCZL);
        end;
        CompanyInitialize();
    end;

    local procedure InitializeDone(): boolean
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(AppInfo.DataVersion() <> Version.Create('0.0.0.0'));
    end;

    local procedure CopyData()
    begin
        CopyTransferShipmentLine();
        CopyItemEntryRelation();
        CopyStandardItemJournalLine();
    end;

    local procedure CopyTransferShipmentLine();
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
        TransferShipmentLineDataTransfer: DataTransfer;
    begin
        TransferShipmentLineDataTransfer.SetTables(Database::"Transfer Shipment Line", Database::"Transfer Shipment Line");
        TransferShipmentLineDataTransfer.AddFieldValue(TransferShipmentLine.FieldNo(Correction), TransferShipmentLine.FieldNo("Correction CZA"));
        TransferShipmentLineDataTransfer.AddFieldValue(TransferShipmentLine.FieldNo("Transfer Order Line No."), TransferShipmentLine.FieldNo("Transfer Order Line No. CZA"));
        TransferShipmentLineDataTransfer.CopyFields();
    end;

    local procedure CopyItemEntryRelation();
    var
        ItemEntryRelation: Record "Item Entry Relation";
        ItemEntryRelationDataTransfer: DataTransfer;
    begin
        ItemEntryRelationDataTransfer.SetTables(Database::"Item Entry Relation", Database::"Item Entry Relation");
        ItemEntryRelationDataTransfer.AddFieldValue(ItemEntryRelation.FieldNo(Undo), ItemEntryRelation.FieldNo("Undo CZA"));
        ItemEntryRelationDataTransfer.CopyFields();
    end;

    local procedure CopyStandardItemJournalLine();
    var
        StandardItemJournalLine: Record "Standard Item Journal Line";
        StandardItemJournalLineDataTransfer: DataTransfer;
    begin
        StandardItemJournalLineDataTransfer.SetTables(Database::"Standard Item Journal Line", Database::"Standard Item Journal Line");
        StandardItemJournalLineDataTransfer.AddFieldValue(StandardItemJournalLine.FieldNo("New Location Code"), StandardItemJournalLine.FieldNo("New Location Code CZA"));
        StandardItemJournalLineDataTransfer.CopyFields();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    var
        DataClassEvalHandlerCZA: Codeunit "Data Class. Eval. Handler CZA";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        DataClassEvalHandlerCZA.ApplyEvaluationClassificationsForPrivacy();
        UpgradeTag.SetAllUpgradeTags();
    end;
}
