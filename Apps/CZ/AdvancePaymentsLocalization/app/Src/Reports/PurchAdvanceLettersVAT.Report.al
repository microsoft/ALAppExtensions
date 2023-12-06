// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Setup;
using System.Utilities;

report 31025 "Purch. Advance Letters VAT CZZ"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    Caption = 'Purchase Advance Letters VAT';
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/PurchAdvanceLettersVAT.rdl';

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
        dataitem("Purch. Adv. Letter Header CZZ"; "Purch. Adv. Letter Header CZZ")
        {
            RequestFilterFields = "Advance Letter Code", "Pay-to Vendor No.", "No.";

            column(Advance_Letter_Code; "Advance Letter Code")
            {
            }
            column(No_PurchAdvanceLetterHeader; "No.")
            {
                IncludeCaption = true;
            }
            column(PaytoVendorNo_PurchAdvLetterHeader; "Pay-to Vendor No.")
            {
                IncludeCaption = true;
            }
            column(PaytoName_PurchAdvLetterHeader; "Pay-to Name")
            {
                IncludeCaption = true;
            }

            dataitem("Purch. Adv. Letter Entry CZZ"; "Purch. Adv. Letter Entry CZZ")
            {
                DataItemTableView = where("Entry Type" = filter("VAT Payment" | "VAT Usage" | "VAT Close" | "VAT Rate" | "VAT Adjustment"), Cancelled = const(false));
                DataItemLink = "Purch. Adv. Letter No." = field("No.");

                column(Document_No_; "Document No.")
                {
                    IncludeCaption = true;
                }
                column(PostingDate_PurchAdvLetterEntry; Format("Posting Date"))
                {
                }
                column(PostingDate_PurchAdvLetterEntryCaption; FieldCaption("Posting Date"))
                {
                }
                column(VATDate_PurchAdvLetterEntry; Format("VAT Date"))
                {
                }
                column(VATDate_PurchAdvLetterEntryCaption; FieldCaption("VAT Date"))
                {
                }
                column(EntryType_PurchAdvLetterEntry; Format("Entry Type"))
                {
                }
                column(EntryType_PurchAdvLetterEntryCaption; FieldCaption("Entry Type"))
                {
                }
                column(VATBusPostingGroup_PurchAdvLetterEntry; "VAT Bus. Posting Group")
                {
                    IncludeCaption = true;
                }
                column(VATProdPostingGroup_PurchAdvLetterEntry; "VAT Prod. Posting Group")
                {
                    IncludeCaption = true;
                }
                column(VATBaseAmountLCY_PurchAdvLetterEntry; "VAT Base Amount (LCY)")
                {
                    IncludeCaption = true;
                }
                column(VATAmountLCY_PurchAdvLetterEntry; "VAT Amount (LCY)")
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
                PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
            begin
                PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", "Purch. Adv. Letter Header CZZ"."No.");
                PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
                PurchAdvLetterEntryCZZ.SetFilter("Posting Date", '..%1', ToDate);
                PurchAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2|%3|%4|%5', PurchAdvLetterEntryCZZ."Entry Type"::"VAT Payment",
                  PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Close",
                  PurchAdvLetterEntryCZZ."Entry Type"::"VAT Rate", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Adjustment");
                if PurchAdvLetterEntryCZZ.IsEmpty() then
                    CurrReport.Skip();
                if OnlyOpen then begin
                    PurchAdvLetterEntryCZZ.CalcSums("VAT Base Amount (LCY)", "VAT Amount (LCY)");
                    if (PurchAdvLetterEntryCZZ."VAT Base Amount (LCY)" = 0) and (PurchAdvLetterEntryCZZ."VAT Amount (LCY)" = 0) then
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
        ReportLbl = 'Purchase Advance Letters VAT';
        PageLbl = 'Page';
        TotalLbl = 'Total';
        TotalForLbl = 'Total for';
        StateToDateLbl = 'State to date';
    }

    trigger OnPreReport()
    begin
        if ToDate = 0D then
            ToDate := WorkDate();

        if "Purch. Adv. Letter Header CZZ".GetFilters() <> '' then
            ReportFilters := StrSubstNo(FiltersTxt, "Purch. Adv. Letter Header CZZ".TableCaption(), "Purch. Adv. Letter Header CZZ".GetFilters());

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
