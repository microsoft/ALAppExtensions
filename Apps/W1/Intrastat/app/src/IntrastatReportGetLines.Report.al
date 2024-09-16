// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Setup;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Ledger;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Ledger;
using Microsoft.Purchases.History;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using Microsoft.Service.History;

report 4810 "Intrastat Report Get Lines"
{
    Caption = 'Intrastat Report Get Lines';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Item Ledger Entry"; "Item Ledger Entry")
        {
            DataItemTableView = sorting("Country/Region Code", "Entry Type", "Posting Date") where("Entry Type" = filter(Purchase | Sale | Transfer), Correction = const(false));

            trigger OnAfterGetRecord()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
                CurrReportSkip, IsHandled : Boolean;
            begin
                if not Item.Get("Item No.") then
                    CurrReport.Skip();

                if Item."Exclude from Intrastat Report" then
                    CurrReport.Skip();

                IntrastatReportLine2.SetRange("Source Entry No.", "Entry No.");
                if IntrastatReportLine2.FindFirst() then
                    CurrReport.Skip();

                if not HasCrossedBorder("Item Ledger Entry") or IsService("Item Ledger Entry") or IsServiceItem("Item No.") then
                    CurrReport.Skip();

                if "Entry Type" in ["Entry Type"::Sale, "Entry Type"::Purchase] then begin
                    ItemLedgEntry.Reset();
                    ItemLedgEntry.SetCurrentKey("Document No.", "Document Type");
                    ItemLedgEntry.SetRange("Document No.", "Document No.");
                    ItemLedgEntry.SetRange("Item No.", "Item No.");
                    ItemLedgEntry.SetRange(Correction, true);
                    if "Document Type" in ["Document Type"::"Sales Shipment", "Document Type"::"Sales Return Receipt",
                                           "Document Type"::"Purchase Receipt", "Document Type"::"Purchase Return Shipment"]
                    then begin
                        ItemLedgEntry.SetRange("Document Type", "Document Type");
                        if ItemLedgEntry.FindSet() then
                            repeat
                                if IsItemLedgerEntryCorrected(ItemLedgEntry, "Entry No.") then
                                    CurrReport.Skip();
                            until ItemLedgEntry.Next() = 0;
                    end;
                end;

                CurrReportSkip := false;
                OnAfterCheckItemLedgerEntry(IntrastatReportHeader, "Item Ledger Entry", CurrReportSkip);
                if CurrReportSkip then
                    CurrReport.Skip();

                IsHandled := false;
                CurrReportSkip := false;
                OnBeforeCalculateTotalsCall(IntrastatReportHeader, IntrastatReportLine, ValueEntry, "Item Ledger Entry", StartDate, EndDate, SkipZeroAmounts, AddCurrencyFactor, IndirectCostPctReq, CurrReportSkip, IsHandled);

                if CurrReportSkip then
                    CurrReport.Skip();

                if not IsHandled then begin
                    CalculateTotals("Item Ledger Entry");
                    if (TotalAmt = 0) and SkipZeroAmounts then
                        CurrReport.Skip();
                end;

                IsHandled := false;
                OnBeforeInsertItemLedgerLineCall(IntrastatReportHeader, IntrastatReportLine, ValueEntry, "Item Ledger Entry", IsHandled);
                if not IsHandled then
                    InsertItemLedgerLine();
            end;

            trigger OnPreDataItem()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeFilterItemLedgerEntry(IntrastatReportHeader, "Item Ledger Entry", StartDate, EndDate, IsHandled);
                if not IsHandled then begin
                    SetRange("Posting Date", StartDate, EndDate);
                    if SkipNotInvoicedEntries then
                        SetFilter("Invoiced Quantity", '<>0');
                end;

                case true of
                    (not IntrastatReportSetup."Report Receipts") and (not IntrastatReportSetup."Report Shipments"):
                        CurrReport.Break();
                    IntrastatReportSetup."Report Receipts" and (not IntrastatReportSetup."Report Shipments"):
                        SetFilter(Quantity, '>%1', 0);
                    IntrastatReportSetup."Report Shipments" and (not IntrastatReportSetup."Report Receipts"):
                        SetFilter(Quantity, '<%1', 0);
                end;

                IntrastatReportLine2.SetCurrentKey("Source Type", "Source Entry No.");
                IntrastatReportLine2.SetRange("Source Type", IntrastatReportLine2."Source Type"::"Item Entry");

                IsHandled := false;
                OnBeforeFilterValueEntry(IntrastatReportHeader, ValueEntry, "Item Ledger Entry", StartDate, EndDate, IsHandled);
                if not IsHandled then begin
                    ValueEntry.SetCurrentKey("Item Ledger Entry No.");
                    ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
                    ValueEntry.SetFilter(
                      "Item Ledger Entry Type", '%1|%2|%3',
                      "Item Ledger Entry Type"::Sale,
                      "Item Ledger Entry Type"::Purchase,
                      "Item Ledger Entry Type"::Transfer);
                end;
                OnAfterItemLedgerEntryOnPreDataItem("Item Ledger Entry");
            end;
        }
        dataitem("Job Ledger Entry"; "Job Ledger Entry")
        {
            DataItemTableView = sorting(Type, "Entry Type", "Country/Region Code", "Source Code", "Posting Date") where(Type = const(Item), "Source Code" = filter(<> ''), "Entry Type" = const(Usage));

            trigger OnAfterGetRecord()
            var
                CountryCode: Code[10];
            begin
                if not Item.Get("No.") then
                    CurrReport.Skip();

                if Item."Exclude from Intrastat Report" then
                    CurrReport.Skip();

                CountryCode := IntrastatReportMgt.GetIntrastatBaseCountryCode("Job Ledger Entry");
                if (Country.Get(CountryCode) and (Country."Intrastat Code" = '')) or (CountryCode in [CompanyInfo."Country/Region Code", '']) then
                    CurrReport.Skip();

                IntrastatReportLine2.SetRange("Source Entry No.", "Entry No.");
                if not IntrastatReportLine2.IsEmpty() then
                    CurrReport.Skip();

                if IsJobService("Job Ledger Entry") then
                    CurrReport.Skip();

                InsertJobLedgerLine();
            end;

            trigger OnPreDataItem()
            begin
                SetRange("Posting Date", StartDate, EndDate);
                IntrastatReportLine2.SetCurrentKey("Source Type", "Source Entry No.");
                IntrastatReportLine2.SetRange("Source Type", IntrastatReportLine2."Source Type"::"Job Entry");

                case true of
                    (not IntrastatReportSetup."Report Receipts") and (not IntrastatReportSetup."Report Shipments"):
                        CurrReport.Break();
                    IntrastatReportSetup."Report Receipts" and (not IntrastatReportSetup."Report Shipments"):
                        SetFilter("Quantity (Base)", '>%1', 0);
                    IntrastatReportSetup."Report Shipments" and (not IntrastatReportSetup."Report Receipts"):
                        SetFilter("Quantity (Base)", '<%1', 0);
                end;
            end;
        }

        dataitem("FA Ledger Entry"; "FA Ledger Entry")
        {
            DataItemTableView = sorting("FA No.", "Depreciation Book Code", "FA Posting Category", "FA Posting Type", "FA Posting Date", "Part of Book Value", "Reclassification Entry");
            trigger OnAfterGetRecord()
            var
                CountryCode: Code[10];
            begin
                if not FixedAsset.Get("FA No.") then
                    CurrReport.Skip();

                if FixedAsset."Exclude from Intrastat Report" then
                    CurrReport.Skip();

                CountryCode := IntrastatReportMgt.GetIntrastatBaseCountryCode("FA Ledger Entry");
                if Country.Get(CountryCode) and (Country."Intrastat Code" = '') then
                    CurrReport.Skip();

                if (("Document Type" = "Document Type"::Invoice) and (CountryCode in [CompanyInfo."Ship-to Country/Region Code", ''])) or
                    (("Document Type" = "Document Type"::"Credit Memo") and (CountryCode in [CompanyInfo."Country/Region Code", '']))
                then
                    CurrReport.Skip();

                IntrastatReportLine2.SetRange("Source Entry No.", "Entry No.");
                if not IntrastatReportLine2.IsEmpty() then
                    CurrReport.Skip();

                InsertFALedgerLine();
            end;

            trigger OnPreDataItem()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeFilterFALedgerEntry(IntrastatReportHeader, "FA Ledger Entry", StartDate, EndDate, IsHandled);
                if not IsHandled then begin
                    SetRange("FA Posting Date", StartDate, EndDate);
                    SetFilter("FA Posting Type", '%1|%2', "FA Posting Type"::"Proceeds on Disposal", "FA Posting Type"::"Acquisition Cost");
                    SetFilter("Document Type", '%1|%2', "Document Type"::Invoice, "Document Type"::"Credit Memo");
                    SetRange("FA Posting Category", "FA Posting Category"::" ");
                end;

                IntrastatReportLine2.SetCurrentKey("Source Type", "Source Entry No.");
                IntrastatReportLine2.SetRange("Source Type", IntrastatReportLine2."Source Type"::"FA Entry");
            end;
        }
#if not CLEAN24
        dataitem("Value Entry"; "Value Entry")
        {
            DataItemTableView = sorting("Entry No.");
            ObsoleteReason = 'Generates false quantity in a period where an item is not moved';
            ObsoleteState = Pending;
            ObsoleteTag = '24.0';

            trigger OnAfterGetRecord()
            var
                IsSkipped: Boolean;
            begin
                if ShowItemCharges then begin
                    IntrastatReportLine2.SetRange("Source Entry No.", "Item Ledger Entry No.");
                    if IntrastatReportLine2.FindFirst() then
                        CurrReport.Skip();

                    if "Item Ledger Entry".Get("Item Ledger Entry No.") then begin
                        if "Item Ledger Entry"."Posting Date" in [StartDate .. EndDate] then
                            CurrReport.Skip();
                        if Country.Get(IntrastatReportMgt.GetIntrastatBaseCountryCode("Item Ledger Entry")) and (Country."EU Country/Region Code" = '') then
                            CurrReport.Skip();
                        if not HasCrossedBorder("Item Ledger Entry") then
                            CurrReport.Skip();
                        IsSkipped := false;
                        OnAfterSkipValueEntry(StartDate, EndDate, "Value Entry", "Item Ledger Entry", IsSkipped);
                        if IsSkipped then
                            CurrReport.Skip();
                        InsertValueEntryLine();
                    end;
                end;
            end;

            trigger OnPreDataItem()
            begin
                SetRange("Posting Date", StartDate, EndDate);
                SetFilter("Item Charge No.", '<> %1', '');
                "Item Ledger Entry".SetRange("Posting Date");

                IntrastatReportLine2.SetRange("Intrastat No.", IntrastatReportHeader."No.");
                IntrastatReportLine2.SetCurrentKey("Source Type", "Source Entry No.");
                IntrastatReportLine2.SetRange("Source Type", IntrastatReportLine2."Source Type"::"Item Entry");

                OnAfterValueEntryOnPreDataItem(IntrastatReportHeader, "Value Entry", "Item Ledger Entry");
            end;
        }
#endif        
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(StartingDate; StartDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Starting Date';
                        ToolTip = 'Specifies the date from which the report or batch job processes information.';
                    }
                    field(EndingDate; EndDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Ending Date';
                        ToolTip = 'Specifies the date to which the report or batch job processes information.';
                    }
                    field(AmtInclItemCharges; AmountInclItemCharges)
                    {
                        ApplicationArea = All;
                        Caption = 'Amount incl. Item Charges';
                        ToolTip = 'Specifies the amount of the entry including any item charges.';

                        trigger OnValidate()
                        begin
                            if AmountInclItemCharges then
                                CostRegulationEnable := true
                            else begin
                                Clear(IndirectCostPctReq);
                                CostRegulationEnable := false;
                            end;
                        end;
                    }
                    field(IndCostPctReq; IndirectCostPctReq)
                    {
                        ApplicationArea = All;
                        Caption = 'Cost Regulation %';
                        DecimalPlaces = 0 : 5;
                        MaxValue = 100;
                        MinValue = 0;
                        Enabled = CostRegulationEnable;
                        ToolTip = 'Specifies the cost regulation percentage to cover freight and insurance. The statistical value of every line in the report is increased by this percentage.';
                    }
                }
                group(Additional)
                {
                    Caption = 'Additional';
                    field(SkipRecalcForZeros; SkipRecalcZeroAmounts)
                    {
                        ApplicationArea = All;
                        Caption = 'Skip Recalculation for Zero Amounts';
                        ToolTip = 'Specifies that lines without amounts will not be recalculated during the batch job.';
                    }
                    field(SkipZeros; SkipZeroAmounts)
                    {
                        ApplicationArea = All;
                        Caption = 'Skip Zero Amounts';
                        ToolTip = 'Specifies that item ledger entries without amounts will not be included in the batch job.';
                    }
#if not CLEAN24
                    field(ShowingItemCharges; ShowItemCharges)
                    {
                        ApplicationArea = All;
                        ObsoleteReason = 'Generates false quantity in a period where an item is not moved';
                        ObsoleteState = Pending;
                        ObsoleteTag = '24.0';
                        Visible = false;
                        Caption = 'Show Item Charge Entries';
                        ToolTip = 'Specifies if you want to show direct costs that your company has assigned and posted as item charges.';
                    }
#endif
                    field(SkipNotInvoiced; SkipNotInvoicedEntries)
                    {
                        ApplicationArea = All;
                        Caption = 'Skip Non-Invoiced Entries';
                        ToolTip = 'Specifies if item ledger entries that are shipped or received but not yet invoiced must be excluded from the process.';
                    }
                }
            }
        }
        trigger OnOpenPage()
        begin
            StartDate := IntrastatReportHeader.GetStatisticsStartDate();
            EndDate := CalcDate('<+1M-1D>', StartDate);
            if AmountInclItemCharges then
                CostRegulationEnable := true
            else begin
                Clear(IndirectCostPctReq);
                CostRegulationEnable := false;
            end;
            OnAfterInitRequestPage(IntrastatReportHeader, AmountInclItemCharges, StartDate, EndDate, CostRegulationEnable);
        end;
    }

    trigger OnInitReport()
    begin
        CompanyInfo.FindFirst();
        IntrastatReportSetup.Get();
        CostRegulationEnable := true;
        AmountInclItemCharges := true;
    end;

    trigger OnPreReport()
    begin
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportHeader."No.");
        IntrastatReportLine.LockTable();
        if not IntrastatReportLine.IsEmpty() then
            if not Confirm(LinesDeletionConfirmationQst, true, IntrastatReportHeader."No.") then
                CurrReport.Quit();

        IntrastatReportLine.DeleteAll();

        GetGLSetup();
        if IntrastatReportHeader."Amounts in Add. Currency" then begin
            GLSetup.TestField("Additional Reporting Currency");
            AddCurrencyFactor :=
                CurrExchRate.ExchangeRate(EndDate, GLSetup."Additional Reporting Currency");
        end;
        AmtRoundingDirection := GetAmtRoundingDirection();
    end;

    trigger OnPostReport()
    begin
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportHeader."No.");
        if IntrastatReportLine.IsEmpty() then
            Message(NoLinesMsg, IntrastatReportSetup.TableCaption());
    end;

    var
        IntrastatReportHeader: Record "Intrastat Report Header";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportLine2: Record "Intrastat Report Line";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        Item: Record Item;
        FixedAsset: Record "Fixed Asset";
        ValueEntry: Record "Value Entry";
        GLSetup: Record "General Ledger Setup";
        CurrExchRate: Record "Currency Exchange Rate";
        CompanyInfo: Record "Company Information";
        AddCurrency: Record Currency;
        OriginalCurrency: Record Currency;
        Country: Record "Country/Region";
        UOMMgt: Codeunit "Unit of Measure Management";
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
        TotalAmt: Decimal;
        TotalIndirectCost: Decimal;
        TotalIndirectCostAmt: Decimal;
        TotalIndirectCostExpected: Decimal;
        TotalIndirectCostAmtExpected: Decimal;
        AddCurrencyFactor: Decimal;
        AmtRoundingPrecision: Decimal;
        AverageCost: Decimal;
        AverageCostACY: Decimal;
        GLSetupRead: Boolean;
        AmountInclItemCharges: Boolean;
        PricesIncludingVATErr: Label 'Prices including VAT cannot be calculated when %1 is %2.', Comment = '%1 - VAT Calculation Type caption, %2 - "VAT Calculation Type"';
        LinesDeletionConfirmationQst: Label 'The existing lines for Intrastat report %1 will be deleted. Do you want to continue?', Comment = '%1 - Intrastat Report number';
        NoLinesMsg: Label 'No lines are suggested for the period. Please check %1.', Comment = '%1 - Intrastat Report Setup caption';
        DefaultRoundingDirectionTok: Label '=', Locked = true;
        CostRegulationEnable: Boolean;

    protected var
        StartDate: Date;
        EndDate: Date;
        IndirectCostPctReq: Decimal;
        SkipRecalcZeroAmounts: Boolean;
        SkipZeroAmounts: Boolean;
