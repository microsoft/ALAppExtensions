// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.Distribution;
using Microsoft.Finance.GST.Payments;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Posting;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Setup;

codeunit 18318 "GST Settlement"
{
    var
        TempGSTPostingBuffer: array[2] of Record "GST Posting Buffer" temporary;
        TempGSTPostingBuffer1: array[2] of Record "GST Posting Buffer" temporary;
        DimensionManagement: Codeunit DimensionManagement;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        ChequeNo: Code[10];
        ChequeDate: Date;
        PostedDocumentNo: Code[20];
        PostingDate: Date;
        Window: Dialog;
        NoPostErr: Label 'There is Nothing to post.';
        GSTPaymentFieldSameErr: Label '%1 must be same in all the GST Payment Lines.', Comment = '%1 = Field Refrence';
        CrAdjstPostedMsg: Label 'Credit Adjustment Journal posted successfully.';
        AdjustmentDateErr: Label 'Document No. %1 already has been adjusted on %2. Please change the date and try again.', Comment = '%1 = Document No, %2 = Posting Date';
        GSTCrAdjFilterErr: Label 'Filter Criteria is not matching with Detailed GST Ledger Entry.';
        PostCrAdjQst: Label 'Do you want to post Credit Adjustment Journal?';
        GSTINErr: Label 'GSTIN No. can not be blank.';
        PostingDateErr: Label 'Posting Date can not be blank.';
        PaymentDocErr: Label 'DocumentNo %1 has already been posted, you can not enter duplicate Document No.', Comment = '%1 = Payment Document No.';
        PostGSTPaymentQst: Label 'Do you want to post GST Payment?';
        PaymentBufferMsg: Label 'Generating Payment Lines : GST Component#1##############\', Comment = '%1 = GST Component Code.';
        CreditSetoffErr: Label 'Credit Utilized can not exceed Total Credit Available.There is no Claim-Setoff available for GST Compoment %1.', Comment = '%1 =GST Component Code.';
        CreditUtilizedErr: Label 'Credit Utilized %1 can not exceed Payment Liability %2 for GST Compoment %3.', Comment = '%1 = Credit Utilized, %2 = Payment Liability, %3 =GST Component Code.';
        CreditAvailableErr: Label 'There is no sufficient Claim-Setoff available for GST Compoment %1, required Credit Utilized is %2, Total Credit Available is %3.', Comment = '%1 =GST Component Code., %2 = Credit Amount, %3  = Availabe Credit Amount';
        DimCombinationErr: Label 'The combination of dimensions used for GST Component %1 is blocked. %2.', Comment = '%1 = GST Component, %2 = Dimension Value';
        LiabilityExceedErr: Label 'Total of Credit Utilize, GST TDS Credit Utilized, GST TCS Credit Utilized and Payment Amount %1 must be equal to Net Payment Liability %2 in GST Component %3.', Comment = '%1 = Credit Utilized and Payment Amount,  %2 = Net Payment Liability, %3 = GST Component';
        InvaidDimensionErr: Label 'The dimensions used are invalid. %2.', Comment = '%1 = Dimension Value';
        UpdatingLedgersMsg: Label 'Updating GST Ledger : GST Component#1##############\', Comment = '%1 =GST Component Code.';
        GSTPaymentTypeTxt: Label 'Component %1 & Type: %2.', Comment = '%1 = GST Component, %2 = Tax Type';
        GstTxt: Label 'Gst';
        NetPaymentLibTxt: Label 'Net Payment Liability';
        UnadjustedCreditTxt: Label 'Unadjusted Credit';
        ReverseChargePaymentTxt: Label 'Rev. Charge Payment';
        CreditUtilizedTxt: Label 'Credit';
        TotalPaymentTxt: Label 'Total Payment Amount';
        RemCreditAmtupdatedMsg: Label 'Remaining GST Credit Amount updated.';
        NothingtoUpdateMsg: Label 'Nothing to update.';

    local procedure GetDetailedGSTLedgerEnfo(DetailedGSTLedgerEntryNo: Integer; Var DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info")
    begin
        if DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntryNo) then;
    end;

    procedure FillAdjustmentJournal(
        GSTINNo: Code[20];
        VendorNo: Code[20];
        PeriodMonth: Integer;
        PeriodYear: Integer;
        PostingDate: Date;
        DocumentNo2: Code[20];
        ExternalDocNo: Code[40];
        NatureOfAdj: Enum "Credit Adjustment Type";
        AdjDocNo: Code[20];
        ReverseCharge: Boolean;
        AdjustmentPerc: Decimal)
    var
        DetailedGSTLedgerEntry: array[2] of Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        TotalGSTAmount: Decimal;
        DocumentNo: Code[20];
        DocumentLineNo: Integer;
        CAJAmt: Decimal;
        PermanentReversalAmt: Decimal;
        Cnt: Integer;
    begin
        Cnt := 0;
        GetCreditAdjustmentSourceCode();
        DetailedGSTLedgerEntry[1].SetCurrentKey(
            "Location  Reg. No.",
            "Transaction Type",
            "Entry Type",
            "GST Vendor Type",
            "GST Credit",
            "Posting Date",
            "Source No.",
            "Document Type",
            "Document No.",
            "Document Line No.");

        DetailedGSTLedgerEntry[1].SetRange("Location  Reg. No.", GSTINNo);
        DetailedGSTLedgerEntry[1].SetRange("Transaction Type", DetailedGSTLedgerEntry[1]."Transaction Type"::Purchase);

        ApplyReverseChargeFilter(DetailedGSTLedgerEntry, NatureOfAdj, ReverseCharge, PeriodMonth, PeriodYear); //Function Break

        if VendorNo <> '' then
            DetailedGSTLedgerEntry[1].SetRange("Source No.", VendorNo);
        if ReverseCharge then
            DetailedGSTLedgerEntry[1].SetRange("Document Type", DetailedGSTLedgerEntry[1]."Document Type"::Invoice)
        else
            DetailedGSTLedgerEntry[1].SetFilter("Document Type", '%1|%2',
              DetailedGSTLedgerEntry[1]."Document Type"::Invoice, DetailedGSTLedgerEntry[1]."Document Type"::"Credit Memo");
        if DocumentNo2 <> '' then
            DetailedGSTLedgerEntry[1].SetRange("Document No.", DocumentNo2);
        if ExternalDocNo <> '' then
            DetailedGSTLedgerEntry[1].SetRange("External Document No.", ExternalDocNo);
        if not (NatureOfAdj in [NatureOfAdj::"Credit Availment", NatureOfAdj::"Reversal of Availment"]) then
            DetailedGSTLedgerEntry[1].SetRange("Credit Availed", true);
        DetailedGSTLedgerEntry[1].SetRange(Distributed, false);
        if ReverseCharge then begin
            DetailedGSTLedgerEntry[1].SetRange("Reverse Charge", true);
            DetailedGSTLedgerEntry[1].SetRange("GST Group Type", DetailedGSTLedgerEntry[1]."GST Group Type"::Service);
            DetailedGSTLedgerEntry[1].SetRange("Item Charge Entry", false);
        end else
            DetailedGSTLedgerEntry[1].SetRange("Reverse Charge", false);
        DetailedGSTLedgerEntry[1].SetRange("GST Exempted Goods", false);
        DetailedGSTLedgerEntry[1].SetRange("Input Service Distribution", false);
        AppyNatureofAdjFilters(DetailedGSTLedgerEntry, NatureOfAdj); //Function Break
        if DetailedGSTLedgerEntry[1].FindSet() then
            repeat
                GetDetailedGSTLedgerEnfo(DetailedGSTLedgerEntry[1]."Entry No.", DetailedGSTLedgerEntryInfo);

                if DetailedGSTLedgerEntryInfo."Last Credit Adjusted Date" > PostingDate then
                    Error(AdjustmentDateErr, DetailedGSTLedgerEntry[1]."Document No.", DetailedGSTLedgerEntryInfo."Last Credit Adjusted Date");

                if GetCAJLines(DetailedGSTLedgerEntry[1], NatureOfAdj) then begin
                    if ReverseCharge and
                        ((DetailedGSTLedgerEntry[1]."Document No." <> DocumentNo) or
                        (DetailedGSTLedgerEntry[1]."Document Line No." <> DocumentLineNo))
                    then
                        if IsComponentNonAvailment(DetailedGSTLedgerEntry[1]."Entry No.") then begin
                            TotalGSTAmount := 0;
                            CAJAmt := 0;
                            DocumentNo := DetailedGSTLedgerEntry[1]."Document No.";
                            DocumentLineNo := DetailedGSTLedgerEntry[1]."Document Line No.";

                            DetailedGSTLedgerEntry[2].CopyFilters(DetailedGSTLedgerEntry[1]);
                            DetailedGSTLedgerEntry[2].SetRange("Source No.", DetailedGSTLedgerEntry[1]."Source No.");
                            DetailedGSTLedgerEntry[2].SetRange("Document Type", DetailedGSTLedgerEntry[1]."Document Type");
                            DetailedGSTLedgerEntry[2].SetRange("Document No.", DetailedGSTLedgerEntry[1]."Document No.");
                            DetailedGSTLedgerEntry[2].SetRange("Document Line No.", DetailedGSTLedgerEntry[1]."Document Line No.");
                            if DetailedGSTLedgerEntry[2].FindSet() then begin
                                Cnt += 1;
                                DetailedGSTLedgerEntry[2].CalcSums("GST Amount");
                                DetailedGSTLedgerEntry[2].CalcSums("CAJ Amount");
                                DetailedGSTLedgerEntry[2].CalcSums("CAJ Amount Permanent Reversal");
                                TotalGSTAmount := Abs(DetailedGSTLedgerEntry[2]."GST Amount");
                                CAJAmt := Abs(DetailedGSTLedgerEntry[2]."CAJ Amount");
                                PermanentReversalAmt := Abs(DetailedGSTLedgerEntry[2]."CAJ Amount Permanent Reversal");
                            end;

                            InitCreditAdjustmentJournal(
                              DetailedGSTLedgerEntry[2], NatureOfAdj, AdjDocNo, PostingDate, ReverseCharge, TotalGSTAmount,
                              AdjustmentPerc, CAJAmt, PermanentReversalAmt);
                        end;

                    if not ReverseCharge and
                        ((DetailedGSTLedgerEntry[1]."Document No." <> DocumentNo) or
                        (DetailedGSTLedgerEntry[1]."Document Line No." <> DocumentLineNo))
                    then begin
                        TotalGSTAmount := 0;
                        CAJAmt := 0;
                        DocumentNo := DetailedGSTLedgerEntry[1]."Document No.";
                        DocumentLineNo := DetailedGSTLedgerEntry[1]."Document Line No.";
                        DetailedGSTLedgerEntry[2].CopyFilters(DetailedGSTLedgerEntry[1]);
                        DetailedGSTLedgerEntry[2].SetRange("Source No.", DetailedGSTLedgerEntry[1]."Source No.");
                        DetailedGSTLedgerEntry[2].SetRange("Document Type", DetailedGSTLedgerEntry[1]."Document Type");
                        DetailedGSTLedgerEntry[2].SetRange("Document No.", DetailedGSTLedgerEntry[1]."Document No.");
                        DetailedGSTLedgerEntry[2].SetRange("Document Line No.", DetailedGSTLedgerEntry[1]."Document Line No.");
                        if DetailedGSTLedgerEntry[2].FindSet() then begin
                            Cnt += 1;
                            DetailedGSTLedgerEntry[2].CalcSums("GST Amount");
                            DetailedGSTLedgerEntry[2].CalcSums("CAJ Amount");
                            DetailedGSTLedgerEntry[2].CalcSums("CAJ Amount Permanent Reversal");
                            TotalGSTAmount := DetailedGSTLedgerEntry[2]."GST Amount";
                            CAJAmt := Abs(DetailedGSTLedgerEntry[2]."CAJ Amount");
                            PermanentReversalAmt := Abs(DetailedGSTLedgerEntry[2]."CAJ Amount Permanent Reversal");
                        end;

                        InitCreditAdjustmentJournal(
                            DetailedGSTLedgerEntry[2],
                            NatureOfAdj,
                            AdjDocNo,
                            PostingDate,
                            ReverseCharge,
                            TotalGSTAmount,
                            AdjustmentPerc,
                            CAJAmt,
                            PermanentReversalAmt);
                    end;
                end;
            until DetailedGSTLedgerEntry[1].Next() = 0
        else
            Error(GSTCrAdjFilterErr);

        if Cnt = 0 then
            Error(GSTCrAdjFilterErr);
    end;

    procedure PostCreditAdjustmentJnl(GSTCreditAdjustmentJournal: Record "GST Credit Adjustment Journal")
    var
        GenJnlLine: Record "Gen. Journal Line";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GenLedgerSetup: Record "General Ledger Setup";
        GenJournalPostLine: Codeunit "Gen. Jnl.-Post Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        GSTHelpers: Codeunit "GST Helpers";
        GSTBaseValidation: Codeunit "GST Base Validation";
        EntryNo: Integer;
        BalAccountNo: Code[20];
    begin
        if not Confirm(PostCrAdjQst, false) then
            exit;

        Clear(EntryNo);
        TempGSTPostingBuffer[1].DeleteAll();
        TempGSTPostingBuffer[2].DeleteAll();
        GenLedgerSetup.Get();
        GSTBaseValidation.CheckGSTAccountingPeriod(GSTCreditAdjustmentJournal."Adjustment Posting Date", false);
        if GSTCreditAdjustmentJournal."Reverse Charge" then
            EntryNo := PostReverseChargeCrAdjJournal(GSTCreditAdjustmentJournal)
        else begin
            Clear(GenJournalPostLine);
            GSTCreditAdjustmentJournal.SetFilter("Nature of Adjustment", '<>%1', GSTCreditAdjustmentJournal."Nature of Adjustment"::" ");
            if GSTCreditAdjustmentJournal.FindSet() then begin
                repeat
                    GSTCreditAdjustmentJournal.Validate("Adjustment %");
                    GSTCreditAdjustmentJournal.Validate("Adjustment Amount");
                    TempGSTPostingBuffer[1].DeleteAll();
                    TempGSTPostingBuffer[2].DeleteAll();
                    DetailedGSTLedgerEntry.SetCurrentKey("Transaction Type", "GST Jurisdiction Type",
                      "Source No.", "Document Type", "Document No.", "Document Line No.", "Posting Date");
                    DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
                    DetailedGSTLedgerEntry.SetRange("GST Jurisdiction Type", GSTCreditAdjustmentJournal."GST Jurisdiction Type");
                    DetailedGSTLedgerEntry.SetRange("Source No.", GSTCreditAdjustmentJournal."Vendor No.");
                    if GSTCreditAdjustmentJournal."Document Type" = GSTCreditAdjustmentJournal."Document Type"::Invoice then
                        DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice)
                    else
                        DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::"Credit Memo");
                    DetailedGSTLedgerEntry.SetRange("Document No.", GSTCreditAdjustmentJournal."Document No.");
                    DetailedGSTLedgerEntry.SetRange("Document Line No.", GSTCreditAdjustmentJournal."Document Line No.");
                    DetailedGSTLedgerEntry.SetRange("Posting Date", GSTCreditAdjustmentJournal."Posting Date");
                    DetailedGSTLedgerEntry.SetRange("GST Credit", DetailedGSTLedgerEntry."GST Credit"::Availment);
                    DetailedGSTLedgerEntry.SetRange(Distributed, false);
                    DetailedGSTLedgerEntry.SetRange("Reverse Charge", false);
                    DetailedGSTLedgerEntry.SetRange("GST Exempted Goods", false);
                    if DetailedGSTLedgerEntry.FindSet() then
                        repeat
                            TempGSTPostingBuffer[1]."Transaction Type" := TempGSTPostingBuffer[1]."Transaction Type"::Purchase;
                            TempGSTPostingBuffer[1]."GST Component Code" := DetailedGSTLedgerEntry."GST Component Code";
                            TempGSTPostingBuffer[1]."GST Amount" :=
                              -Abs(Round((DetailedGSTLedgerEntry."GST Amount" * GSTCreditAdjustmentJournal."Adjustment %") / 100,
                                  GenLedgerSetup."Amount Rounding Precision"));
                            TempGSTPostingBuffer[1]."GST Base Amount" :=
                              -Abs(Round((DetailedGSTLedgerEntry."GST Base Amount" * GSTCreditAdjustmentJournal."Adjustment %") / 100,
                                  GenLedgerSetup."Amount Rounding Precision"));
                            TempGSTPostingBuffer[1]."Global Dimension 1 Code" := GSTCreditAdjustmentJournal."Shortcut Dimension 1 Code";
                            TempGSTPostingBuffer[1]."Global Dimension 2 Code" := GSTCreditAdjustmentJournal."Shortcut Dimension 2 Code";
                            TempGSTPostingBuffer[1]."Dimension Set ID" := GSTCreditAdjustmentJournal."Dimension Set ID";
                            case GSTCreditAdjustmentJournal."Nature of Adjustment" of
                                GSTCreditAdjustmentJournal."Nature of Adjustment"::"Credit Reversal":
                                    begin
                                        TempGSTPostingBuffer[1]."Account No." :=
                                          GSTHelpers.GetGSTPayableAccountNo(
                                              GSTCreditAdjustmentJournal."Location State Code",
                                              DetailedGSTLedgerEntry."GST Component Code");
                                        TempGSTPostingBuffer[1]."GST Amount" := -TempGSTPostingBuffer[1]."GST Amount";
                                        TempGSTPostingBuffer[1]."GST Base Amount" := -TempGSTPostingBuffer[1]."GST Base Amount";
                                    end;
                                GSTCreditAdjustmentJournal."Nature of Adjustment"::"Credit Re-Availment":
                                    if GSTCreditAdjustmentJournal."Input Service Distribution" then
                                        TempGSTPostingBuffer[1]."Account No." :=
                                          GSTHelpers.GetGSTReceivableDistAccountNo(
                                            GSTCreditAdjustmentJournal."Location State Code",
                                            DetailedGSTLedgerEntry."GST Component Code")
                                    else
                                        TempGSTPostingBuffer[1]."Account No." :=
                                          GSTHelpers.GetGSTReceivableAccountNo(
                                            GSTCreditAdjustmentJournal."Location State Code", DetailedGSTLedgerEntry."GST Component Code");
                                GSTCreditAdjustmentJournal."Nature of Adjustment"::"Permanent Reversal":
                                    TempGSTPostingBuffer[1]."Account No." :=
                                      GSTHelpers.GetGSTExpenseAccountNo(
                                          GSTCreditAdjustmentJournal."Location State Code",
                                          DetailedGSTLedgerEntry."GST Component Code")
                            end;

                            UpdateGSTPostingBuffer();
                            UpdateDetailedGSTLedgerEntry(
                                GSTCreditAdjustmentJournal."Nature of Adjustment",
                                DetailedGSTLedgerEntry."Entry No.",
                                GSTCreditAdjustmentJournal."Adjustment Posting Date",
                                TempGSTPostingBuffer[1]."GST Amount",
                                GSTCreditAdjustmentJournal."Adjustment %",
                                TempGSTPostingBuffer[1]."GST Base Amount");
                            PostToDetailedCrAdjEntry(DetailedGSTLedgerEntry, GSTCreditAdjustmentJournal);
                        until DetailedGSTLedgerEntry.Next() = 0;
                    if TempGSTPostingBuffer[1].Find('+') then
                        repeat
                            BalAccountNo :=
                              GSTHelpers.GetGSTMismatchAccountNo(
                                GSTCreditAdjustmentJournal."Location State Code", TempGSTPostingBuffer[1]."GST Component Code");
                            if GSTCreditAdjustmentJournal."Document Type" = GSTCreditAdjustmentJournal."Document Type"::Invoice then
                                PostGenJnlLine(
                                  GenJnlLine,
                                  TempGSTPostingBuffer[1]."Account No.",
                                  BalAccountNo,
                                  GSTCreditAdjustmentJournal."Adjust Document No.",
                                  TempGSTPostingBuffer[1]."GST Amount",
                                  GSTCreditAdjustmentJournal."Adjustment Posting Date",
                                  GenJnlLine."Document Type"::Invoice,
                                  GSTCreditAdjustmentJournal."GST Jurisdiction Type",
                                  false,
                                  false,
                                  TempGSTPostingBuffer[1]."Dimension Set ID")
                            else
                                PostGenJnlLine(
                                  GenJnlLine,
                                  TempGSTPostingBuffer[1]."Account No.",
                                  BalAccountNo,
                                  GSTCreditAdjustmentJournal."Adjust Document No.",
                                  TempGSTPostingBuffer[1]."GST Amount",
                                  GSTCreditAdjustmentJournal."Adjustment Posting Date",
                                  GenJnlLine."Document Type"::"Credit Memo",
                                  GSTCreditAdjustmentJournal."GST Jurisdiction Type",
                                  false,
                                  false,
                                  TempGSTPostingBuffer[1]."Dimension Set ID");

                            EntryNo := GenJournalPostLine.RunWithCheck(GenJnlLine);
                        until TempGSTPostingBuffer[1].Next(-1) = 0;
                until GSTCreditAdjustmentJournal.Next() = 0;
                NoSeriesManagement.GetNextNo(GetNoSeriesCode(false), GSTCreditAdjustmentJournal."Posting Date", true);
            end;
        end;

        if EntryNo <> 0 then
            Message(CrAdjstPostedMsg)
        else
            Error(NoPostErr);
    end;

    procedure GetNoSeriesCode(CreditLiability: Boolean): Code[20]
    var
        GeneLedgerSetup: Record "General Ledger Setup";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        if CreditLiability then begin
            PurchasesPayablesSetup.Get();
            PurchasesPayablesSetup.TestField("GST Liability Adj. Jnl Nos.");
            exit(PurchasesPayablesSetup."GST Liability Adj. Jnl Nos.");
        end;

        GeneLedgerSetup.Get();
        GeneLedgerSetup.TestField("GST Credit Adj. Jnl Nos.");
        exit(GeneLedgerSetup."GST Credit Adj. Jnl Nos.");
    end;

    procedure FillGSTLiabilityAdjustmentJournal(
        GSTINNo: Code[20];
        VendorNo: Code[20];
        LiabilityDate: Date;
        DocumentNo1: Code[20];
        ExternalDocNo: Code[35];
        NatureOfAdj: Enum "Cr Libty Adjustment Type";
        AdjDocNo: Code[20];
        AdjPostingDate: Date)
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        GSTLiabilityBuffer: Record "GST Liability Buffer";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        PostedGSTLiabilityAdj: Record "Posted GST Liability Adj.";
        RemainingAmount: Decimal;
        DocumentNo2: Code[20];
    begin
        GetLiabilitySourceCode();
        GSTLiabilityBuffer.DeleteAll();
        if NatureOfAdj = NatureOfAdj::Generate then begin
            VendorLedgerEntry.SetCurrentKey("Document No.", "Document Type", "Vendor No.");
            if DocumentNo1 <> '' then
                VendorLedgerEntry.SetRange("Document No.", DocumentNo1);
            VendorLedgerEntry.SetRange("Document Type", "Document Type Enum"::Invoice);
            if VendorNo <> '' then
                VendorLedgerEntry.SetRange("Vendor No.", VendorNo);
            VendorLedgerEntry.SetRange(Open, true);
            VendorLedgerEntry.SetFilter("Posting Date", '..%1', LiabilityDate);
            if ExternalDocNo <> '' then
                VendorLedgerEntry.SetRange("External Document No.", ExternalDocNo);
            VendorLedgerEntry.SetFilter(
              VendorLedgerEntry."GST Vendor Type", '%1|%2|%3|%4',
              "GST Vendor Type"::Registered, "GST Vendor Type"::Unregistered, "GST Vendor Type"::Import, "GST Vendor Type"::SEZ);
            VendorLedgerEntry.CalcFields("Remaining Amt. (LCY)");
            VendorLedgerEntry.SetFilter("Remaining Amt. (LCY)", '<>%1', 0);
            VendorLedgerEntry.SetRange("Location GST Reg. No.", GSTINNo);
            if VendorLedgerEntry.FindSet() then
                repeat
                    VendorLedgerEntry.CalcFields("Remaining Amt. (LCY)");
                    RemainingAmount := VendorLedgerEntry."Remaining Amt. (LCY)" - Abs(VendorLedgerEntry."Total TDS Including SHE CESS" / VendorLedgerEntry."Original Currency Factor");
                    FillAppBufferInvoice(
                        VendorLedgerEntry."Document No.",
                        VendorLedgerEntry."Location GST Reg. No.",
                        LiabilityDate,
                        NatureOfAdj);
                    AllocateGSTWithPayment(VendorLedgerEntry."Document No.", VendorLedgerEntry."Vendor No.", RemainingAmount);
                    FillGSTCreditLiability(VendorLedgerEntry, AdjDocNo, AdjPostingDate, NatureOfAdj);
                until VendorLedgerEntry.Next() = 0
            else
                Error(GSTCrAdjFilterErr);
        end;

        if NatureOfAdj = NatureOfAdj::Reverse then begin
            DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
            DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
            DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
            if DocumentNo1 <> '' then
                DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo1);
            if VendorNo <> '' then
                DetailedGSTLedgerEntry.SetRange("Source No.", VendorNo);
            DetailedGSTLedgerEntry.SetRange("Location  Reg. No.", GSTINNo);
            DetailedGSTLedgerEntry.SetFilter("Posting Date", '..%1', LiabilityDate);
            DetailedGSTLedgerEntry.SetRange("Cr. & Liab. Adjustment Type", DetailedGSTLedgerEntry."Cr. & Liab. Adjustment Type"::Generate);
            if DetailedGSTLedgerEntry.FindSet() then
                repeat
                    if DocumentNo2 <> DetailedGSTLedgerEntry."Document No." then begin
                        PostedGSTLiabilityAdj.SetRange("Document No.", DetailedGSTLedgerEntry."Document No.");
                        PostedGSTLiabilityAdj.SetRange("Credit Adjustment Type", DetailedGSTLedgerEntry."Cr. & Liab. Adjustment Type");
                        if PostedGSTLiabilityAdj.FindLast() then
                            if PostedGSTLiabilityAdj."Posting Date" <= AdjPostingDate then begin
                                FillAppBufferInvoice(
                                    DetailedGSTLedgerEntry."Document No.",
                                    DetailedGSTLedgerEntry."Location  Reg. No.",
                                    LiabilityDate,
                                    NatureOfAdj);
                                FillGSTCreditLiabilityReverse(
                                    DetailedGSTLedgerEntry,
                                    AdjDocNo,
                                    AdjPostingDate,
                                    NatureOfAdj);
                            end;
                        DocumentNo2 := DetailedGSTLedgerEntry."Document No.";
                    end;
                until DetailedGSTLedgerEntry.Next() = 0;
        end;
    end;

    procedure FillAppBufferInvoice(
        DocumentNo: Code[20];
        LocationRegNo: Code[20];
        LiabilityDate: Date;
        NatureOfAdj: Enum "Cr Libty Adjustment Type")
    var
        GSTLiabilityBuffer: array[2] of Record "GST Liability Buffer";
        DetailedGSTLedgerEntry: array[2] of Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        GSTBaseValidation: Codeunit "GST Base Validation";
        CurrencyFactor: Decimal;
    begin
        DetailedGSTLedgerEntry[1].SetCurrentKey(
          "Location  Reg. No.", "Transaction Type", "Entry Type", "GST Vendor Type", "GST Credit",
          "Posting Date", "Source No.", "Document Type", "Document No.");
        DetailedGSTLedgerEntry[1].SetRange("Location  Reg. No.", LocationRegNo);
        DetailedGSTLedgerEntry[1].SetRange("Document No.", DocumentNo);
        DetailedGSTLedgerEntry[1].SetRange("Transaction Type", DetailedGSTLedgerEntry[1]."Transaction Type"::Purchase);
        DetailedGSTLedgerEntry[1].SetRange("GST Group Type", DetailedGSTLedgerEntry[1]."GST Group Type"::Service);
        DetailedGSTLedgerEntry[1].SetRange("Reverse Charge", true);
        DetailedGSTLedgerEntry[1].SetRange("Associated Enterprises", false);
        DetailedGSTLedgerEntry[1].SetFilter("Posting Date", '..%1', LiabilityDate);
        if NatureOfAdj = NatureOfAdj::Reverse then
            DetailedGSTLedgerEntry[1].SetRange("Cr. & Liab. Adjustment Type", NatureOfAdj::Generate);
        if DetailedGSTLedgerEntry[1].FindSet() then
            repeat
                if (NatureOfAdj = NatureOfAdj::Generate) and
                   (DetailedGSTLedgerEntry[1]."Cr. & Liab. Adjustment Type" =
                    DetailedGSTLedgerEntry[1]."Cr. & Liab. Adjustment Type"::Generate) and
                   (DetailedGSTLedgerEntry[1]."Remaining Base Amount" = 0)
                then
                    exit;

                if (DetailedGSTLedgerEntry[1]."Cr. & Liab. Adjustment Type" =
                    DetailedGSTLedgerEntry[1]."Cr. & Liab. Adjustment Type"::Generate) and
                   (DetailedGSTLedgerEntry[1]."Remaining Base Amount" <> 0) and
                   (DetailedGSTLedgerEntry[1]."Remaining Base Amount" = DetailedGSTLedgerEntry[1]."AdjustmentBase Amount")
                then begin
                    DetailedGSTLedgerEntry[1]."Remaining Base Amount" := 0;
                    DetailedGSTLedgerEntry[1]."Remaining GST Amount" := 0;
                    DetailedGSTLedgerEntry[1].Modify();
                    exit;
                end;

                GetDetailedGSTLedgerEnfo(DetailedGSTLedgerEntry[1]."Entry No.", DetailedGSTLedgerEntryInfo);
                Clear(GSTLiabilityBuffer[1]);

                CurrencyFactor := 1;
                GSTLiabilityBuffer[1]."Transaction Type" := DetailedGSTLedgerEntry[1]."Transaction Type";
                GSTLiabilityBuffer[1]."Original Document Type" := GSTLiabilityBuffer[1]."Original Document Type"::Invoice;
                GSTLiabilityBuffer[1]."Original Document No." := DetailedGSTLedgerEntry[1]."Document No.";
                GSTLiabilityBuffer[1]."Account No." := DetailedGSTLedgerEntry[1]."Source No.";
                GSTLiabilityBuffer[1]."GST Cess" := DetailedGSTLedgerEntryInfo.Cess;
                GSTLiabilityBuffer[1]."GST Component Code" := DetailedGSTLedgerEntry[1]."GST Component Code";
                GSTLiabilityBuffer[1]."Current Doc. Type" := DetailedGSTLedgerEntry[1]."Document Type";
                GSTLiabilityBuffer[1]."Currency Code" := DetailedGSTLedgerEntry[1]."Currency Code";
                GSTLiabilityBuffer[1]."Currency Factor" := DetailedGSTLedgerEntry[1]."Currency Factor";
                GSTLiabilityBuffer[1]."GST Rounding Precision" := DetailedGSTLedgerEntry[1]."GST Rounding Precision";
                GSTLiabilityBuffer[1]."GST Rounding Type" := DetailedGSTLedgerEntry[1]."GST Rounding Type";
                GSTLiabilityBuffer[1]."GST Group Type" := DetailedGSTLedgerEntry[1]."GST Group Type";
                GSTLiabilityBuffer[1]."GST Group Code" := DetailedGSTLedgerEntry[1]."GST Group Code";
                GSTLiabilityBuffer[1]."GST Jurisdiction Type" := DetailedGSTLedgerEntry[1]."GST Jurisdiction Type";
                GSTLiabilityBuffer[1]."Original Line No." := DetailedGSTLedgerEntry[1]."Document Line No.";
                GSTLiabilityBuffer[1].Exempted := DetailedGSTLedgerEntry[1]."GST Exempted Goods";
                GSTLiabilityBuffer[1]."GST %" := DetailedGSTLedgerEntry[1]."GST %";
                GSTLiabilityBuffer[1]."GST Credit" := DetailedGSTLedgerEntry[1]."GST Credit";

                if GSTLiabilityBuffer[1]."Currency Code" <> '' then
                    GSTLiabilityBuffer[1]."GST Base Amount" := Round(DetailedGSTLedgerEntry[1]."GST Base Amount" * CurrencyFactor, 0.01)
                else
                    GSTLiabilityBuffer[1]."GST Base Amount" := DetailedGSTLedgerEntry[1]."GST Base Amount";

                GSTLiabilityBuffer[1]."GST Amount" := GSTBaseValidation.RoundGSTPrecisionThroughTaxComponent(DetailedGSTLedgerEntry[1]."GST Component Code", DetailedGSTLedgerEntry[1]."GST Amount" * CurrencyFactor);

                if (DetailedGSTLedgerEntry[1]."Cr. & Liab. Adjustment Type" =
                    DetailedGSTLedgerEntry[1]."Cr. & Liab. Adjustment Type"::Generate) and
                   (DetailedGSTLedgerEntry[1]."Remaining Base Amount" <> 0)
                then begin
                    if GSTLiabilityBuffer[1]."Currency Code" <> '' then
                        GSTLiabilityBuffer[1]."GST Base Amount" := Round(DetailedGSTLedgerEntry[1]."Remaining Base Amount" * CurrencyFactor, 0.01)
                    else
                        GSTLiabilityBuffer[1]."GST Base Amount" := DetailedGSTLedgerEntry[1]."Remaining Base Amount";

                    GSTLiabilityBuffer[1]."GST Amount" := GSTBaseValidation.RoundGSTPrecisionThroughTaxComponent(DetailedGSTLedgerEntry[1]."GST Component Code", DetailedGSTLedgerEntry[1]."Remaining GST Amount" * CurrencyFactor);
                end;

                if NatureOfAdj = NatureOfAdj::Reverse then begin
                    if GSTLiabilityBuffer[1]."Currency Code" <> '' then
                        GSTLiabilityBuffer[1]."Applied Base Amount" := Round(DetailedGSTLedgerEntry[1]."AdjustmentBase Amount" * CurrencyFactor, 0.01)
                    else
                        GSTLiabilityBuffer[1]."Applied Base Amount" := DetailedGSTLedgerEntry[1]."AdjustmentBase Amount";

                    GSTLiabilityBuffer[1]."Applied Amount" := GSTBaseValidation.RoundGSTPrecisionThroughTaxComponent(DetailedGSTLedgerEntry[1]."GST Component Code", DetailedGSTLedgerEntry[1]."Adjustment Amount" * CurrencyFactor);
                    if DetailedGSTLedgerEntry[1]."GST Credit" = DetailedGSTLedgerEntry[1]."GST Credit"::Availment then
                        GSTLiabilityBuffer[1]."Credit Amount" := GSTLiabilityBuffer[1]."Applied Amount";
                end;

                GSTLiabilityBuffer[2] := GSTLiabilityBuffer[1];
                if GSTLiabilityBuffer[2].Find() then begin
                    GSTLiabilityBuffer[2]."GST Base Amount" += GSTLiabilityBuffer[1]."GST Base Amount";
                    GSTLiabilityBuffer[2]."GST Base Amount" += 0;
                    GSTLiabilityBuffer[2]."GST Amount" += GSTLiabilityBuffer[1]."GST Amount";
                    GSTLiabilityBuffer[2]."Credit Amount" += GSTLiabilityBuffer[1]."Credit Amount";
                    if NatureOfAdj = NatureOfAdj::Reverse then begin
                        GSTLiabilityBuffer[2]."Applied Base Amount" += GSTLiabilityBuffer[1]."Applied Base Amount";
                        GSTLiabilityBuffer[2]."Applied Amount" += GSTLiabilityBuffer[1]."Applied Amount"
                    end;

                    GSTLiabilityBuffer[2].Modify(true);
                end else
                    GSTLiabilityBuffer[2].Insert(true);
            until DetailedGSTLedgerEntry[1].Next() = 0;
    end;

    procedure PostLiabilityAdjustmentJnl(GSTLiabilityAdjustment: Record "GST Liability Adjustment")
    var
        GSTLiabilityBuffer: Record "GST Liability Buffer";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GenJnlLine: Record "Gen. Journal Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        AppliedBase: Decimal;
        AppliedAmount: Decimal;
        RemainingBase: Decimal;
        RemainingAmount: Decimal;
        AccountNo: Code[20];
        AccountNo2: Code[20];
        BalanceAccountNo: Code[20];
        BalanceAccountNo2: Code[20];
    begin
        GSTLiabilityAdjustment.SetFilter("Nature of Adjustment", '<>%1', GSTLiabilityAdjustment."Nature of Adjustment"::" ");
        if GSTLiabilityAdjustment.FindSet() then begin
            repeat
                TempGSTPostingBuffer1[1].DeleteAll();

                GSTLiabilityBuffer.SetRange("Original Document No.", GSTLiabilityAdjustment."Document No.");
                GSTLiabilityBuffer.SetRange("Account No.", GSTLiabilityAdjustment."Vendor No.");
                if GSTLiabilityAdjustment."Nature of Adjustment" = GSTLiabilityAdjustment."Nature of Adjustment"::Generate then
                    GSTLiabilityBuffer.SetFilter("Applied Amount", '<>%1', 0);
                if GSTLiabilityAdjustment."Nature of Adjustment" = GSTLiabilityAdjustment."Nature of Adjustment"::Reverse then
                    GSTLiabilityBuffer.SetFilter("GST Amount", '<>%1', 0);
                if GSTLiabilityBuffer.FindSet() then
                    repeat
                        DetailedGSTLedgerEntry.SetCurrentKey(
                          "Transaction Type",
                          "Source No.",
                          "Document Type",
                          "Document No.",
                          "GST Group Code");
                        DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
                        DetailedGSTLedgerEntry.SetRange("Source No.", GSTLiabilityBuffer."Account No.");
                        DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
                        DetailedGSTLedgerEntry.SetRange("Document No.", GSTLiabilityBuffer."Original Document No.");
                        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
                        DetailedGSTLedgerEntry.SetRange("GST Group Code", GSTLiabilityBuffer."GST Group Code");
                        DetailedGSTLedgerEntry.SetRange("GST Component Code", GSTLiabilityBuffer."GST Component Code");
                        DetailedGSTLedgerEntry.SetRange("GST Exempted Goods", GSTLiabilityBuffer.Exempted);
                        if DetailedGSTLedgerEntry.FindSet() then begin
                            RemainingBase := GSTLiabilityBuffer."Applied Base Amount";
                            RemainingAmount := GSTLiabilityBuffer."Applied Amount";

                            repeat
                                if RemainingBase <> 0 then begin
                                    if GSTLiabilityAdjustment."Nature of Adjustment" = GSTLiabilityAdjustment."Nature of Adjustment"::Reverse then
                                        GetAppliedAmount(
                                          Abs(RemainingBase),
                                          Abs(RemainingAmount),
                                          Abs(DetailedGSTLedgerEntry."AdjustmentBase Amount"),
                                          Abs(DetailedGSTLedgerEntry."Adjustment Amount"),
                                          AppliedBase,
                                          AppliedAmount)
                                    else
                                        GetAppliedAmount(
                                          Abs(RemainingBase),
                                          Abs(RemainingAmount),
                                          Abs(DetailedGSTLedgerEntry."Remaining Base Amount"),
                                          Abs(DetailedGSTLedgerEntry."Remaining GST Amount"),
                                          AppliedBase,
                                          AppliedAmount);

                                    FillGSTPostingBufferWithApplication(
                                        DetailedGSTLedgerEntry,
                                        AppliedBase,
                                        AppliedAmount,
                                        GSTLiabilityAdjustment."Dimension Set ID");

                                    PostCreditAdjustJnl(
                                        GSTLiabilityBuffer,
                                        GSTLiabilityAdjustment,
                                        DetailedGSTLedgerEntry,
                                        AppliedBase,
                                        AppliedAmount);

                                    RemainingBase := Abs(RemainingBase) - Abs(AppliedBase);
                                    RemainingAmount := Abs(RemainingAmount) - Abs(AppliedAmount);
                                end;

                                UpdateServiceLiabilityDetailedGSTLedgerEntry(
                                    GSTLiabilityAdjustment."Nature of Adjustment",
                                    DetailedGSTLedgerEntry."Entry No.",
                                    AppliedBase,
                                    AppliedAmount);
                            until DetailedGSTLedgerEntry.Next() = 0;
                        end;
                    until GSTLiabilityBuffer.Next() = 0;

                Clear(GenJnlPostLine);
                if TempGSTPostingBuffer1[1].Find('+') then
                    repeat
                        if TempGSTPostingBuffer1[1]."GST Amount" <> 0 then begin
                            GetCreditAccountNormalPayment(
                              DetailedGSTLedgerEntry, TempGSTPostingBuffer1[1], AccountNo, AccountNo2,
                              BalanceAccountNo, BalanceAccountNo2);
                            if GSTLiabilityAdjustment."Nature of Adjustment" = GSTLiabilityAdjustment."Nature of Adjustment"::Generate then
                                PostGenJnlLine(
                                    GenJnlLine,
                                    AccountNo,
                                    BalanceAccountNo,
                                    GSTLiabilityAdjustment."Document No.",
                                    TempGSTPostingBuffer1[1]."GST Amount",
                                    GSTLiabilityAdjustment."Adjustment Posting Date",
                                    GenJnlLine."Document Type"::Invoice,
                                    GSTLiabilityAdjustment."GST Jurisdiction Type",
                                    true,
                                    false,
                                    TempGSTPostingBuffer1[1]."Dimension Set ID")
                            else
                                PostGenJnlLine(
                                    GenJnlLine,
                                    AccountNo,
                                    BalanceAccountNo,
                                    GSTLiabilityAdjustment."Document No.",
                                    -TempGSTPostingBuffer1[1]."GST Amount",
                                    GSTLiabilityAdjustment."Adjustment Posting Date",
                                    GenJnlLine."Document Type"::Invoice,
                                    GSTLiabilityAdjustment."GST Jurisdiction Type",
                                    true,
                                    false,
                                    TempGSTPostingBuffer1[1]."Dimension Set ID");

                            GenJnlPostLine.RunWithCheck(GenJnlLine);

                            if AccountNo2 <> '' then begin
                                if GSTLiabilityAdjustment."Nature of Adjustment" = GSTLiabilityAdjustment."Nature of Adjustment"::Generate then
                                    PostGenJnlLine(
                                        GenJnlLine,
                                        AccountNo2,
                                        BalanceAccountNo2,
                                        GSTLiabilityAdjustment."Document No.",
                                        TempGSTPostingBuffer1[1]."GST Amount",
                                        GSTLiabilityAdjustment."Adjustment Posting Date",
                                        GenJnlLine."Document Type"::Invoice,
                                        GSTLiabilityAdjustment."GST Jurisdiction Type",
                                        true,
                                        false,
                                        TempGSTPostingBuffer1[1]."Dimension Set ID")
                                else
                                    PostGenJnlLine(
                                        GenJnlLine,
                                        AccountNo2,
                                        BalanceAccountNo2,
                                        GSTLiabilityAdjustment."Document No.",
                                        -TempGSTPostingBuffer1[1]."GST Amount",
                                        GSTLiabilityAdjustment."Adjustment Posting Date",
                                        GenJnlLine."Document Type"::Invoice,
                                        GSTLiabilityAdjustment."GST Jurisdiction Type",
                                        true,
                                        false,
                                        TempGSTPostingBuffer1[1]."Dimension Set ID");

                                GenJnlPostLine.RunWithCheck(GenJnlLine);
                            end;
                        end;
                    until TempGSTPostingBuffer1[1].Next(-1) = 0;
            until GSTLiabilityAdjustment.Next() = 0;

            NoSeriesManagement.GetNextNo(GetNoSeriesCode(true), GSTLiabilityAdjustment."Adjustment Posting Date", true);
        end;
    end;

    procedure ApplyGSTSettlement(
        GSTINNo: Code[20];
        PostingDate: Date;
        AccountType: Enum "GST Settlement Account Type";
        AccountNo: Code[20];
        BankRefNo: Code[10];
        BankRefDate: Date)
    var
        GSTPaymentBuffer: Record "GST Payment Buffer";
        PayGST: Page "Pay GST";
        ApplyDocumentNo: Code[20];
    begin
        CheckSettlementInputValidations(GSTINNo, PostingDate);

        ApplyDocumentNo := GetSettlementDocumentNo(PostingDate, false);
        GSTPaymentBuffer.SetRange("Document No.", ApplyDocumentNo);
        GSTPaymentBuffer.DeleteAll();
        IsDuplicateDocumentNo(ApplyDocumentNo);

        CreateGSTPaymentBuffer(GSTINNo, ApplyDocumentNo, PostingDate, AccountType, AccountNo, BankRefNo, BankRefDate);
        UpdateCreditAmount(GSTINNo, ApplyDocumentNo);
        Commit();

        PayGST.SetParameter(GSTINNo, ApplyDocumentNo);
        PayGST.RunModal();
    end;

    procedure IsDuplicateDocumentNo(DocumentNo: Code[20])
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        if DocumentNo = '' then
            exit;

        DetailedGSTLedgerEntry.SetCurrentKey("Payment Document No.");
        DetailedGSTLedgerEntry.SetRange("Payment Document No.", DocumentNo);
        if not DetailedGSTLedgerEntry.IsEmpty() then
            Error(PaymentDocErr, DocumentNo);
    end;

    procedure UpdateCreditAmount(GSTINNo: Code[20]; DocumentNo: Code[20])
    var
        GSTPaymentBuffer: Record "GST Payment Buffer";
    begin
        GSTPaymentBuffer.SetRange("GST Registration No.", GSTINNo);
        GSTPaymentBuffer.SetRange("Document No.", DocumentNo);
        if GSTPaymentBuffer.FindSet() then
            repeat
                UpdateGSTPaymentBufferPriorityAmount(GSTPaymentBuffer, GSTINNo, DocumentNo);
            until GSTPaymentBuffer.Next() = 0;
    end;

    local procedure UpdateGSTPaymentBufferPriorityAmount(var GSTPaymentBuffer: Record "GST Payment Buffer"; GSTINNo: Code[20]; DocumentNo: Code[20])
    var
        GSTClaimSetoff: Record "GST Claim Setoff";
        GSTPaymentBuffer2: Record "GST Payment Buffer";
        AvailableAmount: Decimal;
        PaymentAmount: Decimal;
    begin
        if GSTPaymentBuffer."Payment Amount" > 0 then begin
            AvailableAmount := 0;

            GSTClaimSetoff.Reset();
            GSTClaimSetoff.SetCurrentKey(Priority);
            GSTClaimSetoff.SetRange("GST Component Code", GSTPaymentBuffer."GST Component Code");
            if GSTClaimSetoff.FindSet() then
                repeat
                    GSTPaymentBuffer2.Get(GSTINNo, DocumentNo, GSTClaimSetoff."Set Off Component Code");
                    if GSTPaymentBuffer2."Total Credit Available" > 0 then begin
                        AvailableAmount += GSTPaymentBuffer2."Total Credit Available" - GSTPaymentBuffer2."Surplus Cr. Utilized";
                        PaymentAmount := GSTPaymentBuffer."Payment Amount";

                        if AvailableAmount > 0 then begin
                            if AvailableAmount >= PaymentAmount then begin
                                if GSTPaymentBuffer."GST Component Code" = GSTPaymentBuffer2."GST Component Code" then begin
                                    UpdateGSTPaymentSameComponentAmount(GSTPaymentBuffer, PaymentAmount);
                                    GSTPaymentBuffer2.Get(GSTINNo, DocumentNo, GSTClaimSetoff."Set Off Component Code");
                                end else
                                    UpdateGSTPaymentDiffComponentAmount(GSTPaymentBuffer2, PaymentAmount);

                                GSTPaymentBuffer.Validate("Payment Amount", 0);
                                GSTPaymentBuffer."Credit Utilized" := GSTPaymentBuffer."Credit Utilized" + PaymentAmount;
                                GSTPaymentBuffer.Modify();
                            end else begin
                                if GSTPaymentBuffer."GST Component Code" = GSTPaymentBuffer2."GST Component Code" then begin
                                    UpdateGSTPaymentSameComponentAmount(GSTPaymentBuffer, AvailableAmount);
                                    GSTPaymentBuffer2.Get(GSTINNo, DocumentNo, GSTClaimSetoff."Set Off Component Code");
                                end else
                                    UpdateGSTPaymentDiffComponentAmount(GSTPaymentBuffer2, AvailableAmount);

                                GSTPaymentBuffer.Validate("Payment Amount", GSTPaymentBuffer."Payment Amount" - AvailableAmount);
                                GSTPaymentBuffer."Credit Utilized" := GSTPaymentBuffer."Credit Utilized" + AvailableAmount;
                                GSTPaymentBuffer.Modify();
                                AvailableAmount := 0;
                            end;

                            GSTPaymentBuffer2."Carry Forward" := GSTPaymentBuffer2."Surplus Credit";
                            GSTPaymentBuffer2.Modify(true);
                            GSTPaymentBuffer.Modify(true);
                        end;
                    end;
                until (GSTClaimSetoff.Next() = 0) or (GSTPaymentBuffer."Payment Amount" = 0);
        end;
    end;

    local procedure UpdateGSTPaymentSameComponentAmount(var GSTPaymentBuffer: Record "GST Payment Buffer"; SurplusCredit: Decimal)
    begin
        GSTPaymentBuffer."Surplus Cr. Utilized" += SurplusCredit;
        GSTPaymentBuffer."Surplus Credit" -= SurplusCredit;
        GSTPaymentBuffer."Carry Forward" := GSTPaymentBuffer."Surplus Credit";
        GSTPaymentBuffer.Modify(true);
    end;

    local procedure UpdateGSTPaymentDiffComponentAmount(var GSTPaymentBuffer2: Record "GST Payment Buffer"; SurplusCredit: Decimal)
    begin
        GSTPaymentBuffer2."Surplus Cr. Utilized" += SurplusCredit;
        GSTPaymentBuffer2."Surplus Credit" -= SurplusCredit;
    end;

    procedure GetPeriodendDate(PostingDate: Date): Date
    begin
        exit(CalcDate('<-CM-1D>', PostingDate));
    end;

    procedure PostGSTPayment(GSTINNo: Code[20]; DocumentNo: Code[20]; var NoMsg: Boolean): Boolean
    var
        GSTPaymentBuffer: Record "GST Payment Buffer";
    begin
        GSTPaymentBuffer.SetRange("GST Registration No.", GSTINNo);
        GSTPaymentBuffer.SetRange("Document No.", DocumentNo);
        if GSTPaymentBuffer.IsEmpty() then
            exit(false);

        CopyDocDimToTempDocDim(GSTINNo, DocumentNo);
        ValidateCreditUtilizedAmt(GSTINNo, DocumentNo);
        CheckSettlementValidations(GSTINNo, DocumentNo);
        if not Confirm(PostGSTPaymentQst, false) then begin
            NoMsg := true;
            exit(false);
        end;

        if IsAllComponentsHaveZeroValue(GSTINNo, DocumentNo) then
            exit(false);

        PostGSTBuffer(GSTINNo, DocumentNo);
        exit(true);
    end;

    procedure IsGSTPaymentApplicable(var GSTPaymentBuffer: Record "GST Payment Buffer"): Boolean
    begin
        if (GSTPaymentBuffer."Net Payment Liability" > 0) and
            ((GSTPaymentBuffer."Credit Utilized" > 0) or
                (GSTPaymentBuffer."Payment Amount" > 0) or
                (GSTPaymentBuffer."Total Credit Available" > 0)) or
            (GSTPaymentBuffer.Penalty > 0) or
            (GSTPaymentBuffer.Interest > 0) or
            (GSTPaymentBuffer.Fees > 0) or
            (GSTPaymentBuffer.Others > 0) or
            (GSTPaymentBuffer."Payment Liability - Rev. Chrg." > 0) or
            (GSTPaymentBuffer."Surplus Cr. Utilized" > 0) or
            (GSTPaymentBuffer."Carry Forward" > 0) or
            (GSTPaymentBuffer."UnAdjutsed Credit" < 0) or
            (GSTPaymentBuffer."GST TDS Credit Utilized" > 0) or
            (GSTPaymentBuffer."GST TCS Credit Utilized" > 0) or
            (GSTPaymentBuffer."GST TCS Liability" > 0)
        then
            exit(true);

        exit(false);
    end;

    procedure UpdateAdjRemAmt()
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedCrAdjstmntEntry: Record "Detailed Cr. Adjstmnt. Entry";
        DetailedCrAdjstmntEntry2: Record "Detailed Cr. Adjstmnt. Entry";
        SourceType: Text;
        SourceTypeEnum: Enum "Source Type";
    begin
        DetailedCrAdjstmntEntry.SetRange("Rem. Amt. Updated in DGLE", false);
        if DetailedCrAdjstmntEntry.FindSet() then begin
            repeat
                SourceType := Format(DetailedCrAdjstmntEntry."Source Type");
                Evaluate(SourceTypeEnum, SourceType);
                DetailedGSTLedgerEntry.SetRange("Document Type", DetailedCrAdjstmntEntry."Adjusted Doc. Type");
                DetailedGSTLedgerEntry.SetRange("Document No.", DetailedCrAdjstmntEntry."Adjusted Doc. No.");
                DetailedGSTLedgerEntry.SetRange("Document Line No.", DetailedCrAdjstmntEntry."Adjusted Doc. Line No.");
                DetailedGSTLedgerEntry.SetRange("Source Type", SourceTypeEnum);
                DetailedGSTLedgerEntry.SetRange("Source No.", DetailedCrAdjstmntEntry."Source No.");
                DetailedGSTLedgerEntry.SetRange(Type, DetailedCrAdjstmntEntry.Type);
                DetailedGSTLedgerEntry.SetRange("GST Component Code", DetailedCrAdjstmntEntry."GST Component Code");
                if DetailedGSTLedgerEntry.FindFirst() then begin
                    DetailedGSTLedgerEntry."CAJ Base Amount" := Abs(DetailedGSTLedgerEntry."CAJ Amount" * 100) /
                      DetailedGSTLedgerEntry."GST %";
                    DetailedGSTLedgerEntry."Remaining CAJ Adj. Base Amt" :=
                      Abs(Abs(DetailedGSTLedgerEntry."GST Base Amount") - Abs(DetailedGSTLedgerEntry."CAJ Base Amount"));
                    DetailedGSTLedgerEntry."Remaining CAJ Adj. Amt" :=
                      Abs(Abs(DetailedGSTLedgerEntry."GST Amount") - Abs(DetailedGSTLedgerEntry."CAJ Amount"));
                    DetailedGSTLedgerEntry.Modify();
                    DetailedCrAdjstmntEntry2.Get(DetailedCrAdjstmntEntry."Entry No.");
                    DetailedCrAdjstmntEntry2."Rem. Amt. Updated in DGLE" := true;
                    DetailedCrAdjstmntEntry2.Modify();
                end;
            until DetailedCrAdjstmntEntry.Next() = 0;
            Message(RemCreditAmtupdatedMsg);
        end else
            Message(NothingtoUpdateMsg);
    end;

    local procedure ApplyReverseChargeFilter(
        var DetailedGSTLedgerEntry: array[2] of Record "Detailed GST Ledger Entry";
        NatureOfAdj: Enum "Credit Adjustment Type";
        ReverseCharge: Boolean;
        PeriodMonth: Integer;
        PeriodYear: Integer)
    begin
        if ReverseCharge then begin
            DetailedGSTLedgerEntry[1].SetRange("Entry Type", DetailedGSTLedgerEntry[1]."Entry Type"::Application);
            if NatureOfAdj in [NatureOfAdj::"Credit Reversal", NatureOfAdj::"Credit Re-Availment"] then
                DetailedGSTLedgerEntry[1].SetRange("GST Credit", DetailedGSTLedgerEntry[1]."GST Credit"::Availment)
            else
                if NatureOfAdj in [NatureOfAdj::"Credit Availment", NatureOfAdj::"Reversal of Availment"] then
                    DetailedGSTLedgerEntry[1].SetRange("GST Credit", DetailedGSTLedgerEntry[1]."GST Credit"::"Non-Availment");
        end else begin
            DetailedGSTLedgerEntry[1].SetRange("Entry Type", DetailedGSTLedgerEntry[1]."Entry Type"::"Initial Entry");
            DetailedGSTLedgerEntry[1].SetRange("GST Vendor Type", DetailedGSTLedgerEntry[1]."GST Vendor Type"::Registered);
            DetailedGSTLedgerEntry[1].SetRange("GST Credit", DetailedGSTLedgerEntry[1]."GST Credit"::Availment);
        end;

        DetailedGSTLedgerEntry[1].SetFilter("Posting Date", '<=%1', CalcDate('<CM>', DMY2Date(1, PeriodMonth, PeriodYear)));

    end;

    local procedure AppyNatureofAdjFilters(
        var DetailedGSTLedgerEntry: array[2] of Record "Detailed GST Ledger Entry";
        NatureOfAdj: Enum "Credit Adjustment Type")
    begin
        if NatureOfAdj in [NatureOfAdj::"Credit Reversal"] then
            DetailedGSTLedgerEntry[1].SetFilter(
              "Credit Adjustment Type", '%1|%2|%3|%4',
              DetailedGSTLedgerEntry[1]."Credit Adjustment Type"::" ",
              DetailedGSTLedgerEntry[1]."Credit Adjustment Type"::"Credit Re-Availment",
              DetailedGSTLedgerEntry[1]."Credit Adjustment Type"::"Credit Reversal",
              DetailedGSTLedgerEntry[1]."Credit Adjustment Type"::"Permanent Reversal");
        if NatureOfAdj in [NatureOfAdj::"Credit Re-Availment", NatureOfAdj::"Permanent Reversal"] then
            DetailedGSTLedgerEntry[1].SetFilter(
              "Credit Adjustment Type", '%1|%2|%3',
              DetailedGSTLedgerEntry[1]."Credit Adjustment Type"::"Credit Re-Availment",
              DetailedGSTLedgerEntry[1]."Credit Adjustment Type"::"Credit Reversal",
              DetailedGSTLedgerEntry[1]."Credit Adjustment Type"::"Permanent Reversal");
        if NatureOfAdj in [NatureOfAdj::"Credit Availment"] then
            DetailedGSTLedgerEntry[1].SetFilter(
              "Credit Adjustment Type", '%1|%2|%3', DetailedGSTLedgerEntry[1]."Credit Adjustment Type"::" ",
              DetailedGSTLedgerEntry[1]."Credit Adjustment Type"::"Credit Availment",
              DetailedGSTLedgerEntry[1]."Credit Adjustment Type"::"Reversal of Availment");
        if NatureOfAdj in [NatureOfAdj::"Reversal of Availment"] then
            DetailedGSTLedgerEntry[1].SetFilter(
              "Credit Adjustment Type", '%1|%2', DetailedGSTLedgerEntry[1]."Credit Adjustment Type"::"Credit Availment",
              DetailedGSTLedgerEntry[1]."Credit Adjustment Type"::"Reversal of Availment");
    end;

    local procedure GetCreditAdjustmentSourceCode(): Code[10]
    var
        SourceSetup: Record "Source Code Setup";
    begin
        SourceSetup.Get();
        SourceSetup.TestField("GST Credit Adjustment Journal");
        exit(SourceSetup."GST Credit Adjustment Journal");
    end;

    local procedure GetCAJLines(
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        NatureOfAdj: Enum "Credit Adjustment Type"): Boolean
    begin
        case NatureOfAdj of
            NatureOfAdj::"Credit Reversal":
                if (DetailedGSTLedgerEntry."GST Amount" - DetailedGSTLedgerEntry."CAJ Amount") <> 0 then
                    exit(true);
            NatureOfAdj::"Credit Re-Availment":
                if (DetailedGSTLedgerEntry."CAJ Amount" - DetailedGSTLedgerEntry."CAJ Amount Permanent Reversal") <> 0 then
                    exit(true);
            NatureOfAdj::"Permanent Reversal":
                if (DetailedGSTLedgerEntry."CAJ Amount" - DetailedGSTLedgerEntry."CAJ Amount Permanent Reversal") <> 0 then
                    exit(true);
            NatureOfAdj::"Credit Availment":
                if (DetailedGSTLedgerEntry."GST Amount" - DetailedGSTLedgerEntry."CAJ Amount") <> 0 then
                    exit(true);
            NatureOfAdj::"Reversal of Availment":
                if (DetailedGSTLedgerEntry."CAJ Amount" - DetailedGSTLedgerEntry."CAJ Amount Permanent Reversal") <> 0 then
                    exit(true);
        end;
    end;

    local procedure IsComponentNonAvailment(EntryNo: Integer): Boolean
    var
        PurchInvLine: Record "Purch. Inv. Line";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        DetailedGSTLedgerEntry.Get(EntryNo);
        if DetailedGSTLedgerEntry."GST Credit" = "GST Credit"::Availment then
            exit(true);
        if DetailedGSTLedgerEntry."GST Credit" = "GST Credit"::"Non-Availment" then
            if DetailedGSTLedgerEntry."Document Type" = "Document Type Enum"::Invoice then begin
                if PurchInvLine.Get(DetailedGSTLedgerEntry."Document No.", DetailedGSTLedgerEntry."Document Line No.") then;
                if PurchInvLine."GST Credit" = PurchInvLine."GST Credit"::"Non-Availment" then
                    exit(true);

                exit(false);
            end;
    end;

    local procedure InitCreditAdjustmentJournal(
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        NatureOfAdj: Enum "Credit Adjustment Type";
                         AdjDocNo: Code[20];
                         PostingDate: Date;
                         ReverseCharge: Boolean;
                         TotalGSTAmount: Decimal;
                         AdjustmentPerc: Decimal;
                         CAJAmt: Decimal;
                         CAJPermanentReversalAmt: Decimal)
    var
        GSTCreditAdjustmentJournal: Record "GST Credit Adjustment Journal";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        if TotalGSTAmount = 0 then
            exit;

        GetDetailedGSTLedgerEnfo(DetailedGSTLedgerEntry."Entry No.", DetailedGSTLedgerEntryInfo);

        GSTCreditAdjustmentJournal.Init();
        GSTCreditAdjustmentJournal."GST Registration No." := DetailedGSTLedgerEntry."Location  Reg. No.";
        GSTCreditAdjustmentJournal."Vendor No." := DetailedGSTLedgerEntry."Source No.";
        GSTCreditAdjustmentJournal."Posting Date" := DetailedGSTLedgerEntry."Posting Date";
        if DetailedGSTLedgerEntry."Document Type" = DetailedGSTLedgerEntry."Document Type"::Invoice then
            GSTCreditAdjustmentJournal."Document Type" := GSTCreditAdjustmentJournal."Document Type"::Invoice
        else
            GSTCreditAdjustmentJournal."Document Type" := GSTCreditAdjustmentJournal."Document Type"::"Credit Memo";
        GSTCreditAdjustmentJournal."Document No." := DetailedGSTLedgerEntry."Document No.";
        GSTCreditAdjustmentJournal."Document Line No." := DetailedGSTLedgerEntry."Document Line No.";
        GSTCreditAdjustmentJournal.Type := DetailedGSTLedgerEntry.Type;
        GSTCreditAdjustmentJournal.Validate("No.", DetailedGSTLedgerEntry."No.");
        GSTCreditAdjustmentJournal."Gen. Bus. Posting Group" := DetailedGSTLedgerEntryInfo."Gen. Bus. Posting Group";
        GSTCreditAdjustmentJournal."Gen. Prod. Posting Group" := DetailedGSTLedgerEntryInfo."Gen. Prod. Posting Group";
        GSTCreditAdjustmentJournal."Reverse Charge" := ReverseCharge;
        GSTCreditAdjustmentJournal."External Document No." := DetailedGSTLedgerEntry."External Document No.";
        GSTCreditAdjustmentJournal."GST Jurisdiction Type" := DetailedGSTLedgerEntry."GST Jurisdiction Type";
        GSTCreditAdjustmentJournal."Location State Code" := DetailedGSTLedgerEntryInfo."Location State Code";
        GSTCreditAdjustmentJournal."Total GST Credit Amount" := TotalGSTAmount;
        GSTCreditAdjustmentJournal."Nature of Adjustment" := NatureOfAdj;
        GSTCreditAdjustmentJournal."Selected Nature of Adjustment" := NatureOfAdj;
        if GSTCreditAdjustmentJournal."Nature of Adjustment" in [GSTCreditAdjustmentJournal."Nature of Adjustment"::"Credit Reversal", GSTCreditAdjustmentJournal."Nature of Adjustment"::"Credit Availment"] then begin
            GSTCreditAdjustmentJournal."Available Adjustment Amount" := Abs(TotalGSTAmount - Abs(CAJAmt));
            GSTCreditAdjustmentJournal."Available Adjustment %" := Abs((GSTCreditAdjustmentJournal."Available Adjustment Amount" * 100) / TotalGSTAmount);
        end;

        if GSTCreditAdjustmentJournal."Nature of Adjustment" in [
            GSTCreditAdjustmentJournal."Nature of Adjustment"::"Credit Re-Availment",
            GSTCreditAdjustmentJournal."Nature of Adjustment"::"Reversal of Availment",
            GSTCreditAdjustmentJournal."Nature of Adjustment"::"Permanent Reversal"]
        then begin
            GSTCreditAdjustmentJournal."Available Adjustment Amount" := Abs(CAJAmt) - Abs(CAJPermanentReversalAmt);
            GSTCreditAdjustmentJournal."Available Adjustment %" := Abs((GSTCreditAdjustmentJournal."Available Adjustment Amount" * 100) / TotalGSTAmount);
        end;

        GSTCreditAdjustmentJournal."Adjustment %" := AdjustmentPerc;
        if GSTCreditAdjustmentJournal."Document Type" = GSTCreditAdjustmentJournal."Document Type"::"Credit Memo" then begin
            GSTCreditAdjustmentJournal."Adjustment Amount" := Abs((TotalGSTAmount * GSTCreditAdjustmentJournal."Adjustment %") / 100);
            GSTCreditAdjustmentJournal."Total GST Amount" := (TotalGSTAmount * GSTCreditAdjustmentJournal."Adjustment %") / 100;
        end;

        if GSTCreditAdjustmentJournal."Document Type" = GSTCreditAdjustmentJournal."Document Type"::Invoice then begin
            GSTCreditAdjustmentJournal."Adjustment Amount" := (TotalGSTAmount * GSTCreditAdjustmentJournal."Adjustment %") / 100;
            GSTCreditAdjustmentJournal."Total GST Amount" := GSTCreditAdjustmentJournal."Adjustment Amount";
        end;

        GSTCreditAdjustmentJournal."Input Service Distribution" := DetailedGSTLedgerEntry."Input Service Distribution";
        GSTCreditAdjustmentJournal."Adjustment Posting Date" := PostingDate;
        GSTCreditAdjustmentJournal."Adjust Document No." := AdjDocNo;
        if GSTCreditAdjustmentJournal."Available Adjustment %" = 0 then
            exit;

        GSTCreditAdjustmentJournal.Insert(true);
    end;

    local procedure PostReverseChargeCrAdjJournal(GSTCreditAdjustmentJournal: Record "GST Credit Adjustment Journal") EntryNo: Integer
    var
        GLSetup: Record "General Ledger Setup";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GeneralPostingSetup: Record "General Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        GSTHelpers: Codeunit "GST Helpers";
        TotalGSTAmt: Decimal;
        TotalGSTAmt1: Decimal;
    begin
        Clear(GenJournalLine);
        GLSetup.Get();
        GSTCreditAdjustmentJournal.SetRange("Reverse Charge", true);
        GSTCreditAdjustmentJournal.SetFilter("Nature of Adjustment", '<>%1', GSTCreditAdjustmentJournal."Nature of Adjustment"::" ");
        if GSTCreditAdjustmentJournal.FindSet() then begin
            repeat
                GSTCreditAdjustmentJournal.Validate("Adjustment %");
                GSTCreditAdjustmentJournal.Validate("Adjustment Amount");

                Clear(TempGSTPostingBuffer[1]);
                Clear(TempGSTPostingBuffer[2]);
                TotalGSTAmt := 0;
                TotalGSTAmt1 := 0;

                DetailedGSTLedgerEntry.SetCurrentKey(
                    "Transaction Type",
                    "GST Jurisdiction Type",
                    "Source No.",
                    "Document Type",
                    "Document No.",
                    "Document Line No.",
                    "Posting Date");
                DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
                DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::Application);
                DetailedGSTLedgerEntry.SetRange("GST Jurisdiction Type", GSTCreditAdjustmentJournal."GST Jurisdiction Type");
                DetailedGSTLedgerEntry.SetRange("Source No.", GSTCreditAdjustmentJournal."Vendor No.");
                DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
                DetailedGSTLedgerEntry.SetRange("Document No.", GSTCreditAdjustmentJournal."Document No.");
                DetailedGSTLedgerEntry.SetRange("Document Line No.", GSTCreditAdjustmentJournal."Document Line No.");
                DetailedGSTLedgerEntry.SetRange("Posting Date", GSTCreditAdjustmentJournal."Posting Date");
                if GSTCreditAdjustmentJournal."Nature of Adjustment" in [
                    GSTCreditAdjustmentJournal."Nature of Adjustment"::"Credit Reversal",
                    GSTCreditAdjustmentJournal."Nature of Adjustment"::"Credit Re-Availment"]
                then
                    DetailedGSTLedgerEntry.SetRange("GST Credit", DetailedGSTLedgerEntry."GST Credit"::Availment)
                else
                    if GSTCreditAdjustmentJournal."Nature of Adjustment" in [
                        GSTCreditAdjustmentJournal."Nature of Adjustment"::"Credit Availment",
                        GSTCreditAdjustmentJournal."Nature of Adjustment"::"Reversal of Availment"]
                    then
                        DetailedGSTLedgerEntry.SetRange("GST Credit", DetailedGSTLedgerEntry."GST Credit"::"Non-Availment");
                DetailedGSTLedgerEntry.SetRange(Distributed, false);
                DetailedGSTLedgerEntry.SetRange("Reverse Charge", true);
                DetailedGSTLedgerEntry.SetRange("GST Exempted Goods", false);
                if DetailedGSTLedgerEntry.FindSet() then
                    repeat
                        if IsComponentNonAvailment(DetailedGSTLedgerEntry."Entry No.") then begin
                            TempGSTPostingBuffer[1]."Transaction Type" := TempGSTPostingBuffer[1]."Transaction Type"::Purchase;
                            TempGSTPostingBuffer[1].Type := TempGSTPostingBuffer[1].Type::"G/L Account";
                            TempGSTPostingBuffer[1]."GST Component Code" := DetailedGSTLedgerEntry."GST Component Code";
                            TempGSTPostingBuffer[1]."GST Amount" := Abs(DetailedGSTLedgerEntry."GST Amount");
                            TempGSTPostingBuffer[1]."GST Base Amount" := Abs(DetailedGSTLedgerEntry."GST Base Amount");
                            TempGSTPostingBuffer[1]."Dimension Set ID" := GSTCreditAdjustmentJournal."Dimension Set ID";
                            case GSTCreditAdjustmentJournal."Nature of Adjustment" of
                                GSTCreditAdjustmentJournal."Nature of Adjustment"::"Credit Reversal",
                                GSTCreditAdjustmentJournal."Nature of Adjustment"::"Reversal of Availment":
                                    begin
                                        TempGSTPostingBuffer[1]."Account No." :=
                                          GSTHelpers.GetGSTPayableAccountNo(GSTCreditAdjustmentJournal."Location State Code", DetailedGSTLedgerEntry."GST Component Code");
                                        TempGSTPostingBuffer[1]."GST Amount" :=
                                          Abs(Round((DetailedGSTLedgerEntry."GST Amount" * GSTCreditAdjustmentJournal."Adjustment %") / 100,
                                              GLSetup."Amount Rounding Precision"));
                                        TempGSTPostingBuffer[1]."GST Base Amount" :=
                                          Abs(Round((DetailedGSTLedgerEntry."GST Base Amount" * GSTCreditAdjustmentJournal."Adjustment %") / 100,
                                              GLSetup."Amount Rounding Precision"));
                                        TotalGSTAmt += Abs(TempGSTPostingBuffer[1]."GST Amount");
                                    end;
                                GSTCreditAdjustmentJournal."Nature of Adjustment"::"Credit Re-Availment",
                                GSTCreditAdjustmentJournal."Nature of Adjustment"::"Credit Availment":
                                    begin
                                        TempGSTPostingBuffer[1]."Account No." :=
                                          GSTHelpers.GetGSTReceivableAccountNo(
                                            GSTCreditAdjustmentJournal."Location State Code", DetailedGSTLedgerEntry."GST Component Code");
                                        TempGSTPostingBuffer[1]."GST Amount" :=
                                          -Abs(Round((DetailedGSTLedgerEntry."GST Amount" * GSTCreditAdjustmentJournal."Adjustment %") / 100,
                                              GLSetup."Amount Rounding Precision"));
                                        TempGSTPostingBuffer[1]."GST Base Amount" :=
                                          -Abs(Round((DetailedGSTLedgerEntry."GST Base Amount" * GSTCreditAdjustmentJournal."Adjustment %") / 100,
                                              GLSetup."Amount Rounding Precision"));
                                        TotalGSTAmt += Abs(TempGSTPostingBuffer[1]."GST Amount");
                                    end;
                            end;

                            UpdateGSTPostingBuffer();
                            UpdateDetailedGSTLedgerEntry(
                              GSTCreditAdjustmentJournal."Nature of Adjustment",
                              DetailedGSTLedgerEntry."Entry No.",
                              GSTCreditAdjustmentJournal."Adjustment Posting Date",
                              TempGSTPostingBuffer[1]."GST Amount",
                              GSTCreditAdjustmentJournal."Adjustment %",
                              TempGSTPostingBuffer[1]."GST Base Amount");
                            PostToDetailedCrAdjEntry(DetailedGSTLedgerEntry, GSTCreditAdjustmentJournal);
                        end;
                    until DetailedGSTLedgerEntry.Next() = 0;

                TempGSTPostingBuffer[1]."Transaction Type" := TempGSTPostingBuffer[1]."Transaction Type"::Purchase;
                TempGSTPostingBuffer[1].Type := GSTCreditAdjustmentJournal.Type;
                TempGSTPostingBuffer[1]."Dimension Set ID" := GSTCreditAdjustmentJournal."Dimension Set ID";
                if GSTCreditAdjustmentJournal.Type in [Type::"G/L Account", Type::"Fixed Asset"] then
                    TempGSTPostingBuffer[1]."Account No." := GSTCreditAdjustmentJournal."No."
                else
                    if GSTCreditAdjustmentJournal.Type = Type::Item then begin
                        GeneralPostingSetup.Get(
                            GSTCreditAdjustmentJournal."Gen. Bus. Posting Group",
                            GSTCreditAdjustmentJournal."Gen. Prod. Posting Group");
                        GeneralPostingSetup.TestField("Purch. Account");
                        TempGSTPostingBuffer[1]."Account No." := GeneralPostingSetup."Purch. Account";
                    end;

                TempGSTPostingBuffer[1]."GST Reverse Charge" := GSTCreditAdjustmentJournal."Reverse Charge";
                if GSTCreditAdjustmentJournal."Nature of Adjustment" in [
                    GSTCreditAdjustmentJournal."Nature of Adjustment"::"Credit Reversal",
                    GSTCreditAdjustmentJournal."Nature of Adjustment"::"Reversal of Availment"]
                then begin
                    TotalGSTAmt1 :=
                      -Abs(Round((GSTCreditAdjustmentJournal."Total GST Credit Amount" * GSTCreditAdjustmentJournal."Adjustment %") / 100,
                          GLSetup."Amount Rounding Precision"));
                    TempGSTPostingBuffer[1]."GST Amount" := TotalGSTAmt1 - GETPartialRoundingAmt(TotalGSTAmt, TotalGSTAmt1);
                end else
                    if GSTCreditAdjustmentJournal."Nature of Adjustment" in [
                        GSTCreditAdjustmentJournal."Nature of Adjustment"::"Credit Re-Availment",
                        GSTCreditAdjustmentJournal."Nature of Adjustment"::"Credit Availment"]
                    then begin
                        TotalGSTAmt1 :=
                          Abs(Round(
                              (GSTCreditAdjustmentJournal."Total GST Credit Amount" * GSTCreditAdjustmentJournal."Adjustment %") / 100,
                              GLSetup."Amount Rounding Precision"));
                        TempGSTPostingBuffer[1]."GST Amount" := TotalGSTAmt1 + GETPartialRoundingAmt(TotalGSTAmt, TotalGSTAmt1);
                    end;

                UpdateGSTPostingBuffer();
                if GSTCreditAdjustmentJournal.Type = Type::Item then
                    PostRevaluationEntry(GSTCreditAdjustmentJournal)
            until GSTCreditAdjustmentJournal.Next() = 0;
            NoSeriesManagement.GetNextNo(GetNoSeriesCode(false), GSTCreditAdjustmentJournal."Posting Date", true);
        end;

        Clear(GenJnlPostLine);
        if TempGSTPostingBuffer[1].Find('+') then
            repeat
                if TempGSTPostingBuffer[1].Type = TempGSTPostingBuffer[1].Type::"Fixed Asset" then
                    PostGenJnlLine(
                      GenJournalLine, TempGSTPostingBuffer[1]."Account No.", '',
                      GSTCreditAdjustmentJournal."Adjust Document No.", TempGSTPostingBuffer[1]."GST Amount", GSTCreditAdjustmentJournal."Adjustment Posting Date",
                      GenJournalLine."Document Type"::Invoice, GSTCreditAdjustmentJournal."GST Jurisdiction Type", false, true,
                      TempGSTPostingBuffer[1]."Dimension Set ID")
                else
                    PostGenJnlLine(
                      GenJournalLine, TempGSTPostingBuffer[1]."Account No.", '',
                      GSTCreditAdjustmentJournal."Adjust Document No.", TempGSTPostingBuffer[1]."GST Amount", GSTCreditAdjustmentJournal."Adjustment Posting Date",
                      GenJournalLine."Document Type"::Invoice, GSTCreditAdjustmentJournal."GST Jurisdiction Type", false, false,
                      TempGSTPostingBuffer[1]."Dimension Set ID");
                EntryNo := GenJnlPostLine.RunWithCheck(GenJournalLine);
            until TempGSTPostingBuffer[1].Next(-1) = 0;
    end;

    local procedure UpdateGSTPostingBuffer()
    begin
        DimensionManagement.UpdateGlobalDimFromDimSetID(
            TempGSTPostingBuffer[1]."Dimension Set ID",
            TempGSTPostingBuffer[1]."Global Dimension 1 Code",
            TempGSTPostingBuffer[1]."Global Dimension 2 Code");

        TempGSTPostingBuffer[2] := TempGSTPostingBuffer[1];
        if TempGSTPostingBuffer[2].Find() then begin
            TempGSTPostingBuffer[2]."GST Base Amount" += TempGSTPostingBuffer[1]."GST Base Amount";
            TempGSTPostingBuffer[2]."GST Amount" += TempGSTPostingBuffer[1]."GST Amount";
            TempGSTPostingBuffer[2].Modify();
        end else
            TempGSTPostingBuffer[1].Insert();
    end;

    local procedure UpdateDetailedGSTLedgerEntry(
        TypeOfAdjustment: Enum "Credit Adjustment Type";
                              EntryNo: Integer;
                              PostingDate: Date;
                              CAJAmt: Decimal;
                              CAJPerc: Decimal;
                              CAJBaseAmt: Decimal)
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        DetailedGSTLedgerEntry.Get(EntryNo);
        DetailedGSTLedgerEntry."Credit Adjustment Type" := TypeOfAdjustment;
        UpdateDetGSTLedgPartialAmt(DetailedGSTLedgerEntry, TypeOfAdjustment, CAJAmt, CAJPerc, CAJBaseAmt);
        DetailedGSTLedgerEntry.Modify();

        if DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.") then begin
            DetailedGSTLedgerEntryInfo."Last Credit Adjusted Date" := PostingDate;
            DetailedGSTLedgerEntryInfo.Modify();
        end;
    end;

    local procedure UpdateDetGSTLedgPartialAmt(
        var DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        TypeOfAdjustment: Enum "Credit Adjustment Type";
                              CAJAmt: Decimal;
                              CAJPerc: Decimal;
                              CAJBaseAmt: Decimal)
    begin
        if TypeOfAdjustment in [TypeOfAdjustment::"Credit Reversal", TypeOfAdjustment::"Credit Availment"] then begin
            DetailedGSTLedgerEntry."CAJ Base Amount" := DetailedGSTLedgerEntry."CAJ Base Amount" + Abs(CAJBaseAmt);
            DetailedGSTLedgerEntry."CAJ Amount" := DetailedGSTLedgerEntry."CAJ Amount" + Abs(CAJAmt);
            DetailedGSTLedgerEntry."CAJ %" := DetailedGSTLedgerEntry."CAJ %" + CAJPerc;
        end;

        if TypeOfAdjustment in [TypeOfAdjustment::"Credit Re-Availment", TypeOfAdjustment::"Reversal of Availment"] then begin
            DetailedGSTLedgerEntry."CAJ Base Amount" := DetailedGSTLedgerEntry."CAJ Base Amount" - Abs(CAJBaseAmt);
            DetailedGSTLedgerEntry."CAJ Amount" := DetailedGSTLedgerEntry."CAJ Amount" - Abs(CAJAmt);
            DetailedGSTLedgerEntry."CAJ %" := DetailedGSTLedgerEntry."CAJ %" - CAJPerc;
        end;

        if TypeOfAdjustment in [TypeOfAdjustment::"Permanent Reversal"] then begin
            DetailedGSTLedgerEntry."CAJ Amount Permanent Reversal" := DetailedGSTLedgerEntry."CAJ Amount Permanent Reversal" + Abs(CAJAmt);
            DetailedGSTLedgerEntry."CAJ % Permanent Reversal" := DetailedGSTLedgerEntry."CAJ % Permanent Reversal" + CAJPerc;
        end;

        DetailedGSTLedgerEntry."Remaining CAJ Adj. Base Amt" :=
          Abs(Abs(DetailedGSTLedgerEntry."GST Base Amount") - Abs(DetailedGSTLedgerEntry."CAJ Base Amount"));
        DetailedGSTLedgerEntry."Remaining CAJ Adj. Amt" :=
          Abs(Abs(DetailedGSTLedgerEntry."GST Amount") - Abs(DetailedGSTLedgerEntry."CAJ Amount"));
    end;

    local procedure PostGenJnlLine(
        var GenJournalLine: Record "Gen. Journal Line";
        RecAccountNo: Code[20];
        IntAccountNo: Code[20];
        DocumentNo: Code[20];
        GSTAmt: Decimal;
        PostingDate: Date;
        DocumentType: Enum "Gen. Journal Document Type";
                          GSTJurisdictionType: Enum "GST Jurisdiction Type";
                          Liability: Boolean;
                          FixedAsset: Boolean;
                          DimensionSetID: Integer)
    begin
        GenJournalLine.Init();
        GenJournalLine."Line No." += 10000;
        GenJournalLine."Document Type" := DocumentType;
        GenJournalLine."Document No." := DocumentNo;

        if FixedAsset then begin
            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Fixed Asset";
            GenJournalLine.Validate("Account No.", RecAccountNo);
        end else
            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
        GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
        GenJournalLine."Posting Date" := PostingDate;

        if not FixedAsset then
            GenJournalLine."Account No." := RecAccountNo;

        if FixedAsset then
            GenJournalLine.Validate("FA Posting Type", GenJournalLine."FA Posting Type"::"Acquisition Cost");

        GenJournalLine."Bal. Account No." := IntAccountNo;

        if Liability then
            GenJournalLine."Source Code" := GetLiabilitySourceCode()
        else
            GenJournalLine."Source Code" := GetCreditAdjustmentSourceCode();

        GenJournalLine."GST Jurisdiction Type" := GSTJurisdictionType;
        GenJournalLine."System-Created Entry" := true;

        if GenJournalLine."Document Type" = GenJournalLine."Document Type"::Invoice then
            GenJournalLine.Amount := -GSTAmt
        else
            GenJournalLine.Amount := GSTAmt;

        GenJournalLine."Dimension Set ID" := DimensionSetID;
        DimensionManagement.UpdateGlobalDimFromDimSetID(
            GenJournalLine."Dimension Set ID",
            GenJournalLine."Shortcut Dimension 1 Code",
            GenJournalLine."Shortcut Dimension 2 Code");
    end;

    local procedure GetLiabilitySourceCode(): Code[10]
    var
        SourceSetup: Record "Source Code Setup";
    begin
        SourceSetup.Get();
        SourceSetup.TestField("GST Liability Adjustment");
        exit(SourceSetup."GST Liability Adjustment");
    end;

    local procedure PostToDetailedCrAdjEntry(
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTCreditAdjustmentJournal: Record "GST Credit Adjustment Journal")
    var
        DetailedCrAdjstmntEntry: Record "Detailed Cr. Adjstmnt. Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        GSTHelpers: Codeunit "GST Helpers";
    begin
        GetDetailedGSTLedgerEnfo(DetailedGSTLedgerEntry."Entry No.", DetailedGSTLedgerEntryInfo);

        DetailedCrAdjstmntEntry.Init();
        DetailedCrAdjstmntEntry."Posting Date" := GSTCreditAdjustmentJournal."Adjustment Posting Date";
        DetailedCrAdjstmntEntry."Credit Adjustment Type" := GSTCreditAdjustmentJournal."Nature of Adjustment";
        DetailedCrAdjstmntEntry."Document No." := GSTCreditAdjustmentJournal."Adjust Document No.";
        DetailedCrAdjstmntEntry."Adjusted Doc. Entry No." := DetailedGSTLedgerEntry."Entry No.";
        DetailedCrAdjstmntEntry."Adjusted Doc. Entry Type" := DetailedGSTLedgerEntry."Entry Type";
        DetailedCrAdjstmntEntry."Adjusted Doc. Transaction Type" := DetailedGSTLedgerEntry."Transaction Type";
        DetailedCrAdjstmntEntry."Adjusted Doc. Type" := DetailedGSTLedgerEntry."Document Type";
        DetailedCrAdjstmntEntry."Adjusted Doc. No." := DetailedGSTLedgerEntry."Document No.";
        DetailedCrAdjstmntEntry."Adjusted Doc. Line No." := DetailedGSTLedgerEntry."Document Line No.";
        DetailedCrAdjstmntEntry."Adjusted Doc. Posting Date" := DetailedGSTLedgerEntry."Posting Date";
        DetailedCrAdjstmntEntry.Type := DetailedGSTLedgerEntry.Type;
        DetailedCrAdjstmntEntry."No." := DetailedGSTLedgerEntry."No.";
        DetailedCrAdjstmntEntry."Product Type" := DetailedGSTLedgerEntry."Product Type";
        DetailedCrAdjstmntEntry."Source Type" := DetailedGSTLedgerEntry."Source Type";
        DetailedCrAdjstmntEntry."Source No." := DetailedGSTLedgerEntry."Source No.";
        DetailedCrAdjstmntEntry."HSN/SAC Code" := DetailedGSTLedgerEntry."HSN/SAC Code";
        DetailedCrAdjstmntEntry."GST Component Code" := DetailedGSTLedgerEntry."GST Component Code";
        DetailedCrAdjstmntEntry."GST Group Code" := DetailedGSTLedgerEntry."GST Group Code";
        DetailedCrAdjstmntEntry."GST Jurisdiction Type" := DetailedGSTLedgerEntry."GST Jurisdiction Type";
        if GSTCreditAdjustmentJournal."Reverse Charge" then begin
            DetailedCrAdjstmntEntry."GST Base Amount" :=
                Abs((DetailedGSTLedgerEntry."GST Base Amount" * GSTCreditAdjustmentJournal."Adjustment %") / 100);
            DetailedCrAdjstmntEntry."GST Amount" :=
                Abs((DetailedGSTLedgerEntry."GST Amount" * GSTCreditAdjustmentJournal."Adjustment %") / 100);
            DetailedCrAdjstmntEntry."Adjustment Amount" :=
                Abs((DetailedGSTLedgerEntry."GST Amount" * GSTCreditAdjustmentJournal."Adjustment %") / 100);
        end else begin
            DetailedCrAdjstmntEntry."GST Base Amount" :=
                (DetailedGSTLedgerEntry."GST Base Amount" * GSTCreditAdjustmentJournal."Adjustment %") / 100;
            DetailedCrAdjstmntEntry."GST Amount" :=
                (DetailedGSTLedgerEntry."GST Amount" * GSTCreditAdjustmentJournal."Adjustment %") / 100;
            DetailedCrAdjstmntEntry."Adjustment Amount" :=
                (DetailedGSTLedgerEntry."GST Amount" * GSTCreditAdjustmentJournal."Adjustment %") / 100;
        end;

        DetailedCrAdjstmntEntry."GST %" := DetailedGSTLedgerEntry."GST %";

        if DetailedGSTLedgerEntry."GST Amount" <> 0 then
            DetailedCrAdjstmntEntry."Adjustment %" := GSTCreditAdjustmentJournal."Adjustment %";

        DetailedCrAdjstmntEntry."External Document No." := DetailedGSTLedgerEntry."External Document No.";
        DetailedCrAdjstmntEntry."Location State Code" := DetailedGSTLedgerEntryInfo."Location State Code";

        case GSTCreditAdjustmentJournal."Nature of Adjustment" of
            GSTCreditAdjustmentJournal."Nature of Adjustment"::"Credit Reversal",
            GSTCreditAdjustmentJournal."Nature of Adjustment"::"Reversal of Availment":
                begin
                    if GSTCreditAdjustmentJournal."Reverse Charge" then begin
                        DetailedCrAdjstmntEntry."G/L Account No." :=
                          GSTHelpers.GetGSTPayableAccountNo(
                              DetailedCrAdjstmntEntry."Location State Code",
                              DetailedGSTLedgerEntry."GST Component Code");
                        DetailedCrAdjstmntEntry."GST Credit" := DetailedCrAdjstmntEntry."GST Credit"::"Non-Availment";
                    end else
                        DetailedCrAdjstmntEntry."G/L Account No." :=
                          GSTHelpers.GetGSTMismatchAccountNo(
                              DetailedCrAdjstmntEntry."Location State Code",
                              DetailedGSTLedgerEntry."GST Component Code");
                    DetailedCrAdjstmntEntry."Liable to Pay" := true
                end;
            GSTCreditAdjustmentJournal."Nature of Adjustment"::"Credit Re-Availment",
            GSTCreditAdjustmentJournal."Nature of Adjustment"::"Credit Availment":
                begin
                    if GSTCreditAdjustmentJournal."Reverse Charge" then begin
                        DetailedCrAdjstmntEntry."G/L Account No." :=
                          GSTHelpers.GetGSTReceivableAccountNo(
                              DetailedCrAdjstmntEntry."Location State Code",
                              DetailedGSTLedgerEntry."GST Component Code");
                        DetailedCrAdjstmntEntry.Positive := true;
                        DetailedCrAdjstmntEntry."GST Credit" := DetailedCrAdjstmntEntry."GST Credit"::Availment;
                    end else
                        if DetailedGSTLedgerEntry."Input Service Distribution" then
                            DetailedCrAdjstmntEntry."G/L Account No." :=
                              GSTHelpers.GetGSTReceivableDistAccountNo(
                                  DetailedCrAdjstmntEntry."Location State Code",
                                  DetailedGSTLedgerEntry."GST Component Code")
                        else
                            DetailedCrAdjstmntEntry."G/L Account No." :=
                              GSTHelpers.GetGSTReceivableAccountNo(
                                  DetailedCrAdjstmntEntry."Location State Code",
                                  DetailedGSTLedgerEntry."GST Component Code");
                    DetailedCrAdjstmntEntry."Credit Availed" := true;
                end;
            GSTCreditAdjustmentJournal."Nature of Adjustment"::"Permanent Reversal":
                DetailedCrAdjstmntEntry."G/L Account No." :=
                  GSTHelpers.GetGSTExpenseAccountNo(
                      DetailedCrAdjstmntEntry."Location State Code",
                      DetailedGSTLedgerEntry."GST Component Code")
        end;

        DetailedCrAdjstmntEntry."User ID" := CopyStr(UserId(), 1, StrLen(UserId()));
        if not DetailedGSTLedgerEntry."Reverse Charge" then begin
            DetailedCrAdjstmntEntry.Positive := DetailedGSTLedgerEntryInfo.Positive;
            DetailedCrAdjstmntEntry."GST Credit" := DetailedGSTLedgerEntry."GST Credit";
        end;

        DetailedCrAdjstmntEntry."Buyer/Seller State Code" := DetailedGSTLedgerEntryInfo."Buyer/Seller State Code";
        DetailedCrAdjstmntEntry."Location  Reg. No." := DetailedGSTLedgerEntry."Location  Reg. No.";
        DetailedCrAdjstmntEntry."Buyer/Seller Reg. No." := DetailedGSTLedgerEntry."Buyer/Seller Reg. No.";
        DetailedCrAdjstmntEntry."GST Group Type" := DetailedGSTLedgerEntry."GST Group Type";
        DetailedCrAdjstmntEntry."Currency Code" := DetailedGSTLedgerEntry."Currency Code";
        DetailedCrAdjstmntEntry."Currency Factor" := DetailedGSTLedgerEntry."Currency Factor";
        DetailedCrAdjstmntEntry."GST Rounding Precision" := DetailedGSTLedgerEntry."GST Rounding Precision";
        DetailedCrAdjstmntEntry."GST Rounding Type" := DetailedGSTLedgerEntry."GST Rounding Type";
        DetailedCrAdjstmntEntry."Location Code" := DetailedGSTLedgerEntry."Location Code";
        DetailedCrAdjstmntEntry."GST Vendor Type" := DetailedGSTLedgerEntry."GST Vendor Type";
        DetailedCrAdjstmntEntry.Cess := DetailedGSTLedgerEntryInfo.Cess;
        DetailedCrAdjstmntEntry."Input Service Distribution" := DetailedGSTLedgerEntry."Input Service Distribution";
        DetailedCrAdjstmntEntry."Reverse Charge" := DetailedGSTLedgerEntry."Reverse Charge";
        DetailedCrAdjstmntEntry."Rem. Amt. Updated in DGLE" := true;
        DetailedCrAdjstmntEntry.Insert();
    end;

    local procedure GETPartialRoundingAmt(TotalGSTAmt: Decimal; TotalGSTAmt1: Decimal): Decimal
    var
        RoundOffAmt: Decimal;
    begin
        RoundOffAmt := Abs(TotalGSTAmt) - Abs(TotalGSTAmt1);
        exit(RoundOffAmt);
    end;

    local procedure PostRevaluationEntry(GSTCreditAdjustmentJournal: Record "GST Credit Adjustment Journal")
    var
        SourceSetup: Record "Source Code Setup";
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalLine2: Record "Item Journal Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        Ctr: Integer;
    begin
        ValueEntry.Reset();
        ValueEntry.SetRange("Document No.", GSTCreditAdjustmentJournal."Document No.");
        ValueEntry.SetRange("Document Line No.", GSTCreditAdjustmentJournal."Document Line No.");
        ValueEntry.SetRange("Item No.", GSTCreditAdjustmentJournal."No.");
        if ValueEntry.FindFirst() then begin
            ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.");
            if GSTCreditAdjustmentJournal."Total GST Amount" <> 0 then begin
                SourceSetup.Get();

                ItemJournalLine.Init();
                ItemJournalLine.Validate("Posting Date", GSTCreditAdjustmentJournal."Adjustment Posting Date");
                ItemJournalLine."Document Date" := GSTCreditAdjustmentJournal."Adjustment Posting Date";
                ItemJournalLine.Validate("Document No.", GSTCreditAdjustmentJournal."Adjust Document No.");
                ItemJournalLine."Document Line No." := GSTCreditAdjustmentJournal."Document Line No.";
                ItemJournalLine."External Document No." := CopyStr(GSTCreditAdjustmentJournal."External Document No.", 1, MaxStrLen(ItemJournalLine."External Document No."));
                ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::Purchase);
                ItemJournalLine."Value Entry Type" := ItemJournalLine."Value Entry Type"::Revaluation;
                ItemJournalLine.Validate("Item No.", GSTCreditAdjustmentJournal."No.");
                ItemJournalLine."Source Type" := ItemJournalLine."Source Type"::Vendor;
                ItemJournalLine."Source No." := GSTCreditAdjustmentJournal."Vendor No.";
                ItemJournalLine."Gen. Bus. Posting Group" := GSTCreditAdjustmentJournal."Gen. Bus. Posting Group";
                ItemJournalLine."Gen. Prod. Posting Group" := GSTCreditAdjustmentJournal."Gen. Prod. Posting Group";
                ItemJournalLine."Source Code" := SourceSetup."Revaluation Journal";
                ItemJournalLine.Validate("Applies-to Entry", ItemLedgerEntry."Entry No.");
                ItemJournalLine."Dimension Set ID" := GSTCreditAdjustmentJournal."Dimension Set ID";
                if GSTCreditAdjustmentJournal."Nature of Adjustment" in
                   [GSTCreditAdjustmentJournal."Nature of Adjustment"::"Credit Reversal",
                    GSTCreditAdjustmentJournal."Nature of Adjustment"::"Reversal of Availment"]
                then
                    ItemJournalLine.Validate(
                        "Unit Cost (Revalued)",
                        (ItemJournalLine."Unit Cost (Revalued)" + GSTCreditAdjustmentJournal."Total GST Amount"))
                else
                    if GSTCreditAdjustmentJournal."Nature of Adjustment" in
                       [GSTCreditAdjustmentJournal."Nature of Adjustment"::"Credit Re-Availment",
                        GSTCreditAdjustmentJournal."Nature of Adjustment"::"Credit Availment"]
                    then
                        ItemJournalLine.Validate(
                            "Unit Cost (Revalued)",
                            (ItemJournalLine."Unit Cost (Revalued)" - GSTCreditAdjustmentJournal."Total GST Amount"));

                Ctr := ItemJournalLine2."Line No." + 1;

                ItemJournalLine2.Init();
                ItemJournalLine2.TransferFields(ItemJournalLine);
                ItemJournalLine2."Line No." := Ctr;
                ItemJnlPostLine.Run(ItemJournalLine2);
            end;
        end;
    end;

    local procedure AllocateGSTWithPayment(DocumentNo: Code[20]; VendNo: Code[20]; RemainingAmount: Decimal)
    var
        GSTLiabilityBuffer: Record "GST Liability Buffer";
        InvoiceBaseAmount: Decimal;
        GSTGroupCode: Code[20];
        AppliedAmount: Decimal;
        TotalInvoiceAmount: Decimal;
        Sign: Integer;
        GSTExempted: Boolean;
        IsHandled: Boolean;
    begin
        GSTLiabilityBuffer.SetRange("Transaction Type", GSTLiabilityBuffer."Transaction Type"::Purchase);
        GSTLiabilityBuffer.SetRange("Account No.", VendNo);
        GSTLiabilityBuffer.SetRange("Original Document Type", GSTLiabilityBuffer."Original Document Type"::Invoice);
        GSTLiabilityBuffer.SetRange("Original Document No.", DocumentNo);
        if GSTLiabilityBuffer.FindSet() then begin
            Sign := RemainingAmount / Abs(RemainingAmount);
            repeat
                if (GSTGroupCode <> GSTLiabilityBuffer."GST Group Code") or (GSTExempted <> GSTLiabilityBuffer.Exempted) then begin
                    Clear(InvoiceBaseAmount);
                    Clear(TotalInvoiceAmount);
                    GetInvoiceBaseAmount(GSTLiabilityBuffer, InvoiceBaseAmount);
                    TotalInvoiceAmount := InvoiceBaseAmount;
                    RemainingAmount := (Abs(RemainingAmount) - Abs(AppliedAmount)) * Sign;
                end;

                OnBeforeAllocateGstAppliedAmounts(TotalInvoiceAmount, RemainingAmount, GSTLiabilityBuffer, IsHandled);
                if not IsHandled then
                    if Abs(TotalInvoiceAmount) > Abs(RemainingAmount) then begin
                        GSTLiabilityBuffer."Applied Base Amount" := Round(GSTLiabilityBuffer."GST Base Amount" * Abs(RemainingAmount) / TotalInvoiceAmount, 0.01);
                        GSTLiabilityBuffer."Applied Amount" := GSTLiabilityBuffer."GST Amount" * Abs(RemainingAmount) / TotalInvoiceAmount;
                        if GSTLiabilityBuffer."GST Credit" = "GST Credit"::Availment then
                            GSTLiabilityBuffer."Credit Amount" := GSTLiabilityBuffer."Applied Amount"
                    end else begin
                        GSTLiabilityBuffer."Applied Base Amount" :=
                          Round(GetInvoiceGSTComponentWise(GSTLiabilityBuffer, GSTLiabilityBuffer."Original Document Type"::Invoice, DocumentNo, true), 0.01);
                        GSTLiabilityBuffer."Applied Amount" := GSTLiabilityBuffer."GST Amount";
                        if GSTLiabilityBuffer."GST Credit" = "GST Credit"::Availment then
                            GSTLiabilityBuffer."Credit Amount" := GSTLiabilityBuffer."Applied Amount";
                    end;

                OnAfterAllocateGstAppliedAmount(TotalInvoiceAmount, RemainingAmount, GSTLiabilityBuffer, DocumentNo);
                GSTLiabilityBuffer.Modify(true);
                GSTGroupCode := GSTLiabilityBuffer."GST Group Code";
                GSTExempted := GSTLiabilityBuffer.Exempted;
                Clear(AppliedAmount);
                AppliedAmount := GSTLiabilityBuffer."Applied Base Amount";
            until GSTLiabilityBuffer.Next() = 0;
        end;
    end;

    local procedure FillGSTCreditLiability(
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        AdjDocNo: Code[20];
        AdjPostingDate: Date;
        NatureOfAdj: Enum "Cr Libty Adjustment Type")
    var
        GSTLiabilityBuffer: array[2] of Record "GST Liability Buffer";
        GSTLiabilityAdjustment: Record "GST Liability Adjustment";
        DocumentNo: Code[20];
        TotalGSTAmount: Decimal;
        TotalCreditAmount: Decimal;
    begin
        GSTLiabilityBuffer[1].SetRange("Original Document No.", VendorLedgerEntry."Document No.");
        GSTLiabilityBuffer[1].SetFilter("Applied Amount", '>%1', 0);
        if GSTLiabilityBuffer[1].FindSet() then
            repeat
                if DocumentNo <> GSTLiabilityBuffer[1]."Original Document No." then begin
                    TotalGSTAmount := 0;
                    TotalCreditAmount := 0;
                    DocumentNo := GSTLiabilityBuffer[1]."Original Document No.";

                    GSTLiabilityBuffer[2].CopyFilters(GSTLiabilityBuffer[1]);
                    GSTLiabilityBuffer[2].SetRange("Original Document No.", GSTLiabilityBuffer[1]."Original Document No.");
                    if GSTLiabilityBuffer[2].FindSet() then
                        repeat
                            if GSTLiabilityBuffer[2]."GST Credit" = GSTLiabilityBuffer[2]."GST Credit"::Availment then
                                TotalCreditAmount += GSTLiabilityBuffer[2]."Credit Amount";
                            TotalGSTAmount += GSTLiabilityBuffer[2]."Applied Amount";
                        until GSTLiabilityBuffer[2].Next() = 0;

                    GSTLiabilityAdjustment.Init();
                    GSTLiabilityAdjustment."Journal Doc. No." := AdjDocNo;
                    GSTLiabilityAdjustment."GST Registration No." := VendorLedgerEntry."Location GST Reg. No.";
                    GSTLiabilityAdjustment."Vendor No." := VendorLedgerEntry."Vendor No.";
                    GSTLiabilityAdjustment."Document Type" := GSTLiabilityAdjustment."Document Type"::Invoice;
                    GSTLiabilityAdjustment."Document No." := VendorLedgerEntry."Document No.";
                    GSTLiabilityAdjustment."Document Posting Date" := VendorLedgerEntry."Posting Date";
                    GSTLiabilityAdjustment."External Document No." := VendorLedgerEntry."External Document No.";
                    GSTLiabilityAdjustment."Location State Code" := VendorLedgerEntry."Location State Code";
                    GSTLiabilityAdjustment."GST Jurisdiction Type" := GSTLiabilityBuffer[2]."GST Jurisdiction Type";
                    GSTLiabilityAdjustment."Adjustment Posting Date" := AdjPostingDate;
                    GSTLiabilityAdjustment."Adjustment Amount" := TotalGSTAmount;
                    GSTLiabilityAdjustment."Total GST Amount" := TotalGSTAmount;
                    GSTLiabilityAdjustment."Total GST Credit Amount" := TotalCreditAmount;
                    GSTLiabilityAdjustment."Total GST Liability Amount" := TotalGSTAmount;
                    GSTLiabilityAdjustment."Nature of Adjustment" := NatureOfAdj;
                    GSTLiabilityAdjustment."Select Nature of Adjustment" := NatureOfAdj;
                    GSTLiabilityAdjustment."GST Group Code" := GSTLiabilityBuffer[2]."GST Group Code";
                    GSTLiabilityAdjustment.Insert(true);
                end;
            until GSTLiabilityBuffer[1].Next() = 0;
    end;

    local procedure FillGSTCreditLiabilityReverse(
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        AdjDocNo: Code[20];
        AdjPostingDate: Date;
        NatureOfAdj: Enum "Cr Libty Adjustment Type")
    var
        GSTLiabilityBuffer: array[2] of Record "GST Liability Buffer";
        GSTLiabilityAdjustment: Record "GST Liability Adjustment";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        DocumentNo: Code[20];
        TotalGSTAmount: Decimal;
        TotalCreditAmount: Decimal;
    begin
        GetDetailedGSTLedgerEnfo(DetailedGSTLedgerEntry."Entry No.", DetailedGSTLedgerEntryInfo);

        GSTLiabilityBuffer[1].SetRange("Original Document No.", DetailedGSTLedgerEntry."Document No.");
        if GSTLiabilityBuffer[1].FindSet() then
            repeat
                if DocumentNo <> GSTLiabilityBuffer[1]."Original Document No." then begin
                    TotalGSTAmount := 0;
                    TotalCreditAmount := 0;
                    DocumentNo := GSTLiabilityBuffer[1]."Original Document No.";

                    GSTLiabilityBuffer[2].CopyFilters(GSTLiabilityBuffer[1]);
                    GSTLiabilityBuffer[2].SetRange("Original Document No.", GSTLiabilityBuffer[1]."Original Document No.");
                    if GSTLiabilityBuffer[2].FindSet() then
                        repeat
                            if GSTLiabilityBuffer[2]."GST Credit" = GSTLiabilityBuffer[2]."GST Credit"::Availment then
                                TotalCreditAmount += GSTLiabilityBuffer[2]."Credit Amount";
                            TotalGSTAmount += GSTLiabilityBuffer[2]."Applied Amount";
                        until GSTLiabilityBuffer[2].Next() = 0;

                    if TotalGSTAmount = 0 then
                        exit;

                    GSTLiabilityAdjustment.Init();
                    GSTLiabilityAdjustment."Journal Doc. No." := AdjDocNo;
                    GSTLiabilityAdjustment."GST Registration No." := DetailedGSTLedgerEntry."Location  Reg. No.";
                    GSTLiabilityAdjustment."Vendor No." := DetailedGSTLedgerEntry."Source No.";
                    GSTLiabilityAdjustment."Document Type" := GSTLiabilityAdjustment."Document Type"::Invoice;
                    GSTLiabilityAdjustment."Document No." := DetailedGSTLedgerEntry."Document No.";
                    GSTLiabilityAdjustment."Document Posting Date" := DetailedGSTLedgerEntry."Posting Date";
                    GSTLiabilityAdjustment."External Document No." := DetailedGSTLedgerEntry."External Document No.";
                    GSTLiabilityAdjustment."Location State Code" := DetailedGSTLedgerEntryInfo."Location State Code";
                    GSTLiabilityAdjustment."GST Jurisdiction Type" := GSTLiabilityBuffer[2]."GST Jurisdiction Type";
                    GSTLiabilityAdjustment."Adjustment Posting Date" := AdjPostingDate;
                    GSTLiabilityAdjustment."Adjustment Amount" := TotalGSTAmount;
                    GSTLiabilityAdjustment."Total GST Amount" := TotalGSTAmount;
                    GSTLiabilityAdjustment."Total GST Credit Amount" := TotalCreditAmount;
                    GSTLiabilityAdjustment."Total GST Liability Amount" := TotalGSTAmount;
                    GSTLiabilityAdjustment."Nature of Adjustment" := NatureOfAdj;
                    GSTLiabilityAdjustment."Select Nature of Adjustment" := NatureOfAdj;
                    GSTLiabilityAdjustment."GST Group Code" := GSTLiabilityBuffer[2]."GST Group Code";
                    GSTLiabilityAdjustment.Insert(true);
                end;
            until GSTLiabilityBuffer[1].Next() = 0;
    end;

    local procedure GetInvoiceBaseAmount(
        var GSTLiabilityBuffer: Record "GST Liability Buffer";
        var GSTBaseAmount: Decimal)
    var
        GSTLiabilityBuffer2: Record "GST Liability Buffer";
    begin
        GSTLiabilityBuffer2.SetRange("Transaction Type", GSTLiabilityBuffer."Transaction Type");
        GSTLiabilityBuffer2.SetRange("Account No.", GSTLiabilityBuffer."Account No.");
        GSTLiabilityBuffer2.SetRange("Original Document Type", GSTLiabilityBuffer."Original Document Type");
        GSTLiabilityBuffer2.SetRange("Original Document No.", GSTLiabilityBuffer."Original Document No.");
        GSTLiabilityBuffer2.SetRange("GST Group Code", GSTLiabilityBuffer."GST Group Code");
        GSTLiabilityBuffer2.SetRange(Exempted, GSTLiabilityBuffer.Exempted);
        GSTLiabilityBuffer2.SetFilter("GST Base Amount", '<>%1', 0);
        if GSTLiabilityBuffer2.FindFirst() then
            GSTBaseAmount := GSTLiabilityBuffer2."GST Base Amount";
    end;

    local procedure GetInvoiceGSTComponentWise(
        var GSTLiabilityBuffer: Record "GST Liability Buffer";
        DocumentType: Enum "Current Doc. Type";
                          DocumentNo: Code[20];
                          Base: Boolean): Decimal
    var
        GSTLiabilityBuffer2: Record "GST Liability Buffer";
    begin
        GSTLiabilityBuffer2.SetRange("Transaction Type", GSTLiabilityBuffer."Transaction Type");
        GSTLiabilityBuffer2.SetRange("Account No.", GSTLiabilityBuffer."Account No.");
        GSTLiabilityBuffer2.SetRange("Original Document Type", DocumentType);
        GSTLiabilityBuffer2.SetRange("Original Document No.", DocumentNo);
        GSTLiabilityBuffer2.SetRange("GST Component Code", GSTLiabilityBuffer."GST Component Code");
        GSTLiabilityBuffer2.SetRange("GST Group Code", GSTLiabilityBuffer."GST Group Code");
        GSTLiabilityBuffer2.SetRange(Exempted, GSTLiabilityBuffer.Exempted);
        if GSTLiabilityBuffer2.FindFirst() then begin
            if Base then
                exit(GSTLiabilityBuffer2."GST Base Amount");
            exit(GSTLiabilityBuffer2."GST Amount");
        end;
    end;

    local procedure GetAppliedAmount(
        RemainingBase: Decimal;
        RemainingAmount: Decimal;
        DGSTBase: Decimal;
        DGSTAmount: Decimal;
        var AppliedBase: Decimal;
        var AppliedAmount: Decimal)
    begin
        if RemainingBase >= DGSTBase then begin
            AppliedBase := DGSTBase;
            AppliedAmount := DGSTAmount;
        end else begin
            AppliedBase := RemainingBase;
            AppliedAmount := RemainingAmount;
        end;
    end;

    local procedure FillGSTPostingBufferWithApplication(
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        AppliedBaseAmount: Decimal;
        AppliedAmount: Decimal;
        DimensionSetID: Integer)
    var
        GSTBaseValidation: Codeunit "GST Base Validation";
    begin
        TempGSTPostingBuffer1[1]."Transaction Type" := TempGSTPostingBuffer1[1]."Transaction Type"::Purchase;
        TempGSTPostingBuffer1[1].Type := DetailedGSTLedgerEntry.Type;
        TempGSTPostingBuffer1[1]."Gen. Bus. Posting Group" := '';
        TempGSTPostingBuffer1[1]."Gen. Prod. Posting Group" := '';
        TempGSTPostingBuffer1[1]."GST Component Code" := DetailedGSTLedgerEntry."GST Component Code";
        TempGSTPostingBuffer1[1]."GST Reverse Charge" := DetailedGSTLedgerEntry."Reverse Charge";
        TempGSTPostingBuffer1[1]."GST Group Code" := '';
        TempGSTPostingBuffer1[1].Availment := DetailedGSTLedgerEntry."GST Credit" = DetailedGSTLedgerEntry."GST Credit"::Availment;
        TempGSTPostingBuffer1[1]."GST Group Type" := TempGSTPostingBuffer1[1]."GST Group Type"::Service;
        TempGSTPostingBuffer1[1]."GST Base Amount" := GSTBaseValidation.RoundGSTPrecisionThroughTaxComponent(DetailedGSTLedgerEntry."GST Component Code", AppliedBaseAmount);
        TempGSTPostingBuffer1[1]."GST Amount" := GSTBaseValidation.RoundGSTPrecisionThroughTaxComponent(DetailedGSTLedgerEntry."GST Component Code", AppliedAmount);
        TempGSTPostingBuffer1[1]."GST %" := DetailedGSTLedgerEntry."GST %";
        TempGSTPostingBuffer1[1]."Normal Payment" := DetailedGSTLedgerEntry."Payment Type" = "Payment Type"::Normal;
        TempGSTPostingBuffer1[1]."Dimension Set ID" := DimensionSetID;

        UpdateGSTPostingBufferWithApplication();
    end;

    local procedure PostCreditAdjustJnl(
        GSTLiabilityBuffer: Record "GST Liability Buffer";
        GSTLiabilityAdjustment: Record "GST Liability Adjustment";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        AppliedBaseAmount: Decimal;
        AppliedAmount: Decimal): Boolean
    var
        PostedGSTLiabilityAdj: Record "Posted GST Liability Adj.";
        PostedGSTLiabilityAdj1: Record "Posted GST Liability Adj.";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        EntryNo: Integer;
    begin
        if PostedGSTLiabilityAdj1.FindLast() then
            EntryNo := PostedGSTLiabilityAdj1."Entry No." + 1
        else
            EntryNo := 1;

        GetDetailedGSTLedgerEnfo(DetailedGSTLedgerEntry."Entry No.", DetailedGSTLedgerEntryInfo);
        if AppliedBaseAmount <> 0 then begin
            PostedGSTLiabilityAdj.Init();
            PostedGSTLiabilityAdj."Entry No." := EntryNo;
            PostedGSTLiabilityAdj."Posting Date" := GSTLiabilityAdjustment."Adjustment Posting Date";
            PostedGSTLiabilityAdj."USER ID" := CopyStr(UserId(), 1, MaxStrLen(DetailedGSTLedgerEntryInfo."USER ID"));
            PostedGSTLiabilityAdj."Adjusted Doc. Entry No." := DetailedGSTLedgerEntry."Entry No.";
            PostedGSTLiabilityAdj."Adjusted Doc. Entry Type" := DetailedGSTLedgerEntry."Entry Type";
            PostedGSTLiabilityAdj."Transaction Type" := DetailedGSTLedgerEntry."Transaction Type";
            PostedGSTLiabilityAdj."Document Type" := DetailedGSTLedgerEntry."Document Type";
            PostedGSTLiabilityAdj."Document No." := DetailedGSTLedgerEntry."Document No.";
            PostedGSTLiabilityAdj."Adjusted Doc. Posting Date" := GSTLiabilityAdjustment."Document Posting Date";
            PostedGSTLiabilityAdj.Type := DetailedGSTLedgerEntry.Type;
            PostedGSTLiabilityAdj."No." := DetailedGSTLedgerEntry."No.";
            PostedGSTLiabilityAdj."Product Type" := DetailedGSTLedgerEntry."Product Type";
            PostedGSTLiabilityAdj."Source Type" := DetailedGSTLedgerEntry."Source Type";
            PostedGSTLiabilityAdj."Source No." := DetailedGSTLedgerEntry."Source No.";
            PostedGSTLiabilityAdj."HSN/SAC Code" := DetailedGSTLedgerEntry."HSN/SAC Code";
            PostedGSTLiabilityAdj."GST Component Code" := DetailedGSTLedgerEntry."GST Component Code";
            PostedGSTLiabilityAdj."GST Group Code" := DetailedGSTLedgerEntry."GST Group Code";
            PostedGSTLiabilityAdj."GST Jurisdiction Type" := DetailedGSTLedgerEntry."GST Jurisdiction Type";
            if GSTLiabilityAdjustment."Nature of Adjustment" = GSTLiabilityAdjustment."Nature of Adjustment"::Generate then begin
                PostedGSTLiabilityAdj."GST Base Amount" := AppliedBaseAmount;
                PostedGSTLiabilityAdj."GST Amount" := AppliedAmount;
                PostedGSTLiabilityAdj."Adjustment Amount" := AppliedAmount;
                PostedGSTLiabilityAdj.Positive := DetailedGSTLedgerEntryInfo.Positive;
            end else begin
                PostedGSTLiabilityAdj."GST Base Amount" := -AppliedBaseAmount;
                PostedGSTLiabilityAdj."GST Amount" := -AppliedAmount;
                PostedGSTLiabilityAdj."Adjustment Amount" := AppliedAmount;
                PostedGSTLiabilityAdj.Positive := false;
            end;

            PostedGSTLiabilityAdj."GST %" := GSTLiabilityBuffer."GST %";
            PostedGSTLiabilityAdj."G/L Account" := DetailedGSTLedgerEntry."G/L Account No.";
            PostedGSTLiabilityAdj."External Document No." := DetailedGSTLedgerEntry."External Document No.";
            PostedGSTLiabilityAdj."Location  Reg. No." := DetailedGSTLedgerEntry."Location  Reg. No.";
            PostedGSTLiabilityAdj."Buyer/Seller Reg. No." := DetailedGSTLedgerEntry."Buyer/Seller Reg. No.";
            PostedGSTLiabilityAdj."GST Group Type" := DetailedGSTLedgerEntry."GST Group Type";
            PostedGSTLiabilityAdj."GST Credit" := DetailedGSTLedgerEntry."GST Credit";
            PostedGSTLiabilityAdj."GST Rounding Precision" := DetailedGSTLedgerEntry."GST Rounding Precision";
            PostedGSTLiabilityAdj."GST Rounding Type" := DetailedGSTLedgerEntry."GST Rounding Type";
            PostedGSTLiabilityAdj."GST Vendor Type" := DetailedGSTLedgerEntry."GST Vendor Type";
            PostedGSTLiabilityAdj.Cess := DetailedGSTLedgerEntryInfo.Cess;
            PostedGSTLiabilityAdj."Input Service Distribution" := DetailedGSTLedgerEntry."Input Service Distribution";
            if DetailedGSTLedgerEntry."GST Credit" = DetailedGSTLedgerEntry."GST Credit"::Availment then
                PostedGSTLiabilityAdj."Credit Availed" := true;
            PostedGSTLiabilityAdj."Liable to Pay" := true;
            if GSTLiabilityAdjustment."Nature of Adjustment" = GSTLiabilityAdjustment."Nature of Adjustment"::Reverse then
                PostedGSTLiabilityAdj.Paid := false;
            PostedGSTLiabilityAdj."Credit Adjustment Type" := GSTLiabilityAdjustment."Nature of Adjustment";
            GSTLiabilityAdjustment.TestField("Journal Doc. No.");
            PostedGSTLiabilityAdj."Adjustment Document No." := GSTLiabilityAdjustment."Journal Doc. No.";
            PostedGSTLiabilityAdj.Insert();
        end;

        exit(true);
    end;

    local procedure UpdateServiceLiabilityDetailedGSTLedgerEntry(
        TypeOfAdjustment: Enum "Cr Libty Adjustment Type";
                              EntryNo: Integer;
                              AppliedBaseAmount: Decimal;
                              AppliedAmount: Decimal)
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        DetailedGSTLedgerEntry.Get(EntryNo);
        DetailedGSTLedgerEntry."Cr. & Liab. Adjustment Type" := TypeOfAdjustment;
        if TypeOfAdjustment = TypeOfAdjustment::Reverse then begin
            DetailedGSTLedgerEntry."AdjustmentBase Amount" := 0;
            DetailedGSTLedgerEntry."Adjustment Amount" := 0;
            DetailedGSTLedgerEntry."Remaining Base Amount" += AppliedBaseAmount;
            DetailedGSTLedgerEntry."Remaining GST Amount" += AppliedAmount;
        end else begin
            DetailedGSTLedgerEntry."AdjustmentBase Amount" += AppliedBaseAmount;
            if not DetailedGSTLedgerEntry."GST Exempted Goods" then
                DetailedGSTLedgerEntry."Adjustment Amount" += AppliedAmount;
            DetailedGSTLedgerEntry."Remaining Base Amount" -= AppliedBaseAmount;
            DetailedGSTLedgerEntry."Remaining GST Amount" -= AppliedAmount;
        end;

        DetailedGSTLedgerEntry.Modify();
    end;

    local procedure GetCreditAccountNormalPayment(
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTPostingBuffer: Record "GST Posting Buffer";
        var AccountNo: Code[20];
        var AccountNo2: Code[20];
        var BalanceAccountNo: Code[20];
        var BalanceAccountNo2: Code[20])
    var
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        GSTHelpers: Codeunit "GST Helpers";
    begin
        Clear(AccountNo);
        Clear(AccountNo2);
        Clear(BalanceAccountNo);
        Clear(BalanceAccountNo2);

        GetDetailedGSTLedgerEnfo(DetailedGSTLedgerEntry."Entry No.", DetailedGSTLedgerEntryInfo);
        if GSTPostingBuffer.Availment then begin
            AccountNo := GSTHelpers.GetGSTPayableAccountNo(DetailedGSTLedgerEntryInfo."Location State Code", GSTPostingBuffer."GST Component Code");
            AccountNo2 := GSTHelpers.GetGSTRcvblInterimAccountNo(DetailedGSTLedgerEntryInfo."Location State Code", GSTPostingBuffer."GST Component Code");
            BalanceAccountNo := GSTHelpers.GetGSTPayableInterimAccountNo(DetailedGSTLedgerEntryInfo."Location State Code", GSTPostingBuffer."GST Component Code");
            BalanceAccountNo2 := GSTHelpers.GetGSTReceivableAccountNo(DetailedGSTLedgerEntryInfo."Location State Code", GSTPostingBuffer."GST Component Code");
        end else begin
            AccountNo := GSTHelpers.GetGSTPayableAccountNo(DetailedGSTLedgerEntryInfo."Location State Code", GSTPostingBuffer."GST Component Code");
            BalanceAccountNo := GSTHelpers.GetGSTPayableInterimAccountNo(DetailedGSTLedgerEntryInfo."Location State Code", GSTPostingBuffer."GST Component Code");
        end;
    end;

    local procedure UpdateGSTPostingBufferWithApplication()
    begin
        TempGSTPostingBuffer1[2] := TempGSTPostingBuffer1[1];
        if TempGSTPostingBuffer1[2].Find() then begin
            TempGSTPostingBuffer1[2]."GST Base Amount" += TempGSTPostingBuffer1[1]."GST Base Amount";
            TempGSTPostingBuffer1[2]."GST Amount" += TempGSTPostingBuffer1[1]."GST Amount";
            TempGSTPostingBuffer1[2].Modify();
        end else
            TempGSTPostingBuffer1[1].Insert();
    end;

    local procedure CheckSettlementInputValidations(GSTINNo: Code[20]; PostingDate: Date)
    begin
        if GSTINNo = '' then
            Error(GSTINErr);

        if PostingDate = 0D then
            Error(PostingDateErr);
    end;

    local procedure GetSettlementDocumentNo(PostingDate: Date; modifyTrue: Boolean): Code[20]
    var
        GenLedgerSetup: Record "General Ledger Setup";
        NoSeriesMgmt: Codeunit NoSeriesManagement;
    begin
        GenLedgerSetup.Get();
        GenLedgerSetup.TestField("GST Settlement Nos.");
        exit(NoSeriesMgmt.GetNextNo(GenLedgerSetup."GST Settlement Nos.", PostingDate, modifyTrue));
    end;

    local procedure CreateGSTPaymentBuffer(
        GSTINNo: Code[20];
        DocumentNo: Code[20];
        PostingDate: Date;
        AccountType: Enum "GST Settlement Account Type";
                         AccountNo: Code[20];
                         BankRefNo: Code[10];
                         BankRefDate: Date)
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        ReturnRecoComponent: Record "Retrun & Reco. Components";
        GSTPaymentBuffer: Record "GST Payment Buffer";
        Liability: Decimal;
        RevChargeLiability: Decimal;
        CreditAvailable: Decimal;
        PostedLiability: Decimal;
        PostedRevChargeLiability: Decimal;
        PostedCreditAvailable: Decimal;
        PostedCrAdjutLiability: Decimal;
        PostedCrAdjutCredit: Decimal;
        DetGSTDistCredit: Decimal;
        PostedCrServiceLiability: Decimal;
        PostedCrServiceCredit: Decimal;
        PostedAdjustmentAmount: Decimal;
        GSTTDSAmount: Decimal;
        GSTTCSAmount: Decimal;
        GSTTCSLiabilityAmount: Decimal;
        PostedGSTTDSCredit: Decimal;
        PostedGSTTCSCredit: Decimal;
        EntryType: Option " ",TDS,TCS;
    begin
        Window.Open(PaymentBufferMsg);
        DetailedGSTLedgerEntry.LockTable();
        if ReturnRecoComponent.FindSet() then
            repeat
                Window.Update(1, ReturnRecoComponent."Component Name");
                InsertGSTPaymentBuffer(
                   GSTPaymentBuffer,
                   ReturnRecoComponent."Component Name",
                   GSTINNo,
                   DocumentNo,
                   AccountType,
                   AccountNo,
                   PostingDate,
                   BankRefNo,
                   BankRefDate);

                GetLiabilityAndCredit(GSTPaymentBuffer, Liability, RevChargeLiability, CreditAvailable);
                GetpostedAmount(
                    GSTPaymentBuffer,
                    PostedLiability,
                    PostedCreditAvailable,
                    PostedRevChargeLiability,
                    PostedGSTTDSCredit,
                    PostedGSTTCSCredit);
                GetPostedCreditAdjustmentAmount(GSTPaymentBuffer, PostedCrAdjutLiability, PostedCrAdjutCredit);
                GetPostedCreditandLiabilityAmount(GSTPaymentBuffer, PostedCrServiceLiability, PostedCrServiceCredit);
                GetGSTAdjustmentAmount(GSTPaymentBuffer, PostedAdjustmentAmount);

                GetDetGSTDistEntryAmount(GSTPaymentBuffer, DetGSTDistCredit);
                GetGSTTDSTCSCreditAmount(GSTPaymentBuffer, GSTTDSAmount, EntryType::TDS);
                GetGSTTDSTCSCreditAmount(GSTPaymentBuffer, GSTTCSAmount, EntryType::TCS);
                GetGSTTCSLiabilityAmount(GSTPaymentBuffer, GSTTCSLiabilityAmount);

                GSTPaymentBuffer.Validate("Distributed Credit", DetGSTDistCredit);
                GSTPaymentBuffer.Validate("GST TDS Credit Available", GSTTDSAmount + PostedGSTTDSCredit);
                GSTPaymentBuffer.Validate("GST TCS Credit Available", GSTTCSAmount + PostedGSTTCSCredit);
                GSTPaymentBuffer.Validate("GST TCS Liability", GSTTCSLiabilityAmount);
                Liability += Round(PostedCrAdjutLiability + PostedLiability + PostedAdjustmentAmount);
                CreditAvailable += PostedCreditAvailable + PostedCrAdjutCredit + DetGSTDistCredit + PostedCrServiceCredit;

                if PostedRevChargeLiability < 0 then
                    RevChargeLiability += PostedRevChargeLiability;
                RevChargeLiability += PostedCrServiceLiability;
                GSTPaymentBuffer.Validate("Payment Liability - Rev. Chrg.", RevChargeLiability);

                if RevChargeLiability > 0 then
                    GSTPaymentBuffer.Validate("Payment Amount - Rev. Chrg.", GSTPaymentBuffer."Payment Liability - Rev. Chrg.");

                if CreditAvailable >= 0 then begin
                    GSTPaymentBuffer.Validate("Credit Availed", CreditAvailable);
                    GSTPaymentBuffer.Validate("Payment Liability", Liability);
                end else begin
                    GSTPaymentBuffer.Validate("UnAdjutsed Credit", CreditAvailable);
                    GSTPaymentBuffer.Validate("Payment Liability", Liability + Abs(CreditAvailable));
                end;

                if GSTPaymentBuffer."Payment Liability" < 0 then begin
                    GSTPaymentBuffer.Validate("UnAdjutsed Liability", GSTPaymentBuffer."Payment Liability");
                    GSTPaymentBuffer.Validate("Payment Liability", 0);
                end;

                if GSTPaymentBuffer."Net Payment Liability" >= 0 then
                    GSTPaymentBuffer.Validate("Payment Amount", GSTPaymentBuffer."Net Payment Liability")
                else begin
                    GSTPaymentBuffer.Validate("Credit Utilized", 0);
                    GSTPaymentBuffer.Validate("Payment Amount", 0);
                    GSTPaymentBuffer.Validate(
                        "UnAdjutsed Liability",
                        GSTPaymentBuffer."Net Payment Liability" + GSTPaymentBuffer."UnAdjutsed Liability");
                    GSTPaymentBuffer.Validate("Net Payment Liability", 0);
                end;

                GSTPaymentBuffer.Modify(true);
            until ReturnRecoComponent.Next() = 0;

        Window.Close();
    end;

    local procedure InsertGSTPaymentBuffer(
        var GSTPaymentBuffer: Record "GST Payment Buffer";
        GSTComponent: Code[30];
        GSTINNo: Code[20];
        DocumentNo: Code[20];
        AccountType: Enum "GST Settlement Account Type";
                         AccountNo: Code[20];
                         PostingDate: Date;
                         BankRefNo: Code[10];
                         BankRefDate: Date)
    var
        GSTRegistrationNos: Record "GST Registration Nos.";
    begin
        GSTRegistrationNos.Get(GSTINNo);
        GSTPaymentBuffer.Init();
        GSTPaymentBuffer."GST Registration No." := GSTINNo;
        GSTPaymentBuffer."GST Input Service Distribution" := GSTRegistrationNos."Input Service Distributor";
        GSTPaymentBuffer."GST Component Code" := GSTComponent;
        GSTPaymentBuffer.Description := GSTComponent;
        GSTPaymentBuffer."Document No." := DocumentNo;
        GSTPaymentBuffer."Location State Code" := GetGSTNState(GSTINNo);
        GSTPaymentBuffer."Account Type" := GSTSettlementAccTypeEnum2GenJnlAccType(AccountType);
        GSTPaymentBuffer."Account No." := AccountNo;
        GSTPaymentBuffer."Posting Date" := PostingDate;
        GSTPaymentBuffer."Period end Date" := GetPeriodendDate(PostingDate);
        GSTPaymentBuffer."Bank Reference No." := BankRefNo;
        GSTPaymentBuffer."Bank Reference Date" := BankRefDate;
        GSTPaymentBuffer.Insert(true);
    end;

    local procedure GetLiabilityAndCredit(
        GSTPaymentBuffer: Record "GST Payment Buffer";
        var Liability: Decimal;
        var RevChargeLiability: Decimal;
        var CreditAvailable: Decimal)
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        Clear(Liability);
        Clear(RevChargeLiability);
        Clear(CreditAvailable);

        FilterDetailedGSTLedgerEntry(GSTPaymentBuffer, DetailedGSTLedgerEntry);
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                if not ((DetailedGSTLedgerEntry."ARN No." <> '') and (DetailedGSTLedgerEntry."Buyer/Seller Reg. No." = '')) then
                    case DetailedGSTLedgerEntry."Reverse Charge" of
                        false:
                            begin
                                if DetailedGSTLedgerEntry."Liable to Pay" then
                                    Liability += DetailedGSTLedgerEntry."GST Amount" * -1;
                                if DetailedGSTLedgerEntry."Credit Availed" then
                                    CreditAvailable += DetailedGSTLedgerEntry."GST Amount";
                            end;
                        true:
                            if DetailedGSTLedgerEntry."Payment Type" = "Payment Type"::Normal then begin
                                if DetailedGSTLedgerEntry."Liable to Pay" then
                                    RevChargeLiability += DetailedGSTLedgerEntry."GST Amount" * -1;
                                if DetailedGSTLedgerEntry."Credit Availed" then
                                    CreditAvailable += DetailedGSTLedgerEntry."GST Amount" * -1;
                            end else begin
                                if DetailedGSTLedgerEntry."Liable to Pay" then
                                    RevChargeLiability += DetailedGSTLedgerEntry."GST Amount";

                                if DetailedGSTLedgerEntry."Credit Availed" then
                                    if (DetailedGSTLedgerEntry."Payment Type" = "Payment Type"::Advance) and
                                        (DetailedGSTLedgerEntry."Entry Type" = "Entry Type"::Application) and
                                        not DetailedGSTLedgerEntry."Associated Enterprises" and
                                        (DetailedGSTLedgerEntry."GST Group Type" = "GST Group Type"::Service)
                                    then
                                        CreditAvailable += DetailedGSTLedgerEntry."GST Amount" * -1
                                    else
                                        CreditAvailable += DetailedGSTLedgerEntry."GST Amount";
                            end;
                    end;
            until DetailedGSTLedgerEntry.Next() = 0;
    end;

    local procedure FilterDetailedGSTLedgerEntry(
        GSTPaymentBuffer: Record "GST Payment Buffer";
        var DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry")
    begin
        DetailedGSTLedgerEntry.SetCurrentKey("Location  Reg. No.", "GST Component Code", Paid, "Posting Date");
        DetailedGSTLedgerEntry.SetRange("Location  Reg. No.", GSTPaymentBuffer."GST Registration No.");
        DetailedGSTLedgerEntry.SetRange("GST Component Code", GSTPaymentBuffer."GST Component Code");
        DetailedGSTLedgerEntry.SetRange(Paid, false);
        DetailedGSTLedgerEntry.SetFilter("Posting Date", '..%1', GSTPaymentBuffer."Period end Date");
        DetailedGSTLedgerEntry.SetRange("Input Service Distribution", false);
        DetailedGSTLedgerEntry.SetFilter("Entry Type", '<>%1', DetailedGSTLedgerEntry."Entry Type"::"Adjustment Entry");
    end;

    local procedure GetGSTNState(GSTINNo: Code[20]): Code[10]
    var
        GSTRegistrationNos: Record "GST Registration Nos.";
    begin
        GSTRegistrationNos.Get(GSTINNo);
        exit(GSTRegistrationNos."State Code");
    end;

    local procedure GetPostedCreditAdjustmentAmount(
        GSTPaymentBuffer: Record "GST Payment Buffer";
        var LiableAmount: Decimal;
        var CreditAmount: Decimal)
    var
        DetailedCrAdjstmntEntry: Record "Detailed Cr. Adjstmnt. Entry";
    begin
        Clear(LiableAmount);
        Clear(CreditAmount);

        FilterPostedCreditAdjustmentEntry(GSTPaymentBuffer, DetailedCrAdjstmntEntry);
        if DetailedCrAdjstmntEntry.FindSet() then
            repeat
                if DetailedCrAdjstmntEntry."Liable to Pay" then
                    LiableAmount += DetailedCrAdjstmntEntry."GST Amount";
                if DetailedCrAdjstmntEntry."Credit Availed" then
                    CreditAmount += DetailedCrAdjstmntEntry."GST Amount";
            until DetailedCrAdjstmntEntry.Next() = 0;
    end;

    local procedure FilterPostedCreditAdjustmentEntry(
        GSTPaymentBuffer: Record "GST Payment Buffer";
        var DetailedCrAdjstmntEntry: Record "Detailed Cr. Adjstmnt. Entry")
    begin
        DetailedCrAdjstmntEntry.SetCurrentKey("Location  Reg. No.", "GST Component Code", Paid, "Posting Date");
        DetailedCrAdjstmntEntry.SetRange("Location  Reg. No.", GSTPaymentBuffer."GST Registration No.");
        DetailedCrAdjstmntEntry.SetRange("GST Component Code", GSTPaymentBuffer."GST Component Code");
        DetailedCrAdjstmntEntry.SetRange(Paid, false);
        DetailedCrAdjstmntEntry.SetFilter("Posting Date", '..%1', GSTPaymentBuffer."Posting Date");
    end;

    local procedure GetPostedCreditandLiabilityAmount(
        GSTPaymentBuffer: Record "GST Payment Buffer";
        var LiableAmount: Decimal;
        var CreditAmount: Decimal)
    var
        PostedGSTLiabilityAdj: Record "Posted GST Liability Adj.";
    begin
        Clear(LiableAmount);
        Clear(CreditAmount);

        FilterPostedCreditandLiabilityEntry(GSTPaymentBuffer, PostedGSTLiabilityAdj);
        if PostedGSTLiabilityAdj.FindSet() then
            repeat
                if PostedGSTLiabilityAdj."Liable to Pay" then
                    LiableAmount += PostedGSTLiabilityAdj."GST Amount";
                if PostedGSTLiabilityAdj."Credit Availed" then
                    CreditAmount += PostedGSTLiabilityAdj."GST Amount";
            until PostedGSTLiabilityAdj.Next() = 0;
    end;

    local procedure GetGSTAdjustmentAmount(GSTPaymentBuffer: Record "GST Payment Buffer"; var Liability: Decimal)
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        Clear(Liability);
        FilterDetailedGSTLedgerEntryforAdjustment(GSTPaymentBuffer, DetailedGSTLedgerEntry);
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                if not ((DetailedGSTLedgerEntry."ARN No." <> '') and (DetailedGSTLedgerEntry."Buyer/Seller Reg. No." = '')) then
                    Liability += Abs(DetailedGSTLedgerEntry."GST Amount");
            until DetailedGSTLedgerEntry.Next() = 0;
    end;

    local procedure GetDetGSTDistEntryAmount(GSTPaymentBuffer: Record "GST Payment Buffer"; var CreditAmount: Decimal)
    var
        DetailedGSTDistEntry: Record "Detailed GST Dist. Entry";
    begin
        Clear(CreditAmount);
        FilterDetGSTDistEntry(GSTPaymentBuffer, DetailedGSTDistEntry, true);
        if DetailedGSTDistEntry.FindSet() then
            repeat
                if DetailedGSTDistEntry."Credit Availed" then
                    CreditAmount += DetailedGSTDistEntry."Distribution Amount";
            until DetailedGSTDistEntry.Next() = 0;
    end;

    local procedure FilterDetailedGSTLedgerEntryforAdjustment(
        GSTPaymentBuffer: Record "GST Payment Buffer";
        var DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry")
    begin
        DetailedGSTLedgerEntry.SetCurrentKey("Location  Reg. No.", "GST Component Code", Paid, "Posting Date");
        DetailedGSTLedgerEntry.SetRange("Location  Reg. No.", GSTPaymentBuffer."GST Registration No.");
        DetailedGSTLedgerEntry.SetRange("GST Component Code", GSTPaymentBuffer."GST Component Code");
        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Adjustment Entry");
        DetailedGSTLedgerEntry.SetRange(Paid, false);
        DetailedGSTLedgerEntry.SetFilter("Posting Date", '..%1', GSTPaymentBuffer."Period end Date");
        DetailedGSTLedgerEntry.SetRange("Input Service Distribution", false);
    end;

    local procedure GetGSTTDSTCSCreditAmount(
        GSTPaymentBuffer: Record "GST Payment Buffer";
        var CreditAmount: Decimal;
        EntryType: Option " ",TDS,TCS)
    var
        GSTTdsTcsEntry: Record "GST TDS/TCS Entry";
    begin
        Clear(CreditAmount);

        if EntryType = EntryType::TDS then
            FilterGSTTDSTCSEntry(GSTPaymentBuffer, GSTTdsTcsEntry, EntryType::TDS, false)
        else
            FilterGSTTDSTCSEntry(GSTPaymentBuffer, GSTTdsTcsEntry, EntryType::TCS, false);
        if GSTTdsTcsEntry.FindSet() then
            repeat
                CreditAmount += GSTTdsTcsEntry."GST TDS/TCS Amount (LCY)";
            until GSTTdsTcsEntry.Next() = 0;
    end;

    local procedure GetGSTTCSLiabilityAmount(GSTPaymentBuffer: Record "GST Payment Buffer"; var LiabilityAmount: Decimal)
    var
        GSTTdsTcsEntry: Record "GST TDS/TCS Entry";
        EntryType: Option " ",TDS,TCS;
    begin
        Clear(LiabilityAmount);

        FilterGSTTDSTCSEntry(GSTPaymentBuffer, GSTTdsTcsEntry, EntryType::TCS, true);
        if GSTTdsTcsEntry.FindSet() then
            repeat
                LiabilityAmount += Abs(GSTTdsTcsEntry."GST TDS/TCS Amount (LCY)");
            until GSTTdsTcsEntry.Next() = 0;
    end;

    local procedure FilterPostedCreditandLiabilityEntry(
        GSTPaymentBuffer: Record "GST Payment Buffer";
        var PostedGSTLiabilityAdj: Record "Posted GST Liability Adj.")
    begin
        PostedGSTLiabilityAdj.SetCurrentKey("Location  Reg. No.", "GST Component Code", Paid, "Posting Date");
        PostedGSTLiabilityAdj.SetRange("Location  Reg. No.", GSTPaymentBuffer."GST Registration No.");
        PostedGSTLiabilityAdj.SetRange("GST Component Code", GSTPaymentBuffer."GST Component Code");
        PostedGSTLiabilityAdj.SetRange(Paid, false);
        PostedGSTLiabilityAdj.SetFilter("Posting Date", '..%1', GSTPaymentBuffer."Posting Date");
    end;

    local procedure FilterGSTTDSTCSEntry(
        GSTPaymentBuffer: Record "GST Payment Buffer";
        var GSTTdsTcsEntry: Record "GST TDS/TCS Entry";
        EntryType: Option " ",TDS,TCS;
        VendorGSTTCS: Boolean)
    begin
        GSTTdsTcsEntry.SetCurrentKey("Location GST Reg. No.", "GST Component Code", Paid, "Posting Date");
        GSTTdsTcsEntry.SetRange("Location GST Reg. No.", GSTPaymentBuffer."GST Registration No.");
        GSTTdsTcsEntry.SetRange("GST Component Code", GSTPaymentBuffer."GST Component Code");
        GSTTdsTcsEntry.SetRange(Paid, false);
        GSTTdsTcsEntry.SetFilter("Posting Date", '..%1', GSTPaymentBuffer."Posting Date");
        if EntryType = EntryType::TDS then begin
            GSTTdsTcsEntry.SetRange(Type, GSTTdsTcsEntry.Type::TDS);
            GSTTdsTcsEntry.SetRange("Certificate Received", true);
            GSTTdsTcsEntry.SetRange("Credit Availed", true);
        end else begin
            GSTTdsTcsEntry.SetRange(Type, GSTTdsTcsEntry.Type::TCS);
            if VendorGSTTCS then
                GSTTdsTcsEntry.SetRange("Liable to Pay", true)
            else
                GSTTdsTcsEntry.SetRange("Credit Availed", true);
        end;
        GSTTdsTcsEntry.SetRange(Reversed, false);
    end;

    local procedure GetPostedAmount(
        GSTPaymentBuffer: Record "GST Payment Buffer";
        var PaymentLiability: Decimal;
        var CreditAvailed: Decimal;
        var PaymentLiabilityRev: Decimal;
        var GSTTDSCreditAvailed: Decimal;
        var GSTTCSCreditAvailed: Decimal)
    var
        PostedSettlementEntries: Record "Posted Settlement Entries";
    begin
        Clear(PaymentLiability);
        Clear(CreditAvailed);
        Clear(PaymentLiabilityRev);

        PostedSettlementEntries.SetRange("GST Registration No.", GSTPaymentBuffer."GST Registration No.");
        PostedSettlementEntries.SetRange("GST Component Code", GSTPaymentBuffer."GST Component Code");
        if PostedSettlementEntries.FindLast() then begin
            PaymentLiability := PostedSettlementEntries."UnAdjutsed Liability";
            CreditAvailed := PostedSettlementEntries."Carry Forward";
            PaymentLiabilityRev := PostedSettlementEntries."Payment Liability - Rev. Chrg.";
            GSTTDSCreditAvailed := PostedSettlementEntries."GST TDS Credit Unutilized";
            GSTTCSCreditAvailed := PostedSettlementEntries."GST TCS Credit Unutilized";
        end;
    end;

    local procedure FilterDetGSTDistEntry(
        GSTPaymentBuffer: Record "GST Payment Buffer";
        var DetailedGSTDistEntry: Record "Detailed GST Dist. Entry";
        FilterAvailment: Boolean)
    begin
        DetailedGSTDistEntry.SetRange("Rcpt. GST Reg. No.", GSTPaymentBuffer."GST Registration No.");
        DetailedGSTDistEntry.SetRange("Rcpt. Component Code", GSTPaymentBuffer."GST Component Code");
        if FilterAvailment then
            DetailedGSTDistEntry.SetRange("Rcpt. GST Credit", DetailedGSTDistEntry."Rcpt. GST Credit"::Availment);
        DetailedGSTDistEntry.SetRange(Paid, false);
        DetailedGSTDistEntry.SetFilter("Posting Date", '..%1', GSTPaymentBuffer."Period end Date");
        DetailedGSTDistEntry.SetFilter("ISD Posting Date", '<=%1', GSTPaymentBuffer."Posting Date");
    end;

    local procedure CheckSettlementValidations(GSTINNo: Code[20]; DocumentNo: Code[20])
    var
        GSTPaymentBuffer: Record "GST Payment Buffer";
        GSTClaimSetoff: Record "GST Claim Setoff";
        GSTBaseValidation: Codeunit "GST Base Validation";
    begin
        IsDifferentAccountTypeAndNo(GSTINNo, DocumentNo);

        GSTPaymentBuffer.SetRange("GST Registration No.", GSTINNo);
        GSTPaymentBuffer.SetRange("Document No.", DocumentNo);
        if GSTPaymentBuffer.FindSet() then
            repeat
                GSTBaseValidation.CheckGSTAccountingPeriod(GSTPaymentBuffer."Posting Date", true);
                GSTBaseValidation.CheckGSTAccountingPeriod(GSTPaymentBuffer."Period end Date", true);
                if GSTPaymentBuffer."Credit Utilized" > GSTPaymentBuffer."Net Payment Liability" then
                    Error(
                        CreditUtilizedErr,
                        GSTPaymentBuffer."Credit Utilized",
                        GSTPaymentBuffer."Net Payment Liability",
                        GSTPaymentBuffer."GST Component Code");

                if GSTPaymentBuffer."Credit Utilized" >= 0 then
                    if GSTPaymentBuffer."Net Payment Liability" >
                       (GSTPaymentBuffer."Credit Utilized" +
                        GSTPaymentBuffer."GST TDS Credit Utilized" +
                        GSTPaymentBuffer."GST TCS Credit Utilized" +
                        GSTPaymentBuffer."Payment Amount")
                    then
                        Error(
                            LiabilityExceedErr,
                            GSTPaymentBuffer."Credit Utilized" +
                                GSTPaymentBuffer."GST TDS Credit Utilized" +
                                GSTPaymentBuffer."GST TCS Credit Utilized" +
                                GSTPaymentBuffer."Payment Amount",
                            GSTPaymentBuffer."Net Payment Liability",
                            GSTPaymentBuffer."GST Component Code");

                if GSTPaymentBuffer."Surplus Credit" > 0 then
                    GSTPaymentBuffer."Carry Forward" := GSTPaymentBuffer."Surplus Credit";

                if (GSTPaymentBuffer."Credit Utilized" > 0) then begin

                    GSTClaimSetoff.Reset();
                    GSTClaimSetoff.SetCurrentKey(Priority);
                    GSTClaimSetoff.SetRange("GST Component Code", GSTPaymentBuffer."GST Component Code");
                    if not GSTClaimSetoff.IsEmpty() then begin
                        if GSTPaymentBuffer."Surplus Credit" < 0 then
                            Error(
                                CreditAvailableErr,
                                GSTPaymentBuffer."GST Component Code",
                                GSTPaymentBuffer."Credit Utilized",
                                GSTPaymentBuffer."Credit Utilized" + GSTPaymentBuffer."Surplus Credit");
                    end else
                        if (GSTPaymentBuffer."Credit Utilized" > 0) then
                            Error(CreditSetoffErr, GSTPaymentBuffer."GST Component Code");
                end;

                GSTPaymentBuffer.Modify(true);
                if GSTPaymentBuffer."Payment Liability - Rev. Chrg." >= 0 then
                    GSTPaymentBuffer.TestField("Payment Amount - Rev. Chrg.", GSTPaymentBuffer."Payment Liability - Rev. Chrg.")
                else
                    GSTPaymentBuffer.TestField("Payment Amount - Rev. Chrg.", 0);

                if (GSTPaymentBuffer."Payment Amount" <> 0) or
                    (GSTPaymentBuffer.Interest <> 0) or
                    (GSTPaymentBuffer.Penalty <> 0) or
                    (GSTPaymentBuffer.Fees <> 0) or
                    (GSTPaymentBuffer.Others <> 0)
                then
                    GSTPaymentBuffer.TestField("Account No.");

                if GSTPaymentBuffer.Interest <> 0 then
                    GSTPaymentBuffer.TestField("Interest Account No.");

                if GSTPaymentBuffer.Penalty <> 0 then
                    GSTPaymentBuffer.TestField("Penalty Account No.");

                if GSTPaymentBuffer.Fees <> 0 then
                    GSTPaymentBuffer.TestField("Fees Account No.");

                if GSTPaymentBuffer.Others <> 0 then
                    GSTPaymentBuffer.TestField("Others Account No.");
            until GSTPaymentBuffer.Next() = 0;
    end;

    local procedure IsDifferentAccountTypeAndNo(GSTINNo: Code[20]; DocumentNo: Code[20])
    var
        GSTPaymentBuffer: Record "GST Payment Buffer";
        GSTPaymentBuffer2: Record "GST Payment Buffer";
    begin
        GSTPaymentBuffer.SetRange("GST Registration No.", GSTINNo);
        GSTPaymentBuffer.SetRange("Document No.", DocumentNo);
        if GSTPaymentBuffer.FindFirst() then begin
            GSTPaymentBuffer2.SetRange("GST Registration No.", GSTINNo);
            GSTPaymentBuffer2.SetRange("Document No.", DocumentNo);
            GSTPaymentBuffer2.SetFilter("Account Type", '<>%1', GSTPaymentBuffer."Account Type");
            if not GSTPaymentBuffer2.IsEmpty() then
                Error(GSTPaymentFieldSameErr, Format(GSTPaymentBuffer.FieldCaption("Account Type")));
            GSTPaymentBuffer2.SetRange("Account Type");
            GSTPaymentBuffer2.SetFilter("Account No.", '<>%1', GSTPaymentBuffer."Account No.");
            if not GSTPaymentBuffer2.IsEmpty() then
                Error(GSTPaymentFieldSameErr, GSTPaymentBuffer.FieldCaption("Account No."));
            GSTPaymentBuffer2.SetRange("Account No.");
            GSTPaymentBuffer2.SetFilter("Bank Reference No.", '<>%1', GSTPaymentBuffer."Bank Reference No.");
            if not GSTPaymentBuffer2.IsEmpty() then
                Error(GSTPaymentFieldSameErr, GSTPaymentBuffer.FieldCaption("Bank Reference No."));
            GSTPaymentBuffer2.SetRange("Bank Reference No.");
            GSTPaymentBuffer2.SetFilter("Bank Reference Date", '<>%1', GSTPaymentBuffer."Bank Reference Date");
            if not GSTPaymentBuffer2.IsEmpty() then
                Error(GSTPaymentFieldSameErr, GSTPaymentBuffer.FieldCaption("Bank Reference Date"));
        end;
    end;

    local procedure CopyDocDimToTempDocDim(GSTINNo: Code[20]; DocumentNo: Code[20])
    var
        GSTPaymentBuffer: Record "GST Payment Buffer";
        IsError: Boolean;
        ErrText: Text[250];
    begin
        GSTPaymentBuffer.SetRange("GST Registration No.", GSTINNo);
        GSTPaymentBuffer.SetRange("Document No.", DocumentNo);
        if GSTPaymentBuffer.FindSet() then
            repeat
                CheckDimComb(GSTPaymentBuffer."Dimension Set ID", IsError, ErrText);
                if IsError then
                    Error(DimCombinationErr, GSTPaymentBuffer."GST Component Code", ErrText);

                CheckDimValuePosting(GSTPaymentBuffer."Document No.", GSTPaymentBuffer."Dimension Set ID");
            until GSTPaymentBuffer.Next() = 0;
    end;

    local procedure CheckDimComb(DimSetID: Integer; var IsError: Boolean; var ErrText: Text[250])
    begin
        if not DimensionManagement.CheckDimIDComb(DimSetID) then begin
            IsError := true;
            ErrText := DimensionManagement.GetDimCombErr();
        end else
            IsError := false;
    end;

    local procedure IsAllComponentsHaveZeroValue(GSTINNo: Code[20]; DocumentNo: Code[20]): Boolean
    var
        GSTPaymentBuffer: Record "GST Payment Buffer";
    begin
        GSTPaymentBuffer.SetRange("GST Registration No.", GSTINNo);
        GSTPaymentBuffer.SetRange("Document No.", DocumentNo);
        if GSTPaymentBuffer.FindSet() then
            repeat
                if not ((GSTPaymentBuffer."UnAdjutsed Credit" = 0) and
                    (GSTPaymentBuffer."Total Payment Amount" = 0) and
                    (GSTPaymentBuffer."Credit Utilized" = 0) and
                    (GSTPaymentBuffer."GST TDS Credit Utilized" = 0) and
                    (GSTPaymentBuffer."GST TCS Credit Utilized" = 0) and
                    (GSTPaymentBuffer."GST TCS Liability" = 0))
                then
                    exit(false);

            until GSTPaymentBuffer.Next() = 0;
        exit(true);
    end;

    local procedure CheckDimValuePosting(DocumentNo: Code[20]; DimSetID: Integer)
    var
        NumberArr: array[10] of Code[20];
        DummyTableIDArr: array[10] of Integer;
    begin
        NumberArr[1] := DocumentNo;
        if not DimensionManagement.CheckDimValuePosting(DummyTableIDArr, NumberArr, DimSetID) then
            Error(InvaidDimensionErr, DimensionManagement.GetDimValuePostingErr());
    end;

    local procedure PostGSTBuffer(GSTINNo: Code[20]; PaymentDocumentNo: Code[20])
    var
        GSTPaymentBuffer: Record "GST Payment Buffer";
        GSTPostingSetup: Record "GST Posting Setup";
        SourceCodeSetup: Record "Source Code Setup";
        EntryType: Option ,TDS,TCS;
        AccountType: Enum "Gen. Journal Account Type";
        AccountNo: Code[20];
        TotalPaymentAmount: Decimal;
        ReceivableAmount: Decimal;
        Sign: Decimal;
    begin
        SourceCodeSetup.Get();
        SourceCodeSetup.TestField("GST Settlement");
        Window.Open(UpdatingLedgersMsg);

        GSTPaymentBuffer.LockTable();
        Sign := -1;
        Clear(GenJnlPostLine);
        Clear(DimensionManagement);

        GSTPaymentBuffer.SetRange("GST Registration No.", GSTINNo);
        GSTPaymentBuffer.SetRange("Document No.", PaymentDocumentNo);
        if GSTPaymentBuffer.FindSet() then begin
            GSTPaymentBuffer."Document No." := GetSettlementDocumentNo(GSTPaymentBuffer."Posting Date", true);
            repeat
                if GSTPaymentBuffer."Surplus Credit" < 0 then
                    GSTPaymentBuffer.TestField("Surplus Credit", 0);
                AccountType := GSTPaymentBuffer."Account Type";
                AccountNo := GSTPaymentBuffer."Account No.";
                ChequeNo := GSTPaymentBuffer."Bank Reference No.";
                ChequeDate := GSTPaymentBuffer."Bank Reference Date";
                PostingDate := GSTPaymentBuffer."Posting Date";
                PostedDocumentNo := GSTPaymentBuffer."Document No.";

                if IsGSTPaymentApplicable(GSTPaymentBuffer) then begin
                    Window.Update(1, GSTPaymentBuffer."GST Component Code");
                    GSTPostingSetup.Get(GSTPaymentBuffer."Location State Code", GetComponentId(GSTPaymentBuffer."GST Component Code"));
                    TotalPaymentAmount +=
                        GSTPaymentBuffer."Payment Amount" +
                        GSTPaymentBuffer."GST TCS Liability" +
                        GSTPaymentBuffer.Interest +
                        GSTPaymentBuffer.Penalty +
                        GSTPaymentBuffer.Fees +
                        GSTPaymentBuffer.Others;

                    if GSTPaymentBuffer."Payment Liability - Rev. Chrg." > 0 then begin
                        TotalPaymentAmount += GSTPaymentBuffer."Payment Amount - Rev. Chrg.";
                        CreateAndPostGenJournalLine(
                            GSTPaymentBuffer."Account Type"::"G/L Account",
                            GetPayableAccount(GSTPostingSetup),
                            GSTPaymentBuffer."Payment Amount - Rev. Chrg.",
                            StrSubstNo(
                                GSTPaymentTypeTxt,
                                GSTPaymentBuffer."GST Component Code",
                                ReverseChargePaymentTxt),
                            GSTPaymentBuffer."Dimension Set ID");
                    end;

                    if GSTPaymentBuffer."Net Payment Liability" > 0 then
                        CreateAndPostGenJournalLine(
                            GSTPaymentBuffer."Account Type"::"G/L Account",
                            GetPayableAccount(GSTPostingSetup),
                            GSTPaymentBuffer."Net Payment Liability",
                            StrSubstNo(
                                GSTPaymentTypeTxt,
                                GSTPaymentBuffer."GST Component Code",
                                NetPaymentLibTxt),
                            GSTPaymentBuffer."Dimension Set ID");

                    if GSTPaymentBuffer."GST TDS Credit Utilized" > 0 then
                        CreateAndPostGenJournalLine(
                            GSTPaymentBuffer."Account Type"::"G/L Account",
                            GetGSTTDSReceivableAccount(GSTPostingSetup),
                            GSTPaymentBuffer."GST TDS Credit Utilized" * Sign,
                            StrSubstNo(
                                GSTPaymentTypeTxt,
                                GSTPaymentBuffer."GST Component Code",
                                GSTPaymentBuffer.FieldCaption("GST TDS Credit Utilized")),
                            GSTPaymentBuffer."Dimension Set ID");

                    if GSTPaymentBuffer."GST TCS Credit Utilized" > 0 then
                        CreateAndPostGenJournalLine(
                            GSTPaymentBuffer."Account Type"::"G/L Account",
                            GetGSTTCSReceivableAccount(GSTPostingSetup),
                            GSTPaymentBuffer."GST TCS Credit Utilized" * Sign,
                            StrSubstNo(
                                GSTPaymentTypeTxt,
                                GSTPaymentBuffer."GST Component Code",
                                GSTPaymentBuffer.FieldCaption("GST TCS Credit Utilized")),
                            GSTPaymentBuffer."Dimension Set ID");

                    if GSTPaymentBuffer."GST TCS Liability" > 0 then
                        CreateAndPostGenJournalLine(
                            GSTPaymentBuffer."Account Type"::"G/L Account",
                            GetGSTTCSPayableAccount(GSTPostingSetup),
                            GSTPaymentBuffer."GST TCS Liability",
                            StrSubstNo(
                                GSTPaymentTypeTxt,
                                GSTPaymentBuffer."GST Component Code",
                                GSTPaymentBuffer.FieldCaption("GST TCS Liability")),
                            GSTPaymentBuffer."Dimension Set ID");

                    if GSTPaymentBuffer.Interest > 0 then
                        CreateAndPostGenJournalLine(
                            GSTPaymentBuffer."Account Type"::"G/L Account",
                            GSTPaymentBuffer."Interest Account No.",
                            GSTPaymentBuffer.Interest,
                            StrSubstNo(
                                GSTPaymentTypeTxt,
                                GSTPaymentBuffer."GST Component Code",
                                GSTPaymentBuffer.FieldCaption(Interest)),
                            GSTPaymentBuffer."Dimension Set ID");

                    if GSTPaymentBuffer.Penalty > 0 then
                        CreateAndPostGenJournalLine(
                            GSTPaymentBuffer."Account Type"::"G/L Account",
                            GSTPaymentBuffer."Penalty Account No.",
                            GSTPaymentBuffer.Penalty,
                            StrSubstNo(
                                GSTPaymentTypeTxt,
                                GSTPaymentBuffer."GST Component Code",
                                GSTPaymentBuffer.FieldCaption(Penalty)),
                            GSTPaymentBuffer."Dimension Set ID");

                    if GSTPaymentBuffer.Fees > 0 then
                        CreateAndPostGenJournalLine(
                            GSTPaymentBuffer."Account Type"::"G/L Account",
                            GSTPaymentBuffer."Fees Account No.",
                            GSTPaymentBuffer.Fees,
                            StrSubstNo(
                                GSTPaymentTypeTxt,
                                GSTPaymentBuffer."GST Component Code",
                                GSTPaymentBuffer.FieldCaption(Fees)),
                            GSTPaymentBuffer."Dimension Set ID");

                    if GSTPaymentBuffer.Others > 0 then
                        CreateAndPostGenJournalLine(
                            GSTPaymentBuffer."Account Type"::"G/L Account",
                            GSTPaymentBuffer."Others Account No.",
                            GSTPaymentBuffer.Others,
                            StrSubstNo(
                                GSTPaymentTypeTxt,
                                GSTPaymentBuffer."GST Component Code",
                                GSTPaymentBuffer.FieldCaption(Others)),
                            GSTPaymentBuffer."Dimension Set ID");

                    if (GSTPaymentBuffer."Surplus Cr. Utilized" <> 0) then begin
                        ReceivableAmount := GSTPaymentBuffer."Surplus Cr. Utilized";

                        if ReceivableAmount > 0 then
                            CreateAndPostGenJournalLine(
                                GSTPaymentBuffer."Account Type"::"G/L Account",
                                GetRecAccount(GSTPostingSetup),
                                ReceivableAmount * Sign,
                                StrSubstNo(
                                    GSTPaymentTypeTxt,
                                    GSTPaymentBuffer."GST Component Code",
                                    CreditUtilizedTxt),
                                GSTPaymentBuffer."Dimension Set ID");
                    end;

                    if GSTPaymentBuffer."UnAdjutsed Credit" < 0 then begin
                        CreateAndPostGenJournalLine(
                            GSTPaymentBuffer."Account Type"::"G/L Account",
                            GetPayableAccount(GSTPostingSetup),
                            GSTPaymentBuffer."UnAdjutsed Credit",
                            StrSubstNo(
                                GSTPaymentTypeTxt,
                                GSTPaymentBuffer."GST Component Code",
                                UnadjustedCreditTxt),
                            GSTPaymentBuffer."Dimension Set ID");

                        CreateAndPostGenJournalLine(
                            GSTPaymentBuffer."Account Type"::"G/L Account",
                            GetRecAccount(GSTPostingSetup),
                            GSTPaymentBuffer."UnAdjutsed Credit" * Sign,
                            StrSubstNo(
                                GSTPaymentTypeTxt,
                                GSTPaymentBuffer."GST Component Code",
                                UnadjustedCreditTxt),
                            GSTPaymentBuffer."Dimension Set ID");
                    end;
                end;

                CloseDetailedGSTLedger(GSTPaymentBuffer);
                ClosePostedCreditAdjustmentEntry(GSTPaymentBuffer);
                ClosePostedCreditandLiabilitytEntry(GSTPaymentBuffer);
                CloseDetGSTDistEntry(GSTPaymentBuffer);
                CloseGSTTDSTCSEntry(GSTPaymentBuffer, EntryType::TDS, false);
                CloseGSTTDSTCSEntry(GSTPaymentBuffer, EntryType::TCS, false);
                CloseGSTTDSTCSEntry(GSTPaymentBuffer, EntryType::TCS, true);
                CloseDetailedGSTLedgerEntryForAdjustment(GSTPaymentBuffer);
            until GSTPaymentBuffer.Next() = 0;

            if TotalPaymentAmount > 0 then
                CreateAndPostGenJournalLine(
                    AccountType,
                    AccountNo,
                    TotalPaymentAmount * Sign,
                    StrSubstNo(
                        GSTPaymentTypeTxt,
                        GstTxt,
                        TotalPaymentTxt),
                    GSTPaymentBuffer."Dimension Set ID");
        end;

        Window.Close();
    end;

    local procedure CreateAndPostGenJournalLine(
                        AccountType: Enum "Gen. Journal Account Type";
                                         AccountNo: Code[20];
                                         PaymentAmount: Decimal;
                                         AmountType: Text[100];
                                         DimensionSetID: Integer)
    var
        GenJournalLine2: Record "Gen. Journal Line";
        AmountType2: Text[50];
    begin
        AmountType2 := CopyStr(AmountType, 1, 50);

        GenJournalLine2.Init();
        GenJournalLine2."Account Type" := AccountType;
        GenJournalLine2."Account No." := AccountNo;
        if AccountType = AccountType::"Bank Account" then begin
            GenJournalLine2."Bank Payment Type" := "Bank Payment Type"::"Manual Check";
            GenJournalLine2."Check Printed" := true;
        end;

        GenJournalLine2.Amount := PaymentAmount;
        GenJournalLine2."System-Created Entry" := true;
        GenJournalLine2."Document No." := PostedDocumentNo;
        GenJournalLine2."Posting Date" := PostingDate;
        GenJournalLine2."Dimension Set ID" := DimensionSetID;
        GenJournalLine2.Description := AmountType2;

        DimensionManagement.UpdateGlobalDimFromDimSetID(
            GenJournalLine2."Dimension Set ID",
            GenJournalLine2."Shortcut Dimension 1 Code",
            GenJournalLine2."Shortcut Dimension 2 Code");

        GenJnlPostLine.RunWithCheck(GenJournalLine2);
    end;

    local procedure GetComponentId(GSTGroupCode: Code[30]): Integer
    var
        GSTSetup: Record "GST Setup";
        TaxComponent: Record "Tax Component";
    begin
        if not GSTSetup.Get() then
            exit;
        GSTSetup.TestField("GST Tax Type");

        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxComponent.SetRange(Name, GSTGroupCode);
        if TaxComponent.FindFirst() then
            exit(TaxComponent.Id);
    end;

    local procedure GetPayableAccount(GSTPostingSetup: Record "GST Posting Setup"): Code[20]
    begin
        GSTPostingSetup.TestField("Payable Account");
        exit(GSTPostingSetup."Payable Account");
    end;

    local procedure GetGSTTDSReceivableAccount(GSTPostingSetup: Record "GST Posting Setup"): Code[20]
    begin
        GSTPostingSetup.TestField("GST TDS Receivable Account");
        exit(GSTPostingSetup."GST TDS Receivable Account");
    end;

    local procedure GetGSTTCSReceivableAccount(GSTPostingSetup: Record "GST Posting Setup"): Code[20]
    begin
        GSTPostingSetup.TestField("GST TCS Receivable Account");
        exit(GSTPostingSetup."GST TCS Receivable Account");
    end;

    local procedure GetGSTTCSPayableAccount(GSTPostingSetup: Record "GST Posting Setup"): Code[20]
    begin
        GSTPostingSetup.TestField("GST TCS Payable Account");
        exit(GSTPostingSetup."GST TCS Payable Account");
    end;

    local procedure GetRecAccount(GSTPostingSetup: Record "GST Posting Setup"): Code[20]
    begin
        GSTPostingSetup.TestField("Receivable Account");
        exit(GSTPostingSetup."Receivable Account");
    end;

    local procedure CloseDetailedGSTLedger(var GSTPaymentBuffer: Record "GST Payment Buffer")
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntry2: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        FilterDetailedGSTLedgerEntry(GSTPaymentBuffer, DetailedGSTLedgerEntry);
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                if not ((DetailedGSTLedgerEntry."ARN No." <> '') and (DetailedGSTLedgerEntry."Buyer/Seller Reg. No." = '')) then begin
                    DetailedGSTLedgerEntry2.Get(DetailedGSTLedgerEntry."Entry No.");
                    DetailedGSTLedgerEntry2."Payment Document No." := GSTPaymentBuffer."Document No.";
                    DetailedGSTLedgerEntry2.Paid := true;
                    DetailedGSTLedgerEntry2.Modify();

                    GetDetailedGSTLedgerEnfo(DetailedGSTLedgerEntry."Entry No.", DetailedGSTLedgerEntryInfo);
                    DetailedGSTLedgerEntryInfo."Payment Document Date" := GSTPaymentBuffer."Posting Date";
                    DetailedGSTLedgerEntryInfo.Modify();
                end;
            until DetailedGSTLedgerEntry.Next() = 0;
        InsertPostedSettlementEntries(GSTPaymentBuffer);
    end;

    local procedure InsertPostedSettlementEntries(GSTPaymentBuffer: Record "GST Payment Buffer")
    var
        PostedSettlementEntries: Record "Posted Settlement Entries";
    begin
        PostedSettlementEntries.Init();
        PostedSettlementEntries.TransferFields(GSTPaymentBuffer);
        PostedSettlementEntries.Insert(true);
    end;

    local procedure ClosePostedCreditAdjustmentEntry(GSTPaymentBuffer: Record "GST Payment Buffer")
    var
        DetailedCrAdjstmntEntry: Record "Detailed Cr. Adjstmnt. Entry";
        DetailedCrAdjstmntEntry2: Record "Detailed Cr. Adjstmnt. Entry";
    begin
        FilterPostedCreditAdjustmentEntry(GSTPaymentBuffer, DetailedCrAdjstmntEntry);
        if DetailedCrAdjstmntEntry.FindSet() then
            repeat
                DetailedCrAdjstmntEntry2.Get(DetailedCrAdjstmntEntry."Entry No.");
                DetailedCrAdjstmntEntry2.Paid := true;
                DetailedCrAdjstmntEntry2."Payment Document No." := GSTPaymentBuffer."Document No.";
                DetailedCrAdjstmntEntry2."Payment Document Date" := GSTPaymentBuffer."Posting Date";
                DetailedCrAdjstmntEntry2.Modify();
            until DetailedCrAdjstmntEntry.Next() = 0;
    end;

    local procedure ClosePostedCreditandLiabilitytEntry(GSTPaymentBuffer: Record "GST Payment Buffer")
    var
        PostedGSTLiabilityAdj: Record "Posted GST Liability Adj.";
        PostedGSTLiabilityAdj2: Record "Posted GST Liability Adj.";
    begin
        FilterPostedCreditandLiabilityEntry(GSTPaymentBuffer, PostedGSTLiabilityAdj);
        if PostedGSTLiabilityAdj.FindSet() then
            repeat
                PostedGSTLiabilityAdj2.Get(PostedGSTLiabilityAdj."Entry No.");
                PostedGSTLiabilityAdj2.Paid := true;
                PostedGSTLiabilityAdj2."Payment Document No." := GSTPaymentBuffer."Document No.";
                PostedGSTLiabilityAdj2."Payment Document Date" := GSTPaymentBuffer."Posting Date";
                PostedGSTLiabilityAdj2.Modify();
            until PostedGSTLiabilityAdj.Next() = 0;
    end;

    local procedure CloseDetGSTDistEntry(GSTPaymentBuffer: Record "GST Payment Buffer")
    var
        DetailedGSTDistEntry: Record "Detailed GST Dist. Entry";
        DetailedGSTDistEntry2: Record "Detailed GST Dist. Entry";
    begin
        FilterDetGSTDistEntry(GSTPaymentBuffer, DetailedGSTDistEntry, false);
        if DetailedGSTDistEntry.FindSet() then
            repeat
                DetailedGSTDistEntry2.Get(DetailedGSTDistEntry."Entry No.");
                DetailedGSTDistEntry2.Paid := true;
                DetailedGSTDistEntry2."Payment Document No." := GSTPaymentBuffer."Document No.";
                DetailedGSTDistEntry2."Payment Document Date" := GSTPaymentBuffer."Posting Date";
                DetailedGSTDistEntry2.Modify();
            until DetailedGSTDistEntry.Next() = 0;
    end;

    local procedure CloseGSTTDSTCSEntry(
        GSTPaymentBuffer: Record "GST Payment Buffer";
        EntryType: Option " ",TDS,TCS;
        VendorGSTTCS: Boolean)
    var
        GSTTdsTcsEntry: Record "GST TDS/TCS Entry";
        GSTTdsTcsEntry2: Record "GST TDS/TCS Entry";
    begin
        if EntryType = EntryType::TDS then
            FilterGSTTDSTCSEntry(GSTPaymentBuffer, GSTTdsTcsEntry, EntryType::TDS, false)
        else
            if VendorGSTTCS then
                FilterGSTTDSTCSEntry(GSTPaymentBuffer, GSTTdsTcsEntry, EntryType::TCS, true)
            else
                FilterGSTTDSTCSEntry(GSTPaymentBuffer, GSTTdsTcsEntry, EntryType::TCS, false);

        if GSTTdsTcsEntry.FindSet() then
            repeat
                GSTTdsTcsEntry2.Get(GSTTdsTcsEntry."Entry No.");
                GSTTdsTcsEntry2.Paid := true;
                GSTTdsTcsEntry2."Payment Document No." := GSTPaymentBuffer."Document No.";
                GSTTdsTcsEntry2."Payment Document Date" := GSTPaymentBuffer."Posting Date";
                GSTTdsTcsEntry2.Modify();
            until GSTTdsTcsEntry.Next() = 0;
    end;

    local procedure CloseDetailedGSTLedgerEntryForAdjustment(var GSTPaymentBuffer: Record "GST Payment Buffer")
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntry2: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        FilterDetailedGSTLedgerEntryforAdjustment(GSTPaymentBuffer, DetailedGSTLedgerEntry);
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                if not ((DetailedGSTLedgerEntry."ARN No." <> '') and (DetailedGSTLedgerEntry."Buyer/Seller Reg. No." = '')) then begin
                    DetailedGSTLedgerEntry2.Get(DetailedGSTLedgerEntry."Entry No.");
                    DetailedGSTLedgerEntry2."Payment Document No." := GSTPaymentBuffer."Document No.";
                    DetailedGSTLedgerEntry2.Paid := true;
                    DetailedGSTLedgerEntry2.Modify();

                    GetDetailedGSTLedgerEnfo(DetailedGSTLedgerEntry."Entry No.", DetailedGSTLedgerEntryInfo);
                    DetailedGSTLedgerEntryInfo."Payment Document Date" := GSTPaymentBuffer."Posting Date";
                    DetailedGSTLedgerEntryInfo.Modify();
                end;
            until DetailedGSTLedgerEntry.Next() = 0;
    end;

    local procedure GSTSettlementAccTypeEnum2GenJnlAccType(GSTSettAccType: Enum "GST Settlement Account Type"): Enum "Gen. Journal Account Type"
    var
        ConversionErr: Label 'Account Type %1 is not a valid option.', Comment = '%1 = GST Settlement Account Type';
    begin
        case GSTSettAccType of
            GSTSettAccType::"G/L Account":
                exit("Gen. Journal Account Type"::"G/L Account");
            GSTSettAccType::"Bank Account":
                exit("Gen. Journal Account Type"::"Bank Account");
            else
                Error(ConversionErr, GSTSettAccType);
        end;
    end;

    procedure ValidateCreditUtilizedAmt(GSTINNo: Code[20]; DocumentNo: Code[20])
    var
        GSTPaymentBuffer: Record "GST Payment Buffer";
        GSTPaymentBuffer2: Record "GST Payment Buffer";
        GSTClaimSetoff: Record "GST Claim Setoff";
        GSTPaymentBufferDetails: Record "GST Payment Buffer Details";
        AvailableAmount: Decimal;
        CreditUtilizedAmount: Decimal;
        LineNo: Integer;
    begin
        GSTPaymentBuffer.SetRange("GST Registration No.", GSTINNo);
        GSTPaymentBuffer.SetRange("Document No.", DocumentNo);
        if GSTPaymentBuffer.FindSet() then
            repeat
                GSTPaymentBuffer."Surplus Cr. Utilized" := 0;
                GSTPaymentBuffer."Carry Forward" := 0;
                GSTPaymentBuffer."Surplus Credit" := GSTPaymentBuffer."Total Credit Available";
                GSTPaymentBuffer.Modify(true);
            Until GSTPaymentBuffer.Next() = 0;

        GSTPaymentBufferDetails.Reset();
        if GSTPaymentBufferDetails.FindFirst() then
            GSTPaymentBufferDetails.DeleteAll();

        GSTPaymentBuffer.Reset();
        GSTPaymentBuffer.SetRange("GST Registration No.", GSTINNo);
        GSTPaymentBuffer.SetRange("Document No.", DocumentNo);
        if GSTPaymentBuffer.FindSet() then
            repeat
                if GSTPaymentBuffer."Credit Utilized" > 0 then begin
                    AvailableAmount := 0;
                    CreditUtilizedAmount := GSTPaymentBuffer."Credit Utilized";

                    GSTClaimSetoff.Reset();
                    GSTClaimSetoff.SETCURRENTKEY(Priority);
                    GSTClaimSetoff.SetRange("GST Component Code", GSTPaymentBuffer."GST Component Code");
                    if GSTClaimSetoff.FindSet() then
                        repeat
                            GSTPaymentBuffer2.Get(GSTINNo, DocumentNo, GSTClaimSetoff."Set Off Component Code");
                            GSTPaymentBufferDetails.Init();
                            GSTPaymentBufferDetails."GST Registration No." := GSTPaymentBuffer."GST Registration No.";
                            GSTPaymentBufferDetails."Document No." := GSTPaymentBuffer."Document No.";
                            GSTPaymentBufferDetails."GST Component Code" := GSTPaymentBuffer."GST Component Code";
                            GSTPaymentBufferDetails."Net Payment Liability" := GSTPaymentBuffer."Net Payment Liability";
                            GSTPaymentBufferDetails."Payment Liability" := GSTPaymentBuffer."Payment Liability";
                            GSTPaymentBufferDetails."SetOff Component Code" := GSTPaymentBuffer2."GST Component Code";
                            if GSTPaymentBuffer2."Total Credit Available" > 0 then begin
                                AvailableAmount += GSTPaymentBuffer2."Total Credit Available" - GSTPaymentBuffer2."Surplus Cr. Utilized";
                                if AvailableAmount > 0 then begin
                                    GSTPaymentBufferDetails."Total Credit Available" := AvailableAmount;

                                    if AvailableAmount >= CreditUtilizedAmount then begin
                                        if GSTPaymentBuffer."GST Component Code" = GSTPaymentBuffer2."GST Component Code" then begin
                                            GSTPaymentBuffer."Surplus Cr. Utilized" += CreditUtilizedAmount;
                                            GSTPaymentBuffer."Surplus Credit" -= CreditUtilizedAmount;
                                            GSTPaymentBuffer."Carry Forward" := GSTPaymentBuffer."Surplus Credit";
                                            GSTPaymentBuffer.Modify(true);
                                            GSTPaymentBuffer2.Get(GSTINNo, DocumentNo, GSTClaimSetoff."Set Off Component Code");
                                        end else begin
                                            GSTPaymentBuffer2."Surplus Cr. Utilized" += CreditUtilizedAmount;
                                            GSTPaymentBuffer2."Surplus Credit" -= CreditUtilizedAmount;
                                        end;

                                        GSTPaymentBufferDetails."Credit Utilized" := CreditUtilizedAmount;
                                        GSTPaymentBufferDetails."Surplus Credit" := GSTPaymentBuffer2."Surplus Credit";
                                        CreditUtilizedAmount := 0;
                                    end else begin
                                        if GSTPaymentBuffer."GST Component Code" = GSTPaymentBuffer2."GST Component Code" then begin
                                            GSTPaymentBuffer."Surplus Cr. Utilized" += AvailableAmount;
                                            GSTPaymentBuffer."Surplus Credit" -= AvailableAmount;
                                            GSTPaymentBuffer."Carry Forward" := GSTPaymentBuffer."Surplus Credit";
                                            GSTPaymentBuffer.Modify(true);
                                            GSTPaymentBuffer2.Get(GSTINNo, DocumentNo, GSTClaimSetoff."Set Off Component Code");
                                        end else begin
                                            GSTPaymentBuffer2."Surplus Cr. Utilized" += AvailableAmount;
                                            GSTPaymentBuffer2."Surplus Credit" -= AvailableAmount;
                                        end;

                                        GSTPaymentBufferDetails."Credit Utilized" := AvailableAmount;
                                        GSTPaymentBufferDetails."Surplus Credit" := GSTPaymentBuffer2."Surplus Credit";
                                        CreditUtilizedAmount -= AvailableAmount;
                                        AvailableAmount := 0;
                                    end;

                                    GSTPaymentBuffer2."Carry Forward" := GSTPaymentBuffer2."Surplus Credit";
                                    GSTPaymentBuffer2.Modify(true);
                                    GSTPaymentBuffer.Modify(true);
                                end;
                            end;
                            LineNo += 10000;
                            GSTPaymentBufferDetails."Line No." := LineNo;
                            GSTPaymentBufferDetails.Insert();
                        Until (GSTClaimSetoff.Next() = 0) OR (CreditUtilizedAmount = 0);
                end;
            Until GSTPaymentBuffer.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAllocateGstAppliedAmounts(TotalInvoiceAmount: Decimal; RemainingAmount: Decimal; var GSTLiabilityBuffer: Record "GST Liability Buffer"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAllocateGstAppliedAmount(TotalInvoiceAmount: Decimal; RemainingAmount: Decimal; var GSTLiabilityBuffer: Record "GST Liability Buffer"; DocumentNo: Code[20])
    begin
    end;
}
