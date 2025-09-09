// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ExciseTax;

using Microsoft.Foundation.Company;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.History;
using Microsoft.Inventory.Ledger;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Posting;

codeunit 6274 "Sust. Excise Cal. Mgt"
{
    Permissions = tabledata "Sust. Excise Jnl. Line" = ri;

    var
        SustainabilityExciseJnlBatch: Record "Sust. Excise Journal Batch";
        CalculationNotSupportedErr: Label 'Calculation not supported for Type %1.', Comment = '%1 = Calculation Type';

    internal procedure Calculate(JournalTemplateName: Code[10]; JournalBatchName: Code[10])
    begin
        SustainabilityExciseJnlBatch.Get(JournalTemplateName, JournalBatchName);

        case SustainabilityExciseJnlBatch.Type of
            SustainabilityExciseJnlBatch.Type::CBAM:
                CalculateForCBAM();
            SustainabilityExciseJnlBatch.Type::EPR:
                CalculateForEPR();
            else
                Error(CalculationNotSupportedErr, SustainabilityExciseJnlBatch.Type);
        end;
    end;

    local procedure CalculateForCBAM()
    var
        SustExciseJournalLine: Record "Sust. Excise Jnl. Line";
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        PurchInvLine.SetRange("CBAM Compliance", true);
        PurchInvLine.SetRange("CBAM Reported", false);
        PurchInvLine.SetRange(Type, PurchInvLine.Type::Item);
        PurchInvLine.SetFilter("No.", '<>%1', '');
        PurchInvLine.SetFilter("Sust. Account No.", '<>%1', '');
        if PurchInvLine.FindSet() then
            repeat
                if (not ExistSustExciseJournalLine(PurchInvLine."Document No.", PurchInvLine."Line No.")) and IsForeignVendor(PurchInvLine."Buy-from Vendor No.") then
                    InsertExciseJournalLineFromPurchaseInvoiceLine(SustExciseJournalLine, PurchInvLine);
            until PurchInvLine.Next() = 0;
    end;

    local procedure CalculateForEPR()
    var
        SustExciseJournalLine: Record "Sust. Excise Jnl. Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetFilter("Document Type", '%1|%2', ItemLedgerEntry."Document Type"::"Sales Invoice", ItemLedgerEntry."Document Type"::"Sales Shipment");
        ItemLedgerEntry.SetRange("EPR Reported", false);
        ItemLedgerEntry.SetFilter("Sust. Account No.", '<>%1', '');
        if ItemLedgerEntry.FindSet() then
            repeat
                if not ExistSustExciseJournalLine(ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.") then
                    InsertExciseJournalLineFromItemLedgerEntry(SustExciseJournalLine, ItemLedgerEntry);
            until ItemLedgerEntry.Next() = 0;
    end;

    local procedure InsertExciseJournalLineFromPurchaseInvoiceLine(var SustExciseJournalLine: Record "Sust. Excise Jnl. Line"; PurchInvLine: Record "Purch. Inv. Line")
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        NoSeriesBatch: Codeunit "No. Series - Batch";
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
        CO2eEmission: Decimal;
        CarbonFee: Decimal;
    begin
        SustExciseJournalLine.Init();
        SustExciseJournalLine.Validate("Journal Template Name", SustainabilityExciseJnlBatch."Journal Template Name");
        SustExciseJournalLine.Validate("Journal Batch Name", SustainabilityExciseJnlBatch.Name);
        SustExciseJournalLine.Validate("Line No.", SustExciseJournalLine.GetSustExciseJournalLineLastLineNo(SustainabilityExciseJnlBatch) + 10000);
        SustExciseJournalLine.Validate("Posting Date", WorkDate());
        SustExciseJournalLine.Validate("Entry Type", SustExciseJournalLine."Entry Type"::Purchase);
        SustExciseJournalLine.Validate("Document Type", SustExciseJournalLine."Document Type"::Invoice);
        SustExciseJournalLine.Validate("Document No.", NoSeriesBatch.GetNextNo(SustainabilityExciseJnlBatch."No Series", SustExciseJournalLine."Posting Date"));
        SustExciseJournalLine.Validate("Partner Type", SustExciseJournalLine."Partner Type"::Vendor);
        SustExciseJournalLine.Validate("Partner No.", PurchInvLine."Buy-from Vendor No.");
        SustExciseJournalLine.Validate("Source of Emission Data", PurchInvLine."Source of Emission Data");
        SustExciseJournalLine.Validate("Emission Verified", PurchInvLine."Emission Verified");
        SustExciseJournalLine.Validate("CBAM Compliance", PurchInvLine."CBAM Compliance");
        SustExciseJournalLine.Validate("Source Type", SustExciseJournalLine."Source Type"::Item);
        SustExciseJournalLine.Validate("Source No.", PurchInvLine."No.");
        SustExciseJournalLine.Validate("Source Unit of Measure Code", PurchInvLine."Unit of Measure Code");
        SustExciseJournalLine.Validate("Source Qty.", PurchInvLine.Quantity);
        SustExciseJournalLine.Validate("CO2e Unit of Measure", PurchInvLine."Unit of Measure Code");

        PurchInvHeader.Get(PurchInvLine."Document No.");
        SustExciseJournalLine.Validate("Country/Region Code", PurchInvHeader."Buy-from Country/Region Code");

        SustainabilityPostMgt.UpdateCarbonFeeEmissionValues("Emission Scope"::" ", SustExciseJournalLine."Posting Date", SustExciseJournalLine."Country/Region Code", PurchInvLine."Emission CO2", PurchInvLine."Emission N2O", PurchInvLine."Emission CH4", CO2eEmission, CarbonFee);
        SustExciseJournalLine.Validate("Total Embedded CO2e Emission", CO2eEmission);

        SustExciseJournalLine.Validate("Total Emission Cost", PurchInvLine."Total Emission Cost");
        SustExciseJournalLine.Validate("Source Document No.", PurchInvLine."Document No.");
        SustExciseJournalLine.Validate("Source Document Line No.", PurchInvLine."Line No.");
        SustExciseJournalLine.Validate("Reason Code", SustainabilityExciseJnlBatch."Reason Code");
        SustExciseJournalLine.Validate("Source Code", SustainabilityExciseJnlBatch."Source Code");
        SustExciseJournalLine.Validate("Calculated Date", Today());
        SustExciseJournalLine.Validate("Calculated By", UserId());
        SustExciseJournalLine.Validate("Dimension Set ID", PurchInvLine."Dimension Set ID");
        SustExciseJournalLine.Insert(true);
    end;

    local procedure InsertExciseJournalLineFromItemLedgerEntry(var SustExciseJournalLine: Record "Sust. Excise Jnl. Line"; ItemLedgerEntry: Record "Item Ledger Entry")
    var
        NoSeriesBatch: Codeunit "No. Series - Batch";
    begin
        SustExciseJournalLine.Init();
        SustExciseJournalLine.Validate("Journal Template Name", SustainabilityExciseJnlBatch."Journal Template Name");
        SustExciseJournalLine.Validate("Journal Batch Name", SustainabilityExciseJnlBatch.Name);
        SustExciseJournalLine.Validate("Line No.", SustExciseJournalLine.GetSustExciseJournalLineLastLineNo(SustainabilityExciseJnlBatch) + 10000);
        SustExciseJournalLine.Validate("Posting Date", WorkDate());
        SustExciseJournalLine.Validate("Entry Type", SustExciseJournalLine."Entry Type"::Sales);
        SustExciseJournalLine.Validate("Document Type", SustExciseJournalLine."Document Type"::Invoice);
        SustExciseJournalLine.Validate("Document No.", NoSeriesBatch.GetNextNo(SustainabilityExciseJnlBatch."No Series", SustExciseJournalLine."Posting Date"));
        SustExciseJournalLine.Validate("Partner Type", SustExciseJournalLine."Partner Type"::Customer);

        case ItemLedgerEntry."Document Type" of
            ItemLedgerEntry."Document Type"::"Sales Shipment":
                UpdateExciseJournalFromSalesShipment(SustExciseJournalLine, ItemLedgerEntry);
            ItemLedgerEntry."Document Type"::"Sales Invoice":
                UpdateExciseJournalFromSalesInvoice(SustExciseJournalLine, ItemLedgerEntry);
        end;

        SustExciseJournalLine.Validate("Source Document No.", ItemLedgerEntry."Document No.");
        SustExciseJournalLine.Validate("Source Document Line No.", ItemLedgerEntry."Document Line No.");
        SustExciseJournalLine.Validate("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
        SustExciseJournalLine.Validate("Reason Code", SustainabilityExciseJnlBatch."Reason Code");
        SustExciseJournalLine.Validate("Source Code", SustainabilityExciseJnlBatch."Source Code");
        SustExciseJournalLine.Validate("Calculated Date", Today());
        SustExciseJournalLine.Validate("Calculated By", UserId());
        SustExciseJournalLine.Validate("Dimension Set ID", ItemLedgerEntry."Dimension Set ID");
        SustExciseJournalLine.Insert(true);
    end;

    local procedure ExistSustExciseJournalLine(SourceDocumentNo: Code[20]; SourceDocumentLine: Integer): Boolean
    var
        SustExciseJournalLine: Record "Sust. Excise Jnl. Line";
    begin
        SustExciseJournalLine.SetRange("Source Document No.", SourceDocumentNo);
        SustExciseJournalLine.SetRange("Source Document Line No.", SourceDocumentLine);
        if not SustExciseJournalLine.IsEmpty then
            exit(true);
    end;

    local procedure UpdateExciseJournalFromSalesShipment(var SustExciseJournalLine: Record "Sust. Excise Jnl. Line"; ItemLedgerEntry: Record "Item Ledger Entry")
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        SalesShipmentHeader.SetLoadFields("Sell-to Customer No.", "Sell-to Country/Region Code");
        SalesShipmentHeader.Get(ItemLedgerEntry."Document No.");

        SalesShipmentLine.SetLoadFields("Unit of Measure Code", Quantity, "Total EPR Fee");
        SalesShipmentLine.Get(ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.");

        SustExciseJournalLine.Validate("Partner No.", SalesShipmentHeader."Sell-to Customer No.");
        SustExciseJournalLine.Validate("Country/Region Code", SalesShipmentHeader."Sell-to Country/Region Code");
        SustExciseJournalLine.Validate("Source Type", SustExciseJournalLine."Source Type"::Item);
        SustExciseJournalLine.Validate("Source No.", ItemLedgerEntry."Item No.");
        SustExciseJournalLine.Validate("Source Unit of Measure Code", SalesShipmentLine."Unit of Measure Code");
        SustExciseJournalLine.Validate("Source Qty.", SalesShipmentLine.Quantity);
        SustExciseJournalLine.Validate("Total Emission Cost", SalesShipmentLine."Total EPR Fee");
    end;

    local procedure UpdateExciseJournalFromSalesInvoice(var SustExciseJournalLine: Record "Sust. Excise Jnl. Line"; ItemLedgerEntry: Record "Item Ledger Entry")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceHeader.SetLoadFields("Sell-to Customer No.", "Sell-to Country/Region Code");
        SalesInvoiceHeader.Get(ItemLedgerEntry."Document No.");

        SalesInvoiceLine.SetLoadFields("Unit of Measure Code", Quantity, "Total EPR Fee");
        SalesInvoiceLine.Get(ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.");

        SustExciseJournalLine.Validate("Partner No.", SalesInvoiceHeader."Sell-to Customer No.");
        SustExciseJournalLine.Validate("Country/Region Code", SalesInvoiceHeader."Sell-to Country/Region Code");
        SustExciseJournalLine.Validate("Source Type", SustExciseJournalLine."Source Type"::Item);
        SustExciseJournalLine.Validate("Source No.", ItemLedgerEntry."Item No.");
        SustExciseJournalLine.Validate("Source Unit of Measure Code", SalesInvoiceLine."Unit of Measure Code");
        SustExciseJournalLine.Validate("Source Qty.", SalesInvoiceLine.Quantity);
        SustExciseJournalLine.Validate("Total Emission Cost", SalesInvoiceLine."Total EPR Fee");
    end;

    local procedure IsForeignVendor(VendorNo: Code[20]): Boolean
    var
        Vendor: Record Vendor;
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.SetLoadFields("Country/Region Code");
        CompanyInformation.Get();

        Vendor.SetLoadFields("Country/Region Code");
        Vendor.Get(VendorNo);

        exit(CompanyInformation."Country/Region Code" <> Vendor."Country/Region Code");
    end;
}