// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Bank.Payment;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.FixedAssets.Ledger;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item.Catalog;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Transfer;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Ledger;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using Microsoft.Sales.Setup;
using Microsoft.Service.History;
using System.IO;
using System.Text;
using System.Utilities;

codeunit 148121 "Intrastat Report Management IT"
{
    Access = Internal;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeInitSetup', '', true, true)]
    local procedure OnBeforeInitSetup(var IntrastatReportSetup: Record "Intrastat Report Setup"; var IsHandled: Boolean)
    begin
        IsHandled := true;

        IntrastatReportSetup."Shipments Based On" := IntrastatReportSetup."Shipments Based On"::"Ship-to Country";
        IntrastatReportSetup."Def. Private Person VAT No." := DefPrivatePersonVATNoLbl;
        IntrastatReportSetup."Def. 3-Party Trade VAT No." := Def3DPartyTradeVATNoLbl;
        IntrastatReportSetup."Def. VAT for Unknown State" := DefUnknowVATNoLbl;
        IntrastatReportSetup."Report Receipts" := true;
        IntrastatReportSetup."Report Shipments" := true;
        IntrastatReportSetup.Modify();

        CreateDefaultDataExchangeDef();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeInitCheckList', '', true, true)]
    local procedure OnBeforeInitCheckList(var IsHandled: Boolean)
    var
        IntrastatReportChecklist: Record "Intrastat Report Checklist";
    begin
        IsHandled := true;

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 5);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 7);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 8);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 9);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 12);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 14);
        IntrastatReportChecklist.Validate("Filter Expression", 'Supplementary Units: True');
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 21);
        IntrastatReportChecklist.Validate("Filter Expression", 'Supplementary Units: False');
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 24);
        IntrastatReportChecklist.Validate("Filter Expression", 'Type: Shipment');
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 25);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 26);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 27);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 29);
        IntrastatReportChecklist.Validate("Filter Expression", 'Type: Shipment');
        IntrastatReportChecklist.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeExportIntrastatHeader', '', true, true)]
    local procedure OnBeforeExportIntrastatHeader(var IntrastatReportHeader: Record "Intrastat Report Header"; var IsHandled: Boolean)
    var
        DataExch: Record "Data Exch.";
        TempBlob: Codeunit "Temp Blob";
        DataExchangeDefinitionCode: Code[20];
        FileName: Text;
        ReceptFileName: Text;
        ShipmentFileName: Text;
        ZipFileName: Text;
    begin
        SetIntrastatHeader(IntrastatReportHeader);

        if IntrastatReportHeader.Reported then
            if not Confirm(PeriodAlreadyReportedQst) then
                exit;

        IsHandled := false;
        OnBeforeDefineFileNamesIT(IntrastatReportHeader, FileName, ReceptFileName, ShipmentFileName, ZipFileName, IsHandled);
        if not IsHandled then
            FileName := FileNameLbl;

        IntrastatReportSetup.Get();

        case true of
            (IntrastatReportHeader.Periodicity = IntrastatReportHeader.Periodicity::Month) and
            (IntrastatReportHeader.Type = IntrastatReportHeader.Type::Purchases) and
            not IntrastatReportHeader."Corrective Entry":
                DataExchangeDefinitionCode := IntrastatReportSetup."Data Exch. Def. Code NPM";

            (IntrastatReportHeader.Periodicity = IntrastatReportHeader.Periodicity::Month) and
            (IntrastatReportHeader.Type = IntrastatReportHeader.Type::Sales) and
            not IntrastatReportHeader."Corrective Entry":
                DataExchangeDefinitionCode := IntrastatReportSetup."Data Exch. Def. Code NSM";

            (IntrastatReportHeader.Periodicity = IntrastatReportHeader.Periodicity::Quarter) and
            (IntrastatReportHeader.Type = IntrastatReportHeader.Type::Purchases) and
            not IntrastatReportHeader."Corrective Entry":
                DataExchangeDefinitionCode := IntrastatReportSetup."Data Exch. Def. Code NPQ";

            (IntrastatReportHeader.Periodicity = IntrastatReportHeader.Periodicity::Quarter) and
            (IntrastatReportHeader.Type = IntrastatReportHeader.Type::Sales) and
            not IntrastatReportHeader."Corrective Entry":
                DataExchangeDefinitionCode := IntrastatReportSetup."Data Exch. Def. Code NSQ";

            (IntrastatReportHeader.Periodicity = IntrastatReportHeader.Periodicity::Month) and
            (IntrastatReportHeader.Type = IntrastatReportHeader.Type::Purchases) and
            IntrastatReportHeader."Corrective Entry":
                DataExchangeDefinitionCode := IntrastatReportSetup."Data Exch. Def. Code CPM";

            (IntrastatReportHeader.Periodicity = IntrastatReportHeader.Periodicity::Month) and
            (IntrastatReportHeader.Type = IntrastatReportHeader.Type::Sales) and
            IntrastatReportHeader."Corrective Entry":
                DataExchangeDefinitionCode := IntrastatReportSetup."Data Exch. Def. Code CSM";

            (IntrastatReportHeader.Periodicity = IntrastatReportHeader.Periodicity::Quarter) and
            (IntrastatReportHeader.Type = IntrastatReportHeader.Type::Purchases) and
            IntrastatReportHeader."Corrective Entry":
                DataExchangeDefinitionCode := IntrastatReportSetup."Data Exch. Def. Code CPQ";

            (IntrastatReportHeader.Periodicity = IntrastatReportHeader.Periodicity::Quarter) and
            (IntrastatReportHeader.Type = IntrastatReportHeader.Type::Sales) and
            IntrastatReportHeader."Corrective Entry":
                DataExchangeDefinitionCode := IntrastatReportSetup."Data Exch. Def. Code CSQ";
        end;

        IntrastatReportMgt.ExportOneDataExchangeDef(IntrastatReportHeader, DataExchangeDefinitionCode, IntrastatReportHeader.Type.AsInteger() + 1, DataExch);
        DataExch.CalcFields("File Content");
        IntrastatReportHeader.Validate("Dispatches Reported", true);
        IntrastatReportHeader.Validate("Arrivals Reported", true);

        if DataExch."File Content".HasValue then begin
            TempBlob.FromRecord(DataExch, DataExch.FieldNo("File Content"));
            IntrastatReportMgt.ExportToFile(DataExch, TempBlob, FileName);
        end;

        IntrastatReportHeader."Export Date" := Today;
        IntrastatReportHeader."Export Time" := Time;
        IntrastatReportHeader.Modify();

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Intrastat Report Get Lines", 'OnAfterInitRequestPage', '', true, true)]
    local procedure OnAfterInitRequestPage(var IntrastatReportHeader: Record "Intrastat Report Header"; var AmountInclItemCharges: Boolean; var StartDate: Date; var EndDate: Date; var CostRegulationEnable: Boolean);
    var
        Century, Year, Quarter, Month : Integer;
    begin
        IntrastatReportHeader.TestField("Statistics Period");
        Century := Date2DMY(WorkDate(), 3) div 100;
        Evaluate(Year, CopyStr(IntrastatReportHeader."Statistics Period", 1, 2));
        Year := Year + Century * 100;

        if IntrastatReportHeader.Periodicity = IntrastatReportHeader.Periodicity::Month then begin
            Evaluate(Month, CopyStr(IntrastatReportHeader."Statistics Period", 3, 2));
            StartDate := DMY2Date(1, Month, Year);
        end else begin
            Evaluate(Quarter, CopyStr(IntrastatReportHeader."Statistics Period", 4, 1));
            StartDate := CalcDate(StrSubstNo('<+%1Q>', Quarter - 1), DMY2Date(1, 1, Year));
        end;

        case IntrastatReportHeader.Periodicity of
            IntrastatReportHeader.Periodicity::Month:
                EndDate := CalcDate('<+1M-1D>', StartDate);
            IntrastatReportHeader.Periodicity::Quarter:
                EndDate := CalcDate('<+1Q-1D>', StartDate);
            IntrastatReportHeader.Periodicity::Year:
                EndDate := CalcDate('<+1Y-1D>', StartDate);
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Intrastat Report Get Lines", 'OnBeforeFilterItemLedgerEntry', '', true, true)]
    local procedure OnBeforeFilterItemLedgerEntry(IntrastatReportHeader: Record "Intrastat Report Header"; var ItemLedgerEntry: Record "Item Ledger Entry"; StartDate: Date; EndDate: Date; var IsHandled: Boolean)
    begin
        ItemLedgerEntry.SetRange("Last Invoice Date", StartDate, EndDate);
        ItemLedgerEntry.SetFilter("Invoiced Quantity", '<>%1', 0);

        if IntrastatReportHeader.Type = IntrastatReportHeader.Type::Purchases then
            ItemLedgerEntry.SetFilter("Entry Type", '%1|%2', ItemLedgerEntry."Entry Type"::Purchase, ItemLedgerEntry."Entry Type"::Transfer)
        else
            ItemLedgerEntry.SetFilter("Entry Type", '%1|%2', ItemLedgerEntry."Entry Type"::Sale, ItemLedgerEntry."Entry Type"::Transfer);

        if not IntrastatReportHeader."Corrective Entry" then
            ItemLedgerEntry.SetFilter("Document Type", '<>%1&<>%2&<>%3&<>%4&<>%5',
                ItemLedgerEntry."Document Type"::"Sales Return Receipt", ItemLedgerEntry."Document Type"::"Sales Credit Memo",
                ItemLedgerEntry."Document Type"::"Purchase Return Shipment", ItemLedgerEntry."Document Type"::"Purchase Credit Memo",
                ItemLedgerEntry."Document Type"::"Service Credit Memo")
        else
            ItemLedgerEntry.SetFilter("Document Type", '<>%1&<>%2&<>%3&<>%4&<>%5&<>%6&<>%7&<>%8',
                ItemLedgerEntry."Document Type"::"Sales Shipment", ItemLedgerEntry."Document Type"::"Sales Invoice",
                ItemLedgerEntry."Document Type"::"Purchase Receipt", ItemLedgerEntry."Document Type"::"Purchase Invoice",
                ItemLedgerEntry."Document Type"::"Transfer Shipment", ItemLedgerEntry."Document Type"::"Transfer Receipt",
                ItemLedgerEntry."Document Type"::"Service Shipment", ItemLedgerEntry."Document Type"::"Service Invoice");

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Intrastat Report Get Lines", 'OnBeforeFilterValueEntry', '', true, true)]
    local procedure OnBeforeFilterValueEntry(IntrastatReportHeader: Record "Intrastat Report Header"; var ValueEntry: Record "Value Entry"; ItemLedgerEntry: Record "Item Ledger Entry"; StartDate: Date; EndDate: Date; var IsHandled: Boolean)
    begin
        ValueEntry.SetCurrentKey("Item Ledger Entry No.");
        ValueEntry.SetRange("Posting Date", StartDate, EndDate);
        ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
        ValueEntry.SetFilter("Invoiced Quantity", '<>%1', 0);
        ValueEntry.SetFilter("Item Ledger Entry Type", '%1|%2|%3', "Item Ledger Entry Type"::Sale, "Item Ledger Entry Type"::Purchase, "Item Ledger Entry Type"::Transfer);

        IsHandled := true;
    end;

