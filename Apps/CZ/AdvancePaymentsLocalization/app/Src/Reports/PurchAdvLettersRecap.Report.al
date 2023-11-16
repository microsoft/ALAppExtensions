// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Setup;
using System.Utilities;

report 31027 "Purch. Adv. Letters Recap. CZZ"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    Caption = 'Purch. Advance Letters Recapitulation';
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/PurchAdvLettersRecap.rdl';

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
            DataItemTableView = sorting(Code) where("Sales/Purchase" = const(Purchase));
            PrintOnlyIfDetail = true;

            column(Code_AdvanceLetterTemplate; Code)
            {
            }

            dataitem("Purch. Adv. Letter Header CZZ"; "Purch. Adv. Letter Header CZZ")
            {
                RequestFilterFields = "Advance Letter Code", "Pay-to Vendor No.", "No.";
                DataItemLink = "Advance Letter Code" = field(code);

                column(No_PurchAdvanceLetterHeader; "No.")
                {
                    IncludeCaption = true;
                }
                column(PaytoVendorNo_PurchAdvanceLetterHeader; "Pay-to Vendor No.")
                {
                    IncludeCaption = true;
                }
                column(PaytoName_PurchAdvanceLetterHeader; "Pay-to Name")
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

                    PurchAdvLetterEntryCZZ.Reset();
                    PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", "Purch. Adv. Letter Header CZZ"."No.");
                    PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
                    if PurchAdvLetterEntryCZZ.IsEmpty() then begin
                        AdvPayedLCY := 0;
                        AdvPayedVATLCY := 0;
                        AdvUsedLCY := 0;
                        AdvUsedVATLCY := 0;
                    end else begin
                        PurchAdvLetterEntryCZZ.SetFilter("Posting Date", '..%1', ToDate);
                        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Payment);
                        PurchAdvLetterEntryCZZ.CalcSums("Amount (LCY)");
                        AdvPayedLCY := PurchAdvLetterEntryCZZ."Amount (LCY)";

                        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
                        PurchAdvLetterEntryCZZ.CalcSums("Amount (LCY)");
                        AdvPayedVATLCY := PurchAdvLetterEntryCZZ."Amount (LCY)";

                        PurchAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2', PurchAdvLetterEntryCZZ."Entry Type"::Usage, PurchAdvLetterEntryCZZ."Entry Type"::Close);
                        PurchAdvLetterEntryCZZ.CalcSums("Amount (LCY)");
                        AdvUsedLCY := -PurchAdvLetterEntryCZZ."Amount (LCY)";

                        PurchAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2|%3', PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Close",
                            PurchAdvLetterEntryCZZ."Entry Type"::"VAT Rate");
                        PurchAdvLetterEntryCZZ.CalcSums("Amount (LCY)");
                        AdvUsedVATLCY := -PurchAdvLetterEntryCZZ."Amount (LCY)";
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
        ReportLbl = 'Purchase Advance Letters Recapitulation';
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

        if "Purch. Adv. Letter Header CZZ".GetFilters() <> '' then
            ReportFilters := StrSubstNo(FiltersTxt, "Purch. Adv. Letter Header CZZ".TableCaption(), "Purch. Adv. Letter Header CZZ".GetFilters());

        GeneralLedgerSetup.Get();
        AmountsInLCY := StrSubstNo(AmountsInLCYTxt, GeneralLedgerSetup."LCY Code")
    end;

    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        GeneralLedgerSetup: Record "General Ledger Setup";
        ReportFilters, AmountsInLCY : Text;
        AdvPayedLCY, AdvPayedVATLCY, AdvUsedLCY, AdvUsedVATLCY : Decimal;
        ToDate: Date;
        OnlyOpen: Boolean;
        OnlyDifferences: Boolean;
        FiltersTxt: Label 'Filters: %1: %2', Comment = '%1 = Table Caption, %2 = Table Filter';
        AmountsInLCYTxt: Label 'All Amounts are in %1.', Comment = '%1 = Currency Code';
}
