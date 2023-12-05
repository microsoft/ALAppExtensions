// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Shipping;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Transfer;
using Microsoft.Projects.Project.Journal;
using Microsoft.Projects.Project.Ledger;
using Microsoft.Purchases.Archive;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Archive;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Service.Document;
using Microsoft.Service.History;

codeunit 31301 "Install Application CZ"
{
    Subtype = Install;
    Permissions = tabledata "Item Journal Line" = m,
                  tabledata "Job Journal Line" = m,
                  tabledata "Purchase Header" = m,
                  tabledata "Purchase Header Archive" = m,
                  tabledata "Purchase Line" = m,
                  tabledata "Purchase Line Archive" = m,
                  tabledata "Purch. Cr. Memo Hdr." = m,
                  tabledata "Purch. Cr. Memo Line" = m,
                  tabledata "Purch. Inv. Header" = m,
                  tabledata "Purch. Inv. Line" = m,
                  tabledata "Purch. Rcpt. Header" = m,
                  tabledata "Purch. Rcpt. Line" = m,
                  tabledata "Sales Header" = m,
                  tabledata "Sales Header Archive" = m,
                  tabledata "Sales Line" = m,
                  tabledata "Sales Line Archive" = m,
                  tabledata "Sales Cr.Memo Header" = m,
                  tabledata "Sales Cr.Memo Line" = m,
                  tabledata "Sales Invoice Header" = m,
                  tabledata "Sales Invoice Line" = m,
                  tabledata "Sales Shipment Header" = m,
                  tabledata "Sales Shipment Line" = m,
                  tabledata Item = m,
                  tabledata "Item Charge" = m,
                  tabledata "Service Header" = m,
                  tabledata "Service Line" = m,
                  tabledata "Service Invoice Header" = m,
                  tabledata "Service Invoice Line" = m,
                  tabledata "Service Cr.Memo Header" = m,
                  tabledata "Service Cr.Memo Line" = m,
                  tabledata "Service Shipment Header" = m,
                  tabledata "Service Shipment Line" = m,
                  tabledata "Tariff Number" = m,
                  tabledata "Transfer Header" = m,
                  tabledata "Transfer Line" = m,
                  tabledata "Transfer Receipt Header" = m,
                  tabledata "Transfer Receipt Line" = m,
                  tabledata "Transfer Shipment Header" = m,
                  tabledata "Transfer Shipment Line" = m,
                  tabledata "Item Ledger Entry" = m,
                  tabledata "Job Ledger Entry" = m,
                  tabledata "Return Receipt Header" = m,
                  tabledata "Return Receipt Line" = m,
                  tabledata "Return Shipment Header" = m,
                  tabledata "Return Shipment Line" = m,
                  tabledata "Direct Trans. Header" = m,
                  tabledata "Direct Trans. Line" = m,
                  tabledata "Specific Movement CZ" = im,
                  tabledata "Specific Movement CZL" = r,
                  tabledata "Statistic Indication CZ" = im,
                  tabledata "Statistic Indication CZL" = im,
                  tabledata "Statutory Reporting Setup CZL" = r,
                  tabledata "Intrastat Report Setup" = im,
                  tabledata "Intrastat Delivery Group CZ" = im,
                  tabledata "Intrastat Delivery Group CZL" = r,
                  tabledata Customer = m,
                  tabledata Vendor = m;

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
            CopyData();
            UnbindSubscription(InstallApplicationsMgtCZL);
        end;
    end;

    local procedure InitializeDone(): boolean
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(AppInfo.DataVersion() <> Version.Create('0.0.0.0'));
    end;

    local procedure CopyPermission()
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Statistic Indication CZL", Database::"Statistic Indication CZ");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Intrastat Delivery Group CZL", Database::"Intrastat Delivery Group CZ");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Specific Movement CZL", Database::"Specific Movement CZ");
    end;

    local procedure CopyData()
    begin
        CopyCustomer();
        CopyDirectTransHeader();
        CopyDirectTransLine();
        CopyIntrastatDeliveryGroup();
        CopyItem();
        CopyItemCharge();
        CopyItemJournalLine();
        CopyItemLedgerEntry();
        CopyJobJournalLine();
        CopyJobLedgerEntry();
        CopyPurchaseHeader();
        CopyPurchaseHeaderArchive();
        CopyPurchaseLine();
        CopyPurchaseLineArchive();
        CopyPurchCrMemoHdr();
        CopyPurchCrMemoLine();
        CopyPurchInvHeader();
        CopyPurchInvLine();
        CopyPurchRcptHeader();
        CopyPurchRcptLine();
        CopyReturnReceiptHeader();
        CopyReturnReceiptLine();
        CopyReturnShipmentHeader();
        CopyReturnShipmentLine();
        CopySalesCrMemoHeader();
        CopySalesCrMemoLine();
        CopySalesInvoiceHeader();
        CopySalesInvoiceLine();
        CopySalesHeader();
        CopySalesHeaderArchive();
        CopySalesLine();
        CopySalesLineArchive();
        CopySalesShipmentHeader();
        CopySalesShipmentLine();
        CopyServiceHeader();
        CopyServiceLine();
        CopyServiceInvoiceHeader();
        CopyServiceInvoiceLine();
        CopyServiceCrMemoHeader();
        CopyServiceCrMemoLine();
        CopyServiceShipmentHeader();
        CopyServiceShipmentLine();
        CopyShipmentMethod();
        CopySpecificMovement();
        CopyStatisticIndication();
        CopyStatutoryReportingSetup();
        CopyTariffNumber();
        CopyTransferHeader();
        CopyTransferLine();
        CopyTransferReceiptHeader();
        CopyTransferReceiptLine();
        CopyTransferShipmentHeader();
        CopyTransferShipmentLine();
        CopyVendor();
    end;

    local procedure CopyCustomer()
    var
        Customer: Record Customer;
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Customer", Database::"Customer");
        DataTransfer.AddFieldValue(Customer.FieldNo("Transaction Type CZL"), Customer.FieldNo("Default Trans. Type"));
        DataTransfer.AddFieldValue(Customer.FieldNo("Transport Method CZL"), Customer.FieldNo("Def. Transport Method"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyDirectTransHeader()
    var
        DirectTransHeader: Record "Direct Trans. Header";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Direct Trans. Header", Database::"Direct Trans. Header");
        DataTransfer.AddFieldValue(DirectTransHeader.FieldNo("Intrastat Exclude CZL"), DirectTransHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyDirectTransLine()
    var
        DirectTransLine: Record "Direct Trans. Line";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Direct Trans. Line", Database::"Direct Trans. Line");
        DataTransfer.AddSourceFilter(DirectTransLine.FieldNo("Statistic Indication CZL"), '<>%1', '');
        DataTransfer.AddFieldValue(DirectTransLine.FieldNo("Statistic Indication CZL"), DirectTransLine.FieldNo("Statistic Indication CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyIntrastatDeliveryGroup()
    var
        IntrastatDeliveryGroupCZL: Record "Intrastat Delivery Group CZL";
        IntrastatDeliveryGroupCZ: Record "Intrastat Delivery Group CZ";
    begin
        if IntrastatDeliveryGroupCZL.FindSet() then
            repeat
                if not IntrastatDeliveryGroupCZ.Get(IntrastatDeliveryGroupCZL.Code) then begin
                    IntrastatDeliveryGroupCZ.Init();
                    IntrastatDeliveryGroupCZ.Code := IntrastatDeliveryGroupCZL.Code;
                    IntrastatDeliveryGroupCZ.SystemId := IntrastatDeliveryGroupCZL.SystemId;
                    IntrastatDeliveryGroupCZ.Insert(false, true);
                end;
                IntrastatDeliveryGroupCZ.Description := IntrastatDeliveryGroupCZL.Description;
                IntrastatDeliveryGroupCZ.Modify(false);
            until IntrastatDeliveryGroupCZL.Next() = 0;
    end;

    local procedure CopyItemJournalLine()
    var
        ItemJournalLine: Record "Item Journal Line";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Item Journal Line", Database::"Item Journal Line");
        DataTransfer.AddFieldValue(ItemJournalLine.FieldNo("Statistic Indication CZL"), ItemJournalLine.FieldNo("Statistic Indication CZ"));
        DataTransfer.AddFieldValue(ItemJournalLine.FieldNo("Physical Transfer CZL"), ItemJournalLine.FieldNo("Physical Transfer CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyJobJournalLine()
    var
        JobJournalLine: Record "Job Journal Line";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Job Journal Line", Database::"Job Journal Line");
        DataTransfer.AddSourceFilter(JobJournalLine.FieldNo("Statistic Indication CZL"), '<>%1', '');
        DataTransfer.AddFieldValue(JobJournalLine.FieldNo("Statistic Indication CZL"), JobJournalLine.FieldNo("Statistic Indication CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyPurchaseHeader()
    var
        PurchaseHeader: Record "Purchase Header";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Purchase Header", Database::"Purchase Header");
        DataTransfer.AddFieldValue(PurchaseHeader.FieldNo("Intrastat Exclude CZL"), PurchaseHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.AddFieldValue(PurchaseHeader.FieldNo("Physical Transfer CZL"), PurchaseHeader.FieldNo("Physical Transfer CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyPurchaseHeaderArchive()
    var
        PurchaseHeaderArchive: Record "Purchase Header Archive";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Purchase Header Archive", Database::"Purchase Header Archive");
        DataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("Intrastat Exclude CZL"), PurchaseHeaderArchive.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("Physical Transfer CZL"), PurchaseHeaderArchive.FieldNo("Physical Transfer CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyPurchaseLine()
    var
        PurchaseLine: Record "Purchase Line";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Purchase Line", Database::"Purchase Line");
        DataTransfer.AddFieldValue(PurchaseLine.FieldNo("Statistic Indication CZL"), PurchaseLine.FieldNo("Statistic Indication CZ"));
        DataTransfer.AddFieldValue(PurchaseLine.FieldNo("Physical Transfer CZL"), PurchaseLine.FieldNo("Physical Transfer CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyPurchaseLineArchive()
    var
        PurchaseLineArchive: Record "Purchase Line Archive";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Purchase Line Archive", Database::"Purchase Line Archive");
        DataTransfer.AddFieldValue(PurchaseLineArchive.FieldNo("Physical Transfer CZL"), PurchaseLineArchive.FieldNo("Physical Transfer CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyPurchCrMemoHdr()
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Purch. Cr. Memo Hdr.", Database::"Purch. Cr. Memo Hdr.");
        DataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Intrastat Exclude CZL"), PurchCrMemoHdr.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Physical Transfer CZL"), PurchCrMemoHdr.FieldNo("Physical Transfer CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyPurchCrMemoLine()
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Purch. Cr. Memo Line", Database::"Purch. Cr. Memo Line");
        DataTransfer.AddSourceFilter(PurchCrMemoLine.FieldNo("Statistic Indication CZL"), '<>%1', '');
        DataTransfer.AddFieldValue(PurchCrMemoLine.FieldNo("Statistic Indication CZL"), PurchCrMemoLine.FieldNo("Statistic Indication CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyPurchInvHeader()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Purch. Inv. Header", Database::"Purch. Inv. Header");
        DataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Intrastat Exclude CZL"), PurchInvHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Physical Transfer CZL"), PurchInvHeader.FieldNo("Physical Transfer CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyPurchInvLine()
    var
        PurchInvLine: Record "Purch. Inv. Line";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Purch. Inv. Line", Database::"Purch. Inv. Line");
        DataTransfer.AddSourceFilter(PurchInvLine.FieldNo("Statistic Indication CZL"), '<>%1', '');
        DataTransfer.AddFieldValue(PurchInvLine.FieldNo("Statistic Indication CZL"), PurchInvLine.FieldNo("Statistic Indication CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyPurchRcptHeader()
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Purch. Rcpt. Header", Database::"Purch. Rcpt. Header");
        DataTransfer.AddFieldValue(PurchRcptHeader.FieldNo("Intrastat Exclude CZL"), PurchRcptHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.AddFieldValue(PurchRcptHeader.FieldNo("Physical Transfer CZL"), PurchRcptHeader.FieldNo("Physical Transfer CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyPurchRcptLine()
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Purch. Rcpt. Line", Database::"Purch. Rcpt. Line");
        DataTransfer.AddSourceFilter(PurchRcptLine.FieldNo("Statistic Indication CZL"), '<>%1', '');
        DataTransfer.AddFieldValue(PurchRcptLine.FieldNo("Statistic Indication CZL"), PurchRcptLine.FieldNo("Statistic Indication CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopySalesCrMemoHeader()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Sales Cr.Memo Header", Database::"Sales Cr.Memo Header");
        DataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("Intrastat Exclude CZL"), SalesCrMemoHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("Physical Transfer CZL"), SalesCrMemoHeader.FieldNo("Physical Transfer CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopySalesCrMemoLine()
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Sales Cr.Memo Line", Database::"Sales Cr.Memo Line");
        DataTransfer.AddSourceFilter(SalesCrMemoLine.FieldNo("Statistic Indication CZL"), '<>%1', '');
        DataTransfer.AddFieldValue(SalesCrMemoLine.FieldNo("Statistic Indication CZL"), SalesCrMemoLine.FieldNo("Statistic Indication CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopySalesInvoiceHeader()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Sales Invoice Header", Database::"Sales Invoice Header");
        DataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("Intrastat Exclude CZL"), SalesInvoiceHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("Physical Transfer CZL"), SalesInvoiceHeader.FieldNo("Physical Transfer CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopySalesInvoiceLine()
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Sales Invoice Line", Database::"Sales Invoice Line");
        DataTransfer.AddSourceFilter(SalesInvoiceLine.FieldNo("Statistic Indication CZL"), '<>%1', '');
        DataTransfer.AddFieldValue(SalesInvoiceLine.FieldNo("Statistic Indication CZL"), SalesInvoiceLine.FieldNo("Statistic Indication CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopySalesHeader()
    var
        SalesHeader: Record "Sales Header";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Sales Header", Database::"Sales Header");
        DataTransfer.AddFieldValue(SalesHeader.FieldNo("Intrastat Exclude CZL"), SalesHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.AddFieldValue(SalesHeader.FieldNo("Physical Transfer CZL"), SalesHeader.FieldNo("Physical Transfer CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopySalesHeaderArchive()
    var
        SalesHeaderArchive: Record "Sales Header Archive";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Sales Header Archive", Database::"Sales Header Archive");
        DataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("Intrastat Exclude CZL"), SalesHeaderArchive.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("Physical Transfer CZL"), SalesHeaderArchive.FieldNo("Physical Transfer CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopySalesLine()
    var
        SalesLine: Record "Sales Line";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Sales Line", Database::"Sales Line");
        DataTransfer.AddFieldValue(SalesLine.FieldNo("Statistic Indication CZL"), SalesLine.FieldNo("Statistic Indication CZ"));
        DataTransfer.AddFieldValue(SalesLine.FieldNo("Physical Transfer CZL"), SalesLine.FieldNo("Physical Transfer CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopySalesLineArchive()
    var
        SalesLineArchive: Record "Sales Line Archive";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Sales Line Archive", Database::"Sales Line Archive");
        DataTransfer.AddFieldValue(SalesLineArchive.FieldNo("Physical Transfer CZL"), SalesLineArchive.FieldNo("Physical Transfer CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopySalesShipmentHeader()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Sales Shipment Header", Database::"Sales Shipment Header");
        DataTransfer.AddFieldValue(SalesShipmentHeader.FieldNo("Intrastat Exclude CZL"), SalesShipmentHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.AddFieldValue(SalesShipmentHeader.FieldNo("Physical Transfer CZL"), SalesShipmentHeader.FieldNo("Physical Transfer CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopySalesShipmentLine()
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Sales Shipment Line", Database::"Sales Shipment Line");
        DataTransfer.AddSourceFilter(SalesShipmentLine.FieldNo("Statistic Indication CZL"), '<>%1', '');
        DataTransfer.AddFieldValue(SalesShipmentLine.FieldNo("Statistic Indication CZL"), SalesShipmentLine.FieldNo("Statistic Indication CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyShipmentMethod();
    var
        ShipmentMethod: Record "Shipment Method";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Shipment Method", Database::"Shipment Method");
        DataTransfer.AddFieldValue(ShipmentMethod.FieldNo("Intrastat Deliv. Grp. Code CZL"), ShipmentMethod.FieldNo("Intrastat Deliv. Grp. Code CZ"));
        DataTransfer.AddFieldValue(ShipmentMethod.FieldNo("Incl. Item Charges (Amt.) CZL"), ShipmentMethod.FieldNo("Incl. Item Charges (Amt.) CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopySpecificMovement()
    var
        SpecificMovementCZL: Record "Specific Movement CZL";
        SpecificMovementCZ: Record "Specific Movement CZ";
    begin
        if SpecificMovementCZL.FindSet() then
            repeat
                if not SpecificMovementCZ.Get(SpecificMovementCZL.Code) then begin
                    SpecificMovementCZ.Init();
                    SpecificMovementCZ.Code := SpecificMovementCZL.Code;
                    SpecificMovementCZ.SystemId := SpecificMovementCZL.SystemId;
                    SpecificMovementCZ.Insert(false, true);
                end;
                SpecificMovementCZ.Description := SpecificMovementCZL.Description;
                SpecificMovementCZ.Modify(false);
            until SpecificMovementCZL.Next() = 0;
    end;

    local procedure CopyStatisticIndication()
    var
        StatisticIndicationCZL: Record "Statistic Indication CZL";
        StatisticIndicationCZ: Record "Statistic Indication CZ";
    begin
        if StatisticIndicationCZL.FindSet() then
            repeat
                if not StatisticIndicationCZ.Get(StatisticIndicationCZL."Tariff No.", StatisticIndicationCZL.Code) then begin
                    StatisticIndicationCZ.Init();
                    StatisticIndicationCZ."Tariff No." := StatisticIndicationCZL."Tariff No.";
                    StatisticIndicationCZ.Code := StatisticIndicationCZL.Code;
                    StatisticIndicationCZ.SystemId := StatisticIndicationCZL.SystemId;
                    StatisticIndicationCZ.Insert(false, true);
                end;
                StatisticIndicationCZ.Description := StatisticIndicationCZL.Description;
                StatisticIndicationCZ."Description EN" := CopyStr(StatisticIndicationCZL."Description EN", 1, MaxStrLen(StatisticIndicationCZ."Description EN"));
                StatisticIndicationCZL.Modify(false);
            until StatisticIndicationCZL.Next() = 0;
    end;

    local procedure CopyStatutoryReportingSetup()
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        if StatutoryReportingSetupCZL.Get() then begin
            if not IntrastatReportSetup.Get() then begin
                IntrastatReportSetup.Init();
                IntrastatReportSetup.Insert(false);
            end;

            IntrastatReportSetup."No Item Charges in Int. CZ" := StatutoryReportingSetupCZL."No Item Charges in Intrastat";
            IntrastatReportSetup."Transaction Type Mandatory CZ" := StatutoryReportingSetupCZL."Transaction Type Mandatory";
            IntrastatReportSetup."Transaction Spec. Mandatory CZ" := StatutoryReportingSetupCZL."Transaction Spec. Mandatory";
            IntrastatReportSetup."Transport Method Mandatory CZ" := StatutoryReportingSetupCZL."Transport Method Mandatory";
            IntrastatReportSetup."Shipment Method Mandatory CZ" := StatutoryReportingSetupCZL."Shipment Method Mandatory";
            IntrastatReportSetup."Intrastat Rounding Type CZ" := Enum::"Intrastat Rounding Type CZ".FromInteger(StatutoryReportingSetupCZL."Intrastat Rounding Type");
            IntrastatReportSetup.Modify(false);
        end;
    end;

    local procedure CopyItem()
    var
        Item: Record Item;
        ItemUnitofMeasure: Record "Item Unit of Measure";
        TariffNumber: Record "Tariff Number";
    begin
        if Item.FindSet() then
            repeat
                Item."Statistic Indication CZ" := Item."Statistic Indication CZL";
                Item."Specific Movement CZ" := Item."Specific Movement CZL";
                if Item."Tariff No." <> '' then
                    if TariffNumber.Get(Item."Tariff No.") then
                        if not (TariffNumber."Suppl. Unit of Meas. Code CZL" in ['', Item."Supplementary Unit of Measure"]) then
                            if ItemUnitofMeasure.Get(Item."No.", TariffNumber."Suppl. Unit of Meas. Code CZL") then
                                Item."Supplementary Unit of Measure" := ItemUnitofMeasure.Code;
                Item.Modify();
            until Item.Next() = 0;
    end;

    local procedure CopyItemCharge()
    var
        ItemCharge: Record "Item Charge";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Item Charge", Database::"Item Charge");
        DataTransfer.AddFieldValue(ItemCharge.FieldNo("Incl. in Intrastat Amount CZL"), ItemCharge.FieldNo("Incl. in Intrastat Amount CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyServiceHeader()
    var
        ServiceHeader: Record "Service Header";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Service Header", Database::"Service Header");
        DataTransfer.AddFieldValue(ServiceHeader.FieldNo("Intrastat Exclude CZL"), ServiceHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.AddFieldValue(ServiceHeader.FieldNo("Physical Transfer CZL"), ServiceHeader.FieldNo("Physical Transfer CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyServiceLine()
    var
        ServiceLine: Record "Service Line";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Service Line", Database::"Service Line");
        DataTransfer.AddFieldValue(ServiceLine.FieldNo("Statistic Indication CZL"), ServiceLine.FieldNo("Statistic Indication CZ"));
        DataTransfer.AddFieldValue(ServiceLine.FieldNo("Physical Transfer CZL"), ServiceLine.FieldNo("Physical Transfer CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyServiceInvoiceHeader()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Service Invoice Header", Database::"Service Invoice Header");
        DataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("Intrastat Exclude CZL"), ServiceInvoiceHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("Physical Transfer CZL"), ServiceInvoiceHeader.FieldNo("Physical Transfer CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyServiceInvoiceLine()
    var
        ServiceInvoiceLine: Record "Service Invoice Line";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Service Invoice Line", Database::"Service Invoice Line");
        DataTransfer.AddSourceFilter(ServiceInvoiceLine.FieldNo("Statistic Indication CZL"), '<>%1', '');
        DataTransfer.AddFieldValue(ServiceInvoiceLine.FieldNo("Statistic Indication CZL"), ServiceInvoiceLine.FieldNo("Statistic Indication CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyServiceCrMemoHeader()
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Service Cr.Memo Header", Database::"Service Cr.Memo Header");
        DataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("Intrastat Exclude CZL"), ServiceCrMemoHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("Physical Transfer CZL"), ServiceCrMemoHeader.FieldNo("Physical Transfer CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyServiceCrMemoLine()
    var
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Service Cr.Memo Line", Database::"Service Cr.Memo Line");
        DataTransfer.AddSourceFilter(ServiceCrMemoLine.FieldNo("Statistic Indication CZL"), '<>%1', '');
        DataTransfer.AddFieldValue(ServiceCrMemoLine.FieldNo("Statistic Indication CZL"), ServiceCrMemoLine.FieldNo("Statistic Indication CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyServiceShipmentHeader()
    var
        ServiceShipmentHeader: Record "Service Shipment Header";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Service Shipment Header", Database::"Service Shipment Header");
        DataTransfer.AddFieldValue(ServiceShipmentHeader.FieldNo("Intrastat Exclude CZL"), ServiceShipmentHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.AddFieldValue(ServiceShipmentHeader.FieldNo("Physical Transfer CZL"), ServiceShipmentHeader.FieldNo("Physical Transfer CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyServiceShipmentLine()
    var
        ServiceShipmentLine: Record "Service Shipment Line";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Service Shipment Line", Database::"Service Shipment Line");
        DataTransfer.AddSourceFilter(ServiceShipmentLine.FieldNo("Statistic Indication CZL"), '<>%1', '');
        DataTransfer.AddFieldValue(ServiceShipmentLine.FieldNo("Statistic Indication CZL"), ServiceShipmentLine.FieldNo("Statistic Indication CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyTariffNumber()
    var
        TariffNumber: Record "Tariff Number";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Tariff Number", Database::"Tariff Number");
        DataTransfer.AddSourceFilter(TariffNumber.FieldNo("Suppl. Unit of Meas. Code CZL"), '<>%1', '');
        DataTransfer.AddFieldValue(TariffNumber.FieldNo("Suppl. Unit of Meas. Code CZL"), TariffNumber.FieldNo("Suppl. Unit of Measure"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyTransferHeader()
    var
        TransferHeader: Record "Transfer Header";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Transfer Header", Database::"Transfer Header");
        DataTransfer.AddFieldValue(TransferHeader.FieldNo("Intrastat Exclude CZL"), TransferHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyTransferLine()
    var
        TransferLine: Record "Transfer Line";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Transfer Line", Database::"Transfer Line");
        DataTransfer.AddSourceFilter(TransferLine.FieldNo("Statistic Indication CZL"), '<>%1', '');
        DataTransfer.AddFieldValue(TransferLine.FieldNo("Statistic Indication CZL"), TransferLine.FieldNo("Statistic Indication CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyItemLedgerEntry()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Item Ledger Entry", Database::"Item Ledger Entry");
        DataTransfer.AddFieldValue(ItemLedgerEntry.FieldNo("Statistic Indication CZL"), ItemLedgerEntry.FieldNo("Statistic Indication CZ"));
        DataTransfer.AddFieldValue(ItemLedgerEntry.FieldNo("Physical Transfer CZL"), ItemLedgerEntry.FieldNo("Physical Transfer CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyJobLedgerEntry()
    var
        JobLedgerEntry: Record "Job Ledger Entry";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Job Ledger Entry", Database::"Job Ledger Entry");
        DataTransfer.AddSourceFilter(JobLedgerEntry.FieldNo("Statistic Indication CZL"), '<>%1', '');
        DataTransfer.AddFieldValue(JobLedgerEntry.FieldNo("Statistic Indication CZL"), JobLedgerEntry.FieldNo("Statistic Indication CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyTransferReceiptHeader()
    var
        TransferReceiptHeader: Record "Transfer Receipt Header";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Transfer Receipt Header", Database::"Transfer Receipt Header");
        DataTransfer.AddFieldValue(TransferReceiptHeader.FieldNo("Intrastat Exclude CZL"), TransferReceiptHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyTransferReceiptLine()
    var
        TransferReceiptLine: Record "Transfer Receipt Line";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Transfer Receipt Line", Database::"Transfer Receipt Line");
        DataTransfer.AddSourceFilter(TransferReceiptLine.FieldNo("Statistic Indication CZL"), '<>%1', '');
        DataTransfer.AddFieldValue(TransferReceiptLine.FieldNo("Statistic Indication CZL"), TransferReceiptLine.FieldNo("Statistic Indication CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyTransferShipmentHeader()
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Transfer Shipment Header", Database::"Transfer Shipment Header");
        DataTransfer.AddFieldValue(TransferShipmentHeader.FieldNo("Intrastat Exclude CZL"), TransferShipmentHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyTransferShipmentLine()
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Transfer Shipment Line", Database::"Transfer Shipment Line");
        DataTransfer.AddSourceFilter(TransferShipmentLine.FieldNo("Statistic Indication CZL"), '<>%1', '');
        DataTransfer.AddFieldValue(TransferShipmentLine.FieldNo("Statistic Indication CZL"), TransferShipmentLine.FieldNo("Statistic Indication CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyReturnReceiptHeader()
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Return Receipt Header", Database::"Return Receipt Header");
        DataTransfer.AddFieldValue(ReturnReceiptHeader.FieldNo("Intrastat Exclude CZL"), ReturnReceiptHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.AddFieldValue(ReturnReceiptHeader.FieldNo("Physical Transfer CZL"), ReturnReceiptHeader.FieldNo("Physical Transfer CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyReturnReceiptLine()
    var
        ReturnReceiptLine: Record "Return Receipt Line";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Return Receipt Line", Database::"Return Receipt Line");
        DataTransfer.AddSourceFilter(ReturnReceiptLine.FieldNo("Statistic Indication CZL"), '<>%1', '');
        DataTransfer.AddFieldValue(ReturnReceiptLine.FieldNo("Statistic Indication CZL"), ReturnReceiptLine.FieldNo("Statistic Indication CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyReturnShipmentHeader()
    var
        ReturnShipmentHeader: Record "Return Shipment Header";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Return Shipment Header", Database::"Return Shipment Header");
        DataTransfer.AddFieldValue(ReturnShipmentHeader.FieldNo("Intrastat Exclude CZL"), ReturnShipmentHeader.FieldNo("Intrastat Exclude CZ"));
        DataTransfer.AddFieldValue(ReturnShipmentHeader.FieldNo("Physical Transfer CZL"), ReturnShipmentHeader.FieldNo("Physical Transfer CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyReturnShipmentLine()
    var
        ReturnShipmentLine: Record "Return Shipment Line";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Return Shipment Line", Database::"Return Shipment Line");
        DataTransfer.AddSourceFilter(ReturnShipmentLine.FieldNo("Statistic Indication CZL"), '<>%1', '');
        DataTransfer.AddFieldValue(ReturnShipmentLine.FieldNo("Statistic Indication CZL"), ReturnShipmentLine.FieldNo("Statistic Indication CZ"));
        DataTransfer.CopyFields();
    end;

    local procedure CopyVendor()
    var
        Vendor: Record Vendor;
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::Vendor, Database::Vendor);
        DataTransfer.AddFieldValue(Vendor.FieldNo("Transaction Type CZL"), Vendor.FieldNo("Default Trans. Type"));
        DataTransfer.AddFieldValue(Vendor.FieldNo("Transport Method CZL"), Vendor.FieldNo("Def. Transport Method"));
        DataTransfer.CopyFields();
    end;
}