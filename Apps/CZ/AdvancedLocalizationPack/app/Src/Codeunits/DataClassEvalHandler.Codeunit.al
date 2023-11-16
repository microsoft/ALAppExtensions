// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Utilities;

using Microsoft.Assembly.Document;
using Microsoft.Assembly.History;
using Microsoft.Assembly.Setup;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Setup;
using Microsoft.Inventory.Transfer;
using Microsoft.Manufacturing.Capacity;
using Microsoft.Manufacturing.Setup;
using System.Environment;
using System.IO;
using System.Privacy;

codeunit 31252 "Data Class. Eval. Handler CZA"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure ApplyEvaluationClassificationsForPrivacyOnAfterClassifyCountrySpecificTables()
    begin
        ApplyEvaluationClassificationsForPrivacy();
    end;

    procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        AssemblySetup: Record "Assembly Setup";
        CapacityLedgerEntry: Record "Capacity Ledger Entry";
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
        DefaultDimension: Record "Default Dimension";
        DirectTransHeader: Record "Direct Trans. Header";
        DirectTransLine: Record "Direct Trans. Line";
        GLEntry: Record "G/L Entry";
        InventorySetup: Record "Inventory Setup";
        ItemEntryRelation: Record "Item Entry Relation";
        ItemJournalLine: Record "Item Journal Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ManufacturingSetup: Record "Manufacturing Setup";
        PostedAssemblyHeader: Record "Posted Assembly Header";
        PostedAssemblyLine: Record "Posted Assembly Line";
        StandardItemJournalLine: Record "Standard Item Journal Line";
        ValueEntry: Record "Value Entry";
        TransferRoute: Record "Transfer Route";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        TransferShipmentLine: Record "Transfer Shipment Line";
        TransferReceiptHeader: Record "Transfer Receipt Header";
        TransferReceiptLine: Record "Transfer Receipt Line";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Detailed G/L Entry CZA");

        DataClassificationMgt.SetFieldToNormal(Database::"Assembly Header", AssemblyHeader.FieldNo("Gen. Bus. Posting Group CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Assembly Line", AssemblyLine.FieldNo("Gen. Bus. Posting Group CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Assembly Setup", AssemblySetup.FieldNo("Default Gen.Bus.Post. Grp. CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Capacity Ledger Entry", CapacityLedgerEntry.FieldNo("User ID CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Data Exch. Field Mapping", DataExchFieldMapping.FieldNo("Date Formula CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Default Dimension", DefaultDimension.FieldNo("Automatic Create CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Default Dimension", DefaultDimension.FieldNo("Dim. Description Field ID CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Default Dimension", DefaultDimension.FieldNo("Dim. Description Format CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Default Dimension", DefaultDimension.FieldNo("Dim. Description Update CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Default Dimension", DefaultDimension.FieldNo("Auto. Create Value Posting CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Direct Trans. Header", DirectTransHeader.FieldNo("Gen. Bus. Posting Group CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Direct Trans. Line", DirectTransLine.FieldNo("Gen. Bus. Posting Group CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"G/L Entry", GLEntry.FieldNo("Closed at Date CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"G/L Entry", GLEntry.FieldNo("Applies-to ID CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"G/L Entry", GLEntry.FieldNo("Amount to Apply CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"G/L Entry", GLEntry.FieldNo("Applying Entry CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"G/L Entry", GLEntry.FieldNo("Closed CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Inventory Setup", InventorySetup.FieldNo("Use GPPG from SKU CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Inventory Setup", InventorySetup.FieldNo("Skip Update SKU on Posting CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Inventory Setup", InventorySetup.FieldNo("Exact Cost Revers. Mandat. CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Inventory Setup", InventorySetup.FieldNo("Def.G.Bus.P.Gr.-Dir.Trans. CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Entry Relation", ItemEntryRelation.FieldNo("Undo CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Journal Line", ItemJournalLine.FieldNo("Delivery-to Source No. CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Journal Line", ItemJournalLine.FieldNo("Currency Code CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Journal Line", ItemJournalLine.FieldNo("Currency Factor CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Ledger Entry", ItemLedgerEntry.FieldNo("Invoice-to Source No. CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Ledger Entry", ItemLedgerEntry.FieldNo("Delivery-to Source No. CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Ledger Entry", ItemLedgerEntry.FieldNo("Source Code CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Ledger Entry", ItemLedgerEntry.FieldNo("Reason Code CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Ledger Entry", ItemLedgerEntry.FieldNo("Currency Code CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Ledger Entry", ItemLedgerEntry.FieldNo("Currency Factor CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Manufacturing Setup", ManufacturingSetup.FieldNo("Default Gen.Bus.Post. Grp. CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Manufacturing Setup", ManufacturingSetup.FieldNo("Exact Cost Rev.Mand. Cons. CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Posted Assembly Header", PostedAssemblyHeader.FieldNo("Gen. Bus. Posting Group CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Posted Assembly Line", PostedAssemblyLine.FieldNo("Gen. Bus. Posting Group CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Standard Item Journal Line", StandardItemJournalLine.FieldNo("New Location Code CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Value Entry", ValueEntry.FieldNo("Invoice-to Source No. CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Value Entry", ValueEntry.FieldNo("Delivery-to Source No. CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Value Entry", ValueEntry.FieldNo("Currency Code CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Value Entry", ValueEntry.FieldNo("Currency Factor CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Route", TransferRoute.FieldNo("Gen.Bus.Post.Group Ship CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Route", TransferRoute.FieldNo("Gen.Bus.Post.Group Receive CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Header", TransferHeader.FieldNo("Gen.Bus.Post.Group Ship CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Header", TransferHeader.FieldNo("Gen.Bus.Post.Group Receive CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Line", TransferLine.FieldNo("Gen.Bus.Post.Group Ship CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Line", TransferLine.FieldNo("Gen.Bus.Post.Group Ship CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Shipment Header", TransferShipmentHeader.FieldNo("Gen.Bus.Post.Group Ship CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Shipment Header", TransferShipmentHeader.FieldNo("Gen.Bus.Post.Group Receive CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Shipment Line", TransferShipmentLine.FieldNo("Gen.Bus.Post.Group Ship CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Shipment Line", TransferShipmentLine.FieldNo("Gen.Bus.Post.Group Receive CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Shipment Line", TransferShipmentLine.FieldNo("Correction CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Shipment Line", TransferShipmentLine.FieldNo("Transfer Order Line No. CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Receipt Header", TransferReceiptHeader.FieldNo("Gen.Bus.Post.Group Ship CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Receipt Header", TransferReceiptHeader.FieldNo("Gen.Bus.Post.Group Receive CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Receipt Line", TransferReceiptLine.FieldNo("Gen.Bus.Post.Group Ship CZA"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Receipt Line", TransferReceiptLine.FieldNo("Gen.Bus.Post.Group Receive CZA"));
    end;
}
