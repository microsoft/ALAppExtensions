// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;
using System.IO;

report 18037 "Export Detailed GST Entries"
{
    Caption = 'Export Detailed GST Ledger Entries';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("Detailed GST Ledger Entry"; "Detailed GST Ledger Entry")
        {
            DataItemTableView = sorting("Entry No.");
            trigger OnAfterGetRecord()
            begin
                DetailedGSTLedgerEntryInfo.Get("Detailed GST Ledger Entry"."Entry No.");
                case NatureOfSupplyOption of
                    NatureOfSupplyOption::B2B:
                        if DetailedGSTLedgerEntryInfo."Nature of Supply" <> DetailedGSTLedgerEntryInfo."Nature of Supply"::B2B then
                            CurrReport.Skip();
                    NatureOfSupplyOption::B2C:
                        if DetailedGSTLedgerEntryInfo."Nature of Supply" <> DetailedGSTLedgerEntryInfo."Nature of Supply"::B2C then
                            CurrReport.Skip();
                end;

                TempExcelBuffer.NewRow();
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Entry No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Entry Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Transaction Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Document Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Document No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Posting Date", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".Type, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Product Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Source Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Source No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."HSN/SAC Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."GST Component Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."GST Group Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."GST Jurisdiction Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."GST Base Amount", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."GST %", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."GST Amount", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."External Document No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Amount Loaded on Item", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".Quantity, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."GST Without Payment of Duty", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."G/L Account No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Reversed by Entry No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".Reversed, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Document Line No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Item Charge Entry", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Reverse Charge", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."GST on Advance Payment", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Payment Document No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."GST Exempted Goods", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Location  Reg. No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Buyer/Seller Reg. No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."GST Group Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."GST Credit", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Reversal Entry", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Transaction No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Currency Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Currency Factor", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Application Doc. Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Application Doc. No", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Applied From Entry No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Reversed Entry No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Remaining Closed", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."GST Rounding Precision", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."GST Rounding Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Location Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."GST Customer Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."GST Vendor Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Original Invoice No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Reconciliation Month", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Reconciliation Year", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".Reconciled, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Credit Availed", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".Paid, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Credit Adjustment Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".UnApplied, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."GST Place of Supply", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Payment Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".Distributed, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Distributed Reversed", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Input Service Distribution", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".Opening, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Remaining Base Amount", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Remaining GST Amount", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Dist. Document No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Associated Enterprises", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Liable to Pay", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Dist. Input GST Credit", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Dist. Reverse Document No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Eligibility for ITC", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."GST Assessable Value", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."GST Inv. Rounding Precision", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."GST Inv. Rounding Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Cr. & Liab. Adjustment Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."AdjustmentBase Amount", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Adjustment Amount", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Custom Duty Amount", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Journal Entry", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Remaining Quantity", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."ARN No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Forex Fluctuation", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Fluctuation Amt. Credit", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."CAJ %", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."CAJ Amount", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."CAJ % Permanent Reversal", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."CAJ Amount Permanent Reversal", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Remaining CAJ Adj. Base Amt", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."Remaining CAJ Adj. Amt", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."CAJ Base Amount", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn("Detailed GST Ledger Entry"."G/L Entry No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."User ID", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.Positive, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Nature of Supply", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Location State Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Buyer/Seller State Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Shipping Address State Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Original Doc. Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Original Doc. No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."CLE/VLE Entry No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Bill Of Export No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Bill Of Export Date", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."e-Comm. Merchant Id", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."e-Comm. Operator GST Reg. No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Sales Invoice Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Original Invoice Date", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Amount to Customer/Vendor", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Adv. Pmt. Adjustment", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Payment Document Date", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.Cess, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Item Ledger Entry No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Credit Reversal", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Item Charge Assgn. Line No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Delivery Challan Amount", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Subcon Document No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Component Calc. Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Cess Amount Per Unit Factor", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Cess UOM", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Cess Factor Quantity", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Purchase Invoice Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Allocations Line No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Adjustment Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Rate Change Applicable", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Remaining Amount Closed", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Gen. Bus. Posting Group", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Gen. Prod. Posting Group", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Reason Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Last Credit Adjusted Date", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.UOM, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Bank Charge Entry", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Foreign Exchange", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Bill of Entry No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Bill of Entry Date", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Jnl. Bank Charge", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."GST Reason Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."RCM Exempt", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."RCM Exempt Transaction", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Order Address Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Bill to-Location(POS)", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Recurring Journal", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."GST Journal Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Ship-to Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."FA Journal Entry", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Without Bill Of Entry", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Finance Charge Memo", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Depreciation Book Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Location ARN No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."GST Base Amount FCY", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."GST Amount FCY", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."POS as Vendor State", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."POS Out Of India", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Ship-to Customer", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Ship-to GST Customer Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo."Ship-to Reg. No", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            end;

            trigger OnPostDataItem()
            begin
                CreateExcelBook();
            end;

            trigger OnPreDataItem()
            begin
                if StartDate = 0D then
                    Error(StartDateErr);

                if EndDate = 0D then
                    Error(EndDateErr);

                if (StartDate <> 0D) and (EndDate <> 0D) and (StartDate > EndDate) then
                    Error(StartDtGreaterErr);

                SetRange("Posting Date", StartDate, EndDate);
                if EntryTypeOption <> EntryTypeOption::" " then
                    SetRange("Entry Type", EntryType);
                if TransTypeOption <> TransTypeOption::" " then
                    SetRange("Transaction Type", TransType);
                if LocationRegNo <> '' then
                    SetRange("Location  Reg. No.", LocationRegNo);
                if DocType <> DocType::" " then
                    SetRange("Document Type", DocType);

                MakeExcelHeader();
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
                    field("Start Date"; StartDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Start Date';
                        ToolTip = 'Specifies the starting date of the report.';
                    }
                    field("End Date"; EndDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'End Date';
                        ToolTip = 'Specifies the ending date of the report.';
                    }
                    field("Location GST Reg. No."; LocationRegNo)
                    {
                        TableRelation = "GST Registration Nos.";
                        ApplicationArea = Basic, Suite;
                        Caption = 'Location GST Reg. No.';
                        ToolTip = 'Specifies the GST registration number of the location for which the report will be generated.';
                    }
                    field("Transaction Type"; TransTypeOption)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Transaction Type';
                        OptionCaption = ' , Purchase, Sales, Transfer, Settlement';
                        ToolTip = 'Specifies the transaction type for which the report will be generated.';
                        trigger OnValidate()
                        begin
                            case TransTypeOption of
                                TransTypeOption::"Purchase":
                                    TransType := TransType::Purchase;
                                TransTypeOption::Sales:
                                    TransType := TransType::Sales;
                                TransTypeOption::Settlement:
                                    TransType := TransType::Settlement;
                                TransTypeOption::Transfer:
                                    TransType := TransType::Transfer;
                            end;
                        end;
                    }
                    field("Nature Of Supply"; NatureOfSupplyOption)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Nature Of Supply';
                        OptionCaption = ' ,B2B,B2C';
                        ToolTip = 'Specifies the nature of GST transaction. For example, B2B/B2C.';
                        trigger OnValidate()
                        begin
                            case
                                NatureOfSupplyOption of
                                NatureOfSupplyOption::B2B:
                                    NatureOfSupply := NatureOfSupply::B2B;
                                NatureOfSupplyOption::B2C:
                                    NatureOfSupply := NatureOfSupply::B2C;
                            end;
                        end;
                    }
                    field("Document Type"; Doctype)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Document Type';
                        ToolTip = 'Specifies whether the document type is Payment, Invoice, Credit Memo, Transfer or Refund.';
                    }
                    field("Entry Type"; EntryTypeOption)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Entry Type';
                        OptionCaption = ' ,"Initial Entry",Application,"Adjustment Entry"';
                        ToolTip = 'Specifies whether the entry is an initial entry or an application entry or an adjustment entry.';
                        trigger OnValidate()
                        begin
                            case EntryTypeOption of
                                EntryTypeOption::"Adjustment Entry":
                                    EntryType := EntryType::"Adjustment Entry";
                                EntryTypeOption::Application:
                                    EntryType := EntryType::Application;
                                EntryTypeOption::"Initial Entry":
                                    EntryType := EntryType::"Initial Entry";
                            end;
                        end;
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        TempExcelBuffer.DeleteAll();
    end;

    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        StartDate: Date;
        EndDate: Date;
        LocationRegNo: Code[15];
        TransType: Enum "Detail Ledger Transaction Type";
        TransTypeOption: Option " ",Purchase,Sales,Transfer,Settlement;
        DocType: Enum "GST Document Type";
        EntryType: Enum "Detail Ledger Entry Type";
        EntryTypeOption: Option " ","Initial Entry",Application,"Adjustment Entry";
        NatureOfSupply: Enum "GST Nature of Supply";
        NatureOfSupplyOption: Option " ",B2B,B2C;

        StartDateErr: Label 'You must enter Start Date.';
        EndDateErr: Label 'You must enter End Date.';
        StartDtGreaterErr: Label 'You must not enter Start Date that is greater than End Date.';

    local procedure MakeExcelHeader()
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Entry No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Entry Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Transaction Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Document Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Document No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Posting Date"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption(Type), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Product Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Source Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Source No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("HSN/SAC Code"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("GST Component Code"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("GST Group Code"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("GST Jurisdiction Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("GST Base Amount"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("GST %"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("GST Amount"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("External Document No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Amount Loaded on Item"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption(Quantity), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("GST Without Payment of Duty"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("G/L Account No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Reversed by Entry No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption(Reversed), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Document Line No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Item Charge Entry"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Reverse Charge"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("GST on Advance Payment"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Payment Document No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("GST Exempted Goods"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Location  Reg. No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Buyer/Seller Reg. No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("GST Group Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("GST Credit"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Reversal Entry"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Transaction No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Currency Code"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Currency Factor"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Application Doc. Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Application Doc. No"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Applied From Entry No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Reversed Entry No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Remaining Closed"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("GST Rounding Precision"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("GST Rounding Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Location Code"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("GST Customer Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("GST Vendor Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Original Invoice No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Reconciliation Month"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Reconciliation Year"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption(Reconciled), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Credit Availed"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption(Paid), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Credit Adjustment Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption(UnApplied), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("GST Place of Supply"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Payment Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption(Distributed), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Distributed Reversed"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Input Service Distribution"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption(Opening), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Remaining Base Amount"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Remaining GST Amount"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Dist. Document No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Associated Enterprises"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Liable to Pay"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Dist. Input GST Credit"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Dist. Reverse Document No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Eligibility for ITC"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("GST Assessable Value"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("GST Inv. Rounding Precision"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("GST Inv. Rounding Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Cr. & Liab. Adjustment Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("AdjustmentBase Amount"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Adjustment Amount"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Custom Duty Amount"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Journal Entry"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Remaining Quantity"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("ARN No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Forex Fluctuation"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Fluctuation Amt. Credit"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("CAJ %"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("CAJ Amount"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("CAJ % Permanent Reversal"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("CAJ Amount Permanent Reversal"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Remaining CAJ Adj. Base Amt"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("Remaining CAJ Adj. Amt"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("CAJ Base Amount"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn("Detailed GST Ledger Entry".FieldCaption("G/L Entry No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("User ID"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption(Positive), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Nature of Supply"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Location State Code"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Buyer/Seller State Code"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Shipping Address State Code"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Original Doc. Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Original Doc. No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("CLE/VLE Entry No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Bill Of Export No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Bill Of Export Date"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("e-Comm. Merchant Id"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("e-Comm. Operator GST Reg. No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Sales Invoice Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Original Invoice Date"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Amount to Customer/Vendor"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Adv. Pmt. Adjustment"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Payment Document Date"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption(Cess), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Item Ledger Entry No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Credit Reversal"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Item Charge Assgn. Line No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Delivery Challan Amount"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Subcon Document No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Component Calc. Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Cess Amount Per Unit Factor"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Cess UOM"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Cess Factor Quantity"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Purchase Invoice Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Allocations Line No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Adjustment Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Rate Change Applicable"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Remaining Amount Closed"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Gen. Bus. Posting Group"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Gen. Prod. Posting Group"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Reason Code"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Last Credit Adjusted Date"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption(UOM), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Bank Charge Entry"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Foreign Exchange"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Bill of Entry No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Bill of Entry Date"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Jnl. Bank Charge"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("GST Reason Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("RCM Exempt"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("RCM Exempt Transaction"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Order Address Code"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Bill to-Location(POS)"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Recurring Journal"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("GST Journal Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Ship-to Code"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("FA Journal Entry"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Without Bill Of Entry"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Finance Charge Memo"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Depreciation Book Code"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Location ARN No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("GST Base Amount FCY"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("GST Amount FCY"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("POS as Vendor State"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("POS Out Of India"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Ship-to Customer"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Ship-to GST Customer Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DetailedGSTLedgerEntryInfo.FieldCaption("Ship-to Reg. No"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure CreateExcelBook()
    begin
        TempExcelBuffer.CreateNewBook('GST Entries');
        TempExcelBuffer.WriteSheet('GST Entries', CompanyName(), UserId());
        TempExcelBuffer.CloseBook();
        TempExcelBuffer.OpenExcel();
    end;
}
