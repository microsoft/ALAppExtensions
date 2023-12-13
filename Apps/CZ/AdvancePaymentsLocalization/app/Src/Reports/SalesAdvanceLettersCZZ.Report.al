// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Setup;
using System.Utilities;

report 31019 "Sales Advance Letters CZZ"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    Caption = 'Sales Advance Letters';
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/SalesAdvanceLetters.rdl';

    dataset
    {
        dataitem(Header; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));

            column(ReportFilters; ReportFilters)
            {
            }
            column(CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(ToDateCol; Format(ToDate))
            {
            }
        }
        dataitem("Advance Letter Template CZZ"; "Advance Letter Template CZZ")
        {
            DataItemTableView = sorting(Code) where("Sales/Purchase" = const(Sales));
            PrintOnlyIfDetail = true;

            column(Code_AdvanceLetterTemplate; Code)
            {
            }

            dataitem("Sales Adv. Letter Header CZZ"; "Sales Adv. Letter Header CZZ")
            {
                RequestFilterFields = "Advance Letter Code", "Bill-to Customer No.", "No.";
                DataItemLink = "Advance Letter Code" = field(code);

                column(No_SalesAdvanceLetterHeader; "No.")
                {
                    IncludeCaption = true;
                }
                column(BilltoCustomerNo_SalesAdvanceLetterHeader; "Bill-to Customer No.")
                {
                    IncludeCaption = true;
                }
                column(BilltoName_SalesAdvanceLetterHeader; "Bill-to Name")
                {
                    IncludeCaption = true;
                }
                column(CurrCode_SalesAdvanceLetterHeader; CurrCode)
                {
                }
                column(CurrCode_SalesAdvanceLetterHeaderCaption; FieldCaption("Currency Code"))
                {
                }
                column(AdvAmount; AdvAmount)
                {
                }
                column(PrintAdvPayed; PrintAdvPayed)
                {
                }
                column(PrintAdvToPay; PrintAdvToPay)
                {
                }
                column(PrintAdvUsed; PrintAdvUsed)
                {
                }
                column(PrintBalance; PrintBalance)
                {
                }
                column(PrintBalanceLCY; PrintBalanceLCY)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    SalesAdvLetterEntryCZZ.Reset();
                    SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", "Sales Adv. Letter Header CZZ"."No.");
                    SalesAdvLetterEntryCZZ.SetFilter("Posting Date", '..%1', ToDate);
                    SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
                    if SalesAdvLetterEntryCZZ.IsEmpty() then begin
                        AdvAmount := 0;
                        AdvInit := 0;
                        AdvClosed := 0;
                        AdvPayed := 0;
                        AdvUsed := 0;
                        AdvClosedLCY := 0;
                        AdvPayedLCY := 0;
                        AdvUsedLCY := 0;
                        AdvVATAdjust := 0;

                        if "Posting Date" > ToDate then
                            CurrReport.Skip();
                    end else begin
                        SalesAdvLetterEntryCZZ.SetRange("Posting Date");
                        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
                        SalesAdvLetterEntryCZZ.FindFirst();
                        AdvAmount := SalesAdvLetterEntryCZZ.Amount;

                        SalesAdvLetterEntryCZZ.SetFilter("Posting Date", '..%1', ToDate);
                        SalesAdvLetterEntryCZZ.SetFilter("Entry No.", '>%1', SalesAdvLetterEntryCZZ."Entry No.");
                        SalesAdvLetterEntryCZZ.CalcSums(Amount);
                        AdvInit := SalesAdvLetterEntryCZZ.Amount + AdvAmount;
                        SalesAdvLetterEntryCZZ.SetRange("Entry No.");

                        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Close);
                        SalesAdvLetterEntryCZZ.CalcSums(Amount, "Amount (LCY)");
                        AdvClosed := SalesAdvLetterEntryCZZ.Amount;
                        AdvClosedLCY := SalesAdvLetterEntryCZZ."Amount (LCY)";

                        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Payment);
                        SalesAdvLetterEntryCZZ.CalcSums(Amount, "Amount (LCY)");
                        AdvPayed := SalesAdvLetterEntryCZZ.Amount;
                        AdvPayedLCY := SalesAdvLetterEntryCZZ."Amount (LCY)";

                        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Usage);
                        SalesAdvLetterEntryCZZ.CalcSums(Amount, "Amount (LCY)");
                        AdvUsed := SalesAdvLetterEntryCZZ.Amount;
                        AdvUsedLCY := SalesAdvLetterEntryCZZ."Amount (LCY)";

                        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Adjustment");
                        SalesAdvLetterEntryCZZ.CalcSums("Amount (LCY)");
                        AdvVATAdjust := SalesAdvLetterEntryCZZ."Amount (LCY)";
                    end;

                    if OnlyOpen and (AdvInit + AdvPayed + AdvClosed = 0) and (AdvPayed + AdvUsed + AdvClosed = 0) then
                        CurrReport.Skip();

                    PrintAdvPayed := -AdvPayed;
                    PrintAdvToPay := AdvAmount + AdvPayed;
                    PrintAdvUsed := AdvUsed + AdvClosed;
                    PrintBalance := -(AdvPayed + AdvUsed + AdvClosed);
                    PrintBalanceLCY := -(AdvPayedLCY + AdvUsedLCY + AdvClosedLCY + AdvVATAdjust);
                    TotalBalanceLCYByLetterCode += PrintBalanceLCY;

                    if "Sales Adv. Letter Header CZZ"."Currency Code" <> '' then
                        CurrCode := "Sales Adv. Letter Header CZZ"."Currency Code"
                    else
                        CurrCode := GeneralLedgerSetup."LCY Code";

                    Clear(CurrAmount);

                    if not CurrTotalByLetterCode.ContainsKey(CurrCode) then
                        for i := 1 to 5 do
                            CurrAmount.Add(0)
                    else
                        CurrAmount := CurrTotalByLetterCode.Get(CurrCode);

                    CurrAmount.Set(1, CurrAmount.Get(1) + AdvAmount);
                    CurrAmount.Set(2, CurrAmount.Get(2) + PrintAdvPayed);
                    CurrAmount.Set(3, CurrAmount.Get(3) + PrintAdvToPay);
                    CurrAmount.Set(4, CurrAmount.Get(4) + PrintAdvUsed);
                    CurrAmount.Set(5, CurrAmount.Get(5) + PrintBalance);

                    if not CurrTotalByLetterCode.ContainsKey(CurrCode) then
                        CurrTotalByLetterCode.Add(CurrCode, CurrAmount)
                    else
                        CurrTotalByLetterCode.Set(CurrCode, CurrAmount);
                end;
            }
            dataitem(TotalByLetterCode; Integer)
            {
                DataItemTableView = sorting(Number);

                column(CurrCode_TotalByLetterCode; CurrCode)
                {
                }
                column(AdvAmount_TotalByLetterCode; CurrAmount.Get(1))
                {
                }
                column(PrintAdvPayed_TotalByLetterCode; CurrAmount.Get(2))
                {
                }
                column(PrintAdvToPay_TotalByLetterCode; CurrAmount.Get(3))
                {
                }
                column(PrintAdvUsed_TotalByLetterCode; CurrAmount.Get(4))
                {
                }
                column(PrintBalance_TotalByLetterCode; CurrAmount.Get(5))
                {
                }
                column(BalanceLCY_TotalByLetterCode; TotalBalanceLCYByLetterCode)
                {
                }

                trigger OnPreDataItem()
                begin
                    CurrList := CurrTotalByLetterCode.Keys;
                    SetRange(Number, 1, CurrList.Count);
                end;

                trigger OnAfterGetRecord()
                var
                    CurrTotalAmount: List of [Decimal];
                begin
                    CurrCode := CurrList.Get(Number);
                    CurrAmount := CurrTotalByLetterCode.Get(CurrCode);

                    if not CurrTotal.ContainsKey(CurrCode) then
                        for i := 1 to 5 do
                            CurrTotalAmount.Add(0)
                    else
                        CurrTotalAmount := CurrTotal.Get(CurrCode);

                    CurrTotalAmount.Set(1, CurrTotalAmount.Get(1) + CurrAmount.Get(1));
                    CurrTotalAmount.Set(2, CurrTotalAmount.Get(2) + CurrAmount.Get(2));
                    CurrTotalAmount.Set(3, CurrTotalAmount.Get(3) + CurrAmount.Get(3));
                    CurrTotalAmount.Set(4, CurrTotalAmount.Get(4) + CurrAmount.Get(4));
                    CurrTotalAmount.Set(5, CurrTotalAmount.Get(5) + CurrAmount.Get(5));

                    if not CurrTotal.ContainsKey(CurrCode) then
                        CurrTotal.Add(CurrCode, CurrTotalAmount)
                    else
                        CurrTotal.Set(CurrCode, CurrTotalAmount);
                end;

                trigger OnPostDataItem()
                begin
                    TotalBalanceLCY += TotalBalanceLCYByLetterCode;

                    Clear(CurrTotalByLetterCode);
                    TotalBalanceLCYByLetterCode := 0;
                end;
            }
        }
        dataitem(Total; Integer)
        {
            DataItemTableView = sorting(Number);

            column(CurrCode_Total; CurrCode)
            {
            }
            column(AdvAmount_Total; CurrAmount.Get(1))
            {
            }
            column(PrintAdvPayed_Total; CurrAmount.Get(2))
            {
            }
            column(PrintAdvToPay_Total; CurrAmount.Get(3))
            {
            }
            column(PrintAdvUsed_Total; CurrAmount.Get(4))
            {
            }
            column(PrintBalance_Total; CurrAmount.Get(5))
            {
            }
            column(BalanceLCY_Total; TotalBalanceLCY)
            {
            }

            trigger OnPreDataItem()
            begin
                CurrList := CurrTotal.Keys;
                SetRange(Number, 1, CurrList.Count);
            end;

            trigger OnAfterGetRecord()
            begin
                CurrCode := CurrList.Get(Number);
                CurrAmount := CurrTotal.Get(CurrCode);
            end;

            trigger OnPostDataItem()
            begin
                Clear(CurrTotal);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(OnlyOpenField; OnlyOpen)
                    {
                        Caption = 'Only Open';
                        ToolTip = 'Print only open advance letter.';
                        ApplicationArea = Basic, Suite;
                    }
                    field(ToDateField; ToDate)
                    {
                        Caption = 'To Date';
                        ToolTip = 'Print state to date.';
                        ApplicationArea = Basic, Suite;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if ToDate = 0D then
                ToDate := WorkDate();
        end;
    }

    labels
    {
        ReportLbl = 'Sales Advance Letters';
        PageLbl = 'Page';
        TotalLbl = 'Total';
        TotalForLbl = 'Total for';
        StateToDateLbl = 'State to date';
        AmountLbl = 'Amount';
        PayedLbl = 'Payed';
        ToPayLbl = 'To Pay';
        UsedLbl = 'Used';
        BalanceLbl = 'Balance';
        BalanceLCYLbl = 'Balance (LCY)';
    }

    trigger OnPreReport()
    begin
        if ToDate = 0D then
            ToDate := WorkDate();

        if "Sales Adv. Letter Header CZZ".GetFilters() <> '' then
            ReportFilters := StrSubstNo(FiltersTxt, "Sales Adv. Letter Header CZZ".TableCaption(), "Sales Adv. Letter Header CZZ".GetFilters());

        GeneralLedgerSetup.Get();
    end;

    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        GeneralLedgerSetup: Record "General Ledger Setup";
        ReportFilters: Text;
        AdvAmount, AdvInit, AdvPayed, AdvPayedLCY, AdvUsed, AdvUsedLCY, AdvClosed, AdvClosedLCY, AdvVATAdjust : Decimal;
        PrintAdvPayed, PrintAdvToPay, PrintAdvUsed, PrintBalance, PrintBalanceLCY : Decimal;
        TotalBalanceLCYByLetterCode, TotalBalanceLCY : Decimal;
        CurrCode: Code[10];
        ToDate: Date;
        OnlyOpen: Boolean;
        i: Integer;
        CurrTotalByLetterCode: Dictionary of [Code[10], List of [Decimal]];
        CurrTotal: Dictionary of [Code[10], List of [Decimal]];
        CurrAmount: List of [Decimal];
        CurrList: List of [Code[10]];
        FiltersTxt: Label 'Filters: %1: %2', Comment = '%1 = Table Caption, %2 = Table Filter';
}
