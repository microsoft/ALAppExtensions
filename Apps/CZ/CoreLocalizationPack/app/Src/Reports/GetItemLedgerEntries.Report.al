// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Shipping;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Ledger;
using Microsoft.Purchases.History;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Service.History;

report 31006 "Get Item Ledger Entries CZL"
{
    Caption = 'Get Item Ledger Entries';
    Permissions = tabledata "General Posting Setup" = imd;
    ProcessingOnly = true;
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';

    dataset
    {
        dataitem("Country/Region"; "Country/Region")
        {
            DataItemTableView = sorting("Intrastat Code") where("Intrastat Code" = filter(<> ''));
            dataitem("Item Ledger Entry"; "Item Ledger Entry")
            {
                DataItemTableView = sorting("Country/Region Code", "Entry Type", "Posting Date") where("Entry Type" = filter(Purchase | Sale | Transfer), Correction = const(false), "Intrastat Transaction CZL" = const(true));

                trigger OnAfterGetRecord()
                var
                    ItemLedgEntry: Record "Item Ledger Entry";
                begin
                    IntrastatJnlLine2.SetRange("Source Entry No.", "Entry No.");
                    if IntrastatJnlLine2.FindFirst() then
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

                    if not HasCrossedBorder("Item Ledger Entry") or IsService("Item Ledger Entry") or IsServiceItem("Item No.") then
                        CurrReport.Skip();

                    CalculateTotals("Item Ledger Entry");

                    if (TotalAmt = 0) and SkipZeroAmounts then
                        CurrReport.Skip();

                    InsertItemJnlLine();
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Posting Date", StartDate, EndDate);

                    if ("Country/Region".Code = CompanyInformation."Country/Region Code") or
                       ((CompanyInformation."Country/Region Code" = '') and not ShowBlank)
                    then begin
                        ShowBlank := true;
                        SetFilter("Country/Region Code", '%1|%2', "Country/Region".Code, '');
                    end else
                        SetRange("Country/Region Code", "Country/Region".Code);

                    IntrastatJnlLine2.SetCurrentKey("Source Type", "Source Entry No.");
                    IntrastatJnlLine2.SetRange("Source Type", IntrastatJnlLine2."Source Type"::"Item Entry");

                    ValueEntry.SetCurrentKey("Item Ledger Entry No.");
                    ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
                    ValueEntry.SetFilter(
                        "Item Ledger Entry Type", '%1|%2|%3',
                        "Item Ledger Entry Type"::Sale,
                        "Item Ledger Entry Type"::Purchase,
                        "Item Ledger Entry Type"::Transfer);
                    OnAfterItemLedgerEntryOnPreDataItem("Item Ledger Entry");
                end;
            }
            dataitem("Job Ledger Entry"; "Job Ledger Entry")
            {
                DataItemLink = "Country/Region Code" = field(Code);
                DataItemTableView = sorting(Type, "Entry Type", "Country/Region Code", "Source Code", "Posting Date") where(Type = const(Item), "Source Code" = filter(<> ''), "Entry Type" = const(Usage));

                trigger OnAfterGetRecord()
                begin
                    IntrastatJnlLine2.SetRange("Source Entry No.", "Entry No.");
                    if IntrastatJnlLine2.FindFirst() or (CompanyInformation."Country/Region Code" = "Country/Region Code") then
                        CurrReport.Skip();

                    if IsJobService("Job Ledger Entry") then
                        CurrReport.Skip();

                    InsertJobLedgerLine();
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Posting Date", StartDate, EndDate);
                    IntrastatJnlLine2.SetCurrentKey("Source Type", "Source Entry No.");
                    IntrastatJnlLine2.SetRange("Source Type", IntrastatJnlLine2."Source Type"::"Job Entry");
                end;
            }
        }
        dataitem("Value Entry"; "Value Entry")
        {
            DataItemTableView = sorting("Entry No.");

            trigger OnAfterGetRecord()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
            begin
                if ShowItemCharges then begin
                    IntrastatJnlLine2.SetRange("Source Entry No.", "Item Ledger Entry No.");
                    if IntrastatJnlLine2.FindFirst() then
                        CurrReport.Skip();

                    if "Item Ledger Entry".Get("Item Ledger Entry No.")
                    then begin
                        if "Item Ledger Entry"."Posting Date" in [StartDate .. EndDate] then
                            CurrReport.Skip();
                        if "Country/Region".Get("Item Ledger Entry"."Country/Region Code") then
                            if "Country/Region"."Intrastat Code" = '' then
                                CurrReport.Skip();
                        if "Item Ledger Entry".Correction or
                           not "Item Ledger Entry"."Intrastat Transaction CZL" or
                           not ("Item Ledger Entry"."Entry Type" in
                                ["Item Ledger Entry"."Entry Type"::Purchase,
                                 "Item Ledger Entry"."Entry Type"::Sale,
                                 "Item Ledger Entry"."Entry Type"::Transfer])
                        then
                            CurrReport.Skip();
                        if "Item Ledger Entry"."Entry Type" in
                           ["Item Ledger Entry"."Entry Type"::Sale,
                            "Item Ledger Entry"."Entry Type"::Purchase]
                        then begin
                            ItemLedgEntry.Reset();
                            ItemLedgEntry.SetCurrentKey("Document No.", "Document Type");
                            ItemLedgEntry.SetRange("Document No.", "Item Ledger Entry"."Document No.");
                            ItemLedgEntry.SetRange("Item No.", "Item Ledger Entry"."Item No.");
                            ItemLedgEntry.SetRange(Correction, true);
                            if "Item Ledger Entry"."Document Type" in
                               ["Item Ledger Entry"."Document Type"::"Sales Shipment",
                                "Item Ledger Entry"."Document Type"::"Sales Return Receipt",
                                "Item Ledger Entry"."Document Type"::"Purchase Receipt",
                                "Item Ledger Entry"."Document Type"::"Purchase Return Shipment"]
                            then begin
                                ItemLedgEntry.SetRange("Document Type", "Item Ledger Entry"."Document Type");
                                if ItemLedgEntry.FindSet() then
                                    repeat
                                        if IsItemLedgerEntryCorrected(ItemLedgEntry, "Item Ledger Entry"."Entry No.") then
                                            CurrReport.Skip();
                                    until ItemLedgEntry.Next() = 0;
                            end;
                        end;

                        if not HasCrossedBorder("Item Ledger Entry") or IsService("Item Ledger Entry") then
                            CurrReport.Skip();
                        CalculateTotals2("Value Entry");
                        InsertValueEntryLine();
                    end;
                end;
            end;

            trigger OnPreDataItem()
            begin
                if not StatutoryReportingSetupCZL."Include other Period add.Costs" then
                    CurrReport.Break();

                SetRange("Posting Date", StartDate, EndDate);
                SetFilter("Item Charge No.", '<> %1', '');
                "Item Ledger Entry".SetRange("Posting Date");

                IntrastatJnlLine2.SetRange("Journal Batch Name", IntrastatJnlBatch.Name);
                IntrastatJnlLine2.SetCurrentKey("Source Type", "Source Entry No.");
                IntrastatJnlLine2.SetRange("Source Type", IntrastatJnlLine2."Source Type"::"Item Entry");
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(StartingDate; StartDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Starting Date';
                        ToolTip = 'Specifies the date from which the report or batch job processes information.';
                    }
                    field(EndingDate; EndDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Ending Date';
                        ToolTip = 'Specifies the date to which the report or batch job processes information.';
                    }
                    field(IndirectCostPctRegField; IndirectCostPctReq)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Cost Regulation %';
                        DecimalPlaces = 0 : 5;
                        Enabled = false;
                        ToolTip = 'Specifies the cost regulation percentage to cover freight and insurance. The statistical value of every line in the journal is increased by this percentage.';
                        Visible = false;
                    }
                }
                group(Additional)
                {
                    Caption = 'Additional';
                    field(SkipRecalcForZeros; SkipRecalcZeroAmounts)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Skip Recalculation for Zero Amounts';
                        ToolTip = 'Specifies that lines without amounts will not be recalculated during the batch job.';
                    }
                    field(SkipZeros; SkipZeroAmounts)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Skip Zero Amounts';
                        ToolTip = 'Specifies that item ledger entries without amounts will not be included in the batch job.';
                    }
                    field(ShowingItemCharges; ShowItemCharges)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Item Charge Entries';
                        ToolTip = 'Specifies if you want to show direct costs that your company has assigned and posted as item charges.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            IntrastatJnlBatch.Get(IntrastatJnlLine."Journal Template Name", IntrastatJnlLine."Journal Batch Name");
            StartDate := IntrastatJnlBatch.GetStatisticsStartDate();
            EndDate := CalcDate('<CM>', StartDate);
        end;
    }

    trigger OnInitReport()
    begin
        CompanyInformation.FindFirst();
    end;

    trigger OnPreReport()
    begin
        IntrastatJnlLine.SetRange("Journal Template Name", IntrastatJnlLine."Journal Template Name");
        IntrastatJnlLine.SetRange("Journal Batch Name", IntrastatJnlLine."Journal Batch Name");
        IntrastatJnlLine.LockTable();
        if IntrastatJnlLine.FindLast() then;

        IntrastatJnlBatch.Get(IntrastatJnlLine."Journal Template Name", IntrastatJnlLine."Journal Batch Name");
        IntrastatJnlBatch.TestField(Reported, false);

        GetGLSetup();
        if IntrastatJnlBatch."Amounts in Add. Currency" then begin
            GeneralLedgerSetup.TestField("Additional Reporting Currency");
            AddCurrencyFactor :=
              CurrencyExchangeRate.ExchangeRate(EndDate, GeneralLedgerSetup."Additional Reporting Currency");
        end;

        GetStatReportingSetup();
        case StatutoryReportingSetupCZL."Intrastat Rounding Type" of
            StatutoryReportingSetupCZL."Intrastat Rounding Type"::Nearest:
                Direction := '=';
            StatutoryReportingSetupCZL."Intrastat Rounding Type"::Up:
                Direction := '>';
            StatutoryReportingSetupCZL."Intrastat Rounding Type"::Down:
                Direction := '<';
        end;
        IndirectCostPctReq := StatutoryReportingSetupCZL."Cost Regulation %";
    end;

    var
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        Currency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        IntrastatJnlBatch: Record "Intrastat Jnl. Batch";
        IntrastatJnlLine: Record "Intrastat Jnl. Line";
        IntrastatJnlLine2: Record "Intrastat Jnl. Line";
        Item: Record Item;
        ValueEntry: Record "Value Entry";
        UnitofMeasureManagement: Codeunit "Unit of Measure Management";
        ShowBlank: Boolean;
        ShowItemCharges: Boolean;
        SkipRecalcZeroAmounts: Boolean;
        SkipZeroAmounts: Boolean;
        GLSetupRead: Boolean;
        StatReportingSetupRead: Boolean;
        EndDate: Date;
        StartDate: Date;
        AddCurrencyFactor: Decimal;
        AverageCost: Decimal;
        AverageCostACY: Decimal;
        IndirectCostPctReq: Decimal;
        TotalAmt: Decimal;
        TotalCostAmt2: Decimal;
        TotalICAmt: array[2] of Decimal;
        TotalICAmtExpected: array[2] of Decimal;
        TotalICCostAmt: array[2] of Decimal;
        TotalICCostAmtExpected: array[2] of Decimal;
        Direction: Text[1];
        CannotBeCalculatedErr: Label 'Prices including VAT cannot be calculated when %1 is %2.', Comment = '%1 = fieldcaption VAT calculation type, %2 = VAT calculation type';

    procedure SetIntrastatJnlLine(NewIntrastatJnlLine: Record "Intrastat Jnl. Line")
    begin
        IntrastatJnlLine := NewIntrastatJnlLine;
    end;

    local procedure InsertItemJnlLine()
    var
        TempSalesHeader: Record "Sales Header" temporary;
        IsHandled: Boolean;
        DocumentCurrencyFactor: Decimal;
        IntrastatCurrencyFactor: Decimal;
    begin
        GetGLSetup();
        GetDocumentFromItemLedgEntry("Item Ledger Entry", TempSalesHeader);
        DocumentCurrencyFactor := TempSalesHeader."Currency Factor";
        IntrastatCurrencyFactor := TempSalesHeader."VAT Currency Factor CZL";
        IntrastatJnlLine.Init();
        IntrastatJnlLine."Line No." := IntrastatJnlLine."Line No." + 10000;
        IntrastatJnlLine.Date := "Item Ledger Entry"."Posting Date";
        IntrastatJnlLine."Country/Region Code" := "Item Ledger Entry"."Country/Region Code";
        IntrastatJnlLine."Transaction Type" := "Item Ledger Entry"."Transaction Type";
        IntrastatJnlLine."Transport Method" := "Item Ledger Entry"."Transport Method";
        IntrastatJnlLine."Source Entry No." := "Item Ledger Entry"."Entry No.";
        IntrastatJnlLine.Quantity := "Item Ledger Entry".Quantity;
        IntrastatJnlLine."Document No." := "Item Ledger Entry"."Document No.";
        IntrastatJnlLine.Validate("Item No.", "Item Ledger Entry"."Item No.");
        IntrastatJnlLine."Entry/Exit Point" := "Item Ledger Entry"."Entry/Exit Point";
        IntrastatJnlLine."Area" := "Item Ledger Entry".Area;
        IntrastatJnlLine."Transaction Specification" := "Item Ledger Entry"."Transaction Specification";
        IntrastatJnlLine."Shpt. Method Code" := "Item Ledger Entry"."Shpt. Method Code";
        IntrastatJnlLine."Location Code" := "Item Ledger Entry"."Location Code";
        CalcDataForItemJnlLine();
        IntrastatJnlLine."Source Type" := IntrastatJnlLine."Source Type"::"Item Entry";
        case "Item Ledger Entry"."Entry Type" of
            "Item Ledger Entry"."Entry Type"::Purchase:
                if "Item Ledger Entry"."Physical Transfer CZL" then begin
                    IntrastatJnlLine.Type := IntrastatJnlLine.Type::Shipment;
                    IntrastatJnlLine.Amount := Round(Abs(TotalCostAmt2 + TotalICCostAmt[1]), 1, Direction);
                    IntrastatJnlLine.Validate(Quantity, Abs(IntrastatJnlLine.Quantity));
                end else
                    if "Item Ledger Entry".Quantity > 0 then begin
                        IntrastatJnlLine.Type := IntrastatJnlLine.Type::Receipt;
                        IntrastatJnlLine.Amount := Round(Abs(TotalCostAmt2 + TotalICCostAmt[1]), 1, Direction);
                        IntrastatJnlLine.Validate(Quantity, Abs(IntrastatJnlLine.Quantity));
                    end else begin
                        IntrastatJnlLine.Type := IntrastatJnlLine.Type::Receipt;
                        IntrastatJnlLine.Amount := -Round(Abs(TotalCostAmt2 + TotalICCostAmt[1]), 1, Direction);
                        IntrastatJnlLine.Validate(Quantity, -Abs(IntrastatJnlLine.Quantity));
                    end;
            "Item Ledger Entry"."Entry Type"::Sale:
                if "Item Ledger Entry"."Physical Transfer CZL" then begin
                    IntrastatJnlLine.Type := IntrastatJnlLine.Type::Receipt;
                    IntrastatJnlLine.Amount := Round(Abs(TotalAmt + TotalICAmt[1]), 1, Direction);
                    IntrastatJnlLine.Validate(Quantity, IntrastatJnlLine.RoundValueCZL(Abs(IntrastatJnlLine.Quantity)));
                end else
                    if "Item Ledger Entry".Quantity < 0 then begin
                        IntrastatJnlLine.Type := IntrastatJnlLine.Type::Shipment;
                        IntrastatJnlLine.Amount := Round(Abs(TotalAmt + TotalICAmt[1]), 1, Direction);
                        IntrastatJnlLine.Validate(Quantity, Abs(IntrastatJnlLine.Quantity));
                    end else begin
                        IntrastatJnlLine.Type := IntrastatJnlLine.Type::Shipment;
                        IntrastatJnlLine.Amount := -Round(Abs(TotalAmt + TotalICAmt[1]), 1, Direction);
                        IntrastatJnlLine.Validate(Quantity, -Abs(IntrastatJnlLine.Quantity));
                    end;
            "Item Ledger Entry"."Entry Type"::Transfer:
                if "Item Ledger Entry".Quantity < 0 then begin
                    IntrastatJnlLine.Type := IntrastatJnlLine.Type::Shipment;
                    IntrastatJnlLine.Amount := Round(Abs(TotalCostAmt2 + TotalICCostAmt[1]), 1, Direction);
                    IntrastatJnlLine.Validate(Quantity, Abs(IntrastatJnlLine.Quantity));
                end else begin
                    IntrastatJnlLine.Type := IntrastatJnlLine.Type::Receipt;
                    IntrastatJnlLine.Amount := Round(Abs(TotalCostAmt2 + TotalICCostAmt[1]), 1, Direction);
                    IntrastatJnlLine.Validate(Quantity, Abs(IntrastatJnlLine.Quantity));
                end;
        end;
        IntrastatJnlLine."Cost Regulation %" := IndirectCostPctReq;
        CalcStatValue();

        IntrastatJnlLine.Amount := Round(CalculateExchangeAmount(IntrastatJnlLine.Amount, DocumentCurrencyFactor, IntrastatCurrencyFactor), 1, Direction);
        IntrastatJnlLine."Statistical Value" :=
          Round(CalculateExchangeAmount(IntrastatJnlLine."Statistical Value", DocumentCurrencyFactor, IntrastatCurrencyFactor), 1, Direction);
        IntrastatJnlLine."Indirect Cost" :=
          Round(CalculateExchangeAmount(IntrastatJnlLine."Indirect Cost", DocumentCurrencyFactor, IntrastatCurrencyFactor), 1, Direction);
        IntrastatJnlLine."Source Entry Date CZL" := "Item Ledger Entry"."Posting Date";
        IntrastatJnlLine.Validate("Source Type", IntrastatJnlLine."Source Type"::"Item Entry");

        IsHandled := false;
        OnBeforeInsertItemJnlLine(IntrastatJnlLine, "Item Ledger Entry", IsHandled);
        if not IsHandled then
            IntrastatJnlLine.Insert();
    end;

    local procedure InsertJobLedgerLine()
    var
        IsCorrection: Boolean;
        IsHandled: Boolean;
    begin
        IntrastatJnlLine.Init();
        IntrastatJnlLine."Line No." := IntrastatJnlLine."Line No." + 10000;

        IntrastatJnlLine.Date := "Job Ledger Entry"."Posting Date";
        IntrastatJnlLine."Country/Region Code" := "Job Ledger Entry"."Country/Region Code";
        IntrastatJnlLine."Transaction Type" := "Job Ledger Entry"."Transaction Type";
        IntrastatJnlLine."Transport Method" := "Job Ledger Entry"."Transport Method";
        IntrastatJnlLine.Quantity := "Job Ledger Entry"."Quantity (Base)";
        CalcDataForJobJnlLine();
        IsCorrection := "Job Ledger Entry"."Correction CZL";
        if (IntrastatJnlLine.Quantity > 0) xor IsCorrection then
            IntrastatJnlLine.Type := IntrastatJnlLine.Type::Shipment
        else
            IntrastatJnlLine.Type := IntrastatJnlLine.Type::Receipt;
        if IntrastatJnlBatch."Amounts in Add. Currency" then
            IntrastatJnlLine.Amount := "Job Ledger Entry"."Add.-Currency Line Amount"
        else
            IntrastatJnlLine.Amount := "Job Ledger Entry"."Line Amount (LCY)";
        IntrastatJnlLine."Source Entry No." := "Job Ledger Entry"."Entry No.";
        IntrastatJnlLine."Document No." := "Job Ledger Entry"."Document No.";
        IntrastatJnlLine."Item No." := "Job Ledger Entry"."No.";
        IntrastatJnlLine."Entry/Exit Point" := "Job Ledger Entry"."Entry/Exit Point";
        IntrastatJnlLine."Area" := "Job Ledger Entry".Area;
        IntrastatJnlLine."Transaction Specification" := "Job Ledger Entry"."Transaction Specification";
        IntrastatJnlLine."Shpt. Method Code" := "Job Ledger Entry"."Shpt. Method Code";
        IntrastatJnlLine."Location Code" := "Job Ledger Entry"."Location Code";

        if IntrastatJnlBatch."Amounts in Add. Currency" then
            IntrastatJnlLine.Amount := Round(Abs(IntrastatJnlLine.Amount), Currency."Amount Rounding Precision", Direction)
        else
            IntrastatJnlLine.Amount := Round(Abs(IntrastatJnlLine.Amount), GeneralLedgerSetup."Amount Rounding Precision", Direction);
        IntrastatJnlLine.Validate("Item No.");
        IntrastatJnlLine.Validate("Source Type", IntrastatJnlLine."Source Type"::"Job Entry");
        IntrastatJnlLine.Validate(Quantity, Round(Abs(IntrastatJnlLine.Quantity), 0.00001));

        IntrastatJnlLine.Validate("Cost Regulation %", IndirectCostPctReq);
        if IsCorrection then begin
            IntrastatJnlLine.Quantity := -IntrastatJnlLine.Quantity;
            IntrastatJnlLine.Amount := -IntrastatJnlLine.Amount;
            IntrastatJnlLine."Statistical Value" := -IntrastatJnlLine."Statistical Value";
        end;
        IntrastatJnlLine."Source Entry Date CZL" := "Job Ledger Entry"."Posting Date";
        IsHandled := false;
        OnBeforeInsertJobLedgerLine(IntrastatJnlLine, "Job Ledger Entry", IsHandled);
        if not IsHandled then
            IntrastatJnlLine.Insert();
    end;

    local procedure GetGLSetup()
    begin
        if not GLSetupRead then begin
            GeneralLedgerSetup.Get();
            if GeneralLedgerSetup."Additional Reporting Currency" <> '' then
                Currency.Get(GeneralLedgerSetup."Additional Reporting Currency");
        end;
        GLSetupRead := true;
    end;

    local procedure GetStatReportingSetup()
    begin
        if not StatReportingSetupRead then
            StatutoryReportingSetupCZL.Get();
        StatReportingSetupRead := true;
    end;

    local procedure CalculateAverageCost(var AverageCost: Decimal; var AverageCostACY: Decimal): Boolean
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry2: Record "Value Entry";
        AverageQty: Decimal;
    begin
        ItemLedgerEntry.SetCurrentKey(ItemLedgerEntry."Item No.", ItemLedgerEntry."Entry Type");
        ItemLedgerEntry.SetRange(ItemLedgerEntry."Item No.", "Item Ledger Entry"."Item No.");
        ItemLedgerEntry.SetRange(ItemLedgerEntry."Entry Type", "Item Ledger Entry"."Entry Type");
        ItemLedgerEntry.CalcSums(ItemLedgerEntry.Quantity);

        ValueEntry2.SetCurrentKey(ValueEntry2."Item No.", ValueEntry2."Posting Date", ValueEntry2."Item Ledger Entry Type");
        ValueEntry2.SetRange(ValueEntry2."Item No.", "Item Ledger Entry"."Item No.");
        ValueEntry2.SetRange(ValueEntry2."Item Ledger Entry Type", "Item Ledger Entry"."Entry Type");
        ValueEntry2.CalcSums(
          ValueEntry2."Cost Amount (Actual)",
          ValueEntry2."Cost Amount (Expected)");
        ValueEntry2."Cost Amount (Actual) (ACY)" :=
          CurrencyExchangeRate.ExchangeAmtLCYToFCY(
            EndDate, GeneralLedgerSetup."Additional Reporting Currency", ValueEntry2."Cost Amount (Actual)", AddCurrencyFactor);
        ValueEntry2."Cost Amount (Expected) (ACY)" :=
          CurrencyExchangeRate.ExchangeAmtLCYToFCY(
            EndDate, GeneralLedgerSetup."Additional Reporting Currency", ValueEntry2."Cost Amount (Expected)", AddCurrencyFactor);
        AverageQty := ItemLedgerEntry.Quantity;
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
        if ("Item Ledger Entry"."Country/Region Code" in [CompanyInformation."Country/Region Code", '']) =
           (CountryRegionCode in [CompanyInformation."Country/Region Code", ''])
        then
            exit(false);

        if CountryRegionCode <> '' then begin
            CountryRegion.Get(CountryRegionCode);
            if CountryRegion."Intrastat Code" = '' then
                exit(false);
        end;
        exit(true);
    end;

    local procedure HasCrossedBorder(ItemLedgerEntry: Record "Item Ledger Entry") Result: Boolean
    var
        ItemLedgerEntry2: Record "Item Ledger Entry";
        Location: Record Location;
        Include: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeHasCrossedBorder(ItemLedgerEntry, Result, IsHandled);
        if IsHandled then
            exit(Result);

        case true of
            ItemLedgerEntry."Drop Shipment":
                begin
                    if (ItemLedgerEntry."Country/Region Code" = CompanyInformation."Country/Region Code") or
                       (ItemLedgerEntry."Country/Region Code" = '')
                    then
                        exit(false);
                    if ItemLedgerEntry."Applies-to Entry" = 0 then begin
                        ItemLedgerEntry2.SetCurrentKey("Item No.", "Posting Date");
                        ItemLedgerEntry2.SetRange("Item No.", ItemLedgerEntry."Item No.");
                        ItemLedgerEntry2.SetRange("Posting Date", ItemLedgerEntry."Posting Date");
                        ItemLedgerEntry2.SetRange("Applies-to Entry", ItemLedgerEntry."Entry No.");
                        ItemLedgerEntry2.FindFirst();
                    end else
                        ItemLedgerEntry2.Get(ItemLedgerEntry."Applies-to Entry");
                    if (ItemLedgerEntry2."Country/Region Code" <> CompanyInformation."Country/Region Code") and
                       (ItemLedgerEntry2."Country/Region Code" <> '')
                    then
                        exit(false);
                end;
            ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::Transfer:
                begin
                    if (ItemLedgerEntry."Country/Region Code" = CompanyInformation."Country/Region Code") or
                       (ItemLedgerEntry."Country/Region Code" = '')
                    then
                        exit(false);
                    if (ItemLedgerEntry."Order Type" <> ItemLedgerEntry."Order Type"::Transfer) or (ItemLedgerEntry."Order No." = '') then begin
                        Location.Get(ItemLedgerEntry."Location Code");
                        if (Location."Country/Region Code" <> '') and
                           (Location."Country/Region Code" <> CompanyInformation."Country/Region Code")
                        then
                            exit(false);
                    end else begin
                        ItemLedgerEntry2.SetCurrentKey("Order Type", "Order No.");
                        ItemLedgerEntry2.SetRange("Order Type", ItemLedgerEntry."Order Type"::Transfer);
                        ItemLedgerEntry2.SetRange("Order No.", ItemLedgerEntry."Order No.");
                        ItemLedgerEntry2.SetFilter("Country/Region Code", '%1 | %2', '', CompanyInformation."Country/Region Code");
                        ItemLedgerEntry2.SetFilter("Location Code", '<>%1', '');
                        if ItemLedgerEntry2.FindSet() then
                            repeat
                                Location.Get(ItemLedgerEntry2."Location Code");
                                if Location."Use As In-Transit" then
                                    Include := true;
                            until Include or (ItemLedgerEntry2.Next() = 0);
                        if not Include then
                            exit(false);
                    end;
                end;
            ItemLedgerEntry."Location Code" <> '':
                begin
                    Location.Get(ItemLedgerEntry."Location Code");
                    if not CountryOfOrigin(Location."Country/Region Code") then
                        exit(false);
                end;
            else begin
                if ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::Purchase then
                    if not CountryOfOrigin(CompanyInformation."Ship-to Country/Region Code") then
                        exit(false);
                if ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::Sale then
                    if not CountryOfOrigin(CompanyInformation."Country/Region Code") then
                        exit(false);
            end;
        end;
        exit(true);
    end;

    local procedure InsertValueEntryLine()
    var
        TempSalesHeader: Record "Sales Header" temporary;
        IsHandled: Boolean;
        DocumentCurrencyFactor: Decimal;
        IntrastatCurrencyFactor: Decimal;
    begin
        GetGLSetup();
        GetDocumentFromValueEntry("Value Entry", TempSalesHeader);
        DocumentCurrencyFactor := TempSalesHeader."Currency Factor";
        IntrastatCurrencyFactor := TempSalesHeader."VAT Currency Factor CZL";
        IntrastatJnlLine.Init();
        IntrastatJnlLine."Line No." := IntrastatJnlLine."Line No." + 10000;
        IntrastatJnlLine.Date := "Value Entry"."Posting Date";
        IntrastatJnlLine."Country/Region Code" := "Item Ledger Entry"."Country/Region Code";
        IntrastatJnlLine."Transaction Type" := "Item Ledger Entry"."Transaction Type";
        IntrastatJnlLine."Transport Method" := "Item Ledger Entry"."Transport Method";
        IntrastatJnlLine."Source Entry No." := "Item Ledger Entry"."Entry No.";
        IntrastatJnlLine.Quantity := "Item Ledger Entry".Quantity;
        IntrastatJnlLine."Document No." := "Value Entry"."Document No.";
        IntrastatJnlLine.Validate("Item No.", "Item Ledger Entry"."Item No.");
        IntrastatJnlLine."Entry/Exit Point" := "Item Ledger Entry"."Entry/Exit Point";
        IntrastatJnlLine."Area" := "Item Ledger Entry".Area;
        IntrastatJnlLine."Transaction Specification" := "Item Ledger Entry"."Transaction Specification";
        IntrastatJnlLine."Location Code" := "Item Ledger Entry"."Location Code";
        CalcDataForItemJnlLine();
        IntrastatJnlLine."Source Type" := IntrastatJnlLine."Source Type"::"Item Entry";
        case "Item Ledger Entry"."Entry Type" of
            "Item Ledger Entry"."Entry Type"::Purchase:
                if "Item Ledger Entry"."Physical Transfer CZL" then begin
                    IntrastatJnlLine.Type := IntrastatJnlLine.Type::Shipment;
                    IntrastatJnlLine.Amount := Round(Abs(TotalICCostAmt[1]), 1, Direction);
                    IntrastatJnlLine.Validate(Quantity, Abs(IntrastatJnlLine.Quantity));
                end else
                    if "Item Ledger Entry".Quantity > 0 then begin
                        IntrastatJnlLine.Type := IntrastatJnlLine.Type::Receipt;
                        IntrastatJnlLine.Amount := Round(Abs(TotalICCostAmt[1]), 1, Direction);
                        IntrastatJnlLine.Validate(Quantity, Abs(IntrastatJnlLine.Quantity));
                    end else begin
                        IntrastatJnlLine.Type := IntrastatJnlLine.Type::Receipt;
                        IntrastatJnlLine.Amount := -Round(Abs(TotalICCostAmt[1]), 1, Direction);
                        IntrastatJnlLine.Validate(Quantity, -Abs(IntrastatJnlLine.Quantity));
                    end;
            "Item Ledger Entry"."Entry Type"::Sale:
                if "Item Ledger Entry"."Physical Transfer CZL" then begin
                    IntrastatJnlLine.Type := IntrastatJnlLine.Type::Receipt;
                    IntrastatJnlLine.Amount := Round(Abs(TotalAmt + TotalICAmt[1]), 1, Direction);
                    IntrastatJnlLine.Validate(Quantity, IntrastatJnlLine.RoundValueCZL(Abs(IntrastatJnlLine.Quantity)));
                end else
                    if "Item Ledger Entry".Quantity < 0 then begin
                        IntrastatJnlLine.Type := IntrastatJnlLine.Type::Shipment;
                        IntrastatJnlLine.Amount := Round(Abs(TotalICAmt[1]), 1, Direction);
                        IntrastatJnlLine.Validate(Quantity, Abs(IntrastatJnlLine.Quantity));
                    end else begin
                        IntrastatJnlLine.Type := IntrastatJnlLine.Type::Shipment;
                        IntrastatJnlLine.Amount := -Round(Abs(TotalICAmt[1]), 1, Direction);
                        IntrastatJnlLine.Validate(Quantity, -Abs(IntrastatJnlLine.Quantity));
                    end;
            "Item Ledger Entry"."Entry Type"::Transfer:
                if "Item Ledger Entry".Quantity < 0 then begin
                    IntrastatJnlLine.Type := IntrastatJnlLine.Type::Shipment;
                    IntrastatJnlLine.Amount := Round(Abs(TotalICCostAmt[1]), 1, Direction);
                    IntrastatJnlLine.Validate(Quantity, Abs(IntrastatJnlLine.Quantity));
                end else begin
                    IntrastatJnlLine.Type := IntrastatJnlLine.Type::Receipt;
                    IntrastatJnlLine.Amount := Round(Abs(TotalICCostAmt[1]), 1, Direction);
                    IntrastatJnlLine.Validate(Quantity, Abs(IntrastatJnlLine.Quantity));
                end;
        end;
        IntrastatJnlLine."Cost Regulation %" := IndirectCostPctReq;
        CalcStatValue();

        IntrastatJnlLine.Amount := Round(CalculateExchangeAmount(IntrastatJnlLine.Amount, DocumentCurrencyFactor, IntrastatCurrencyFactor), 1, Direction);
        IntrastatJnlLine."Statistical Value" :=
          Round(CalculateExchangeAmount(IntrastatJnlLine."Statistical Value", DocumentCurrencyFactor, IntrastatCurrencyFactor), 1, Direction);
        IntrastatJnlLine."Indirect Cost" :=
          Round(CalculateExchangeAmount(IntrastatJnlLine."Indirect Cost", DocumentCurrencyFactor, IntrastatCurrencyFactor), 1, Direction);

        IntrastatJnlLine."Additional Costs CZL" := true;
        IntrastatJnlLine."Source Entry Date CZL" := "Item Ledger Entry"."Posting Date";
        IntrastatJnlLine.Validate("Source Type", IntrastatJnlLine."Source Type"::"Item Entry");

        IsHandled := false;
        OnBeforeInsertValueEntryLine(IntrastatJnlLine, "Item Ledger Entry", IsHandled);
        if not IsHandled then
            IntrastatJnlLine.Insert();

    end;

    local procedure IsService(ItemLedgerEntry: Record "Item Ledger Entry"): Boolean
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        ReturnReceiptLine: Record "Return Receipt Line";
        ReturnShipmentLine: Record "Return Shipment Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesShipmentLine: Record "Sales Shipment Line";
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
        ServiceInvoiceLine: Record "Service Invoice Line";
        ServiceShipmentLine: Record "Service Shipment Line";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        case true of
            ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Sales Shipment":
                if SalesShipmentLine.Get(ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.") then
                    if VATPostingSetup.Get(SalesShipmentLine."VAT Bus. Posting Group", SalesShipmentLine."VAT Prod. Posting Group") then;
            ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Sales Return Receipt":
                if ReturnReceiptLine.Get(ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.") then
                    if VATPostingSetup.Get(ReturnReceiptLine."VAT Bus. Posting Group", ReturnReceiptLine."VAT Prod. Posting Group") then;
            ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Sales Invoice":
                if SalesInvoiceLine.Get(ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.") then
                    if VATPostingSetup.Get(SalesInvoiceLine."VAT Bus. Posting Group", SalesInvoiceLine."VAT Prod. Posting Group") then;
            ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Sales Credit Memo":
                if SalesCrMemoLine.Get(ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.") then
                    if VATPostingSetup.Get(SalesCrMemoLine."VAT Bus. Posting Group", SalesCrMemoLine."VAT Prod. Posting Group") then;
            ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Purchase Receipt":
                if PurchRcptLine.Get(ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.") then
                    if VATPostingSetup.Get(PurchRcptLine."VAT Bus. Posting Group", PurchRcptLine."VAT Prod. Posting Group") then;
            ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Purchase Return Shipment":
                if ReturnShipmentLine.Get(ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.") then
                    if VATPostingSetup.Get(ReturnShipmentLine."VAT Bus. Posting Group", ReturnShipmentLine."VAT Prod. Posting Group") then;
            ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Purchase Invoice":
                if PurchInvLine.Get(ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.") then
                    if VATPostingSetup.Get(PurchInvLine."VAT Bus. Posting Group", PurchInvLine."VAT Prod. Posting Group") then;
            ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Purchase Credit Memo":
                if PurchCrMemoLine.Get(ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.") then
                    if VATPostingSetup.Get(PurchCrMemoLine."VAT Bus. Posting Group", PurchCrMemoLine."VAT Prod. Posting Group") then;
            ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Service Shipment":
                if ServiceShipmentLine.Get(ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.") then
                    if VATPostingSetup.Get(ServiceShipmentLine."VAT Bus. Posting Group", ServiceShipmentLine."VAT Prod. Posting Group") then;
            ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Service Credit Memo":
                if ServiceCrMemoLine.Get(ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.") then
                    if VATPostingSetup.Get(ServiceCrMemoLine."VAT Bus. Posting Group", ServiceCrMemoLine."VAT Prod. Posting Group") then;
            ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Service Invoice":
                if ServiceInvoiceLine.Get(ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.") then
                    if VATPostingSetup.Get(ServiceInvoiceLine."VAT Bus. Posting Group", ServiceInvoiceLine."VAT Prod. Posting Group") then;
        end;
        exit(VATPostingSetup."Intrastat Service CZL");
    end;

    local procedure CalculateTotals(ItemLedgerEntry: Record "Item Ledger Entry")
    var
        VATPostingSetup: Record "VAT Posting Setup";
        TotalAmtExpected: Decimal;
        TotalCostAmt: Decimal;
        TotalCostAmtExpected: Decimal;
        TotalInvoicedQty: Decimal;
    begin
        TotalInvoicedQty := 0;
        TotalAmt := 0;
        TotalAmtExpected := 0;
        TotalCostAmt := 0;
        TotalCostAmtExpected := 0;
        Clear(TotalICAmt);
        Clear(TotalICCostAmt);
        TotalCostAmt2 := 0;
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
        ValueEntry.SetRange("Posting Date", StartDate, EndDate);
        if ValueEntry.FindSet() then
            repeat
                if ValueEntry."Item Charge No." = '' then begin
                    // Calculate item amount                    
                    TotalInvoicedQty := TotalInvoicedQty + ValueEntry."Invoiced Quantity";
                    if not IntrastatJnlBatch."Amounts in Add. Currency" then begin
                        TotalAmt := TotalAmt + ValueEntry."Sales Amount (Actual)";
                        TotalCostAmt := TotalCostAmt + ValueEntry."Cost Amount (Actual)";
                        TotalAmtExpected := TotalAmtExpected + ValueEntry."Sales Amount (Expected)";
                        TotalCostAmtExpected := TotalCostAmtExpected + ValueEntry."Cost Amount (Expected)";
                    end else begin
                        TotalCostAmt := TotalCostAmt + ValueEntry."Cost Amount (Actual) (ACY)";
                        TotalCostAmtExpected := TotalCostAmtExpected + ValueEntry."Cost Amount (Expected) (ACY)";
                        if ValueEntry."Cost per Unit" <> 0 then begin
                            TotalAmt :=
                              TotalAmt +
                              ValueEntry."Sales Amount (Actual)" * ValueEntry."Cost per Unit (ACY)" / ValueEntry."Cost per Unit";
                            TotalAmtExpected :=
                              TotalAmtExpected +
                              ValueEntry."Sales Amount (Expected)" * ValueEntry."Cost per Unit (ACY)" / ValueEntry."Cost per Unit";
                        end else begin
                            TotalAmt :=
                              TotalAmt +
                              CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                                ValueEntry."Posting Date", GeneralLedgerSetup."Additional Reporting Currency",
                                ValueEntry."Sales Amount (Actual)", AddCurrencyFactor);
                            TotalAmtExpected :=
                              TotalAmtExpected +
                              CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                                ValueEntry."Posting Date", GeneralLedgerSetup."Additional Reporting Currency",
                                ValueEntry."Sales Amount (Expected)", AddCurrencyFactor);
                        end;
                    end;
                end else begin
                    // Item charge processing
                    if ValueEntry."Incl. in Intrastat Amount CZL" then
                        CalcTotalsForItemCharge(TotalICAmt[1], TotalICCostAmt[1], TotalICAmtExpected[1], TotalICCostAmtExpected[1]);
                    if ValueEntry."Incl. in Intrastat S.Value CZL" then
                        CalcTotalsForItemCharge(TotalICAmt[2], TotalICCostAmt[2], TotalICAmtExpected[2], TotalICCostAmtExpected[2]);
                end;
            until ValueEntry.Next() = 0;

        if ItemLedgerEntry.Quantity <> TotalInvoicedQty then begin
            TotalAmt := TotalAmt + TotalAmtExpected;
            TotalCostAmt := TotalCostAmt + TotalCostAmtExpected;
            TotalICAmt[1] := TotalICAmtExpected[1];
            TotalICCostAmt[1] := TotalICCostAmtExpected[1];
            TotalICAmt[2] := TotalICAmtExpected[2];
            TotalICCostAmt[2] := TotalICCostAmtExpected[2];
        end;

        OnCalculateTotalsOnAfterSumTotals(ItemLedgerEntry, IntrastatJnlBatch, TotalAmt, TotalCostAmt);

        if ItemLedgerEntry."Entry Type" in [ItemLedgerEntry."Entry Type"::Purchase, ItemLedgerEntry."Entry Type"::Transfer] then begin
            if TotalCostAmt = 0 then begin
                CalculateAverageCost(AverageCost, AverageCostACY);
                if IntrastatJnlBatch."Amounts in Add. Currency" then
                    TotalCostAmt :=
                      TotalCostAmt + ItemLedgerEntry.Quantity * AverageCostACY
                else
                    TotalCostAmt :=
                      TotalCostAmt + ItemLedgerEntry.Quantity * AverageCost;
            end;
            TotalAmt := TotalCostAmt;
        end;

        if (TotalAmt = 0) and (ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::Sale) and (not SkipRecalcZeroAmounts) then begin
            if Item."No." <> ItemLedgerEntry."Item No." then
                Item.Get(ItemLedgerEntry."Item No.");
            if IntrastatJnlBatch."Amounts in Add. Currency" then
                Item."Unit Price" :=
                  CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                    EndDate, GeneralLedgerSetup."Additional Reporting Currency",
                    Item."Unit Price", AddCurrencyFactor);
            if Item."Price Includes VAT" then begin
                VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group");
                case VATPostingSetup."VAT Calculation Type" of
                    VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT":
                        VATPostingSetup."VAT %" := 0;
                    VATPostingSetup."VAT Calculation Type"::"Sales Tax":
                        Error(
                          CannotBeCalculatedErr,
                          VATPostingSetup.FieldCaption("VAT Calculation Type"),
                          VATPostingSetup."VAT Calculation Type");
                end;
                TotalAmt :=
                  TotalAmt + ItemLedgerEntry.Quantity *
                  (Item."Unit Price" / (1 + (VATPostingSetup."VAT %" / 100)));
            end else
                TotalAmt := TotalAmt + ItemLedgerEntry.Quantity * Item."Unit Price";
        end;
        TotalCostAmt2 := TotalCostAmt;

        OnAfterCalculateTotals(ItemLedgerEntry, IntrastatJnlBatch, TotalAmt, TotalCostAmt);
    end;

    local procedure IsJobService(JobLedgerEntry: Record "Job Ledger Entry"): Boolean
    var
        Customer: Record Customer;
        Job: Record Job;
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if Job.Get(JobLedgerEntry."Job No.") then
            if Customer.Get(Job."Bill-to Customer No.") then;
        if Item.Get(JobLedgerEntry."No.") then
            if VATPostingSetup.Get(Customer."VAT Bus. Posting Group", Item."VAT Prod. Posting Group") then
                if VATPostingSetup."Intrastat Service CZL" then
                    exit(true);
        exit(false);
    end;

    local procedure IsServiceItem(ItemNo: Code[20]): Boolean
    var
        Item2: Record Item;
    begin
        exit(Item2.Get(ItemNo) and (Item2.IsServiceType()));
    end;

    procedure InitializeRequest(NewStartDate: Date; NewEndDate: Date; NewIndirectCostPctReq: Decimal)
    begin
        StartDate := NewStartDate;
        EndDate := NewEndDate;
        IndirectCostPctReq := NewIndirectCostPctReq;
    end;

    procedure CalcTotalsForItemCharge(var TotalICAmt1: Decimal; var TotalICCostAmt1: Decimal; var TotalICAmtExpected1: Decimal; var TotalICCostAmtExpected1: Decimal)
    begin
        if not IntrastatJnlBatch."Amounts in Add. Currency" then begin
            TotalICAmt1 := TotalICAmt1 + ValueEntry."Sales Amount (Actual)";
            TotalICCostAmt1 := TotalICCostAmt1 + ValueEntry."Cost Amount (Actual)";
            TotalICAmtExpected1 := TotalICAmtExpected1 + ValueEntry."Sales Amount (Expected)";
            TotalICCostAmtExpected1 := TotalICCostAmtExpected1 + ValueEntry."Cost Amount (Expected)";
        end else begin
            TotalICCostAmt1 := TotalICCostAmt1 + ValueEntry."Cost Amount (Actual) (ACY)";
            TotalICCostAmtExpected1 := TotalICCostAmtExpected1 + ValueEntry."Cost Amount (Expected) (ACY)";
            if ValueEntry."Cost per Unit" <> 0 then begin
                TotalICAmt1 += ValueEntry."Sales Amount (Actual)" * ValueEntry."Cost per Unit (ACY)" / ValueEntry."Cost per Unit";
                TotalICAmtExpected1 += ValueEntry."Sales Amount (Expected)" * ValueEntry."Cost per Unit (ACY)" / ValueEntry."Cost per Unit";
            end else begin
                TotalICAmt1 += CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                    ValueEntry."Posting Date", GeneralLedgerSetup."Additional Reporting Currency",
                    ValueEntry."Sales Amount (Actual)", AddCurrencyFactor);
                TotalICAmtExpected1 += CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                    ValueEntry."Posting Date", GeneralLedgerSetup."Additional Reporting Currency",
                    ValueEntry."Sales Amount (Expected)", AddCurrencyFactor);
            end;
        end;
    end;

    procedure CalcDataForItemJnlLine()
    begin
        IntrastatJnlLine."Shpt. Method Code" := "Item Ledger Entry"."Shpt. Method Code";
        Item.Get("Item Ledger Entry"."Item No.");
        IntrastatJnlLine.Name := Item.Description;
        if (StatutoryReportingSetupCZL."Get Net Weight From" = StatutoryReportingSetupCZL."Get Net Weight From"::"Item Card") and
           (Item."Net Weight" <> 0)
        then
            IntrastatJnlLine.Validate(IntrastatJnlLine."Net Weight", Item."Net Weight")
        else
            IntrastatJnlLine.Validate(IntrastatJnlLine."Net Weight", "Item Ledger Entry"."Net Weight CZL");
        if (StatutoryReportingSetupCZL."Get Tariff No. From" = StatutoryReportingSetupCZL."Get Tariff No. From"::"Item Card") and
           (Item."Tariff No." <> '')
        then begin
            IntrastatJnlLine.Validate(IntrastatJnlLine."Tariff No.", Item."Tariff No.");
            IntrastatJnlLine."Statistic Indication CZL" := Item."Statistic Indication CZL";
        end else begin
            IntrastatJnlLine.Validate(IntrastatJnlLine."Tariff No.", "Item Ledger Entry"."Tariff No. CZL");
            IntrastatJnlLine."Statistic Indication CZL" := "Item Ledger Entry"."Statistic Indication CZL";
        end;
        if (StatutoryReportingSetupCZL."Get Country/Region of Origin" = StatutoryReportingSetupCZL."Get Country/Region of Origin"::"Item Card") and
           (Item."Country/Region of Origin Code" <> '')
        then
            IntrastatJnlLine.Validate("Country/Region of Origin Code", Item."Country/Region of Origin Code")
        else
            IntrastatJnlLine.Validate("Country/Region of Origin Code", "Item Ledger Entry"."Country/Reg. of Orig. Code CZL");

        IntrastatJnlLine."Base Unit of Measure CZL" := Item."Base Unit of Measure";
        if IntrastatJnlLine."Supplementary Units" then begin
            IntrastatJnlLine."Supplem. UoM Quantity CZL" := IntrastatJnlLine.Quantity /
              UnitofMeasureManagement.GetQtyPerUnitOfMeasure(Item, IntrastatJnlLine."Supplem. UoM Code CZL");
            IntrastatJnlLine."Supplem. UoM Net Weight CZL" := IntrastatJnlLine."Net Weight" *
              UnitofMeasureManagement.GetQtyPerUnitOfMeasure(Item, IntrastatJnlLine."Supplem. UoM Code CZL");
        end;
        IntrastatJnlLine.TestField(IntrastatJnlLine.Quantity);
    end;

    procedure CalcDataForJobJnlLine()
    begin
        IntrastatJnlLine."Shpt. Method Code" := "Job Ledger Entry"."Shpt. Method Code";
        Item.Get("Job Ledger Entry"."No.");
        IntrastatJnlLine.Name := Item.Description;
        if (StatutoryReportingSetupCZL."Get Net Weight From" = StatutoryReportingSetupCZL."Get Net Weight From"::"Item Card") and
           (Item."Net Weight" <> 0)
        then
            IntrastatJnlLine.Validate(IntrastatJnlLine."Net Weight", Item."Net Weight")
        else
            IntrastatJnlLine.Validate(IntrastatJnlLine."Net Weight", "Job Ledger Entry"."Net Weight CZL");
        if (StatutoryReportingSetupCZL."Get Tariff No. From" = StatutoryReportingSetupCZL."Get Tariff No. From"::"Item Card") and
           (Item."Tariff No." <> '')
        then begin
            IntrastatJnlLine.Validate(IntrastatJnlLine."Tariff No.", Item."Tariff No.");
            IntrastatJnlLine."Statistic Indication CZL" := Item."Statistic Indication CZL";
        end else begin
            IntrastatJnlLine.Validate(IntrastatJnlLine."Tariff No.", "Job Ledger Entry"."Tariff No. CZL");
            IntrastatJnlLine."Statistic Indication CZL" := "Job Ledger Entry"."Statistic Indication CZL";
        end;
        if (StatutoryReportingSetupCZL."Get Country/Region of Origin" = StatutoryReportingSetupCZL."Get Country/Region of Origin"::"Item Card") and
           (Item."Country/Region of Origin Code" <> '')
        then
            IntrastatJnlLine.Validate(IntrastatJnlLine."Country/Region of Origin Code", Item."Country/Region of Origin Code")
        else
            IntrastatJnlLine.Validate(IntrastatJnlLine."Country/Region of Origin Code", "Job Ledger Entry"."Country/Reg. of Orig. Code CZL");

        IntrastatJnlLine."Base Unit of Measure CZL" := Item."Base Unit of Measure";
        if IntrastatJnlLine."Supplementary Units" then begin
            IntrastatJnlLine."Supplem. UoM Quantity CZL" := IntrastatJnlLine.Quantity /
              UnitofMeasureManagement.GetQtyPerUnitOfMeasure(Item, IntrastatJnlLine."Supplem. UoM Code CZL");
            IntrastatJnlLine."Supplem. UoM Net Weight CZL" := IntrastatJnlLine."Net Weight" *
              UnitofMeasureManagement.GetQtyPerUnitOfMeasure(Item, IntrastatJnlLine."Supplem. UoM Code CZL");
        end;
        IntrastatJnlLine.TestField(IntrastatJnlLine.Quantity);

    end;

    procedure CalcStatValue()
    var
        ShipmentMethod: Record "Shipment Method";
    begin
        case StatutoryReportingSetupCZL."Stat. Value Reporting" of
            StatutoryReportingSetupCZL."Stat. Value Reporting"::None:
                begin
                    IntrastatJnlLine."Cost Regulation %" := 0;
                    IntrastatJnlLine."Indirect Cost" := 0;
                end;
            StatutoryReportingSetupCZL."Stat. Value Reporting"::Percentage:
                IntrastatJnlLine."Indirect Cost" := Round(IntrastatJnlLine.Amount * IntrastatJnlLine."Cost Regulation %" / 100, 1, Direction);
            StatutoryReportingSetupCZL."Stat. Value Reporting"::"Shipment Method":
                begin
                    IntrastatJnlLine.TestField(IntrastatJnlLine."Shpt. Method Code");
                    ShipmentMethod.Get(IntrastatJnlLine."Shpt. Method Code");
                    if ShipmentMethod."Incl. Item Charges (S.Val) CZL" then begin
                        IntrastatJnlLine."Cost Regulation %" := 0;
                        if IntrastatJnlLine.Type = IntrastatJnlLine.Type::Shipment then
                            IntrastatJnlLine."Indirect Cost" := TotalICAmt[2];
                        if IntrastatJnlLine.Type = IntrastatJnlLine.Type::Receipt then
                            IntrastatJnlLine."Indirect Cost" := TotalICCostAmt[2];
                    end else begin
                        IntrastatJnlLine."Cost Regulation %" := ShipmentMethod."Adjustment % CZL";
                        IntrastatJnlLine."Indirect Cost" := Round(IntrastatJnlLine.Amount * IntrastatJnlLine."Cost Regulation %" / 100, 1, Direction);
                    end;
                end;
        end;
        IntrastatJnlLine."Statistical Value" := Round(Abs(IntrastatJnlLine.Amount) + IntrastatJnlLine."Indirect Cost", 1, Direction);

    end;

    local procedure GetDocument(DocumentType: Enum "Item Ledger Document Type"; DocumentNo: Code[20]; var TempSalesHeader: Record "Sales Header" temporary): Boolean
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        ReturnShipmentHeader: Record "Return Shipment Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceShipmentHeader: Record "Service Shipment Header";
    begin
        Clear(TempSalesHeader);

        case DocumentType of
            DocumentType::"Sales Shipment":
                if SalesShipmentHeader.Get(DocumentNo) then begin
                    TempSalesHeader."Posting Date" := SalesShipmentHeader."Posting Date";
                    TempSalesHeader."Currency Code" := SalesShipmentHeader."Currency Code";
                    TempSalesHeader."Currency Factor" := SalesShipmentHeader."Currency Factor";
                    TempSalesHeader."VAT Currency Factor CZL" := SalesShipmentHeader."Currency Factor";
                end;
            DocumentType::"Sales Invoice":
                if SalesInvoiceHeader.Get(DocumentNo) then begin
                    TempSalesHeader."Posting Date" := SalesInvoiceHeader."Posting Date";
                    TempSalesHeader."Currency Code" := SalesInvoiceHeader."Currency Code";
                    TempSalesHeader."Currency Factor" := SalesInvoiceHeader."Currency Factor";
                    TempSalesHeader."VAT Currency Factor CZL" := SalesInvoiceHeader."VAT Currency Factor CZL";
                end;
            DocumentType::"Sales Credit Memo":
                if SalesCrMemoHeader.Get(DocumentNo) then begin
                    TempSalesHeader."Posting Date" := SalesCrMemoHeader."Posting Date";
                    TempSalesHeader."Currency Code" := SalesCrMemoHeader."Currency Code";
                    TempSalesHeader."Currency Factor" := SalesCrMemoHeader."Currency Factor";
                    TempSalesHeader."VAT Currency Factor CZL" := SalesCrMemoHeader."VAT Currency Factor CZL";
                end;
            DocumentType::"Sales Return Receipt":
                if ReturnReceiptHeader.Get(DocumentNo) then begin
                    TempSalesHeader."Posting Date" := ReturnReceiptHeader."Posting Date";
                    TempSalesHeader."Currency Code" := ReturnReceiptHeader."Currency Code";
                    TempSalesHeader."Currency Factor" := ReturnReceiptHeader."Currency Factor";
                    TempSalesHeader."VAT Currency Factor CZL" := ReturnReceiptHeader."Currency Factor";
                end;
            DocumentType::"Service Shipment":
                if ServiceShipmentHeader.Get(DocumentNo) then begin
                    TempSalesHeader."Posting Date" := ServiceShipmentHeader."Posting Date";
                    TempSalesHeader."Currency Code" := ServiceShipmentHeader."Currency Code";
                    TempSalesHeader."Currency Factor" := ServiceShipmentHeader."Currency Factor";
                    TempSalesHeader."VAT Currency Factor CZL" := ServiceShipmentHeader."Currency Factor";
                end;
            DocumentType::"Service Invoice":
                if ServiceInvoiceHeader.Get(DocumentNo) then begin
                    TempSalesHeader."Posting Date" := ServiceInvoiceHeader."Posting Date";
                    TempSalesHeader."Currency Code" := ServiceInvoiceHeader."Currency Code";
                    TempSalesHeader."Currency Factor" := ServiceInvoiceHeader."Currency Factor";
                    TempSalesHeader."VAT Currency Factor CZL" := ServiceInvoiceHeader."VAT Currency Factor CZL";
                end;
            DocumentType::"Service Credit Memo":
                if ServiceCrMemoHeader.Get(DocumentNo) then begin
                    TempSalesHeader."Posting Date" := ServiceCrMemoHeader."Posting Date";
                    TempSalesHeader."Currency Code" := ServiceCrMemoHeader."Currency Code";
                    TempSalesHeader."Currency Factor" := ServiceCrMemoHeader."Currency Factor";
                    TempSalesHeader."VAT Currency Factor CZL" := ServiceCrMemoHeader."VAT Currency Factor CZL";
                end;
            DocumentType::"Purchase Receipt":
                if PurchRcptHeader.Get(DocumentNo) then begin
                    TempSalesHeader."Posting Date" := PurchRcptHeader."Posting Date";
                    TempSalesHeader."Currency Code" := PurchRcptHeader."Currency Code";
                    TempSalesHeader."Currency Factor" := PurchRcptHeader."Currency Factor";
                    TempSalesHeader."VAT Currency Factor CZL" := PurchRcptHeader."Currency Factor";
                end;
            DocumentType::"Purchase Invoice":
                if PurchInvHeader.Get(DocumentNo) then begin
                    TempSalesHeader."Posting Date" := PurchInvHeader."Posting Date";
                    TempSalesHeader."Currency Code" := PurchInvHeader."Currency Code";
                    TempSalesHeader."Currency Factor" := PurchInvHeader."Currency Factor";
                    TempSalesHeader."VAT Currency Factor CZL" := PurchInvHeader."VAT Currency Factor CZL";
                end;
            DocumentType::"Purchase Credit Memo":
                if PurchCrMemoHdr.Get(DocumentNo) then begin
                    TempSalesHeader."Posting Date" := PurchCrMemoHdr."Posting Date";
                    TempSalesHeader."Currency Code" := PurchCrMemoHdr."Currency Code";
                    TempSalesHeader."Currency Factor" := PurchCrMemoHdr."Currency Factor";
                    TempSalesHeader."VAT Currency Factor CZL" := PurchCrMemoHdr."VAT Currency Factor CZL";
                end;
            DocumentType::"Purchase Return Shipment":
                if ReturnShipmentHeader.Get(DocumentNo) then begin
                    TempSalesHeader."Posting Date" := ReturnShipmentHeader."Posting Date";
                    TempSalesHeader."Currency Code" := ReturnShipmentHeader."Currency Code";
                    TempSalesHeader."Currency Factor" := ReturnShipmentHeader."Currency Factor";
                    TempSalesHeader."VAT Currency Factor CZL" := ReturnShipmentHeader."Currency Factor";
                end;
            else
                exit(false);
        end;

        exit(
          (TempSalesHeader."Posting Date" <> 0D) or
          (TempSalesHeader."Currency Code" <> '') or
          (TempSalesHeader."Currency Factor" <> 0) or
          (TempSalesHeader."VAT Currency Factor CZL" <> 0));
    end;

    local procedure GetDocumentFromItemLedgEntry(ItemLedgerEntry: Record "Item Ledger Entry"; var TempSalesHeader: Record "Sales Header" temporary): Boolean
    var
        DocumentValueEntry: Record "Value Entry";
    begin
        if FindValueEntryFromItemLedgEntry(ItemLedgerEntry, DocumentValueEntry) then
            exit(GetDocumentFromValueEntry(DocumentValueEntry, TempSalesHeader));
        exit(GetDocument(ItemLedgerEntry."Document Type", ItemLedgerEntry."Document No.", TempSalesHeader));

    end;

    local procedure GetDocumentFromValueEntry(DocumentValueEntry: Record "Value Entry"; var TempSalesHeader: Record "Sales Header" temporary): Boolean
    begin
        exit(GetDocument(DocumentValueEntry."Document Type", DocumentValueEntry."Document No.", TempSalesHeader));
    end;

    local procedure CalculateExchangeAmount(Amount: Decimal; DocumentCurrencyFactor: Decimal; IntrastatCurrencyFactor: Decimal): Decimal
    begin
        if (IntrastatCurrencyFactor <> 0) and (DocumentCurrencyFactor <> 0) then
            exit(Amount * DocumentCurrencyFactor / IntrastatCurrencyFactor);
        exit(Amount);
    end;

    procedure CalculateTotals2(ValueEntry2: Record "Value Entry")
    begin
        Clear(TotalAmt);
        Clear(TotalICAmt);
        Clear(TotalICCostAmt);
        Clear(TotalCostAmt2);

        ValueEntry.Get(ValueEntry2."Entry No.");

        if ValueEntry."Incl. in Intrastat Amount CZL" then
            CalcTotalsForItemCharge(TotalICAmt[1], TotalICCostAmt[1], TotalICAmtExpected[1], TotalICCostAmtExpected[1]);
        if ValueEntry."Incl. in Intrastat S.Value CZL" then
            CalcTotalsForItemCharge(TotalICAmt[2], TotalICCostAmt[2], TotalICAmtExpected[2], TotalICCostAmtExpected[2]);
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
        exit(not ItemApplicationEntry.IsEmpty());
    end;

    local procedure FindValueEntryFromItemLedgEntry(ItemLedgerEntry: Record "Item Ledger Entry"; var ValueEntry: Record "Value Entry"): Boolean
    begin
        if not ItemLedgerEntry."Completely Invoiced" then
            exit(false);

        ValueEntry.Reset();
        ValueEntry.SetCurrentKey("Item Ledger Entry No.");
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
        ValueEntry.SetFilter("Invoiced Quantity", '<>%1', 0);
        exit(ValueEntry.FindFirst());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateTotals(var ItemLedgerEntry: Record "Item Ledger Entry"; IntrastatJnlBatch: Record "Intrastat Jnl. Batch"; var TotalAmt: Decimal; var TotalCostAmt: Decimal)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterItemLedgerEntryOnPreDataItem(var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeHasCrossedBorder(ItemLedgerEntry: Record "Item Ledger Entry"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertItemJnlLine(var IntrastatJnlLine: Record "Intrastat Jnl. Line"; ItemLedgerEntry: Record "Item Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertJobLedgerLine(var IntrastatJnlLine: Record "Intrastat Jnl. Line"; JobLedgerEntry: Record "Job Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertValueEntryLine(var IntrastatJnlLine: Record "Intrastat Jnl. Line"; ItemLedgerEntry: Record "Item Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalculateTotalsOnAfterSumTotals(var ItemLedgerEntry: Record "Item Ledger Entry"; IntrastatJnlBatch: Record "Intrastat Jnl. Batch"; var TotalAmt: Decimal; var TotalCostAmt: Decimal)
    begin
    end;
}

#endif
