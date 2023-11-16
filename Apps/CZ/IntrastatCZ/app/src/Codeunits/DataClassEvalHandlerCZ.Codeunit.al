// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Foundation.Shipping;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Transfer;
using Microsoft.Projects.Project.Journal;
using Microsoft.Projects.Project.Ledger;
using Microsoft.Purchases.Archive;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Sales.Archive;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using Microsoft.Utilities;
using System.Environment;
using System.Privacy;

codeunit 31300 "Data Class. Eval. Handler CZ"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure ApplyEvaluationClassificationsForPrivacyOnAfterClassifyCountrySpecificTables()
    begin
        ApplyEvaluationClassificationsForPrivacy();
    end;

    procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
        DirectTransHeader: Record "Direct Trans. Header";
        DirectTransLine: Record "Direct Trans. Line";
        FixedAsset: Record "Fixed Asset";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportHeader: Record "Intrastat Report Header";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        Item: Record Item;
        ItemCharge: Record "Item Charge";
        ItemJournalLine: Record "Item Journal Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        JobJournalLine: Record "Job Journal Line";
        JobLedgerEntry: Record "Job Ledger Entry";
        PurchaseHeader: Record "Purchase Header";
        PurchaseHeaderArchive: Record "Purchase Header Archive";
        PurchaseLine: Record "Purchase Line";
        PurchaseLineArchive: Record "Purchase Line Archive";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        ReturnReceiptHeader: Record "Return Receipt Header";
        ReturnReceiptLine: Record "Return Receipt Line";
        ReturnShipmentHeader: Record "Return Shipment Header";
        ReturnShipmentLine: Record "Return Shipment Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesHeader: Record "Sales Header";
        SalesHeaderArchive: Record "Sales Header Archive";
        SalesLine: Record "Sales Line";
        SalesLineArchive: Record "Sales Line Archive";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceInvoiceLine: Record "Service Invoice Line";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceShipmentHeader: Record "Service Shipment Header";
        ServiceShipmentLine: Record "Service Shipment Line";
        ShipmentMethod: Record "Shipment Method";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        TransferReceiptHeader: Record "Transfer Receipt Header";
        TransferReceiptLine: Record "Transfer Receipt Line";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        TransferShipmentLine: Record "Transfer Shipment Line";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"Statistic Indication CZ");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Intrastat Delivery Group CZ");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Specific Movement CZ");

        DataClassificationMgt.SetFieldToNormal(Database::"Direct Trans. Header", DirectTransHeader.FieldNo("Intrastat Exclude CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Direct Trans. Line", DirectTransLine.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Fixed Asset", FixedAsset.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Fixed Asset", FixedAsset.FieldNo("Specific Movement CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Report Line", IntrastatReportLine.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Report Line", IntrastatReportLine.FieldNo("Specific Movement CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Report Line", IntrastatReportLine.FieldNo("Company VAT Reg. No. CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Report Line", IntrastatReportLine.FieldNo("Internal Note 1 CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Report Line", IntrastatReportLine.FieldNo("Internal Note 2 CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Report Header", IntrastatReportHeader.FieldNo("Statement Type CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Report Setup", IntrastatReportSetup.FieldNo("No Item Charges in Int. CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Report Setup", IntrastatReportSetup.FieldNo("Transaction Type Mandatory CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Report Setup", IntrastatReportSetup.FieldNo("Transaction Spec. Mandatory CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Report Setup", IntrastatReportSetup.FieldNo("Transport Method Mandatory CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Report Setup", IntrastatReportSetup.FieldNo("Shipment Method Mandatory CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Report Setup", IntrastatReportSetup.FieldNo("Intrastat Rounding Type CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Report Setup", IntrastatReportSetup.FieldNo("Def. Phys. Trans. - Returns CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::Item, Item.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::Item, Item.FieldNo("Specific Movement CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Charge", ItemCharge.FieldNo("Incl. in Intrastat Amount CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Journal Line", ItemJournalLine.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Journal Line", ItemJournalLine.FieldNo("Physical Transfer CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Ledger Entry", ItemLedgerEntry.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Ledger Entry", ItemLedgerEntry.FieldNo("Physical Transfer CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Job Journal Line", JobJournalLine.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Job Ledger Entry", JobLedgerEntry.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("Intrastat Exclude CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("Physical Transfer CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header Archive", PurchaseHeaderArchive.FieldNo("Intrastat Exclude CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header Archive", PurchaseHeaderArchive.FieldNo("Physical Transfer CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Line", PurchaseLine.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Line", PurchaseLine.FieldNo("Physical Transfer CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Line Archive", PurchaseLineArchive.FieldNo("Physical Transfer CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Cr. Memo Hdr.", PurchCrMemoHdr.FieldNo("Intrastat Exclude CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Cr. Memo Hdr.", PurchCrMemoHdr.FieldNo("Physical Transfer CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Cr. Memo Line", PurchCrMemoLine.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Inv. Header", PurchInvHeader.FieldNo("Intrastat Exclude CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Inv. Header", PurchInvHeader.FieldNo("Physical Transfer CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Inv. Line", PurchInvLine.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Rcpt. Header", PurchRcptHeader.FieldNo("Intrastat Exclude CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Rcpt. Header", PurchRcptHeader.FieldNo("Physical Transfer CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Rcpt. Line", PurchRcptLine.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Return Receipt Header", ReturnReceiptHeader.FieldNo("Intrastat Exclude CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Return Receipt Header", ReturnReceiptHeader.FieldNo("Physical Transfer CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Return Receipt Line", ReturnReceiptLine.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Return Shipment Header", ReturnShipmentHeader.FieldNo("Intrastat Exclude CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Return Shipment Header", ReturnShipmentHeader.FieldNo("Physical Transfer CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Return Shipment Line", ReturnShipmentLine.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Cr.Memo Header", SalesCrMemoHeader.FieldNo("Intrastat Exclude CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Cr.Memo Header", SalesCrMemoHeader.FieldNo("Physical Transfer CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Cr.Memo Line", SalesCrMemoLine.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header", SalesHeader.FieldNo("Intrastat Exclude CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header", SalesHeader.FieldNo("Physical Transfer CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header Archive", SalesHeaderArchive.FieldNo("Intrastat Exclude CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header Archive", SalesHeaderArchive.FieldNo("Physical Transfer CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Invoice Header", SalesInvoiceHeader.FieldNo("Intrastat Exclude CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Invoice Header", SalesInvoiceHeader.FieldNo("Physical Transfer CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Invoice Line", SalesInvoiceLine.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Line", SalesLine.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Line", SalesLine.FieldNo("Physical Transfer CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Line Archive", SalesLineArchive.FieldNo("Physical Transfer CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Shipment Header", SalesShipmentHeader.FieldNo("Intrastat Exclude CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Shipment Header", SalesShipmentHeader.FieldNo("Physical Transfer CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Shipment Line", SalesShipmentLine.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Cr.Memo Header", ServiceCrMemoHeader.FieldNo("Intrastat Exclude CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Cr.Memo Header", ServiceCrMemoHeader.FieldNo("Physical Transfer CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Cr.Memo Line", ServiceCrMemoLine.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Header", ServiceHeader.FieldNo("Intrastat Exclude CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Header", ServiceHeader.FieldNo("Physical Transfer CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Invoice Header", ServiceInvoiceHeader.FieldNo("Intrastat Exclude CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Invoice Header", ServiceInvoiceHeader.FieldNo("Physical Transfer CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Invoice Line", ServiceInvoiceLine.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Line", ServiceLine.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Line", ServiceLine.FieldNo("Physical Transfer CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Shipment Header", ServiceShipmentHeader.FieldNo("Intrastat Exclude CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Shipment Header", ServiceShipmentHeader.FieldNo("Physical Transfer CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Shipment Line", ServiceShipmentLine.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Shipment Method", ShipmentMethod.FieldNo("Intrastat Deliv. Grp. Code CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Shipment Method", ShipmentMethod.FieldNo("Incl. Item Charges (Amt.) CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Header", TransferHeader.FieldNo("Intrastat Exclude CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Line", TransferLine.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Receipt Header", TransferReceiptHeader.FieldNo("Intrastat Exclude CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Receipt Line", TransferReceiptLine.FieldNo("Statistic Indication CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Shipment Header", TransferShipmentHeader.FieldNo("Intrastat Exclude CZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Shipment Line", TransferShipmentLine.FieldNo("Statistic Indication CZ"));
    end;
}