#if not CLEAN24
        [Obsolete('Generates false quantity in a period where an item is not moved', '24.0')]
        ShowItemCharges: Boolean;
#endif
        SkipNotInvoicedEntries: Boolean;
        AmtRoundingDirection: Text[1];


    procedure SetIntrastatReportHeader(NewIntrastatReportHeader: Record "Intrastat Report Header")
    begin
        IntrastatReportHeader := NewIntrastatReportHeader;
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportHeader."No.");
    end;

    local procedure InsertItemLedgerLine()
    var
        IsHandled: Boolean;
    begin
        IntrastatReportLine.Init();
        IntrastatReportLine."Intrastat No." := IntrastatReportHeader."No.";
        IntrastatReportLine."Line No." += 10000;
        IntrastatReportLine.Date := "Item Ledger Entry"."Posting Date";
        IntrastatReportLine."Country/Region Code" := IntrastatReportMgt.GetIntrastatBaseCountryCode("Item Ledger Entry");
        IntrastatReportLine."Transaction Type" := "Item Ledger Entry"."Transaction Type";
        IntrastatReportLine."Transport Method" := "Item Ledger Entry"."Transport Method";
        IntrastatReportLine."Source Entry No." := "Item Ledger Entry"."Entry No.";
        IntrastatReportLine.Quantity := "Item Ledger Entry".Quantity;
        IntrastatReportLine."Document No." := "Item Ledger Entry"."Document No.";
        IntrastatReportLine."Item No." := "Item Ledger Entry"."Item No.";
        IntrastatReportLine."Entry/Exit Point" := "Item Ledger Entry"."Entry/Exit Point";
        IntrastatReportLine.Area := "Item Ledger Entry".Area;
        IntrastatReportLine."Transaction Specification" := "Item Ledger Entry"."Transaction Specification";
        IntrastatReportLine."Shpt. Method Code" := "Item Ledger Entry"."Shpt. Method Code";
        IntrastatReportLine."Location Code" := "Item Ledger Entry"."Location Code";

        if AmountInclItemCharges then
            TotalAmt := Abs(TotalAmt + TotalIndirectCost)
        else
            IntrastatReportLine."Indirect Cost" := Abs(TotalAmt + TotalIndirectCost) - Abs(TotalAmt);

        if IntrastatReportHeader."Amounts in Add. Currency" then
            IntrastatReportLine.Amount := Round(Abs(TotalAmt), AddCurrency."Amount Rounding Precision", AmtRoundingDirection)
        else
            IntrastatReportLine.Amount := Round(Abs(TotalAmt), GLSetup."Amount Rounding Precision", AmtRoundingDirection);

        IntrastatReportLine."Currency Code" := IntrastatReportMgt.GetOriginalCurrency("Item Ledger Entry");
        if IntrastatReportLine."Currency Code" <> '' then begin
            if OriginalCurrency.Get(IntrastatReportLine."Currency Code") then
                AmtRoundingPrecision := OriginalCurrency."Amount Rounding Precision"
            else
                AmtRoundingPrecision := GLSetup."Amount Rounding Precision";

            if IntrastatReportHeader."Amounts in Add. Currency" then
                IntrastatReportLine."Source Currency Amount" :=
                    Round(
                        Abs(
                            CurrExchRate.ExchangeAmtFCYToFCY(
                                IntrastatReportLine.Date,
                                GLSetup."Additional Reporting Currency",
                                IntrastatReportLine."Currency Code",
                                TotalAmt)),
                        AmtRoundingPrecision,
                        AmtRoundingDirection)
            else
                IntrastatReportLine."Source Currency Amount" :=
                    Round(
                        Abs(
                            CurrExchRate.ExchangeAmtLCYToFCY(
                                IntrastatReportLine.Date,
                                IntrastatReportLine."Currency Code",
                                TotalAmt,
                                CurrExchRate.ExchangeRate(
                                    IntrastatReportLine.Date,
                                    IntrastatReportLine."Currency Code"))),
                        AmtRoundingPrecision,
                        AmtRoundingDirection)
        end else
            IntrastatReportLine."Source Currency Amount" := IntrastatReportLine.Amount;

        if IntrastatReportLine.Quantity < 0 then
            IntrastatReportLine.Type := IntrastatReportLine.Type::Shipment
        else
            IntrastatReportLine.Type := IntrastatReportLine.Type::Receipt;

        SetCountryRegionCode(IntrastatReportLine, "Item Ledger Entry");

        IsHandled := false;
        OnBeforeValidateItemLedgerLineFields(IntrastatReportLine, "Item Ledger Entry", IsHandled);
        if not IsHandled then begin
            IntrastatReportLine.Validate("Item No.");
            IntrastatReportLine.Validate("Source Type", IntrastatReportLine."Source Type"::"Item Entry");
            IntrastatReportLine.Validate(Quantity, Round(Abs(IntrastatReportLine.Quantity), UOMMgt.QtyRndPrecision()));
        end;

        if AmountInclItemCharges then
            IntrastatReportLine.Validate("Cost Regulation %", IndirectCostPctReq)
        else
            IntrastatReportLine.Validate("Indirect Cost");

        IsHandled := false;
        OnBeforeInsertItemLedgerLine(IntrastatReportLine, "Item Ledger Entry", IsHandled);
        if not IsHandled then
            IntrastatReportLine.Insert();

        IntrastatReportLine."Record ID Filter" := Format(IntrastatReportLine.RecordId);
        IntrastatReportLine.Modify();
    end;

    local procedure InsertJobLedgerLine()
    var
        IsHandled: Boolean;
    begin
        IntrastatReportLine.Init();
        IntrastatReportLine."Intrastat No." := IntrastatReportHeader."No.";
        IntrastatReportLine."Line No." += 10000;
        IntrastatReportLine.Date := "Job Ledger Entry"."Posting Date";
        IntrastatReportLine."Country/Region Code" := IntrastatReportMgt.GetIntrastatBaseCountryCode("Job Ledger Entry");
        IntrastatReportLine."Transaction Type" := "Job Ledger Entry"."Transaction Type";
        IntrastatReportLine."Transport Method" := "Job Ledger Entry"."Transport Method";
        IntrastatReportLine."Shpt. Method Code" := "Job Ledger Entry"."Shpt. Method Code";
        IntrastatReportLine.Quantity := "Job Ledger Entry"."Quantity (Base)";
        if IntrastatReportLine.Quantity > 0 then
            IntrastatReportLine.Type := IntrastatReportLine.Type::Shipment
        else
            IntrastatReportLine.Type := IntrastatReportLine.Type::Receipt;

        if IntrastatReportHeader."Amounts in Add. Currency" then
            IntrastatReportLine.Amount :=
                Round(
                    Abs("Job Ledger Entry"."Add.-Currency Line Amount"),
                    AddCurrency."Amount Rounding Precision",
                    AmtRoundingDirection)
        else
            IntrastatReportLine.Amount :=
                Round(
                    Abs("Job Ledger Entry"."Line Amount (LCY)"),
                    GLSetup."Amount Rounding Precision",
                    AmtRoundingDirection);

        IntrastatReportLine."Currency Code" := "Job Ledger Entry"."Currency Code";

        AmtRoundingPrecision := GLSetup."Amount Rounding Precision";
        if IntrastatReportLine."Currency Code" <> '' then
            if OriginalCurrency.Get(IntrastatReportLine."Currency Code") then
                AmtRoundingPrecision := OriginalCurrency."Amount Rounding Precision";

        IntrastatReportLine."Source Currency Amount" :=
            Round(
                Abs("Job Ledger Entry"."Line Amount"),
                AmtRoundingPrecision,
                AmtRoundingDirection);

        IntrastatReportLine."Source Entry No." := "Job Ledger Entry"."Entry No.";
        IntrastatReportLine."Document No." := "Job Ledger Entry"."Document No.";
        IntrastatReportLine."Item No." := "Job Ledger Entry"."No.";
        IntrastatReportLine."Entry/Exit Point" := "Job Ledger Entry"."Entry/Exit Point";
        IntrastatReportLine.Area := "Job Ledger Entry".Area;
        IntrastatReportLine."Transaction Specification" := "Job Ledger Entry"."Transaction Specification";
        IntrastatReportLine."Shpt. Method Code" := "Job Ledger Entry"."Shpt. Method Code";
        IntrastatReportLine."Location Code" := "Job Ledger Entry"."Location Code";

        IsHandled := false;
        OnBeforeValidateJobLedgerLineFields(IntrastatReportLine, "Job Ledger Entry", IsHandled);
        if not IsHandled then begin
            IntrastatReportLine.Validate("Item No.");
            IntrastatReportLine.Validate("Source Type", IntrastatReportLine."Source Type"::"Job Entry");
            IntrastatReportLine.Validate(Quantity, Round(Abs(IntrastatReportLine.Quantity), UOMMgt.QtyRndPrecision()));
        end;

        if AmountInclItemCharges then
            IntrastatReportLine.Validate("Cost Regulation %", IndirectCostPctReq);

        IsHandled := false;
        OnBeforeInsertJobLedgerLine(IntrastatReportLine, "Job Ledger Entry", IsHandled);
        if not IsHandled then
            IntrastatReportLine.Insert();

        IntrastatReportLine."Record ID Filter" := Format(IntrastatReportLine.RecordId);
        IntrastatReportLine.Modify();
    end;

    local procedure InsertFALedgerLine()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        IsHandled: Boolean;
    begin
        IntrastatReportLine.Init();
        IntrastatReportLine."Intrastat No." := IntrastatReportHeader."No.";
        IntrastatReportLine."Line No." += 10000;
        IntrastatReportLine.Type := GetIntrastatReportLineType("FA Ledger Entry");

        if (IntrastatReportLine.Type = IntrastatReportLine.Type::Receipt) and (not IntrastatReportSetup."Report Receipts") or
            (IntrastatReportLine.Type = IntrastatReportLine.Type::Shipment) and (not IntrastatReportSetup."Report Shipments")
        then
            CurrReport.Skip();

        IntrastatReportLine."Document No." := "FA Ledger Entry"."Document No.";
        IntrastatReportLine.Date := "FA Ledger Entry"."FA Posting Date";
        IntrastatReportLine."Item No." := "FA Ledger Entry"."FA No.";
        IntrastatReportLine.Quantity := 1;

        FixedAsset.Get("FA Ledger Entry"."FA No.");
        if "FA Ledger Entry"."FA Posting Type" = "FA Ledger Entry"."FA Posting Type"::"Acquisition Cost" then
            case "FA Ledger Entry"."Document Type" of
                "FA Ledger Entry"."Document Type"::Invoice:
                    if PurchInvHeader.Get("FA Ledger Entry"."Document No.") then begin
                        IntrastatReportLine."Transaction Type" := PurchInvHeader."Transaction Type";
                        IntrastatReportLine."Transport Method" := PurchInvHeader."Transport Method";
                        IntrastatReportLine."Entry/Exit Point" := PurchInvHeader."Entry Point";
                        IntrastatReportLine."Transaction Specification" := PurchInvHeader."Transaction Specification";
                        IntrastatReportLine.Area := PurchInvHeader.Area;
                        IntrastatReportLine."Shpt. Method Code" := PurchInvHeader."Shipment Method Code";
                        IntrastatReportLine."Location Code" := PurchInvHeader."Location Code";
                    end;
                "FA Ledger Entry"."Document Type"::"Credit Memo":
                    if PurchCrMemoHdr.Get("FA Ledger Entry"."Document No.") then begin
                        IntrastatReportLine."Transaction Type" := PurchCrMemoHdr."Transaction Type";
                        IntrastatReportLine."Transport Method" := PurchCrMemoHdr."Transport Method";
                        IntrastatReportLine."Entry/Exit Point" := PurchCrMemoHdr."Entry Point";
                        IntrastatReportLine."Transaction Specification" := PurchCrMemoHdr."Transaction Specification";
                        IntrastatReportLine.Area := PurchCrMemoHdr.Area;
                        IntrastatReportLine."Shpt. Method Code" := PurchCrMemoHdr."Shipment Method Code";
                        IntrastatReportLine."Location Code" := PurchCrMemoHdr."Location Code";
                    end;
            end
        else    //  "FA Posting Type"::"Proceeds on Disposal"
            case "FA Ledger Entry"."Document Type" of
                "FA Ledger Entry"."Document Type"::Invoice:
                    if SalesInvHeader.Get("FA Ledger Entry"."Document No.") then begin
                        IntrastatReportLine."Transaction Type" := SalesInvHeader."Transaction Type";
                        IntrastatReportLine."Transport Method" := SalesInvHeader."Transport Method";
                        IntrastatReportLine."Entry/Exit Point" := SalesInvHeader."Exit Point";
                        IntrastatReportLine."Transaction Specification" := SalesInvHeader."Transaction Specification";
                        IntrastatReportLine.Area := SalesInvHeader.Area;
                        IntrastatReportLine."Shpt. Method Code" := SalesInvHeader."Shipment Method Code";
                        IntrastatReportLine."Location Code" := SalesInvHeader."Location Code";
                    end;
                "FA Ledger Entry"."Document Type"::"Credit Memo":
                    if SalesCrMemoHeader.Get("FA Ledger Entry"."Document No.") then begin
                        IntrastatReportLine."Transaction Type" := SalesCrMemoHeader."Transaction Type";
                        IntrastatReportLine."Transport Method" := SalesCrMemoHeader."Transport Method";
                        IntrastatReportLine."Entry/Exit Point" := SalesCrMemoHeader."Exit Point";
                        IntrastatReportLine."Transaction Specification" := SalesCrMemoHeader."Transaction Specification";
                        IntrastatReportLine.Area := SalesCrMemoHeader.Area;
                        IntrastatReportLine."Shpt. Method Code" := SalesCrMemoHeader."Shipment Method Code";
                        IntrastatReportLine."Location Code" := SalesCrMemoHeader."Location Code";
                    end;
            end;

        IntrastatReportLine."Country/Region Code" := IntrastatReportMgt.GetIntrastatBaseCountryCode("FA Ledger Entry");
        if IntrastatReportHeader."Amounts in Add. Currency" then
            IntrastatReportLine.Amount :=
                Round(
                    Abs(
                        CurrExchRate.ExchangeAmtLCYToFCY(
                            IntrastatReportLine.Date, GLSetup."Additional Reporting Currency",
                            "FA Ledger Entry"."Amount (LCY)", AddCurrencyFactor)),
                    AddCurrency."Amount Rounding Precision",
                    AmtRoundingDirection)
        else
            IntrastatReportLine.Amount :=
                Round(
                    Abs("FA Ledger Entry"."Amount (LCY)"),
                    GLSetup."Amount Rounding Precision",
                    AmtRoundingDirection);

        IntrastatReportLine."Currency Code" := IntrastatReportMgt.GetOriginalCurrency("FA Ledger Entry");
        AmtRoundingPrecision := GLSetup."Amount Rounding Precision";
        if IntrastatReportLine."Currency Code" <> '' then
            if OriginalCurrency.Get(IntrastatReportLine."Currency Code") then
                AmtRoundingPrecision := OriginalCurrency."Amount Rounding Precision";

        IntrastatReportLine."Source Currency Amount" :=
            Round(
                Abs("FA Ledger Entry".Amount),
                AmtRoundingPrecision,
                AmtRoundingDirection);

        IntrastatReportLine."Source Entry No." := "FA Ledger Entry"."Entry No.";

        IsHandled := false;
        OnBeforeValidateFALedgerLineFields(IntrastatReportLine, "FA Ledger Entry", IsHandled);
        if not IsHandled then begin
            IntrastatReportLine.Validate("Source Type", IntrastatReportLine."Source Type"::"FA Entry");
            IntrastatReportLine.Validate("Item No.");
            IntrastatReportLine.Validate(Quantity, Round(Abs(IntrastatReportLine.Quantity), UOMMgt.QtyRndPrecision()));
        end;
        if AmountInclItemCharges then
            IntrastatReportLine.Validate("Cost Regulation %", IndirectCostPctReq);

        IsHandled := false;
        OnBeforeInsertFALedgerLine(IntrastatReportLine, "FA Ledger Entry", IsHandled);

        if not IsHandled then
            IntrastatReportLine.Insert();

        IntrastatReportLine."Record ID Filter" := Format(IntrastatReportLine.RecordId);
        IntrastatReportLine.Modify();
    end;

    local procedure GetIntrastatReportLineType(FALedgerEntry: Record "FA Ledger Entry") IntrastatReportLineType: Enum "Intrastat Report Line Type"
    begin
        if FALedgerEntry."FA Posting Type" = FALedgerEntry."FA Posting Type"::"Acquisition Cost" then
            if FALedgerEntry."Document Type" = FALedgerEntry."Document Type"::Invoice then
                IntrastatReportLineType := Enum::"Intrastat Report Line Type"::Receipt
            else
                IntrastatReportLineType := Enum::"Intrastat Report Line Type"::Shipment
        else    //  "FA Posting Type"::"Proceeds on Disposal"
            if FALedgerEntry."Document Type" = FALedgerEntry."Document Type"::Invoice then
                IntrastatReportLineType := Enum::"Intrastat Report Line Type"::Shipment
            else
                IntrastatReportLineType := Enum::"Intrastat Report Line Type"::Receipt;
        OnAfterGetIntrastatReportLineType(FALedgerEntry, IntrastatReportLineType);
    end;

    local procedure GetGLSetup()
    begin
        if not GLSetupRead then begin
            GLSetup.Get();
            if GLSetup."Additional Reporting Currency" <> '' then
                AddCurrency.Get(GLSetup."Additional Reporting Currency");
        end;
        GLSetupRead := true;
    end;

    local procedure CalculateAverageCost(var AverageCost: Decimal; var AverageCostACY: Decimal): Boolean
    var
        ValueEntry2: Record "Value Entry";
        ItemLedgEntry: Record "Item Ledger Entry";
        AverageQty: Decimal;
    begin
        ItemLedgEntry.SetCurrentKey("Item No.", "Entry Type");
        ItemLedgEntry.SetRange("Item No.", "Item Ledger Entry"."Item No.");
        ItemLedgEntry.SetRange("Entry Type", "Item Ledger Entry"."Entry Type");
        ItemLedgEntry.CalcSums(Quantity);

        ValueEntry2.SetCurrentKey("Item No.", "Posting Date", "Item Ledger Entry Type");
        ValueEntry2.SetRange("Item No.", "Item Ledger Entry"."Item No.");
        ValueEntry2.SetRange("Item Ledger Entry Type", "Item Ledger Entry"."Entry Type");
        ValueEntry2.CalcSums(
          "Cost Amount (Actual)",
          "Cost Amount (Expected)");
        ValueEntry2."Cost Amount (Actual) (ACY)" :=
          CurrExchRate.ExchangeAmtLCYToFCY(
            EndDate, GLSetup."Additional Reporting Currency", ValueEntry2."Cost Amount (Actual)", AddCurrencyFactor);
        ValueEntry2."Cost Amount (Expected) (ACY)" :=
          CurrExchRate.ExchangeAmtLCYToFCY(
            EndDate, GLSetup."Additional Reporting Currency", ValueEntry2."Cost Amount (Expected)", AddCurrencyFactor);
        AverageQty := ItemLedgEntry.Quantity;
        AverageCost := ValueEntry2."Cost Amount (Actual)" + ValueEntry2."Cost Amount (Expected)";
        AverageCostACY := ValueEntry2."Cost Amount (Actual) (ACY)" + ValueEntry2."Cost Amount (Expected) (ACY)";

        if AverageQty <> 0 then begin
            AverageCost := AverageCost / AverageQty;
            AverageCostACY := AverageCostACY / AverageQty;
            if (AverageCost < 0) or (AverageCostACY < 0) then begin
                AverageCost := 0;
                AverageCostACY := 0;
            end;
        end else begin
            AverageCost := 0;
            AverageCostACY := 0;
        end;

        exit(AverageQty >= 0);
    end;

    local procedure CountryOfOrigin(CountryRegionCode: Code[20]): Boolean
    var
        CountryRegion: Record "Country/Region";
    begin
        if (IntrastatReportMgt.GetIntrastatBaseCountryCode("Item Ledger Entry") in [CompanyInfo."Country/Region Code", '']) =
           (CountryRegionCode in [CompanyInfo."Country/Region Code", ''])
        then
            exit(false);

        if CountryRegionCode <> '' then begin
            CountryRegion.Get(CountryRegionCode);
            if CountryRegion."Intrastat Code" = '' then
                exit(false);
        end;
        exit(true);
    end;

    local procedure HasCrossedBorder(ItemLedgEntry: Record "Item Ledger Entry") Result: Boolean
    var
        ItemLedgEntry2: Record "Item Ledger Entry";
        Location: Record Location;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeHasCrossedBorder(ItemLedgEntry, Result, IsHandled);
        if IsHandled then
            exit(Result);

        Clear(Country);
        if (Country.Get(IntrastatReportMgt.GetIntrastatBaseCountryCode(ItemLedgEntry)) and (Country."Intrastat Code" <> '')) or (Country.Code = '') then
            case true of
                ItemLedgEntry."Drop Shipment":
                    begin
                        IsHandled := false;
                        OnBeforeCheckDropShipment(IntrastatReportHeader, ItemLedgEntry, Country, Result, IsHandled);
                        if IsHandled then
                            exit(Result);

                        if not IntrastatReportSetup."Include Drop Shipment" then
                            exit(false);

                        if Country.Code in [CompanyInfo."Country/Region Code", ''] then
                            exit(false);
                        if ItemLedgEntry."Applies-to Entry" = 0 then begin
                            ItemLedgEntry2.SetCurrentKey("Item No.", "Posting Date");
                            ItemLedgEntry2.SetRange("Item No.", ItemLedgEntry."Item No.");
                            ItemLedgEntry2.SetRange("Posting Date", ItemLedgEntry."Posting Date");
                            ItemLedgEntry2.SetRange("Applies-to Entry", ItemLedgEntry."Entry No.");
                            ItemLedgEntry2.FindFirst();
                        end else
                            ItemLedgEntry2.Get(ItemLedgEntry."Applies-to Entry");
                        if not (IntrastatReportMgt.GetIntrastatBaseCountryCode(ItemLedgEntry2) in [CompanyInfo."Country/Region Code", '']) then
                            exit(false);
                    end;
                ItemLedgEntry."Entry Type" = ItemLedgEntry."Entry Type"::Transfer:
                    begin
                        if Country.Code in [CompanyInfo."Country/Region Code", ''] then
                            exit(false);
                        case true of
                            ((ItemLedgEntry."Order Type" <> ItemLedgEntry."Order Type"::Transfer) or (ItemLedgEntry."Order No." = '')),
                            ItemLedgEntry."Document Type" = ItemLedgEntry."Document Type"::"Direct Transfer":
                                if Location.Get(ItemLedgEntry."Location Code") then
                                    if (Location."Country/Region Code" <> '') and (Location."Country/Region Code" <> CompanyInfo."Country/Region Code") then
                                        exit(false);
                            ItemLedgEntry."Document Type" = ItemLedgEntry."Document Type"::"Transfer Receipt":
                                begin
                                    ItemLedgEntry2.SetCurrentKey("Order Type", "Order No.");
                                    ItemLedgEntry2.SetRange("Order Type", ItemLedgEntry."Order Type"::Transfer);
                                    ItemLedgEntry2.SetRange("Order No.", ItemLedgEntry."Order No.");
                                    ItemLedgEntry2.SetRange("Document Type", ItemLedgEntry2."Document Type"::"Transfer Shipment");
                                    ItemLedgEntry2.SetFilter("Country/Region Code", '%1 | %2', '', CompanyInfo."Country/Region Code");
                                    ItemLedgEntry2.SetRange(Positive, true);
                                    if ItemLedgEntry2.IsEmpty() then
                                        exit(false);
                                end;
                            ItemLedgEntry."Document Type" = ItemLedgEntry."Document Type"::"Transfer Shipment":
                                begin
                                    if not ItemLedgEntry.Positive then
                                        exit;
                                    ItemLedgEntry2.SetCurrentKey("Order Type", "Order No.");
                                    ItemLedgEntry2.SetRange("Order Type", ItemLedgEntry."Order Type"::Transfer);
                                    ItemLedgEntry2.SetRange("Order No.", ItemLedgEntry."Order No.");
                                    ItemLedgEntry2.SetRange("Document Type", ItemLedgEntry2."Document Type"::"Transfer Receipt");
                                    ItemLedgEntry2.SetFilter("Country/Region Code", '%1 | %2', '', CompanyInfo."Country/Region Code");
                                    ItemLedgEntry2.SetRange(Positive, false);
                                    if ItemLedgEntry2.IsEmpty() then
                                        exit(false);
                                end;
                        end;
                    end;
                ItemLedgEntry."Location Code" <> '':
                    begin
                        Location.Get(ItemLedgEntry."Location Code");
                        if not CountryOfOrigin(Location."Country/Region Code") then
                            exit(false);
                    end;
                else begin
                    if ItemLedgEntry."Entry Type" = ItemLedgEntry."Entry Type"::Purchase then
                        if not CountryOfOrigin(CompanyInfo."Ship-to Country/Region Code") then
                            exit(false);
                    if ItemLedgEntry."Entry Type" = ItemLedgEntry."Entry Type"::Sale then
                        if not CountryOfOrigin(CompanyInfo."Country/Region Code") then
                            exit(false);
                end;
            end
        else
            exit(false);

        exit(true);
    end;

