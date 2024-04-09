// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.CashFlow.Reports;

using Microsoft.CashFlow.Forecast;
using System.Utilities;

report 31005 "Cash Flow Date List CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/CashFlowDateList.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'Cash Flow Date List';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(CashFlow; "Cash Flow Forecast")
        {
            RequestFilterFields = "No.";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(CashFlowNo; "No.")
            {
                IncludeCaption = true;
            }
            column(CashFlowDescription; Description)
            {
                IncludeCaption = true;
            }

            dataitem(EditionPeriod; "Integer")
            {
                DataItemTableView = sorting(Number) order(ascending);
                column(NewCFSumTotal; NewCFSumTotal)
                {
                }
                column(BeforeSumTotal; BeforeSumTotal)
                {
                }
                column(Liquidity; Values[CashFlowForecastEntry."Source Type"::"Liquid Funds".AsInteger()])
                {
                }
                column(Receivables; Values[CashFlowForecastEntry."Source Type"::Receivables.AsInteger()])
                {
                }
                column(SalesOrders; Values[CashFlowForecastEntry."Source Type"::"Sales Orders".AsInteger()])
                {
                }
                column(ServiceOrders; Values[CashFlowForecastEntry."Source Type"::"Service Orders".AsInteger()])
                {
                }
                column(ManualRevenues; Values[CashFlowForecastEntry."Source Type"::"Cash Flow Manual Revenue".AsInteger()])
                {
                }
                column(Payables; Values[CashFlowForecastEntry."Source Type"::Payables.AsInteger()])
                {
                }
                column(PurchaseOrders; Values[CashFlowForecastEntry."Source Type"::"Purchase Orders".AsInteger()])
                {
                }
                column(ManualExpenses; Values[CashFlowForecastEntry."Source Type"::"Cash Flow Manual Expense".AsInteger()])
                {
                }
                column(InvFixedAssets; Values[CashFlowForecastEntry."Source Type"::"Fixed Assets Budget".AsInteger()])
                {
                }
                column(SaleFixedAssets; Values[CashFlowForecastEntry."Source Type"::"Fixed Assets Disposal".AsInteger()])
                {
                }
                column(GLBudget; Values[CashFlowForecastEntry."Source Type"::"G/L Budget".AsInteger()])
                {
                }
                column(SalesAdvances; SalesAdvanceValue)
                {
                }
                column(PurchaseAdvances; PurchaseAdvanceValue)
                {
                }
                column(EditionPeriod_Number; Number)
                {
                }
                column(Period_Number; PeriodNumber)
                {
                }
                column(DateTo; Format(CurrentDateTo))
                {
                }
                column(DateFrom; Format(CurrentDateFrom))
                {
                }
                column(Jobs; Values[CashFlowForecastEntry."Source Type"::Job.AsInteger()])
                {
                }
                column(Taxes; Values[CashFlowForecastEntry."Source Type"::Tax.AsInteger()])
                {
                }

                trigger OnAfterGetRecord()
                begin
                    CashFlow.SetCashFlowDateFilter(CurrentDateFrom, CurrentDateTo);
                    case Number of
                        0:
                            begin
                                CurrentDateTo := UserInputDateFrom - 1;
                                CurrentDateFrom := 0D;
                            end;
                        PeriodNumber + 1:
                            begin
                                CurrentDateFrom := CurrentDateTo + 1;
                                CurrentDateTo := 0D;
                            end;
                        else begin
                            CurrentDateFrom := CurrentDateTo + 1;
                            CurrentDateTo := CalcDate(Interval, CurrentDateFrom) - 1;
                        end
                    end;

                    CashFlow.CalculateAllAmounts(CurrentDateFrom, CurrentDateTo, Values, CFSumTotal);
                    NewCFSumTotal := NewCFSumTotal + CFSumTotal;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 0, PeriodNumber + 1);
                    CashFlow.CalculateAllAmounts(0D, UserInputDateFrom - 1, Values, BeforeSumTotal);
                end;
            }
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
                    field(FromDate; UserInputDateFrom)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'From Date';
                        ToolTip = 'Specifies the first date to be included in the report.';
                    }
                    field(PeriodNumberField; PeriodNumber)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Number of Intervals';
                        ToolTip = 'Specifies the number of intervals.';
                    }
                    field(IntervalField; Interval)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Interval Length';
                        ToolTip = 'Specifies the length of each interval, such as 1M for one month, 1W for one week, or 1D for one day.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            UserInputDateFrom := WorkDate();
        end;
    }

    labels
    {
        GLBudgetCaption = 'G/L Budget';
        LiquidityCaption = 'Liquidity';
        PurchaseAdvancesCaption = 'Purchase Advances';
        SalesAdvancesCaption = 'Sales Advances';
        PAGENOCaption = 'Page';
        CashFlowDateListCaption = 'Cash Flow Date List';
        ServiceOrdersCaption = 'Service Orders';
        SumTotalCaption = 'Cash Flow Interference';
        PurchaseOrdersCaptionL = 'Purchase Orders';
        PayablesCaption = 'Payables';
        SalesOrdersCaption = 'Sales Orders';
        ReceivablesCaption = 'Receivables';
        ManualRevenuesCaption = 'Cash Flow Manual Revenues';
        ManualExpensesCaption = 'Cash Flow Manual Expenses';
        DateFromCaption = 'From';
        DateToCaption = 'To';
        InvFixedAssetsCaption = 'Fixed Assets Budget';
        SaleFixedAssetsCaption = 'Fixed Assets Disposal';
        beforeCaption = 'Before:';
        afterCaption = 'After:';
        JobsCaption = 'Jobs';
        TaxesCaption = 'Taxes';
    }

    var
        CashFlowForecastEntry: Record "Cash Flow Forecast Entry";
        Interval: DateFormula;
        UserInputDateFrom: Date;
        CurrentDateFrom: Date;
        CurrentDateTo: Date;
        PeriodNumber: Integer;
        Values: array[15] of Decimal;
        BeforeSumTotal: Decimal;
        NewCFSumTotal: Decimal;
        CFSumTotal: Decimal;

    protected var
        SalesAdvanceValue: Decimal;
        PurchaseAdvanceValue: Decimal;

    procedure InitializeRequest(FromDate: Date; NumberOfIntervals: Integer; IntervalLength: DateFormula)
    begin
        UserInputDateFrom := FromDate;
        PeriodNumber := NumberOfIntervals;
        Interval := IntervalLength;
    end;
}

