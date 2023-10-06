// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Distribution;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;

codeunit 18200 "GST Distribution"
{
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SourceCodeSetup: Record "Source Code Setup";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        ZeroDistPercentErr: Label '%1 cannot be zero for Location Code: %2 in Distribution Line.', Comment = '%1 = Distribution % , %2 =From Location Code';
        selectDitributionErr: Label 'No entries are selected for distribution.';
        ToGSTCompErr: Label 'GST Component Distribution setup must be provided for GST Component Code %1 and GST Jurisdiction Type %2.', Comment = '%1 = GSTComponentCode , %2 = JurisdictionType';
        DistributeErr: Label 'Sum of %1 must be 100 for Distribution Lines.', Comment = '%1 = Distribution %';
        RcptCreditTypeErr: Label '%1 must be Non-Availment as %2 is blank in Line No: %3.', Comment = '%1 = Rcpt. Credit Type , %2 = To GSTIN No. , %3 = Line No.';
        SameToLocationErr: Label 'You cannot have same To Location Code: %1 and Rcpt. Credit Type: %2 combination in multiple lines.', Comment = '%1 = To Location Code, %2  =Rcpt. Credit Type';
        PostDistributionQst: Label 'Do you want to post Distribution?';
        PostDistributionReversalQst: Label 'Do you want to post Distribution Reversal?';
        DistRevPostDateErr: Label 'You cannot post Reversal before Reversal Invoice No. %1 Posting Date: %2. Current Posting Date is: %3.', Comment = '%1 = Reversal Invoice No , %2 = Posting Date , %3 = Posting Date';

    procedure PostGSTDistribution(DistributionNo: Code[20]; ReversalInvNo: Code[20]; DistReversal: Boolean): Boolean
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTDistributionHeader: Record "GST Distribution Header";
        GSTDistributionLine: Record "GST Distribution Line";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DistComponentAmount: Record "Dist. Component Amount";
        DetailedGSTDistEntry: Record "Detailed GST Dist. Entry";
        PostedGSTDistributionHeader: Record "Posted GST Distribution Header";
        PostedDistNo: Code[20];
    begin
        Clear(GenJnlPostLine);
        if DistReversal then begin
            if not Confirm(PostDistributionReversalQst) then
                exit;
        end else
            if not Confirm(PostDistributionQst, false) then
                exit;

        GSTDistributionHeader.Get(DistributionNo);
        if DistReversal then begin
            PostedGSTDistributionHeader.Get(GSTDistributionHeader."Reversal Invoice No.");
            if GSTDistributionHeader."Posting Date" < PostedGSTDistributionHeader."Posting Date" then
                Error(DistRevPostDateErr, GSTDistributionHeader."Reversal Invoice No.", PostedGSTDistributionHeader."Posting Date", GSTDistributionHeader."Posting Date");
        end;

        PostedDistNo := InsertPostedGSTDistHeader(GSTDistributionHeader);
        GSTDistributionLine.Reset();
        GSTDistributionLine.SetCurrentKey("Distribution No.");
        GSTDistributionLine.SetRange("Distribution No.", DistributionNo);
        if GSTDistributionLine.FindSet() then
            repeat
                InsertPostedGSTDistLine(GSTDistributionLine, PostedDistNo);
                DetailedGSTLedgerEntry.Reset();
                if DistReversal then begin
                    DetailedGSTLedgerEntry.SetRange("Dist. Reverse Document No.", GSTDistributionHeader."No.");
                    DetailedGSTLedgerEntry.SetRange(Distributed, true);
                    if DetailedGSTLedgerEntry.FindSet() then
                        repeat
                            ModifyDistReversalDetailedGSTLedgerEntry(DetailedGSTLedgerEntry."Entry No.", PostedDistNo, GSTDistributionLine."Posting Date");
                        until DetailedGSTLedgerEntry.Next() = 0;
                end else begin
                    DetailedGSTLedgerEntry.SetRange("Dist. Document No.", GSTDistributionHeader."No.");
                    if DetailedGSTLedgerEntry.FindSet() then
                        repeat
                            ModifyDistDetailedGSTLedgerEntry(DetailedGSTLedgerEntry."Entry No.", PostedDistNo);
                        until DetailedGSTLedgerEntry.Next() = 0;
                end;
            until GSTDistributionLine.Next() = 0;

        InsertDetGSTDistEntries(DistributionNo, PostedDistNo);
        DistComponentAmount.SetCurrentKey("Distribution No.");
        DistComponentAmount.SetRange("Distribution No.", DistributionNo);
        if DistComponentAmount.FindSet() then
            repeat
                if DistComponentAmount."Debit Amount" <> 0 then
                    PostGenJournalLine(
                        GenJournalLine,
                        GSTDistributionHeader."ISD Document Type",
                        PostedDistNo,
                        GSTDistributionHeader."Posting Date",
                        DistComponentAmount."No.",
                        DistComponentAmount."Debit Amount",
                        GSTDistributionHeader."Shortcut Dimension 1 Code",
                        GSTDistributionHeader."Shortcut Dimension 2 Code",
                        GSTDistributionHeader."Dimension Set ID")
                else
                    PostGenJournalLine(
                        GenJournalLine,
                        GSTDistributionHeader."ISD Document Type",
                        PostedDistNo,
                        GSTDistributionHeader."Posting Date",
                        DistComponentAmount."No.",
                        -DistComponentAmount."Credit Amount",
                        GSTDistributionHeader."Shortcut Dimension 1 Code",
                        GSTDistributionHeader."Shortcut Dimension 2 Code",
                        GSTDistributionHeader."Dimension Set ID");

                GenJnlPostLine.RunWithCheck(GenJournalLine);
            until DistComponentAmount.Next() = 0;

        if DistReversal then begin
            DetailedGSTDistEntry.Reset();
            DetailedGSTDistEntry.SetRange("ISD Document No.", ReversalInvNo);
            DetailedGSTDistEntry.SetRange(Reversal, false);
            if DetailedGSTDistEntry.IsEmpty() then begin
                PostedGSTDistributionHeader.Get(ReversalInvNo);
                PostedGSTDistributionHeader."Completely Reversed" := true;
                PostedGSTDistributionHeader.Modify(true);
            end;
        end;

        GSTDistributionHeader.Delete();
        DeleteGSTDistributionLine(DistributionNo);
        DeleteDistComponentAmount(DistributionNo);
        exit(true);
    end;

    procedure DeleteGSTDistributionLine(DistributionNo: Code[20])
    var
        GSTDistributionLine: Record "GST Distribution Line";
    begin
        GSTDistributionLine.Reset();
        GSTDistributionLine.SetCurrentKey("Distribution No.");
        GSTDistributionLine.SetRange("Distribution No.", DistributionNo);
        GSTDistributionLine.DeleteAll();
    end;

    procedure InsertDistComponentAmount(DistributionNo: Code[20]; DistReversal: Boolean)
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DistComponentAmount: Record "Dist. Component Amount";
        GSTDistributionHeader: Record "GST Distribution Header";
        GSTDistributionLine: Record "GST Distribution Line";
        GSTPostingSetup: Record "GST Posting Setup";
        Location: Record Location;
    begin
        CheckDistributionValidations(DistributionNo);
        DeleteDistComponentAmount(DistributionNo);

        GeneralLedgerSetup.Get();
        GSTDistributionHeader.Get(DistributionNo);

        GSTDistributionLine.SetRange("Distribution No.", DistributionNo);
        if GSTDistributionLine.FindSet() then
            repeat
                DetailedGSTLedgerEntry.Reset();
                DetailedGSTLedgerEntry.SetCurrentKey("Dist. Document No.", "Dist. Input GST Credit");
                if DistReversal then begin
                    DetailedGSTLedgerEntry.SetRange("Dist. Reverse Document No.", DistributionNo);
                    DetailedGSTLedgerEntry.SetRange(Distributed, true);
                end else
                    DetailedGSTLedgerEntry.SetRange("Dist. Document No.", DistributionNo);

                if DetailedGSTLedgerEntry.FindSet() then
                    repeat
                        FilterDistComponentAmount(DistComponentAmount, GSTDistributionLine, DetailedGSTLedgerEntry, DistributionNo);
                        if not DistComponentAmount.FindFirst() then begin
                            DistComponentAmount.Init();
                            DistComponentAmount."Distribution No." := DistributionNo;
                            if GSTDistributionLine."Rcpt. Credit Type" = GSTDistributionLine."Rcpt. Credit Type"::Availment then begin
                                Location.Get(GSTDistributionLine."To Location Code");
                                Location.TestField("State Code");
                                GSTPostingSetup.Get(
                                  Location."State Code",
                                  GetToGSTComponentID(
                                      DetailedGSTLedgerEntry."GST Component Code",
                                      GSTDistributionLine."Distribution Jurisdiction"));
                                GSTPostingSetup.TestField("Receivable Account");
                                DistComponentAmount."GST Component Code" := DetailedGSTLedgerEntry."GST Component Code";
                                DistComponentAmount."To Location Code" := GSTDistributionLine."To Location Code";
                                DistComponentAmount.Type := DistComponentAmount.Type::"G/L Account";
                                DistComponentAmount."No." := GSTPostingSetup."Receivable Account";
                            end else begin
                                DistComponentAmount."GST Component Code" := '';
                                DistComponentAmount.Type := DetailedGSTLedgerEntry.Type;
                                DistComponentAmount."No." := DetailedGSTLedgerEntry."No.";
                            end;

                            DistComponentAmount."GST Credit" := GSTDistributionLine."Rcpt. Credit Type";
                            DistComponentAmount."GST Base Amount" := DetailedGSTLedgerEntry."GST Base Amount";
                            DistComponentAmount."GST Amount" := DetailedGSTLedgerEntry."GST Amount";
                            DistComponentAmount."GST Registration No." := GSTDistributionHeader."From GSTIN No.";
                            DistComponentAmount."Distribution %" := GSTDistributionLine."Distribution %";
                            if DistReversal then
                                DistComponentAmount."Credit Amount" :=
                                  Round(
                                      GSTDistributionLine."Distribution %" * DistComponentAmount."GST Amount" / 100,
                                      GeneralLedgerSetup."Amount Rounding Precision")
                            else
                                DistComponentAmount."Debit Amount" :=
                                  Round(
                                      GSTDistributionLine."Distribution %" * DistComponentAmount."GST Amount" / 100,
                                      GeneralLedgerSetup."Amount Rounding Precision");

                            DistComponentAmount.Insert();
                        end else begin
                            DistComponentAmount."GST Base Amount" += DetailedGSTLedgerEntry."GST Base Amount";
                            DistComponentAmount."GST Amount" += DetailedGSTLedgerEntry."GST Amount";
                            DistComponentAmount."Distribution %" := GSTDistributionLine."Distribution %";
                            if DistReversal then
                                DistComponentAmount."Credit Amount" +=
                                  Round(GSTDistributionLine."Distribution %" * DetailedGSTLedgerEntry."GST Amount" / 100,
                                    GeneralLedgerSetup."Amount Rounding Precision")
                            else
                                DistComponentAmount."Debit Amount" +=
                                  Round(GSTDistributionLine."Distribution %" * DetailedGSTLedgerEntry."GST Amount" / 100,
                                    GeneralLedgerSetup."Amount Rounding Precision");

                            DistComponentAmount.Modify();
                        end;
                    until DetailedGSTLedgerEntry.Next() = 0
                else
                    Error(SelectDitributionErr);

            until GSTDistributionLine.Next() = 0;

        InsertDistComponentAmountBalancingAcc(DistributionNo, DistReversal);
    end;

    local procedure InsertDistComponentAmountBalancingAcc(DistributionNo: Code[20]; DistReversal: Boolean)
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DistComponentAmount: Record "Dist. Component Amount";
        GSTDistributionHeader: Record "GST Distribution Header";
        GSTPostingSetup: Record "GST Posting Setup";
        Location: Record "Location";
    begin
        GSTDistributionHeader.Get(DistributionNo);

        Location.Get(GSTDistributionHeader."From Location Code");
        Location.TestField("State Code");

        DetailedGSTLedgerEntry.Reset();
        DetailedGSTLedgerEntry.SetCurrentKey("Dist. Document No.", "Dist. Input GST Credit");
        if DistReversal then begin
            DetailedGSTLedgerEntry.SetRange("Dist. Reverse Document No.", DistributionNo);
            DetailedGSTLedgerEntry.SetRange(Distributed, true);
        end else
            DetailedGSTLedgerEntry.SetRange("Dist. Document No.", DistributionNo);

        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                GSTPostingSetup.Get(Location."State Code", GetComponentID(DetailedGSTLedgerEntry."GST Component Code"));
                GSTPostingSetup.TestField("Receivable Acc. (Dist)");
                GSTPostingSetup.TestField("Expense Account");

                DistComponentAmount.Reset();
                DistComponentAmount.SetRange("Distribution No.", DistributionNo);
                DistComponentAmount.SetRange("GST Credit", GSTDistributionHeader."Dist. Credit Type");
                DistComponentAmount.SetRange("GST Component Code", DetailedGSTLedgerEntry."GST Component Code");
                DistComponentAmount.SetRange("To Location Code", GSTDistributionHeader."From Location Code");
                if not DistComponentAmount.FindFirst() then begin
                    DistComponentAmount.Init();
                    DistComponentAmount."Distribution No." := DistributionNo;
                    DistComponentAmount."GST Component Code" := DetailedGSTLedgerEntry."GST Component Code";
                    DistComponentAmount."To Location Code" := GSTDistributionHeader."From Location Code";
                    DistComponentAmount."GST Credit" := GSTDistributionHeader."Dist. Credit Type";
                    DistComponentAmount.Type := DistComponentAmount.Type::"G/L Account";
                    if GSTDistributionHeader."Dist. Credit Type" = GSTDistributionHeader."Dist. Credit Type"::Availment then
                        DistComponentAmount."No." := GSTPostingSetup."Receivable Acc. (Dist)"
                    else
                        DistComponentAmount."No." := GSTPostingSetup."Expense Account";

                    DistComponentAmount."GST Base Amount" := DetailedGSTLedgerEntry."GST Base Amount";
                    DistComponentAmount."GST Amount" := DetailedGSTLedgerEntry."GST Amount";
                    DistComponentAmount."GST Registration No." := GSTDistributionHeader."From GSTIN No.";
                    DistComponentAmount."Distribution %" := 0;
                    if DistReversal then
                        DistComponentAmount."Debit Amount" := DistComponentAmount."GST Amount"
                    else
                        DistComponentAmount."Credit Amount" := DistComponentAmount."GST Amount";

                    DistComponentAmount.Insert();
                end else begin
                    DistComponentAmount."GST Base Amount" += DetailedGSTLedgerEntry."GST Base Amount";
                    DistComponentAmount."GST Amount" += DetailedGSTLedgerEntry."GST Amount";
                    if DistReversal then
                        DistComponentAmount."Debit Amount" := DistComponentAmount."GST Amount"
                    else
                        DistComponentAmount."Credit Amount" := DistComponentAmount."GST Amount";

                    DistComponentAmount.Modify();
                end;
            until DetailedGSTLedgerEntry.Next() = 0;
    end;

    local procedure InsertPostedGSTDistHeader(GSTDistributionHeader: Record "GST Distribution Header"): Code[20]
    var
        PostedGSTDistributionHeader: Record "Posted GST Distribution Header";
        Location: Record "Location";
        GSTDistributionSubcsribers: Codeunit "GST Distribution Subcsribers";
        Record: Variant;
    begin
        Location.Get(GSTDistributionHeader."From Location Code");
        Record := GSTDistributionHeader;

        PostedGSTDistributionHeader.Init();
        PostedGSTDistributionHeader.TransferFields(GSTDistributionHeader);
        PostedGSTDistributionHeader."Pre Distribution No." := GSTDistributionHeader."No.";
        if GSTDistributionHeader."ISD Document Type" = GSTDistributionHeader."ISD Document Type"::Invoice then begin
            GSTDistributionSubcsribers.GetDistributionNoSeriesCode(Record);
            GSTDistributionHeader := Record;
            PostedGSTDistributionHeader."No." := NoSeriesManagement.GetNextNo(GSTDistributionHeader."Posting No. Series", WorkDate(), true);
        end else begin
            GSTDistributionSubcsribers.GetDistributionNoSeriesCode(Record);
            GSTDistributionHeader := Record;
            PostedGSTDistributionHeader."No." := NoSeriesManagement.GetNextNo(GSTDistributionHeader."Posting No. Series", WorkDate(), true);
        end;

        PostedGSTDistributionHeader.Insert(true);
        exit(PostedGSTDistributionHeader."No.");
    end;

    local procedure CheckDistributionValidations(DistributionNo: Code[20])
    var
        GSTDistributionLine: Record "GST Distribution Line";
        GSTDistributionLine2: Record "GST Distribution Line";
    begin
        GSTDistributionLine.Reset();
        GSTDistributionLine.SetCurrentKey("Distribution No.");
        GSTDistributionLine.SetRange("Distribution No.", DistributionNo);
        GSTDistributionLine.CalcSums("Distribution %");
        if GSTDistributionLine."Distribution %" <> 100 then
            Error(DistributeErr, GSTDistributionLine.FieldCaption("Distribution %"));

        if GSTDistributionLine.FindSet() then
            repeat
                if GSTDistributionLine."Distribution %" = 0 then
                    Error(ZeroDistPercentErr, GSTDistributionLine.FieldCaption("Distribution %"), GSTDistributionLine."From Location Code");

                if (GSTDistributionLine."To GSTIN No." = '') and (GSTDistributionLine."Rcpt. Credit Type" = GSTDistributionLine."Rcpt. Credit Type"::Availment)
                then
                    Error(
                        RcptCreditTypeErr,
                        GSTDistributionLine.FieldCaption("Rcpt. Credit Type"),
                        GSTDistributionLine.FieldCaption("To GSTIN No."),
                        GSTDistributionLine."Line No.");

                GSTDistributionLine2.Reset();
                GSTDistributionLine2.SetRange("Distribution No.", DistributionNo);
                GSTDistributionLine2.SetRange("To Location Code", GSTDistributionLine."To Location Code");
                GSTDistributionLine2.SetRange("Rcpt. Credit Type", GSTDistributionLine."Rcpt. Credit Type");
                if GSTDistributionLine2.Count() > 1 then
                    Error(SameToLocationErr, GSTDistributionLine."To Location Code", GSTDistributionLine."Rcpt. Credit Type");

            until GSTDistributionLine.Next() = 0;
    end;

    local procedure InsertDetGSTDistEntries(DistributionNo: Code[20]; PostedDistributionNo: Code[20])
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTDistributionHeader: Record "GST Distribution Header";
        GSTDistributionLine: Record "GST Distribution Line";
        DetailedGSTDistEntry: Record "Detailed GST Dist. Entry";
        Location: Record "Location";
        Vendor: Record "Vendor";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PostedGSTDistributionHeader: Record "Posted GST Distribution Header";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        Sign: Integer;
        Type: Enum "Distribution Type";
    begin
        Sign := 1;
        GeneralLedgerSetup.Get();
        GSTDistributionHeader.Get(DistributionNo);
        if GSTDistributionHeader.Reversal then begin
            Sign := -1;
            DetailedGSTLedgerEntry.SetRange("Dist. Reverse Document No.", PostedDistributionNo);
        end else
            DetailedGSTLedgerEntry.SetRange("Dist. Document No.", PostedDistributionNo);

        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                Vendor.Get(DetailedGSTLedgerEntry."Source No.");
                VendorLedgerEntry.SetRange("Buy-from Vendor No.", Vendor."No.");
                VendorLedgerEntry.SetRange("Document No.", DetailedGSTLedgerEntry."Document No.");
                VendorLedgerEntry.FindFirst();

                if DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.") then;

                GSTDistributionLine.Reset();
                GSTDistributionLine.SetCurrentKey("Distribution No.");
                GSTDistributionLine.SetRange("Distribution No.", DistributionNo);
                if GSTDistributionLine.FindSet() then
                    repeat
                        Location.Get(GSTDistributionLine."To Location Code");

                        DetailedGSTDistEntry.Init();
                        DetailedGSTDistEntry."Entry No." := 0;
                        DetailedGSTDistEntry."Detailed GST Ledger Entry No." := DetailedGSTLedgerEntry."Entry No.";
                        DetailedGSTDistEntry."Dist. Location Code" := GSTDistributionLine."From Location Code";
                        DetailedGSTDistEntry."Dist. Location State Code" := DetailedGSTLedgerEntryInfo."Location State Code";
                        DetailedGSTDistEntry."Dist. GST Regn. No." := DetailedGSTLedgerEntry."Location  Reg. No.";
                        DetailedGSTDistEntry."Dist. GST Credit" := DetailedGSTLedgerEntry."GST credit";
                        DetailedGSTDistEntry."ISD Document Type" := GSTDistributionHeader."ISD Document Type";
                        DetailedGSTDistEntry."ISD Document No." := PostedDistributionNo;
                        DetailedGSTDistEntry."ISD Posting Date" := GSTDistributionHeader."Posting Date";
                        DetailedGSTDistEntry."Vendor No." := DetailedGSTLedgerEntry."Source No.";
                        DetailedGSTDistEntry."Supplier GST Reg. No." := DetailedGSTLedgerEntry."Buyer/Seller Reg. No.";
                        DetailedGSTDistEntry."Vendor Name" := Vendor.Name;
                        DetailedGSTDistEntry."Vendor Address" := Vendor.Address;
                        DetailedGSTDistEntry."Vendor State Code" := DetailedGSTLedgerEntryInfo."Buyer/Seller State Code";
                        DetailedGSTDistEntry."Document Type" := DetailedGSTLedgerEntry."Document Type";
                        DetailedGSTDistEntry."Document No." := DetailedGSTLedgerEntry."Document No.";
                        DetailedGSTDistEntry."Posting Date" := DetailedGSTLedgerEntry."Posting Date";
                        DetailedGSTDistEntry."Vendor Invoice No." := DetailedGSTLedgerEntry."External Document No.";
                        DetailedGSTDistEntry."Vendor Document Date" := VendorLedgerEntry."Document Date";
                        DetailedGSTDistEntry."GST Base Amount" := Sign * DetailedGSTLedgerEntry."GST Base Amount";
                        DetailedGSTDistEntry."GST Group Code" := DetailedGSTLedgerEntry."GST Group Code";
                        DetailedGSTDistEntry."GST %" := DetailedGSTLedgerEntry."GST %";
                        DetailedGSTDistEntry."GST Amount" := Sign * DetailedGSTLedgerEntry."GST Amount";
                        DetailedGSTDistEntry."Rcpt. Location Code" := GSTDistributionLine."To Location Code";
                        DetailedGSTDistEntry."Rcpt. GST Reg. No." := GSTDistributionLine."To GSTIN No.";
                        DetailedGSTDistEntry."Rcpt. Location State Code" := Location."State Code";
                        DetailedGSTDistEntry."Rcpt. GST Credit" := GSTDistributionLine."Rcpt. Credit Type";
                        if DetailedGSTLedgerEntry."GST Jurisdiction Type" = DetailedGSTLedgerEntry."GST Jurisdiction Type"::Interstate then
                            DetailedGSTDistEntry."Distribution Jurisdiction" := DetailedGSTLedgerEntry."GST Jurisdiction Type"::Interstate
                        else
                            DetailedGSTDistEntry."Distribution Jurisdiction" := GSTDistributionLine."Distribution Jurisdiction";

                        DetailedGSTDistEntry."Location Distribution %" := GSTDistributionLine."Distribution %";
                        DetailedGSTDistEntry."Distributed Component Code" := DetailedGSTLedgerEntry."GST Component Code";
                        DetailedGSTDistEntry."Rcpt. Component Code" := GetToGSTComponent(
                            DetailedGSTDistEntry."Distributed Component Code",
                            DetailedGSTDistEntry."Distribution Jurisdiction");
                        DetailedGSTDistEntry."Distribution Amount" := Round(
                            DetailedGSTDistEntry."GST Amount" * GSTDistributionLine."Distribution %" / 100,
                            GeneralLedgerSetup."Amount Rounding Precision");
                        DetailedGSTDistEntry."Pre Dist. Invoice No." := DistributionNo;
                        DetailedGSTDistEntry."Document Line No." := DetailedGSTLedgerEntry."Document Line No.";
                        if GSTDistributionHeader.Reversal then begin
                            PostedGSTDistributionHeader.Get(GSTDistributionHeader."Reversal Invoice No.");
                            DetailedGSTDistEntry."Original Dist. Invoice No." := GSTDistributionHeader."Reversal Invoice No.";
                            DetailedGSTDistEntry."Original Dist. Invoice Date" := PostedGSTDistributionHeader."Posting Date";
                        end;

                        if DetailedGSTDistEntry."Rcpt. GST Credit" = DetailedGSTDistEntry."Rcpt. GST Credit"::Availment then begin
                            DetailedGSTDistEntry."G/L Account No." := GetGSTAccountNoDistribution(
                                DetailedGSTDistEntry."Rcpt. Location State Code",
                                DetailedGSTDistEntry."Rcpt. Component Code",
                                DetailedGSTLedgerEntry."Transaction Type",
                                Type::"G/L Account",
                                DetailedGSTDistEntry."Rcpt. GST Credit",
                                true,
                                true);
                            DetailedGSTDistEntry."Credit Availed" := true;
                        end else
                            DetailedGSTDistEntry."G/L Account No." := DetailedGSTLedgerEntry."No.";

                        DetailedGSTDistEntry."GST Rounding Precision" := DetailedGSTLedgerEntry."GST Rounding Precision";
                        DetailedGSTDistEntry."GST Rounding Type" := DetailedGSTLedgerEntry."GST Rounding Type";
                        DetailedGSTDistEntry.Cess := DetailedGSTLedgerEntryInfo.Cess;
                        if PurchInvHeader.Get(DetailedGSTLedgerEntry."Document No.") then
                            DetailedGSTDistEntry."Invoice Type" := PurchInvHeader."Invoice Type"
                        else
                            if PurchCrMemoHdr.Get(DetailedGSTLedgerEntry."Document No.") then
                                DetailedGSTDistEntry."Invoice Type" := PurchInvHeader."Invoice Type";

                        DetailedGSTDistEntry."Service Account No." := DetailedGSTLedgerEntry."No.";
                        DetailedGSTDistEntry.Insert(true);
                    until GSTDistributionLine.Next() = 0;
            until DetailedGSTLedgerEntry.Next() = 0;
    end;

    local procedure GetGSTAccountNoDistribution(
        GSTStateCode: Code[10];
        GSTComponentCode: Code[30];
        TransactionType: Enum "Detail Ledger Transaction Type";
        Type: Enum "Distribution Type";
        GSTCredit: Enum "GST Credit";
        ISD: Boolean;
        ReceivableApplicable: Boolean): Code[20]
    var
        GSTPostingSetup: Record "GST Posting Setup";
        GLAcc: Code[20];
    begin
        GSTPostingSetup.Get(GSTStateCode, GetComponentID(GSTComponentCode));
        if TransactionType = TransactionType::Sales then begin
            GSTPostingSetup.TestField("Payable Account");
            GLAcc := GSTPostingSetup."Payable Account";
        end else
            if TransactionType = TransactionType::Purchase then
                if (Type = Type::"G/L Account") and (GSTCredit = GSTCredit::"Non-Availment") then begin
                    GSTPostingSetup.TestField("Expense Account");
                    GLAcc := GSTPostingSetup."Expense Account";
                end else
                    if ReceivableApplicable then
                        if ISD then begin
                            GSTPostingSetup.TestField("Receivable Acc. (Dist)");
                            GLAcc := GSTPostingSetup."Receivable Acc. (Dist)";
                        end else begin
                            GSTPostingSetup.TestField("Receivable Account");
                            GLAcc := GSTPostingSetup."Receivable Account";
                        end
                    else
                        if not ISD then begin
                            GSTPostingSetup.TestField("Receivable Account (Interim)");
                            GLAcc := GSTPostingSetup."Receivable Account (Interim)";
                        end else
                            if GSTCredit = GSTCredit::"Non-Availment" then begin
                                GSTPostingSetup.TestField("Expense Account");
                                GLAcc := GSTPostingSetup."Expense Account";
                            end else begin
                                GSTPostingSetup.TestField("Receivable Acc. Interim (Dist)");
                                GLAcc := GSTPostingSetup."Receivable Acc. Interim (Dist)";
                            end;
        exit(GLAcc);
    end;

    local procedure DeleteDistComponentAmount(DistributionNo: Code[20])
    var
        DistComponentAmount: Record "Dist. Component Amount";
    begin
        DistComponentAmount.Reset();
        DistComponentAmount.SetCurrentKey("Distribution No.");
        DistComponentAmount.SetRange("Distribution No.", DistributionNo);
        DistComponentAmount.DeleteAll();
    end;

    local procedure GetToGSTComponent(GSTComponentCode: Code[30]; JurisdictionType: Enum "GST Jurisdiction Type"): Code[30]
    var
        GSTComponentDistribution: Record "GST Component Distribution";
    begin
        GSTComponentDistribution.SetRange("GST Component Code", GSTComponentCode);
        if JurisdictionType = JurisdictionType::Interstate then
            GSTComponentDistribution.SetRange("Interstate Distribution", true)
        else
            GSTComponentDistribution.SetRange("Intrastate Distribution", true);

        if not GSTComponentDistribution.FindFirst() then
            Error(ToGSTCompErr, GSTComponentCode, JurisdictionType);

        exit(GSTComponentDistribution."Distribution Component Code");
    end;

    local procedure GetToGSTComponentID(GSTComponentCode: Code[30]; JurisdictionType: Enum "GST Jurisdiction Type"): Integer
    var
        GSTComponentDistribution: Record "GST Component Distribution";
    begin
        GSTComponentDistribution.SetRange("GST Component Code", GSTComponentCode);
        if JurisdictionType = JurisdictionType::Interstate then
            GSTComponentDistribution.SetRange("Interstate Distribution", true)
        else
            GSTComponentDistribution.SetRange("Intrastate Distribution", true);

        if GSTComponentDistribution.Findfirst() then
            exit(GetComponentID(GSTComponentDistribution."Distribution Component Code"))
        else
            Error(ToGSTCompErr, GSTComponentCode, JurisdictionType);
    end;

    local procedure GetComponentID(GSTComponentCode: Code[30]): Integer
    var
        GSTSetup: Record "GST Setup";
        TaxComponent: Record "Tax Component";
    begin
        if not GSTSetup.Get() then
            exit;

        GSTSetup.TestField("GST Tax Type");
        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxComponent.SetRange(Name, GSTComponentCode);
        if TaxComponent.FindFirst() then
            exit(TaxComponent.Id);
    end;

    local procedure InsertPostedGSTDistLine(GSTDistributionLine: Record "GST Distribution Line"; DistributionNo: Code[20])
    var
        PostedGSTDistributionLine: Record "Posted GST Distribution Line";
    begin
        PostedGSTDistributionLine.Init();
        PostedGSTDistributionLine.TransferFields(GSTDistributionLine);
        PostedGSTDistributionLine."Distribution No." := DistributionNo;
        PostedGSTDistributionLine.Insert(true);
    end;

    local procedure PostGenJournalLine(
        var GenJournalLine: Record "Gen. Journal Line";
        DocumentType: Enum "Adjustment Document Type";
        DocumentNo: Code[20];
        PostingDate: Date;
        AccountNo: Code[20];
        Amt: Decimal;
        ShortcutDim1: Code[20];
        ShortcutDim2: Code[20];
        DimSetID: Integer)
    begin
        SourceCodeSetup.Get();
        SourceCodeSetup.TestField("GST Distribution");

        GenJournalLine.Init();
        GenJournalLine."Line No." += 10000;
        GenJournalLine."Source Code" := SourceCodeSetup."GST Distribution";
        if DocumentType = DocumentType::Invoice then
            GenJournalLine."Document Type" := "Document Type Enum"::Invoice
        else
            GenJournalLine."Document Type" := "Document Type Enum"::"Credit Memo";

        GenJournalLine."Document No." := DocumentNo;
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
        GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
        GenJournalLine."Posting Date" := PostingDate;
        GenJournalLine.Validate("Account No.", AccountNo);
        GenJournalLine.Validate(Amount, Amt);
        GenJournalLine."System-Created Entry" := true;
        GenJournalLine."Shortcut Dimension 1 Code" := ShortcutDim1;
        GenJournalLine."Shortcut Dimension 2 Code" := ShortcutDim2;
        GenJournalLine."Dimension Set ID" := DimSetID;
    end;

    local procedure ModifyDistReversalDetailedGSTLedgerEntry(EntryNo: Integer; PostedDistNo: Code[20]; PostingDate: Date)
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTDistEntry: Record "Detailed GST Dist. Entry";
        DetailedGSTDistEntry2: Record "Detailed GST Dist. Entry";
    begin
        DetailedGSTLedgerEntry.Get(EntryNo);
        DetailedGSTLedgerEntry.Distributed := false;
        DetailedGSTLedgerEntry."Dist. Reverse Document No." := PostedDistNo;
        DetailedGSTLedgerEntry."Distributed Reversed" := true;
        DetailedGSTLedgerEntry.Modify(true);

        DetailedGSTDistEntry.SetRange("Detailed GST Ledger Entry No.", DetailedGSTLedgerEntry."Entry No.");
        DetailedGSTDistEntry.SetRange(Reversal, false);
        DetailedGSTDistEntry.SetRange("Original Dist. Invoice No.", '');
        if DetailedGSTDistEntry.FindSet() then
            repeat
                DetailedGSTDistEntry2.Get(DetailedGSTDistEntry."Entry No.");
                DetailedGSTDistEntry2.Reversal := true;
                DetailedGSTDistEntry2."Reversal Date" := PostingDate;
                DetailedGSTDistEntry2.Modify(true);
            until DetailedGSTDistEntry.Next() = 0;
    end;

    local procedure ModifyDistDetailedGSTLedgerEntry(EntryNo: Integer; PostedDistNo: Code[20])
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        DetailedGSTLedgerEntry.Get(EntryNo);
        DetailedGSTLedgerEntry.Distributed := true;
        DetailedGSTLedgerEntry."Distributed Reversed" := false;
        DetailedGSTLedgerEntry."Dist. Document No." := PostedDistNo;
        DetailedGSTLedgerEntry.Modify();
    end;

    local procedure FilterDistComponentAmount(
        var DistComponentAmount: Record "Dist. Component Amount";
        GSTDistributionLine: Record "GST Distribution Line";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DistributionNo: Code[20])
    begin
        DistComponentAmount.Reset();
        DistComponentAmount.SetRange("Distribution No.", DistributionNo);
        DistComponentAmount.SetRange("GST Credit", GSTDistributionLine."Rcpt. Credit Type");
        if GSTDistributionLine."Rcpt. Credit Type" = GSTDistributionLine."Rcpt. Credit Type"::Availment then begin
            DistComponentAmount.SetRange("GST Component Code", DetailedGSTLedgerEntry."GST Component Code");
            DistComponentAmount.SetRange("To Location Code", GSTDistributionLine."To Location Code");
            DistComponentAmount.SetRange(Type);
            DistComponentAmount.SetRange("No.");
        end else begin
            DistComponentAmount.SetRange("GST Component Code");
            DistComponentAmount.SetRange("To Location Code");
            DistComponentAmount.SetRange(Type, DetailedGSTLedgerEntry.Type);
            DistComponentAmount.SetRange("No.", DetailedGSTLedgerEntry."No.");
        end;
    end;
}