#if not CLEAN24
    [Obsolete('Generates false quantity in a period where an item is not moved', '24.0')]
    local procedure InsertValueEntryLine()
    var
        Location: Record Location;
        IsHandled: Boolean;
    begin
        IntrastatReportLine.Init();
        IntrastatReportLine."Intrastat No." := IntrastatReportHeader."No.";
        IntrastatReportLine."Line No." += 10000;
        IntrastatReportLine.Date := "Value Entry"."Posting Date";
        IntrastatReportLine."Country/Region Code" := "Item Ledger Entry"."Country/Region Code";
        IntrastatReportLine."Transaction Type" := "Item Ledger Entry"."Transaction Type";
        IntrastatReportLine."Transport Method" := "Item Ledger Entry"."Transport Method";
        IntrastatReportLine."Source Entry No." := "Item Ledger Entry"."Entry No.";
        IntrastatReportLine.Quantity := "Item Ledger Entry".Quantity;
        IntrastatReportLine."Document No." := "Value Entry"."Document No.";
        IntrastatReportLine."Item No." := "Item Ledger Entry"."Item No.";
        IntrastatReportLine."Entry/Exit Point" := "Item Ledger Entry"."Entry/Exit Point";
        IntrastatReportLine.Area := "Item Ledger Entry".Area;
        IntrastatReportLine."Transaction Specification" := "Item Ledger Entry"."Transaction Specification";
        IntrastatReportLine."Location Code" := "Item Ledger Entry"."Location Code";
        IntrastatReportLine.Amount := Round(Abs("Value Entry"."Sales Amount (Actual)"), 1, AmtRoundingDirection);

        SetJnlLineType(IntrastatReportLine, "Value Entry"."Document Type");

        if (IntrastatReportLine."Country/Region Code" = '') or
           (IntrastatReportLine."Country/Region Code" = CompanyInfo."Country/Region Code")
        then
            if "Item Ledger Entry"."Location Code" = '' then
                IntrastatReportLine."Country/Region Code" := CompanyInfo."Ship-to Country/Region Code"
            else begin
                Location.Get("Item Ledger Entry"."Location Code");
                IntrastatReportLine."Country/Region Code" := Location."Country/Region Code"
            end;

        IntrastatReportLine.Validate("Item No.");
        IntrastatReportLine.Validate("Source Type", IntrastatReportLine."Source Type"::"Item Entry");
        IntrastatReportLine.Validate(Quantity, Round(Abs(IntrastatReportLine.Quantity), 0.00001));
        IntrastatReportLine.Validate("Cost Regulation %", IndirectCostPctReq);

        IsHandled := false;
        OnBeforeInsertValueEntryLine(IntrastatReportLine, "Item Ledger Entry", IsHandled);
        if not IsHandled then
            IntrastatReportLine.Insert();

        IntrastatReportLine."Record ID Filter" := Format(IntrastatReportLine.RecordId);
        IntrastatReportLine.Modify();
    end;
