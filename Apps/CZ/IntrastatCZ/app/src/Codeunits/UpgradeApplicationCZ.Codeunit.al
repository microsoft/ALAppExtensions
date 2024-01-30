// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Inventory.Transfer;
using Microsoft.Purchases.Archive;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Sales.Archive;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using System.Environment.Configuration;
using System.Upgrade;
using Microsoft.Foundation.Shipping;
using System.IO;

codeunit 31306 "Upgrade Application CZ"
{
    Subtype = Upgrade;
    Permissions = tabledata "Purchase Header" = m,
                  tabledata "Purchase Header Archive" = m,
                  tabledata "Purch. Cr. Memo Hdr." = m,
                  tabledata "Purch. Inv. Header" = m,
                  tabledata "Purch. Rcpt. Header" = m,
                  tabledata "Sales Header" = m,
                  tabledata "Sales Header Archive" = m,
                  tabledata "Sales Cr.Memo Header" = m,
                  tabledata "Sales Invoice Header" = m,
                  tabledata "Sales Shipment Header" = m,
                  tabledata "Service Header" = m,
                  tabledata "Service Invoice Header" = m,
                  tabledata "Service Cr.Memo Header" = m,
                  tabledata "Service Shipment Header" = m,
                  tabledata "Transfer Header" = m,
                  tabledata "Transfer Receipt Header" = m,
                  tabledata "Transfer Shipment Header" = m,
                  tabledata "Return Receipt Header" = m,
                  tabledata "Return Shipment Header" = m,
                  tabledata "Direct Trans. Header" = m;

    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitionsCZ: Codeunit "Upgrade Tag Definitions CZ";

    trigger OnUpgradePerCompany()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();
        UpgradeData();
    end;

    local procedure UpgradeData()
    begin
        UpgradeDirectTransHeader();
        UpgradePurchaseHeader();
        UpgradePurchaseHeaderArchive();
        UpgradePurchCrMemoHdr();
        UpgradePurchInvHeader();
        UpgradePurchRcptHeader();
        UpgradeReturnReceiptHeader();
        UpgradeReturnShipmentHeader();
        UpgradeSalesCrMemoHeader();
        UpgradeSalesInvoiceHeader();
        UpgradeSalesHeader();
        UpgradeSalesHeaderArchive();
        UpgradeSalesShipmentHeader();
        UpgradeServiceHeader();
        UpgradeServiceInvoiceHeader();
        UpgradeServiceCrMemoHeader();
        UpgradeServiceShipmentHeader();
        UpgradeTransferHeader();
        UpgradeTransferReceiptHeader();
        UpgradeTransferShipmentHeader();
        UpgradeIntrastatDeliveryGroup();
        UpgradeIntrastatDescription();
    end;

    local procedure UpgradeDirectTransHeader()
    var
        DirectTransHeader: Record "Direct Trans. Header";
        DataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag()) then
            exit;

        DataTransfer.SetTables(Database::"Direct Trans. Header", Database::"Direct Trans. Header");
        DataTransfer.AddFieldValue(DirectTransHeader.FieldNo("Intrastat Exclude CZL"), DirectTransHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag());
    end;

    local procedure UpgradePurchaseHeader()
    var
        PurchaseHeader: Record "Purchase Header";
        DataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag()) then
            exit;

        DataTransfer.SetTables(Database::"Purchase Header", Database::"Purchase Header");
        DataTransfer.AddFieldValue(PurchaseHeader.FieldNo("Intrastat Exclude CZL"), PurchaseHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag());
    end;

    local procedure UpgradePurchaseHeaderArchive()
    var
        PurchaseHeaderArchive: Record "Purchase Header Archive";
        DataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag()) then
            exit;

        DataTransfer.SetTables(Database::"Purchase Header Archive", Database::"Purchase Header Archive");
        DataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("Intrastat Exclude CZL"), PurchaseHeaderArchive.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag());
    end;

    local procedure UpgradePurchCrMemoHdr()
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        DataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag()) then
            exit;

        DataTransfer.SetTables(Database::"Purch. Cr. Memo Hdr.", Database::"Purch. Cr. Memo Hdr.");
        DataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Intrastat Exclude CZL"), PurchCrMemoHdr.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag());
    end;

    local procedure UpgradePurchInvHeader()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        DataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag()) then
            exit;

        DataTransfer.SetTables(Database::"Purch. Inv. Header", Database::"Purch. Inv. Header");
        DataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Intrastat Exclude CZL"), PurchInvHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag());
    end;

    local procedure UpgradePurchRcptHeader()
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        DataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag()) then
            exit;

        DataTransfer.SetTables(Database::"Purch. Rcpt. Header", Database::"Purch. Rcpt. Header");
        DataTransfer.AddFieldValue(PurchRcptHeader.FieldNo("Intrastat Exclude CZL"), PurchRcptHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag());
    end;

    local procedure UpgradeSalesCrMemoHeader()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        DataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag()) then
            exit;

        DataTransfer.SetTables(Database::"Sales Cr.Memo Header", Database::"Sales Cr.Memo Header");
        DataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("Intrastat Exclude CZL"), SalesCrMemoHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag());
    end;

    local procedure UpgradeSalesInvoiceHeader()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag()) then
            exit;

        DataTransfer.SetTables(Database::"Sales Invoice Header", Database::"Sales Invoice Header");
        DataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("Intrastat Exclude CZL"), SalesInvoiceHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag());
    end;

    local procedure UpgradeSalesHeader()
    var
        SalesHeader: Record "Sales Header";
        DataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag()) then
            exit;

        DataTransfer.SetTables(Database::"Sales Header", Database::"Sales Header");
        DataTransfer.AddFieldValue(SalesHeader.FieldNo("Intrastat Exclude CZL"), SalesHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag());
    end;

    local procedure UpgradeSalesHeaderArchive()
    var
        SalesHeaderArchive: Record "Sales Header Archive";
        DataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag()) then
            exit;

        DataTransfer.SetTables(Database::"Sales Header Archive", Database::"Sales Header Archive");
        DataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("Intrastat Exclude CZL"), SalesHeaderArchive.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag());
    end;

    local procedure UpgradeSalesShipmentHeader()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        DataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag()) then
            exit;

        DataTransfer.SetTables(Database::"Sales Shipment Header", Database::"Sales Shipment Header");
        DataTransfer.AddFieldValue(SalesShipmentHeader.FieldNo("Intrastat Exclude CZL"), SalesShipmentHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag());
    end;

    local procedure UpgradeServiceHeader()
    var
        ServiceHeader: Record "Service Header";
        DataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag()) then
            exit;

        DataTransfer.SetTables(Database::"Service Header", Database::"Service Header");
        DataTransfer.AddFieldValue(ServiceHeader.FieldNo("Intrastat Exclude CZL"), ServiceHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag());
    end;

    local procedure UpgradeServiceInvoiceHeader()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        DataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag()) then
            exit;

        DataTransfer.SetTables(Database::"Service Invoice Header", Database::"Service Invoice Header");
        DataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("Intrastat Exclude CZL"), ServiceInvoiceHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag());
    end;

    local procedure UpgradeServiceCrMemoHeader()
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        DataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag()) then
            exit;

        DataTransfer.SetTables(Database::"Service Cr.Memo Header", Database::"Service Cr.Memo Header");
        DataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("Intrastat Exclude CZL"), ServiceCrMemoHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag());
    end;

    local procedure UpgradeServiceShipmentHeader()
    var
        ServiceShipmentHeader: Record "Service Shipment Header";
        DataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag()) then
            exit;

        DataTransfer.SetTables(Database::"Service Shipment Header", Database::"Service Shipment Header");
        DataTransfer.AddFieldValue(ServiceShipmentHeader.FieldNo("Intrastat Exclude CZL"), ServiceShipmentHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag());
    end;

    local procedure UpgradeTransferHeader()
    var
        TransferHeader: Record "Transfer Header";
        DataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag()) then
            exit;

        DataTransfer.SetTables(Database::"Transfer Header", Database::"Transfer Header");
        DataTransfer.AddFieldValue(TransferHeader.FieldNo("Intrastat Exclude CZL"), TransferHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag());
    end;

    local procedure UpgradeTransferReceiptHeader()
    var
        TransferReceiptHeader: Record "Transfer Receipt Header";
        DataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag()) then
            exit;

        DataTransfer.SetTables(Database::"Transfer Receipt Header", Database::"Transfer Receipt Header");
        DataTransfer.AddFieldValue(TransferReceiptHeader.FieldNo("Intrastat Exclude CZL"), TransferReceiptHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag());
    end;

    local procedure UpgradeTransferShipmentHeader()
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
        DataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag()) then
            exit;

        DataTransfer.SetTables(Database::"Transfer Shipment Header", Database::"Transfer Shipment Header");
        DataTransfer.AddFieldValue(TransferShipmentHeader.FieldNo("Intrastat Exclude CZL"), TransferShipmentHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag());
    end;

    local procedure UpgradeReturnReceiptHeader()
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
        DataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag()) then
            exit;

        DataTransfer.SetTables(Database::"Return Receipt Header", Database::"Return Receipt Header");
        DataTransfer.AddFieldValue(ReturnReceiptHeader.FieldNo("Intrastat Exclude CZL"), ReturnReceiptHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag());
    end;

    local procedure UpgradeReturnShipmentHeader()
    var
        ReturnShipmentHeader: Record "Return Shipment Header";
        DataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag()) then
            exit;

        DataTransfer.SetTables(Database::"Return Shipment Header", Database::"Return Shipment Header");
        DataTransfer.AddFieldValue(ReturnShipmentHeader.FieldNo("Intrastat Exclude CZL"), ReturnShipmentHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatExcludeUpgradeTag());
    end;

    local procedure UpgradeIntrastatDeliveryGroup()
    var
        IntrastatReportLine: Record "Intrastat Report Line";
        ShipmentMethod: Record "Shipment Method";
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
        DataExchFieldGrouping: Record "Data Exch. Field Grouping";
        NewDataExchFieldMapping: Record "Data Exch. Field Mapping";
        DataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatDeliveryGroupUpgradeTag()) then
            exit;

        DataTransfer.SetTables(Database::"Shipment Method", Database::"Intrastat Report Line");
        DataTransfer.AddFieldValue(ShipmentMethod.FieldNo("Intrastat Deliv. Grp. Code CZ"), IntrastatReportLine.FieldNo("Intrastat Delivery Group CZ"));
        DataTransfer.AddJoin(ShipmentMethod.FieldNo(Code), IntrastatReportLine.FieldNo("Shpt. Method Code"));
        DataTransfer.CopyFields();

        if DataExchFieldMapping.Get('INTRA-2022-CZ', 'DEFAULT', Database::"Intrastat Report Line", 11, IntrastatReportLine.FieldNo("Shpt. Method Code")) then begin
            NewDataExchFieldMapping.Init();
            NewDataExchFieldMapping := DataExchFieldMapping;
            DataExchFieldMapping.Delete();
            NewDataExchFieldMapping.Validate("Field ID", IntrastatReportLine.FieldNo("Intrastat Delivery Group CZ"));
            NewDataExchFieldMapping.Validate("Transformation Rule", '');
            NewDataExchFieldMapping.Insert();
        end;

        if DataExchFieldMapping.Get('INTRA-2022-CZ', 'DEFAULT', Database::"Intrastat Report Line", 15, IntrastatReportLine.FieldNo("Item Name")) then begin
            NewDataExchFieldMapping.Init();
            NewDataExchFieldMapping := DataExchFieldMapping;
            DataExchFieldMapping.Delete();
            NewDataExchFieldMapping.Validate("Field ID", IntrastatReportLine.FieldNo("Tariff Description"));
            NewDataExchFieldMapping.Insert();
        end;

        DataExchFieldGrouping.SetRange("Data Exch. Def Code", 'INTRA-2022-CZ');
        DataExchFieldGrouping.SetRange("Data Exch. Line Def Code", 'DEFAULT');
        DataExchFieldGrouping.SetRange("Table ID", Database::"Intrastat Report Line");
        if not DataExchFieldGrouping.IsEmpty() then begin
            if not DataExchFieldGrouping.Get('INTRA-2022-CZ', 'DEFAULT', Database::"Intrastat Report Line", IntrastatReportLine.FieldNo("Transport Method")) then begin
                DataExchFieldGrouping.Init();
                DataExchFieldGrouping."Data Exch. Def Code" := 'INTRA-2022-CZ';
                DataExchFieldGrouping."Data Exch. Line Def Code" := 'DEFAULT';
                DataExchFieldGrouping."Table ID" := Database::"Intrastat Report Line";
                DataExchFieldGrouping."Field ID" := IntrastatReportLine.FieldNo("Transport Method");
                DataExchFieldGrouping.Insert();
            end;

            if not DataExchFieldGrouping.Get('INTRA-2022-CZ', 'DEFAULT', Database::"Intrastat Report Line", IntrastatReportLine.FieldNo("Intrastat Delivery Group CZ")) then begin
                DataExchFieldGrouping.Init();
                DataExchFieldGrouping."Data Exch. Def Code" := 'INTRA-2022-CZ';
                DataExchFieldGrouping."Data Exch. Line Def Code" := 'DEFAULT';
                DataExchFieldGrouping."Table ID" := Database::"Intrastat Report Line";
                DataExchFieldGrouping."Field ID" := IntrastatReportLine.FieldNo("Intrastat Delivery Group CZ");
                DataExchFieldGrouping.Insert();
            end;
        end;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatDeliveryGroupUpgradeTag());
    end;

    local procedure UpgradeIntrastatDescription()
    var
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
        IntrastatReportLine: Record "Intrastat Report Line";
        TransformationRule: Record "Transformation Rule";
        IntrastatTransformationCZ: Codeunit "Intrastat Transformation CZ";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatDescriptionUpgradeTag()) then
            exit;

        if DataExchFieldMapping.Get('INTRA-2022-CZ', 'DEFAULT', Database::"Intrastat Report Line", 15, IntrastatReportLine.FieldNo("Tariff Description")) then begin
            TransformationRule.InsertRec(
                IntrastatTransformationCZ.GetIntrastatItemDescriptionCode(),
                IntrastatTransformationCZ.GetIntrastatItemDescriptionDescCode(),
                TransformationRule."Transformation Type"::Substring.AsInteger(), 1, 80, '', '');

            DataExchFieldMapping.Validate("Transformation Rule", IntrastatTransformationCZ.GetIntrastatItemDescriptionCode());
            DataExchFieldMapping.Modify();
        end;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZ.GetIntrastatDescriptionUpgradeTag());
    end;
}