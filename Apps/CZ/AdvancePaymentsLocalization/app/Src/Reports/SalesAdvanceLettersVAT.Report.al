// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Setup;
using System.Utilities;

report 31023 "Sales Advance Letters VAT CZZ"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    Caption = 'Sales Advance Letters VAT';
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/SalesAdvanceLettersVAT.rdl';

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
            column(PrintEntriesCol; PrintEntries)
            {
            }
        }
        dataitem("Sales Adv. Letter Header CZZ"; "Sales Adv. Letter Header CZZ")
        {
            RequestFilterFields = "Advance Letter Code", "Bill-to Customer No.", "No.";

            column(Advance_Letter_Code; "Advance Letter Code")
            {
            }
            column(No_SalesAdvanceLetterHeader; "No.")
            {
                IncludeCaption = true;
            }
            column(BilltoCustomerNo_SalesAdvLetterHeader; "Bill-to Customer No.")
            {
                IncludeCaption = true;
            }
            column(BilltoName_SalesAdvLetterHeader; "Bill-to Name")
            {
                IncludeCaption = true;
            }

            dataitem("Sales Adv. Letter Entry CZZ"; "Sales Adv. Letter Entry CZZ")
            {
                DataItemTableView = where("Entry Type" = filter("VAT Payment" | "VAT Usage" | "VAT Close" | "VAT Rate" | "VAT Adjustment"), Cancelled = const(false));
                DataItemLink = "Sales Adv. Letter No." = field("No.");

                column(Document_No_; "Document No.")
                {
                    IncludeCaption = true;
                }
                column(PostingDate_SalesAdvLetterEntry; Format("Posting Date"))
                {
                }
                column(PostingDate_SalesAdvLetterEntryCaption; FieldCaption("Posting Date"))
                {
                }
                column(VATDate_SalesAdvLetterEntry; Format("VAT Date"))
                {
                }
                column(VATDate_SalesAdvLetterEntryCaption; FieldCaption("VAT Date"))
                {
                }
                column(EntryType_SalesAdvLetterEntry; Format("Entry Type"))
                {
                }
                column(EntryType_SalesAdvLetterEntryCaption; FieldCaption("Entry Type"))
                {
                }
                column(VATBusPostingGroup_SalesAdvLetterEntry; "VAT Bus. Posting Group")
                {
                    IncludeCaption = true;
                }
                column(VATProdPostingGroup_SalesAdvLetterEntry; "VAT Prod. Posting Group")
                {
                    IncludeCaption = true;
                }
                column(VATBaseAmountLCY_SalesAdvLetterEntry; "VAT Base Amount (LCY)")
                {
                    IncludeCaption = true;
                }
                column(VATAmountLCY_SalesAdvLetterEntry; "VAT Amount (LCY)")
                {
                    IncludeCaption = true;
                }

                trigger OnPreDataItem()
                begin
                    SetFilter("Posting Date", '..%1', ToDate);
                end;
            }

            trigger OnAfterGetRecord()
            var
                SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
            begin
                SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", "Sales Adv. Letter Header CZZ"."No.");
                SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
                SalesAdvLetterEntryCZZ.SetFilter("Posting Date", '..%1', ToDate);
                SalesAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2|%3|%4|%5', SalesAdvLetterEntryCZZ."Entry Type"::"VAT Payment",
                  SalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Close",
                  SalesAdvLetterEntryCZZ."Entry Type"::"VAT Rate", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Adjustment");
                if SalesAdvLetterEntryCZZ.IsEmpty() then
                    CurrReport.Skip();
                if OnlyOpen then begin
                    SalesAdvLetterEntryCZZ.CalcSums("VAT Base Amount (LCY)", "VAT Amount (LCY)");
                    if (SalesAdvLetterEntryCZZ."VAT Base Amount (LCY)" = 0) and (SalesAdvLetterEntryCZZ."VAT Amount (LCY)" = 0) then
                        CurrReport.Skip();
                end;
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
                    field(PrintEntriesField; PrintEntries)
                    {
                        Caption = 'Print Entries';
                        ToolTip = 'Specifies if entries will be printed.';
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
        ReportLbl = 'Sales Advance Letters VAT';
        PageLbl = 'Page';
        TotalLbl = 'Total';
        TotalForLbl = 'Total for';
        StateToDateLbl = 'State to date';
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
        GeneralLedgerSetup: Record "General Ledger Setup";
        ReportFilters, AmountsInLCY : Text;
        ToDate: Date;
        OnlyOpen, PrintEntries : Boolean;
        FiltersTxt: Label 'Filters: %1: %2', Comment = '%1 = Table Caption, %2 = Table Filter';
        AmountsInLCYTxt: Label 'All Amounts are in %1.', Comment = '%1 = Currency Code';
}
