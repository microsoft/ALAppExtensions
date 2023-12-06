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

    trigger OnInstallAppPerDatabase()
    begin
        CopyPermission();
    end;

    trigger OnInstallAppPerCompany()
    begin
        if not InitializeDone() then begin
            BindSubscription(InstallApplicationsMgtCZL);
            CopyUsage();
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

    local procedure CopyPermission();
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Detailed G/L Entry", Database::"Detailed G/L Entry CZA");
    end;

    local procedure CopyUsage();
    begin
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Detailed G/L Entry", Database::"Detailed G/L Entry CZA");
    end;

    local procedure CopyData()
    begin
        CopyInventorySetup();
        CopyManufacturingSetup();
        CopyAssemblySetup();
        CopyAssemblyHeader();
        CopyAssemblyLine();
        CopyPostedAssemblyHeader();
        CopyPostedAssemblyLine();
        CopyNonstockItemSetup();
        CopyItemLedgerEntry();
        CopyValueEntry();
        CopyCapacityLedgerEntry();
        CopyItemJournalLine();
        CopyTransferRoute();
        CopyTransferHeader();
        CopyTransferLine();
        CopyTransferShipmentHeader();
        CopyTransferShipmentLine();
        CopyTransferReceiptHeader();
        CopyTransferReceiptLine();
        CopyDetailedGLEntry();
        CopyGLEntry();
        CopyItemEntryRelation();
        CopyDefaultDimension();
        CopyStandardItemJournalLine();
    end;

    local procedure CopyInventorySetup();
    var
        InventorySetup: Record "Inventory Setup";
    begin
        if InventorySetup.Get() then begin
            InventorySetup."Use GPPG from SKU CZA" := InventorySetup."Use GPPG from SKU";
            InventorySetup."Skip Update SKU on Posting CZA" := InventorySetup."Skip Update SKU on Posting";
            InventorySetup."Exact Cost Revers. Mandat. CZA" := InventorySetup."Exact Cost Reversing Mandatory";
            InventorySetup.Modify(false);
        end;
    end;

    local procedure CopyManufacturingSetup();
    var
        ManufacturingSetup: Record "Manufacturing Setup";
    begin
        if ManufacturingSetup.Get() then begin
            ManufacturingSetup."Default Gen.Bus.Post. Grp. CZA" := ManufacturingSetup."Default Gen.Bus. Posting Group";
            ManufacturingSetup."Exact Cost Rev.Mand. Cons. CZA" := ManufacturingSetup."Exact Cost Rev.Manda. (Cons.)";
            ManufacturingSetup.Modify(false);
        end;
    end;

    local procedure CopyAssemblySetup();
    var
        AssemblySetup: Record "Assembly Setup";
    begin
        if AssemblySetup.Get() then begin
            AssemblySetup."Default Gen.Bus.Post. Grp. CZA" := AssemblySetup."Gen. Bus. Posting Group";
            AssemblySetup.Modify(false);
        end;
    end;

    local procedure CopyAssemblyHeader();
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyHeaderDataTransfer: DataTransfer;
    begin
        AssemblyHeaderDataTransfer.SetTables(Database::"Assembly Header", Database::"Assembly Header");
        AssemblyHeaderDataTransfer.AddFieldValue(AssemblyHeader.FieldNo("Gen. Bus. Posting Group"), AssemblyHeader.FieldNo("Gen. Bus. Posting Group CZA"));
        AssemblyHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyAssemblyLine();
    var
        AssemblyLine: Record "Assembly Line";
        AssemblyLineDataTransfer: DataTransfer;
    begin
        AssemblyLineDataTransfer.SetTables(Database::"Assembly Line", Database::"Assembly Line");
        AssemblyLineDataTransfer.AddFieldValue(AssemblyLine.FieldNo("Gen. Bus. Posting Group"), AssemblyLine.FieldNo("Gen. Bus. Posting Group CZA"));
        AssemblyLineDataTransfer.CopyFields();
    end;

    local procedure CopyPostedAssemblyHeader();
    var
        PostedAssemblyHeader: Record "Posted Assembly Header";
        PostedAssemblyHeaderDataTransfer: DataTransfer;
    begin
        PostedAssemblyHeaderDataTransfer.SetTables(Database::"Posted Assembly Header", Database::"Posted Assembly Header");
        PostedAssemblyHeaderDataTransfer.AddFieldValue(PostedAssemblyHeader.FieldNo("Gen. Bus. Posting Group"), PostedAssemblyHeader.FieldNo("Gen. Bus. Posting Group CZA"));
        PostedAssemblyHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyPostedAssemblyLine();
    var
        PostedAssemblyLine: Record "Posted Assembly Line";
        PostedAssemblyLineDataTransfer: DataTransfer;
    begin
        PostedAssemblyLineDataTransfer.SetTables(Database::"Posted Assembly Line", Database::"Posted Assembly Line");
        PostedAssemblyLineDataTransfer.AddFieldValue(PostedAssemblyLine.FieldNo("Gen. Bus. Posting Group"), PostedAssemblyLine.FieldNo("Gen. Bus. Posting Group CZA"));
        PostedAssemblyLineDataTransfer.CopyFields();
    end;

    local procedure CopyNonstockItemSetup();
    var
        NonstockItemSetup: Record "Nonstock Item Setup";
    begin
        if NonstockItemSetup.Get() then begin
            if NonstockItemSetup."No. From No. Series" then
                NonstockItemSetup."No. Format" := NonstockItemSetup."No. Format"::"Item No. Series";
            NonstockItemSetup.Modify(false);
        end;
    end;

    local procedure CopyItemLedgerEntry();
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemLedgerEntryDataTransfer: DataTransfer;
    begin
        ItemLedgerEntryDataTransfer.SetTables(Database::"Item Ledger Entry", Database::"Item Ledger Entry");
        ItemLedgerEntryDataTransfer.AddFieldValue(ItemLedgerEntry.FieldNo("Source No. 2"), ItemLedgerEntry.FieldNo("Invoice-to Source No. CZA"));
        ItemLedgerEntryDataTransfer.AddFieldValue(ItemLedgerEntry.FieldNo("Source No. 3"), ItemLedgerEntry.FieldNo("Delivery-to Source No. CZA"));
        ItemLedgerEntryDataTransfer.AddFieldValue(ItemLedgerEntry.FieldNo("Source Code"), ItemLedgerEntry.FieldNo("Source Code CZA"));
        ItemLedgerEntryDataTransfer.AddFieldValue(ItemLedgerEntry.FieldNo("Reason Code"), ItemLedgerEntry.FieldNo("Reason Code CZA"));
        ItemLedgerEntryDataTransfer.AddFieldValue(ItemLedgerEntry.FieldNo("Currency Code"), ItemLedgerEntry.FieldNo("Currency Code CZA"));
        ItemLedgerEntryDataTransfer.AddFieldValue(ItemLedgerEntry.FieldNo("Currency Factor"), ItemLedgerEntry.FieldNo("Currency Factor CZA"));
        ItemLedgerEntryDataTransfer.CopyFields();
    end;

    local procedure CopyValueEntry();
    var
        ValueEntry: Record "Value Entry";
        ValueEntryDataTransfer: DataTransfer;
    begin
        ValueEntryDataTransfer.SetTables(Database::"Value Entry", Database::"Value Entry");
        ValueEntryDataTransfer.AddFieldValue(ValueEntry.FieldNo("Source No. 2"), ValueEntry.FieldNo("Invoice-to Source No. CZA"));
        ValueEntryDataTransfer.AddFieldValue(ValueEntry.FieldNo("Source No. 3"), ValueEntry.FieldNo("Delivery-to Source No. CZA"));
        ValueEntryDataTransfer.AddFieldValue(ValueEntry.FieldNo("Currency Code"), ValueEntry.FieldNo("Currency Code CZA"));
        ValueEntryDataTransfer.AddFieldValue(ValueEntry.FieldNo("Currency Factor"), ValueEntry.FieldNo("Currency Factor CZA"));
        ValueEntryDataTransfer.CopyFields();
    end;

    local procedure CopyCapacityLedgerEntry();
    var
        CapacityLedgerEntry: Record "Capacity Ledger Entry";
        CapacityLedgerEntryDataTransfer: DataTransfer;
    begin
        CapacityLedgerEntryDataTransfer.SetTables(Database::"Capacity Ledger Entry", Database::"Capacity Ledger Entry");
        CapacityLedgerEntryDataTransfer.AddFieldValue(CapacityLedgerEntry.FieldNo("User ID"), CapacityLedgerEntry.FieldNo("User ID CZA"));
        CapacityLedgerEntryDataTransfer.CopyFields();
    end;

    local procedure CopyItemJournalLine();
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalLineDataTransfer: DataTransfer;
    begin
        ItemJournalLineDataTransfer.SetTables(Database::"Item Journal Line", Database::"Item Journal Line");
        ItemJournalLineDataTransfer.AddFieldValue(ItemJournalLine.FieldNo("Source No. 3"), ItemJournalLine.FieldNo("Delivery-to Source No. CZA"));
        ItemJournalLineDataTransfer.AddFieldValue(ItemJournalLine.FieldNo("Currency Code"), ItemJournalLine.FieldNo("Currency Code CZA"));
        ItemJournalLineDataTransfer.AddFieldValue(ItemJournalLine.FieldNo("Currency Factor"), ItemJournalLine.FieldNo("Currency Factor CZA"));
        ItemJournalLineDataTransfer.CopyFields();
    end;

    local procedure CopyTransferRoute();
    var
        TransferRoute: Record "Transfer Route";
        TransferRouteDataTransfer: DataTransfer;
    begin
        TransferRouteDataTransfer.SetTables(Database::"Transfer Route", Database::"Transfer Route");
        TransferRouteDataTransfer.AddFieldValue(TransferRoute.FieldNo("Gen. Bus. Post. Group Ship"), TransferRoute.FieldNo("Gen.Bus.Post.Group Ship CZA"));
        TransferRouteDataTransfer.AddFieldValue(TransferRoute.FieldNo("Gen. Bus. Post. Group Receive"), TransferRoute.FieldNo("Gen.Bus.Post.Group Receive CZA"));
        TransferRouteDataTransfer.CopyFields();
    end;

    local procedure CopyTransferHeader();
    var
        TransferHeader: Record "Transfer Header";
        TransferHeaderDataTransfer: DataTransfer;
    begin
        TransferHeaderDataTransfer.SetTables(Database::"Transfer Header", Database::"Transfer Header");
        TransferHeaderDataTransfer.AddFieldValue(TransferHeader.FieldNo("Gen. Bus. Post. Group Ship"), TransferHeader.FieldNo("Gen.Bus.Post.Group Ship CZA"));
        TransferHeaderDataTransfer.AddFieldValue(TransferHeader.FieldNo("Gen. Bus. Post. Group Receive"), TransferHeader.FieldNo("Gen.Bus.Post.Group Receive CZA"));
        TransferHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyTransferLine();
    var
        TransferLine: Record "Transfer Line";
        TransferLineDataTransfer: DataTransfer;
    begin
        TransferLineDataTransfer.SetTables(Database::"Transfer Line", Database::"Transfer Line");
        TransferLineDataTransfer.AddFieldValue(TransferLine.FieldNo("Gen. Bus. Post. Group Ship"), TransferLine.FieldNo("Gen.Bus.Post.Group Ship CZA"));
        TransferLineDataTransfer.AddFieldValue(TransferLine.FieldNo("Gen. Bus. Post. Group Receive"), TransferLine.FieldNo("Gen.Bus.Post.Group Receive CZA"));
        TransferLineDataTransfer.CopyFields();
    end;

    local procedure CopyTransferShipmentHeader();
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
        TransferShipmentHeaderDataTransfer: DataTransfer;
    begin
        TransferShipmentHeaderDataTransfer.SetTables(Database::"Transfer Shipment Header", Database::"Transfer Shipment Header");
        TransferShipmentHeaderDataTransfer.AddFieldValue(TransferShipmentHeader.FieldNo("Gen. Bus. Post. Group Ship"), TransferShipmentHeader.FieldNo("Gen.Bus.Post.Group Ship CZA"));
        TransferShipmentHeaderDataTransfer.AddFieldValue(TransferShipmentHeader.FieldNo("Gen. Bus. Post. Group Receive"), TransferShipmentHeader.FieldNo("Gen.Bus.Post.Group Receive CZA"));
        TransferShipmentHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyTransferShipmentLine();
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
        TransferShipmentLineDataTransfer: DataTransfer;
    begin
        TransferShipmentLineDataTransfer.SetTables(Database::"Transfer Shipment Line", Database::"Transfer Shipment Line");
        TransferShipmentLineDataTransfer.AddFieldValue(TransferShipmentLine.FieldNo("Gen. Bus. Post. Group Ship"), TransferShipmentLine.FieldNo("Gen.Bus.Post.Group Ship CZA"));
        TransferShipmentLineDataTransfer.AddFieldValue(TransferShipmentLine.FieldNo("Gen. Bus. Post. Group Receive"), TransferShipmentLine.FieldNo("Gen.Bus.Post.Group Receive CZA"));
        TransferShipmentLineDataTransfer.AddFieldValue(TransferShipmentLine.FieldNo(Correction), TransferShipmentLine.FieldNo("Correction CZA"));
        TransferShipmentLineDataTransfer.AddFieldValue(TransferShipmentLine.FieldNo("Transfer Order Line No."), TransferShipmentLine.FieldNo("Transfer Order Line No. CZA"));
        TransferShipmentLineDataTransfer.CopyFields();
    end;

    local procedure CopyTransferReceiptHeader();
    var
        TransferReceiptHeader: Record "Transfer Receipt Header";
        TransferReceiptHeaderDataTransfer: DataTransfer;
    begin
        TransferReceiptHeaderDataTransfer.SetTables(Database::"Transfer Receipt Header", Database::"Transfer Receipt Header");
        TransferReceiptHeaderDataTransfer.AddFieldValue(TransferReceiptHeader.FieldNo("Gen. Bus. Post. Group Ship"), TransferReceiptHeader.FieldNo("Gen.Bus.Post.Group Ship CZA"));
        TransferReceiptHeaderDataTransfer.AddFieldValue(TransferReceiptHeader.FieldNo("Gen. Bus. Post. Group Receive"), TransferReceiptHeader.FieldNo("Gen.Bus.Post.Group Receive CZA"));
        TransferReceiptHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyTransferReceiptLine();
    var
        TransferReceiptLine: Record "Transfer Receipt Line";
        TransferReceiptLineDataTransfer: DataTransfer;
    begin
        TransferReceiptLineDataTransfer.SetTables(Database::"Transfer Receipt Line", Database::"Transfer Receipt Line");
        TransferReceiptLineDataTransfer.AddFieldValue(TransferReceiptLine.FieldNo("Gen. Bus. Post. Group Ship"), TransferReceiptLine.FieldNo("Gen.Bus.Post.Group Ship CZA"));
        TransferReceiptLineDataTransfer.AddFieldValue(TransferReceiptLine.FieldNo("Gen. Bus. Post. Group Receive"), TransferReceiptLine.FieldNo("Gen.Bus.Post.Group Receive CZA"));
        TransferReceiptLineDataTransfer.CopyFields();
    end;

    local procedure CopyDetailedGLEntry()
    var
        DetailedGLEntry: Record "Detailed G/L Entry";
        DetailedGLEntryCZA: Record "Detailed G/L Entry CZA";
    begin
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

    local procedure CopyGLEntry();
    var
        GLEntry: Record "G/L Entry";
        GLEntryDataTransfer: DataTransfer;
    begin
        GLEntryDataTransfer.SetTables(Database::"G/L Entry", Database::"G/L Entry");
        GLEntryDataTransfer.AddFieldValue(GLEntry.FieldNo(Closed), GLEntry.FieldNo("Closed CZA"));
        GLEntryDataTransfer.AddFieldValue(GLEntry.FieldNo("Closed at Date"), GLEntry.FieldNo("Closed at Date CZA"));
        GLEntryDataTransfer.AddFieldValue(GLEntry.FieldNo("Amount to Apply"), GLEntry.FieldNo("Amount to Apply CZA"));
        GLEntryDataTransfer.AddFieldValue(GLEntry.FieldNo("Applies-to ID"), GLEntry.FieldNo("Applies-to ID CZA"));
        GLEntryDataTransfer.CopyFields();
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

    local procedure CopyDefaultDimension();
    var
        DefaultDimension: Record "Default Dimension";
    begin
        DefaultDimension.SetLoadFields("Automatic Create", "Dimension Description Field ID", "Dimension Description Format", "Dimension Description Update", "Automatic Cr. Value Posting");
        if DefaultDimension.FindSet(true) then
            repeat
                if DefaultDimension."Automatic Create" then begin
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
                end;
            until DefaultDimension.Next() = 0;
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
