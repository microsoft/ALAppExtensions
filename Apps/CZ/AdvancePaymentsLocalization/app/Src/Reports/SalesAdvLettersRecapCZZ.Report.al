// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Setup;
using System.Utilities;

report 31026 "Sales Adv. Letters Recap. CZZ"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    Caption = 'Sales Advance Letters Recapitulation';
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/SalesAdvLettersRecap.rdl';

    dataset
    {
        dataitem(Header; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));

            column(ReportFilters; ReportFilters)
            {
            }
            column(AmountsInLCY; AmountsInLCY)
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
                column(AdvPayedLCY; AdvPayedLCY)
                {
                }
                column(AdvPayedVATLCY; AdvPayedVATLCY)
                {
                }
                column(AdvUsedLCY; AdvUsedLCY)
                {
                }
                column(AdvUsedVATLCY; AdvUsedVATLCY)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if OnlyOpen and (Status in [Status::New, Status::Closed]) then
                        CurrReport.Skip();

                    SalesAdvLetterEntryCZZ.Reset();
                    SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", "Sales Adv. Letter Header CZZ"."No.");
                    SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
                    if SalesAdvLetterEntryCZZ.IsEmpty() then begin
                        AdvPayedLCY := 0;
                        AdvPayedVATLCY := 0;
                        AdvUsedLCY := 0;
                        AdvUsedVATLCY := 0;
                    end else begin
                        SalesAdvLetterEntryCZZ.SetFilter("Posting Date", '..%1', ToDate);
                        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Payment);
                        SalesAdvLetterEntryCZZ.CalcSums("Amount (LCY)");
                        AdvPayedLCY := -SalesAdvLetterEntryCZZ."Amount (LCY)";

                        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
                        SalesAdvLetterEntryCZZ.CalcSums("Amount (LCY)");
                        AdvPayedVATLCY := -SalesAdvLetterEntryCZZ."Amount (LCY)";

                        SalesAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2', SalesAdvLetterEntryCZZ."Entry Type"::Usage, SalesAdvLetterEntryCZZ."Entry Type"::Close);
                        SalesAdvLetterEntryCZZ.CalcSums("Amount (LCY)");
                        AdvUsedLCY := SalesAdvLetterEntryCZZ."Amount (LCY)";

                        SalesAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2|%3', SalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Close",
                            SalesAdvLetterEntryCZZ."Entry Type"::"VAT Rate");
                        SalesAdvLetterEntryCZZ.CalcSums("Amount (LCY)");
                        AdvUsedVATLCY := SalesAdvLetterEntryCZZ."Amount (LCY)";
                    end;

                    if OnlyDifferences and (AdvPayedLCY - AdvPayedVATLCY = 0) and (AdvUsedLCY - AdvUsedVATLCY = 0) then
                        CurrReport.Skip();
                end;
            }
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
                    field(OnlyDifferencesField; OnlyDifferences)
                    {
                        Caption = 'Only Differences';
                        ToolTip = 'Print only advance letter with differences.';
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
        ReportLbl = 'Sales Advance Letters Recapitulation';
        PageLbl = 'Page';
        TotalLbl = 'Total';
        TotalForLbl = 'Total for';
        StateToDateLbl = 'State to date';
        AmountLbl = 'Amount';
        PayedLbl = 'Payment';
        UsedLbl = 'Usage';
        PayedVATLbl = 'VAT Payment';
        UsedVATLbl = 'VAT Usage';
        DifferenceLbl = 'Difference';
    }

    trigger OnPreReport()
    begin
        if ToDate = 0D then
            ToDate := WorkDate();

        if "Sales Adv. Letter Header CZZ".GetFilters() <> '' then
            ReportFilters := StrSubstNo(FiltersTxt, "Sales Adv. Letter Header CZZ".TableCaption(), "Sales Adv. Letter Header CZZ".GetFilters());

        GeneralLedgerSetup.Get();
        AmountsInLCY := StrSubstNo(AmountsInLCYTxt, GeneralLedgerSetup."LCY Code")
    end;

    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        GeneralLedgerSetup: Record "General Ledger Setup";
        ReportFilters, AmountsInLCY : Text;
        AdvPayedLCY, AdvPayedVATLCY, AdvUsedLCY, AdvUsedVATLCY : Decimal;
        ToDate: Date;
        OnlyOpen: Boolean;
        OnlyDifferences: Boolean;
        FiltersTxt: Label 'Filters: %1: %2', Comment = '%1 = Table Caption, %2 = Table Filter';
        AmountsInLCYTxt: Label 'All Amounts are in %1.', Comment = '%1 = Currency Code';
}
