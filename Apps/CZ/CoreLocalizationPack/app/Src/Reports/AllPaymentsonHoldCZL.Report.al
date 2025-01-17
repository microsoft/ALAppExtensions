// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Posting;

using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;

report 11704 "All Payments on Hold CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/AllPaymentsonHold.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'All Payments on Hold';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", Name;

            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(Vendor_Filters; VendorFilters)
            {
            }
            column(Vendor_No; "No.")
            {
                IncludeCaption = true;
            }
            column(Vendor_Name; Name)
            {
                IncludeCaption = true;
            }
            dataitem(VendorLedgerEntry; "Vendor Ledger Entry")
            {
                DataItemLink = "Vendor No." = field("No.");
                DataItemTableView = sorting("Vendor No.", Open, Positive, "Due Date") where(Open = const(true), "On Hold" = filter(<> ''));

                column(VendorLedgerEntry_DueDate; "Due Date")
                {
                    IncludeCaption = true;
                }
                column(VendorLedgerEntry_PostingDate; "Posting Date")
                {
                    IncludeCaption = true;
                }
                column(VendorLedgerEntry_DocumentType; "Document Type")
                {
                    IncludeCaption = true;
                }
                column(VendorLedgerEntry_DocumentNo; "Document No.")
                {
                    IncludeCaption = true;
                }
                column(VendorLedgerEntry_Description; Description)
                {
                    IncludeCaption = true;
                }
                column(VendorLedgerEntry_CurrencyCode; "Currency Code")
                {
                }
                column(VendorLedgerEntry_OnHold; "On Hold")
                {
                    IncludeCaption = true;
                }
                column(VendorLedgerEntry_RemainingAmount; "Remaining Amount")
                {
                    IncludeCaption = true;
                    AutoCalcField = true;
                }
                column(VendorLedgerEntry_RemainingAmtLCY; "Remaining Amt. (LCY)")
                {
                    IncludeCaption = true;
                    AutoCalcField = true;
                }
                column(VendorLedgerEntry_EntryNo; "Entry No.")
                {
                    IncludeCaption = true;
                }

                trigger OnPreDataItem()
                begin
                    if LastDueDate <> 0D then
                        SetFilter("Due Date", '..%1', LastDueDate);
                end;
            }
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
                    field(LastDueDateField; LastDueDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Last Due Date';
                        ToolTip = 'Specifies the last due date for the entrie''s filter.';
                    }
                }
            }
        }
    }

    labels
    {
        PageLbl = 'Page';
        ReportNameLbl = 'Payments on Hold';
        TotalLCYbl = 'Total (LCY)';
        CurrencyCodeLbl = 'Curr. Code';
    }

    trigger OnPreReport()
    var
        VendorFiltersTok: Label '%1: %2', Locked = true;
    begin
        if Vendor.GetFilters() <> '' then
            VendorFilters := StrSubstNo(VendorFiltersTok, Vendor.TableCaption(), Vendor.GetFilters());
    end;

    var
        VendorFilters: Text;
        LastDueDate: Date;
}
