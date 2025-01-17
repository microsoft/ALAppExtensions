// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.History;

report 10038 "IRS 1099 Propagate Vend. Setup"
{
    Caption = 'IRS 1099 Propagate Vendor Form Box Setup';
    ProcessingOnly = true;
    ApplicationArea = BasicUS;
    Permissions = TableData "Vendor Ledger Entry" = rm, tabledata "Purch. Inv. Header" = rm;

    dataset
    {
        dataitem(IRS1099VendorFormBoxSetup; "IRS 1099 Vendor Form Box Setup")
        {
            DataItemTableView = sorting("Period No.", "Vendor No.");

            trigger OnAfterGetRecord()
            begin
                if (StartingDate = 0D) or (EndingDate = 0D) then
                    Error(DatesMustBeSpecifiedErr);
                if (not PurchaseDocuments) and (not VendorLedgerEntries) then
                    Error(OneOfTheReportOptionsMustBeSelectedErr);
                if PurchaseDocuments then
                    UpdatePurchaseDocuments();
                if VendorLedgerEntries then
                    UpdateVendorLedgerEntries();
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
                    field(StartingDateControl; StartingDate)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Starting Date';
                        ToolTip = 'Specifies the starting posting date of the vendor ledger entries to be included in propagation process.';

                        trigger OnValidate()
                        begin
                            if not (StartingDate in [IRSReportingPeriod."Starting Date" .. IRSReportingPeriod."Ending Date"]) then
                                error(DateMustBeInSelectedPeriodErr, IRSReportingPeriod.FieldCaption("Starting Date"));
                        end;
                    }
                    field(EndingDateControl; EndingDate)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Ending Date';
                        ToolTip = 'Specifies the ending posting date of the vendor ledger entries to be included in propagation process.';

                        trigger OnValidate()
                        begin
                            if not (EndingDate in [IRSReportingPeriod."Starting Date" .. IRSReportingPeriod."Ending Date"]) then
                                error(DateMustBeInSelectedPeriodErr, IRSReportingPeriod.FieldCaption("Ending Date"));
                        end;
                    }
                    field(PurchaseDocumentsControl; PurchaseDocuments)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Purchase Documents';
                        ToolTip = 'Specifies whether to include purchase documents in the propagation process.';
                    }
                    field(VendorLedgerEntriesControl; VendorLedgerEntries)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Vendor Ledger Entries';
                        ToolTip = 'Specifies whether to include vendor ledger entries in the propagation process.';

                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if IRS1099VendorFormBoxSetup.GetFilter("Period No.") = '' then
                error(PeriodMustBeSpecifiedErr);
            IRSReportingPeriod.Get(IRS1099VendorFormBoxSetup.GetFilter("Period No."));
            StartingDate := IRSReportingPeriod."Starting Date";
            EndingDate := IRSReportingPeriod."Ending Date";
        end;
    }

    var
        IRSReportingPeriod: Record "IRS Reporting Period";
        StartingDate, EndingDate : Date;
        PurchaseDocuments, VendorLedgerEntries : Boolean;
        PeriodMustBeSpecifiedErr: Label 'Period No. must be specified.';
        DateMustBeInSelectedPeriodErr: Label '%1 must be within the selected reporting period.', Comment = '%1 = starting or ending date';
        DatesMustBeSpecifiedErr: Label 'Starting and Ending Date must be specified.';
        OneOfTheReportOptionsMustBeSelectedErr: Label 'At least Purchase Documents or Vendor Ledger Entries option must be selected.';

    local procedure UpdatePurchaseDocuments()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.SetRange("Posting Date", StartingDate, EndingDate);
        PurchaseHeader.SetRange("Buy-from Vendor No.", IRS1099VendorFormBoxSetup."Vendor No.");
        PurchaseHeader.SetFilter(
            "Document Type", '%1|%2|%3|%4',
            PurchaseHeader."Document Type"::Order, PurchaseHeader."Document Type"::Invoice,
            PurchaseHeader."Document Type"::"Credit Memo", PurchaseHeader."Document Type"::"Return Order");
        PurchaseHeader.SetRange(Status, PurchaseHeader.Status::Open);
        if PurchaseHeader.FindSet(true) then
            repeat
                PurchaseHeader.Validate("IRS 1099 Reporting Period", IRS1099VendorFormBoxSetup."Period No.");
                PurchaseHeader.Validate("IRS 1099 Form No.", IRS1099VendorFormBoxSetup."Form No.");
                PurchaseHeader.Validate("IRS 1099 Form Box No.", IRS1099VendorFormBoxSetup."Form Box No.");
                PurchaseHeader.Modify(true);
            until PurchaseHeader.Next() = 0;
    end;

    local procedure UpdateVendorLedgerEntries()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        VendorLedgerEntry.SetRange("Posting Date", StartingDate, EndingDate);
        VendorLedgerEntry.SetRange("Vendor No.", IRS1099VendorFormBoxSetup."Vendor No.");
        VendorLedgerEntry.SetFilter("Document Type", '%1|%2', VendorLedgerEntry."Document Type"::Invoice, VendorLedgerEntry."Document Type"::"Credit Memo");
        if VendorLedgerEntry.FindSet(true) then
            repeat
                VendorLedgerEntry.Validate("IRS 1099 Reporting Period", IRS1099VendorFormBoxSetup."Period No.");
                VendorLedgerEntry.Validate("IRS 1099 Form No.", IRS1099VendorFormBoxSetup."Form No.");
                VendorLedgerEntry.Validate("IRS 1099 Form Box No.", IRS1099VendorFormBoxSetup."Form Box No.");
                VendorLedgerEntry.CalcFields(Amount);
                VendorLedgerEntry.Validate("IRS 1099 Reporting Amount", VendorLedgerEntry.Amount);
                VendorLedgerEntry.Modify();
                if PurchInvHeader.Get(VendorLedgerEntry."Document No.") then begin
                    PurchInvHeader.Validate("IRS 1099 Reporting Period", IRS1099VendorFormBoxSetup."Period No.");
                    PurchInvHeader.Validate("IRS 1099 Form No.", IRS1099VendorFormBoxSetup."Form No.");
                    PurchInvHeader.Validate("IRS 1099 Form Box No.", IRS1099VendorFormBoxSetup."Form Box No.");
                    PurchInvHeader.Modify(true);
                end;
            until VendorLedgerEntry.Next() = 0;
    end;

}