#if not CLEAN24
    [Obsolete('Generates false quantity in a period where an item is not moved', '24.0')]
    [EventSubscriber(ObjectType::Report, Report::"Intrastat Report Get Lines", 'OnAfterValueEntryOnPreDataItem', '', true, true)]
    local procedure OnAfterValueEntryOnPreDataItem(IntrastatReportHeader: Record "Intrastat Report Header"; var ValueEntry: Record "Value Entry"; var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
        if not IntrastatReportHeader."Corrective Entry" then
            ValueEntry.SetFilter("Document Type", '<>%1&<>%2&<>%3&<>%4&<>%5',
                ValueEntry."Document Type"::"Sales Return Receipt", ValueEntry."Document Type"::"Sales Credit Memo",
                ValueEntry."Document Type"::"Purchase Return Shipment", ValueEntry."Document Type"::"Purchase Credit Memo",
                ValueEntry."Document Type"::"Service Credit Memo")
        else
            ValueEntry.SetFilter("Document Type", '<>%1&<>%2&<>%3&<>%4&<>%5&<>%6&<>%7&<>%8',
                ValueEntry."Document Type"::"Sales Shipment", ValueEntry."Document Type"::"Sales Invoice",
                ValueEntry."Document Type"::"Purchase Receipt", ValueEntry."Document Type"::"Purchase Invoice",
                ValueEntry."Document Type"::"Transfer Shipment", ValueEntry."Document Type"::"Transfer Receipt",
                ValueEntry."Document Type"::"Service Shipment", ValueEntry."Document Type"::"Service Invoice");

        if IntrastatReportHeader.Type = IntrastatReportHeader.Type::Purchases then
            ValueEntry.SetFilter("Item Ledger Entry Type", '%1|%2', "Item Ledger Entry Type"::Purchase, "Item Ledger Entry Type"::Transfer)
        else
            ValueEntry.SetRange("Item Ledger Entry Type", "Item Ledger Entry Type"::Sale);
    end;
#endif

    [EventSubscriber(ObjectType::Report, Report::"Intrastat Report Get Lines", 'OnBeforeCheckDropShipment', '', true, true)]
    local procedure OnBeforeCheckDropShipment(IntrastatReportHeader: Record "Intrastat Report Header"; ItemLedgerEntry: Record "Item Ledger Entry"; Country: Record "Country/Region"; var Result: Boolean; var IsHandled: Boolean)
    var
        CompanyInfo: Record "Company Information";
        ItemLedgEntry2: Record "Item Ledger Entry";
    begin
        IsHandled := true;
        Result := false;

        CompanyInfo.Get();
        if Country.Code in [CompanyInfo."Country/Region Code", ''] then
            Result := IntrastatReportHeader."Include Community Entries";

        if ItemLedgerEntry."Applies-to Entry" = 0 then begin
            ItemLedgEntry2.SetCurrentKey("Item No.", "Posting Date");
            ItemLedgEntry2.SetRange("Item No.", ItemLedgerEntry."Item No.");
            ItemLedgEntry2.SetRange("Posting Date", ItemLedgerEntry."Posting Date");
            ItemLedgEntry2.SetRange("Applies-to Entry", ItemLedgerEntry."Entry No.");
            ItemLedgEntry2.FindFirst();
        end else
            ItemLedgEntry2.Get(ItemLedgerEntry."Applies-to Entry");

        if not (IntrastatReportMgt.GetIntrastatBaseCountryCode(ItemLedgEntry2) in [CompanyInfo."Country/Region Code", '']) then
            Result := IntrastatReportHeader."Include Community Entries";
    end;

    [EventSubscriber(ObjectType::Report, Report::"Intrastat Report Get Lines", 'OnAfterCheckItemLedgerEntry', '', true, true)]
    local procedure OnAfterCheckItemLedgerEntry(IntrastatReportHeader: Record "Intrastat Report Header"; ItemLedgerEntry: Record "Item Ledger Entry"; var CurrReportSkip: Boolean)
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo.Get();
        CurrReportSkip := (ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::Sale) and
            SalesShipmentHeader.Get(ItemLedgerEntry."Document No.") and
            (CompanyInfo."Country/Region Code" = SalesShipmentHeader."Bill-to Country/Region Code");
    end;

    [EventSubscriber(ObjectType::Report, Report::"Intrastat Report Get Lines", 'OnBeforeCalculateTotalsCall', '', true, true)]
    local procedure OnBeforeCalculateTotalsCall(IntrastatReportHeader: Record "Intrastat Report Header"; var IntrastatReportLine: Record "Intrastat Report Line"; var ValueEntry: Record "Value Entry"; var ItemLedgerEntry: Record "Item Ledger Entry";
        StartDate: Date; EndDate: Date; SkipZeroAmounts: Boolean; AddCurrencyFactor: Decimal; IndirectCostPctReq: Decimal; var CurrReportSkip: Boolean; var IsHandled: Boolean)
    var
        IntrastatReportLine2: Record "Intrastat Report Line";
    begin
        GLSetup.Get();
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
        if ValueEntry.FindSet() then
            repeat
                CalculateTotals(IntrastatReportHeader, ValueEntry, ItemLedgerEntry, StartDate, EndDate, AddCurrencyFactor, CurrReportSkip);

                if not CurrReportSkip then
                    if (TotalAmt <> 0) or (not SkipZeroAmounts) then
                        if ValueEntry."Item Ledger Entry Type" = ValueEntry."Item Ledger Entry Type"::Transfer then
                            InsertItemLedgerLine(IntrastatReportHeader, IntrastatReportLine, ValueEntry, ItemLedgerEntry, IndirectCostPctReq)
                        else begin
                            IntrastatReportLine2.Reset();
                            IntrastatReportLine2.SetRange("Item No.", ItemLedgerEntry."Item No.");
                            IntrastatReportLine2.SetRange("Document No.", ValueEntry."Document No.");
                            if IntrastatReportLine2.IsEmpty() then
                                InsertItemLedgerLine(IntrastatReportHeader, IntrastatReportLine, ValueEntry, ItemLedgerEntry, IndirectCostPctReq);
                        end;
            until (ValueEntry.Next() = 0) or CurrReportSkip;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Intrastat Report Get Lines", 'OnBeforeInsertItemLedgerLineCall', '', true, true)]
    local procedure OnBeforeInsertItemLedgerLineCall(IntrastatReportHeader: Record "Intrastat Report Header"; var IntrastatReportLine: Record "Intrastat Report Line"; var ValueEntry: Record "Value Entry"; var ItemLedgerEntry: Record "Item Ledger Entry"; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Intrastat Report Get Lines", 'OnBeforeInsertJobLedgerLine', '', true, true)]
    local procedure OnBeforeInsertJobLedgerLine(var IntrastatReportLine: Record "Intrastat Report Line"; JobLedgerEntry: Record "Job Ledger Entry"; var IsHandled: Boolean)
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
    begin
        IntrastatReportHeader.Get(IntrastatReportLine."Intrastat No.");
        IntrastatReportLine."Corrected Intrastat Report No." := IntrastatReportHeader."Corrected Intrastat Rep. No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payment Export Mgt", 'OnBeforeFormatToText', '', true, true)]
    local procedure OnBeforeFormatToText(ValueToFormat: Variant; DataExchDef: Record "Data Exch. Def"; DataExchColumnDef: Record "Data Exch. Column Def"; var ResultText: Text[250]; var IsHandled: Boolean)
    begin
        IsHandled := true;

        if (Format(ValueToFormat) = '0') and (DataExchColumnDef."Blank Zero") then
            ResultText := ''
        else
            if DataExchColumnDef."Data Format" <> '' then
                ResultText := Format(ValueToFormat, 0, DataExchColumnDef."Data Format")
            else
                if DataExchDef."File Type" in [DataExchDef."File Type"::Xml, DataExchDef."File Type"::Json] then
                    ResultText := Format(ValueToFormat, 0, 9)
                else
                    ResultText := Format(ValueToFormat);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payment Export Mgt", 'OnProcessColumnMappingOnBeforeCheckLength', '', true, true)]
    local procedure OnProcessColumnMappingOnBeforeCheckLength(var ValueAsString: Text[250]; DataExchFieldMapping: Record "Data Exch. Field Mapping"; DataExchColumnDef: Record "Data Exch. Column Def")
    var
        StringConversionManagement: Codeunit StringConversionManagement;
    begin
        if DataExchColumnDef."Text Padding Required" and (DataExchColumnDef."Pad Character" <> '') and (not DataExchColumnDef."Blank Zero") then
            ValueAsString :=
                StringConversionManagement.GetPaddedString(
                    ValueAsString,
                    DataExchColumnDef.Length,
                    DataExchColumnDef."Pad Character",
                    DataExchColumnDef.Justification);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeCreateDefaultDataExchangeDef', '', true, true)]
    local procedure OnBeforeCreateDefaultDataExchangeDef(var IsHandled: Boolean);
    begin
        CreateDefaultDataExchangeDef();
        IsHandled := true;
    end;

    local procedure CalculateTotals(IntrastatReportHeader: Record "Intrastat Report Header"; var ValueEntry: Record "Value Entry"; var ItemLedgerEntry: Record "Item Ledger Entry"; StartDate: Date; EndDate: Date; AddCurrencyFactor: Decimal; var CurrReportSkip: Boolean)
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesShipLine: Record "Sales Shipment Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ServiceInvoiceLine: Record "Service Invoice Line";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceShipLine: Record "Service Shipment Line";
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        TotalCostAmt: Decimal;
        DocItemSum: Decimal;
        CorrectionFound: Boolean;
    begin
        TotalInvoicedQty := 0;
        TotalAmt := 0;
        DocItemSum := 0;
        CorrectionFound := false;

        if not ((ValueEntry."Item Charge No." <> '') and ((ValueEntry."Posting Date" > EndDate) or (ValueEntry."Posting Date" < StartDate))) then
            case ValueEntry."Item Ledger Entry Type" of
                ValueEntry."Item Ledger Entry Type"::Purchase:
                    begin
                        if ValueEntry."Invoiced Quantity" > 0 then begin
                            PurchInvLine.SetRange("Document No.", ValueEntry."Document No.");
                            PurchInvLine.SetRange(Type, PurchInvLine.Type::Item);
                            PurchInvLine.SetRange("No.", ValueEntry."Item No.");
                            if PurchInvLine.FindSet() then begin
                                PurchInvHeader.Get(ValueEntry."Document No.");
                                repeat
                                    TotalInvoicedQty += PurchInvLine.Quantity;
                                    if PurchInvHeader."Currency Factor" <> 0 then
                                        TotalAmt += PurchInvLine.Amount / PurchInvHeader."Currency Factor"
                                    else
                                        TotalAmt += PurchInvLine.Amount;
                                until PurchInvLine.Next() = 0;
                            end else begin
                                PurchRcptLine.SetRange("Document No.", ValueEntry."Document No.");
                                PurchRcptLine.SetRange(Type, PurchRcptLine.Type::Item);
                                PurchRcptLine.SetRange("No.", ValueEntry."Item No.");
                                if PurchRcptLine.FindSet() then begin
                                    repeat
                                        if PurchRcptLine.Correction then
                                            CorrectionFound := true;
                                        DocItemSum += PurchRcptLine."Quantity Invoiced";
                                    until PurchRcptLine.Next() = 0;
                                    if (DocItemSum = 0) and CorrectionFound then
                                        CurrReportSkip := true;
                                end;
                            end;
                        end else begin
                            PurchCrMemoLine.SetRange("Document No.", ValueEntry."Document No.");
                            PurchCrMemoLine.SetRange(Type, PurchInvLine.Type::Item);
                            PurchCrMemoLine.SetRange("No.", ValueEntry."Item No.");
                            if PurchCrMemoLine.FindSet() then begin
                                PurchCrMemoHdr.Get(ValueEntry."Document No.");
                                repeat
                                    TotalInvoicedQty -= PurchCrMemoLine.Quantity;
                                    if PurchCrMemoHdr."Currency Factor" <> 0 then
                                        TotalAmt -= PurchCrMemoLine.Amount / PurchCrMemoHdr."Currency Factor"
                                    else
                                        TotalAmt -= PurchCrMemoLine.Amount;
                                until PurchCrMemoLine.Next() = 0;
                            end else begin
                                PurchRcptLine.SetRange("Document No.", ValueEntry."Document No.");
                                PurchRcptLine.SetRange(Type, PurchRcptLine.Type::Item);
                                PurchRcptLine.SetRange("No.", ValueEntry."Item No.");
                                if PurchRcptLine.FindSet() then begin
                                    repeat
                                        if PurchRcptLine.Correction then
                                            CorrectionFound := true;
                                        DocItemSum += PurchRcptLine."Quantity Invoiced";
                                    until PurchRcptLine.Next() = 0;
                                    if (DocItemSum = 0) and CorrectionFound then
                                        CurrReportSkip := true;
                                end;
                            end;
                        end;
                        if IntrastatReportHeader."Amounts in Add. Currency" then
                            TotalAmt := CurrExchRate.ExchangeAmtLCYToFCY(
                                ValueEntry."Posting Date", GLSetup."Additional Reporting Currency",
                                TotalAmt, AddCurrencyFactor);
                    end;
                ValueEntry."Item Ledger Entry Type"::Sale:
                    begin
                        if (ValueEntry."Invoiced Quantity" < 0) and (ValueEntry."Order Type" = ValueEntry."Order Type"::" ") then begin
                            SalesInvoiceLine.SetRange("Document No.", ValueEntry."Document No.");
                            SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
                            SalesInvoiceLine.SetRange("No.", ValueEntry."Item No.");
                            if SalesInvoiceLine.FindSet() then begin
                                SalesInvoiceHeader.Get(ValueEntry."Document No.");
                                repeat
                                    TotalInvoicedQty -= SalesInvoiceLine.Quantity;
                                    if SalesInvoiceHeader."Currency Factor" <> 0 then
                                        TotalAmt -= SalesInvoiceLine.Amount / SalesInvoiceHeader."Currency Factor"
                                    else
                                        TotalAmt -= SalesInvoiceLine.Amount;
                                until SalesInvoiceLine.Next() = 0;
                            end else begin
                                SalesShipLine.SetRange("Document No.", ValueEntry."Document No.");
                                SalesShipLine.SetRange(Type, SalesShipLine.Type::Item);
                                SalesShipLine.SetRange("No.", ValueEntry."Item No.");
                                if SalesShipLine.FindSet() then begin
                                    repeat
                                        if SalesShipLine.Correction then
                                            CorrectionFound := true;
                                        DocItemSum += SalesShipLine."Quantity Invoiced";
                                    until SalesShipLine.Next() = 0;
                                    if (DocItemSum = 0) and CorrectionFound then
                                        CurrReportSkip := true;
                                end;
                            end;
                        end else
                            if (ValueEntry."Invoiced Quantity" >= 0) and (ValueEntry."Order Type" = ValueEntry."Order Type"::" ") then begin
                                SalesCrMemoLine.SetRange("Document No.", ValueEntry."Document No.");
                                SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
                                SalesCrMemoLine.SetRange("No.", ValueEntry."Item No.");
                                if SalesCrMemoLine.FindSet() then begin
                                    SalesCrMemoHeader.Get(ValueEntry."Document No.");
                                    repeat
                                        TotalInvoicedQty += SalesCrMemoLine.Quantity;
                                        if SalesCrMemoHeader."Currency Factor" <> 0 then
                                            TotalAmt += SalesCrMemoLine.Amount / SalesCrMemoHeader."Currency Factor"
                                        else
                                            TotalAmt += SalesCrMemoLine.Amount;
                                    until SalesCrMemoLine.Next() = 0;
                                end else begin
                                    SalesShipLine.SetRange("Document No.", ValueEntry."Document No.");
                                    SalesShipLine.SetRange(Type, SalesShipLine.Type::Item);
                                    SalesShipLine.SetRange("No.", ValueEntry."Item No.");
                                    if SalesShipLine.FindSet() then begin
                                        repeat
                                            if SalesShipLine.Correction then
                                                CorrectionFound := true;
                                            DocItemSum += SalesShipLine."Quantity Invoiced";
                                        until SalesShipLine.Next() = 0;
                                        if (DocItemSum = 0) and CorrectionFound then
                                            CurrReportSkip := true;
                                    end;
                                end;
                            end else
                                if (ValueEntry."Invoiced Quantity" < 0) and (ValueEntry."Order Type" = ValueEntry."Order Type"::Service) then begin
                                    ServiceInvoiceLine.SetRange("Document No.", ValueEntry."Document No.");
                                    ServiceInvoiceLine.SetRange(Type, ServiceInvoiceLine.Type::Item);
                                    ServiceInvoiceLine.SetRange("No.", ValueEntry."Item No.");
                                    if ServiceInvoiceLine.FindSet() then begin
                                        ServiceInvoiceHeader.Get(ValueEntry."Document No.");
                                        repeat
                                            TotalInvoicedQty -= ServiceInvoiceLine.Quantity;
                                            if ServiceInvoiceHeader."Currency Factor" <> 0 then
                                                TotalAmt -= ServiceInvoiceLine.Amount / ServiceInvoiceHeader."Currency Factor"
                                            else
                                                TotalAmt -= ServiceInvoiceLine.Amount;
                                        until ServiceInvoiceLine.Next() = 0;
                                    end else begin
                                        ServiceShipLine.SetRange("Document No.", ValueEntry."Document No.");
                                        ServiceShipLine.SetRange(Type, ServiceShipLine.Type::Item);
                                        ServiceShipLine.SetRange("No.", ValueEntry."Item No.");
                                        if ServiceShipLine.FindSet() then begin
                                            repeat
                                                if ServiceShipLine.Correction then
                                                    CorrectionFound := true;
                                                DocItemSum += ServiceShipLine."Quantity Invoiced";
                                            until ServiceShipLine.Next() = 0;
                                            if (DocItemSum = 0) and CorrectionFound then
                                                CurrReportSkip := true;
                                        end;
                                    end;
                                end else
                                    if (ValueEntry."Invoiced Quantity" >= 0) and (ValueEntry."Order Type" = ValueEntry."Order Type"::Service) then begin
                                        ServiceCrMemoLine.SetRange("Document No.", ValueEntry."Document No.");
                                        ServiceCrMemoLine.SetRange(Type, ServiceCrMemoLine.Type::Item);
                                        ServiceCrMemoLine.SetRange("No.", ValueEntry."Item No.");
                                        if ServiceCrMemoLine.FindSet() then begin
                                            ServiceCrMemoHeader.Get(ValueEntry."Document No.");
                                            repeat
                                                TotalInvoicedQty += ServiceCrMemoLine.Quantity;
                                                if ServiceCrMemoHeader."Currency Factor" <> 0 then
                                                    TotalAmt += ServiceCrMemoLine.Amount / ServiceCrMemoHeader."Currency Factor"
                                                else
                                                    TotalAmt += ServiceCrMemoLine.Amount;
                                            until ServiceCrMemoLine.Next() = 0;
                                        end else begin
                                            ServiceShipLine.SetRange("Document No.", ValueEntry."Document No.");
                                            ServiceShipLine.SetRange(Type, ServiceShipLine.Type::Item);
                                            ServiceShipLine.SetRange("No.", ValueEntry."Item No.");
                                            if ServiceShipLine.FindSet() then begin
                                                repeat
                                                    if ServiceShipLine.Correction then
                                                        CorrectionFound := true;
                                                    DocItemSum += ServiceShipLine."Quantity Invoiced";
                                                until ServiceShipLine.Next() = 0;
                                                if (DocItemSum = 0) and CorrectionFound then
                                                    CurrReportSkip := true;
                                            end;
                                        end;
                                    end;
                        if IntrastatReportHeader."Amounts in Add. Currency" then
                            TotalAmt := CurrExchRate.ExchangeAmtLCYToFCY(
                                ValueEntry."Posting Date", GLSetup."Additional Reporting Currency",
                                TotalAmt, AddCurrencyFactor);
                    end;
                else begin
                    TotalInvoicedQty += ValueEntry."Invoiced Quantity";
                    if not IntrastatReportHeader."Amounts in Add. Currency" then
                        TotalAmt += ValueEntry."Cost Amount (Actual)"
                    else
                        if ValueEntry."Cost per Unit" <> 0 then
                            TotalAmt += ValueEntry."Cost Amount (Actual)" * ValueEntry."Cost per Unit (ACY)" / ValueEntry."Cost per Unit"
                        else
                            TotalAmt +=
                                CurrExchRate.ExchangeAmtLCYToFCY(
                                    ValueEntry."Posting Date", GLSetup."Additional Reporting Currency",
                                    ValueEntry."Cost Amount (Actual)", AddCurrencyFactor);
                end;
            end;
        OnCalculateTotalsOnAfterSumTotals(ItemLedgerEntry, IntrastatReportHeader, TotalAmt, TotalCostAmt);

        CalcTotalItemChargeAmt(IntrastatReportHeader, ValueEntry, AddCurrencyFactor);

        OnAfterCalculateTotals(ItemLedgerEntry, IntrastatReportHeader, TotalAmt, TotalCostAmt);
    end;

    local procedure CalcTotalItemChargeAmt(IntrastatReportHeader: Record "Intrastat Report Header"; var ValueEntry: Record "Value Entry"; AddCurrencyFactor: Decimal)
    var
        ValueEntry2: Record "Value Entry";
        ActualAmount: Decimal;
    begin
        ValueEntry2.CopyFilters(ValueEntry);
        ValueEntry2.SetRange("Invoiced Quantity", 0);
        ValueEntry2.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type");
        ValueEntry2.SetRange("Item Ledger Entry No.");
        ValueEntry2.SetRange("Item No.", ValueEntry."Item No.");
        ValueEntry2.SetFilter("Item Charge No.", '<>%1', '');
        ValueEntry2.SetRange("Document No.", ValueEntry."Document No.");
        if ValueEntry2.FindSet() then
            repeat
                ActualAmount := GetActualAmount(ValueEntry2);
                if IntrastatReportHeader."Amounts in Add. Currency" then
                    ActualAmount :=
                        CurrExchRate.ExchangeAmtLCYToFCY(
                            ValueEntry2."Posting Date", GLSetup."Additional Reporting Currency",
                            ActualAmount, AddCurrencyFactor);
                TotalAmt += ActualAmount;
            until ValueEntry2.Next() = 0;
    end;

    local procedure GetActualAmount(ValueEntry2: Record "Value Entry"): Decimal
    begin
        case ValueEntry2."Item Ledger Entry Type" of
            ValueEntry2."Item Ledger Entry Type"::Sale:
                exit(-ValueEntry2."Sales Amount (Actual)");
            ValueEntry2."Item Ledger Entry Type"::Purchase:
                exit(ValueEntry2."Cost Amount (Actual)");
        end;
    end;

    local procedure InsertItemLedgerLine(IntrastatReportHeader: Record "Intrastat Report Header"; var IntrastatReportLine: Record "Intrastat Report Line"; var ValueEntry: Record "Value Entry"; var ItemLedgerEntry: Record "Item Ledger Entry"; IndirectCostPctReq: Decimal)
    var
        Item: Record Item;
        UOMMgt: Codeunit "Unit of Measure Management";
        IsHandled: Boolean;
    begin
        Item.Get(ItemLedgerEntry."Item No.");

        IntrastatReportLine.Init();
        IntrastatReportLine."Intrastat No." := IntrastatReportHeader."No.";
        IntrastatReportLine."Line No." += 10000;
        IntrastatReportLine.Date := ItemLedgerEntry."Last Invoice Date";
        IntrastatReportLine."Country/Region Code" := GetIntrastatCountryCode(ItemLedgerEntry."Country/Region Code");
        IntrastatReportLine."Transaction Type" := ItemLedgerEntry."Transaction Type";
        IntrastatReportLine."Transport Method" := ItemLedgerEntry."Transport Method";
        IntrastatReportLine."Source Type" := IntrastatReportLine."Source Type"::"Item Entry";
        IntrastatReportLine."Source Entry No." := ItemLedgerEntry."Entry No.";
        IntrastatReportLine.Amount := TotalAmt;
        IntrastatReportLine.Quantity := TotalInvoicedQty;
        IntrastatReportLine."Document No." := ValueEntry."Document No.";
        IntrastatReportLine."Item No." := Item."No.";
        IntrastatReportLine."Item Name" := Item.Description;
        IntrastatReportLine."Entry/Exit Point" := ItemLedgerEntry."Entry/Exit Point";
        IntrastatReportLine.Area := ItemLedgerEntry.Area;
        IntrastatReportLine."Transaction Specification" := ItemLedgerEntry."Transaction Specification";
        IntrastatReportLine."Shpt. Method Code" := ItemLedgerEntry."Shpt. Method Code";
        IntrastatReportLine."Location Code" := ItemLedgerEntry."Location Code";
        if IntrastatReportLine."Entry/Exit Point" <> '' then
            IntrastatReportLine.Validate("Entry/Exit Point");
        IntrastatReportLine."Statistics Period" := IntrastatReportHeader."Statistics Period";
        IntrastatReportLine."Reference Period" := IntrastatReportLine."Statistics Period";

        if ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::Sale then begin
            IntrastatReportLine.Type := IntrastatReportLine.Type::Shipment;
            FillVATRegNoAndCountryRegionCodeFromCustomer(IntrastatReportLine, GetCustomerNoFromDocumentNo(ValueEntry, ItemLedgerEntry));
            IntrastatReportLine.Amount := Round(-IntrastatReportLine.Amount, GLSetup."Amount Rounding Precision");
            IntrastatReportLine."Indirect Cost" := Round(-IntrastatReportLine."Indirect Cost", GLSetup."Amount Rounding Precision");
            IntrastatReportLine.Validate(Quantity, Round(-IntrastatReportLine.Quantity, 0.00001));
        end else begin
            if ValueEntry."Item Ledger Entry Type" = ValueEntry."Item Ledger Entry Type"::Transfer then begin
                if TotalInvoicedQty < 0 then
                    IntrastatReportLine.Type := IntrastatReportLine.Type::Receipt
                else
                    IntrastatReportLine.Type := IntrastatReportLine.Type::Shipment
            end else
                IntrastatReportLine.Type := IntrastatReportLine.Type::Receipt;

            if ValueEntry."Item Ledger Entry Type" = ValueEntry."Item Ledger Entry Type"::Transfer then begin
                IntrastatReportLine.Amount := Round(Abs(IntrastatReportLine.Amount), GLSetup."Amount Rounding Precision");
                IntrastatReportLine.Validate(Quantity, Round(Abs(IntrastatReportLine.Quantity), UOMMgt.QtyRndPrecision()));
            end else begin
                IntrastatReportLine.Amount := Round(IntrastatReportLine.Amount, GLSetup."Amount Rounding Precision");
                IntrastatReportLine.Validate(Quantity, Round(IntrastatReportLine.Quantity, UOMMgt.QtyRndPrecision()));
            end;
        end;

        SetCountryRegionCode(IntrastatReportLine, ItemLedgerEntry);

        IntrastatReportLine.Validate("Item No.");

        FindSourceCurrency(IntrastatReportLine, ItemLedgerEntry."Source No.", ItemLedgerEntry."Document Date", ItemLedgerEntry."Posting Date");

        IntrastatReportLine."Country/Region of Origin Code" := GetCountryOfOriginCode(Item, IntrastatReportHeader, IntrastatReportLine);
        IntrastatReportLine."Partner VAT ID" := RemoveLeadingCountryCode(GetPartnerID(IntrastatReportLine), IntrastatReportLine."Country/Region Code");
        IntrastatReportLine.Validate("Cost Regulation %", IndirectCostPctReq);
        IntrastatReportLine."Corrected Intrastat Report No." := IntrastatReportHeader."Corrected Intrastat Rep. No.";
        IntrastatReportLine.Validate("Source Entry No.");

        IsHandled := false;
        OnBeforeInsertItemLedgerLine(IntrastatReportLine, ItemLedgerEntry, IsHandled);
        if not IsHandled then
            IntrastatReportLine.Insert();

        IntrastatReportLine."Record ID Filter" := Format(IntrastatReportLine.RecordId);
        IntrastatReportLine.Modify();
    end;

    local procedure SetCountryRegionCode(var IntrastatReportLine: Record "Intrastat Report Line"; ItemLedgerEntry: Record "Item Ledger Entry")
    var
        CompanyInfo: Record "Company Information";
        Location: Record Location;
    begin
        CompanyInfo.Get();
        if IntrastatReportLine."Country/Region Code" in ['', CompanyInfo."Country/Region Code"] then
            if ItemLedgerEntry."Location Code" = '' then
                IntrastatReportLine."Country/Region Code" := CompanyInfo."Ship-to Country/Region Code"
            else begin
                Location.Get(ItemLedgerEntry."Location Code");
                IntrastatReportLine."Country/Region Code" := Location."Country/Region Code"
            end;
    end;

    internal procedure GetIntrastatCountryCode(CountryRegionCode: Code[10]): Code[10]
    var
        CountryRegion: Record "Country/Region";
        CompanyInformation: Record "Company Information";
    begin
        if CountryRegionCode = '' then
            if CompanyInformation.Get() then
                CountryRegionCode := CompanyInformation."Country/Region Code";

        if CountryRegion.Get(CountryRegionCode) then
            if CountryRegion."Intrastat Code" <> '' then
                CountryRegionCode := CountryRegion."Intrastat Code";

        exit(CountryRegionCode);
    end;

    local procedure FindSourceCurrency(var IntrastatReportLine: Record "Intrastat Report Line"; VendorNo: Code[20]; DocumentDate: Date; PostingDate: Date)
    var
        Country: Record "Country/Region";
        Vendor: Record Vendor;
        CurrencyExchRate: Record "Currency Exchange Rate";
        CurrencyDate: Date;
        Factor: Decimal;
    begin
        if DocumentDate <> 0D then
            CurrencyDate := DocumentDate
        else
            CurrencyDate := PostingDate;
        if Vendor.Get(VendorNo) then begin
            if Country.Get(Vendor."Country/Region Code") then
                IntrastatReportLine."Currency Code" := Country."Currency Code";
            if IntrastatReportLine."Currency Code" <> '' then begin
                Factor := CurrencyExchRate.ExchangeRate(CurrencyDate, IntrastatReportLine."Currency Code");
                IntrastatReportLine."Source Currency Amount" :=
                    CurrencyExchRate.ExchangeAmtLCYToFCY(
                        CurrencyDate, IntrastatReportLine."Currency Code", IntrastatReportLine.Amount, Factor);
            end;
        end;
    end;

    local procedure GetCustomerNoFromDocumentNo(ValueEntry: Record "Value Entry"; ItemLedgerEntry: Record "Item Ledger Entry"): Code[20]
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ServiceShipmentHeader: Record "Service Shipment Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        if SalesShipmentHeader.Get(ItemLedgerEntry."Document No.") then
            exit(SalesShipmentHeader."Sell-to Customer No.");
        SalesSetup.Get();
        if not SalesSetup."Shipment on Invoice" and SalesInvoiceHeader.Get(ItemLedgerEntry."Document No.") then
            exit(SalesInvoiceHeader."Sell-to Customer No.");
        if SalesCrMemoHeader.Get(ValueEntry."Document No.") then
            exit(SalesCrMemoHeader."Sell-to Customer No.");
        if ServiceShipmentHeader.Get(ItemLedgerEntry."Document No.") then
            exit(ServiceShipmentHeader."Customer No.");
    end;

    local procedure FillVATRegNoAndCountryRegionCodeFromCustomer(var IntrastatReportLine: Record "Intrastat Report Line"; CustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        if not Customer.Get(CustomerNo) then
            exit;
        IntrastatReportLine."Partner VAT ID" := Customer."VAT Registration No.";
        IntrastatReportLine."Country/Region Code" := GetIntrastatCountryCode(Customer."Country/Region Code");
    end;

    local procedure GetCountryOfOriginCode(Item: Record Item; IntrastatReporHeader: Record "Intrastat Report Header"; var IntrastatReportLine: Record "Intrastat Report Line") CountryOfOriginCode: Code[10]
    var
        ItemVendor: Record "Item Vendor";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        CountryOfOriginCode := GetIntrastatCountryCode(Item."Country/Region of Origin Code");
        if IntrastatReporHeader.Type = IntrastatReporHeader.Type::Purchases then
            if (IntrastatReportLine."Source Type"::"Item Entry" = IntrastatReportLine."Source Type"::"Item Entry") and ItemLedgerEntry.Get(IntrastatReportLine."Source Entry No.") then
                if ItemVendor.Get(ItemLedgerEntry."Source No.", ItemLedgerEntry."Item No.", ItemLedgerEntry."Variant Code") and
                   (ItemVendor."Country/Region of Origin Code" <> '')
                then
                    CountryOfOriginCode := GetIntrastatCountryCode(ItemVendor."Country/Region of Origin Code");

        OnAfterGetCountryOfOriginCode(IntrastatReportLine, CountryOfOriginCode);
    end;

    local procedure GetPartnerID(var IntrastatReportLine: Record "Intrastat Report Line") PartnerID: Text[50]
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetPartnerID(IntrastatReportLine, PartnerID, IsHandled);
        if IsHandled then
            exit(PartnerID);

        case IntrastatReportLine."Source Type" of
            IntrastatReportLine."Source Type"::"Job Entry":
                exit(GetPartnerIDFromJobEntry(IntrastatReportLine));
            IntrastatReportLine."Source Type"::"Item Entry":
                exit(GetPartnerIDFromItemEntry(IntrastatReportLine));
            IntrastatReportLine."Source Type"::"FA Entry":
                exit(GetPartnerIDFromFAEntry(IntrastatReportLine));
        end;
    end;

    local procedure GetPartnerIDFromJobEntry(var IntrastatReportLine: Record "Intrastat Report Line") Result: Text[50]
    var
        Customer: Record Customer;
        Job: Record Job;
        JobLedgerEntry: Record "Job Ledger Entry";
    begin
        if not JobLedgerEntry.Get(IntrastatReportLine."Source Entry No.") then
            exit('');
        if not Job.Get(JobLedgerEntry."Job No.") then
            exit('');
        if not Customer.Get(Job."Bill-to Customer No.") then
            exit('');
        IntrastatReportSetup.Get();
        Result := GetPartnerIDForCountry(Customer."Country/Region Code", IntrastatReportMgt.GetVATRegNo(Customer."Country/Region Code", Customer."VAT Registration No.", IntrastatReportSetup."Cust. VAT No. on File"), IsCustomerPrivatePerson(Customer."No."), false);
        OnAfterGetPartnerIDFromJobEntry(IntrastatReportLine, Customer, Result);
    end;

    local procedure GetPartnerIDFromItemEntry(var IntrastatReportLine: Record "Intrastat Report Line"): Text[50]
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        ReturnShipmentHeader: Record "Return Shipment Header";
        ServiceShipmentHeader: Record "Service Shipment Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        Customer: Record Customer;
        Vendor: Record Vendor;
        TransferReceiptHeader: Record "Transfer Receipt Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        EU3rdPartyTrade: Boolean;
        IsHandled: Boolean;
        Result: Text[50];
    begin
        IsHandled := false;
        OnBeforeGetPartnerIDFromItemEntry(IntrastatReportLine, Result);
        if IsHandled then
            exit(Result);

        if not ItemLedgerEntry.Get(IntrastatReportLine."Source Entry No.") then
            exit('');

        case ItemLedgerEntry."Document Type" of
            ItemLedgerEntry."Document Type"::"Sales Invoice":
                if SalesInvoiceHeader.Get(ItemLedgerEntry."Document No.") then
                    EU3rdPartyTrade := SalesInvoiceHeader."EU 3-Party Trade";
            ItemLedgerEntry."Document Type"::"Sales Credit Memo":
                if SalesCrMemoHeader.Get(ItemLedgerEntry."Document No.") then
                    EU3rdPartyTrade := SalesCrMemoHeader."EU 3-Party Trade";
            ItemLedgerEntry."Document Type"::"Sales Shipment":
                if SalesShipmentHeader.Get(ItemLedgerEntry."Document No.") then
                    EU3rdPartyTrade := SalesShipmentHeader."EU 3-Party Trade";
            ItemLedgerEntry."Document Type"::"Sales Return Receipt":
                if ReturnReceiptHeader.Get(ItemLedgerEntry."Document No.") then
                    EU3rdPartyTrade := ReturnReceiptHeader."EU 3-Party Trade";
            ItemLedgerEntry."Document Type"::"Purchase Credit Memo":
                if PurchCrMemoHdr.Get(ItemLedgerEntry."Document No.") then
                    exit(GetPartnerIDForCountry(
                            PurchCrMemoHdr."Pay-to Country/Region Code", PurchCrMemoHdr."VAT Registration No.",
                            IsVendorPrivatePerson(PurchCrMemoHdr."Pay-to Vendor No."), false));
            ItemLedgerEntry."Document Type"::"Purchase Return Shipment":
                if ReturnShipmentHeader.Get(ItemLedgerEntry."Document No.") then
                    exit(GetPartnerIDForCountry(
                            ReturnShipmentHeader."Pay-to Country/Region Code", ReturnShipmentHeader."VAT Registration No.",
                            IsVendorPrivatePerson(ReturnShipmentHeader."Pay-to Vendor No."), false));
            ItemLedgerEntry."Document Type"::"Purchase Receipt":
                if PurchRcptHeader.Get(ItemLedgerEntry."Document No.") then
                    if Vendor.Get(PurchRcptHeader."Buy-from Vendor No.") then
                        exit(GetPartnerIDForCountry(
                                PurchRcptHeader."Buy-from Country/Region Code", Vendor."VAT Registration No.",
                                IsVendorPrivatePerson(Vendor."No."), false))
                    else
                        exit('');
            ItemLedgerEntry."Document Type"::"Service Shipment":
                if ServiceShipmentHeader.Get(ItemLedgerEntry."Document No.") then
                    if Customer.Get(ServiceShipmentHeader."Bill-to Customer No.") then
                        exit(GetPartnerIDForCountry(
                                ServiceShipmentHeader."Bill-to Country/Region Code", ServiceShipmentHeader."VAT Registration No.",
                                IsCustomerPrivatePerson(ServiceShipmentHeader."Bill-to Customer No."), ServiceShipmentHeader."EU 3-Party Trade"))
                    else
                        exit('');
            ItemLedgerEntry."Document Type"::"Service Invoice":
                if ServiceInvoiceHeader.Get(ItemLedgerEntry."Document No.") then
                    if Customer.Get(ServiceInvoiceHeader."Bill-to Customer No.") then
                        exit(GetPartnerIDForCountry(
                                ServiceInvoiceHeader."Bill-to Country/Region Code", ServiceInvoiceHeader."VAT Registration No.",
                                IsCustomerPrivatePerson(ServiceInvoiceHeader."Bill-to Customer No."), ServiceInvoiceHeader."EU 3-Party Trade"))
                    else
                        exit('');
            ItemLedgerEntry."Document Type"::"Service Credit Memo":
                if ServiceCrMemoHeader.Get(ItemLedgerEntry."Document No.") then
                    if Customer.Get(ServiceCrMemoHeader."Bill-to Customer No.") then
                        exit(GetPartnerIDForCountry(
                                ServiceCrMemoHeader."Bill-to Country/Region Code", ServiceCrMemoHeader."VAT Registration No.",
                                IsCustomerPrivatePerson(ServiceCrMemoHeader."Bill-to Customer No."), ServiceCrMemoHeader."EU 3-Party Trade"))
                    else
                        exit('');
            ItemLedgerEntry."Document Type"::"Transfer Receipt":
                if TransferReceiptHeader.Get(ItemLedgerEntry."Document No.") then
                    exit(GetPartnerIDForCountry(ItemLedgerEntry."Country/Region Code", TransferReceiptHeader."Partner VAT ID", false, false));
            ItemLedgerEntry."Document Type"::"Transfer Shipment":
                if TransferShipmentHeader.Get(ItemLedgerEntry."Document No.") then
                    exit(GetPartnerIDForCountry(ItemLedgerEntry."Country/Region Code", TransferShipmentHeader."Partner VAT ID", false, false));
        end;

        IntrastatReportSetup.Get();
        case ItemLedgerEntry."Source Type" of
            ItemLedgerEntry."Source Type"::Customer:
                if Customer.Get(ItemLedgerEntry."Source No.") then
                    exit(GetPartnerIDForCountry(
                            ItemLedgerEntry."Country/Region Code",
                            IntrastatReportMgt.GetVATRegNo(Customer."Country/Region Code", Customer."VAT Registration No.", IntrastatReportSetup."Cust. VAT No. on File"),
                            IsCustomerPrivatePerson(Customer."No."), EU3rdPartyTrade))
                else
                    exit('');
            ItemLedgerEntry."Source Type"::Vendor:
                if Vendor.Get(ItemLedgerEntry."Source No.") then
                    exit(GetPartnerIDForCountry(
                            ItemLedgerEntry."Country/Region Code",
                            IntrastatReportMgt.GetVATRegNo(Vendor."Country/Region Code", Vendor."VAT Registration No.", IntrastatReportSetup."Vend. VAT No. on File"),
                            IsVendorPrivatePerson(Vendor."No."), false))
                else
                    exit('');
        end;
    end;

    local procedure GetPartnerIDFromFAEntry(var IntrastatReportLine: Record "Intrastat Report Line"): Text[50]
    var
        FALedgerEntry: Record "FA Ledger Entry";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        Vendor: Record Vendor;
        IsHandled: Boolean;
        Result: Text[50];
    begin
        IsHandled := false;
        OnBeforeGetPartnerIDFromFAEntry(IntrastatReportLine, Result);
        if IsHandled then
            exit(Result);

        if not FALedgerEntry.Get(IntrastatReportLine."Source Entry No.") then
            exit('');

        case FALedgerEntry."Document Type" of
            FALedgerEntry."Document Type"::Invoice:
                if PurchInvHeader.Get(FALedgerEntry."Document No.") then
                    if not Vendor.Get(PurchInvHeader."Buy-from Vendor No.") then
                        exit('');
            FALedgerEntry."Document Type"::"Credit Memo":
                if PurchCrMemoHdr.Get(FALedgerEntry."Document No.") then
                    if not Vendor.Get(PurchCrMemoHdr."Pay-to Vendor No.") then
                        exit('');
        end;

        IntrastatReportSetup.Get();
        exit(GetPartnerIDForCountry(
                Vendor."Country/Region Code",
                IntrastatReportMgt.GetVATRegNo(
                    Vendor."Country/Region Code", Vendor."VAT Registration No.", IntrastatReportSetup."Vend. VAT No. on File"),
                    IsVendorPrivatePerson(Vendor."No."), false));
    end;

    local procedure IsCustomerPrivatePerson(CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
    begin
        if not Customer.Get(CustomerNo) then
            exit(false);

        exit(IntrastatReportMgt.IsCustomerPrivatePerson(Customer));
    end;

    local procedure IsVendorPrivatePerson(VendorNo: Code[20]): Boolean
    var
        Vendor: Record Vendor;
    begin
        if not Vendor.Get(VendorNo) then
            exit(false);

        exit(IntrastatReportMgt.IsVendorPrivatePerson(Vendor));
    end;

    local procedure GetPartnerIDForCountry(CountryRegionCode: Code[10]; VATRegistrationNo: Text[50]; IsPrivatePerson: Boolean; IsThirdPartyTrade: Boolean): Text[50]
    var
        CountryRegion: Record "Country/Region";
        PartnerID: Text[50];
        IsHandled: Boolean;
    begin
        OnBeforeGetPartnerIDForCountryIT(CountryRegionCode, VATRegistrationNo, IsPrivatePerson, IsThirdPartyTrade, PartnerID, IsHandled);
        if IsHandled then
            exit(PartnerID);

        IntrastatReportSetup.Get();
        if IsPrivatePerson then
            exit(IntrastatReportSetup."Def. Private Person VAT No.");

        if IsThirdPartyTrade then
            exit(IntrastatReportSetup."Def. 3-Party Trade VAT No.");

        if (CountryRegionCode <> '') and CountryRegion.Get(CountryRegionCode) then
            exit(VATRegistrationNo);

        exit(IntrastatReportSetup."Def. VAT for Unknown State");
    end;

    internal procedure SetIntrastatHeader(var IntrastatReportHeader2: Record "Intrastat Report Header")
    begin
        IntrastatReportHeader := IntrastatReportHeader2;
    end;

    internal procedure GetIntrastatHeader(): Record "Intrastat Report Header"
    begin
        exit(IntrastatReportHeader);
    end;

    internal procedure SetTotals(TotalRoundedAmount2: Integer; LineCount2: Integer)
    begin
        TotalRoundedAmount := TotalRoundedAmount2;
        LineCount := LineCount2;
    end;

    internal procedure GetTotals(var TotalRoundedAmount2: Integer; var LineCount2: Integer)
    begin
        TotalRoundedAmount2 := TotalRoundedAmount;
        LineCount2 := LineCount;
    end;

    internal procedure RemoveLeadingCountryCode(CodeParameter: Text[50]; CountryCode: Text[10]): Text[20]
    begin
        CountryCode := CountryCode.Trim();
        if CopyStr(CodeParameter, 1, StrLen(CountryCode)) = CountryCode then
            exit(CopyStr(CodeParameter, StrLen(CountryCode) + 1))
        else
            exit(CodeParameter);
    end;

    internal procedure IsEU3PartyTrade(IntrastatReportLine: Record "Intrastat Report Line"): Boolean
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        SalesShipmentHeader: Record "Sales Shipment Header";
        ServiceShipmentHeader: Record "Service Shipment Header";
    begin
        if (IntrastatReportLine.Type <> IntrastatReportLine.Type::Shipment) or
           (IntrastatReportLine."Source Type" <> IntrastatReportLine."Source Type"::"Item Entry")
        then
            exit(false);

        ItemLedgerEntry.Get(IntrastatReportLine."Source Entry No.");
        case ItemLedgerEntry."Document Type" of
            ItemLedgerEntry."Document Type"::"Sales Shipment":
                begin
                    SalesShipmentHeader.SetRange("No.", ItemLedgerEntry."Document No.");
                    SalesShipmentHeader.SetRange("Posting Date", ItemLedgerEntry."Posting Date");
                    exit(SalesShipmentHeader.FindFirst() and SalesShipmentHeader."EU 3-Party Trade");
                end;
            ItemLedgerEntry."Document Type"::"Service Shipment":
                begin
                    ServiceShipmentHeader.SetRange("No.", ItemLedgerEntry."Document No.");
                    ServiceShipmentHeader.SetRange("Posting Date", ItemLedgerEntry."Posting Date");
                    exit(ServiceShipmentHeader.FindFirst() and ServiceShipmentHeader."EU 3-Party Trade");
                end;
        end;

        exit(false);
    end;

    internal procedure GetCompanyRepresentativeVATNo(): Text[20]
    var
        CompanyInfo: Record "Company Information";
        Vendor: Record Vendor;
    begin
        CompanyInfo.Get();
        if (CompanyInfo."Tax Representative No." <> '') and Vendor.Get(CompanyInfo."Tax Representative No.") and
           (Vendor."VAT Registration No." <> '')
        then
            exit(Format(RemoveLeadingCountryCode(Vendor."VAT Registration No.", CompanyInfo."Country/Region Code")).PadRight(11, '0'))
        else
            exit(Format(RemoveLeadingCountryCode(CompanyInfo."VAT Registration No.", CompanyInfo."Country/Region Code")).PadRight(11, '0'));
    end;

    procedure CreateDefaultDataExchangeDef()
    var
        DataExchDef: Record "Data Exch. Def";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        TempBlob: Codeunit "Temp Blob";
        XMLOutStream: OutStream;
        XMLInStream: InStream;
    begin
        if DataExchDef.Get('INTRA-2022-IT-NPM') then
            DataExchDef.Delete(true);

        if DataExchDef.Get('INTRA-2022-IT-NPQ') then
            DataExchDef.Delete(true);

        if DataExchDef.Get('INTRA-2022-IT-NSM') then
            DataExchDef.Delete(true);

        if DataExchDef.Get('INTRA-2022-IT-NSQ') then
            DataExchDef.Delete(true);

        if DataExchDef.Get('INTRA-2022-IT-CPM') then
            DataExchDef.Delete(true);

        if DataExchDef.Get('INTRA-2022-IT-CPQ') then
            DataExchDef.Delete(true);

        if DataExchDef.Get('INTRA-2022-IT-CSM') then
            DataExchDef.Delete(true);

        if DataExchDef.Get('INTRA-2022-IT-CSQ') then
            DataExchDef.Delete(true);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeXMLNPMP1Txt + DataExchangeXMLNPMP2Txt + DataExchangeXMLNPMP3Txt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
        Clear(TempBlob);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeXMLNPQP1Txt + DataExchangeXMLNPQP2Txt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
        Clear(TempBlob);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeXMLNSMP1Txt + DataExchangeXMLNSMP2Txt + DataExchangeXMLNSMP3Txt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
        Clear(TempBlob);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeXMLNSQP1Txt + DataExchangeXMLNSQP2Txt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
        Clear(TempBlob);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeXMLCPMP1Txt + DataExchangeXMLCPMP2Txt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
        Clear(TempBlob);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeXMLCPQP1Txt + DataExchangeXMLCPQP2Txt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
        Clear(TempBlob);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeXMLCSMP1Txt + DataExchangeXMLCSMP2Txt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
        Clear(TempBlob);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeXMLCSQP1Txt + DataExchangeXMLCSQP2Txt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
        Clear(TempBlob);

        IntrastatReportSetup.Get();
        IntrastatReportSetup."Data Exch. Def. Code NPM" := 'INTRA-2022-IT-NPM';
        IntrastatReportSetup."Data Exch. Def. Code NSM" := 'INTRA-2022-IT-NSM';
        IntrastatReportSetup."Data Exch. Def. Code NPQ" := 'INTRA-2022-IT-NPQ';
        IntrastatReportSetup."Data Exch. Def. Code NSQ" := 'INTRA-2022-IT-NSQ';
        IntrastatReportSetup."Data Exch. Def. Code CPM" := 'INTRA-2022-IT-CPM';
        IntrastatReportSetup."Data Exch. Def. Code CSM" := 'INTRA-2022-IT-CSM';
        IntrastatReportSetup."Data Exch. Def. Code CPQ" := 'INTRA-2022-IT-CPQ';
        IntrastatReportSetup."Data Exch. Def. Code CSQ" := 'INTRA-2022-IT-CSQ';
        IntrastatReportSetup.Modify();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetCountryOfOriginCode(var IntrastatReportLine: Record "Intrastat Report Line"; var CountryOfOriginCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetPartnerID(var IntrastatReportLine: Record "Intrastat Report Line"; var PartnerID: Text[50]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetPartnerIDFromJobEntry(var IntrastatReportLine: Record "Intrastat Report Line"; Customer: Record Customer; var Result: Text[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetPartnerIDFromItemEntry(var IntrastatReportLine: Record "Intrastat Report Line"; var Result: Text[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetPartnerIDFromFAEntry(var IntrastatReportLine: Record "Intrastat Report Line"; var Result: Text[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalculateTotalsOnAfterSumTotals(var ItemLedgerEntry: Record "Item Ledger Entry"; IntrastatReportHeader: Record "Intrastat Report Header"; var TotalAmt: Decimal; var TotalCostAmt: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateTotals(var ItemLedgerEntry: Record "Item Ledger Entry"; IntrastatReportHeader: Record "Intrastat Report Header"; var TotalAmt: Decimal; var TotalCostAmt: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertItemLedgerLine(var IntrastatReportLine: Record "Intrastat Report Line"; ItemLedgerEntry: Record "Item Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetPartnerIDForCountryIT(CountryRegionCode: Code[10]; VATRegistrationNo: Text[50]; IsPrivatePerson: Boolean; IsThirdPartyTrade: Boolean; var PartnerID: Text[50]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeDefineFileNamesIT(var IntrastatReportHeader: Record "Intrastat Report Header"; var FileName: Text; var ReceptFileName: Text; var ShipmentFileName: Text; var ZipFileName: Text; var IsHandled: Boolean)
    begin
    end;

    var
        CurrExchRate: Record "Currency Exchange Rate";
        GLSetup: Record "General Ledger Setup";
        IntrastatReportHeader: Record "Intrastat Report Header";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
        DefPrivatePersonVATNoLbl: TextConst ENU = 'QN999999999999';
        Def3DPartyTradeVATNoLbl: TextConst ENU = 'QV999999999999';
        DefUnknowVATNoLbl: TextConst ENU = 'QV999999999999';
        FileNameLbl: Label 'scambi.cee', Locked = true;
        TotalInvoicedQty, TotalAmt : Decimal;
        TotalRoundedAmount, LineCount : Integer;
        PeriodAlreadyReportedQst: Label 'You''ve already submitted the report for this period.\Do you want to continue?';
        DataExchangeXMLNPMP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-IT-NPM" Name="Intrastat Report 2022 IT (Normal Purchase Monthly)" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="148122" ColumnSeparator="1" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="20"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Progressive No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Partner VAT ID" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Source Currency Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Transaction Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="Total Weight" Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="Supplementary Quantity" Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="14" Name="Statistical Value" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="15" Name="Group Code" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="16" Name="Transport Method" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="17" Name="Transaction Specification" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="18" Name="Country/Region of Origin Code" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="19" Name="Area" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="20" Name="Transaction Type" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="10" MappingCodeunit="1269" PostMappingCodeunit="148123"><DataExchFieldMapping ColumnNo="1" Optional="true" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="148121" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="148122" Optional="true" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" Optional="true" UseDefaultValue="true" DefaultValue="1" /><DataExchFieldMapping ColumnNo="5" FieldID="46" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="7" FieldID="29" Optional="true" /><DataExchFieldMapping ColumnNo="8" FieldID="13" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture />',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLNPMP2Txt: Label '<NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="38" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="10" FieldID="8" Optional="true" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="11" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="12" FieldID="21" Optional="true" TransformationRule="ROUNDTOINTWITHMIN1"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINTWITHMIN1</Code><Description>Round to Integer with minimal value equal to 1</Description><TransformationType>6</TransformationType><FindValue>^0[,.].*</FindValue><ReplaceValue>1</ReplaceValue><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ROUNDTOINT</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="13" FieldID="35" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules>',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLNPMP3Txt: Label '<TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="14" FieldID="17" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="15" FieldID="40" Optional="true" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="16" FieldID="9" Optional="true" TransformationRule="NUMBERSONLYFIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>NUMBERSONLYFIRSTCHAR</Code><Description>Numbers Only First Character</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>FIRSTCHAR</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="17" FieldID="27" Optional="true" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First Two Characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="18" FieldID="24" Optional="true" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First Two Characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="19" FieldID="26" Optional="true" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First Two Characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="20" FieldID="8" Optional="true" TransformationRule="SECONDCHAR"><TransformationRules><Code>SECONDCHAR</Code><Description>Second Character</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>2</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldGrouping FieldID="3" /><DataExchFieldGrouping FieldID="5" /><DataExchFieldGrouping FieldID="7" /><DataExchFieldGrouping FieldID="8" /><DataExchFieldGrouping FieldID="9" /><DataExchFieldGrouping FieldID="26" /><DataExchFieldGrouping FieldID="27" /><DataExchFieldGrouping FieldID="29" /><DataExchFieldGrouping FieldID="39" /><DataExchFieldGrouping FieldID="40" /><DataExchFieldGrouping FieldID="148123" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLNPQP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-IT-NPQ" Name="Intrastat Report 2022 IT (Normal Purchase Quarterly)" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="148122" ColumnSeparator="1" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="11"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Progressive No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Partner VAT ID" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Source Currency Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Transaction Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="10" MappingCodeunit="1269" PostMappingCodeunit="148123"><DataExchFieldMapping ColumnNo="1" Optional="true" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="148121" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="148122" Optional="true" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only </Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" Optional="true" UseDefaultValue="true" DefaultValue="1" /><DataExchFieldMapping ColumnNo="5" FieldID="46" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="7" FieldID="29" Optional="true" /><DataExchFieldMapping ColumnNo="8" FieldID="13" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="38" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules>',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLNPQP2Txt: Label '<TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="10" FieldID="8" Optional="true" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="11" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldGrouping FieldID="3" /><DataExchFieldGrouping FieldID="5" /><DataExchFieldGrouping FieldID="7" /><DataExchFieldGrouping FieldID="8" /><DataExchFieldGrouping FieldID="9" /><DataExchFieldGrouping FieldID="26" /><DataExchFieldGrouping FieldID="27" /><DataExchFieldGrouping FieldID="29" /><DataExchFieldGrouping FieldID="39" /><DataExchFieldGrouping FieldID="40" /><DataExchFieldGrouping FieldID="148123" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLNSMP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-IT-NSM" Name="Intrastat Report 2022 IT (Normal Sale Monthly)" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="148122" ColumnSeparator="1" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="19"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Progressive No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Partner VAT ID" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Transaction Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Total Weight" Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="Supplementary Quantity" Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="Statistical Value" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="14" Name="Group Code" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="15" Name="Transport Method" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="16" Name="Transaction Specification" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="17" Name="Area" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="18" Name="Transaction Type" Show="false" DataType="0" Length="1" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="19" Name="Country/Region of Origin Code" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="10" MappingCodeunit="1269" PostMappingCodeunit="148123"><DataExchFieldMapping ColumnNo="1" Optional="true" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="148121" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="148122" Optional="true" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" Optional="true" UseDefaultValue="true" DefaultValue="1" /><DataExchFieldMapping ColumnNo="5" FieldID="46" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="7" FieldID="29" Optional="true" /><DataExchFieldMapping ColumnNo="8" FieldID="13" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules>',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLNSMP2Txt: Label '<TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="8" Optional="true" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="10" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="11" FieldID="21" Optional="true" TransformationRule="ROUNDTOINTWITHMIN1"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINTWITHMIN1</Code><Description>Round to Integer with minimal value equal to 1</Description><TransformationType>6</TransformationType><FindValue>^0[,.].*</FindValue><ReplaceValue>1</ReplaceValue><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ROUNDTOINT</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="12" FieldID="35" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="13" FieldID="17" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule>',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLNSMP3Txt: Label '<TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="14" FieldID="40" Optional="true" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="15" FieldID="9" Optional="true" TransformationRule="NUMBERSONLYFIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>NUMBERSONLYFIRSTCHAR</Code><Description>Numbers Only First Character</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>FIRSTCHAR</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="16" FieldID="27" Optional="true" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First Two Characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="17" FieldID="26" Optional="true" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First Two Characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="18" FieldID="8" Optional="true" TransformationRule="SECONDCHAR"><TransformationRules><Code>SECONDCHAR</Code><Description>Second Character</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>2</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="19" FieldID="24" Optional="true" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First Two Characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldGrouping FieldID="3" /><DataExchFieldGrouping FieldID="5" /><DataExchFieldGrouping FieldID="7" /><DataExchFieldGrouping FieldID="8" /><DataExchFieldGrouping FieldID="9" /><DataExchFieldGrouping FieldID="26" /><DataExchFieldGrouping FieldID="27" /><DataExchFieldGrouping FieldID="29" /><DataExchFieldGrouping FieldID="39" /><DataExchFieldGrouping FieldID="40" /><DataExchFieldGrouping FieldID="148123" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLNSQP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-IT-NSQ" Name="Intrastat Report 2022 IT (Normal Sale Quarterly)" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="148122" ColumnSeparator="1" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="10"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Progressive No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Partner VAT ID" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Transaction Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="10" MappingCodeunit="1269" PostMappingCodeunit="148123"><DataExchFieldMapping ColumnNo="1" Optional="true" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="148121" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="148122" Optional="true" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only </Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" Optional="true" UseDefaultValue="true" DefaultValue="1" /><DataExchFieldMapping ColumnNo="5" FieldID="46" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="7" FieldID="29" Optional="true" /><DataExchFieldMapping ColumnNo="8" FieldID="13" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="8" Optional="true" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping>',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLNSQP2Txt: Label '<DataExchFieldMapping ColumnNo="10" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldGrouping FieldID="3" /><DataExchFieldGrouping FieldID="5" /><DataExchFieldGrouping FieldID="7" /><DataExchFieldGrouping FieldID="8" /><DataExchFieldGrouping FieldID="9" /><DataExchFieldGrouping FieldID="26" /><DataExchFieldGrouping FieldID="27" /><DataExchFieldGrouping FieldID="29" /><DataExchFieldGrouping FieldID="39" /><DataExchFieldGrouping FieldID="40" /><DataExchFieldGrouping FieldID="148123" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLCPMP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-IT-CPM" Name="Intrastat Report 2022 IT (Correction Purchase Monthly)" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="148122" ColumnSeparator="1" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="16"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Progressive No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Month" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Quarter" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Year" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Partner VAT ID" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Sign" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="Source Currency Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="14" Name="Transaction Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="15" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="16" Name="Statistical Value" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="8" MappingCodeunit="1269" PostMappingCodeunit="148123"><DataExchFieldMapping ColumnNo="1" Optional="true" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="148121" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="148122" Optional="true" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" Optional="true" UseDefaultValue="true" DefaultValue="2" /><DataExchFieldMapping ColumnNo="5" FieldID="46" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="42" Optional="true" TransformationRule="SECOND2CHARS"><TransformationRules><Code>SECOND2CHARS</Code><Description>Gets characters 3d and 4th charachters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>3</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="7" Optional="true" UseDefaultValue="true" DefaultValue="0" /><DataExchFieldMapping ColumnNo="8" FieldID="42" Optional="true" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First Two Characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules>',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLCPMP2Txt: Label '</DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="10" FieldID="29" Optional="true" /><DataExchFieldMapping ColumnNo="11" FieldID="13" Optional="true" TransformationRule="GETAMOUNTSIGN"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>GETAMOUNTSIGN</Code><Description>Get Amount Sign</Description><TransformationType>6</TransformationType><FindValue>^\d</FindValue><ReplaceValue>+</ReplaceValue><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>FIRSTCHAR</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="12" FieldID="13" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="13" FieldID="38" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="14" FieldID="8" Optional="true" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="15" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="16" FieldID="17" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLCSMP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-IT-CSM" Name="Intrastat Report 2022 IT (Correction Sales Monthly)" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="148122" ColumnSeparator="1" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="15"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Progressive No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Month" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Quarter" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Year" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Partner VAT ID" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Sign" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="Transaction Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="14" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="15" Name="Statistical Value" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="10" MappingCodeunit="1269" PostMappingCodeunit="148123"><DataExchFieldMapping ColumnNo="1" Optional="true" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="148121" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="148122" Optional="true" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" Optional="true" UseDefaultValue="true" DefaultValue="2" /><DataExchFieldMapping ColumnNo="5" FieldID="46" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="42" Optional="true" TransformationRule="SECOND2CHARS"><TransformationRules><Code>SECOND2CHARS</Code><Description>Gets characters 3d and 4th charachters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>3</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="7" Optional="true" UseDefaultValue="true" DefaultValue="0" /><DataExchFieldMapping ColumnNo="8" FieldID="42" Optional="true" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First Two Characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules>',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLCSMP2Txt: Label '</DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="10" FieldID="29" Optional="true" /><DataExchFieldMapping ColumnNo="11" FieldID="13" Optional="true" TransformationRule="GETAMOUNTSIGN"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>GETAMOUNTSIGN</Code><Description>Get Amount Sign</Description><TransformationType>6</TransformationType><FindValue>^\d</FindValue><ReplaceValue>+</ReplaceValue><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>FIRSTCHAR</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="12" FieldID="13" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="13" FieldID="8" Optional="true" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="14" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="15" FieldID="17" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLCPQP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-IT-CPQ" Name="Intrastat Report 2022 IT (Correction Purchase Quarterly)" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="148122" ColumnSeparator="1" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="15"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Progressive No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Month" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Quarter" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Year" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Partner VAT ID" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Sign" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="Source Currency Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="14" Name="Transaction Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="15" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="8" MappingCodeunit="1269" PostMappingCodeunit="148123"><DataExchFieldMapping ColumnNo="1" Optional="true" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="148121" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="148122" Optional="true" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" Optional="true" UseDefaultValue="true" DefaultValue="2" /><DataExchFieldMapping ColumnNo="5" FieldID="46" Optional="true" /><DataExchFieldMapping ColumnNo="6" Optional="true" UseDefaultValue="true" DefaultValue="0" /><DataExchFieldMapping ColumnNo="7" FieldID="42" Optional="true" TransformationRule="FOURTHCHAR"><TransformationRules><Code>FOURTHCHAR</Code><Description>Fourth Character</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>4</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="8" FieldID="42" Optional="true" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First Two Characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="10" FieldID="29" Optional="true" /><DataExchFieldMapping ColumnNo="11" FieldID="13" Optional="true" TransformationRule="GETAMOUNTSIGN"><TransformationRules>',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLCPQP2Txt: Label '<Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>GETAMOUNTSIGN</Code><Description>Get Amount Sign</Description><TransformationType>6</TransformationType><FindValue>^\d</FindValue><ReplaceValue>+</ReplaceValue><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>FIRSTCHAR</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="12" FieldID="13" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="13" FieldID="38" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="14" FieldID="8" Optional="true" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="15" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLCSQP1Txt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-IT-CSQ" Name="Intrastat Report 2022 IT (Correction Sales Quarterly)" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="148122" ColumnSeparator="1" FileType="2" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="0" Code="DEFAULT" Name="DEFAULT" ColumnCount="14"><DataExchColumnDef ColumnNo="1" Name="EUROX" Show="false" DataType="0" Length="5" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Company VAT" Show="false" DataType="0" Length="11" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="File No." Show="false" DataType="0" Length="6" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Progressive No." Show="false" DataType="0" Length="5" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Month" Show="false" DataType="0" Length="2" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Quarter" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Year" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Country/Region Code" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Partner VAT ID" Show="false" DataType="0" Length="12" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Sign" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="Amount" Show="false" DataType="0" Length="13" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="Transaction Type" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="14" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="8" MappingCodeunit="1269" PostMappingCodeunit="148123"><DataExchFieldMapping ColumnNo="1" Optional="true" UseDefaultValue="true" DefaultValue="EUROX" /><DataExchFieldMapping ColumnNo="2" FieldID="148121" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="148122" Optional="true" TransformationRule="NUMBERSONLY"><TransformationRules><Code>NUMBERSONLY</Code><Description>Numbers Only</Description><TransformationType>6</TransformationType><FindValue>\D+</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="4" Optional="true" UseDefaultValue="true" DefaultValue="2" /><DataExchFieldMapping ColumnNo="5" FieldID="46" Optional="true" /><DataExchFieldMapping ColumnNo="6" Optional="true" UseDefaultValue="true" DefaultValue="0" /><DataExchFieldMapping ColumnNo="7" FieldID="42" Optional="true" TransformationRule="FOURTHCHAR"><TransformationRules><Code>FOURTHCHAR</Code><Description>Fourth Character</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>4</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="8" FieldID="42" Optional="true" TransformationRule="FIRST2CHARS"><TransformationRules><Code>FIRST2CHARS</Code><Description>First Two Characters</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="9" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="10" FieldID="29" Optional="true" /><DataExchFieldMapping ColumnNo="11" FieldID="13" Optional="true" TransformationRule="GETAMOUNTSIGN"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules>',
                            Locked = true; // will be replaced with file import when available
        DataExchangeXMLCSQP2Txt: Label '<TransformationRules><Code>GETAMOUNTSIGN</Code><Description>Get Amount Sign</Description><TransformationType>6</TransformationType><FindValue>^\d</FindValue><ReplaceValue>+</ReplaceValue><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>FIRSTCHAR</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="12" FieldID="13" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUM_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to Integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUM_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="13" FieldID="8" Optional="true" TransformationRule="FIRSTCHAR"><TransformationRules><Code>FIRSTCHAR</Code><Description>First Character</Description><TransformationType>4</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>1</StartPosition><Length>1</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="14" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true; // will be replaced with file import when available

}
