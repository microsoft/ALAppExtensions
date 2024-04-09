// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

#if not CLEAN24 
using Microsoft.Finance;
#endif
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Enums;
using System.Utilities;

report 14600 "IS VAT Balancing Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/ISVATBalancingReport.rdlc';
    ApplicationArea = Basic, Suite;
    Caption = 'VAT Balancing Report';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("VAT Posting Setup"; "VAT Posting Setup")
        {
            DataItemTableView = sorting("VAT Bus. Posting Group", "VAT Prod. Posting Group");
            column(CompanyName; COMPANYPROPERTY.DisplayName())
            {
            }
            column(UserIdFormattedTime; UserId + ',  at ' + Format(Time, 5))
            {
            }
            column(V10941; '10941')
            {
            }
            column(FormattedDateFromToDateTo; Format(DateFrom) + '  to  ' + Format(DateTo))
            {
            }
            column(FormattedOpenClosedEntries; Format(ISVATEntriesFilter) + ' entries')
            {
            }
            column(VATBusPostingGroup_VATPostingSetup; "VAT Bus. Posting Group")
            {
            }
            column(VATProdPostingGroup_VATPostingSetup; "VAT Prod. Posting Group")
            {
            }
            column(VATCalculationType_VATPostingSetup; "VAT Calculation Type")
            {
            }
            column(FormattedVAT; Format("VAT %") + '%')
            {
            }
            column(TurnoverOut; TurnoverOut)
            {
            }
            column(VatReceivable; VatReceivable)
            {
            }
            column(TurnoverIn; TurnoverIn)
            {
            }
            column(VatPayableVariance; VatPayableVariance)
            {
            }
            column(VatReceivableVarianceTxt; VatReceivableVarianceTxt)
            {
            }
            column(VatPayableVarianceTxt; VatPayableVarianceTxt)
            {
            }
            column(Total; 'Total')
            {
            }
            column(VatReceivableVarianceKr; VatReceivableVarianceKr)
            {
            }
            column(VatPayableVarianceKr; VatPayableVarianceKr)
            {
            }
            column(PaymentDue; TotalVatReceivable - TotalVatPayable)
            {
            }
            column(TotalVatReceivable; TotalVatReceivable)
            {
            }
            column(TotalVatPayable; TotalVatPayable)
            {
            }
            column(VATReconciliationReportCaption; VATReconciliationReportCaptionLbl)
            {
            }
            column(VATBusPostingGroupCaption; VATBusPostingGroupCaptionLbl)
            {
            }
            column(VATProdPostingGroupCaption; VATProdPostingGroupCaptionLbl)
            {
            }
            column(VATCaption; VATCaptionLbl)
            {
            }
            column(SalesCaption; SalesCaptionLbl)
            {
            }
            column(BaseCaption; BaseCaptionLbl)
            {
            }
            column(SalesVATCaption; SalesVATCaptionLbl)
            {
            }
            column(PurchaseCaption; PurchaseCaptionLbl)
            {
            }
            column(PurchaseVATCaption; PurchaseVATCaptionLbl)
            {
            }
            column(PaymentDueCaption; PaymentDueCaptionLbl)
            {
            }
            column(VATReportCaption; VATReportCaptionLbl)
            {
            }
            column(ReverseChargeVATCaption; ReverseChargeVATValue)
            {
            }
            column(SalesPctReverseChargeVAT; SalesPercentReverseChargeVAT)
            {
            }
            column(PurchVATOppositeSign; PurchaseVATOppositeSign)
            {
            }

            trigger OnAfterGetRecord()
            var
                IsReverseChargeVAT: Boolean;
                VATPercentSales: Decimal;
            begin
                VatReceivableVarianceKr := 0;
                VatPayableVarianceKr := 0;
                PurchaseVATOppositeSign := 0;
                IsReverseChargeVAT := "VAT Calculation Type" = "Tax Calculation Type"::"Reverse Charge VAT";

                VatF.Reset();
                VatF.SetCurrentKey(Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group", "VAT Reporting Date");
                case ISVATEntriesFilter of
                    ISVATEntriesFilter::Open:
                        VatF.SetRange(Closed, false);
                    ISVATEntriesFilter::Closed:
                        VatF.SetRange(Closed, true);
                end;
                VatF.SetRange("VAT Bus. Posting Group", "VAT Bus. Posting Group");
                VatF.SetRange("VAT Prod. Posting Group", "VAT Prod. Posting Group");
                VatF.SetRange("VAT Reporting Date", DateFrom, DateTo);

                VatF.SetRange(Type, VatF.Type::Sale);
                VatF.CalcSums(Base, Amount);
                TurnoverOut := VatF.Base;
                VatReceivable := VatF.Amount;

                if (TurnoverOut <> 0) and (TurnoverOut <> VatReceivable) then begin
                    VatReceivablePct := Round(VatReceivable / TurnoverOut * 100, 0.1);
                    if Abs(VatReceivablePct - "VAT %") > 0.1 then
                        if not ((VatReceivable = 0) and IsReverseChargeVAT) then begin
                            VatReceivableVarianceKr := Round(VatReceivable - (TurnoverOut * "VAT %" / 100), 1);
                            VatReceivableVarianceTxt := StrSubstNo(VarianceinVATreceivableTxt, VatReceivablePct, VatReceivableVarianceKr);
                        end;
                end;

                if IsReverseChargeVAT then
                    VATPercentSales := 0
                else
                    VATPercentSales := "VAT Posting Setup"."VAT %";
                Index := ArrayIndexOf(VATPercentSales);
                if Index <> 0 then
                    VATBuffer[Index] [2] += TurnoverOut
                else begin
                    Index := ArrayInsert();
                    VATBuffer[Index] [1] := VATPercentSales;
                    VATBuffer[Index] [2] += TurnoverOut;
                end;

                TotalVatReceivable += VatReceivable;

                VatF.SetRange(Type, VatF.Type::Purchase);
                VatF.CalcSums(Base, Amount);
                TurnoverIn := VatF.Base;
                VatPayableVariance := VatF.Amount;
                if IsReverseChargeVAT then
                    PurchaseVATOppositeSign := -VatPayableVariance;

                if (TurnoverIn <> 0) and (TurnoverIn <> VatPayableVariance) then begin
                    VatPayablePct := Round(VatPayableVariance / TurnoverIn * 100, 0.1);
                    if Abs(VatPayablePct - "VAT %") > 0.1 then begin
                        VatPayableVarianceKr := Round(VatPayableVariance - (TurnoverIn * "VAT %" / 100), 1);
                        VatPayableVarianceTxt := StrSubstNo(VarianceinVATpayableTxt, VatPayablePct, VatPayableVarianceKr);
                    end;
                end;

                TotalVatPayable += (VatPayableVariance + PurchaseVATOppositeSign);

                if (TurnoverOut = 0) and (VatReceivable = 0) and (TurnoverIn = 0) and (VatPayableVariance = 0) then
                    CurrReport.Skip();
            end;

            trigger OnPreDataItem()
            begin
                Clear(TurnoverOut);
                Clear(TurnoverIn);
                Clear(VatReceivable);
                Clear(VatPayableVariance);

                ReverseChargeVATValue := Format("VAT Calculation Type"::"Reverse Charge VAT");
                SalesPercentReverseChargeVAT := '0%';
            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = sorting(Number) order(descending);
            column(VATBufferNumber1; StrSubstNo(TurnoverVATRateTxt, Format(VATBuffer[Number] [1])))
            {
            }
            column(VATBufferNumber2; VATBuffer[Number] [2])
            {
            }
            column(TotalVatReceivableTotalVatPayable; -TotalVatReceivable - TotalVatPayable)
            {
            }
            column(IntegerPurchaseVATCaption; PurchaseVATCaptionLbl)
            {
            }
            column(Number_IntegerLine; Number)
            {
            }

            trigger OnPreDataItem()
            begin
                SetRange(Number, 1, NumberofElements);
            end;
        }
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
                    field(ISVATEntriesFilter; ISVATEntriesFilter)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies if you want to include only open VAT ledger entries.';
                        Caption = 'Open/Closed';
                    }
                    field(Period; Period)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Period';
                        OptionCaption = 'Custom,January-February,March-April,May-June,July-August,September-October,November-December';
                        ToolTip = 'Specifies the VAT report period. Select a two month period, or choose Custom to specify a different period in the From and to fields.';

                        trigger OnValidate()
                        begin
                            FindDates();
                        end;
                    }
                    field(Year; YY)
                    {
                        ApplicationArea = Basic, Suite;
                        BlankZero = true;
                        Caption = 'Year';
                        Style = Strong;
                        StyleExpr = true;
                        ToolTip = 'Specifies the VAT reporting year.';

                        trigger OnValidate()
                        begin
                            FindDates();
                        end;
                    }
                    field(DateFrom; DateFrom)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'From';
                        ToolTip = 'Specifies the start of the VAT report period.';

                        trigger OnValidate()
                        begin
                            CheckPeriodType();
                        end;
                    }
                    field(DateTo; DateTo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'to';
                        ToolTip = 'Specifies the end of the VAT report period.';

                        trigger OnValidate()
                        begin
                            CheckPeriodType();
                        end;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            MM := Date2DMY(CalcDate('<-2M>', Today), 2);
            YY := Date2DMY(CalcDate('<-2M>', Today), 3);
            FindPeriod();
        end;
    }

    labels
    {
    }

    var
        VatF: Record "VAT Entry";
        DateFrom: Date;
        DateTo: Date;
        ISVATEntriesFilter: Enum "IS VAT Entries Filter";
        Period: Option Custom,"January-February","March-April","May-June","July-August","September-October","November-December";
        VatReceivableVarianceTxt: Text[120];
        VatPayableVarianceTxt: Text[120];
        TurnoverOut: Decimal;
        VatReceivable: Decimal;
        TurnoverIn: Decimal;
        VatPayableVariance: Decimal;
        TotalVatReceivable: Decimal;
        TotalVatPayable: Decimal;
        VatReceivablePct: Decimal;
        VatPayablePct: Decimal;
        VatReceivableVarianceKr: Decimal;
        VatPayableVarianceKr: Decimal;
        PurchaseVATOppositeSign: Decimal;
        ReverseChargeVATValue: Text;
        SalesPercentReverseChargeVAT: Text;
        YY: Integer;
        MM: Integer;
        DD: Integer;
        VATBuffer: array[20, 2] of Decimal;
        Index: Integer;
        NumberofElements: Integer;
        VarianceinVATreceivableTxt: Label 'Attention! Variance in VAT receivable. Calculated VAT receivable. %1%. Variance %2 kr.', Comment = '%1 = VAT Percentage, %2 - VAT variance amount';
        VarianceinVATpayableTxt: Label 'Attention! Variance in VAT payable. Calculated VAT payable. %1%. Variance %2 kr.', Comment = '%1 = VAT Percentage, %2 - VAT variance amount';
        TurnoverVATRateTxt: Label 'Turnover for %1% VAT rate', Comment = '%1 = VAT Rate';
        PeriodMustBeCustomTxt: Label 'Period must be Custom.';
        VATReconciliationReportCaptionLbl: Label 'VAT Reconciliation  / Report';
        VATBusPostingGroupCaptionLbl: Label 'VAT Bus. Posting Group';
        VATProdPostingGroupCaptionLbl: Label 'VAT Prod. Posting Group';
        VATCaptionLbl: Label 'VAT %';
        SalesCaptionLbl: Label 'Sales';
        BaseCaptionLbl: Label 'Base';
        SalesVATCaptionLbl: Label 'Sales VAT';
        PurchaseCaptionLbl: Label 'Purchase';
        PurchaseVATCaptionLbl: Label 'Purchase VAT';
        VATReportCaptionLbl: Label 'VAT Report';
        PaymentDueCaptionLbl: Label 'Payment Due';

