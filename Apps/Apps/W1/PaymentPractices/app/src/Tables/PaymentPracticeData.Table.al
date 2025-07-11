// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Analysis;

using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;

table 686 "Payment Practice Data"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Header No."; Integer)
        {

        }
        field(2; "Invoice Entry No."; Integer)
        {

        }
        field(3; "Source Type"; Enum "Paym. Prac. Header Type")
        {

        }
        field(4; "Pmt. Entry No."; Integer)
        {

        }
        field(5; "Invoice Posting Date"; Date)
        {

        }
        field(6; "Invoice Received Date"; Date)
        {

        }
        field(7; "Due Date"; Date)
        {

        }
        field(8; "Pmt. Posting Date"; Date)
        {

        }
        field(9; "Invoice Is Open"; Boolean)
        {

        }
        field(10; "Invoice Doc. No."; Code[20])
        {

        }
        field(11; "CV No."; Code[20])
        {

        }
        field(12; "Inv. External Document No."; Code[35])
        {

        }
        field(13; "Company Size Code"; Code[20])
        {

        }
        field(14; "Agreed Payment Days"; Integer)
        {

        }
        field(15; "Actual Payment Days"; Integer)
        {

        }
        field(16; "Invoice Amount"; Decimal)
        {

        }

    }

    keys
    {
        key(Key1; "Header No.", "Invoice Entry No.", "Source Type")
        {
            Clustered = true;
        }
        key(Key2; "Pmt. Posting Date") { }
    }

    fieldgroups
    {
    }

    procedure CopyFromInvoiceVendLedgEntry(VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        "Source Type" := "Paym. Prac. Header Type"::"Vendor";
        "Invoice Entry No." := VendorLedgerEntry."Entry No.";
        "CV No." := VendorLedgerEntry."Vendor No.";
        "Inv. External Document No." := VendorLedgerEntry."External Document No.";
        "Invoice Doc. No." := VendorLedgerEntry."Document No.";
        "Invoice Posting Date" := VendorLedgerEntry."Posting Date";
        if VendorLedgerEntry."Invoice Received Date" = 0D then
            "Invoice Received Date" := VendorLedgerEntry."Document Date"
        else
            "Invoice Received Date" := VendorLedgerEntry."Invoice Received Date";
        "Due Date" := VendorLedgerEntry."Due Date";
        "Invoice Is Open" := VendorLedgerEntry.Open;
        VendorLedgerEntry.CalcFields(Amount);
        "Invoice Amount" := -VendorLedgerEntry.Amount;
        "Pmt. Posting Date" := VendorLedgerEntry."Closed at Date";
        "Pmt. Entry No." := VendorLedgerEntry."Closed by Entry No.";
        if "Invoice Posting Date" <> 0D then
            "Agreed Payment Days" := "Due Date" - "Invoice Received Date";
        if "Pmt. Posting Date" <> 0D then
            "Actual Payment Days" := "Pmt. Posting Date" - "Invoice Received Date";
    end;

    procedure CopyFromInvoiceCustLedgEntry(CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        "Source Type" := "Paym. Prac. Header Type"::"Customer";
        "Invoice Entry No." := CustLedgerEntry."Entry No.";
        "CV No." := CustLedgerEntry."Customer No.";
        "Inv. External Document No." := CustLedgerEntry."External Document No.";
        "Invoice Doc. No." := CustLedgerEntry."Document No.";
        "Invoice Posting Date" := CustLedgerEntry."Posting Date";
        "Invoice Received Date" := CustLedgerEntry."Document Date";
        "Due Date" := CustLedgerEntry."Due Date";
        "Invoice Is Open" := CustLedgerEntry.Open;
        CustLedgerEntry.CalcFields(Amount);
        "Invoice Amount" := -CustLedgerEntry.Amount;
        "Pmt. Posting Date" := CustLedgerEntry."Closed at Date";
        "Pmt. Entry No." := CustLedgerEntry."Closed by Entry No.";
        if "Invoice Posting Date" <> 0D then
            "Agreed Payment Days" := "Due Date" - "Invoice Received Date";
        if "Pmt. Posting Date" <> 0D then
            "Actual Payment Days" := "Pmt. Posting Date" - "Invoice Received Date";
    end;

    procedure SetFilterForLine(PaymentPracticeLine: Record "Payment Practice Line")
    var
        PaymentPeriod: Record "Payment Period";
    begin
        Rec.SetRange("Header No.", PaymentPracticeLine."Header No.");
        Rec.SetRange("Source Type", PaymentPracticeLine."Source Type");
        case PaymentPracticeLine."Aggregation Type" of
            PaymentPracticeLine."Aggregation Type"::"Company Size":
                Rec.SetRange("Company Size Code", PaymentPracticeLine."Company Size Code");
            PaymentPracticeLine."Aggregation Type"::Period:
                begin
                    PaymentPeriod.Get(PaymentPracticeLine."Payment Period Code");
                    if PaymentPeriod."Days To" <> 0 then
                        Rec.SetRange("Actual Payment Days", PaymentPeriod."Days From", PaymentPeriod."Days To")
                    else
                        Rec.SetFilter("Actual Payment Days", '>=%1', PaymentPeriod."Days From");
                    Rec.SetRange("Invoice Is Open", false);
                end;
        end;
    end;
}