#endif
    local procedure IsService(ItemLedgEntry: Record "Item Ledger Entry"): Boolean
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        ReturnReceiptLine: Record "Return Receipt Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesInvLine: Record "Sales Invoice Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        ReturnShipmentLine: Record "Return Shipment Line";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        ServiceShipmentLine: Record "Service Shipment Line";
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
        ServiceInvLine: Record "Service Invoice Line";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        case true of
            ItemLedgEntry."Document Type" = ItemLedgEntry."Document Type"::"Sales Shipment":
                if SalesShipmentLine.Get(ItemLedgEntry."Document No.", ItemLedgEntry."Document Line No.") then
                    if VATPostingSetup.Get(SalesShipmentLine."VAT Bus. Posting Group", SalesShipmentLine."VAT Prod. Posting Group") then;
            ItemLedgEntry."Document Type" = ItemLedgEntry."Document Type"::"Sales Return Receipt":
                if ReturnReceiptLine.Get(ItemLedgEntry."Document No.", ItemLedgEntry."Document Line No.") then
                    if VATPostingSetup.Get(ReturnReceiptLine."VAT Bus. Posting Group", ReturnReceiptLine."VAT Prod. Posting Group") then;
            ItemLedgEntry."Document Type" = ItemLedgEntry."Document Type"::"Sales Invoice":
                if SalesInvLine.Get(ItemLedgEntry."Document No.", ItemLedgEntry."Document Line No.") then
                    if VATPostingSetup.Get(SalesInvLine."VAT Bus. Posting Group", SalesInvLine."VAT Prod. Posting Group") then;
            ItemLedgEntry."Document Type" = ItemLedgEntry."Document Type"::"Sales Credit Memo":
                if SalesCrMemoLine.Get(ItemLedgEntry."Document No.", ItemLedgEntry."Document Line No.") then
                    if VATPostingSetup.Get(SalesCrMemoLine."VAT Bus. Posting Group", SalesCrMemoLine."VAT Prod. Posting Group") then;
            ItemLedgEntry."Document Type" = ItemLedgEntry."Document Type"::"Purchase Receipt":
                if PurchRcptLine.Get(ItemLedgEntry."Document No.", ItemLedgEntry."Document Line No.") then
                    if VATPostingSetup.Get(PurchRcptLine."VAT Bus. Posting Group", PurchRcptLine."VAT Prod. Posting Group") then;
            ItemLedgEntry."Document Type" = ItemLedgEntry."Document Type"::"Purchase Return Shipment":
                if ReturnShipmentLine.Get(ItemLedgEntry."Document No.", ItemLedgEntry."Document Line No.") then
                    if VATPostingSetup.Get(ReturnShipmentLine."VAT Bus. Posting Group", ReturnShipmentLine."VAT Prod. Posting Group") then;
            ItemLedgEntry."Document Type" = ItemLedgEntry."Document Type"::"Purchase Invoice":
                if PurchInvLine.Get(ItemLedgEntry."Document No.", ItemLedgEntry."Document Line No.") then
                    if VATPostingSetup.Get(PurchInvLine."VAT Bus. Posting Group", PurchInvLine."VAT Prod. Posting Group") then;
            ItemLedgEntry."Document Type" = ItemLedgEntry."Document Type"::"Purchase Credit Memo":
                if PurchCrMemoLine.Get(ItemLedgEntry."Document No.", ItemLedgEntry."Document Line No.") then
                    if VATPostingSetup.Get(PurchCrMemoLine."VAT Bus. Posting Group", PurchCrMemoLine."VAT Prod. Posting Group") then;
            ItemLedgEntry."Document Type" = ItemLedgEntry."Document Type"::"Service Shipment":
                if ServiceShipmentLine.Get(ItemLedgEntry."Document No.", ItemLedgEntry."Document Line No.") then
                    if VATPostingSetup.Get(ServiceShipmentLine."VAT Bus. Posting Group", ServiceShipmentLine."VAT Prod. Posting Group") then;
            ItemLedgEntry."Document Type" = ItemLedgEntry."Document Type"::"Service Credit Memo":
                if ServiceCrMemoLine.Get(ItemLedgEntry."Document No.", ItemLedgEntry."Document Line No.") then
                    if VATPostingSetup.Get(ServiceCrMemoLine."VAT Bus. Posting Group", ServiceCrMemoLine."VAT Prod. Posting Group") then;
            ItemLedgEntry."Document Type" = ItemLedgEntry."Document Type"::"Service Invoice":
                if ServiceInvLine.Get(ItemLedgEntry."Document No.", ItemLedgEntry."Document Line No.") then
                    if VATPostingSetup.Get(ServiceInvLine."VAT Bus. Posting Group", ServiceInvLine."VAT Prod. Posting Group") then;
        end;
        exit(VATPostingSetup."EU Service");
    end;

    local procedure CalculateTotals(ItemLedgerEntry: Record "Item Ledger Entry")
    var
        VATPostingSetup: Record "VAT Posting Setup";
        TotalInvoicedQty: Decimal;
        TotalCostAmt: Decimal;
        TotalAmtExpected: Decimal;
        TotalCostAmtExpected: Decimal;
        IsHandled, IsSkipped : Boolean;
    begin
        TotalInvoicedQty := 0;
        TotalAmt := 0;
        TotalAmtExpected := 0;
        TotalCostAmt := 0;
        TotalCostAmtExpected := 0;
        TotalIndirectCost := 0;
        TotalIndirectCostExpected := 0;
        TotalIndirectCostAmt := 0;
        TotalIndirectCostAmtExpected := 0;

        IsHandled := false;
        OnBeforeCalculateTotals(ItemLedgerEntry, IntrastatReportHeader,
            TotalAmt, TotalCostAmt, TotalAmtExpected, TotalCostAmtExpected,
            TotalIndirectCost, TotalIndirectCostAmt, TotalIndirectCostExpected, TotalIndirectCostAmtExpected, StartDate, EndDate, SkipRecalcZeroAmounts, IsHandled);
        if IsHandled then
            exit;

        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
        if ValueEntry.FindSet() then
            repeat
                IsSkipped := false;
                OnAfterSkipValueEntry(StartDate, EndDate, ValueEntry, ItemLedgerEntry, IsSkipped);
                if not IsSkipped then begin
                    TotalInvoicedQty += ValueEntry."Invoiced Quantity";
                    if not IntrastatReportHeader."Amounts in Add. Currency" then begin
                        if ValueEntry."Item Charge No." = '' then begin
                            TotalAmt += ValueEntry."Sales Amount (Actual)";
                            TotalCostAmt += ValueEntry."Cost Amount (Actual)";
                            TotalAmtExpected += ValueEntry."Sales Amount (Expected)";
                            TotalCostAmtExpected += ValueEntry."Cost Amount (Expected)";
                        end else begin
                            TotalIndirectCost += ValueEntry."Sales Amount (Actual)";
                            TotalIndirectCostAmt += ValueEntry."Cost Amount (Actual)";
                            TotalIndirectCostExpected += ValueEntry."Sales Amount (Expected)";
                            TotalIndirectCostAmtExpected += ValueEntry."Cost Amount (Expected)";
                        end;
                    end else begin
                        if ValueEntry."Item Charge No." = '' then begin
                            TotalCostAmt += ValueEntry."Cost Amount (Actual) (ACY)";
                            TotalCostAmtExpected += ValueEntry."Cost Amount (Expected) (ACY)";
                        end else begin
                            TotalIndirectCostAmt += ValueEntry."Cost Amount (Actual) (ACY)";
                            TotalIndirectCostAmtExpected += ValueEntry."Cost Amount (Expected) (ACY)";
                        end;
                        if ValueEntry."Cost per Unit" <> 0 then begin
                            if ValueEntry."Item Charge No." = '' then begin
                                TotalAmt +=
                                    ValueEntry."Sales Amount (Actual)" * ValueEntry."Cost per Unit (ACY)" / ValueEntry."Cost per Unit";
                                TotalAmtExpected +=
                                    ValueEntry."Sales Amount (Expected)" * ValueEntry."Cost per Unit (ACY)" / ValueEntry."Cost per Unit";
                            end else begin
                                TotalIndirectCost +=
                                    ValueEntry."Sales Amount (Actual)" * ValueEntry."Cost per Unit (ACY)" / ValueEntry."Cost per Unit";
                                TotalIndirectCostExpected +=
                                    ValueEntry."Sales Amount (Expected)" * ValueEntry."Cost per Unit (ACY)" / ValueEntry."Cost per Unit";
                            end;
                        end else
                            if ValueEntry."Item Charge No." = '' then begin
                                TotalAmt +=
                                    CurrExchRate.ExchangeAmtLCYToFCY(
                                        ValueEntry."Posting Date", GLSetup."Additional Reporting Currency",
                                        ValueEntry."Sales Amount (Actual)", AddCurrencyFactor);
                                TotalAmtExpected +=
                                    CurrExchRate.ExchangeAmtLCYToFCY(
                                        ValueEntry."Posting Date", GLSetup."Additional Reporting Currency",
                                        ValueEntry."Sales Amount (Expected)", AddCurrencyFactor);
                            end else begin
                                TotalIndirectCost +=
                                    CurrExchRate.ExchangeAmtLCYToFCY(
                                        ValueEntry."Posting Date", GLSetup."Additional Reporting Currency",
                                        ValueEntry."Sales Amount (Actual)", AddCurrencyFactor);
                                TotalIndirectCostExpected +=
                                    CurrExchRate.ExchangeAmtLCYToFCY(
                                        ValueEntry."Posting Date", GLSetup."Additional Reporting Currency",
                                        ValueEntry."Sales Amount (Expected)", AddCurrencyFactor);
                            end;
                    end;
                end;
            until ValueEntry.Next() = 0;

        OnCalculateTotalsOnBeforeSumTotals(ItemLedgerEntry, IntrastatReportHeader, TotalAmt, TotalCostAmt);

        if ItemLedgerEntry.Quantity <> TotalInvoicedQty then begin
            TotalAmt += TotalAmtExpected;
            TotalCostAmt += TotalCostAmtExpected;

            TotalIndirectCost += TotalIndirectCostExpected;
            TotalIndirectCostAmt += TotalIndirectCostAmtExpected;
        end;

        OnCalculateTotalsOnAfterSumTotals(ItemLedgerEntry, IntrastatReportHeader, TotalAmt, TotalCostAmt);

        if ItemLedgerEntry."Entry Type" in [ItemLedgerEntry."Entry Type"::Purchase, ItemLedgerEntry."Entry Type"::Transfer] then begin
            if TotalCostAmt = 0 then begin
                CalculateAverageCost(AverageCost, AverageCostACY);
                if IntrastatReportHeader."Amounts in Add. Currency" then
                    TotalCostAmt += ItemLedgerEntry.Quantity * AverageCostACY
                else
                    TotalCostAmt += ItemLedgerEntry.Quantity * AverageCost;
            end;
            TotalAmt := TotalCostAmt;
            TotalIndirectCost := TotalIndirectCostAmt;
        end;

        if (TotalAmt = 0) and (ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::Sale) and (not SkipRecalcZeroAmounts) then begin
            if Item."No." <> ItemLedgerEntry."Item No." then
                Item.Get(ItemLedgerEntry."Item No.");
            if IntrastatReportHeader."Amounts in Add. Currency" then
                Item."Unit Price" :=
                    CurrExchRate.ExchangeAmtLCYToFCY(
                        EndDate, GLSetup."Additional Reporting Currency",
                        Item."Unit Price", AddCurrencyFactor);
            if Item."Price Includes VAT" then begin
                VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group");
                case VATPostingSetup."VAT Calculation Type" of
                    VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT":
                        VATPostingSetup."VAT %" := 0;
                    VATPostingSetup."VAT Calculation Type"::"Sales Tax":
                        Error(
                            PricesIncludingVATErr,
                            VATPostingSetup.FieldCaption("VAT Calculation Type"),
                            VATPostingSetup."VAT Calculation Type");
                end;
                TotalAmt += ItemLedgerEntry.Quantity *
                  (Item."Unit Price" / (1 + (VATPostingSetup."VAT %" / 100)));
            end else
                TotalAmt += ItemLedgerEntry.Quantity * Item."Unit Price";
        end;

        OnAfterCalculateTotals(ItemLedgerEntry, IntrastatReportHeader,
            TotalAmt, TotalCostAmt, TotalAmtExpected, TotalCostAmtExpected,
            TotalIndirectCost, TotalIndirectCostAmt, TotalIndirectCostExpected, TotalIndirectCostAmtExpected);
    end;

    local procedure GetAmtRoundingDirection() Direction: Text[1]
    begin
        Direction := DefaultRoundingDirectionTok;
        OnAfterGetAmtRoundingDirection(Direction);
    end;

    local procedure IsJobService(JobLedgEntry: Record "Job Ledger Entry"): Boolean
    var
        Job: Record Job;
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if Job.Get(JobLedgEntry."Job No.") then
            if Customer.Get(Job."Bill-to Customer No.") then;
        if Item.Get(JobLedgEntry."No.") then
            if VATPostingSetup.Get(Customer."VAT Bus. Posting Group", Item."VAT Prod. Posting Group") then
                if VATPostingSetup."EU Service" then
                    exit(true);
        exit(false);
    end;

    local procedure IsServiceItem(ItemNo: Code[20]): Boolean
    var
        Item2: Record Item;
    begin
        exit(Item2.Get(ItemNo) and (Item2.Type = Item2.Type::Service));
    end;

    procedure InitializeRequest(NewStartDate: Date; NewEndDate: Date; NewIndirectCostPctReq: Decimal)
    begin
        StartDate := NewStartDate;
        EndDate := NewEndDate;
        IndirectCostPctReq := NewIndirectCostPctReq;
    end;

    local procedure IsItemLedgerEntryCorrected(ItemLedgerEntryCorrection: Record "Item Ledger Entry"; ItemLedgerEntryNo: Integer): Boolean
    var
        ItemApplicationEntry: Record "Item Application Entry";
    begin
        ItemApplicationEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntryCorrection."Entry No.");
        case ItemLedgerEntryCorrection."Document Type" of
            ItemLedgerEntryCorrection."Document Type"::"Sales Shipment",
          ItemLedgerEntryCorrection."Document Type"::"Purchase Return Shipment":
                ItemApplicationEntry.SetRange("Outbound Item Entry No.", ItemLedgerEntryNo);
            ItemLedgerEntryCorrection."Document Type"::"Purchase Receipt",
          ItemLedgerEntryCorrection."Document Type"::"Sales Return Receipt":
                ItemApplicationEntry.SetRange("Inbound Item Entry No.", ItemLedgerEntryNo);
        end;
        exit(not ItemApplicationEntry.IsEmpty);
    end;

    local procedure SetCountryRegionCode(var IntrastatReportLine: Record "Intrastat Report Line"; ItemLedgerEntry: Record "Item Ledger Entry")
    var
        Location: Record Location;
    begin
        if (IntrastatReportLine."Country/Region Code" = '') or
           (IntrastatReportLine."Country/Region Code" = CompanyInfo."Country/Region Code")
        then
            if ItemLedgerEntry."Location Code" = '' then
                IntrastatReportLine."Country/Region Code" := CompanyInfo."Ship-to Country/Region Code"
            else begin
                Location.Get(ItemLedgerEntry."Location Code");
                IntrastatReportLine."Country/Region Code" := Location."Country/Region Code"
            end;
    end;