#if not CLEAN24
    trigger OnInitReport()
    var
        ISCoreAppSetup: Record "IS Core App Setup";
    begin
        if not ISCoreAppSetup.IsEnabled() then begin
            Report.Run(Report::"VAT Balancing Report");
            Error('');
        end;
    end;
#endif


    procedure FindPeriod()
    begin
        DateFrom := DMY2Date(1, MM, YY);
        DateTo := CalcDate('<+CM>', DateFrom);

        case MM of
            1, 2:
                Period := Period::"January-February";
            3, 4:
                Period := Period::"March-April";
            5, 6:
                Period := Period::"May-June";
            7, 8:
                Period := Period::"July-August";
            9, 10:
                Period := Period::"September-October";
            11, 12:
                Period := Period::"November-December";
        end;
        FindDates();
    end;

    procedure FindDates()
    begin
        DateFrom := 0D;
        DateTo := 0D;

        case Period of
            Period::"January-February":
                begin
                    DateFrom := DMY2Date(1, 1, YY);
                    DD := Date2DMY(CalcDate('<+CM>', DMY2Date(1, 2, YY)), 1);
                    DateTo := DMY2Date(DD, 2, YY);
                end;
            Period::"March-April":
                begin
                    DateFrom := DMY2Date(1, 3, YY);
                    DateTo := DMY2Date(30, 4, YY);
                end;
            Period::"May-June":
                begin
                    DateFrom := DMY2Date(1, 5, YY);
                    DateTo := DMY2Date(30, 6, YY);
                end;
            Period::"July-August":
                begin
                    DateFrom := DMY2Date(1, 7, YY);
                    DateTo := DMY2Date(31, 8, YY);
                end;
            Period::"September-October":
                begin
                    DateFrom := DMY2Date(1, 9, YY);
                    DateTo := DMY2Date(31, 10, YY);
                end;
            Period::"November-December":
                begin
                    DateFrom := DMY2Date(1, 11, YY);
                    DateTo := DMY2Date(31, 12, YY);
                end;
        end;
    end;

    procedure ArrayFind(): Decimal
    var
        i: Integer;
    begin
        for i := 1 to NumberofElements do
            if VATBuffer[i] [1] = "VAT Posting Setup"."VAT %" then
                exit(i);
        exit(0);
    end;

    procedure ArrayInsert(): Integer
    begin
        NumberofElements := NumberofElements + 1;
        exit(NumberofElements);
    end;

    local procedure CheckPeriodType()
    begin
        if Period <> Period::Custom then
            Error(PeriodMustBeCustomTxt);
    end;

    local procedure ArrayIndexOf(VATPercent: Decimal): Integer
    var
        i: Integer;
    begin
        for i := 1 to NumberofElements do
            if VATBuffer[i] [1] = VATPercent then
                exit(i);
        exit(0);
    end;
}