#if not CLEAN24
    local procedure SetJnlLineType(var IntrastatReportLine: Record "Intrastat Report Line"; ValueEntryDocumentType: Enum "Item Ledger Document Type")
    begin
        if IntrastatReportLine.Quantity < 0 then begin
            if ValueEntryDocumentType = "Value Entry"."Document Type"::"Sales Credit Memo" then
                IntrastatReportLine.Type := IntrastatReportLine.Type::Receipt
            else
                IntrastatReportLine.Type := IntrastatReportLine.Type::Shipment
        end else
            if ValueEntryDocumentType = "Value Entry"."Document Type"::"Purchase Credit Memo" then
                IntrastatReportLine.Type := IntrastatReportLine.Type::Shipment
            else
                IntrastatReportLine.Type := IntrastatReportLine.Type::Receipt;
    end;
#endif

    [IntegrationEvent(true, false)]
    local procedure OnAfterCheckItemLedgerEntry(IntrastatReportHeader: Record "Intrastat Report Header"; ItemLedgerEntry: Record "Item Ledger Entry"; var CurrReportSkip: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCalculateTotalsCall(IntrastatReportHeader: Record "Intrastat Report Header"; var IntrastatReportLine: Record "Intrastat Report Line"; var ValueEntry: Record "Value Entry"; var ItemLedgerEntry: Record "Item Ledger Entry";
        StartDate: Date; EndDate: Date; SkipZeroAmounts: Boolean; AddCurrencyFactor: Decimal; IndirectCostPctReq: Decimal; var CurrReportSkip: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeInsertItemLedgerLineCall(IntrastatReportHeader: Record "Intrastat Report Header"; var IntrastatReportLine: Record "Intrastat Report Line"; var ValueEntry: Record "Value Entry"; var ItemLedgerEntry: Record "Item Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateTotals(var ItemLedgerEntry: Record "Item Ledger Entry"; IntrastatReportHeader: Record "Intrastat Report Header";
        var TotalAmt: Decimal; var TotalCostAmt: Decimal; var TotalAmtExpected: Decimal; var TotalCostAmtExpected: Decimal;
        var TotalIndirectCost: Decimal; var TotalIndirectCostAmt: Decimal; var TotalIndirectCostExpected: Decimal; var TotalIndirectCostAmtExpected: Decimal;
        StartDate: Date; EndDate: Date; SkipRecalcZeroAmounts: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateTotals(var ItemLedgerEntry: Record "Item Ledger Entry"; IntrastatReportHeader: Record "Intrastat Report Header";
        var TotalAmt: Decimal; var TotalCostAmt: Decimal; var TotalAmtExpected: Decimal; var TotalCostAmtExpected: Decimal;
        var TotalIndirectCost: Decimal; var TotalIndirectCostAmt: Decimal; var TotalIndirectCostExpected: Decimal; var TotalIndirectCostAmtExpected: Decimal)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeFilterItemLedgerEntry(IntrastatReportHeader: Record "Intrastat Report Header"; var ItemLedgerEntry: Record "Item Ledger Entry"; StartDate: Date; EndDate: Date; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeFilterValueEntry(IntrastatReportHeader: Record "Intrastat Report Header"; var ValueEntry: Record "Value Entry"; ItemLedgerEntry: Record "Item Ledger Entry"; StartDate: Date; EndDate: Date; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeFilterFALedgerEntry(IntrastatReportHeader: Record "Intrastat Report Header"; var FALedgerEntry: Record "FA Ledger Entry"; StartDate: Date; EndDate: Date; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterItemLedgerEntryOnPreDataItem(var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
    end;

#if not CLEAN24
    [IntegrationEvent(true, false)]
    [Obsolete('Generates false quantity in a period where an item is not moved', '24.0')]
    local procedure OnAfterValueEntryOnPreDataItem(IntrastatReportHeader: Record "Intrastat Report Header"; var ValueEntry: Record "Value Entry"; var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnBeforeHasCrossedBorder(ItemLedgerEntry: Record "Item Ledger Entry"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckDropShipment(IntrastatReportHeader: Record "Intrastat Report Header"; ItemLedgerEntry: Record "Item Ledger Entry"; Country: Record "Country/Region"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertItemLedgerLine(var IntrastatReportLine: Record "Intrastat Report Line"; ItemLedgerEntry: Record "Item Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateItemLedgerLineFields(var IntrastatReportLine: Record "Intrastat Report Line"; ItemLedgerEntry: Record "Item Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateJobLedgerLineFields(var IntrastatReportLine: Record "Intrastat Report Line"; JobLedgerEntry: Record "Job Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateFALedgerLineFields(var IntrastatReportLine: Record "Intrastat Report Line"; FALedgerEntry: Record "FA Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertJobLedgerLine(var IntrastatReportLine: Record "Intrastat Report Line"; JobLedgerEntry: Record "Job Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertFALedgerLine(var IntrastatReportLine: Record "Intrastat Report Line"; FALedgerEntry: Record "FA Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

#if not CLEAN24
    [IntegrationEvent(false, false)]
    [Obsolete('Generates false quantity in a period where an item is not moved', '24.0')]
    local procedure OnBeforeInsertValueEntryLine(var IntrastatReportLine: Record "Intrastat Report Line"; ItemLedgerEntry: Record "Item Ledger Entry"; var IsHandled: Boolean)
    begin
    end;
#endif
    [IntegrationEvent(false, false)]
    local procedure OnCalculateTotalsOnBeforeSumTotals(var ItemLedgerEntry: Record "Item Ledger Entry"; IntrastatReportHeader: Record "Intrastat Report Header"; var TotalAmt: Decimal; var TotalCostAmt: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalculateTotalsOnAfterSumTotals(var ItemLedgerEntry: Record "Item Ledger Entry"; IntrastatReportHeader: Record "Intrastat Report Header"; var TotalAmt: Decimal; var TotalCostAmt: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitRequestPage(var IntrastatReportHeader: Record "Intrastat Report Header"; var AmountInclItemCharges: Boolean; var StartDate: Date; var EndDate: Date; var CostRegulationEnable: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSkipValueEntry(StartDate: Date; EndDate: Date; ValueEntry: Record "Value Entry"; ItemLedgerEntry: Record "Item Ledger Entry"; var IsSkipped: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetAmtRoundingDirection(var Direction: Text[1]);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetIntrastatReportLineType(FALedgerEntry: Record "FA Ledger Entry"; var IntrastatReportLineType: Enum "Intrastat Report Line Type")
    begin
    end;
}