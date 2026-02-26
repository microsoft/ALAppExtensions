// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.BatchProcessing;
using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.Reporting;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;

codeunit 6785 "Withholding Tax Mgmt."
{
    var
        PurchInvLine: Record "Purch. Inv. Line";
        PurchaseInvLine: Record "Purch. Inv. Line";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        PurchaseCrMemoLine: Record "Purch. Cr. Memo Line";
        WithholdingPostingSetup: Record "Withholding Tax Posting Setup";
        CurrExchRate: Record "Currency Exchange Rate";
        VendorLedgerEntries: Record "Vendor Ledger Entry";
        VendorLedgerEntries1: Record "Vendor Ledger Entry";
        TempGenJnlLine: Record "Gen. Journal Line" temporary;
        DocType: Enum "Gen. Journal Document Type";
        ApplyDocType: Enum "Gen. Journal Document Type";
        PayToAccType: Option Vendor,Customer;
        TType: Option Purchase,Sale;
        BuyFromAccType: Option Vendor,Customer;
        TransType: Option Purchase,Sale,Settlement;
        DocDate: Date;
        PostingDate: Date;
        WithholdingBusPostGrp: Code[20];
        WithholdingProdPostGrp: Code[20];
        "Applies-toID": Code[50];
        CurrencyCode: Code[10];
        DocNo: Code[20];
        PayToVendCustNo: Code[20];
        BuyFromVendCustNo: Code[20];
        ApplyDocNo: Code[20];
        WithholdingRevenueType: Code[10];
        Dim1: Code[20];
        Dim2: Code[20];
        ExtDocNo: Code[20];
        WithholdingReportLineNo: Code[10];
        SourceCode: Code[10];
        ReasonCode: Code[10];
        GenBusPostGrp: Code[20];
        GenProdPostGrp: Code[20];
        OnesText: array[20] of Text[30];
        TensText: array[10] of Text[30];
        ExponentText: array[5] of Text[30];
        TotalInvoiceAmount: Decimal;
        TotalInvoiceAmountLCY: Decimal;
        AppliedBase: Decimal;
        AmountVAT: Decimal;
        Amount: Decimal;
        AbsorbBase: Decimal;
        CurrFactor: Decimal;
        TotAmt: Decimal;
        TempRemAmt: Decimal;
        TempRemBase: Decimal;
        WithholdingMinInvoiceAmt: Decimal;
        NextWithholdingTaxEntryNo: Integer;
        ExitLoop: Boolean;
        UnrealizedWithholding: Boolean;
        ActualVendorNo: Code[20];
        CurrencyCodeSameErr: Label 'Currency Code should be same for Payment and Invoice.';
        WithholdingMinInvNotConsistentErr: Label 'You cannot post a transaction using different Withholding Tax minimum invoice amounts on lines.';
        DiffWithholdingPostGroupsErr: Label 'The Withholding Tax posting groups are different and thus the entries cannot be apply.';
        MissingRevenueTypeErr: Label 'The Withholding Tax Entry you are trying to process contains WHT Revenue Type `%1`. Please add this value to your Withholding Revenue Types and post again.', Comment = '%1 = Withholding Revenue Type';
        MustbeNegativeLbl: Label 'must be positive.';
        OneLbl: Label 'ONE';
        TwoLbl: Label 'TWO';
        ThreeLbl: Label 'THREE';
        FourLbl: Label 'FOUR';
        FiveLbl: Label 'FIVE';
        SixLbl: Label 'SIX';
        SevenLbl: Label 'SEVEN';
        EightLbl: Label 'EIGHT';
        NineLbl: Label 'NINE';
        TenLbl: Label 'TEN';
        ElevenLbl: Label 'ELEVEN';
        TwelveLbl: Label 'TWELVE';
        ThirteenLbl: Label 'THIRTEEN';
        FourteenLbl: Label 'FOURTEEN';
        FifteenLbl: Label 'FIFTEEN';
        SixteenLbl: Label 'SIXTEEN';
        SeventeenLbl: Label 'SEVENTEEN';
        EighteenLbl: Label 'EIGHTEEN';
        NinteenLbl: Label 'NINETEEN';
        TwentyLbl: Label 'TWENTY';
        ThirtyLbl: Label 'THIRTY';
        FortyLbl: Label 'FORTY';
        FiftyLbl: Label 'FIFTY';
        SixtyLbl: Label 'SIXTY';
        SeventyLbl: Label 'SEVENTY';
        EightyLbl: Label 'EIGHTY';
        NinetyLbl: Label 'NINETY';
        ThousandLbl: Label 'THOUSAND';
        MillionLbl: Label 'MILLION';
        BillionLbl: Label 'BILLION';
        HundredLbl: Label 'HUNDRED';
        ZeroLbl: Label 'ZERO';
        AndLbl: Label 'AND';

    procedure CheckApplicationPurchWithholdingTax(var PurchHeader: Record "Purchase Header")
    var
        VendorLedgEntry: Record "Vendor Ledger Entry";
        WithholdingTaxEntry: Record "Withholding Tax Entry";
        PurchLine1: Record "Purchase Line";
    begin
        if PurchHeader."Applies-to Doc. No." <> '' then
            VendorLedgEntry.SetRange("Document No.", PurchHeader."Applies-to Doc. No.")
        else
            VendorLedgEntry.SetRange("Applies-to ID", PurchHeader."Applies-to ID");

        if VendorLedgEntry.FindSet() then
            repeat
                WithholdingTaxEntry.Reset();
                WithholdingTaxEntry.SetRange("Document No.", VendorLedgEntry."Document No.");
                WithholdingTaxEntry.SetRange("Transaction Type", WithholdingTaxEntry."Transaction Type"::Purchase);
                if WithholdingTaxEntry.FindSet() then
                    repeat
                        PurchLine1.Reset();
                        PurchLine1.SetRange("Document No.", PurchHeader."No.");
                        PurchLine1.SetRange("Document Type", PurchHeader."Document Type");
                        PurchLine1.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group");
                        PurchLine1.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                        if not PurchLine1.FindFirst() then
                            Error(DiffWithholdingPostGroupsErr);
                    until WithholdingTaxEntry.Next() = 0;
            until VendorLedgEntry.Next() = 0;
    end;

    procedure CheckApplicationGenPurchWithholdingTax(var GenJnlLine: Record "Gen. Journal Line")
    var
        VendorLedgEntry: Record "Vendor Ledger Entry";
        WithholdingTaxEntry: Record "Withholding Tax Entry";
    begin
        if (GenJnlLine."Applies-to Doc. No." <> '') or
           (GenJnlLine."Applies-to ID" <> '')
        then begin
            VendorLedgEntry.Reset();
            if GenJnlLine."Applies-to Doc. No." <> '' then
                VendorLedgEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.")
            else
                VendorLedgEntry.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");
            if VendorLedgEntry.FindSet() then
                repeat
                    WithholdingTaxEntry.Reset();
                    WithholdingTaxEntry.SetRange("Document No.", VendorLedgEntry."Document No.");
                    WithholdingTaxEntry.SetRange("Transaction Type", WithholdingTaxEntry."Transaction Type"::Purchase);
                    if WithholdingTaxEntry.FindSet() then
                        repeat
                            GenJnlLine.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group");
                            GenJnlLine.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                            if not GenJnlLine.FindFirst() then
                                Error(DiffWithholdingPostGroupsErr);
                        until WithholdingTaxEntry.Next() = 0;
                until VendorLedgEntry.Next() = 0;
        end;
    end;

    procedure InsertVendInvoiceWithholdingTax(var PurchInvHeader: Record "Purch. Inv. Header")
    var
        PurchaseLine: Record "Purchase Line";
        GLSetup: Record "General Ledger Setup";
        Vendor: Record Vendor;
        PrepaymentAmtDeducted: Decimal;
    begin
        PurchInvLine.Reset();
        PurchInvLine.SetCurrentKey("Document No.", "Wthldg. Tax Bus. Post. Group", "Wthldg. Tax Prod. Post. Group");
        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
        PurchInvLine.SetFilter(Quantity, '<>0');
        if PurchInvLine.FindSet() then begin
            WithholdingBusPostGrp := PurchInvLine."Wthldg. Tax Bus. Post. Group";
            WithholdingProdPostGrp := PurchInvLine."Wthldg. Tax Prod. Post. Group";
            if WithholdingPostingSetup.Get(PurchInvLine."Wthldg. Tax Bus. Post. Group", PurchInvLine."Wthldg. Tax Prod. Post. Group") then
                WithholdingMinInvoiceAmt := WithholdingPostingSetup."Wthldg. Tax Min. Inv. Amount";
            repeat
                if WithholdingPostingSetup.Get(PurchInvLine."Wthldg. Tax Bus. Post. Group", PurchInvLine."Wthldg. Tax Prod. Post. Group") then begin
                    if (WithholdingBusPostGrp <> PurchInvLine."Wthldg. Tax Bus. Post. Group") or
                       (WithholdingProdPostGrp <> PurchInvLine."Wthldg. Tax Prod. Post. Group")
                    then
                        if WithholdingMinInvoiceAmt <> WithholdingPostingSetup."Wthldg. Tax Min. Inv. Amount" then
                            Error(WithholdingMinInvNotConsistentErr);

                    WithholdingBusPostGrp := PurchInvLine."Wthldg. Tax Bus. Post. Group";
                    WithholdingProdPostGrp := PurchInvLine."Wthldg. Tax Prod. Post. Group";
                end;
            until PurchInvLine.Next() = 0;
        end;

        GLSetup.Get();
        if GLSetup."Enable Withholding Tax" then begin
            Vendor.Get(PurchInvHeader."Pay-to Vendor No.");

            TotalInvoiceAmount := 0;
            TotalInvoiceAmountLCY := 0;
            PurchaseInvLine.Reset();
            PurchaseInvLine.SetRange("Document No.", PurchInvHeader."No.");
            PurchaseInvLine.SetFilter(Quantity, '<>0');
            PurchaseInvLine.SetRange("Prepayment Line", false);
            if PurchaseInvLine.FindSet() then
                repeat
                    if WithholdingPostingSetup.Get(
                         PurchaseInvLine."Wthldg. Tax Bus. Post. Group",
                         PurchaseInvLine."Wthldg. Tax Prod. Post. Group")
                    then
                        if PurchaseInvLine."Withholding Tax Absorb Base" <> 0 then
                            TotalInvoiceAmount := TotalInvoiceAmount + PurchaseInvLine."Withholding Tax Absorb Base"
                        else
                            TotalInvoiceAmount := TotalInvoiceAmount + PurchaseInvLine.Amount
                until PurchaseInvLine.Next() = 0;

            if PurchInvHeader."Currency Code" = '' then
                TotalInvoiceAmountLCY := TotalInvoiceAmount
            else
                TotalInvoiceAmountLCY :=
                  Round(
                    CurrExchRate.ExchangeAmtFCYToLCY(
                      PurchInvHeader."Document Date",
                      PurchInvHeader."Currency Code",
                      TotalInvoiceAmount,
                      PurchInvHeader."Currency Factor"));

            if CheckWithholdingCalculationRule(TotalInvoiceAmountLCY, WithholdingPostingSetup) then
                exit;
        end;

        PurchInvLine.Reset();
        PurchInvLine.SetCurrentKey("Document No.", "Wthldg. Tax Bus. Post. Group", "Wthldg. Tax Prod. Post. Group");
        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
        PurchInvLine.SetFilter(Quantity, '<>0');
        PurchInvLine.SetRange("Prepayment Line", false);
        if PurchInvLine.FindSet() then
            repeat
                if WithholdingPostingSetup.Get(PurchInvLine."Wthldg. Tax Bus. Post. Group", PurchInvLine."Wthldg. Tax Prod. Post. Group") then
                    if WithholdingPostingSetup."Withholding Tax %" > 0 then begin
                        DocNo := PurchInvLine."Document No.";
                        DocType := DocType::Invoice;
                        PayToAccType := PayToAccType::Vendor;
                        PayToVendCustNo := PurchInvHeader."Pay-to Vendor No.";
                        BuyFromAccType := BuyFromAccType::Vendor;
                        GenBusPostGrp := PurchInvLine."Gen. Bus. Posting Group";
                        GenProdPostGrp := PurchInvLine."Gen. Prod. Posting Group";
                        TransType := TransType::Purchase;
                        PostingDate := PurchInvHeader."Posting Date";
                        DocDate := PurchInvHeader."Document Date";
                        CurrencyCode := PurchInvHeader."Currency Code";
                        CurrFactor := PurchInvHeader."Currency Factor";
                        ApplyDocType := PurchInvHeader."Applies-to Doc. Type";
                        ApplyDocNo := PurchInvHeader."Applies-to Doc. No.";
                        SourceCode := PurchInvHeader."Source Code";
                        ReasonCode := PurchInvHeader."Reason Code";

                        if (WithholdingBusPostGrp <> PurchInvLine."Wthldg. Tax Bus. Post. Group") or
                           (WithholdingProdPostGrp <> PurchInvLine."Wthldg. Tax Prod. Post. Group")
                        then begin
                            if AmountVAT <> 0 then begin
                                if WithholdingPostingSetup."Realized Withholding Tax Type" in
                                   [WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest,
                                    WithholdingPostingSetup."Realized Withholding Tax Type"::Invoice]
                                then begin
                                    PurchaseLine.Reset();
                                    PurchaseLine.SetCurrentKey("Document Type", "Document No.",
                                      "Wthldg. Tax Bus. Post. Group", "Wthldg. Tax Prod. Post. Group");
                                    PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
                                    PurchaseLine.SetRange("Document No.", PurchInvHeader."Order No.");
                                    PurchaseLine.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingBusPostGrp);
                                    PurchaseLine.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingProdPostGrp);
                                    PurchaseLine.CalcSums(PurchaseLine."Prepmt. Amt. Inv.", PurchaseLine."Prepmt Amt to Deduct");
                                    PrepaymentAmtDeducted := PurchaseLine."Prepmt Amt to Deduct";
                                    AmountVAT := AmountVAT - PrepaymentAmtDeducted;
                                end;

                                InsertWithholdingTax(TType::Purchase);
                            end;

                            WithholdingBusPostGrp := PurchInvLine."Wthldg. Tax Bus. Post. Group";
                            WithholdingProdPostGrp := PurchInvLine."Wthldg. Tax Prod. Post. Group";
                            PurchInvHeader.Amount := 0;
                            AbsorbBase := 0;
                            AmountVAT := 0;
                            PurchInvHeader.Amount := PurchInvHeader.Amount + PurchInvLine.Amount;
                            AbsorbBase := AbsorbBase + PurchInvLine."Withholding Tax Absorb Base";

                            if AbsorbBase <> 0 then
                                AmountVAT := AbsorbBase
                            else
                                AmountVAT := PurchInvHeader.Amount;
                        end else begin
                            WithholdingBusPostGrp := PurchInvLine."Wthldg. Tax Bus. Post. Group";
                            WithholdingProdPostGrp := PurchInvLine."Wthldg. Tax Prod. Post. Group";
                            PurchInvHeader.Amount := PurchInvHeader.Amount + PurchInvLine.Amount;
                            AbsorbBase := AbsorbBase + PurchInvLine."Withholding Tax Absorb Base";

                            if AbsorbBase <> 0 then
                                AmountVAT := AbsorbBase
                            else
                                AmountVAT := PurchInvHeader.Amount;
                        end;

                        WithholdingBusPostGrp := PurchInvLine."Wthldg. Tax Bus. Post. Group";
                        WithholdingProdPostGrp := PurchInvLine."Wthldg. Tax Prod. Post. Group";
                    end;
            until PurchInvLine.Next() = 0;

        if WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest then begin
            PurchaseLine.Reset();
            PurchaseLine.SetCurrentKey("Document Type", "Document No.", "Wthldg. Tax Bus. Post. Group", "Wthldg. Tax Prod. Post. Group");
            PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
            PurchaseLine.SetRange("Document No.", PurchInvHeader."Order No.");
            PurchaseLine.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingBusPostGrp);
            PurchaseLine.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingProdPostGrp);
            PurchaseLine.CalcSums(PurchaseLine."Prepmt. Amt. Inv.", PurchaseLine."Prepmt Amt to Deduct");
            PrepaymentAmtDeducted := PurchaseLine."Prepmt Amt to Deduct";

            if AmountVAT <> 0 then
                AmountVAT := AmountVAT - PrepaymentAmtDeducted;
        end;

        InsertWithholdingTax(TType::Purchase);
    end;

    procedure InsertVendCreditWithholding(var PurchCreditHeader: Record "Purch. Cr. Memo Hdr."; AppliesID: Code[50])
    var
        WithholdingTaxEntry: Record "Withholding Tax Entry";
        GLSetup: Record "General Ledger Setup";
        Vendor: Record Vendor;
    begin
        PurchCrMemoLine.Reset();
        PurchCrMemoLine.SetCurrentKey("Document No.", "Wthldg. Tax Bus. Post. Group", "Wthldg. Tax Prod. Post. Group");
        PurchCrMemoLine.SetRange("Document No.", PurchCreditHeader."No.");
        PurchCrMemoLine.SetFilter(Quantity, '<>0');
        if PurchCrMemoLine.FindSet() then begin
            WithholdingBusPostGrp := PurchCrMemoLine."Wthldg. Tax Bus. Post. Group";
            WithholdingProdPostGrp := PurchCrMemoLine."Wthldg. Tax Prod. Post. Group";

            if WithholdingPostingSetup.Get(PurchCrMemoLine."Wthldg. Tax Bus. Post. Group", PurchCrMemoLine."Wthldg. Tax Prod. Post. Group") then
                WithholdingMinInvoiceAmt := WithholdingPostingSetup."Wthldg. Tax Min. Inv. Amount";
            repeat
                if WithholdingPostingSetup.Get(PurchCrMemoLine."Wthldg. Tax Bus. Post. Group", PurchCrMemoLine."Wthldg. Tax Prod. Post. Group") then begin
                    if (WithholdingBusPostGrp <> PurchCrMemoLine."Wthldg. Tax Bus. Post. Group") or
                       (WithholdingProdPostGrp <> PurchCrMemoLine."Wthldg. Tax Prod. Post. Group")
                    then
                        if WithholdingMinInvoiceAmt <> WithholdingPostingSetup."Wthldg. Tax Min. Inv. Amount" then
                            Error(WithholdingMinInvNotConsistentErr);

                    WithholdingBusPostGrp := PurchCrMemoLine."Wthldg. Tax Bus. Post. Group";
                    WithholdingProdPostGrp := PurchCrMemoLine."Wthldg. Tax Prod. Post. Group";
                end;
            until PurchCrMemoLine.Next() = 0;
        end;

        GLSetup.Get();
        if GLSetup."Enable Withholding Tax" then begin
            Vendor.Get(PurchCreditHeader."Pay-to Vendor No.");

            TotalInvoiceAmount := 0;
            TotalInvoiceAmountLCY := 0;
            PurchaseCrMemoLine.Reset();
            PurchaseCrMemoLine.SetRange("Document No.", PurchCreditHeader."No.");
            PurchaseCrMemoLine.SetFilter(Quantity, '<>0');
            if PurchaseCrMemoLine.FindSet() then
                repeat
                    if WithholdingPostingSetup.Get(
                         PurchaseCrMemoLine."Wthldg. Tax Bus. Post. Group",
                         PurchaseCrMemoLine."Wthldg. Tax Prod. Post. Group")
                    then
                        if PurchaseCrMemoLine."Withholding Tax Absorb Base" <> 0 then
                            TotalInvoiceAmount := TotalInvoiceAmount + PurchaseCrMemoLine."Withholding Tax Absorb Base"
                        else
                            TotalInvoiceAmount := TotalInvoiceAmount + PurchaseCrMemoLine.Amount;
                until PurchaseCrMemoLine.Next() = 0;

            if PurchCreditHeader."Currency Code" = '' then
                TotalInvoiceAmountLCY := TotalInvoiceAmount
            else
                TotalInvoiceAmountLCY :=
                  Round(
                    CurrExchRate.ExchangeAmtFCYToLCY(
                      PurchCreditHeader."Document Date",
                      PurchCreditHeader."Currency Code",
                      TotalInvoiceAmount,
                      PurchCreditHeader."Currency Factor"));

            VendorLedgerEntries.Reset();
            if ((PurchCreditHeader."Applies-to Doc. Type" = PurchCreditHeader."Applies-to Doc. Type"::Invoice) and
                (PurchCreditHeader."Applies-to Doc. No." <> ''))
            then
                VendorLedgerEntries.SetRange("Document No.", PurchCreditHeader."Applies-to Doc. No.")
            else
                if AppliesID <> '' then
                    VendorLedgerEntries.SetRange("Applies-to ID", AppliesID);

            if VendorLedgerEntries.GetFilters <> '' then begin
                if VendorLedgerEntries.FindSet() then begin
                    WithholdingTaxEntry.Reset();
                    WithholdingTaxEntry.SetRange("Transaction Type", WithholdingTaxEntry."Transaction Type"::Purchase);
                    WithholdingTaxEntry.SetRange("Document No.", VendorLedgerEntries."Document No.");
                    if not WithholdingTaxEntry.FindFirst() then
                        if CheckWithholdingCalculationRule(TotalInvoiceAmountLCY, WithholdingPostingSetup) then
                            exit;
                end;
            end else
                if CheckWithholdingCalculationRule(TotalInvoiceAmountLCY, WithholdingPostingSetup) then
                    exit;
        end;

        PurchCrMemoLine.Reset();
        PurchCrMemoLine.SetCurrentKey("Document No.", "Wthldg. Tax Bus. Post. Group", "Wthldg. Tax Prod. Post. Group");
        PurchCrMemoLine.SetRange("Document No.", PurchCreditHeader."No.");
        PurchCrMemoLine.SetFilter(Quantity, '<>0');
        if PurchCrMemoLine.FindSet() then
            repeat
                if WithholdingPostingSetup.Get(PurchCrMemoLine."Wthldg. Tax Bus. Post. Group", PurchCrMemoLine."Wthldg. Tax Prod. Post. Group") then
                    if WithholdingPostingSetup."Withholding Tax %" > 0 then begin
                        DocNo := PurchCrMemoLine."Document No.";
                        DocType := DocType::"Credit Memo";
                        PayToAccType := PayToAccType::Vendor;
                        PayToVendCustNo := PurchCreditHeader."Pay-to Vendor No.";
                        BuyFromAccType := BuyFromAccType::Vendor;
                        GenBusPostGrp := PurchCrMemoLine."Gen. Bus. Posting Group";
                        GenProdPostGrp := PurchCrMemoLine."Gen. Prod. Posting Group";
                        TransType := TransType::Purchase;
                        BuyFromVendCustNo := PurchCreditHeader."WHT Actual Vendor No.";
                        PostingDate := PurchCreditHeader."Posting Date";
                        DocDate := PurchCreditHeader."Document Date";
                        CurrencyCode := PurchCreditHeader."Currency Code";
                        CurrFactor := PurchCreditHeader."Currency Factor";
                        ApplyDocType := PurchCreditHeader."Applies-to Doc. Type";
                        ApplyDocNo := PurchCreditHeader."Applies-to Doc. No.";
                        "Applies-toID" := AppliesID;
                        SourceCode := PurchCreditHeader."Source Code";
                        ReasonCode := PurchCreditHeader."Reason Code";

                        if (WithholdingBusPostGrp <> PurchCrMemoLine."Wthldg. Tax Bus. Post. Group") or
                           (WithholdingProdPostGrp <> PurchCrMemoLine."Wthldg. Tax Prod. Post. Group")
                        then begin
                            if AmountVAT <> 0 then
                                InsertWithholdingTax(TType::Purchase);

                            WithholdingBusPostGrp := PurchCrMemoLine."Wthldg. Tax Bus. Post. Group";
                            WithholdingProdPostGrp := PurchCrMemoLine."Wthldg. Tax Prod. Post. Group";
                            PurchCreditHeader.Amount := 0;
                            AbsorbBase := 0;
                            AmountVAT := 0;
                            PurchCreditHeader.Amount := PurchCreditHeader.Amount + PurchCrMemoLine.Amount;
                            AbsorbBase := AbsorbBase + PurchCrMemoLine."Withholding Tax Absorb Base";

                            if AbsorbBase <> 0 then
                                AmountVAT := -AbsorbBase
                            else
                                AmountVAT := -PurchCreditHeader.Amount;
                        end else begin
                            WithholdingBusPostGrp := PurchCrMemoLine."Wthldg. Tax Bus. Post. Group";
                            WithholdingProdPostGrp := PurchCrMemoLine."Wthldg. Tax Prod. Post. Group";
                            PurchCreditHeader.Amount := PurchCreditHeader.Amount + PurchCrMemoLine.Amount;
                            AbsorbBase := AbsorbBase + PurchCrMemoLine."Withholding Tax Absorb Base";

                            if AbsorbBase <> 0 then
                                AmountVAT := -AbsorbBase
                            else
                                AmountVAT := -PurchCreditHeader.Amount;
                        end;

                        WithholdingBusPostGrp := PurchCrMemoLine."Wthldg. Tax Bus. Post. Group";
                        WithholdingProdPostGrp := PurchCrMemoLine."Wthldg. Tax Prod. Post. Group";
                    end;
            until PurchCrMemoLine.Next() = 0;

        InsertWithholdingTax(TType::Purchase);
    end;

    procedure InsertVendJournalWithholdingTax(var GenJnlLine: Record "Gen. Journal Line") EntryNo: Integer
    var
        GLSetup: Record "General Ledger Setup";
        Vendor: Record Vendor;
    begin
        if ((GenJnlLine."Document Type" <> GenJnlLine."Document Type"::Invoice) and
            (GenJnlLine."Document Type" <> GenJnlLine."Document Type"::"Credit Memo") and
            (GenJnlLine."Document Type" <> GenJnlLine."Document Type"::Payment) and
            (GenJnlLine."Document Type" <> GenJnlLine."Document Type"::Refund))
        then
            exit;

        if not WithholdingPostingSetup.Get(
             GenJnlLine."Wthldg. Tax Bus. Post. Group", GenJnlLine."Wthldg. Tax Prod. Post. Group")
        then
            exit;

        TransType := TransType::Purchase;

        case GenJnlLine."Document Type" of
            GenJnlLine."Document Type"::Invoice:
                DocType := DocType::Invoice;

            GenJnlLine."Document Type"::"Credit Memo":
                DocType := DocType::"Credit Memo";

            GenJnlLine."Document Type"::Payment:
                DocType := DocType::Payment;

            GenJnlLine."Document Type"::Refund:
                DocType := DocType::Refund;
        end;

        PostingDate := GenJnlLine."Posting Date";
        DocNo := GenJnlLine."Document No.";
        PayToAccType := PayToAccType::Vendor;
        PayToVendCustNo := GenJnlLine."Account No.";
        BuyFromAccType := BuyFromAccType::Vendor;
        BuyFromVendCustNo := GenJnlLine."Account No.";
        ActualVendorNo := GenJnlLine."WHT Actual Vendor No.";
        ApplyDocType := GenJnlLine."Applies-to Doc. Type";
        ApplyDocNo := GenJnlLine."Applies-to Doc. No.";
        "Applies-toID" := GenJnlLine."Applies-to ID";
        WithholdingBusPostGrp := GenJnlLine."Wthldg. Tax Bus. Post. Group";
        WithholdingProdPostGrp := GenJnlLine."Wthldg. Tax Prod. Post. Group";
        WithholdingPostingSetup.Reset();
        WithholdingPostingSetup.Get(WithholdingBusPostGrp, WithholdingProdPostGrp);
        WithholdingRevenueType := WithholdingPostingSetup."Revenue Type";
        Amount := -GenJnlLine.Amount;

        if GenJnlLine."Bal. VAT %" <> 0 then
            Amount := GenJnlLine."Bal. VAT Base Amount";

        AbsorbBase := -GenJnlLine."Withholding Tax Absorb Base";

        if AbsorbBase <> 0 then
            AmountVAT := AbsorbBase
        else
            AmountVAT := Amount;

        CurrFactor := GenJnlLine."Currency Factor";
        DocDate := GenJnlLine."Document Date";
        Dim1 := GenJnlLine."Shortcut Dimension 1 Code";
        Dim2 := GenJnlLine."Shortcut Dimension 2 Code";
        ExtDocNo := GenJnlLine."External Document No.";
        CurrencyCode := GenJnlLine."Currency Code";
        SourceCode := GenJnlLine."Source Code";

        TempGenJnlLine.Reset();
        TempGenJnlLine.DeleteAll();

        TempGenJnlLine := GenJnlLine;

        GLSetup.Get();
        if GLSetup."Enable Withholding Tax" then begin
            Vendor.Get(GenJnlLine."Account No.");

            if CheckWithholdingCalculationRule(GenJnlLine."Amount (LCY)", WithholdingPostingSetup) then
                exit;
        end;

        exit(InsertWithholdingTax(TType::Purchase));
    end;

    procedure CheckWithholdingCalculationRule(TotalInvoiceAmountLCY: Decimal; WithholdingPostingSetup: Record "Withholding Tax Posting Setup"): Boolean
    begin
        case WithholdingPostingSetup."Wthldg. Tax Calculation Rule" of
            WithholdingPostingSetup."Wthldg. Tax Calculation Rule"::"Less than":
                if Abs(TotalInvoiceAmountLCY) < WithholdingPostingSetup."Wthldg. Tax Min. Inv. Amount" then
                    exit(true);

            WithholdingPostingSetup."Wthldg. Tax Calculation Rule"::"Less than or equal to":
                if Abs(TotalInvoiceAmountLCY) <= WithholdingPostingSetup."Wthldg. Tax Min. Inv. Amount" then
                    exit(true);

            WithholdingPostingSetup."Wthldg. Tax Calculation Rule"::"Equal to":
                if Abs(TotalInvoiceAmountLCY) = WithholdingPostingSetup."Wthldg. Tax Min. Inv. Amount" then
                    exit(true);

            WithholdingPostingSetup."Wthldg. Tax Calculation Rule"::"Greater than":
                if Abs(TotalInvoiceAmountLCY) > WithholdingPostingSetup."Wthldg. Tax Min. Inv. Amount" then
                    exit(true);

            WithholdingPostingSetup."Wthldg. Tax Calculation Rule"::"Greater than or equal to":
                if Abs(TotalInvoiceAmountLCY) >= WithholdingPostingSetup."Wthldg. Tax Min. Inv. Amount" then
                    exit(true);
        end;

        exit(false);
    end;

    procedure InsertWithholdingTax(TransType: Option Purchase,Sale) EntryNo: Integer
    var
        WithholdingTaxEntry: Record "Withholding Tax Entry";
        WithholdingTaxEntry1: Record "Withholding Tax Entry";
        VendLedgerEntry: Record "Vendor Ledger Entry";
        VendLedgerEntry1: Record "Vendor Ledger Entry";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        WithholdingTaxEntryTemp: Record "Withholding Tax Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
        VendLedgEntry1: Record "Vendor Ledger Entry";
        WithholdingTaxEntry3: Record "Withholding Tax Entry";
        NoSeries: Codeunit "No. Series";
        TotalWithholdingTax: Decimal;
        TotalWithholdingTaxBase: Decimal;
        ExpectedAmount: Decimal;
        PaymentAmount1: Decimal;
        AppldAmount: Decimal;
        RemainingAmt: Decimal;
        WithholdingTaxPart: Decimal;
    begin
        if WithholdingPostingSetup.Get(WithholdingBusPostGrp, WithholdingProdPostGrp) then
            if WithholdingPostingSetup."Realized Withholding Tax Type" <> WithholdingPostingSetup."Realized Withholding Tax Type"::" " then begin
                UnrealizedWithholding := (WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Payment);
                WithholdingTaxEntry.Init();
                WithholdingTaxEntry."Entry No." := NextEntryNo();
                WithholdingTaxEntry."Gen. Bus. Posting Group" := GenBusPostGrp;
                WithholdingTaxEntry."Gen. Prod. Posting Group" := GenProdPostGrp;
                WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group" := WithholdingBusPostGrp;
                WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group" := WithholdingProdPostGrp;
                WithholdingTaxEntry."Posting Date" := PostingDate;
                WithholdingTaxEntry."Document Date" := DocDate;
                WithholdingTaxEntry."Document No." := DocNo;
                WithholdingTaxEntry."Withholding Tax %" := WithholdingPostingSetup."Withholding Tax %";
                WithholdingTaxEntry."Applies-to Doc. Type" := ApplyDocType;
                WithholdingTaxEntry."Applies-to Doc. No." := ApplyDocNo;
                WithholdingTaxEntry."Source Code" := SourceCode;
                WithholdingTaxEntry."Reason Code" := ReasonCode;
                WithholdingTaxEntry."Withholding Tax Revenue Type" := WithholdingPostingSetup."Revenue Type";
                WithholdingTaxEntry."Document Type" := DocType;

                if TransType = TransType::Purchase then
                    WithholdingTaxEntry."Transaction Type" := WithholdingTaxEntry."Transaction Type"::Purchase
                else
                    WithholdingTaxEntry."Transaction Type" := WithholdingTaxEntry."Transaction Type"::Sale;

                WithholdingTaxEntry."Source Code" := SourceCode;
                WithholdingTaxEntry."Bill-to/Pay-to No." := PayToVendCustNo;
                WithholdingTaxEntry."User ID" := UserId;
                WithholdingTaxEntry."Currency Code" := CurrencyCode;

                // VAT for G/L entry/entries
                if UnrealizedWithholding then begin
                    SetWithholdingTaxEntryAmounts(WithholdingTaxEntry, AbsorbBase, AmountVAT, CurrFactor);
                    if WithholdingTaxEntry."Applies-to Doc. No." <> '' then begin
                        WithholdingTaxEntry1.Reset();
                        WithholdingTaxEntry1.SetRange("Document Type", WithholdingTaxEntry."Applies-to Doc. Type");
                        WithholdingTaxEntry1.SetRange("Document No.", WithholdingTaxEntry."Applies-to Doc. No.");
                        WithholdingTaxEntry1.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group");
                        WithholdingTaxEntry1.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                        if WithholdingTaxEntry1.FindFirst() then begin
                            if Abs(WithholdingTaxEntry."Unrealized Amount") <=
                               Abs(WithholdingTaxEntry1."Remaining Unrealized Amount")
                            then begin
                                WithholdingTaxEntry1."Remaining Unrealized Amount" :=
                                  WithholdingTaxEntry1."Remaining Unrealized Amount" + WithholdingTaxEntry."Unrealized Amount";
                                WithholdingTaxEntry1."Remaining Unrealized Base" :=
                                  WithholdingTaxEntry1."Remaining Unrealized Base" + WithholdingTaxEntry."Unrealized Base";
                                WithholdingTaxEntry."Remaining Unrealized Amount" := 0;
                                WithholdingTaxEntry."Remaining Unrealized Base" := 0;
                                WithholdingTaxEntry.Closed := true;
                            end else begin
                                WithholdingTaxEntry1."Remaining Unrealized Amount" := 0;
                                WithholdingTaxEntry1."Remaining Unrealized Base" := 0;
                                WithholdingTaxEntry."Remaining Unrealized Amount" :=
                                  WithholdingTaxEntry1."Remaining Unrealized Amount" + WithholdingTaxEntry."Unrealized Amount";
                                WithholdingTaxEntry."Remaining Unrealized Base" :=
                                  WithholdingTaxEntry1."Remaining Unrealized Base" + WithholdingTaxEntry."Unrealized Base";
                            end;

                            if (WithholdingTaxEntry1."Remaining Unrealized Base" = 0) and
                               (WithholdingTaxEntry1."Remaining Unrealized Amount" = 0)
                            then
                                WithholdingTaxEntry1.Closed := true;

                            WithholdingTaxEntry1.Modify();
                            WithholdingTaxEntry."Applies-to Entry No." := WithholdingTaxEntry1."Entry No.";
                        end;
                    end else
                        if "Applies-toID" <> '' then
                            if (TransType = TransType::Purchase) and
                               (WithholdingTaxEntry."Document Type" = WithholdingTaxEntry."Document Type"::"Credit Memo")
                            then begin
                                VendLedgerEntry1.SetRange("Applies-to ID", "Applies-toID");
                                if VendLedgerEntry1.FindSet() then
                                    repeat
                                        if FindWithholdingTaxEntryForApply(
                                             WithholdingTaxEntry1, VendLedgerEntry1."Document Type", VendLedgerEntry1."Document No.",
                                             WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group")
                                        then begin
                                            VendLedgerEntry1.CalcFields("Remaining Amount");
                                            WithholdingTaxPart := Abs(VendLedgerEntry1."Amount to Apply" / VendLedgerEntry1."Remaining Amount");

                                            if WithholdingTaxPart >= 1 then begin
                                                if Abs(WithholdingTaxEntry."Remaining Unrealized Amount") <=
                                                   Abs(WithholdingTaxEntry1."Remaining Unrealized Amount" * WithholdingTaxPart)
                                                then
                                                    CalcWithholdingEntriesRemAmounts(WithholdingTaxEntry1, WithholdingTaxEntry, WithholdingTaxPart)
                                                else
                                                    CalcWithholdingEntriesRemAmounts(WithholdingTaxEntry, WithholdingTaxEntry1, WithholdingTaxPart);
                                            end else
                                                CalcWithholdingEntriesRemAmounts(WithholdingTaxEntry1, WithholdingTaxEntry, WithholdingTaxPart)
                                        end;

                                        WithholdingTaxEntry1."Applies-to Entry No." := WithholdingTaxEntry."Entry No.";
                                        WithholdingTaxEntry1.Modify();
                                    until VendLedgerEntry1.Next() = 0;
                            end;
                end else begin
                    if AbsorbBase <> 0 then
                        WithholdingTaxEntry.Base := AbsorbBase
                    else
                        WithholdingTaxEntry.Base := AmountVAT;

                    WithholdingTaxEntry."Unrealized Amount" := 0;
                    WithholdingTaxEntry."Unrealized Base" := 0;
                    WithholdingTaxEntry."Remaining Unrealized Amount" := 0;
                    WithholdingTaxEntry."Remaining Unrealized Base" := 0;
                    WithholdingTaxEntry.Amount := Round(WithholdingTaxEntry.Base * WithholdingTaxEntry."Withholding Tax %" / 100);
                    WithholdingTaxEntry."Rem Realized Amount" := WithholdingTaxEntry.Amount;
                    WithholdingTaxEntry."Rem Realized Base" := WithholdingTaxEntry.Base;
                    WithholdingTaxEntry."Original Document No." := DocNo;

                    if ((WithholdingReportLineNo = '') and
                        (WithholdingPostingSetup."Wthldg. Tax Rep Line No Series" <> ''))
                    then
                        WithholdingTaxEntry."Wthldg. Tax Report Line No" := NoSeries.GetNextNo(WithholdingPostingSetup."Wthldg. Tax Rep Line No Series", WithholdingTaxEntry."Posting Date");

                    if TransType = TransType::Purchase then begin
                        if ((WithholdingTaxEntry."Document Type" = WithholdingTaxEntry."Document Type"::Invoice) or
                            (WithholdingTaxEntry."Document Type" = WithholdingTaxEntry."Document Type"::Payment))
                        then begin
                            WithholdingTaxEntry.Base := Abs(WithholdingTaxEntry.Base);
                            WithholdingTaxEntry.Amount := Abs(WithholdingTaxEntry.Amount);
                            WithholdingTaxEntry."Payment Amount" := Abs(Amount);
                            WithholdingTaxEntry."Rem Realized Base" := WithholdingTaxEntry.Base;
                            WithholdingTaxEntry."Rem Realized Amount" := WithholdingTaxEntry.Amount;
                            if (WithholdingPostingSetup."Realized Withholding Tax Type" =
                                WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest)
                            then
                                if WithholdingTaxEntry."Applies-to Doc. No." <> '' then begin
                                    WithholdingTaxEntry1.Reset();
                                    WithholdingTaxEntry1.SetRange("Document Type", WithholdingTaxEntry."Applies-to Doc. Type");
                                    WithholdingTaxEntry1.SetRange("Document No.", WithholdingTaxEntry."Applies-to Doc. No.");
                                    WithholdingTaxEntry1.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group");
                                    WithholdingTaxEntry1.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                                    if WithholdingTaxEntry."Document Type" = WithholdingTaxEntry."Document Type"::Invoice then
                                        WithholdingTaxEntry1.SetRange(
                                          "Document Type",
                                          WithholdingTaxEntry1."Document Type"::Payment,
                                          WithholdingTaxEntry1."Document Type"::"Credit Memo");

                                    if WithholdingTaxEntry."Document Type" = WithholdingTaxEntry."Document Type"::Payment then
                                        WithholdingTaxEntry1.SetFilter(
                                          "Document Type",
                                          '%1|%2',
                                          WithholdingTaxEntry1."Document Type"::Invoice,
                                          WithholdingTaxEntry1."Document Type"::Refund);

                                    if WithholdingTaxEntry1.FindFirst() then
                                        if WithholdingTaxEntry1.Prepayment then begin
                                            PaymentAmount1 := WithholdingTaxEntry.Base;
                                            WithholdingTaxEntry3.Reset();
                                            WithholdingTaxEntry3 := WithholdingTaxEntry1;

                                            PurchCrMemoHeader.Reset();
                                            PurchCrMemoHeader.SetRange("Applies-to Doc. No.", WithholdingTaxEntry."Applies-to Doc. No.");
                                            PurchCrMemoHeader.SetRange("Applies-to Doc. Type", PurchCrMemoHeader."Applies-to Doc. Type"::Invoice);
                                            if PurchCrMemoHeader.FindFirst() then begin
                                                TempRemAmt := 0;
                                                VendLedgEntry1.SetRange("Document No.", PurchCrMemoHeader."No.");
                                                VendLedgEntry1.SetRange("Document Type", VendLedgEntry1."Document Type"::"Credit Memo");
                                                if VendLedgEntry1.FindFirst() then
                                                    VendLedgEntry1.CalcFields(Amount, "Remaining Amount");

                                                WithholdingTaxEntryTemp.Reset();
                                                WithholdingTaxEntryTemp.SetRange("Document No.", PurchCrMemoHeader."No.");
                                                WithholdingTaxEntryTemp.SetRange("Document Type", WithholdingTaxEntry."Document Type"::"Credit Memo");
                                                WithholdingTaxEntryTemp.SetRange("Transaction Type", WithholdingTaxEntry."Transaction Type"::Purchase);
                                                WithholdingTaxEntryTemp.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group");
                                                WithholdingTaxEntryTemp.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                                                if WithholdingTaxEntryTemp.FindFirst() then begin
                                                    TempRemBase := WithholdingTaxEntryTemp."Unrealized Amount";
                                                    TempRemAmt := WithholdingTaxEntryTemp."Unrealized Base";
                                                end;
                                            end;

                                            VendLedgEntry.Reset();
                                            VendLedgEntry.SetRange("Document No.", WithholdingTaxEntry."Applies-to Doc. No.");
                                            if WithholdingTaxEntry."Applies-to Doc. Type" = WithholdingTaxEntry."Applies-to Doc. Type"::Invoice then
                                                VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::Invoice)
                                            else
                                                if WithholdingTaxEntry."Applies-to Doc. Type" = WithholdingTaxEntry."Applies-to Doc. Type"::"Credit Memo" then
                                                    VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::"Credit Memo");

                                            if VendLedgEntry.FindFirst() then
                                                VendLedgEntry.CalcFields(Amount, "Remaining Amount");

                                            ExpectedAmount := -(VendLedgEntry.Amount + VendLedgEntry1.Amount);

                                            if VendLedgEntry1."Amount (LCY)" = 0 then
                                                VendLedgEntry1."WHT Rem. Amt" := 0;

                                            if (WithholdingTaxEntry."Posting Date" <= VendLedgEntry."Pmt. Discount Date") and
                                               (Abs(PaymentAmount1) >=
                                                (Abs(VendLedgEntry."WHT Rem. Amt" + VendLedgEntry1."WHT Rem. Amt") -
                                                 Abs(VendLedgEntry."Original Pmt. Disc. Possible")))
                                            then begin
                                                AppldAmount :=
                                                  Round(
                                                    ((PaymentAmount1 - VendLedgEntry."Original Pmt. Disc. Possible") *
                                                     (WithholdingTaxEntry1."Unrealized Base" + TempRemAmt)) /
                                                    ExpectedAmount);
                                                WithholdingTaxEntry3."Remaining Unrealized Base" :=
                                                  Round(
                                                    WithholdingTaxEntry1."Remaining Unrealized Base" -
                                                    Round(
                                                      ((PaymentAmount1 - VendLedgEntry."Original Pmt. Disc. Possible") *
                                                       (WithholdingTaxEntry1."Unrealized Base" + TempRemAmt)) /
                                                      ExpectedAmount));
                                                WithholdingTaxEntry3."Remaining Unrealized Amount" :=
                                                  Round(
                                                    WithholdingTaxEntry1."Remaining Unrealized Amount" -
                                                    Round(
                                                      ((PaymentAmount1 - VendLedgEntry."Original Pmt. Disc. Possible") *
                                                       (WithholdingTaxEntry1."Unrealized Amount" + TempRemBase)) /
                                                      ExpectedAmount));
                                            end else begin
                                                AppldAmount :=
                                                  Round(
                                                    (PaymentAmount1 * (WithholdingTaxEntry1."Unrealized Base" + TempRemAmt)) /
                                                    ExpectedAmount);
                                                WithholdingTaxEntry3."Remaining Unrealized Base" :=
                                                  Round(
                                                    WithholdingTaxEntry1."Remaining Unrealized Base" -
                                                    Round(
                                                      (PaymentAmount1 * (WithholdingTaxEntry1."Unrealized Base" + TempRemAmt)) /
                                                      ExpectedAmount));
                                                WithholdingTaxEntry3."Remaining Unrealized Amount" :=
                                                  Round(
                                                    WithholdingTaxEntry1."Remaining Unrealized Amount" -
                                                    Round(
                                                      (PaymentAmount1 * (WithholdingTaxEntry1."Unrealized Amount" + TempRemBase)) /
                                                      ExpectedAmount));
                                            end;

                                            WithholdingTaxEntry."Applies-to Entry No." := WithholdingTaxEntry1."Entry No.";
                                            WithholdingTaxEntry."Unreal. Wthldg. Tax Entry No." := WithholdingTaxEntry1."Entry No.";
                                            WithholdingTaxEntry."Withholding Tax %" := WithholdingTaxEntry1."Withholding Tax %";
                                            WithholdingTaxEntry.Base := Round(AppldAmount);
                                            WithholdingTaxEntry.Amount := Round(WithholdingTaxEntry.Base * WithholdingTaxEntry."Withholding Tax %" / 100);
                                            WithholdingTaxEntry."Payment Amount" := PaymentAmount1;
                                            WithholdingTaxEntry."Rem Realized Base" := 0;
                                            WithholdingTaxEntry."Rem Realized Amount" := 0;

                                            if CurrencyCode = '' then begin
                                                WithholdingTaxEntry3."Rem Unrealized Amount (LCY)" :=
                                                  WithholdingTaxEntry1."Rem Unrealized Amount (LCY)" - WithholdingTaxEntry.Amount;
                                                WithholdingTaxEntry3."Rem Unrealized Base (LCY)" :=
                                                  WithholdingTaxEntry1."Rem Unrealized Base (LCY)" - WithholdingTaxEntry.Base;
                                            end else begin
                                                WithholdingTaxEntry3."Rem Unrealized Amount (LCY)" := WithholdingTaxEntry1."Rem Unrealized Amount (LCY)" -
                                                  Round(CurrExchRate.ExchangeAmtFCYToLCY(DocDate, CurrencyCode, WithholdingTaxEntry.Amount, CurrFactor));
                                                WithholdingTaxEntry3."Rem Unrealized Base (LCY)" := WithholdingTaxEntry1."Rem Unrealized Base (LCY)" -
                                                  Round(CurrExchRate.ExchangeAmtFCYToLCY(DocDate, CurrencyCode, WithholdingTaxEntry.Base, CurrFactor));
                                            end;

                                            if (WithholdingTaxEntry3."Remaining Unrealized Base" = 0) and (WithholdingTaxEntry3."Remaining Unrealized Amount" = 0) then
                                                WithholdingTaxEntry3.Closed := true;
                                            WithholdingTaxEntry3.Modify();
                                        end else begin
                                            if WithholdingTaxEntry."Document Type" = WithholdingTaxEntry."Document Type"::Invoice then begin
                                                if Abs(WithholdingTaxEntry1."Rem Realized Amount") >= Abs(WithholdingTaxEntry.Amount) then begin
                                                    if ((WithholdingTaxEntry1."Document Type" = WithholdingTaxEntry1."Document Type"::"Credit Memo") or
                                                        (WithholdingTaxEntry1."Document Type" = WithholdingTaxEntry1."Document Type"::Refund))
                                                    then begin
                                                        WithholdingTaxEntry1."Rem Realized Base" :=
                                                          WithholdingTaxEntry1."Rem Realized Base" + WithholdingTaxEntry.Base;
                                                        WithholdingTaxEntry1."Rem Realized Amount" :=
                                                          WithholdingTaxEntry1."Rem Realized Amount" + WithholdingTaxEntry.Amount;
                                                    end else begin
                                                        WithholdingTaxEntry1."Rem Realized Base" :=
                                                          WithholdingTaxEntry1."Rem Realized Base" - WithholdingTaxEntry.Base;
                                                        WithholdingTaxEntry1."Rem Realized Amount" :=
                                                          WithholdingTaxEntry1."Rem Realized Amount" - WithholdingTaxEntry.Amount;
                                                        WithholdingTaxEntry.Amount := 0;
                                                    end;

                                                    if CurrencyCode = '' then begin
                                                        WithholdingTaxEntry1."Rem Realized Base (LCY)" := WithholdingTaxEntry1."Rem Realized Base";
                                                        WithholdingTaxEntry1."Rem Realized Amount (LCY)" := WithholdingTaxEntry1."Rem Realized Amount";
                                                    end else begin
                                                        WithholdingTaxEntry1."Rem Realized Amount (LCY)" :=
                                                          Round(
                                                            CurrExchRate.ExchangeAmtFCYToLCY(
                                                              DocDate, CurrencyCode, WithholdingTaxEntry1."Rem Realized Amount", CurrFactor));
                                                        WithholdingTaxEntry1."Rem Realized Base (LCY)" :=
                                                          Round(
                                                            CurrExchRate.ExchangeAmtFCYToLCY(
                                                              DocDate, CurrencyCode, WithholdingTaxEntry1."Rem Realized Base", CurrFactor));
                                                    end;
                                                end else begin
                                                    if ((WithholdingTaxEntry1."Document Type" = WithholdingTaxEntry1."Document Type"::"Credit Memo") or
                                                        (WithholdingTaxEntry1."Document Type" = WithholdingTaxEntry1."Document Type"::Refund))
                                                    then begin
                                                        WithholdingTaxEntry."Rem Realized Base" := WithholdingTaxEntry."Rem Realized Base" + WithholdingTaxEntry1."Rem Realized Base";
                                                        WithholdingTaxEntry."Rem Realized Amount" := WithholdingTaxEntry."Rem Realized Amount" + WithholdingTaxEntry1."Rem Realized Amount";
                                                    end else begin
                                                        WithholdingTaxEntry.Base := WithholdingTaxEntry.Base - WithholdingTaxEntry1."Rem Realized Base";
                                                        WithholdingTaxEntry.Amount := WithholdingTaxEntry.Amount - WithholdingTaxEntry1."Rem Realized Amount";
                                                        WithholdingTaxEntry."Rem Realized Base" := WithholdingTaxEntry."Rem Realized Base" - WithholdingTaxEntry1."Rem Realized Base";
                                                        WithholdingTaxEntry."Rem Realized Amount" := WithholdingTaxEntry."Rem Realized Amount" - WithholdingTaxEntry1."Rem Realized Amount";
                                                    end;

                                                    WithholdingTaxEntry1."Rem Realized Base" := 0;
                                                    WithholdingTaxEntry1."Rem Realized Amount" := 0;
                                                    WithholdingTaxEntry1."Rem Realized Base (LCY)" := 0;
                                                    WithholdingTaxEntry1."Rem Realized Amount (LCY)" := 0;
                                                end;
                                            end else begin
                                                TotAmt := 0;
                                                TotAmt := TempGenJnlLine.Amount;
                                                VendLedgerEntry.Reset();
                                                VendLedgerEntry.SetRange("Document No.", WithholdingTaxEntry1."Document No.");
                                                VendLedgerEntry.SetRange("Document Type", WithholdingTaxEntry1."Document Type");
                                                if VendLedgerEntry.FindFirst() then begin
                                                    VendorLedgerEntries.Reset();
                                                    VendorLedgerEntries.SetRange("Entry No.", VendLedgerEntry."Entry No.");
                                                    if VendorLedgerEntries.FindSet() then begin
                                                        VendorLedgerEntries.CalcFields(
                                                          Amount, "Amount (LCY)",
                                                          "Remaining Amount", "Remaining Amt. (LCY)");

                                                        if ((WithholdingTaxEntry."Document Type" = WithholdingTaxEntry."Document Type"::Payment) and
                                                            (WithholdingTaxEntry1."Document Type" = WithholdingTaxEntry1."Document Type"::Invoice))
                                                        then
                                                            if CheckPmtDisc(
                                                                 TempGenJnlLine."Posting Date",
                                                                 VendorLedgerEntries."Pmt. Discount Date",
                                                                 Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"),
                                                                 Abs(VendorLedgerEntries."WHT Rem. Amt"),
                                                                 Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"),
                                                                 Abs(TotAmt))
                                                            then
                                                                TotAmt := TotAmt - VendorLedgerEntries."Original Pmt. Disc. Possible";

                                                        if Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax") < Abs(TotAmt) then begin
                                                            if ((WithholdingTaxEntry1."Document Type" = WithholdingTaxEntry1."Document Type"::"Credit Memo") or
                                                                (WithholdingTaxEntry1."Document Type" = WithholdingTaxEntry1."Document Type"::Refund))
                                                            then begin
                                                                WithholdingTaxEntry."Rem Realized Base" := WithholdingTaxEntry."Rem Realized Base" + WithholdingTaxEntry1."Rem Realized Base";
                                                                WithholdingTaxEntry."Rem Realized Amount" :=
                                                                  WithholdingTaxEntry."Rem Realized Amount" + WithholdingTaxEntry1."Rem Realized Amount";
                                                            end else
                                                                if CheckPmtDisc(
                                                                     TempGenJnlLine."Posting Date",
                                                                     VendorLedgerEntries."Pmt. Discount Date",
                                                                     Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"),
                                                                     Abs(VendorLedgerEntries."WHT Rem. Amt"),
                                                                     Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"),
                                                                     Abs(TotAmt))
                                                                then begin
                                                                    WithholdingTaxEntry.Base := (WithholdingTaxEntry.Base -
                                                                                      Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax" -
                                                                                        VendorLedgerEntries."Original Pmt. Disc. Possible")) - Abs(WithholdingTaxEntry1.Amount);
                                                                    WithholdingTaxEntry.Amount :=
                                                                      Round(WithholdingTaxEntry.Base * WithholdingTaxEntry."Withholding Tax %" / 100);
                                                                    WithholdingTaxEntry."Rem Realized Base" := WithholdingTaxEntry."Rem Realized Base" -
                                                                      Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax" -
                                                                        VendorLedgerEntries."Original Pmt. Disc. Possible" - WithholdingTaxEntry1.Amount);
                                                                    WithholdingTaxEntry."Rem Realized Amount" := WithholdingTaxEntry."Rem Realized Amount" -
                                                                      Round(Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax" -
                                                                          VendorLedgerEntries."Original Pmt. Disc. Possible" - WithholdingTaxEntry1.Amount) *
                                                                        WithholdingTaxEntry."Withholding Tax %" / 100);
                                                                end else begin
                                                                    WithholdingTaxEntry.Base := (WithholdingTaxEntry.Base -
                                                                                      Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax")) - Abs(WithholdingTaxEntry1.Amount);
                                                                    WithholdingTaxEntry.Amount :=
                                                                      Round(WithholdingTaxEntry.Base * WithholdingTaxEntry."Withholding Tax %" / 100);
                                                                    WithholdingTaxEntry."Rem Realized Base" := WithholdingTaxEntry."Rem Realized Base" -
                                                                      Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax" - WithholdingTaxEntry1.Amount);
                                                                    WithholdingTaxEntry."Rem Realized Amount" := WithholdingTaxEntry."Rem Realized Amount" -
                                                                      Round(Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax" - WithholdingTaxEntry1.Amount) * WithholdingTaxEntry."Withholding Tax %" / 100);
                                                                end;

                                                            WithholdingTaxEntry1."Rem Realized Base" := 0;
                                                            WithholdingTaxEntry1."Rem Realized Amount" := 0;
                                                            WithholdingTaxEntry1."Rem Realized Base (LCY)" := 0;
                                                            WithholdingTaxEntry1."Rem Realized Amount (LCY)" := 0;
                                                        end else begin
                                                            if ((WithholdingTaxEntry1."Document Type" = WithholdingTaxEntry1."Document Type"::"Credit Memo") or
                                                                (WithholdingTaxEntry1."Document Type" = WithholdingTaxEntry1."Document Type"::Refund))
                                                            then begin
                                                                WithholdingTaxEntry1."Rem Realized Base" :=
                                                                  WithholdingTaxEntry1."Rem Realized Base" + WithholdingTaxEntry.Base;
                                                                WithholdingTaxEntry1."Rem Realized Amount" :=
                                                                  WithholdingTaxEntry1."Rem Realized Amount" + WithholdingTaxEntry.Amount;
                                                            end else begin
                                                                WithholdingTaxEntry1."Rem Realized Base" :=
                                                                  WithholdingTaxEntry1."Rem Realized Base" - TotAmt;
                                                                WithholdingTaxEntry1."Rem Realized Amount" :=
                                                                  WithholdingTaxEntry1."Rem Realized Amount" - Round(Abs(TotAmt) * WithholdingTaxEntry."Withholding Tax %" / 100);
                                                                WithholdingTaxEntry.Amount := 0;
                                                            end;

                                                            if CurrencyCode = '' then begin
                                                                WithholdingTaxEntry1."Rem Realized Base (LCY)" := WithholdingTaxEntry1."Rem Realized Base";
                                                                WithholdingTaxEntry1."Rem Realized Amount (LCY)" := WithholdingTaxEntry1."Rem Realized Amount";
                                                            end else begin
                                                                WithholdingTaxEntry1."Rem Realized Amount (LCY)" :=
                                                                  Round(
                                                                    CurrExchRate.ExchangeAmtFCYToLCY(
                                                                      DocDate, CurrencyCode, WithholdingTaxEntry1."Rem Realized Amount", CurrFactor));
                                                                WithholdingTaxEntry1."Rem Realized Base (LCY)" :=
                                                                  Round(
                                                                    CurrExchRate.ExchangeAmtFCYToLCY(
                                                                      DocDate, CurrencyCode, WithholdingTaxEntry1."Rem Realized Base", CurrFactor));
                                                            end;

                                                            TotAmt := 0;
                                                        end;
                                                    end;
                                                end;
                                            end;

                                            if (WithholdingTaxEntry1."Rem Realized Amount" = 0) and
                                               (WithholdingTaxEntry1."Rem Realized Base" = 0)
                                            then
                                                WithholdingTaxEntry1.Closed := true;
                                            WithholdingTaxEntry1.Modify();
                                        end;
                                end else
                                    if "Applies-toID" <> '' then begin
                                        if WithholdingTaxEntry."Document Type" = WithholdingTaxEntry."Document Type"::Payment then begin
                                            TotAmt := 0;
                                            RemainingAmt := 0;
                                            VendorLedgerEntries1.Reset();
                                            VendorLedgerEntries1.SetRange("Applies-to ID", TempGenJnlLine."Applies-to ID");
                                            if VendorLedgerEntries1.FindSet() then
                                                repeat
                                                    VendorLedgerEntries1.CalcFields(
                                                      Amount, "Amount (LCY)", "Remaining Amount", "Remaining Amt. (LCY)",
                                                      "Original Amount", "Original Amt. (LCY)");

                                                    if VendorLedgerEntries1."Rem. Amt for Withholding Tax" = 0 then
                                                        VendorLedgerEntries1."Rem. Amt for Withholding Tax" := VendorLedgerEntries1."Remaining Amt. (LCY)";

                                                    RemainingAmt := RemainingAmt + VendorLedgerEntries1."Rem. Amt for Withholding Tax";
                                                until VendorLedgerEntries1.Next() = 0;

                                            TotAmt := Abs(TempGenJnlLine.Amount);

                                            VendLedgerEntry.Reset();
                                            VendLedgerEntry.SetRange("Applies-to ID", "Applies-toID");
                                            VendLedgerEntry.SetRange("Document Type", VendLedgerEntry."Document Type"::Refund);
                                            if VendLedgerEntry.FindSet() then begin
                                                TotalWithholdingTaxBase := WithholdingTaxEntry."Rem Realized Base";
                                                TotalWithholdingTax := WithholdingTaxEntry."Rem Realized Amount";
                                                repeat
                                                    WithholdingTaxEntry1.Reset();
                                                    WithholdingTaxEntry1.SetRange(Settled, false);
                                                    WithholdingTaxEntry1.SetRange("Document No.", VendLedgerEntry."Document No.");
                                                    WithholdingTaxEntry1.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group");
                                                    WithholdingTaxEntry1.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                                                    if WithholdingTaxEntry1.FindFirst() then begin
                                                        if Abs(TotalWithholdingTax) > Abs(WithholdingTaxEntry1."Rem Realized Amount") then begin
                                                            WithholdingTaxEntry."Rem Realized Base" :=
                                                              WithholdingTaxEntry."Rem Realized Base" + WithholdingTaxEntry1."Rem Realized Base";
                                                            WithholdingTaxEntry."Rem Realized Amount" :=
                                                              WithholdingTaxEntry."Rem Realized Amount" + WithholdingTaxEntry1."Rem Realized Amount";
                                                            TotalWithholdingTaxBase := TotalWithholdingTaxBase - Abs(WithholdingTaxEntry1."Rem Realized Base");
                                                            TotalWithholdingTax := TotalWithholdingTax - Abs(WithholdingTaxEntry1."Rem Realized Amount");
                                                            WithholdingTaxEntry1."Rem Realized Base" := 0;
                                                            WithholdingTaxEntry1."Rem Realized Amount" := 0;
                                                            WithholdingTaxEntry1."Rem Realized Base (LCY)" := 0;
                                                            WithholdingTaxEntry1."Rem Realized Amount (LCY)" := 0;
                                                        end else
                                                            if (Abs(TotalWithholdingTax) > 0) and (Abs(TotalWithholdingTax) <= Abs(WithholdingTaxEntry1."Rem Realized Amount")) then begin
                                                                WithholdingTaxEntry1."Rem Realized Base" :=
                                                                  WithholdingTaxEntry1."Rem Realized Base" + TotalWithholdingTaxBase;
                                                                WithholdingTaxEntry1."Rem Realized Amount" :=
                                                                  WithholdingTaxEntry1."Rem Realized Amount" + TotalWithholdingTax;
                                                                WithholdingTaxEntry."Rem Realized Amount" := 0;
                                                                WithholdingTaxEntry."Rem Realized Base" := 0;
                                                                TotalWithholdingTaxBase := 0;
                                                                TotalWithholdingTax := 0;
                                                            end;

                                                        if CurrencyCode = '' then begin
                                                            WithholdingTaxEntry1."Rem Realized Base (LCY)" := WithholdingTaxEntry1."Rem Realized Base";
                                                            WithholdingTaxEntry1."Rem Realized Amount (LCY)" := WithholdingTaxEntry1."Rem Realized Amount";
                                                        end else begin
                                                            WithholdingTaxEntry1."Rem Realized Amount (LCY)" :=
                                                              Round(
                                                                CurrExchRate.ExchangeAmtFCYToLCY(
                                                                  DocDate, CurrencyCode, WithholdingTaxEntry1."Rem Realized Amount (LCY)", CurrFactor));
                                                            WithholdingTaxEntry1."Rem Realized Base (LCY)" :=
                                                              Round(
                                                                CurrExchRate.ExchangeAmtFCYToLCY(
                                                                  DocDate, CurrencyCode, WithholdingTaxEntry1."Rem Realized Base (LCY)", CurrFactor));
                                                        end;

                                                        if ((WithholdingTaxEntry1."Rem Realized Amount" = 0) and
                                                            (WithholdingTaxEntry1."Rem Realized Base" = 0))
                                                        then
                                                            WithholdingTaxEntry1.Closed := true;

                                                        WithholdingTaxEntry1.Modify();
                                                    end;
                                                until VendLedgerEntry.Next() = 0;

                                                WithholdingTaxEntry."Applies-to Entry No." := WithholdingTaxEntry1."Entry No.";
                                            end;

                                            VendLedgerEntry.Reset();
                                            VendLedgerEntry.SetRange("Applies-to ID", "Applies-toID");
                                            VendLedgerEntry.SetRange("Document Type", VendLedgerEntry."Document Type"::Invoice);
                                            if VendLedgerEntry.FindSet() then begin
                                                TotalWithholdingTaxBase := WithholdingTaxEntry."Rem Realized Base";
                                                TotalWithholdingTax := WithholdingTaxEntry."Rem Realized Amount";
                                                repeat
                                                    if VendLedgerEntry.Prepayment then begin
                                                        VendorLedgerEntries.Reset();
                                                        VendorLedgerEntries.SetRange("Entry No.", VendLedgerEntry."Entry No.");
                                                        if VendorLedgerEntries.FindFirst() then begin
                                                            VendorLedgerEntries.CalcFields(
                                                              Amount, "Amount (LCY)",
                                                              "Remaining Amount", "Remaining Amt. (LCY)");

                                                            if CheckPmtDisc(
                                                                 TempGenJnlLine."Posting Date",
                                                                 VendorLedgerEntries."Pmt. Discount Date",
                                                                 Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"),
                                                                 Abs(VendorLedgerEntries."WHT Rem. Amt"),
                                                                 Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"),
                                                                 Abs(TotAmt))
                                                            then
                                                                TotAmt := TotAmt - VendorLedgerEntries."Original Pmt. Disc. Possible";

                                                            if (Abs(RemainingAmt) < Abs(TotAmt)) or
                                                               (Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax") < Abs(TotAmt))
                                                            then begin
                                                                if CheckPmtDisc(
                                                                     TempGenJnlLine."Posting Date",
                                                                     VendorLedgerEntries."Pmt. Discount Date",
                                                                     Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"),
                                                                     Abs(VendorLedgerEntries."WHT Rem. Amt"),
                                                                     Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"),
                                                                     Abs(TotAmt))
                                                                then begin
                                                                    TempGenJnlLine.Validate(
                                                                      Amount,
                                                                      Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax" -
                                                                        VendorLedgerEntries."Original Pmt. Disc. Possible"));

                                                                    if VendorLedgerEntries."Document Type" <>
                                                                       VendorLedgerEntries."Document Type"::"Credit Memo"
                                                                    then
                                                                        TotAmt := TotAmt + VendorLedgerEntries."Rem. Amt for Withholding Tax";

                                                                    RemainingAmt :=
                                                                      RemainingAmt -
                                                                      VendorLedgerEntries."Rem. Amt for Withholding Tax";
                                                                end else begin
                                                                    TempGenJnlLine.Validate(Amount, Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"));
                                                                    if VendorLedgerEntries."Document Type" <>
                                                                       VendorLedgerEntries."Document Type"::"Credit Memo"
                                                                    then
                                                                        TotAmt := TotAmt + VendorLedgerEntries."Rem. Amt for Withholding Tax";

                                                                    RemainingAmt := RemainingAmt - VendorLedgerEntries."Rem. Amt for Withholding Tax";
                                                                end;
                                                            end else begin
                                                                if CheckPmtDisc(
                                                                     TempGenJnlLine."Posting Date",
                                                                     VendorLedgerEntries."Pmt. Discount Date",
                                                                     Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"),
                                                                     Abs(VendorLedgerEntries."WHT Rem. Amt"),
                                                                     Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"),
                                                                     Abs(TotAmt))
                                                                then
                                                                    TempGenJnlLine.Validate(Amount, TotAmt + VendorLedgerEntries."Original Pmt. Disc. Possible")
                                                                else
                                                                    TempGenJnlLine.Validate(Amount, TotAmt);

                                                                WithholdingTaxEntry.Amount := 0;
                                                                TotAmt := 0;
                                                            end;

                                                            if VendorLedgerEntries."Document Type" = VendorLedgerEntries."Document Type"::Invoice then
                                                                TempGenJnlLine."Applies-to Doc. Type" := TempGenJnlLine."Applies-to Doc. Type"::Invoice
                                                            else begin
                                                                if VendorLedgerEntries."Document Type" = VendorLedgerEntries."Document Type"::"Credit Memo" then
                                                                    TempGenJnlLine."Applies-to Doc. Type" := TempGenJnlLine."Applies-to Doc. Type"::"Credit Memo";

                                                                RemainingAmt := RemainingAmt + VendorLedgerEntries."Rem. Amt for Withholding Tax";
                                                                TotAmt := TotAmt + VendorLedgerEntries."Rem. Amt for Withholding Tax";
                                                            end;

                                                            TempGenJnlLine."Applies-to Doc. No." := VendorLedgerEntries."Document No.";
                                                            PaymentAmount1 := TempGenJnlLine.Amount;

                                                            WithholdingTaxEntry1.Reset();
                                                            WithholdingTaxEntry1.SetCurrentKey("Transaction Type", "Document No.", "Document Type", "Bill-to/Pay-to No.");
                                                            WithholdingTaxEntry1.SetRange("Transaction Type", WithholdingTaxEntry1."Transaction Type"::Purchase);
                                                            if TempGenJnlLine."Applies-to Doc. No." <> '' then begin
                                                                WithholdingTaxEntry1.SetRange("Document No.", TempGenJnlLine."Applies-to Doc. No.");
                                                                WithholdingTaxEntry1.SetRange("Document Type", TempGenJnlLine."Applies-to Doc. Type");
                                                            end else
                                                                WithholdingTaxEntry1.SetRange("Bill-to/Pay-to No.", TempGenJnlLine."Account No.");

                                                            if WithholdingTaxEntry1.FindSet() then
                                                                repeat
                                                                    WithholdingTaxEntry3.Reset();
                                                                    WithholdingTaxEntry3 := WithholdingTaxEntry1;

                                                                    PurchCrMemoHeader.Reset();
                                                                    PurchCrMemoHeader.SetRange("Applies-to Doc. No.", TempGenJnlLine."Applies-to Doc. No.");
                                                                    PurchCrMemoHeader.SetRange(
                                                                      "Applies-to Doc. Type", PurchCrMemoHeader."Applies-to Doc. Type"::Invoice);
                                                                    if PurchCrMemoHeader.FindFirst() then begin
                                                                        TempRemAmt := 0;

                                                                        VendLedgEntry1.SetRange("Document No.", PurchCrMemoHeader."No.");
                                                                        VendLedgEntry1.SetRange("Document Type", VendLedgEntry1."Document Type"::"Credit Memo");
                                                                        if VendLedgEntry1.FindFirst() then
                                                                            VendLedgEntry1.CalcFields(Amount, "Remaining Amount");

                                                                        WithholdingTaxEntryTemp.Reset();
                                                                        WithholdingTaxEntryTemp.SetRange("Document No.", PurchCrMemoHeader."No.");
                                                                        WithholdingTaxEntryTemp.SetRange("Document Type", WithholdingTaxEntry1."Document Type"::"Credit Memo");
                                                                        WithholdingTaxEntryTemp.SetRange("Transaction Type", WithholdingTaxEntry1."Transaction Type"::Purchase);
                                                                        WithholdingTaxEntryTemp.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry1."Wthldg. Tax Bus. Post. Group");
                                                                        WithholdingTaxEntryTemp.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingTaxEntry1."Wthldg. Tax Prod. Post. Group");
                                                                        if WithholdingTaxEntryTemp.FindFirst() then begin
                                                                            TempRemBase := WithholdingTaxEntryTemp."Unrealized Amount";
                                                                            TempRemAmt := WithholdingTaxEntryTemp."Unrealized Base";
                                                                        end;
                                                                    end;

                                                                    VendLedgEntry.Reset();
                                                                    VendLedgEntry.SetRange("Document No.", TempGenJnlLine."Applies-to Doc. No.");
                                                                    if TempGenJnlLine."Applies-to Doc. Type" = TempGenJnlLine."Applies-to Doc. Type"::Invoice then
                                                                        VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::Invoice)
                                                                    else
                                                                        if TempGenJnlLine."Applies-to Doc. Type" =
                                                                           TempGenJnlLine."Applies-to Doc. Type"::"Credit Memo"
                                                                        then
                                                                            VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::"Credit Memo");

                                                                    if VendLedgEntry.FindFirst() then
                                                                        VendLedgEntry.CalcFields(Amount, "Remaining Amount");

                                                                    ExpectedAmount := -(VendLedgEntry.Amount + VendLedgEntry1.Amount);

                                                                    if VendLedgEntry1."Amount (LCY)" = 0 then
                                                                        VendLedgEntry1."WHT Rem. Amt" := 0;
                                                                    if (TempGenJnlLine."Posting Date" <= VendLedgEntry."Pmt. Discount Date") and
                                                                       (Abs(PaymentAmount1) >=
                                                                        (Abs(VendLedgEntry."WHT Rem. Amt" + VendLedgEntry1."WHT Rem. Amt") -
                                                                         Abs(VendLedgEntry."Original Pmt. Disc. Possible")))
                                                                    then begin
                                                                        AppldAmount :=
                                                                          Round(
                                                                            ((PaymentAmount1 - VendLedgEntry."Original Pmt. Disc. Possible") *
                                                                             (WithholdingTaxEntry1."Unrealized Base" + TempRemAmt)) /
                                                                            ExpectedAmount);

                                                                        WithholdingTaxEntry3."Remaining Unrealized Base" :=
                                                                          Round(
                                                                            WithholdingTaxEntry1."Remaining Unrealized Base" -
                                                                            Round(
                                                                              ((PaymentAmount1 - VendLedgEntry."Original Pmt. Disc. Possible") *
                                                                               (WithholdingTaxEntry1."Unrealized Base" + TempRemAmt)) /
                                                                              ExpectedAmount));

                                                                        WithholdingTaxEntry3."Remaining Unrealized Amount" :=
                                                                          Round(
                                                                            WithholdingTaxEntry1."Remaining Unrealized Amount" -
                                                                            Round(
                                                                              ((PaymentAmount1 - VendLedgEntry."Original Pmt. Disc. Possible") *
                                                                               (WithholdingTaxEntry1."Unrealized Amount" + TempRemBase)) /
                                                                              ExpectedAmount));
                                                                    end else begin
                                                                        AppldAmount :=
                                                                          Round(
                                                                            (PaymentAmount1 *
                                                                             (WithholdingTaxEntry1."Unrealized Base" + TempRemAmt)) /
                                                                            ExpectedAmount);

                                                                        WithholdingTaxEntry3."Remaining Unrealized Base" :=
                                                                          Round(
                                                                            WithholdingTaxEntry1."Remaining Unrealized Base" -
                                                                            Round(
                                                                              (PaymentAmount1 * (WithholdingTaxEntry1."Unrealized Base" + TempRemAmt)) /
                                                                              ExpectedAmount));

                                                                        WithholdingTaxEntry3."Remaining Unrealized Amount" :=
                                                                          Round(
                                                                            WithholdingTaxEntry1."Remaining Unrealized Amount" -
                                                                            Round(
                                                                              (PaymentAmount1 * (WithholdingTaxEntry1."Unrealized Amount" + TempRemBase)) /
                                                                              ExpectedAmount));
                                                                    end;

                                                                    InitWithholdingTaxEntry(WithholdingTaxEntry1, AppldAmount, PaymentAmount1, WithholdingTaxEntry3);
                                                                until WithholdingTaxEntry1.Next(-1) = 0;
                                                        end;
                                                    end else begin
                                                        WithholdingTaxEntry1.Reset();
                                                        WithholdingTaxEntry1.SetRange("Document No.", VendLedgerEntry."Document No.");
                                                        WithholdingTaxEntry1.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group");
                                                        WithholdingTaxEntry1.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                                                        if WithholdingTaxEntry1.FindFirst() then begin
                                                            VendorLedgerEntries.Reset();
                                                            VendorLedgerEntries.SetRange("Entry No.", VendLedgerEntry."Entry No.");
                                                            if VendorLedgerEntries.FindFirst() then begin
                                                                VendorLedgerEntries.CalcFields(
                                                                  Amount, "Amount (LCY)",
                                                                  "Remaining Amount", "Remaining Amt. (LCY)");

                                                                if CheckPmtDisc(
                                                                     TempGenJnlLine."Posting Date",
                                                                     VendorLedgerEntries."Pmt. Discount Date",
                                                                     Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"),
                                                                     Abs(VendorLedgerEntries."WHT Rem. Amt"),
                                                                     Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"),
                                                                     Abs(TotAmt))
                                                                then
                                                                    TotAmt := TotAmt - VendorLedgerEntries."Original Pmt. Disc. Possible";

                                                                if (Abs(RemainingAmt) < Abs(TotAmt)) or
                                                                   (Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax") < Abs(TotAmt))
                                                                then begin
                                                                    if CheckPmtDisc(
                                                                         TempGenJnlLine."Posting Date",
                                                                         VendorLedgerEntries."Pmt. Discount Date",
                                                                         Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"),
                                                                         Abs(VendorLedgerEntries."WHT Rem. Amt"),
                                                                         Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"),
                                                                         Abs(TotAmt))
                                                                    then begin
                                                                        if VendorLedgerEntries."Document Type" <>
                                                                           VendorLedgerEntries."Document Type"::"Credit Memo"
                                                                        then
                                                                            TotAmt := TotAmt + VendorLedgerEntries."Rem. Amt for Withholding Tax";

                                                                        RemainingAmt :=
                                                                          RemainingAmt -
                                                                          VendorLedgerEntries."Rem. Amt for Withholding Tax" +
                                                                          VendorLedgerEntries."Original Pmt. Disc. Possible";

                                                                        WithholdingTaxEntry.Base := WithholdingTaxEntry.Base -
                                                                          Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax" -
                                                                            VendorLedgerEntries."Original Pmt. Disc. Possible");
                                                                        WithholdingTaxEntry.Amount := WithholdingTaxEntry.Amount -
                                                                          Round(Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax" -
                                                                              VendorLedgerEntries."Original Pmt. Disc. Possible") * WithholdingTaxEntry."Withholding Tax %" / 100);
                                                                        WithholdingTaxEntry."Rem Realized Base" := WithholdingTaxEntry."Rem Realized Base" -
                                                                          Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax" -
                                                                            VendorLedgerEntries."Original Pmt. Disc. Possible");
                                                                        WithholdingTaxEntry."Rem Realized Amount" := WithholdingTaxEntry."Rem Realized Amount" -
                                                                          Round(Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax" -
                                                                              VendorLedgerEntries."Original Pmt. Disc. Possible") * WithholdingTaxEntry."Withholding Tax %" / 100);
                                                                    end else begin
                                                                        if VendorLedgerEntries."Document Type" <>
                                                                           VendorLedgerEntries."Document Type"::"Credit Memo"
                                                                        then
                                                                            TotAmt := TotAmt + VendorLedgerEntries."Rem. Amt for Withholding Tax";

                                                                        RemainingAmt := RemainingAmt - VendorLedgerEntries."Rem. Amt for Withholding Tax";

                                                                        WithholdingTaxEntry.Base := WithholdingTaxEntry.Base -
                                                                          Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax");
                                                                        WithholdingTaxEntry.Amount := WithholdingTaxEntry.Amount -
                                                                          Round(Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax") * WithholdingTaxEntry."Withholding Tax %" / 100);
                                                                        WithholdingTaxEntry."Rem Realized Base" := WithholdingTaxEntry."Rem Realized Base" -
                                                                          Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax");
                                                                        WithholdingTaxEntry."Rem Realized Amount" := WithholdingTaxEntry."Rem Realized Amount" -
                                                                          Round(Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax") * WithholdingTaxEntry."Withholding Tax %" / 100);
                                                                    end;

                                                                    WithholdingTaxEntry1."Rem Realized Base" := 0;
                                                                    WithholdingTaxEntry1."Rem Realized Amount" := 0;
                                                                    WithholdingTaxEntry1."Rem Realized Base (LCY)" := 0;
                                                                    WithholdingTaxEntry1."Rem Realized Amount (LCY)" := 0;
                                                                end else begin
                                                                    WithholdingTaxEntry1."Rem Realized Base" :=
                                                                      WithholdingTaxEntry1."Rem Realized Base" - TotAmt;
                                                                    WithholdingTaxEntry1."Rem Realized Amount" :=
                                                                      WithholdingTaxEntry1."Rem Realized Amount" -
                                                                      Round(Abs(TotAmt) * WithholdingTaxEntry."Withholding Tax %" / 100);
                                                                    WithholdingTaxEntry.Amount := 0;
                                                                    TotAmt := 0;
                                                                end;
                                                            end;

                                                            if CurrencyCode = '' then begin
                                                                WithholdingTaxEntry1."Rem Realized Base (LCY)" := WithholdingTaxEntry1."Rem Realized Base";
                                                                WithholdingTaxEntry1."Rem Realized Amount (LCY)" := WithholdingTaxEntry1."Rem Realized Amount";
                                                            end else begin
                                                                WithholdingTaxEntry1."Rem Realized Amount (LCY)" :=
                                                                  Round(
                                                                    CurrExchRate.ExchangeAmtFCYToLCY(
                                                                      DocDate, CurrencyCode, WithholdingTaxEntry1."Rem Realized Amount (LCY)", CurrFactor));
                                                                WithholdingTaxEntry1."Rem Realized Base (LCY)" :=
                                                                  Round(
                                                                    CurrExchRate.ExchangeAmtFCYToLCY(
                                                                      DocDate, CurrencyCode, WithholdingTaxEntry1."Rem Realized Base (LCY)", CurrFactor));
                                                            end;

                                                            if ((WithholdingTaxEntry1."Rem Realized Amount" = 0) and
                                                                (WithholdingTaxEntry1."Rem Realized Base" = 0))
                                                            then
                                                                WithholdingTaxEntry1.Closed := true;

                                                            WithholdingTaxEntry1.Modify();
                                                        end;
                                                    end;
                                                until VendLedgerEntry.Next() = 0;

                                                if TotAmt > 0 then begin
                                                    WithholdingTaxEntry.Base := TotAmt;
                                                    WithholdingTaxEntry.Amount := Round(TotAmt * WithholdingPostingSetup."Withholding Tax %" / 100);
                                                    WithholdingTaxEntry."Rem Realized Amount" := WithholdingTaxEntry.Amount;
                                                    WithholdingTaxEntry."Rem Realized Base" := WithholdingTaxEntry.Base;
                                                    WithholdingTaxEntry."Entry No." := NextEntryNo();
                                                end else
                                                    WithholdingTaxEntry."Applies-to Entry No." := WithholdingTaxEntry1."Entry No.";
                                            end;
                                        end;

                                        if WithholdingTaxEntry."Document Type" = WithholdingTaxEntry."Document Type"::Invoice then begin
                                            VendLedgerEntry.Reset();
                                            VendLedgerEntry.SetRange("Applies-to ID", "Applies-toID");
                                            VendLedgerEntry.SetFilter(
                                              "Document Type",
                                              '%1|%2',
                                              VendLedgerEntry."Document Type"::Payment,
                                              VendLedgerEntry."Document Type"::"Credit Memo");
                                            if VendLedgerEntry.FindSet() then begin
                                                TotalWithholdingTaxBase := Abs(WithholdingTaxEntry."Rem Realized Base");
                                                TotalWithholdingTax := Abs(WithholdingTaxEntry."Rem Realized Amount");
                                                repeat
                                                    WithholdingTaxEntry1.Reset();
                                                    WithholdingTaxEntry1.SetRange(Settled, false);
                                                    WithholdingTaxEntry1.SetRange("Document No.", VendLedgerEntry."Document No.");
                                                    WithholdingTaxEntry1.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group");
                                                    WithholdingTaxEntry1.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                                                    if WithholdingTaxEntry1.FindFirst() then begin
                                                        if TotalWithholdingTax > Abs(WithholdingTaxEntry1."Rem Realized Amount") then begin
                                                            if WithholdingTaxEntry1."Document Type" = WithholdingTaxEntry1."Document Type"::Payment then begin
                                                                WithholdingTaxEntry.Base := WithholdingTaxEntry.Base - Abs(WithholdingTaxEntry1."Rem Realized Base");
                                                                WithholdingTaxEntry.Amount := WithholdingTaxEntry.Amount - Abs(WithholdingTaxEntry1."Rem Realized Amount");
                                                            end;

                                                            WithholdingTaxEntry."Rem Realized Base" := WithholdingTaxEntry."Rem Realized Base" - Abs(WithholdingTaxEntry1."Rem Realized Base");
                                                            WithholdingTaxEntry."Rem Realized Amount" :=
                                                              WithholdingTaxEntry."Rem Realized Amount" - Abs(WithholdingTaxEntry1."Rem Realized Amount");
                                                            WithholdingTaxEntry."Rem Realized Base" := WithholdingTaxEntry."Rem Realized Base" - Abs(WithholdingTaxEntry1."Rem Realized Base");
                                                            WithholdingTaxEntry."Rem Realized Amount" :=
                                                              WithholdingTaxEntry."Rem Realized Amount" - Abs(WithholdingTaxEntry1."Rem Realized Amount");
                                                            TotalWithholdingTaxBase := TotalWithholdingTaxBase - Abs(WithholdingTaxEntry1."Rem Realized Base");
                                                            TotalWithholdingTax := TotalWithholdingTax - Abs(WithholdingTaxEntry1."Rem Realized Amount");
                                                            WithholdingTaxEntry1."Rem Realized Base" := 0;
                                                            WithholdingTaxEntry1."Rem Realized Amount" := 0;
                                                            WithholdingTaxEntry1."Rem Realized Base (LCY)" := 0;
                                                            WithholdingTaxEntry1."Rem Realized Amount (LCY)" := 0;
                                                        end else
                                                            if (TotalWithholdingTax > 0) and (TotalWithholdingTax <= Abs(WithholdingTaxEntry1."Rem Realized Amount")) then begin
                                                                if WithholdingTaxEntry1."Document Type" = WithholdingTaxEntry1."Document Type"::"Credit Memo" then begin
                                                                    WithholdingTaxEntry1."Rem Realized Base" :=
                                                                      WithholdingTaxEntry1."Rem Realized Base" + TotalWithholdingTaxBase;
                                                                    WithholdingTaxEntry1."Rem Realized Amount" :=
                                                                      WithholdingTaxEntry1."Rem Realized Amount" + TotalWithholdingTax;
                                                                end else begin
                                                                    WithholdingTaxEntry1."Rem Realized Base" :=
                                                                      WithholdingTaxEntry1."Rem Realized Base" - TotalWithholdingTaxBase;
                                                                    WithholdingTaxEntry1."Rem Realized Amount" :=
                                                                      WithholdingTaxEntry1."Rem Realized Amount" - TotalWithholdingTax;
                                                                    WithholdingTaxEntry.Base := 0;
                                                                    WithholdingTaxEntry.Amount := 0;
                                                                end;

                                                                WithholdingTaxEntry."Rem Realized Amount" := 0;
                                                                WithholdingTaxEntry."Rem Realized Base" := 0;
                                                                TotalWithholdingTaxBase := 0;
                                                                TotalWithholdingTax := 0;
                                                            end;

                                                        if CurrencyCode = '' then begin
                                                            WithholdingTaxEntry1."Rem Realized Base (LCY)" := WithholdingTaxEntry1."Rem Realized Base";
                                                            WithholdingTaxEntry1."Rem Realized Amount (LCY)" := WithholdingTaxEntry1."Rem Realized Amount";
                                                        end else begin
                                                            WithholdingTaxEntry1."Rem Realized Amount (LCY)" :=
                                                              Round(
                                                                CurrExchRate.ExchangeAmtFCYToLCY(
                                                                  DocDate, CurrencyCode, WithholdingTaxEntry1."Rem Realized Amount (LCY)", CurrFactor));
                                                            WithholdingTaxEntry1."Rem Realized Base (LCY)" :=
                                                              Round(
                                                                CurrExchRate.ExchangeAmtFCYToLCY(
                                                                  DocDate, CurrencyCode, WithholdingTaxEntry1."Rem Realized Base (LCY)", CurrFactor));
                                                        end;

                                                        if ((WithholdingTaxEntry1."Rem Realized Amount" = 0) and
                                                            (WithholdingTaxEntry1."Rem Realized Base" = 0))
                                                        then
                                                            WithholdingTaxEntry1.Closed := true;

                                                        WithholdingTaxEntry1.Modify();
                                                    end;
                                                until VendLedgerEntry.Next() = 0;

                                                WithholdingTaxEntry."Applies-to Entry No." := WithholdingTaxEntry1."Entry No.";
                                            end;
                                        end;
                                    end;
                        end;

                        // Purchase Credit Memo & Refund
                        if ((WithholdingTaxEntry."Document Type" = WithholdingTaxEntry."Document Type"::"Credit Memo") or
                            (WithholdingTaxEntry."Document Type" = WithholdingTaxEntry."Document Type"::Refund))
                        then begin
                            WithholdingTaxEntry.Base := -Abs(WithholdingTaxEntry.Base);
                            WithholdingTaxEntry.Amount := -Abs(WithholdingTaxEntry.Amount);
                            WithholdingTaxEntry."Payment Amount" := -Abs(Amount);
                            WithholdingTaxEntry."Rem Realized Base" := WithholdingTaxEntry.Base;
                            WithholdingTaxEntry."Rem Realized Amount" := WithholdingTaxEntry.Amount;

                            if (WithholdingPostingSetup."Realized Withholding Tax Type" =
                                WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest)
                            then
                                if WithholdingTaxEntry."Applies-to Doc. No." <> '' then begin
                                    WithholdingTaxEntry1.Reset();
                                    WithholdingTaxEntry1.SetRange("Document Type", WithholdingTaxEntry."Applies-to Doc. Type");
                                    WithholdingTaxEntry1.SetRange("Document No.", WithholdingTaxEntry."Applies-to Doc. No.");
                                    WithholdingTaxEntry1.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group");
                                    WithholdingTaxEntry1.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                                    if WithholdingTaxEntry."Document Type" = WithholdingTaxEntry."Document Type"::"Credit Memo" then
                                        WithholdingTaxEntry1.SetFilter(
                                          "Document Type",
                                          '%1|%2',
                                          WithholdingTaxEntry1."Document Type"::Refund,
                                          WithholdingTaxEntry1."Document Type"::Invoice);

                                    if WithholdingTaxEntry."Document Type" = WithholdingTaxEntry."Document Type"::Refund then
                                        WithholdingTaxEntry1.SetFilter(
                                          "Document Type",
                                          '%1|%2',
                                          WithholdingTaxEntry1."Document Type"::"Credit Memo",
                                          WithholdingTaxEntry1."Document Type"::Payment);

                                    if WithholdingTaxEntry1.FindFirst() then begin
                                        if Abs(WithholdingTaxEntry1."Rem Realized Amount") >= Abs(WithholdingTaxEntry.Amount) then begin
                                            if ((WithholdingTaxEntry1."Document Type" = WithholdingTaxEntry1."Document Type"::Invoice) or
                                                (WithholdingTaxEntry1."Document Type" = WithholdingTaxEntry1."Document Type"::Payment))
                                            then begin
                                                WithholdingTaxEntry1."Rem Realized Base" :=
                                                  WithholdingTaxEntry1."Rem Realized Base" + WithholdingTaxEntry.Base;
                                                WithholdingTaxEntry1."Rem Realized Amount" :=
                                                  WithholdingTaxEntry1."Rem Realized Amount" + WithholdingTaxEntry.Amount;
                                                WithholdingTaxEntry."Rem Realized Base" := 0;
                                                WithholdingTaxEntry."Rem Realized Amount" := 0;
                                            end else begin
                                                WithholdingTaxEntry1."Rem Realized Base" :=
                                                  WithholdingTaxEntry1."Rem Realized Base" - WithholdingTaxEntry.Base;
                                                WithholdingTaxEntry1."Rem Realized Amount" :=
                                                  WithholdingTaxEntry1."Rem Realized Amount" - WithholdingTaxEntry.Amount;
                                                WithholdingTaxEntry.Amount := 0;
                                            end;

                                            if CurrencyCode = '' then begin
                                                WithholdingTaxEntry1."Rem Realized Base (LCY)" := WithholdingTaxEntry1."Rem Realized Base";
                                                WithholdingTaxEntry1."Rem Realized Amount (LCY)" := WithholdingTaxEntry1."Rem Realized Amount";
                                            end else begin
                                                WithholdingTaxEntry1."Rem Realized Amount (LCY)" :=
                                                  Round(
                                                    CurrExchRate.ExchangeAmtFCYToLCY(
                                                      DocDate, CurrencyCode, WithholdingTaxEntry1."Rem Realized Amount (LCY)", CurrFactor));
                                                WithholdingTaxEntry1."Rem Realized Base (LCY)" :=
                                                  Round(
                                                    CurrExchRate.ExchangeAmtFCYToLCY(
                                                      DocDate, CurrencyCode, WithholdingTaxEntry1."Rem Realized Base (LCY)", CurrFactor));
                                            end;
                                        end else begin
                                            if ((WithholdingTaxEntry1."Document Type" = WithholdingTaxEntry1."Document Type"::Invoice) or
                                                (WithholdingTaxEntry1."Document Type" = WithholdingTaxEntry1."Document Type"::Payment))
                                            then begin
                                                WithholdingTaxEntry."Rem Realized Base" := WithholdingTaxEntry."Rem Realized Base" + WithholdingTaxEntry1."Rem Realized Base";
                                                WithholdingTaxEntry."Rem Realized Amount" := WithholdingTaxEntry."Rem Realized Amount" + WithholdingTaxEntry1."Rem Realized Amount";
                                            end else begin
                                                WithholdingTaxEntry.Base := WithholdingTaxEntry.Base - WithholdingTaxEntry1."Rem Realized Base";
                                                WithholdingTaxEntry.Amount := WithholdingTaxEntry.Amount - WithholdingTaxEntry1."Rem Realized Amount";
                                                WithholdingTaxEntry."Rem Realized Base" := WithholdingTaxEntry."Rem Realized Base" - WithholdingTaxEntry1."Rem Realized Base";
                                                WithholdingTaxEntry."Rem Realized Amount" := WithholdingTaxEntry."Rem Realized Amount" - WithholdingTaxEntry1."Rem Realized Amount";
                                            end;

                                            WithholdingTaxEntry1."Rem Realized Base" := 0;
                                            WithholdingTaxEntry1."Rem Realized Amount" := 0;
                                            WithholdingTaxEntry1."Rem Realized Base (LCY)" := 0;
                                            WithholdingTaxEntry1."Rem Realized Amount (LCY)" := 0;
                                        end;

                                        if ((WithholdingTaxEntry1."Rem Realized Amount" = 0) and
                                            (WithholdingTaxEntry1."Rem Realized Base" = 0))
                                        then
                                            WithholdingTaxEntry1.Closed := true;

                                        WithholdingTaxEntry1.Modify();
                                    end
                                    else
                                        if "Applies-toID" <> '' then begin
                                            if WithholdingTaxEntry."Document Type" = WithholdingTaxEntry."Document Type"::"Credit Memo" then begin
                                                VendLedgerEntry.Reset();
                                                VendLedgerEntry.SetRange("Applies-to ID", "Applies-toID");
                                                VendLedgerEntry.SetRange("Document Type", VendLedgerEntry."Document Type"::Refund);
                                                if VendLedgerEntry.FindSet() then begin
                                                    TotalWithholdingTaxBase := WithholdingTaxEntry."Rem Realized Base";
                                                    TotalWithholdingTax := WithholdingTaxEntry."Rem Realized Amount";
                                                    repeat
                                                        WithholdingTaxEntry1.Reset();
                                                        WithholdingTaxEntry1.SetRange(Settled, false);
                                                        WithholdingTaxEntry1.SetRange("Document No.", VendLedgerEntry."Document No.");
                                                        WithholdingTaxEntry1.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group");
                                                        WithholdingTaxEntry1.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                                                        if WithholdingTaxEntry1.FindFirst() then begin
                                                            if Abs(TotalWithholdingTax) > Abs(WithholdingTaxEntry1."Rem Realized Amount") then begin
                                                                WithholdingTaxEntry.Base := WithholdingTaxEntry.Base + WithholdingTaxEntry1."Rem Realized Base";
                                                                WithholdingTaxEntry.Amount := WithholdingTaxEntry.Amount + WithholdingTaxEntry1."Rem Realized Amount";
                                                                WithholdingTaxEntry."Rem Realized Base" :=
                                                                  WithholdingTaxEntry."Rem Realized Base" + WithholdingTaxEntry1."Rem Realized Base";
                                                                WithholdingTaxEntry."Rem Realized Amount" :=
                                                                  WithholdingTaxEntry."Rem Realized Amount" + WithholdingTaxEntry1."Rem Realized Amount";
                                                                TotalWithholdingTaxBase := TotalWithholdingTaxBase - Abs(WithholdingTaxEntry1."Rem Realized Base");
                                                                TotalWithholdingTax := TotalWithholdingTax - Abs(WithholdingTaxEntry1."Rem Realized Amount");
                                                                WithholdingTaxEntry1."Rem Realized Base" := 0;
                                                                WithholdingTaxEntry1."Rem Realized Amount" := 0;
                                                                WithholdingTaxEntry1."Rem Realized Base (LCY)" := 0;
                                                                WithholdingTaxEntry1."Rem Realized Amount (LCY)" := 0;
                                                            end else
                                                                if (Abs(TotalWithholdingTax) > 0) and (Abs(TotalWithholdingTax) <= Abs(WithholdingTaxEntry1."Rem Realized Amount")) then begin
                                                                    WithholdingTaxEntry1."Rem Realized Base" :=
                                                                      WithholdingTaxEntry1."Rem Realized Base" + TotalWithholdingTaxBase;
                                                                    WithholdingTaxEntry1."Rem Realized Amount" :=
                                                                      WithholdingTaxEntry1."Rem Realized Amount" + TotalWithholdingTax;
                                                                    WithholdingTaxEntry.Base := 0;
                                                                    WithholdingTaxEntry.Amount := 0;
                                                                    WithholdingTaxEntry."Rem Realized Amount" := 0;
                                                                    WithholdingTaxEntry."Rem Realized Base" := 0;
                                                                    TotalWithholdingTaxBase := 0;
                                                                    TotalWithholdingTax := 0;
                                                                end;

                                                            if CurrencyCode = '' then begin
                                                                WithholdingTaxEntry1."Rem Realized Base (LCY)" := WithholdingTaxEntry1."Rem Realized Base";
                                                                WithholdingTaxEntry1."Rem Realized Amount (LCY)" := WithholdingTaxEntry1."Rem Realized Amount";
                                                            end else begin
                                                                WithholdingTaxEntry1."Rem Realized Amount (LCY)" :=
                                                                  Round(
                                                                    CurrExchRate.ExchangeAmtFCYToLCY(
                                                                      DocDate, CurrencyCode, WithholdingTaxEntry1."Rem Realized Amount (LCY)", CurrFactor));
                                                                WithholdingTaxEntry1."Rem Realized Base (LCY)" :=
                                                                  Round(
                                                                    CurrExchRate.ExchangeAmtFCYToLCY(
                                                                      DocDate, CurrencyCode, WithholdingTaxEntry1."Rem Realized Base (LCY)", CurrFactor));
                                                            end;

                                                            if ((WithholdingTaxEntry1."Rem Realized Amount" = 0) and
                                                                (WithholdingTaxEntry1."Rem Realized Base" = 0))
                                                            then
                                                                WithholdingTaxEntry1.Closed := true;

                                                            WithholdingTaxEntry1.Modify();
                                                        end;
                                                    until VendLedgerEntry.Next() = 0;

                                                    WithholdingTaxEntry."Applies-to Entry No." := WithholdingTaxEntry1."Entry No.";
                                                end;

                                                VendLedgerEntry.Reset();
                                                VendLedgerEntry.SetRange("Applies-to ID", "Applies-toID");
                                                VendLedgerEntry.SetRange("Document Type", VendLedgerEntry."Document Type"::Invoice);
                                                if VendLedgerEntry.FindSet() then begin
                                                    TotalWithholdingTaxBase := Abs(WithholdingTaxEntry."Rem Realized Base");
                                                    TotalWithholdingTax := Abs(WithholdingTaxEntry."Rem Realized Amount");
                                                    repeat
                                                        WithholdingTaxEntry1.Reset();
                                                        WithholdingTaxEntry1.SetRange(Settled, false);
                                                        WithholdingTaxEntry1.SetRange("Document No.", VendLedgerEntry."Document No.");
                                                        WithholdingTaxEntry1.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group");
                                                        WithholdingTaxEntry1.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                                                        if WithholdingTaxEntry1.FindFirst() then begin
                                                            if TotalWithholdingTax > Abs(WithholdingTaxEntry1."Rem Realized Amount") then begin
                                                                WithholdingTaxEntry."Rem Realized Base" := WithholdingTaxEntry."Rem Realized Base" + WithholdingTaxEntry1."Rem Realized Base";
                                                                WithholdingTaxEntry."Rem Realized Amount" := WithholdingTaxEntry."Rem Realized Amount" + WithholdingTaxEntry1."Rem Realized Amount";
                                                                TotalWithholdingTaxBase := TotalWithholdingTaxBase - Abs(WithholdingTaxEntry1."Rem Realized Base");
                                                                TotalWithholdingTax := TotalWithholdingTax - Abs(WithholdingTaxEntry1."Rem Realized Amount");
                                                                WithholdingTaxEntry1."Rem Realized Base" := 0;
                                                                WithholdingTaxEntry1."Rem Realized Amount" := 0;
                                                                WithholdingTaxEntry1."Rem Realized Base (LCY)" := 0;
                                                                WithholdingTaxEntry1."Rem Realized Amount (LCY)" := 0;
                                                            end else
                                                                if (TotalWithholdingTax > 0) and (Abs(TotalWithholdingTax) <= Abs(WithholdingTaxEntry1."Rem Realized Amount")) then begin
                                                                    WithholdingTaxEntry1."Rem Realized Base" :=
                                                                      WithholdingTaxEntry1."Rem Realized Base" - TotalWithholdingTaxBase;
                                                                    WithholdingTaxEntry1."Rem Realized Amount" :=
                                                                      WithholdingTaxEntry1."Rem Realized Amount" - TotalWithholdingTax;
                                                                    WithholdingTaxEntry."Rem Realized Amount" := 0;
                                                                    WithholdingTaxEntry."Rem Realized Base" := 0;
                                                                    TotalWithholdingTaxBase := 0;
                                                                    TotalWithholdingTax := 0;
                                                                end;

                                                            if CurrencyCode = '' then begin
                                                                WithholdingTaxEntry1."Rem Realized Base (LCY)" := WithholdingTaxEntry1."Rem Realized Base";
                                                                WithholdingTaxEntry1."Rem Realized Amount (LCY)" := WithholdingTaxEntry1."Rem Realized Amount";
                                                            end else begin
                                                                WithholdingTaxEntry1."Rem Realized Amount (LCY)" :=
                                                                  Round(
                                                                    CurrExchRate.ExchangeAmtFCYToLCY(
                                                                      DocDate, CurrencyCode, WithholdingTaxEntry1."Rem Realized Amount (LCY)", CurrFactor));
                                                                WithholdingTaxEntry1."Rem Realized Base (LCY)" :=
                                                                  Round(
                                                                    CurrExchRate.ExchangeAmtFCYToLCY(
                                                                      DocDate, CurrencyCode, WithholdingTaxEntry1."Rem Realized Base (LCY)", CurrFactor));
                                                            end;

                                                            if ((WithholdingTaxEntry1."Rem Realized Amount" = 0) and
                                                                (WithholdingTaxEntry1."Rem Realized Base" = 0))
                                                            then
                                                                WithholdingTaxEntry1.Closed := true;

                                                            WithholdingTaxEntry1.Modify();
                                                        end;
                                                    until VendLedgerEntry.Next() = 0;

                                                    WithholdingTaxEntry."Applies-to Entry No." := WithholdingTaxEntry1."Entry No.";
                                                end;
                                            end;

                                            if WithholdingTaxEntry."Document Type" = WithholdingTaxEntry."Document Type"::Refund then begin
                                                VendLedgerEntry.Reset();
                                                VendLedgerEntry.SetRange("Applies-to ID", "Applies-toID");
                                                VendLedgerEntry.SetFilter(
                                                  "Document Type",
                                                  '%1|%2',
                                                  VendLedgerEntry."Document Type"::Payment,
                                                  VendLedgerEntry."Document Type"::"Credit Memo");
                                                if VendLedgerEntry.FindSet() then begin
                                                    TotalWithholdingTaxBase := Abs(WithholdingTaxEntry."Rem Realized Base");
                                                    TotalWithholdingTax := Abs(WithholdingTaxEntry."Rem Realized Amount");
                                                    repeat
                                                        WithholdingTaxEntry1.Reset();
                                                        WithholdingTaxEntry1.SetRange(Settled, false);
                                                        WithholdingTaxEntry1.SetRange("Document No.", VendLedgerEntry."Document No.");
                                                        WithholdingTaxEntry1.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group");
                                                        WithholdingTaxEntry1.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                                                        if WithholdingTaxEntry1.FindFirst() then begin
                                                            if TotalWithholdingTax > Abs(WithholdingTaxEntry1."Rem Realized Amount") then begin
                                                                if WithholdingTaxEntry1."Document Type" = WithholdingTaxEntry1."Document Type"::"Credit Memo" then begin
                                                                    WithholdingTaxEntry.Base := WithholdingTaxEntry.Base + Abs(WithholdingTaxEntry1."Rem Realized Base");
                                                                    WithholdingTaxEntry.Amount := WithholdingTaxEntry.Amount + Abs(WithholdingTaxEntry1."Rem Realized Amount");
                                                                end;

                                                                WithholdingTaxEntry."Rem Realized Base" := WithholdingTaxEntry."Rem Realized Base" + Abs(WithholdingTaxEntry1."Rem Realized Base");
                                                                WithholdingTaxEntry."Rem Realized Amount" :=
                                                                  WithholdingTaxEntry."Rem Realized Amount" + Abs(WithholdingTaxEntry1."Rem Realized Amount");
                                                                TotalWithholdingTaxBase := TotalWithholdingTaxBase - Abs(WithholdingTaxEntry1."Rem Realized Base");
                                                                TotalWithholdingTax := TotalWithholdingTax - Abs(WithholdingTaxEntry1."Rem Realized Amount");
                                                                WithholdingTaxEntry1."Rem Realized Base" := 0;
                                                                WithholdingTaxEntry1."Rem Realized Amount" := 0;
                                                                WithholdingTaxEntry1."Rem Realized Base (LCY)" := 0;
                                                                WithholdingTaxEntry1."Rem Realized Amount (LCY)" := 0;
                                                            end else
                                                                if (TotalWithholdingTax > 0) and (TotalWithholdingTax <= Abs(WithholdingTaxEntry1."Rem Realized Amount")) then begin
                                                                    if WithholdingTaxEntry1."Document Type" = WithholdingTaxEntry1."Document Type"::Payment then begin
                                                                        WithholdingTaxEntry1."Rem Realized Base" :=
                                                                          WithholdingTaxEntry1."Rem Realized Base" - TotalWithholdingTaxBase;
                                                                        WithholdingTaxEntry1."Rem Realized Amount" :=
                                                                          WithholdingTaxEntry1."Rem Realized Amount" - TotalWithholdingTax;
                                                                    end else begin
                                                                        WithholdingTaxEntry1."Rem Realized Base" :=
                                                                          WithholdingTaxEntry1."Rem Realized Base" + TotalWithholdingTaxBase;
                                                                        WithholdingTaxEntry1."Rem Realized Amount" :=
                                                                          WithholdingTaxEntry1."Rem Realized Amount" + TotalWithholdingTax;
                                                                        WithholdingTaxEntry.Base := 0;
                                                                        WithholdingTaxEntry.Amount := 0;
                                                                    end;

                                                                    WithholdingTaxEntry."Rem Realized Amount" := 0;
                                                                    WithholdingTaxEntry."Rem Realized Base" := 0;
                                                                    TotalWithholdingTaxBase := 0;
                                                                    TotalWithholdingTax := 0;
                                                                end;

                                                            if CurrencyCode = '' then begin
                                                                WithholdingTaxEntry1."Rem Realized Base (LCY)" := WithholdingTaxEntry1."Rem Realized Base";
                                                                WithholdingTaxEntry1."Rem Realized Amount (LCY)" := WithholdingTaxEntry1."Rem Realized Amount";
                                                            end else begin
                                                                WithholdingTaxEntry1."Rem Realized Amount (LCY)" :=
                                                                  Round(
                                                                    CurrExchRate.ExchangeAmtFCYToLCY(
                                                                      DocDate, CurrencyCode, WithholdingTaxEntry1."Rem Realized Amount (LCY)", CurrFactor));
                                                                WithholdingTaxEntry1."Rem Realized Base (LCY)" :=
                                                                  Round(
                                                                    CurrExchRate.ExchangeAmtFCYToLCY(
                                                                      DocDate, CurrencyCode, WithholdingTaxEntry1."Rem Realized Base (LCY)", CurrFactor));
                                                            end;

                                                            if ((WithholdingTaxEntry1."Rem Realized Amount" = 0) and
                                                                (WithholdingTaxEntry1."Rem Realized Base" = 0))
                                                            then
                                                                WithholdingTaxEntry1.Closed := true;

                                                            WithholdingTaxEntry1.Modify();
                                                        end;
                                                    until VendLedgerEntry.Next() = 0;

                                                    WithholdingTaxEntry."Applies-to Entry No." := WithholdingTaxEntry1."Entry No.";
                                                end;
                                            end;
                                        end;
                                end;
                        end;
                    end;

                    if WithholdingTaxEntry.Amount = 0 then
                        if NextWithholdingTaxEntryNo = 0 then
                            exit
                        else
                            exit(NextWithholdingTaxEntryNo);

                    if ((WithholdingTaxEntry."Rem Realized Amount" = 0) and
                        (WithholdingTaxEntry."Rem Realized Base" = 0))
                    then
                        WithholdingTaxEntry.Closed := true;
                end;

                if CurrencyCode = '' then begin
                    WithholdingTaxEntry."Base (LCY)" := WithholdingTaxEntry.Base;
                    WithholdingTaxEntry."Amount (LCY)" := WithholdingTaxEntry.Amount;
                    WithholdingTaxEntry."Unrealized Amount (LCY)" := WithholdingTaxEntry."Unrealized Amount";
                    WithholdingTaxEntry."Unrealized Base (LCY)" := WithholdingTaxEntry."Unrealized Base";
                    WithholdingTaxEntry."Rem Realized Base (LCY)" := WithholdingTaxEntry."Rem Realized Base";
                    WithholdingTaxEntry."Rem Realized Amount (LCY)" := WithholdingTaxEntry."Rem Realized Amount";
                    WithholdingTaxEntry."Rem Unrealized Amount (LCY)" := WithholdingTaxEntry."Remaining Unrealized Amount";
                    WithholdingTaxEntry."Rem Unrealized Base (LCY)" := WithholdingTaxEntry."Remaining Unrealized Base";
                end else begin
                    WithholdingTaxEntry."Base (LCY)" :=
                      Round(CurrExchRate.ExchangeAmtFCYToLCY(DocDate, CurrencyCode, WithholdingTaxEntry.Base, CurrFactor));
                    WithholdingTaxEntry."Amount (LCY)" :=
                      Round(CurrExchRate.ExchangeAmtFCYToLCY(DocDate, CurrencyCode, WithholdingTaxEntry.Amount, CurrFactor));
                    WithholdingTaxEntry."Unrealized Base (LCY)" :=
                      Round(CurrExchRate.ExchangeAmtFCYToLCY(DocDate, CurrencyCode, WithholdingTaxEntry."Unrealized Base", CurrFactor));
                    WithholdingTaxEntry."Rem Realized Amount (LCY)" :=
                      Round(CurrExchRate.ExchangeAmtFCYToLCY(DocDate, CurrencyCode, WithholdingTaxEntry."Rem Realized Amount", CurrFactor));
                    WithholdingTaxEntry."Rem Realized Base (LCY)" :=
                      Round(CurrExchRate.ExchangeAmtFCYToLCY(DocDate, CurrencyCode, WithholdingTaxEntry."Rem Realized Base", CurrFactor));
                    WithholdingTaxEntry."Unrealized Amount (LCY)" :=
                      Round(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                          DocDate, CurrencyCode, WithholdingTaxEntry."Unrealized Amount", CurrFactor));
                    WithholdingTaxEntry."Rem Unrealized Amount (LCY)" :=
                      Round(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                          DocDate, CurrencyCode, WithholdingTaxEntry."Remaining Unrealized Amount", CurrFactor));
                    WithholdingTaxEntry."Rem Unrealized Base (LCY)" :=
                      Round(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                          DocDate, CurrencyCode, WithholdingTaxEntry."Remaining Unrealized Base", CurrFactor));
                end;

                if (WithholdingTaxEntry."Applies-to Doc. No." <> '') and UnrealizedWithholding then begin
                    WithholdingTaxEntry1.SetRange("Document Type", WithholdingTaxEntry."Applies-to Doc. Type");
                    WithholdingTaxEntry1.SetRange("Document No.", WithholdingTaxEntry."Applies-to Doc. No.");
                    WithholdingTaxEntry1.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group");
                    WithholdingTaxEntry1.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                    if WithholdingTaxEntry1.FindFirst() then begin
                        WithholdingTaxEntry1."Rem Unrealized Amount (LCY)" :=
                          WithholdingTaxEntry1."Rem Unrealized Amount (LCY)" + WithholdingTaxEntry."Unrealized Amount (LCY)";
                        WithholdingTaxEntry1."Rem Unrealized Base (LCY)" :=
                          WithholdingTaxEntry1."Rem Unrealized Base (LCY)" + WithholdingTaxEntry."Unrealized Base (LCY)";
                        WithholdingTaxEntry1.Modify();
                        WithholdingTaxEntry."Rem Unrealized Amount (LCY)" := 0;
                        WithholdingTaxEntry."Rem Unrealized Base (LCY)" := 0;
                    end;
                end;

                if WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest then
                    if Abs(WithholdingTaxEntry.Base) < WithholdingPostingSetup."Wthldg. Tax Min. Inv. Amount" then
                        exit;

                WithholdingTaxEntry.Insert();
                NextWithholdingTaxEntryNo := WithholdingTaxEntry."Entry No." + 1;

                if WithholdingTaxEntry1.Prepayment then begin
                    WithholdingTaxEntry3.Reset();
                    WithholdingTaxEntry3.SetCurrentKey("Applies-to Entry No.");
                    WithholdingTaxEntry3.SetRange("Applies-to Entry No.", WithholdingTaxEntry1."Entry No.");
                    WithholdingTaxEntry3.CalcSums(Amount, "Amount (LCY)");

                    if (Abs(Abs(WithholdingTaxEntry3.Amount) - Abs(WithholdingTaxEntry1."Unrealized Amount")) < 0.1) and
                       (Abs(Abs(WithholdingTaxEntry3.Amount) - Abs(WithholdingTaxEntry1."Unrealized Amount")) > 0)
                    then begin
                        WithholdingTaxEntry."Withholding Tax Difference" := WithholdingTaxEntry1."Unrealized Amount" - WithholdingTaxEntry3.Amount;
                        WithholdingTaxEntry.Amount := WithholdingTaxEntry.Amount + WithholdingTaxEntry."Withholding Tax Difference";
                        WithholdingTaxEntry.Modify();
                    end;

                    if (Abs(Abs(WithholdingTaxEntry3."Amount (LCY)") - Abs(WithholdingTaxEntry1."Unrealized Amount (LCY)")) < 0.1) and
                       (Abs(Abs(WithholdingTaxEntry3."Amount (LCY)") - Abs(WithholdingTaxEntry1."Unrealized Amount (LCY)")) > 0)
                    then begin
                        WithholdingTaxEntry."Amount (LCY)" := WithholdingTaxEntry."Amount (LCY)" +
                          WithholdingTaxEntry1."Unrealized Amount (LCY)" - WithholdingTaxEntry3."Amount (LCY)";
                        WithholdingTaxEntry.Modify();
                    end;
                end;
            end;
        exit(NextWithholdingTaxEntryNo);
    end;

    procedure NextEntryNo(): Integer
    var
        NewWithholdingTaxEntry: Record "Withholding Tax Entry";
    begin
        NewWithholdingTaxEntry.Reset();
        exit(NewWithholdingTaxEntry.GetLastEntryNo() + 1);
    end;

    procedure CheckPmtDisc(PostingDate: Date; PmtDiscDate: Date; Amount1: Decimal; Amount2: Decimal; Amount3: Decimal; Amount4: Decimal): Boolean
    begin
        if (PostingDate <= PmtDiscDate) and
           (Amount1 >= (Amount2 - Amount3)) and
           (Amount4 >= (Amount2 - Amount3))
        then
            exit(true);

        exit(false);
    end;

    procedure InitWithholdingTaxEntry(TempWithholdingTaxEntry: Record "Withholding Tax Entry"; AppldAmount: Decimal; PaymentAmount1: Decimal; var WithholdingTaxEntry3: Record "Withholding Tax Entry")
    var
        WithholdingTaxEntry2: Record "Withholding Tax Entry";
        WithholdingTax: Record "Withholding Tax Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
        WithholdingTaxEntry4: Record "Withholding Tax Entry";
        NoSeries: Codeunit "No. Series";
    begin
        WithholdingTaxEntry2.Init();
        WithholdingTaxEntry2."Posting Date" := TempGenJnlLine."Document Date";
        WithholdingTaxEntry2."Entry No." := NextEntryNo();
        WithholdingTaxEntry2."Document Date" := TempWithholdingTaxEntry."Document Date";
        WithholdingTaxEntry2."Document Type" := TempGenJnlLine."Document Type";
        WithholdingTaxEntry2."Document No." := DocNo;
        WithholdingTaxEntry2."Gen. Bus. Posting Group" := TempWithholdingTaxEntry."Gen. Bus. Posting Group";
        WithholdingTaxEntry2."Gen. Prod. Posting Group" := TempWithholdingTaxEntry."Gen. Prod. Posting Group";
        WithholdingTaxEntry2."Bill-to/Pay-to No." := TempWithholdingTaxEntry."Bill-to/Pay-to No.";
        WithholdingTaxEntry2."Wthldg. Tax Bus. Post. Group" := TempWithholdingTaxEntry."Wthldg. Tax Bus. Post. Group";
        WithholdingTaxEntry2."Wthldg. Tax Prod. Post. Group" := TempWithholdingTaxEntry."Wthldg. Tax Prod. Post. Group";
        WithholdingTaxEntry2."Withholding Tax Revenue Type" := TempWithholdingTaxEntry."Withholding Tax Revenue Type";
        WithholdingTaxEntry2."Currency Code" := TempGenJnlLine."Currency Code";
        WithholdingTaxEntry2."Applies-to Entry No." := TempWithholdingTaxEntry."Entry No.";
        WithholdingTaxEntry2."User ID" := UserId;
        WithholdingTaxEntry2."External Document No." := TempGenJnlLine."External Document No.";
        WithholdingTaxEntry2."Original Document No." := TempGenJnlLine."Document No.";
        WithholdingTaxEntry2."Source Code" := TempGenJnlLine."Source Code";
        WithholdingTaxEntry2."Unreal. Wthldg. Tax Entry No." := TempWithholdingTaxEntry."Entry No.";
        WithholdingTaxEntry2."Withholding Tax %" := TempWithholdingTaxEntry."Withholding Tax %";

        VendLedgEntry.Reset();
        VendLedgEntry.SetRange("Document Type", TempGenJnlLine."Document Type");
        VendLedgEntry.SetRange("Document No.", TempGenJnlLine."Document No.");
        if VendLedgEntry.FindLast() then
            WithholdingTaxEntry2."Transaction No." := VendLedgEntry."Transaction No.";

        WithholdingTaxEntry2.Base := Round(AppldAmount);
        WithholdingTaxEntry2.Amount := Round(WithholdingTaxEntry2.Base * WithholdingTaxEntry2."Withholding Tax %" / 100);
        WithholdingTaxEntry2."Payment Amount" := PaymentAmount1;
        WithholdingTaxEntry2."Transaction Type" := WithholdingTaxEntry2."Transaction Type"::Purchase;
        WithholdingPostingSetup.Get(TempWithholdingTaxEntry."Wthldg. Tax Bus. Post. Group", TempWithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");

        if TempGenJnlLine."WHT Certificate Printed" then begin
            WithholdingTaxEntry2."Wthldg. Tax Report Line No" := TempGenJnlLine."Wthldg. Tax Report Line No.";
            WithholdingTax.SetRange("Document No.", TempWithholdingTaxEntry."Document No.");
            if WithholdingTax.FindFirst() then
                WithholdingTaxEntry2."Wthldg. Tax Certificate No." := WithholdingTax."Wthldg. Tax Certificate No.";
        end else begin
            if ((TransType = TransType::Purchase) and
                (TempWithholdingTaxEntry."Document Type" = TempWithholdingTaxEntry."Document Type"::Invoice))
            then
                if (WithholdingReportLineNo = '') and
                   (WithholdingTaxEntry2.Amount <> 0) and
                   (WithholdingPostingSetup."Wthldg. Tax Rep Line No Series" <> '')
                then
                    WithholdingReportLineNo := NoSeries.GetNextNo(WithholdingPostingSetup."Wthldg. Tax Rep Line No Series", WithholdingTaxEntry2."Posting Date");

            WithholdingTaxEntry2."Wthldg. Tax Report Line No" := WithholdingReportLineNo;
        end;

        if WithholdingTaxEntry2."Currency Code" <> '' then begin
            CurrFactor :=
              CurrExchRate.ExchangeRate(
                WithholdingTaxEntry2."Posting Date",
                WithholdingTaxEntry2."Currency Code");
            WithholdingTaxEntry2."Base (LCY)" :=
              Round(
                CurrExchRate.ExchangeAmtFCYToLCY(
                  TempGenJnlLine."Document Date",
                  WithholdingTaxEntry2."Currency Code",
                  WithholdingTaxEntry2.Base, CurrFactor));
            WithholdingTaxEntry2."Amount (LCY)" :=
              Round(
                CurrExchRate.ExchangeAmtFCYToLCY(
                  TempGenJnlLine."Document Date",
                  WithholdingTaxEntry2."Currency Code",
                  WithholdingTaxEntry2.Amount, CurrFactor));
        end else begin
            WithholdingTaxEntry2."Amount (LCY)" := WithholdingTaxEntry2.Amount;
            WithholdingTaxEntry2."Base (LCY)" := WithholdingTaxEntry2.Base;
        end;

        if CurrencyCode = '' then begin
            WithholdingTaxEntry3."Rem Unrealized Amount (LCY)" -= WithholdingTaxEntry2.Amount;
            WithholdingTaxEntry3."Rem Unrealized Base (LCY)" -= WithholdingTaxEntry2.Base;
        end else begin
            WithholdingTaxEntry3."Rem Unrealized Amount (LCY)" -=
              Round(CurrExchRate.ExchangeAmtFCYToLCY(DocDate, CurrencyCode, WithholdingTaxEntry2.Amount, CurrFactor));
            WithholdingTaxEntry3."Rem Unrealized Base (LCY)" -=
              Round(CurrExchRate.ExchangeAmtFCYToLCY(DocDate, CurrencyCode, WithholdingTaxEntry2.Base, CurrFactor));
        end;

        WithholdingTaxEntry3.Closed :=
          (WithholdingTaxEntry3."Remaining Unrealized Base" = 0) and (WithholdingTaxEntry3."Remaining Unrealized Amount" = 0);

        if ((WithholdingTaxEntry2."Rem Realized Amount" = 0) and
            (WithholdingTaxEntry2."Rem Realized Base" = 0))
        then
            WithholdingTaxEntry2.Closed := true;

        WithholdingTaxEntry2.Insert();
        NextWithholdingTaxEntryNo := WithholdingTaxEntry2."Entry No." + 1;
        WithholdingTaxEntry3.Modify();

        WithholdingTaxEntry4.Reset();
        WithholdingTaxEntry4.SetCurrentKey("Applies-to Entry No.");
        WithholdingTaxEntry4.SetRange("Applies-to Entry No.", TempWithholdingTaxEntry."Entry No.");
        WithholdingTaxEntry4.CalcSums(Amount, "Amount (LCY)");

        if (Abs(Abs(WithholdingTaxEntry4.Amount) - Abs(TempWithholdingTaxEntry."Unrealized Amount")) < 0.1) and
           (Abs(Abs(WithholdingTaxEntry4.Amount) - Abs(TempWithholdingTaxEntry."Unrealized Amount")) > 0)
        then begin
            WithholdingTaxEntry2."Withholding Tax Difference" := TempWithholdingTaxEntry."Unrealized Amount" - WithholdingTaxEntry4.Amount;
            WithholdingTaxEntry2.Amount := WithholdingTaxEntry2.Amount + WithholdingTaxEntry2."Withholding Tax Difference";
            WithholdingTaxEntry2.Modify();
        end;

        if (Abs(Abs(WithholdingTaxEntry4."Amount (LCY)") - Abs(TempWithholdingTaxEntry."Unrealized Amount (LCY)")) < 0.1) and
           (Abs(Abs(WithholdingTaxEntry4."Amount (LCY)") - Abs(TempWithholdingTaxEntry."Unrealized Amount (LCY)")) > 0)
        then begin
            WithholdingTaxEntry2."Amount (LCY)" := WithholdingTaxEntry2."Amount (LCY)" +
              TempWithholdingTaxEntry."Unrealized Amount (LCY)" - WithholdingTaxEntry4."Amount (LCY)";
            WithholdingTaxEntry2.Modify();
        end;
    end;

    local procedure CalcWithholdingEntriesRemAmounts(var WithholdingTaxEntry: Record "Withholding Tax Entry"; var ClosingWithholdingTaxEntry: Record "Withholding Tax Entry"; WithholdingTaxPart: Decimal)
    var
        WithholdingBaseToApply: Decimal;
        WithholdingAmountToApply: Decimal;
        WithholdingBaseToApplyLCY: Decimal;
        WithholdingAmountToApplyLCY: Decimal;
    begin
        if WithholdingTaxPart >= 1 then begin
            WithholdingTaxEntry."Remaining Unrealized Amount" += ClosingWithholdingTaxEntry."Remaining Unrealized Amount";
            WithholdingTaxEntry."Remaining Unrealized Base" += ClosingWithholdingTaxEntry."Remaining Unrealized Base";
            WithholdingTaxEntry."Rem Unrealized Amount (LCY)" += ClosingWithholdingTaxEntry."Rem Unrealized Amount (LCY)";
            WithholdingTaxEntry."Rem Unrealized Base (LCY)" += ClosingWithholdingTaxEntry."Rem Unrealized Base (LCY)";

            ClosingWithholdingTaxEntry."Remaining Unrealized Amount" := 0;
            ClosingWithholdingTaxEntry."Remaining Unrealized Base" := 0;
            ClosingWithholdingTaxEntry."Rem Unrealized Amount (LCY)" := 0;
            ClosingWithholdingTaxEntry."Rem Unrealized Base (LCY)" := 0;
        end else begin
            WithholdingBaseToApply := Round(WithholdingTaxEntry."Remaining Unrealized Base" * WithholdingTaxPart);
            WithholdingAmountToApply := Round(WithholdingTaxEntry."Remaining Unrealized Amount" * WithholdingTaxPart);
            WithholdingBaseToApplyLCY := Round(WithholdingTaxEntry."Rem Unrealized Base (LCY)" * WithholdingTaxPart);
            WithholdingAmountToApplyLCY := Round(WithholdingTaxEntry."Remaining Unrealized Amount" * WithholdingTaxPart);

            WithholdingTaxEntry."Remaining Unrealized Amount" -= WithholdingAmountToApply;
            WithholdingTaxEntry."Remaining Unrealized Base" -= WithholdingBaseToApply;
            WithholdingTaxEntry."Rem Unrealized Amount (LCY)" -= WithholdingAmountToApplyLCY;
            WithholdingTaxEntry."Rem Unrealized Base (LCY)" -= WithholdingBaseToApplyLCY;

            ClosingWithholdingTaxEntry."Remaining Unrealized Amount" += WithholdingAmountToApply;
            ClosingWithholdingTaxEntry."Remaining Unrealized Base" += WithholdingBaseToApply;
            ClosingWithholdingTaxEntry."Rem Unrealized Amount (LCY)" += WithholdingAmountToApplyLCY;
            ClosingWithholdingTaxEntry."Rem Unrealized Base (LCY)" += WithholdingBaseToApplyLCY;
        end;

        CloseWithholdingTaxEntry(WithholdingTaxEntry);
        CloseWithholdingTaxEntry(ClosingWithholdingTaxEntry);
    end;

    local procedure CloseWithholdingTaxEntry(var WithholdingTaxEntry: Record "Withholding Tax Entry")
    begin
        if (WithholdingTaxEntry."Remaining Unrealized Base" = 0) and
           (WithholdingTaxEntry."Remaining Unrealized Amount" = 0)
        then
            WithholdingTaxEntry.Closed := true;
    end;

    local procedure SetWithholdingTaxEntryAmounts(var WithholdingTaxEntry: Record "Withholding Tax Entry"; AbsorbBase: Decimal; AmountVAT: Decimal; CurrFactor: Decimal)
    begin
        WithholdingTaxEntry.Amount := 0;
        WithholdingTaxEntry.Base := 0;

        if AbsorbBase <> 0 then
            WithholdingTaxEntry."Unrealized Base" := AbsorbBase
        else
            WithholdingTaxEntry."Unrealized Base" := AmountVAT;

        WithholdingTaxEntry."Unrealized Amount" := Round(WithholdingTaxEntry."Unrealized Base" * WithholdingTaxEntry."Withholding Tax %" / 100);
        WithholdingTaxEntry."Unrealized Base (LCY)" :=
          Round(CurrExchRate.ExchangeAmtFCYToLCY(WithholdingTaxEntry."Document Date", WithholdingTaxEntry."Currency Code", WithholdingTaxEntry."Unrealized Base", CurrFactor));
        WithholdingTaxEntry."Unrealized Amount (LCY)" :=
          Round(CurrExchRate.ExchangeAmtFCYToLCY(WithholdingTaxEntry."Document Date", WithholdingTaxEntry."Currency Code", WithholdingTaxEntry."Unrealized Amount", CurrFactor));
        WithholdingTaxEntry."Remaining Unrealized Amount" := WithholdingTaxEntry."Unrealized Amount";
        WithholdingTaxEntry."Remaining Unrealized Base" := WithholdingTaxEntry."Unrealized Base";
        WithholdingTaxEntry."Rem Unrealized Amount (LCY)" := WithholdingTaxEntry."Unrealized Amount (LCY)";
        WithholdingTaxEntry."Rem Unrealized Base (LCY)" := WithholdingTaxEntry."Unrealized Base (LCY)";
    end;

    local procedure FindWithholdingTaxEntryForApply(var WithholdingTaxEntry: Record "Withholding Tax Entry"; DocType: Enum "Gen. Journal Document Type"; DocNo: Code[20]; WithholdingBusPostingGr: Code[20]; WithholdingProdPostingGr: Code[20]): Boolean
    begin
        WithholdingTaxEntry.Reset();
        WithholdingTaxEntry.SetRange("Document Type", DocType);
        WithholdingTaxEntry.SetRange("Document No.", DocNo);
        WithholdingTaxEntry.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingBusPostingGr);
        WithholdingTaxEntry.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingProdPostingGr);

        exit(WithholdingTaxEntry.FindFirst());
    end;

    procedure InsertVendPrepaymentInvoiceWithholding(var PurchInvHeader: Record "Purch. Inv. Header"; var PurchHeader: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
        GLSetup: Record "General Ledger Setup";
        Vendor: Record Vendor;
        PurchasePostPrepayments: Codeunit "Purchase-Post Prepayments";
    begin
        GLSetup.Get();

        if GLSetup."Enable Withholding Tax" then
            Vendor.Get(PurchInvHeader."Pay-to Vendor No.");

        PurchLine.Reset();
        PurchLine.SetCurrentKey("Document Type", "Document No.", "Wthldg. Tax Bus. Post. Group", "Wthldg. Tax Prod. Post. Group");
        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        PurchLine.SetFilter(Type, '<>%1', PurchLine.Type::" ");
        if PurchLine.FindSet() then
            repeat
                if PurchasePostPrepayments.PrepmtAmount(PurchLine, 0) <> 0 then
                    if WithholdingPostingSetup.Get(PurchLine."Wthldg. Tax Bus. Post. Group", PurchLine."Wthldg. Tax Prod. Post. Group") then
                        if WithholdingPostingSetup."Withholding Tax %" > 0 then begin
                            DocNo := PurchInvHeader."No.";
                            DocType := DocType::Invoice;
                            PayToAccType := PayToAccType::Vendor;
                            PayToVendCustNo := PurchInvHeader."Pay-to Vendor No.";
                            BuyFromAccType := BuyFromAccType::Vendor;
                            GenBusPostGrp := PurchLine."Gen. Bus. Posting Group";
                            GenProdPostGrp := PurchLine."Gen. Prod. Posting Group";
                            TransType := TransType::Purchase;
                            BuyFromVendCustNo := PurchInvHeader."WHT Actual Vendor No.";
                            PostingDate := PurchInvHeader."Posting Date";
                            DocDate := PurchInvHeader."Document Date";
                            CurrencyCode := PurchInvHeader."Currency Code";
                            CurrFactor := PurchInvHeader."Currency Factor";
                            ApplyDocType := PurchInvHeader."Applies-to Doc. Type";
                            ApplyDocNo := PurchInvHeader."Applies-to Doc. No.";
                            SourceCode := PurchInvHeader."Source Code";
                            ReasonCode := PurchInvHeader."Reason Code";

                            if (WithholdingBusPostGrp <> PurchLine."Wthldg. Tax Bus. Post. Group") or
                               (WithholdingProdPostGrp <> PurchLine."Wthldg. Tax Prod. Post. Group")
                            then begin
                                if AmountVAT <> 0 then
                                    InsertPrepaymentUnrealizedWithholding(TType::Purchase);

                                WithholdingBusPostGrp := PurchLine."Wthldg. Tax Bus. Post. Group";
                                WithholdingProdPostGrp := PurchLine."Wthldg. Tax Prod. Post. Group";

                                AmountVAT := 0;
                                PurchInvHeader.Amount := PurchasePostPrepayments.PrepmtAmount(PurchLine, 0);
                                AbsorbBase := PurchLine."Withholding Tax Absorb Base";

                                if AbsorbBase <> 0 then
                                    AmountVAT := AbsorbBase
                                else
                                    AmountVAT := PurchInvHeader.Amount;
                            end else begin
                                WithholdingBusPostGrp := PurchLine."Wthldg. Tax Bus. Post. Group";
                                WithholdingProdPostGrp := PurchLine."Wthldg. Tax Prod. Post. Group";
                                PurchInvHeader.Amount += PurchasePostPrepayments.PrepmtAmount(PurchLine, 0);
                                AbsorbBase += PurchLine."Withholding Tax Absorb Base";

                                if AbsorbBase <> 0 then
                                    AmountVAT := AbsorbBase
                                else
                                    AmountVAT := PurchInvHeader.Amount;
                            end;

                            WithholdingBusPostGrp := PurchLine."Wthldg. Tax Bus. Post. Group";
                            WithholdingProdPostGrp := PurchLine."Wthldg. Tax Prod. Post. Group";
                        end;
            until PurchLine.Next() = 0;

        InsertPrepaymentUnrealizedWithholding(TType::Purchase);
    end;

    procedure InsertVendPrepaymentCrMemoWithholding(var PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; var PurchHeader: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
        GLSetup: Record "General Ledger Setup";
        Vendor: Record Vendor;
    begin
        GLSetup.Get();

        if GLSetup."Enable Withholding Tax" then
            Vendor.Get(PurchCrMemoHeader."Pay-to Vendor No.");

        PurchLine.Reset();
        PurchLine.SetCurrentKey("Document Type", "Document No.", "Wthldg. Tax Bus. Post. Group", "Wthldg. Tax Prod. Post. Group");
        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        PurchLine.SetFilter(Type, '<>%1', PurchLine.Type::" ");
        if PurchLine.FindSet() then
            repeat
                if PurchLine."Prepmt. Line Amount" <> 0 then
                    if WithholdingPostingSetup.Get(PurchLine."Wthldg. Tax Bus. Post. Group", PurchLine."Wthldg. Tax Prod. Post. Group") then
                        if WithholdingPostingSetup."Withholding Tax %" > 0 then begin
                            DocNo := PurchCrMemoHeader."No.";
                            DocType := DocType::"Credit Memo";
                            PayToAccType := PayToAccType::Vendor;
                            PayToVendCustNo := PurchHeader."Pay-to Vendor No.";
                            BuyFromAccType := BuyFromAccType::Vendor;
                            GenBusPostGrp := PurchLine."Gen. Bus. Posting Group";
                            GenProdPostGrp := PurchLine."Gen. Prod. Posting Group";
                            TransType := TransType::Purchase;
                            BuyFromVendCustNo := PurchHeader."WHT Actual Vendor No.";
                            PostingDate := PurchHeader."Posting Date";
                            DocDate := PurchHeader."Document Date";
                            CurrencyCode := PurchHeader."Currency Code";
                            CurrFactor := PurchHeader."Currency Factor";
                            ApplyDocType := PurchHeader."Applies-to Doc. Type";
                            ApplyDocNo := PurchHeader."Applies-to Doc. No.";
                            SourceCode := PurchCrMemoHeader."Source Code";
                            ReasonCode := PurchHeader."Reason Code";

                            if (WithholdingBusPostGrp <> PurchLine."Wthldg. Tax Bus. Post. Group") or
                               (WithholdingProdPostGrp <> PurchLine."Wthldg. Tax Prod. Post. Group")
                            then begin
                                if AmountVAT <> 0 then
                                    InsertPrepaymentUnrealizedWithholding(TType::Purchase);

                                WithholdingBusPostGrp := PurchLine."Wthldg. Tax Bus. Post. Group";
                                WithholdingProdPostGrp := PurchLine."Wthldg. Tax Prod. Post. Group";
                                PurchHeader.Amount := 0;
                                AbsorbBase := 0;
                                AmountVAT := 0;
                                PurchHeader.Amount -= PurchLine."Prepmt. Line Amount";
                                AbsorbBase -= PurchLine."Withholding Tax Absorb Base";

                                if AbsorbBase <> 0 then
                                    AmountVAT := AbsorbBase
                                else
                                    AmountVAT := PurchHeader.Amount;
                            end else begin
                                WithholdingBusPostGrp := PurchLine."Wthldg. Tax Bus. Post. Group";
                                WithholdingProdPostGrp := PurchLine."Wthldg. Tax Prod. Post. Group";
                                PurchHeader.Amount -= PurchLine."Prepmt. Line Amount";
                                AbsorbBase -= PurchLine."Withholding Tax Absorb Base";

                                if AbsorbBase <> 0 then
                                    AmountVAT := AbsorbBase
                                else
                                    AmountVAT := PurchHeader.Amount;
                            end;

                            WithholdingBusPostGrp := PurchLine."Wthldg. Tax Bus. Post. Group";
                            WithholdingProdPostGrp := PurchLine."Wthldg. Tax Prod. Post. Group";
                        end;
            until PurchLine.Next() = 0;

        InsertPrepaymentUnrealizedWithholding(TType::Purchase);
    end;

    procedure InsertPrepaymentUnrealizedWithholding(TransType: Option Purchase,Sale) EntryNo: Integer
    var
        WithholdingTaxEntry: Record "Withholding Tax Entry";
    begin
        if WithholdingPostingSetup.Get(WithholdingBusPostGrp, WithholdingProdPostGrp) then
            if WithholdingPostingSetup."Realized Withholding Tax Type" <> WithholdingPostingSetup."Realized Withholding Tax Type"::" " then begin
                UnrealizedWithholding := (WithholdingPostingSetup."Realized Withholding Tax Type" in [WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest,
                                                                          WithholdingPostingSetup."Realized Withholding Tax Type"::Invoice]);
                WithholdingTaxEntry.Init();
                WithholdingTaxEntry."Entry No." := NextEntryNo();
                WithholdingTaxEntry."Gen. Bus. Posting Group" := GenBusPostGrp;
                WithholdingTaxEntry."Gen. Prod. Posting Group" := GenProdPostGrp;
                WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group" := WithholdingBusPostGrp;
                WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group" := WithholdingProdPostGrp;
                WithholdingTaxEntry."Posting Date" := PostingDate;
                WithholdingTaxEntry."Document Date" := DocDate;
                WithholdingTaxEntry."Document No." := DocNo;
                WithholdingTaxEntry."Withholding Tax %" := WithholdingPostingSetup."Withholding Tax %";
                WithholdingTaxEntry."Applies-to Doc. Type" := ApplyDocType;
                WithholdingTaxEntry."Applies-to Doc. No." := ApplyDocNo;
                WithholdingTaxEntry."Source Code" := SourceCode;
                WithholdingTaxEntry."Reason Code" := ReasonCode;
                WithholdingTaxEntry."Withholding Tax Revenue Type" := WithholdingPostingSetup."Revenue Type";
                WithholdingTaxEntry."Document Type" := DocType;

                if TransType = TransType::Purchase then
                    WithholdingTaxEntry."Transaction Type" := WithholdingTaxEntry."Transaction Type"::Purchase
                else
                    WithholdingTaxEntry."Transaction Type" := WithholdingTaxEntry."Transaction Type"::Sale;

                WithholdingTaxEntry."Actual Vendor No." := ActualVendorNo;
                WithholdingTaxEntry."Source Code" := SourceCode;
                WithholdingTaxEntry."Bill-to/Pay-to No." := PayToVendCustNo;
                WithholdingTaxEntry."User ID" := UserId;
                WithholdingTaxEntry."Currency Code" := CurrencyCode;

                if UnrealizedWithholding then begin
                    WithholdingTaxEntry.Amount := 0;
                    WithholdingTaxEntry.Base := 0;
                    WithholdingTaxEntry.Prepayment := true;
                    if AbsorbBase <> 0 then
                        WithholdingTaxEntry."Unrealized Base" := AbsorbBase
                    else
                        WithholdingTaxEntry."Unrealized Base" := AmountVAT;

                    WithholdingTaxEntry."Unrealized Amount" :=
                      Round(WithholdingTaxEntry."Unrealized Base" * WithholdingTaxEntry."Withholding Tax %" / 100);
                    WithholdingTaxEntry."Remaining Unrealized Amount" := WithholdingTaxEntry."Unrealized Amount";
                    WithholdingTaxEntry."Remaining Unrealized Base" := WithholdingTaxEntry."Unrealized Base";
                end;

                if CurrencyCode = '' then begin
                    WithholdingTaxEntry."Base (LCY)" := WithholdingTaxEntry.Base;
                    WithholdingTaxEntry."Amount (LCY)" := WithholdingTaxEntry.Amount;
                    WithholdingTaxEntry."Unrealized Amount (LCY)" := WithholdingTaxEntry."Unrealized Amount";
                    WithholdingTaxEntry."Unrealized Base (LCY)" := WithholdingTaxEntry."Unrealized Base";
                    WithholdingTaxEntry."Rem Realized Base (LCY)" := WithholdingTaxEntry."Rem Realized Base";
                    WithholdingTaxEntry."Rem Realized Amount (LCY)" := WithholdingTaxEntry."Rem Realized Amount";
                    WithholdingTaxEntry."Rem Unrealized Amount (LCY)" := WithholdingTaxEntry."Remaining Unrealized Amount";
                    WithholdingTaxEntry."Rem Unrealized Base (LCY)" := WithholdingTaxEntry."Remaining Unrealized Base";
                end else begin
                    WithholdingTaxEntry."Base (LCY)" :=
                      Round(CurrExchRate.ExchangeAmtFCYToLCY(DocDate, CurrencyCode, WithholdingTaxEntry.Base, CurrFactor));
                    WithholdingTaxEntry."Amount (LCY)" :=
                      Round(CurrExchRate.ExchangeAmtFCYToLCY(DocDate, CurrencyCode, WithholdingTaxEntry.Amount, CurrFactor));
                    WithholdingTaxEntry."Unrealized Base (LCY)" :=
                      Round(CurrExchRate.ExchangeAmtFCYToLCY(DocDate, CurrencyCode, WithholdingTaxEntry."Unrealized Base", CurrFactor));
                    WithholdingTaxEntry."Rem Realized Amount (LCY)" :=
                      Round(CurrExchRate.ExchangeAmtFCYToLCY(DocDate, CurrencyCode, WithholdingTaxEntry."Rem Realized Amount (LCY)", CurrFactor));
                    WithholdingTaxEntry."Rem Realized Base (LCY)" :=
                      Round(CurrExchRate.ExchangeAmtFCYToLCY(DocDate, CurrencyCode, WithholdingTaxEntry."Rem Realized Base (LCY)", CurrFactor));
                    WithholdingTaxEntry."Unrealized Amount (LCY)" :=
                      Round(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                          DocDate, CurrencyCode, WithholdingTaxEntry."Unrealized Amount", CurrFactor));
                    WithholdingTaxEntry."Rem Unrealized Amount (LCY)" :=
                      Round(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                          DocDate, CurrencyCode, WithholdingTaxEntry."Remaining Unrealized Amount", CurrFactor));
                    WithholdingTaxEntry."Rem Unrealized Base (LCY)" :=
                      Round(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                          DocDate, CurrencyCode, WithholdingTaxEntry."Remaining Unrealized Base", CurrFactor));
                end;

                WithholdingTaxEntry.Insert();
                NextWithholdingTaxEntryNo := WithholdingTaxEntry."Entry No." + 1;
            end;

        exit(NextWithholdingTaxEntryNo);
    end;

    procedure WithholdingAmountJournal(var GenJnlLine1: Record "Gen. Journal Line"; Post: Boolean) WithholdingTaxAmount: Decimal
    var
        WithholdingTaxEntry: Record "Withholding Tax Entry";
        WithholdingTaxEntry3: Record "Withholding Tax Entry";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        VendLedgEntry1: Record "Vendor Ledger Entry";
        WithholdingTaxEntryTemp: Record "Withholding Tax Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
        GenJnlLine: Record "Gen. Journal Line";
        GLSetup: Record "General Ledger Setup";
        TotalWithholdingTaxAmount: Decimal;
        TotalWithholdingTaxAmount2: Decimal;
        TotalWithholdingTaxAmount3: Decimal;
        PaymentAmount: Decimal;
        PaymentAmountLCY: Decimal;
        PaymentAmount1: Decimal;
        AppldAmount: Decimal;
        ExpectedAmount: Decimal;
        TotalWithholdingTaxAmount4: Decimal;
        WithholdingTaxAmount1: Decimal;
        RemainingAmt: Decimal;
        GenJnlLineAmount: Decimal;
    begin
        GenJnlLine.Copy(GenJnlLine1);
        if (GenJnlLine."Document Type" <> GenJnlLine."Document Type"::Payment) and
           (GenJnlLine."Document Type" <> GenJnlLine."Document Type"::Refund)
        then
            exit;

        GLSetup.Get();
        if not GLSetup."Enable Withholding Tax" then
            exit;


        ExitLoop := false;
        TotalWithholdingTaxAmount := 0;
        TotalWithholdingTaxAmount2 := 0;
        TotalWithholdingTaxAmount3 := 0;
        TotalWithholdingTaxAmount4 := 0;
        RemainingAmt := 0;
        TotAmt := 0;
        VendorLedgerEntries.Reset();
        VendorLedgerEntries1.Reset();

        if GenJnlLine."Applies-to Doc. No." = '' then begin
            if GenJnlLine."Applies-to ID" <> '' then begin
                VendorLedgerEntries1.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");
                VendorLedgerEntries1.SetRange(Open, true);
                VendorLedgerEntries1.SetFilter("Document Type", '<>%1', VendorLedgerEntries1."Document Type"::" ");
                if GenJnlLine."Bill-to/Pay-to No." = '' then
                    VendorLedgerEntries1.SetRange("Buy-from Vendor No.", GenJnlLine."Account No.")
                else
                    VendorLedgerEntries1.SetRange("Buy-from Vendor No.", GenJnlLine."Bill-to/Pay-to No.");
            end else
                exit(TotalWithholdingTaxAmount);

            if VendorLedgerEntries1.FindSet() then
                repeat
                    VendorLedgerEntries1.CalcFields(
                      Amount, "Amount (LCY)",
                      "Remaining Amount", "Remaining Amt. (LCY)",
                      "Original Amount", "Original Amt. (LCY)");
                    RemainingAmt := RemainingAmt + VendorLedgerEntries1."Remaining Amount";
                until VendorLedgerEntries1.Next() = 0;

            TotAmt := Abs(GenJnlLine.Amount);

            if GenJnlLine."Applies-to ID" <> '' then begin
                VendorLedgerEntries.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");
                if GenJnlLine."Bill-to/Pay-to No." = '' then
                    VendorLedgerEntries.SetRange("Buy-from Vendor No.", GenJnlLine."Account No.")
                else
                    VendorLedgerEntries.SetRange("Buy-from Vendor No.", GenJnlLine."Bill-to/Pay-to No.");
            end else
                VendorLedgerEntries.SetRange("Applies-to ID", GenJnlLine."Document No.");

            VendorLedgerEntries.SetRange(Open, true);
            VendorLedgerEntries.SetRange("Document Type", VendorLedgerEntries."Document Type"::"Credit Memo");
            if VendorLedgerEntries.FindSet() then
                repeat
                    VendorLedgerEntries.CalcFields(
                      Amount, "Amount (LCY)",
                      "Remaining Amount",
                      "Remaining Amt. (LCY)",
                      "Original Amount",
                      "Original Amt. (LCY)");

                    if CheckPmtDisc(
                         GenJnlLine."Posting Date",
                         VendorLedgerEntries."Pmt. Discount Date",
                         Abs(VendorLedgerEntries."Amount to Apply"),
                         Abs(VendorLedgerEntries."Remaining Amount"),
                         Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"),
                         Abs(TotAmt))
                    then
                        TotAmt := TotAmt - Abs(VendorLedgerEntries."Original Pmt. Disc. Possible");

                    GenJnlLine.Validate(Amount, -Abs(VendorLedgerEntries."Remaining Amount"));
                    RemainingAmt -= VendorLedgerEntries."Remaining Amount";
                    TotAmt += VendorLedgerEntries."Remaining Amount";

                    GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::"Credit Memo";
                    GenJnlLine."Applies-to Doc. No." := VendorLedgerEntries."Document No.";
                    PaymentAmount := GenJnlLine.Amount;
                    PaymentAmount1 := GenJnlLine.Amount;
                    PaymentAmountLCY := GenJnlLine."Amount (LCY)";

                    FilterWithholdingTaxEntry(WithholdingTaxEntry, GenJnlLine);
                    if WithholdingTaxEntry.FindSet() then
                        repeat
                            PurchCrMemoHeader.Reset();
                            PurchCrMemoHeader.SetRange("Applies-to Doc. Type", PurchCrMemoHeader."Applies-to Doc. Type"::Invoice);
                            PurchCrMemoHeader.SetRange("Applies-to Doc. No.", GenJnlLine."Applies-to Doc. No.");
                            if PurchCrMemoHeader.FindFirst() then begin
                                TempRemAmt := 0;
                                VendLedgEntry1.SetRange("Document Type", VendLedgEntry1."Document Type"::"Credit Memo");
                                VendLedgEntry1.SetRange("Document No.", PurchCrMemoHeader."No.");
                                if VendLedgEntry1.FindFirst() then
                                    VendLedgEntry1.CalcFields(Amount, "Remaining Amount");

                                WithholdingTaxEntryTemp.Reset();
                                WithholdingTaxEntryTemp.SetRange("Document Type", WithholdingTaxEntry."Document Type"::"Credit Memo");
                                WithholdingTaxEntryTemp.SetRange("Transaction Type", WithholdingTaxEntry."Transaction Type"::Purchase);
                                WithholdingTaxEntryTemp.SetRange("Document No.", PurchCrMemoHeader."No.");
                                WithholdingTaxEntryTemp.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group");
                                WithholdingTaxEntryTemp.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                                if WithholdingTaxEntryTemp.FindFirst() then begin
                                    TempRemBase := WithholdingTaxEntryTemp."Unrealized Amount";
                                    TempRemAmt := WithholdingTaxEntryTemp."Unrealized Base";
                                end;
                            end;

                            VendLedgEntry.Reset();
                            VendLedgEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
                            VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::"Credit Memo");

                            if VendLedgEntry.FindFirst() then
                                VendLedgEntry.CalcFields(Amount, "Remaining Amount");

                            ExpectedAmount := -(VendLedgEntry.Amount + VendLedgEntry1.Amount);

                            if (GenJnlLine."Posting Date" <= VendLedgEntry."Pmt. Discount Date") and
                               (Abs(PaymentAmount1) >=
                                (Abs(VendLedgEntry."Remaining Amount" +
                                   VendLedgEntry1."Remaining Amount") -
                                 Abs(VendLedgEntry."Original Pmt. Disc. Possible")))
                            then
                                AppldAmount :=
                                  Round(
                                    ((PaymentAmount1 * (WithholdingTaxEntry."Unrealized Base" + TempRemAmt)) /
                                     ExpectedAmount))
                            else
                                AppldAmount :=
                                  Round(
                                    (PaymentAmount1 * (WithholdingTaxEntry."Unrealized Base" + TempRemAmt)) / ExpectedAmount);

                            if GenJnlLine."Currency Code" <> '' then begin
                                CurrFactor :=
                                  CurrExchRate.ExchangeRate(
                                    GenJnlLine."Document Date",
                                    GenJnlLine."Currency Code");

                                WithholdingTaxAmount1 := Round(AppldAmount * WithholdingTaxEntry."Withholding Tax %" / 100);

                                WithholdingTaxEntry3.Reset();
                                WithholdingTaxEntry3.SetCurrentKey("Applies-to Entry No.");
                                WithholdingTaxEntry3.SetRange("Applies-to Entry No.", WithholdingTaxEntry."Entry No.");
                                WithholdingTaxEntry3.CalcSums(Amount);
                                if (Abs(Abs(WithholdingTaxEntry3.Amount) + Abs(WithholdingTaxAmount1) - Abs(WithholdingTaxEntry."Unrealized Amount")) < 0.1) and
                                   (Abs(Abs(WithholdingTaxEntry3.Amount) + Abs(WithholdingTaxAmount1) - Abs(WithholdingTaxEntry."Unrealized Amount")) > 0)
                                then
                                    WithholdingTaxAmount1 := WithholdingTaxAmount1 + (WithholdingTaxEntry."Unrealized Amount" - (WithholdingTaxEntry3.Amount + WithholdingTaxAmount1));

                                TotalWithholdingTaxAmount4 :=
                                    CurrExchRate.ExchangeAmtFCYToLCY(
                                      GenJnlLine."Document Date",
                                      GenJnlLine."Currency Code",
                                      WithholdingTaxAmount1,
                                      CurrFactor);

                                TotalWithholdingTaxAmount4 :=
                                  CurrExchRate.ExchangeAmtLCYToFCY(
                                    GenJnlLine."Document Date",
                                    GenJnlLine."Currency Code",
                                    TotalWithholdingTaxAmount4,
                                    CurrFactor);

                                TotalWithholdingTaxAmount := (TotalWithholdingTaxAmount + TotalWithholdingTaxAmount4);
                            end else begin
                                WithholdingTaxAmount1 := Round(AppldAmount * WithholdingTaxEntry."Withholding Tax %" / 100);
                                WithholdingTaxEntry3.Reset();
                                WithholdingTaxEntry3.SetCurrentKey("Applies-to Entry No.");
                                WithholdingTaxEntry3.SetRange("Applies-to Entry No.", WithholdingTaxEntry."Entry No.");
                                WithholdingTaxEntry3.CalcSums(Amount);

                                if (Abs(Abs(WithholdingTaxEntry3.Amount) + Abs(WithholdingTaxAmount1) - Abs(WithholdingTaxEntry."Unrealized Amount")) < 0.1) and
                                   (Abs(Abs(WithholdingTaxEntry3.Amount) + Abs(WithholdingTaxAmount1) - Abs(WithholdingTaxEntry."Unrealized Amount")) > 0)
                                then
                                    WithholdingTaxAmount1 := WithholdingTaxAmount1 + (WithholdingTaxEntry."Unrealized Amount" - (WithholdingTaxEntry3.Amount + WithholdingTaxAmount1));

                                TotalWithholdingTaxAmount := Round(TotalWithholdingTaxAmount + WithholdingTaxAmount1);
                            end;

                            TotalWithholdingTaxAmount2 := TotalWithholdingTaxAmount;
                        until WithholdingTaxEntry.Next() = 0;

                until VendorLedgerEntries.Next() = 0;

            ExitLoop := false;
            VendorLedgerEntries.Reset();
            if GenJnlLine."Applies-to ID" <> '' then begin
                VendorLedgerEntries.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");
                if GenJnlLine."Bill-to/Pay-to No." = '' then
                    VendorLedgerEntries.SetRange("Buy-from Vendor No.", GenJnlLine."Account No.")
                else
                    VendorLedgerEntries.SetRange("Buy-from Vendor No.", GenJnlLine."Bill-to/Pay-to No.");
            end else
                VendorLedgerEntries.SetRange("Applies-to ID", GenJnlLine."Document No.");

            VendorLedgerEntries.SetRange(Open, true);
            VendorLedgerEntries.SetFilter("Document Type", '<>%1&<>%2',
              VendorLedgerEntries."Document Type"::"Credit Memo", VendorLedgerEntries."Document Type"::" ");
            if VendorLedgerEntries.FindSet() then begin
                repeat
                    VendorLedgerEntries.CalcFields(
                      Amount,
                      "Amount (LCY)",
                      "Remaining Amount",
                      "Remaining Amt. (LCY)",
                      "Original Amount",
                      "Original Amt. (LCY)");

                    if CheckPmtDisc(
                         GenJnlLine."Posting Date",
                         VendorLedgerEntries."Pmt. Discount Date",
                         Abs(VendorLedgerEntries."Amount to Apply"),
                         Abs(VendorLedgerEntries."Remaining Amount"),
                         Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"),
                         Abs(TotAmt))
                    then
                        TotAmt := TotAmt + Abs(VendorLedgerEntries."Original Pmt. Disc. Possible");

                    UpdateAmounts(VendorLedgerEntries, GenJnlLine, RemainingAmt, TotAmt, GenJnlLineAmount, ExitLoop);

                    if VendorLedgerEntries."Document Type" = VendorLedgerEntries."Document Type"::Invoice then
                        GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice;

                    GenJnlLine."Applies-to Doc. No." := VendorLedgerEntries."Document No.";
                    PaymentAmount := GenJnlLine.Amount;
                    PaymentAmount1 := GenJnlLine.Amount;
                    PaymentAmountLCY := GenJnlLine."Amount (LCY)";

                    FilterWithholdingTaxEntry(WithholdingTaxEntry, GenJnlLine);
                    if WithholdingTaxEntry.FindSet() then
                        repeat
                            PurchCrMemoHeader.SetRange("Applies-to Doc. Type", PurchCrMemoHeader."Applies-to Doc. Type"::Invoice);
                            PurchCrMemoHeader.SetRange("Applies-to Doc. No.", GenJnlLine."Applies-to Doc. No.");
                            if PurchCrMemoHeader.FindFirst() then begin
                                TempRemAmt := 0;

                                VendLedgEntry1.SetRange("Document Type", VendLedgEntry1."Document Type"::"Credit Memo");
                                VendLedgEntry1.SetRange("Document No.", PurchCrMemoHeader."No.");
                                if VendLedgEntry1.FindFirst() then
                                    VendLedgEntry1.CalcFields(Amount, "Remaining Amount");

                                WithholdingTaxEntryTemp.Reset();
                                WithholdingTaxEntryTemp.SetRange("Document Type", WithholdingTaxEntry."Document Type"::"Credit Memo");
                                WithholdingTaxEntryTemp.SetRange("Transaction Type", WithholdingTaxEntry."Transaction Type"::Purchase);
                                WithholdingTaxEntryTemp.SetRange("Document No.", PurchCrMemoHeader."No.");
                                WithholdingTaxEntryTemp.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group");
                                WithholdingTaxEntryTemp.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                                if WithholdingTaxEntryTemp.FindFirst() then begin
                                    TempRemBase := WithholdingTaxEntryTemp."Unrealized Amount";
                                    TempRemAmt := WithholdingTaxEntryTemp."Unrealized Base";
                                end;
                            end;

                            VendLedgEntry.Reset();
                            VendLedgEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
                            if GenJnlLine."Applies-to Doc. Type" = GenJnlLine."Applies-to Doc. Type"::Invoice then
                                VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::Invoice);
                            if VendLedgEntry.FindFirst() then
                                VendLedgEntry.CalcFields(Amount, "Remaining Amount");
                            ExpectedAmount := -(VendLedgEntry.Amount + VendLedgEntry1.Amount);

                            if (GenJnlLine."Posting Date" <= VendLedgEntry."Pmt. Discount Date") and
                               (Abs(PaymentAmount1) >=
                                (Abs(VendLedgEntry."Remaining Amount" + VendLedgEntry1."Remaining Amount") -
                                 Abs(VendLedgEntry."Original Pmt. Disc. Possible")))
                            then
                                AppldAmount :=
                                  Round(
                                    (PaymentAmount1 *
                                     (WithholdingTaxEntry."Unrealized Base" + TempRemAmt)) /
                                    ExpectedAmount)
                            else
                                AppldAmount :=
                                  Round(
                                    (PaymentAmount1 *
                                     (WithholdingTaxEntry."Unrealized Base" + TempRemAmt)) /
                                    ExpectedAmount);

                            if GenJnlLine."Currency Code" <> '' then begin
                                CurrFactor :=
                                  CurrExchRate.ExchangeRate(
                                    GenJnlLine."Document Date",
                                    GenJnlLine."Currency Code");
                                WithholdingTaxAmount1 := Round(AppldAmount * WithholdingTaxEntry."Withholding Tax %" / 100);

                                TotalWithholdingTaxAmount4 :=
                                    CurrExchRate.ExchangeAmtFCYToLCY(
                                      GenJnlLine."Document Date",
                                      GenJnlLine."Currency Code",
                                      WithholdingTaxAmount1,
                                       CurrFactor);
                                TotalWithholdingTaxAmount4 :=
                                  CurrExchRate.ExchangeAmtLCYToFCY(
                                    GenJnlLine."Document Date",
                                    GenJnlLine."Currency Code",
                                    TotalWithholdingTaxAmount4,
                                    CurrFactor);
                                TotalWithholdingTaxAmount := (TotalWithholdingTaxAmount + TotalWithholdingTaxAmount4);
                            end else begin
                                WithholdingTaxAmount1 := CalcAppliedWithholdingTaxAmount(VendorLedgerEntries, AppldAmount, WithholdingTaxEntry."Withholding Tax %", ExitLoop);
                                TotalWithholdingTaxAmount := Round(TotalWithholdingTaxAmount + WithholdingTaxAmount1);
                            end;

                            TotalWithholdingTaxAmount2 := TotalWithholdingTaxAmount;
                        until WithholdingTaxEntry.Next() = 0;

                    if ExitLoop then
                        exit(TotalWithholdingTaxAmount2);
                until VendorLedgerEntries.Next() = 0;

                if GenJnlLine."Currency Code" <> '' then begin
                    CurrFactor :=
                      CurrExchRate.ExchangeRate(
                        GenJnlLine."Document Date",
                        GenJnlLine."Currency Code");

                    TotalWithholdingTaxAmount3 :=
                      Round(
                        TotalWithholdingTaxAmount3 +
                        Round(
                          CurrExchRate.ExchangeAmtFCYToLCY(
                            GenJnlLine."Document Date",
                            GenJnlLine."Currency Code",
                            TotalWithholdingTaxAmount2, CurrFactor)));
                end;
            end;

            exit(TotalWithholdingTaxAmount2);
        end;

        TotAmt := Abs(GenJnlLine.Amount);

        VendorLedgerEntries.Reset();
        VendorLedgerEntries.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
        VendorLedgerEntries.SetRange("Document Type", GenJnlLine."Applies-to Doc. Type");
        if VendorLedgerEntries.FindFirst() then
            if VendorLedgerEntries."Document Type" = VendorLedgerEntries."Document Type"::Invoice then begin
                VendorLedgerEntries.CalcFields(
                  Amount,
                  "Amount (LCY)",
                  "Remaining Amount",
                  "Remaining Amt. (LCY)",
                  "Original Amount",
                  "Original Amt. (LCY)");

                if VendorLedgerEntries."Amount to Apply" = 0 then
                    VendorLedgerEntries."Amount to Apply" := -ABSMin(VendorLedgerEntries."Remaining Amount", GenJnlLine.Amount);

                if CheckPmtDisc(
                     GenJnlLine."Posting Date",
                     VendorLedgerEntries."Pmt. Discount Date",
                     Abs(VendorLedgerEntries."Amount to Apply"),
                     Abs(VendorLedgerEntries."Remaining Amount"),
                     Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"),
                     Abs(TotAmt))
                then
                    TotAmt := TotAmt + Abs(VendorLedgerEntries."Original Pmt. Disc. Possible");

                if Abs(VendorLedgerEntries."Remaining Amount") < Abs(TotAmt) then
                    GenJnlLine.Validate(Amount, Abs(VendorLedgerEntries."Remaining Amount"))
                else
                    GenJnlLine.Validate(Amount, TotAmt);
            end else
                if VendorLedgerEntries."Document Type" = VendorLedgerEntries."Document Type"::"Credit Memo" then begin
                    VendorLedgerEntries.CalcFields(
                      Amount,
                      "Amount (LCY)",
                      "Remaining Amount",
                      "Remaining Amt. (LCY)",
                      "Original Amount",
                      "Original Amt. (LCY)");

                    if VendorLedgerEntries."Amount to Apply" = 0 then
                        VendorLedgerEntries."Amount to Apply" := ABSMin(VendorLedgerEntries."Remaining Amount", GenJnlLine.Amount);

                    if CheckPmtDisc(
                         GenJnlLine."Posting Date",
                         VendorLedgerEntries."Pmt. Discount Date",
                         Abs(VendorLedgerEntries."Amount to Apply"),
                         Abs(VendorLedgerEntries."Remaining Amount"),
                         Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"),
                         Abs(TotAmt))
                    then
                        TotAmt := TotAmt + Abs(VendorLedgerEntries."Original Pmt. Disc. Possible");

                    if Abs(VendorLedgerEntries."Remaining Amount") < Abs(TotAmt) then
                        GenJnlLine.Validate(Amount, -Abs(VendorLedgerEntries."Remaining Amount"))
                    else
                        GenJnlLine.Validate(Amount, -TotAmt);
                end;

        TotalWithholdingTaxAmount := 0;
        TempRemAmt := 0;
        PaymentAmount := GenJnlLine.Amount;
        PaymentAmount1 := GenJnlLine.Amount;
        PaymentAmountLCY := GenJnlLine."Amount (LCY)";

        FilterWithholdingTaxEntry(WithholdingTaxEntry, GenJnlLine);
        if WithholdingTaxEntry.FindSet() then begin
            repeat
                PurchCrMemoHeader.SetRange(
                  "Applies-to Doc. Type",
                  PurchCrMemoHeader."Applies-to Doc. Type"::Invoice);
                PurchCrMemoHeader.SetRange("Applies-to Doc. No.", GenJnlLine."Applies-to Doc. No.");
                if PurchCrMemoHeader.FindFirst() then begin
                    TempRemAmt := 0;

                    VendLedgEntry1.SetRange("Document Type", VendLedgEntry1."Document Type"::"Credit Memo");
                    VendLedgEntry1.SetRange("Document No.", PurchCrMemoHeader."No.");
                    if VendLedgEntry1.FindFirst() then
                        VendLedgEntry1.CalcFields(Amount, "Remaining Amount", "Remaining Amt. (LCY)");

                    WithholdingTaxEntryTemp.Reset();
                    WithholdingTaxEntryTemp.SetRange("Document Type", WithholdingTaxEntry."Document Type"::"Credit Memo");
                    WithholdingTaxEntryTemp.SetRange("Transaction Type", WithholdingTaxEntry."Transaction Type"::Purchase);
                    WithholdingTaxEntryTemp.SetRange("Document No.", PurchCrMemoHeader."No.");
                    WithholdingTaxEntryTemp.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group");
                    WithholdingTaxEntryTemp.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                    if WithholdingTaxEntryTemp.FindFirst() then
                        TempRemAmt := WithholdingTaxEntryTemp."Unrealized Base";
                end;

                VendLedgEntry.Reset();
                VendLedgEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
                VendLedgEntry.SetRange("Document Type", GenJnlLine."Applies-to Doc. Type");
                if VendLedgEntry.FindFirst() then
                    VendLedgEntry.CalcFields(Amount, "Remaining Amount", "Remaining Amt. (LCY)");
                ExpectedAmount := -(VendLedgEntry.Amount + VendLedgEntry1.Amount);
                AppldAmount :=
                  Round(
                    (PaymentAmount1 * (WithholdingTaxEntry."Unrealized Base" + TempRemAmt)) /
                    ExpectedAmount);

                if GenJnlLine."Currency Code" <> '' then begin
                    CurrFactor :=
                      CurrExchRate.ExchangeRate(
                        GenJnlLine."Document Date",
                        GenJnlLine."Currency Code");

                    WithholdingTaxAmount1 := Round(AppldAmount * WithholdingTaxEntry."Withholding Tax %" / 100);
                    WithholdingTaxEntry3.Reset();
                    WithholdingTaxEntry3.SetCurrentKey("Applies-to Entry No.");
                    WithholdingTaxEntry3.SetRange("Applies-to Entry No.", WithholdingTaxEntry."Entry No.");
                    WithholdingTaxEntry3.CalcSums(Amount);
                    if (Abs(Abs(WithholdingTaxEntry3.Amount) + Abs(WithholdingTaxAmount1) - Abs(WithholdingTaxEntry."Unrealized Amount")) < 0.1) and
                       (Abs(Abs(WithholdingTaxEntry3.Amount) + Abs(WithholdingTaxAmount1) - Abs(WithholdingTaxEntry."Unrealized Amount")) > 0)
                    then
                        WithholdingTaxAmount1 := WithholdingTaxAmount1 + (WithholdingTaxEntry."Unrealized Amount" - (WithholdingTaxEntry3.Amount + WithholdingTaxAmount1));


                    TotalWithholdingTaxAmount4 :=
                        CurrExchRate.ExchangeAmtFCYToLCY(
                          GenJnlLine."Document Date",
                          GenJnlLine."Currency Code",
                          WithholdingTaxAmount1,
                          CurrFactor);

                    TotalWithholdingTaxAmount4 :=
                      CurrExchRate.ExchangeAmtLCYToFCY(
                        GenJnlLine."Document Date",
                        GenJnlLine."Currency Code",
                        TotalWithholdingTaxAmount4,
                        CurrFactor);

                    TotalWithholdingTaxAmount := (TotalWithholdingTaxAmount + TotalWithholdingTaxAmount4);
                end else begin
                    WithholdingTaxAmount1 := Round(AppldAmount * WithholdingTaxEntry."Withholding Tax %" / 100);
                    WithholdingTaxEntry3.Reset();
                    WithholdingTaxEntry3.SetCurrentKey("Applies-to Entry No.");
                    WithholdingTaxEntry3.SetRange("Applies-to Entry No.", WithholdingTaxEntry."Entry No.");
                    WithholdingTaxEntry3.CalcSums(Amount);
                    TotalWithholdingTaxAmount := Round(TotalWithholdingTaxAmount + WithholdingTaxAmount1, GLSetup."Inv. Rounding Precision (LCY)", '=');
                end;
            until WithholdingTaxEntry.Next() = 0;

            exit(TotalWithholdingTaxAmount);
        end;
    end;

    procedure CalcVendExtraWithholdingForEarliest(var GenJnlLine: Record "Gen. Journal Line") WithholdingTaxAmount: Decimal
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        WithholdingTaxEntry: Record "Withholding Tax Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        VendLedgEntry1: Record "Vendor Ledger Entry";
        WithholdingTaxEntryTemp: Record "Withholding Tax Entry";
        WithholdingTaxEntry3: Record "Withholding Tax Entry";
        GLSetup: Record "General Ledger Setup";
        Vendor: Record Vendor;
        TotalWithholdingTaxBase: Decimal;
        WithholdingTaxBase: Decimal;
        TotalWithholdingTaxAmount: Decimal;
        TotalWithholdingTaxAmount2: Decimal;
        TotalWithholdingTaxAmount3: Decimal;
        PaymentAmount1: Decimal;
        AppldAmount: Decimal;
        ExpectedAmount: Decimal;
        Diff: Decimal;
        RemainingAmt: Decimal;
    begin
        GLSetup.Get();
        if GLSetup."Enable Withholding Tax" then
            if GenJnlLine."Bill-to/Pay-to No." = '' then
                Vendor.Get(GenJnlLine."Account No.")
            else
                Vendor.Get(GenJnlLine."Bill-to/Pay-to No.");

        WithholdingTaxAmount := 0;
        TotalWithholdingTaxBase := 0;
        WithholdingTaxBase := 0;

        if WithholdingPostingSetup.Get(
             GenJnlLine."Wthldg. Tax Bus. Post. Group",
             GenJnlLine."Wthldg. Tax Prod. Post. Group")
        then
            if (WithholdingPostingSetup."Realized Withholding Tax Type" =
                WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest)
            then
                if GenJnlLine."Withholding Tax Absorb Base" <> 0 then
                    WithholdingTaxBase := Abs(GenJnlLine."Withholding Tax Absorb Base")
                else
                    WithholdingTaxBase := Abs(GenJnlLine.Amount);

        TotalWithholdingTaxBase := WithholdingTaxBase;

        if GenJnlLine."Applies-to Doc. No." <> '' then begin
            VendorLedgerEntry.Reset();
            VendorLedgerEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
            if (GenJnlLine."Document Type" = GenJnlLine."Document Type"::Payment) then
                VendorLedgerEntry.SetFilter(
                  "Document Type",
                  '%1',
                  VendorLedgerEntry."Document Type"::Invoice);

            if (GenJnlLine."Document Type" = GenJnlLine."Document Type"::Refund) then
                VendorLedgerEntry.SetFilter(
                  "Document Type",
                  '%1',
                  VendorLedgerEntry."Document Type"::"Credit Memo");

            if (GenJnlLine."Document Type" = GenJnlLine."Document Type"::Invoice) then
                VendorLedgerEntry.SetFilter(
                  "Document Type",
                  '%1',
                  VendorLedgerEntry."Document Type"::Payment);

            if (GenJnlLine."Document Type" = GenJnlLine."Document Type"::"Credit Memo") then
                VendorLedgerEntry.SetFilter(
                  "Document Type",
                  '%1',
                  VendorLedgerEntry."Document Type"::Refund);

            if VendorLedgerEntry.FindFirst() then begin
                if GenJnlLine."Currency Code" <> VendorLedgerEntry."Currency Code" then
                    Error(CurrencyCodeSameErr);

                if VendorLedgerEntry.Prepayment then begin
                    TotalWithholdingTaxAmount := 0;
                    PaymentAmount1 := GenJnlLine.Amount;

                    WithholdingTaxEntry.Reset();
                    WithholdingTaxEntry.SetCurrentKey("Transaction Type", "Document No.", "Document Type", "Bill-to/Pay-to No.");
                    WithholdingTaxEntry.SetRange("Transaction Type", WithholdingTaxEntry."Transaction Type"::Purchase);
                    if GenJnlLine."Applies-to Doc. No." <> '' then begin
                        WithholdingTaxEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
                        WithholdingTaxEntry.SetRange("Document Type", GenJnlLine."Applies-to Doc. Type");
                    end else
                        WithholdingTaxEntry.SetRange("Bill-to/Pay-to No.", GenJnlLine."Account No.");
                    if WithholdingTaxEntry.FindSet() then begin
                        repeat
                            PurchCrMemoHeader.SetRange(
                              "Applies-to Doc. Type",
                              PurchCrMemoHeader."Applies-to Doc. Type"::Invoice);
                            PurchCrMemoHeader.SetRange("Applies-to Doc. No.", GenJnlLine."Applies-to Doc. No.");
                            if PurchCrMemoHeader.FindFirst() then begin
                                TempRemAmt := 0;

                                VendLedgEntry1.SetRange("Document Type", VendLedgEntry1."Document Type"::"Credit Memo");
                                VendLedgEntry1.SetRange("Document No.", PurchCrMemoHeader."No.");
                                if VendLedgEntry1.FindFirst() then
                                    VendLedgEntry1.CalcFields(Amount, "Remaining Amount");

                                WithholdingTaxEntryTemp.Reset();
                                WithholdingTaxEntryTemp.SetRange("Document Type", WithholdingTaxEntry."Document Type"::"Credit Memo");
                                WithholdingTaxEntryTemp.SetRange("Transaction Type", WithholdingTaxEntry."Transaction Type"::Purchase);
                                WithholdingTaxEntryTemp.SetRange("Document No.", PurchCrMemoHeader."No.");
                                WithholdingTaxEntryTemp.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group");
                                WithholdingTaxEntryTemp.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                                if WithholdingTaxEntryTemp.FindFirst() then
                                    TempRemAmt := WithholdingTaxEntryTemp."Unrealized Base";
                            end;

                            VendLedgEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
                            VendLedgEntry.SetRange("Document Type", GenJnlLine."Applies-to Doc. Type");
                            if VendLedgEntry.FindFirst() then
                                VendLedgEntry.CalcFields(Amount, "Remaining Amount");
                            ExpectedAmount := -(VendLedgEntry.Amount + VendLedgEntry1.Amount);
                            if (GenJnlLine."Posting Date" <= VendLedgEntry."Pmt. Discount Date") and
                               (Abs(PaymentAmount1) >= (Abs(VendLedgEntry."Remaining Amount" +
                                                          VendLedgEntry1."Remaining Amount") -
                                                        Abs(VendLedgEntry."Original Pmt. Disc. Possible")))
                            then
                                AppldAmount :=
                                  Round(
                                    ((PaymentAmount1 - VendLedgEntry."Original Pmt. Disc. Possible") *
                                     (WithholdingTaxEntry."Unrealized Base" + TempRemAmt)) / ExpectedAmount)
                            else
                                AppldAmount :=
                                  Round(
                                    (PaymentAmount1 * (WithholdingTaxEntry."Unrealized Base" + TempRemAmt)) /
                                    ExpectedAmount);

                            TotalWithholdingTaxAmount := Round(TotalWithholdingTaxAmount + AppldAmount * WithholdingTaxEntry."Withholding Tax %" / 100);
                        until WithholdingTaxEntry.Next() = 0;

                        WithholdingTaxEntry3.Reset();
                        WithholdingTaxEntry3.SetCurrentKey("Applies-to Entry No.");
                        WithholdingTaxEntry3.SetRange("Applies-to Entry No.", WithholdingTaxEntry."Entry No.");
                        WithholdingTaxEntry3.CalcSums(Amount, "Amount (LCY)");
                        if (Abs(Abs(WithholdingTaxEntry3.Amount) + Abs(TotalWithholdingTaxAmount) - Abs(WithholdingTaxEntry."Unrealized Amount")) < 0.1) and
                           (Abs(Abs(WithholdingTaxEntry3.Amount) + Abs(TotalWithholdingTaxAmount) - Abs(WithholdingTaxEntry."Unrealized Amount")) > 0)
                        then begin
                            Diff := WithholdingTaxEntry."Unrealized Amount" - (WithholdingTaxEntry3.Amount + TotalWithholdingTaxAmount);
                            TotalWithholdingTaxAmount := TotalWithholdingTaxAmount + Diff;
                        end;

                        exit(Round(TotalWithholdingTaxAmount));
                    end
                end else begin
                    WithholdingTaxEntry.Reset();
                    WithholdingTaxEntry.SetRange("Document No.", VendorLedgerEntry."Document No.");
                    if WithholdingTaxEntry.FindFirst() then
                        if WithholdingPostingSetup.Get(
                             WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group",
                             WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group")
                        then
                            if ((WithholdingPostingSetup."Realized Withholding Tax Type" =
                                 WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest) and
                                (WithholdingTaxEntry."Withholding Tax %" = WithholdingPostingSetup."Withholding Tax %"))
                            then begin
                                TotAmt := 0;
                                TotAmt := GenJnlLine.Amount;

                                VendorLedgerEntries.Reset();
                                VendorLedgerEntries.SetRange("Entry No.", VendorLedgerEntry."Entry No.");
                                if VendorLedgerEntries.FindSet() then begin
                                    VendorLedgerEntries.CalcFields(
                                      Amount, "Amount (LCY)",
                                      "Remaining Amount", "Remaining Amt. (LCY)");

                                    if CheckPmtDisc(
                                         GenJnlLine."Posting Date",
                                         VendorLedgerEntries."Pmt. Discount Date",
                                         Abs(VendorLedgerEntries."Amount to Apply"),
                                         Abs(VendorLedgerEntries."Remaining Amount"),
                                         Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"),
                                         Abs(TotAmt))
                                    then
                                        TotAmt := TotAmt - VendorLedgerEntries."Original Pmt. Disc. Possible";

                                    if Abs(WithholdingTaxEntry."Rem Realized Base") >= WithholdingTaxBase then
                                        TotAmt := 0
                                    else
                                        TotAmt := TotAmt - Abs(WithholdingTaxEntry."Rem Realized Base");
                                end;

                                WithholdingTaxBase := TotAmt;
                            end;
                end;
            end;
        end else
            if GenJnlLine."Applies-to ID" <> '' then begin
                if ((GenJnlLine."Document Type" = GenJnlLine."Document Type"::Invoice) or
                    (GenJnlLine."Document Type" = GenJnlLine."Document Type"::Refund))
                then begin
                    VendorLedgerEntry.Reset();
                    VendorLedgerEntry.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");
                    VendorLedgerEntry.SetFilter(
                      "Document Type",
                      '%1|%2',
                      VendorLedgerEntry."Document Type"::Payment,
                      VendorLedgerEntry."Document Type"::"Credit Memo");
                    if VendorLedgerEntry.FindSet() then
                        repeat
                            WithholdingTaxEntry.Reset();
                            WithholdingTaxEntry.SetRange("Document No.", VendorLedgerEntry."Document No.");
                            if WithholdingTaxEntry.FindSet() then
                                repeat
                                    if WithholdingPostingSetup.Get(
                                         WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group",
                                         WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group")
                                    then
                                        if ((WithholdingPostingSetup."Realized Withholding Tax Type" =
                                             WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest) and
                                            (WithholdingTaxEntry."Withholding Tax %" = WithholdingPostingSetup."Withholding Tax %"))
                                        then
                                            if TotalWithholdingTaxBase > Abs(WithholdingTaxEntry."Rem Realized Base") then begin
                                                TotalWithholdingTaxBase := TotalWithholdingTaxBase - Abs(WithholdingTaxEntry."Rem Realized Base");
                                                if (((GenJnlLine."Document Type" = GenJnlLine."Document Type"::Refund) and
                                                     (WithholdingTaxEntry."Document Type" = WithholdingTaxEntry."Document Type"::"Credit Memo")) or
                                                    ((GenJnlLine."Document Type" = GenJnlLine."Document Type"::Invoice) and
                                                     (WithholdingTaxEntry."Document Type" = WithholdingTaxEntry."Document Type"::Payment)))
                                                then
                                                    WithholdingTaxBase := WithholdingTaxBase - Abs(WithholdingTaxEntry."Rem Realized Base");
                                            end else begin
                                                if (TotalWithholdingTaxBase > 0) and (Abs(TotalWithholdingTaxBase) <= Abs(WithholdingTaxEntry."Rem Realized Base")) then
                                                    TotalWithholdingTaxBase := TotalWithholdingTaxBase - TotalWithholdingTaxBase;

                                                if (((GenJnlLine."Document Type" = GenJnlLine."Document Type"::Refund) and
                                                     (WithholdingTaxEntry."Document Type" = WithholdingTaxEntry."Document Type"::"Credit Memo")) or
                                                    ((GenJnlLine."Document Type" = GenJnlLine."Document Type"::Invoice) and
                                                     (WithholdingTaxEntry."Document Type" = WithholdingTaxEntry."Document Type"::Payment)))
                                                then
                                                    WithholdingTaxBase := 0;
                                            end;
                                until WithholdingTaxEntry.Next() = 0;
                        until VendorLedgerEntry.Next() = 0;
                end;

                if ((GenJnlLine."Document Type" = GenJnlLine."Document Type"::Payment) or
                    (GenJnlLine."Document Type" = GenJnlLine."Document Type"::"Credit Memo"))
                then begin
                    TotalWithholdingTaxAmount := 0;
                    TotalWithholdingTaxAmount2 := 0;
                    TotalWithholdingTaxAmount3 := 0;
                    RemainingAmt := 0;
                    TotAmt := 0;

                    VendorLedgerEntries1.Reset();
                    VendorLedgerEntries1.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");
                    VendorLedgerEntries1.SetRange(Open, true);
                    if GenJnlLine."Bill-to/Pay-to No." = '' then
                        VendorLedgerEntries1.SetRange("Buy-from Vendor No.", GenJnlLine."Account No.")
                    else
                        VendorLedgerEntries1.SetRange("Buy-from Vendor No.", GenJnlLine."Bill-to/Pay-to No.");
                    if VendorLedgerEntries1.FindSet() then
                        repeat
                            VendorLedgerEntries1.CalcFields(
                              Amount, "Amount (LCY)",
                              "Remaining Amount", "Remaining Amt. (LCY)");

                            RemainingAmt := RemainingAmt + VendorLedgerEntries1."Remaining Amt. (LCY)";
                        until VendorLedgerEntries1.Next() = 0;

                    TotAmt := Abs(GenJnlLine."Amount (LCY)");
                    CurrFactor :=
                      CurrExchRate.ExchangeRate(
                        GenJnlLine."Document Date", GenJnlLine."Currency Code");

                    VendorLedgerEntry.Reset();
                    VendorLedgerEntry.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");
                    VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Refund);
                    if VendorLedgerEntry.FindSet() then
                        repeat
                            WithholdingTaxEntry.Reset();
                            WithholdingTaxEntry.SetRange("Document No.", VendorLedgerEntry."Document No.");
                            if WithholdingTaxEntry.FindSet() then
                                repeat
                                    if WithholdingPostingSetup.Get(
                                         WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group",
                                         WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group")
                                    then
                                        if ((WithholdingPostingSetup."Realized Withholding Tax Type" =
                                             WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest) and
                                            (WithholdingTaxEntry."Withholding Tax %" = WithholdingPostingSetup."Withholding Tax %"))
                                        then
                                            if TotalWithholdingTaxBase > Abs(WithholdingTaxEntry."Rem Realized Base") then begin
                                                TotalWithholdingTaxBase := TotalWithholdingTaxBase - Abs(WithholdingTaxEntry."Rem Realized Base");
                                                if GenJnlLine."Document Type" = GenJnlLine."Document Type"::"Credit Memo" then
                                                    WithholdingTaxBase := WithholdingTaxBase - Abs(WithholdingTaxEntry."Rem Realized Base");
                                            end else
                                                if (TotalWithholdingTaxBase > 0) and (Abs(TotalWithholdingTaxBase) <= Abs(WithholdingTaxEntry."Rem Realized Base")) then begin
                                                    TotalWithholdingTaxBase := 0;
                                                    if GenJnlLine."Document Type" = GenJnlLine."Document Type"::"Credit Memo" then
                                                        WithholdingTaxBase := 0;
                                                end;
                                until WithholdingTaxEntry.Next() = 0;
                        until VendorLedgerEntry.Next() = 0;

                    VendorLedgerEntry.Reset();
                    VendorLedgerEntry.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");
                    VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
                    if VendorLedgerEntry.FindSet() then begin
                        repeat
                            if GenJnlLine."Currency Code" <> VendorLedgerEntry."Currency Code" then
                                Error(CurrencyCodeSameErr);

                            if VendorLedgerEntry.Prepayment then begin
                                VendorLedgerEntries.Reset();
                                VendorLedgerEntries.SetRange("Entry No.", VendorLedgerEntry."Entry No.");
                                if VendorLedgerEntries.FindSet() then begin
                                    VendorLedgerEntries.CalcFields(
                                      Amount, "Amount (LCY)",
                                      "Remaining Amount", "Remaining Amt. (LCY)");

                                    if CheckPmtDisc(
                                         GenJnlLine."Posting Date",
                                         VendorLedgerEntries."Pmt. Discount Date",
                                         CurrExchRate.ExchangeAmtFCYToLCY(
                                           GenJnlLine."Document Date",
                                           GenJnlLine."Currency Code",
                                           Abs(VendorLedgerEntries."Amount to Apply"), CurrFactor),
                                         Abs(VendorLedgerEntries."Remaining Amt. (LCY)"),
                                         CurrExchRate.ExchangeAmtFCYToLCY(
                                           GenJnlLine."Document Date",
                                           GenJnlLine."Currency Code",
                                           Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"), CurrFactor),
                                         Abs(TotAmt))
                                    then
                                        TotAmt := TotAmt -
                                          CurrExchRate.ExchangeAmtFCYToLCY(
                                            GenJnlLine."Document Date",
                                            GenJnlLine."Currency Code",
                                            VendorLedgerEntries."Original Pmt. Disc. Possible", CurrFactor);

                                    if (Abs(RemainingAmt) < Abs(TotAmt)) or
                                       (Abs(VendorLedgerEntries."Remaining Amt. (LCY)") < Abs(TotAmt))
                                    then begin
                                        if CheckPmtDisc(
                                             GenJnlLine."Posting Date",
                                             VendorLedgerEntries."Pmt. Discount Date",
                                             CurrExchRate.ExchangeAmtFCYToLCY(
                                               GenJnlLine."Document Date",
                                               GenJnlLine."Currency Code",
                                               Abs(VendorLedgerEntries."Amount to Apply"), CurrFactor),
                                             Abs(VendorLedgerEntries."Remaining Amt. (LCY)"),
                                             CurrExchRate.ExchangeAmtFCYToLCY(
                                               GenJnlLine."Document Date",
                                               GenJnlLine."Currency Code",
                                               Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"), CurrFactor),
                                             Abs(TotAmt))
                                        then begin
                                            GenJnlLine.Validate(
                                              Amount,
                                              Abs(VendorLedgerEntries."Remaining Amt. (LCY)" -
                                                CurrExchRate.ExchangeAmtFCYToLCY(
                                                  GenJnlLine."Document Date",
                                                  GenJnlLine."Currency Code",
                                                  VendorLedgerEntries."Original Pmt. Disc. Possible", CurrFactor)));

                                            if VendorLedgerEntries."Document Type" <>
                                               VendorLedgerEntries."Document Type"::"Credit Memo"
                                            then
                                                TotAmt := TotAmt + VendorLedgerEntries."Remaining Amt. (LCY)";

                                            RemainingAmt :=
                                              RemainingAmt -
                                              VendorLedgerEntries."Remaining Amt. (LCY)";
                                        end else begin
                                            GenJnlLine.Validate(Amount, Abs(VendorLedgerEntries."Remaining Amt. (LCY)"));

                                            if VendorLedgerEntries."Document Type" <>
                                               VendorLedgerEntries."Document Type"::"Credit Memo"
                                            then
                                                TotAmt := TotAmt + VendorLedgerEntries."Remaining Amt. (LCY)";

                                            RemainingAmt := RemainingAmt - VendorLedgerEntries."Remaining Amt. (LCY)";
                                        end;
                                    end else begin
                                        if CheckPmtDisc(
                                             GenJnlLine."Posting Date",
                                             VendorLedgerEntries."Pmt. Discount Date",
                                             CurrExchRate.ExchangeAmtFCYToLCY(
                                               GenJnlLine."Document Date",
                                               GenJnlLine."Currency Code",
                                               Abs(VendorLedgerEntries."Amount to Apply"), CurrFactor),
                                             Abs(VendorLedgerEntries."Remaining Amt. (LCY)"),
                                             CurrExchRate.ExchangeAmtFCYToLCY(
                                               GenJnlLine."Document Date",
                                               GenJnlLine."Currency Code",
                                               Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"), CurrFactor),
                                             Abs(TotAmt))
                                        then
                                            GenJnlLine.Validate(Amount, TotAmt +
                                              CurrExchRate.ExchangeAmtFCYToLCY(
                                                GenJnlLine."Document Date",
                                                GenJnlLine."Currency Code",
                                                VendorLedgerEntries."Original Pmt. Disc. Possible", CurrFactor))
                                        else
                                            GenJnlLine.Validate(Amount, TotAmt);

                                        TotAmt := 0;
                                    end;

                                    if VendorLedgerEntries."Document Type" = VendorLedgerEntries."Document Type"::Invoice then
                                        GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice
                                    else begin
                                        if VendorLedgerEntries."Document Type" = VendorLedgerEntries."Document Type"::"Credit Memo" then
                                            GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::"Credit Memo";

                                        RemainingAmt := RemainingAmt + VendorLedgerEntries."Remaining Amt. (LCY)";
                                        TotAmt := TotAmt + VendorLedgerEntries."Remaining Amt. (LCY)";
                                    end;

                                    GenJnlLine."Applies-to Doc. No." := VendorLedgerEntries."Document No.";
                                    PaymentAmount1 := GenJnlLine.Amount;

                                    WithholdingTaxEntry.Reset();
                                    WithholdingTaxEntry.SetCurrentKey("Transaction Type", "Document No.", "Document Type", "Bill-to/Pay-to No.");
                                    WithholdingTaxEntry.SetRange("Transaction Type", WithholdingTaxEntry."Transaction Type"::Purchase);
                                    if GenJnlLine."Applies-to Doc. No." <> '' then begin
                                        WithholdingTaxEntry.SetRange("Document Type", GenJnlLine."Applies-to Doc. Type");
                                        WithholdingTaxEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
                                    end else
                                        WithholdingTaxEntry.SetRange("Bill-to/Pay-to No.", GenJnlLine."Account No.");
                                    if WithholdingTaxEntry.FindSet() then
                                        repeat
                                            PurchCrMemoHeader.Reset();
                                            PurchCrMemoHeader.SetRange("Applies-to Doc. No.", GenJnlLine."Applies-to Doc. No.");
                                            PurchCrMemoHeader.SetRange("Applies-to Doc. Type", PurchCrMemoHeader."Applies-to Doc. Type"::Invoice);
                                            if PurchCrMemoHeader.FindFirst() then begin
                                                TempRemAmt := 0;

                                                VendLedgEntry1.SetRange("Document Type", VendLedgEntry1."Document Type"::"Credit Memo");
                                                VendLedgEntry1.SetRange("Document No.", PurchCrMemoHeader."No.");
                                                if VendLedgEntry1.FindFirst() then
                                                    VendLedgEntry1.CalcFields(Amount, "Remaining Amount",
                                                      "Amount (LCY)", "Remaining Amt. (LCY)");

                                                WithholdingTaxEntryTemp.Reset();
                                                WithholdingTaxEntryTemp.SetRange("Document Type", WithholdingTaxEntry."Document Type"::"Credit Memo");
                                                WithholdingTaxEntryTemp.SetRange("Transaction Type", WithholdingTaxEntry."Transaction Type"::Purchase);
                                                WithholdingTaxEntryTemp.SetRange("Document No.", PurchCrMemoHeader."No.");
                                                WithholdingTaxEntryTemp.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group");
                                                WithholdingTaxEntryTemp.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                                                if WithholdingTaxEntryTemp.FindFirst() then begin
                                                    TempRemBase := WithholdingTaxEntryTemp."Unrealized Amount";
                                                    TempRemAmt := WithholdingTaxEntryTemp."Unrealized Base";
                                                end;
                                            end;

                                            VendLedgEntry.Reset();
                                            VendLedgEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
                                            if GenJnlLine."Applies-to Doc. Type" = GenJnlLine."Applies-to Doc. Type"::Invoice then
                                                VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::Invoice)
                                            else
                                                if GenJnlLine."Applies-to Doc. Type" = GenJnlLine."Applies-to Doc. Type"::"Credit Memo" then
                                                    VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::"Credit Memo");
                                            if VendLedgEntry.FindFirst() then
                                                VendLedgEntry.CalcFields(Amount, "Remaining Amount",
                                                  "Amount (LCY)", "Remaining Amt. (LCY)");
                                            ExpectedAmount := -(VendLedgEntry.Amount + VendLedgEntry1.Amount);
                                            if (GenJnlLine."Posting Date" <= VendLedgEntry."Pmt. Discount Date") and
                                               (Abs(PaymentAmount1) >=
                                                (Abs(VendLedgEntry."Remaining Amt. (LCY)" + VendLedgEntry1."Remaining Amt. (LCY)") -
                                                 Abs(
                                                   CurrExchRate.ExchangeAmtFCYToLCY(
                                                     GenJnlLine."Document Date",
                                                     GenJnlLine."Currency Code",
                                                     VendorLedgerEntries."Original Pmt. Disc. Possible", CurrFactor))))
                                            then
                                                AppldAmount :=
                                                  Round(
                                                    ((PaymentAmount1 -
                                                      CurrExchRate.ExchangeAmtFCYToLCY(
                                                        GenJnlLine."Document Date",
                                                        GenJnlLine."Currency Code",
                                                        VendorLedgerEntries."Original Pmt. Disc. Possible", CurrFactor)) *
                                                     (WithholdingTaxEntry."Unrealized Base" + TempRemAmt)) /
                                                    ExpectedAmount)
                                            else
                                                AppldAmount :=
                                                  Round(
                                                    (PaymentAmount1 *
                                                     (WithholdingTaxEntry."Unrealized Base" + TempRemAmt)) /
                                                    ExpectedAmount);

                                            TotalWithholdingTaxAmount := Round(TotalWithholdingTaxAmount + AppldAmount * WithholdingTaxEntry."Withholding Tax %" / 100);

                                            if GenJnlLine."Currency Code" <> '' then
                                                TotalWithholdingTaxAmount2 :=
                                                  Round(
                                                    TotalWithholdingTaxAmount2 +
                                                    Round(
                                                      CurrExchRate.ExchangeAmtLCYToFCY(
                                                        GenJnlLine."Document Date",
                                                        GenJnlLine."Currency Code",
                                                        AppldAmount * WithholdingTaxEntry."Withholding Tax %" / 100,
                                                        CurrFactor)))
                                            else
                                                TotalWithholdingTaxAmount2 := TotalWithholdingTaxAmount;

                                            WithholdingTaxEntry3.Reset();
                                            WithholdingTaxEntry3.SetCurrentKey("Applies-to Entry No.");
                                            WithholdingTaxEntry3.SetRange("Applies-to Entry No.", WithholdingTaxEntry."Entry No.");
                                            WithholdingTaxEntry3.CalcSums(Amount, "Amount (LCY)");
                                            if (Abs(Abs(WithholdingTaxEntry3.Amount) + Abs(TotalWithholdingTaxAmount2) - Abs(WithholdingTaxEntry."Unrealized Amount")) < 0.1) and
                                               (Abs(Abs(WithholdingTaxEntry3.Amount) + Abs(TotalWithholdingTaxAmount2) - Abs(WithholdingTaxEntry."Unrealized Amount")) > 0)
                                            then begin
                                                Diff := WithholdingTaxEntry."Unrealized Amount" - (WithholdingTaxEntry3.Amount + TotalWithholdingTaxAmount2);
                                                TotalWithholdingTaxAmount2 := TotalWithholdingTaxAmount2 + Diff;
                                            end;

                                        until WithholdingTaxEntry.Next() = 0;
                                end;
                            end else begin
                                WithholdingTaxEntry.Reset();
                                WithholdingTaxEntry.SetRange("Document No.", VendorLedgerEntry."Document No.");
                                if WithholdingTaxEntry.FindSet() then
                                    repeat
                                        if WithholdingPostingSetup.Get(
                                             WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group",
                                             WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group")
                                        then
                                            if ((WithholdingPostingSetup."Realized Withholding Tax Type" =
                                                 WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest) and
                                                (WithholdingTaxEntry."Withholding Tax %" = WithholdingPostingSetup."Withholding Tax %"))
                                            then begin
                                                VendorLedgerEntries.Reset();
                                                VendorLedgerEntries.SetRange("Entry No.", VendorLedgerEntry."Entry No.");
                                                if VendorLedgerEntries.FindSet() then begin
                                                    VendorLedgerEntries.CalcFields(
                                                      Amount, "Amount (LCY)",
                                                      "Remaining Amount", "Remaining Amt. (LCY)");

                                                    if CheckPmtDisc(
                                                         GenJnlLine."Posting Date",
                                                         VendorLedgerEntries."Pmt. Discount Date",
                                                         CurrExchRate.ExchangeAmtFCYToLCY(
                                                           GenJnlLine."Document Date",
                                                           GenJnlLine."Currency Code",
                                                           Abs(VendorLedgerEntries."Amount to Apply"), CurrFactor),
                                                         Abs(VendorLedgerEntries."Remaining Amt. (LCY)"),
                                                         CurrExchRate.ExchangeAmtFCYToLCY(
                                                           GenJnlLine."Document Date",
                                                           GenJnlLine."Currency Code",
                                                           Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"), CurrFactor),
                                                         Abs(TotAmt))
                                                    then
                                                        TotAmt := TotAmt -
                                                          CurrExchRate.ExchangeAmtFCYToLCY(
                                                            GenJnlLine."Document Date",
                                                            GenJnlLine."Currency Code",
                                                            VendorLedgerEntries."Original Pmt. Disc. Possible", CurrFactor);

                                                    if (Abs(RemainingAmt) < Abs(TotAmt)) or
                                                       (Abs(VendorLedgerEntries."Remaining Amt. (LCY)") < Abs(TotAmt))
                                                    then begin
                                                        if VendorLedgerEntries."Document Type" <>
                                                           VendorLedgerEntries."Document Type"::"Credit Memo"
                                                        then
                                                            TotAmt := TotAmt + VendorLedgerEntries."Remaining Amt. (LCY)";
                                                        RemainingAmt := RemainingAmt - VendorLedgerEntries."Remaining Amt. (LCY)";
                                                    end else
                                                        TotAmt := 0;
                                                end;
                                            end;
                                    until WithholdingTaxEntry.Next() = 0;
                            end;
                        until VendorLedgerEntry.Next() = 0;

                        if TotAmt > 0 then begin
                            TotalWithholdingTaxAmount3 := Round(TotalWithholdingTaxAmount3 + TotAmt * WithholdingPostingSetup."Withholding Tax %" / 100);

                            if GenJnlLine."Currency Code" <> '' then
                                TotalWithholdingTaxAmount2 :=
                                  Round(
                                    TotalWithholdingTaxAmount2 +
                                    Round(
                                      CurrExchRate.ExchangeAmtLCYToFCY(
                                        GenJnlLine."Document Date",
                                        GenJnlLine."Currency Code",
                                        TotAmt * WithholdingPostingSetup."Withholding Tax %" / 100,
                                        CurrFactor)))
                            else
                                TotalWithholdingTaxAmount2 := TotalWithholdingTaxAmount2 + TotalWithholdingTaxAmount3;
                        end else
                            WithholdingTaxBase := 0;

                        if Round(TotalWithholdingTaxAmount2) <> 0 then
                            exit(Round(TotalWithholdingTaxAmount2));
                    end;
                end;
            end;

        WithholdingTaxAmount := Round(WithholdingTaxBase * WithholdingPostingSetup."Withholding Tax %" / 100);

        if WithholdingPostingSetup.Get(GenJnlLine."Wthldg. Tax Bus. Post. Group", GenJnlLine."Wthldg. Tax Prod. Post. Group") then
            if WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest then
                if WithholdingTaxBase < WithholdingPostingSetup."Wthldg. Tax Min. Inv. Amount" then
                    WithholdingTaxAmount := 0;
    end;

    local procedure UpdateAmounts(VendorLedgerEntry: Record "Vendor Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line"; var RemainingAmt: Decimal; var TotAmt: Decimal; var GenJnlLineAmount: Decimal; var ExitLoop: Boolean)
    begin
        if (Abs(RemainingAmt) < Abs(TotAmt)) or
           (Abs(VendorLedgerEntry."Remaining Amount") < Abs(TotAmt))
        then begin
            GenJnlLineAmount := Abs(ABSMin(VendorLedgerEntry."Remaining Amount", RemainingAmt));
            GenJournalLine.Validate(Amount, Abs(ABSMin(VendorLedgerEntry."Amount to Apply", GenJnlLineAmount)));
            TotAmt := TotAmt - Abs(GenJournalLine.Amount);
            RemainingAmt := RemainingAmt + Abs(GenJournalLine.Amount);
        end else begin
            GenJournalLine.Validate(Amount, TotAmt);
            ExitLoop := true;
        end;
    end;

    local procedure FilterWithholdingTaxEntry(var WithholdingTaxEntry: Record "Withholding Tax Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        WithholdingTaxEntry.Reset();
        WithholdingTaxEntry.SetCurrentKey("Transaction Type", "Document No.", "Document Type", "Bill-to/Pay-to No.");
        WithholdingTaxEntry.SetRange("Transaction Type", WithholdingTaxEntry."Transaction Type"::Purchase);
        if GenJournalLine."Applies-to Doc. No." <> '' then begin
            WithholdingTaxEntry.SetRange("Document Type", GenJournalLine."Applies-to Doc. Type");
            WithholdingTaxEntry.SetRange("Document No.", GenJournalLine."Applies-to Doc. No.");
        end else
            WithholdingTaxEntry.SetRange("Bill-to/Pay-to No.", GenJournalLine."Account No.");
    end;

    procedure CalcAppliedWithholdingTaxAmount(var VendorLedgerEntry: Record "Vendor Ledger Entry"; AppliedAmountWithholding: Decimal; WithholdingTaxPercent: Decimal; ExitLoop: Boolean): Decimal
    var
        Result: Decimal;
        EntryNo: Integer;
        TotalAmountToApply: Decimal;
        AppliedAmount: Decimal;
    begin
        if ExitLoop then begin
            // Here we can have several Vendor Ledger Entries to be applied.
            // So we need iterate through remaining entries to calculate Withholding Tax amount per entry
            EntryNo := VendorLedgerEntry."Entry No.";
            TotalAmountToApply := AppliedAmountWithholding;
            repeat
                AppliedAmount := ABSMin(-VendorLedgerEntry."Amount to Apply", TotalAmountToApply);
                Result += CalcWithholdingTaxAmount(AppliedAmount, WithholdingTaxPercent);
                TotalAmountToApply -= AppliedAmount;
            until (VendorLedgerEntry.Next() = 0) or (TotalAmountToApply <= 0);

            VendorLedgerEntry.Get(EntryNo);

            exit(Result);
        end;

        exit(CalcWithholdingTaxAmount(AppliedAmountWithholding, WithholdingTaxPercent));
    end;

    local procedure CalcWithholdingTaxAmount(Amount: Decimal; WithholdingTaxPercent: Decimal): Decimal
    begin
        exit(Round(Amount * WithholdingTaxPercent / 100));
    end;

    procedure ABSMin(Decimal1: Decimal; Decimal2: Decimal): Decimal
    begin
        if Abs(Decimal1) < Abs(Decimal2) then
            exit(Decimal1);

        exit(Decimal2);
    end;

    procedure PrintWHTSlips(var GLReg: Record "G/L Register"; ScheduleInJobQueue: Boolean)
    var
        GLEntry: Record "G/L Entry";
        WithholdingTaxEntry: Record "Withholding Tax Entry";
        WithholdingTaxEntry2: Record "Withholding Tax Entry";
        WithholdingSlipBuffer: Record "Withholding Tax Cert. Buffer";
        PurchSetup: Record "Purchases & Payables Setup";
        ReportSelection: Record "Report Selections";
        WithholdingRevenueTypes: Record "Withholding Tax Revenue Types";
        GeneralLedgerSetup: Record "General Ledger Setup";
        BatchPostingPrintMgt: Codeunit "Batch Posting Print Mgt.";
        NoSeries: Codeunit "No. Series";
        GLRegFilter: Text;
        StartTrans: Integer;
        EndTrans: Integer;
        x: Integer;
        PrintSlips: Integer;
        WHTSlipBuffer2: Code[20];
        WHTSlipDocument2: Code[20];
        VendorArray: array[1000] of Code[20];
        DocumentArray: array[1000] of Code[20];
        WHTSlipNo: Code[20];
        ActualVendorExist: Boolean;
    begin
        x := 0;
        GLRegFilter := GLReg.GetFilters();

        GLEntry.Reset();
        if GLReg."From Entry No." < 0 then
            GLEntry.SetRange("Entry No.", GLReg."To Entry No.", GLReg."From Entry No.")
        else
            GLEntry.SetRange("Entry No.", GLReg."From Entry No.", GLReg."To Entry No.");
        GLEntry.FindFirst();

        StartTrans := GLEntry."Transaction No.";
        GLEntry.FindLast();
        EndTrans := GLEntry."Transaction No.";

        WithholdingTaxEntry.Reset();
        WithholdingTaxEntry.SetCurrentKey("Bill-to/Pay-to No.", "Original Document No.", "Withholding Tax Revenue Type");
        WithholdingTaxEntry.SetRange("Entry No.", GLReg."From Withholding Tax Entry No.", GLReg."To Withholding Tax Entry No.");
        if not WithholdingTaxEntry.FindFirst() then
            exit;
        repeat
            if WithholdingTaxEntry."Transaction Type" = WithholdingTaxEntry."Transaction Type"::Sale then
                if WithholdingTaxEntry."Document Type" in [
                                                WithholdingTaxEntry."Document Type"::Invoice,
                                                WithholdingTaxEntry."Document Type"::Payment]
                then
                    exit;

            x := x + 1;

            if WithholdingTaxEntry."Actual Vendor No." <> '' then begin
                VendorArray[x] := WithholdingTaxEntry."Actual Vendor No.";
                ActualVendorExist := true;
            end else
                VendorArray[x] := WithholdingTaxEntry."Bill-to/Pay-to No.";

            DocumentArray[x] := WithholdingTaxEntry."Original Document No.";
        until WithholdingTaxEntry.Next() = 0;

        PurchSetup.Get();
        WithholdingSlipBuffer.DeleteAll();

        for PrintSlips := 1 to x do begin
            WithholdingSlipBuffer.Init();
            WithholdingSlipBuffer."Line No." := PrintSlips;
            WithholdingSlipBuffer."Vendor No." := VendorArray[PrintSlips];
            WithholdingSlipBuffer."Document No." := DocumentArray[PrintSlips];
            WithholdingSlipBuffer.Insert();
        end;

        x := 0;
        Clear(VendorArray);
        Clear(DocumentArray);

        WithholdingSlipBuffer.Reset();
        WithholdingSlipBuffer.SetCurrentKey("Vendor No.", "Document No.");
        WithholdingSlipBuffer.FindSet();
        repeat
            x := x + 1;
            VendorArray[x] := WithholdingSlipBuffer."Vendor No.";
            DocumentArray[x] := WithholdingSlipBuffer."Document No.";
        until WithholdingSlipBuffer.Next() = 0;

        for PrintSlips := 1 to x do begin
            if (VendorArray[PrintSlips] <> WHTSlipBuffer2) or
               (DocumentArray[PrintSlips] <> WHTSlipDocument2)
            then begin
                PurchSetup.TestField("Wthldg. Tax Certificate Nos.");
                WHTSlipNo := NoSeries.GetNextNo(PurchSetup."Wthldg. Tax Certificate Nos.", WithholdingTaxEntry."Posting Date");

                WithholdingTaxEntry.Reset();
                WithholdingTaxEntry.SetCurrentKey("Bill-to/Pay-to No.", "Original Document No.", "Withholding Tax Revenue Type");
                if ActualVendorExist then
                    WithholdingTaxEntry.SetRange("Actual Vendor No.", VendorArray[PrintSlips])
                else
                    WithholdingTaxEntry.SetRange("Bill-to/Pay-to No.", VendorArray[PrintSlips]);
                WithholdingTaxEntry.SetRange("Original Document No.", DocumentArray[PrintSlips]);
                if WithholdingTaxEntry.FindSet() then
                    repeat
                        WithholdingRevenueTypes.Reset();
                        WithholdingRevenueTypes.SetRange(Code, WithholdingTaxEntry."Withholding Tax Revenue Type");

                        WithholdingTaxEntry2.Reset();
                        WithholdingTaxEntry2 := WithholdingTaxEntry;

                        if WithholdingRevenueTypes.FindFirst() then begin
                            WithholdingTaxEntry2."Wthldg. Tax Certificate No." := WHTSlipNo;
                            WithholdingTaxEntry2.Modify();
                        end else
                            Error(MissingRevenueTypeErr, WithholdingTaxEntry."Withholding Tax Revenue Type");

                    until WithholdingTaxEntry.Next() = 0;

                WithholdingTaxEntry.Reset();
                WithholdingTaxEntry.SetCurrentKey("Bill-to/Pay-to No.", "Original Document No.", "Withholding Tax Revenue Type");
                if ActualVendorExist then
                    WithholdingTaxEntry.SetRange("Actual Vendor No.", VendorArray[PrintSlips])
                else
                    WithholdingTaxEntry.SetRange("Bill-to/Pay-to No.", VendorArray[PrintSlips]);
                WithholdingTaxEntry.SetRange("Original Document No.", DocumentArray[PrintSlips]);
                WithholdingTaxEntry.SetRange("Wthldg. Tax Certificate No.", WHTSlipNo);
                if WithholdingTaxEntry.FindSet() then
                    ReportSelection.Reset();

                ReportSelection.SetRange(Usage, ReportSelection.Usage::"Withholding Tax Certificate");
                GeneralLedgerSetup.Get();
                if ReportSelection.FindSet() then
                    repeat
                        if ScheduleInJobQueue then
                            BatchPostingPrintMgt.SchedulePrintJobQueueEntry(WithholdingTaxEntry, ReportSelection."Report ID", GeneralLedgerSetup."Report Output Type".AsInteger())
                        else
                            REPORT.Run(ReportSelection."Report ID", PurchSetup."WHT Print Dialog", false, WithholdingTaxEntry);
                    until ReportSelection.Next() = 0;
            end;

            WHTSlipBuffer2 := VendorArray[PrintSlips];
            WHTSlipDocument2 := DocumentArray[PrintSlips];
        end;
    end;

    procedure ApplyVendInvoiceWHT(var VendLedgerEntry: Record "Vendor Ledger Entry"; var GenJnlLine: Record "Gen. Journal Line") EntryNo: Integer
    var
        GLSetup: Record "General Ledger Setup";
        Vendor: Record Vendor;
        Currency: Option Vendor,Customer;
        RemainingAmt: Decimal;
        PmtDiscount: Decimal;
        NextEntry: Integer;
    begin
        GLSetup.Get();
        if GLSetup."Enable Withholding Tax" then
            if GenJnlLine."Bill-to/Pay-to No." = '' then begin
                if GenJnlLine."Account Type" = GenJnlLine."Account Type"::Vendor then
                    Vendor.Get(GenJnlLine."Account No.");
            end else
                Vendor.Get(GenJnlLine."Bill-to/Pay-to No.");

        ExitLoop := false;

        VendorLedgerEntries1.Reset();
        SetVendAppliesToFilter(VendorLedgerEntries1, GenJnlLine);
        VendorLedgerEntries1.SetFilter("Document Type", '<>%1', VendorLedgerEntries1."Document Type"::" ");
        if VendorLedgerEntries1.FindSet() then
            repeat
                VendorLedgerEntries1.CalcFields(
                  Amount, "Amount (LCY)", "Remaining Amount", "Remaining Amt. (LCY)",
                  "Original Amount", "Original Amt. (LCY)");

                if VendorLedgerEntries1."Rem. Amt for Withholding Tax" = 0 then
                    VendorLedgerEntries1."Rem. Amt for Withholding Tax" := VendorLedgerEntries1."Remaining Amount";

                RemainingAmt := RemainingAmt + VendorLedgerEntries1."Rem. Amt for Withholding Tax";
            until VendorLedgerEntries1.Next() = 0;

        TotAmt := Abs(GenJnlLine.Amount);

        VendorLedgerEntries.Reset();
        SetVendAppliesToFilter(VendorLedgerEntries, GenJnlLine);
        VendorLedgerEntries.SetRange("Document Type", VendorLedgerEntries."Document Type"::"Credit Memo");
        if VendorLedgerEntries.FindSet() then
            repeat
                VendorLedgerEntries.CalcFields(
                  Amount, "Amount (LCY)", "Remaining Amount", "Remaining Amt. (LCY)",
                  "Original Amount", "Original Amt. (LCY)");

                PmtDiscount := 0;

                if CheckPmtDisc(
                     GenJnlLine."Posting Date", VendorLedgerEntries."Pmt. Discount Date",
                     Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"),
                     Abs(VendorLedgerEntries."WHT Rem. Amt"),
                     Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"),
                     Abs(TotAmt))
                then
                    PmtDiscount := VendorLedgerEntries."Original Pmt. Disc. Possible";

                GenJnlLine.Validate(Amount, -Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax" - PmtDiscount));
                RemainingAmt -= VendorLedgerEntries."Rem. Amt for Withholding Tax";
                TotAmt += (VendorLedgerEntries."Rem. Amt for Withholding Tax" - PmtDiscount);

                GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::"Credit Memo";
                GenJnlLine."Applies-to Doc. No." := VendorLedgerEntries."Document No.";
                NextEntry :=
                  ProcessPayment(
                    GenJnlLine, VendLedgerEntry."Transaction No.", VendLedgerEntry."Entry No.", Currency::Vendor, false);

                if ExitLoop then
                    exit(NextEntry);
            until VendorLedgerEntries.Next() = 0;

        ExitLoop := false;
        VendorLedgerEntries.Reset();
        SetVendAppliesToFilter(VendorLedgerEntries, GenJnlLine);
        VendorLedgerEntries.SetFilter("Document Type", '<>%1&<>%2',
          VendorLedgerEntries."Document Type"::"Credit Memo", VendorLedgerEntries."Document Type"::" ");
        if VendorLedgerEntries.FindSet() then
            repeat
                VendorLedgerEntries.CalcFields(
                  Amount,
                  "Amount (LCY)",
                  "Remaining Amount",
                  "Remaining Amt. (LCY)",
                  "Original Amount",
                  "Original Amt. (LCY)");

                if VendorLedgerEntries."Remaining Amount" = 0 then
                    if CheckPmtDisc(
                         GenJnlLine."Posting Date",
                         VendorLedgerEntries."Pmt. Discount Date",
                         Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"),
                         Abs(VendorLedgerEntries."WHT Rem. Amt"),
                         Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"),
                         Abs(TotAmt))
                    then
                        TotAmt := TotAmt - VendorLedgerEntries."Original Pmt. Disc. Possible";

                if (Abs(RemainingAmt) < Abs(TotAmt)) or
                   (Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax") < Abs(TotAmt))
                then begin
                    if CheckPmtDisc(
                         GenJnlLine."Posting Date",
                         VendorLedgerEntries."Pmt. Discount Date",
                         Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"),
                         Abs(VendorLedgerEntries."WHT Rem. Amt"),
                         Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"),
                         Abs(TotAmt))
                    then begin
                        if (Abs(TotAmt) < Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax")) or (VendorLedgerEntries."Rem. Amt for Withholding Tax" = 0) then
                            GenJnlLine.Validate(Amount, TotAmt)
                        else
                            GenJnlLine.Validate(
                              Amount,
                              Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax" - VendorLedgerEntries."Original Pmt. Disc. Possible"));

                        TotAmt := TotAmt + VendorLedgerEntries."Rem. Amt for Withholding Tax";
                        RemainingAmt :=
                          RemainingAmt - VendorLedgerEntries."Rem. Amt for Withholding Tax" + VendorLedgerEntries."Original Pmt. Disc. Possible";
                    end else begin
                        GenJnlLine.Validate(Amount, Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"));
                        TotAmt := TotAmt + VendorLedgerEntries."Rem. Amt for Withholding Tax";
                        RemainingAmt := RemainingAmt - VendorLedgerEntries."Rem. Amt for Withholding Tax";
                    end;
                end else begin
                    if CheckPmtDisc(
                         GenJnlLine."Posting Date",
                         VendorLedgerEntries."Pmt. Discount Date",
                         Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"),
                         Abs(VendorLedgerEntries."WHT Rem. Amt"),
                         Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"),
                         Abs(TotAmt))
                    then
                        GenJnlLine.Validate(Amount, TotAmt + VendorLedgerEntries."Original Pmt. Disc. Possible")
                    else
                        GenJnlLine.Validate(Amount, TotAmt);

                    ExitLoop := true;
                end;

                if VendorLedgerEntries."Document Type" = VendorLedgerEntries."Document Type"::Invoice then
                    GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice;

                GenJnlLine."Applies-to Doc. No." := VendorLedgerEntries."Document No.";
                NextEntry :=
                  ProcessPayment(
                    GenJnlLine, VendLedgerEntry."Transaction No.", VendLedgerEntry."Entry No.", Currency::Vendor, false);

                if ExitLoop then
                    exit(NextEntry);
            until VendorLedgerEntries.Next() = 0;

        exit(NextEntry);
    end;

    local procedure SetVendAppliesToFilter(var VendLedgEntry: Record "Vendor Ledger Entry"; GenJnlLine: Record "Gen. Journal Line")
    begin
        if GenJnlLine."Applies-to ID" <> '' then
            VendLedgEntry.SetRange("Applies-to ID", GenJnlLine."Applies-to ID")
        else begin
            VendLedgEntry.SetRange("Document Type", GenJnlLine."Applies-to Doc. Type");
            VendLedgEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
        end;
    end;

    procedure ProcessPayment(var GenJnlLine: Record "Gen. Journal Line"; TransactionNo: Integer; EntryNo: Integer; Source: Option Vendor,Customer; AmountWithDisc: Boolean) PaymentNo: Integer
    var
        WithholdingTaxEntry: Record "Withholding Tax Entry";
        WithholdingTaxEntry2: Record "Withholding Tax Entry";
        WithholdingTaxEntry3: Record "Withholding Tax Entry";
        GLSetup: Record "General Ledger Setup";
        WithholdingTaxEntryTemp: Record "Withholding Tax Entry";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        VendLedgEntry1: Record "Vendor Ledger Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
        TempWithholdingTaxEntry: Record "Temp Withholding Tax Entry";
        GenJnlTemplate: Record "Gen. Journal Template";
        WithholdingTaxEntry4: Record "Withholding Tax Entry";
        Vendor: Record Vendor;
        NoSeries: Codeunit "No. Series";
        PaymentAmount: Decimal;
        AppldAmount: Decimal;
        ExpectedAmount: Decimal;
        PaymentAmount1: Decimal;
    begin
        GLSetup.Get();
        if GLSetup."Enable Withholding Tax" then
            if GenJnlLine."Bill-to/Pay-to No." = '' then
                Vendor.Get(GenJnlLine."Account No.")
            else
                Vendor.Get(GenJnlLine."Bill-to/Pay-to No.");

        case Source of
            Source::Vendor:
                begin
                    WithholdingTaxEntry4.Reset();
                    WithholdingTaxEntry4.SetCurrentKey("Document Type", "Document No.");
                    WithholdingTaxEntry4.SetRange("Document Type", VendorLedgerEntries."Document Type");
                    WithholdingTaxEntry4.SetFilter("Document No.", VendorLedgerEntries."Document No.");
                    if WithholdingTaxEntry4.FindFirst() then begin
                        if Abs(GenJnlLine.Amount) < Abs(VendorLedgerEntries.Amount) then
                            PaymentAmount1 := GenJnlLine.Amount
                        else
                            PaymentAmount1 := -VendorLedgerEntries.Amount;

                        if CheckPmtDisc(
                          GenJnlLine."Posting Date",
                          VendorLedgerEntries."Pmt. Discount Date", Abs(VendorLedgerEntries."Amount to Apply"),
                          Abs(VendorLedgerEntries."Remaining Amount"), Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"),
                          Abs(PaymentAmount1))
                        then
                            PaymentAmount1 := PaymentAmount1 - VendorLedgerEntries."Original Pmt. Disc. Possible"; //xxx
                    end else
                        if (VendorLedgerEntries."Document No." = '') and (GenJnlLine.Amount <> 0) then
                            PaymentAmount1 := GenJnlLine.Amount;
                end;
        end;

        WithholdingTaxEntry.Reset();
        WithholdingTaxEntry.SetCurrentKey("Transaction Type", "Document No.", "Document Type", "Bill-to/Pay-to No.");
        if GenJnlLine."Applies-to Doc. Type" = GenJnlLine."Applies-to Doc. Type"::Invoice then
            WithholdingTaxEntry.SetRange("Document Type", WithholdingTaxEntry."Document Type"::Invoice);
        if GenJnlLine."Applies-to Doc. Type" = GenJnlLine."Applies-to Doc. Type"::"Credit Memo" then
            WithholdingTaxEntry.SetRange("Document Type", WithholdingTaxEntry."Document Type"::"Credit Memo");
        case Source of
            Source::Vendor:
                WithholdingTaxEntry.SetRange("Transaction Type", WithholdingTaxEntry."Transaction Type"::Purchase);
            Source::Customer:
                WithholdingTaxEntry.SetRange("Transaction Type", WithholdingTaxEntry."Transaction Type"::Sale);
        end;

        WithholdingTaxEntry.SetRange(Closed, false);
        WithholdingTaxEntry.SetRange("Transaction No.", 0);
        if GenJnlLine."Applies-to Doc. No." <> '' then
            WithholdingTaxEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.")
        else
            WithholdingTaxEntry.SetRange("Bill-to/Pay-to No.", GenJnlLine."Account No.");
        if WithholdingTaxEntry.FindSet() then
            repeat
                WithholdingPostingSetup.Get(WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                if (WithholdingPostingSetup."Realized Withholding Tax Type" =
                    WithholdingPostingSetup."Realized Withholding Tax Type"::Payment)
                then begin
                    WithholdingTaxEntry3.Reset();
                    WithholdingTaxEntry3 := WithholdingTaxEntry;

                    case Source of
                        Source::Vendor:
                            begin
                                if GenJnlLine."Applies-to Doc. No." = '' then
                                    exit;
                                PurchCrMemoHeader.Reset();
                                PurchCrMemoHeader.SetRange("Applies-to Doc. No.", GenJnlLine."Applies-to Doc. No.");
                                PurchCrMemoHeader.SetRange("Applies-to Doc. Type", PurchCrMemoHeader."Applies-to Doc. Type"::Invoice);
                                if PurchCrMemoHeader.FindFirst() then begin
                                    TempRemAmt := 0;

                                    VendLedgEntry1.Reset();
                                    VendLedgEntry1.SetRange("Document No.", PurchCrMemoHeader."No.");
                                    VendLedgEntry1.SetRange("Document Type", VendLedgEntry1."Document Type"::"Credit Memo");
                                    if VendLedgEntry1.FindFirst() then
                                        VendLedgEntry1.CalcFields(Amount, "Remaining Amount");

                                    WithholdingTaxEntryTemp.Reset();
                                    WithholdingTaxEntryTemp.SetRange("Document No.", PurchCrMemoHeader."No.");
                                    WithholdingTaxEntryTemp.SetRange("Document Type", WithholdingTaxEntry."Document Type"::"Credit Memo");
                                    WithholdingTaxEntryTemp.SetRange("Transaction Type", WithholdingTaxEntry."Transaction Type"::Purchase);
                                    WithholdingTaxEntryTemp.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group");
                                    WithholdingTaxEntryTemp.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                                    if WithholdingTaxEntryTemp.FindFirst() then begin
                                        TempRemBase := WithholdingTaxEntryTemp."Unrealized Amount";
                                        TempRemAmt := WithholdingTaxEntryTemp."Unrealized Base";
                                    end;
                                end;

                                VendLedgEntry.Reset();
                                VendLedgEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
                                if GenJnlLine."Applies-to Doc. Type" = GenJnlLine."Applies-to Doc. Type"::Invoice then
                                    VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::Invoice)
                                else
                                    if GenJnlLine."Applies-to Doc. Type" = GenJnlLine."Applies-to Doc. Type"::"Credit Memo" then
                                        VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::"Credit Memo");
                                if VendLedgEntry.FindFirst() then
                                    VendLedgEntry.CalcFields(Amount, "Remaining Amount");

                                ExpectedAmount := -(VendLedgEntry.Amount + VendLedgEntry1.Amount);

                                if VendLedgEntry1."Amount (LCY)" = 0 then
                                    VendLedgEntry1."WHT Rem. Amt" := 0;

                                if (GenJnlLine."Posting Date" <= VendLedgEntry."Pmt. Discount Date") and
                                   (Abs(PaymentAmount1) >=
                                    (Abs(VendLedgEntry."WHT Rem. Amt" + VendLedgEntry1."WHT Rem. Amt") -
                                     Abs(VendLedgEntry."Original Pmt. Disc. Possible"))) and
                                   (not AmountWithDisc)
                                then begin
                                    if VendLedgEntry."Remaining Amount" = 0 then begin
                                        AppldAmount :=
                                          Round(
                                            (PaymentAmount1 *
                                             (WithholdingTaxEntry."Unrealized Base" + TempRemAmt)) /
                                            ExpectedAmount);
                                        WithholdingTaxEntry3."Remaining Unrealized Base" :=
                                          Round(
                                            WithholdingTaxEntry."Remaining Unrealized Base" -
                                            Round(
                                              (PaymentAmount1 *
                                               (WithholdingTaxEntry."Unrealized Base" + TempRemAmt)) /
                                              ExpectedAmount));
                                        WithholdingTaxEntry3."Remaining Unrealized Amount" :=
                                          Round(
                                            WithholdingTaxEntry."Remaining Unrealized Amount" -
                                            Round(
                                              (PaymentAmount1 *
                                               ((WithholdingTaxEntry."Unrealized Base"
                                                 * WithholdingTaxEntry."Withholding Tax %" / 100) + TempRemBase)) /
                                              ExpectedAmount));
                                    end else begin
                                        AppldAmount :=
                                          Round(
                                            (PaymentAmount1 *
                                             (WithholdingTaxEntry."Unrealized Base" + TempRemAmt)) /
                                            ExpectedAmount);
                                        WithholdingTaxEntry3."Remaining Unrealized Base" :=
                                          Round(
                                            WithholdingTaxEntry."Remaining Unrealized Base" -
                                            Round(
                                              (PaymentAmount1 *
                                               (WithholdingTaxEntry."Unrealized Base" + TempRemAmt)) /
                                              ExpectedAmount));
                                        WithholdingTaxEntry3."Remaining Unrealized Amount" :=
                                          Round(
                                            WithholdingTaxEntry."Remaining Unrealized Amount" -
                                            Round(
                                              (PaymentAmount1 *
                                               (WithholdingTaxEntry."Unrealized Amount" + TempRemBase)) /
                                              ExpectedAmount));
                                    end
                                end else begin
                                    AppldAmount :=
                                      Round(
                                        (PaymentAmount1 * (WithholdingTaxEntry."Unrealized Base" + TempRemAmt)) /
                                        ExpectedAmount);
                                    WithholdingTaxEntry3."Remaining Unrealized Base" :=
                                      Round(
                                        WithholdingTaxEntry."Remaining Unrealized Base" -
                                        Round(
                                          (PaymentAmount1 * (WithholdingTaxEntry."Unrealized Base" + TempRemAmt)) /
                                          ExpectedAmount));
                                    WithholdingTaxEntry3."Remaining Unrealized Amount" :=
                                      Round(
                                        WithholdingTaxEntry."Remaining Unrealized Amount" -
                                        Round(
                                          (PaymentAmount1 * (WithholdingTaxEntry."Unrealized Amount" + TempRemBase)) /
                                          ExpectedAmount));
                                end;

                                PaymentAmount := PaymentAmount + AppldAmount;
                            end;
                    end;

                    if (WithholdingTaxEntry."Remaining Unrealized Base" = 0) and (WithholdingTaxEntry."Remaining Unrealized Amount" = 0) then
                        WithholdingTaxEntry3.Closed := true;

                    if GenJnlLine."Currency Code" <> WithholdingTaxEntry."Currency Code" then
                        Error(CurrencyCodeSameErr);

                    if AppldAmount = 0 then
                        exit;

                    WithholdingTaxEntry2.Init();
                    WithholdingTaxEntry2."Posting Date" := GenJnlLine."Document Date";
                    WithholdingTaxEntry2."Entry No." := NextEntryNo();
                    WithholdingTaxEntry2."Document Date" := WithholdingTaxEntry."Document Date";
                    WithholdingTaxEntry2."Document Type" := GenJnlLine."Document Type";
                    WithholdingTaxEntry2."Document No." := WithholdingTaxEntry."Document No.";
                    WithholdingTaxEntry2."Gen. Bus. Posting Group" := WithholdingTaxEntry."Gen. Bus. Posting Group";
                    WithholdingTaxEntry2."Gen. Prod. Posting Group" := WithholdingTaxEntry."Gen. Prod. Posting Group";
                    WithholdingTaxEntry2."Bill-to/Pay-to No." := WithholdingTaxEntry."Bill-to/Pay-to No.";
                    WithholdingTaxEntry2."Wthldg. Tax Bus. Post. Group" := WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group";
                    WithholdingTaxEntry2."Wthldg. Tax Prod. Post. Group" := WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group";
                    WithholdingTaxEntry2."Withholding Tax Revenue Type" := WithholdingTaxEntry."Withholding Tax Revenue Type";
                    WithholdingTaxEntry2."Currency Code" := GenJnlLine."Currency Code";
                    WithholdingTaxEntry2."Applies-to Entry No." := WithholdingTaxEntry."Entry No.";
                    WithholdingTaxEntry2."User ID" := UserId;
                    WithholdingTaxEntry2."External Document No." := GenJnlLine."External Document No.";
                    WithholdingTaxEntry2."Actual Vendor No." := GenJnlLine."WHT Actual Vendor No.";
                    WithholdingTaxEntry2."Original Document No." := GenJnlLine."Document No.";
                    WithholdingTaxEntry2."Source Code" := GenJnlLine."Source Code";
                    WithholdingTaxEntry2."Transaction No." := TransactionNo;
                    WithholdingTaxEntry2."Unreal. Wthldg. Tax Entry No." := WithholdingTaxEntry."Entry No.";
                    WithholdingTaxEntry2."Withholding Tax %" := WithholdingTaxEntry."Withholding Tax %";

                    case Source of
                        Source::Vendor:
                            begin
                                WithholdingTaxEntry2.Base := Round(AppldAmount);
                                WithholdingTaxEntry2.Amount := Round(WithholdingTaxEntry2.Base * WithholdingTaxEntry2."Withholding Tax %" / 100);
                                WithholdingTaxEntry2."Payment Amount" := PaymentAmount1;
                                WithholdingTaxEntry2."Transaction Type" := WithholdingTaxEntry2."Transaction Type"::Purchase;
                                WithholdingPostingSetup.Get(WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");

                                if GenJnlLine."WHT Certificate Printed" then begin
                                    WithholdingTaxEntry2."Wthldg. Tax Report Line No" := GenJnlLine."Wthldg. Tax Report Line No.";
                                    TempWithholdingTaxEntry.SetRange("Document No.", WithholdingTaxEntry2."Document No.");
                                    if TempWithholdingTaxEntry.FindFirst() then
                                        WithholdingTaxEntry2."Wthldg. Tax Certificate No." := TempWithholdingTaxEntry."Wthldg. Tax Certificate No.";
                                end else begin
                                    if ((Source = Source::Vendor) and
                                        (WithholdingTaxEntry."Document Type" = WithholdingTaxEntry."Document Type"::Invoice)) or
                                       ((Source = Source::Customer) and
                                        (WithholdingTaxEntry."Document Type" = WithholdingTaxEntry."Document Type"::"Credit Memo"))
                                    then
                                        if (WithholdingReportLineNo = '') and
                                           (WithholdingTaxEntry2.Amount <> 0) and
                                           (WithholdingPostingSetup."Wthldg. Tax Rep Line No Series" <> '')
                                        then
                                            WithholdingReportLineNo := NoSeries.GetNextNo(WithholdingPostingSetup."Wthldg. Tax Rep Line No Series", WithholdingTaxEntry2."Posting Date");

                                    WithholdingTaxEntry2."Wthldg. Tax Report Line No" := WithholdingReportLineNo;
                                end;

                                TType := TType::Purchase;
                            end;
                    end;

                    if WithholdingTaxEntry2."Currency Code" <> '' then begin
                        CurrFactor := GenJnlLine."Currency Factor";
                        WithholdingTaxEntry2."Base (LCY)" :=
                          Round(
                            CurrExchRate.ExchangeAmtFCYToLCY(
                              GenJnlLine."Document Date",
                              WithholdingTaxEntry2."Currency Code",
                              WithholdingTaxEntry2.Base, CurrFactor));
                        WithholdingTaxEntry2."Amount (LCY)" :=
                          Round(
                            CurrExchRate.ExchangeAmtFCYToLCY(
                              GenJnlLine."Document Date",
                              WithholdingTaxEntry2."Currency Code",
                              WithholdingTaxEntry2.Amount, CurrFactor));
                    end else begin
                        WithholdingTaxEntry2."Amount (LCY)" := WithholdingTaxEntry2.Amount;
                        WithholdingTaxEntry2."Base (LCY)" := WithholdingTaxEntry2.Base;
                    end;

                    if WithholdingTaxEntry2."Currency Code" <> '' then begin
                        CurrFactor := GenJnlLine."Currency Factor";
                        WithholdingTaxEntry2."Base (LCY)" :=
                          Round(
                            CurrExchRate.ExchangeAmtFCYToLCY(
                              GenJnlLine."Document Date",
                              WithholdingTaxEntry2."Currency Code",
                              WithholdingTaxEntry2.Base, CurrFactor));
                        WithholdingTaxEntry2."Amount (LCY)" :=
                          Round(
                            CurrExchRate.ExchangeAmtFCYToLCY(
                              GenJnlLine."Document Date",
                              WithholdingTaxEntry2."Currency Code",
                              WithholdingTaxEntry2.Amount, CurrFactor));
                    end else begin
                        WithholdingTaxEntry2."Amount (LCY)" := WithholdingTaxEntry2.Amount;
                        WithholdingTaxEntry2."Base (LCY)" := WithholdingTaxEntry2.Base;
                    end;

                    if VendLedgEntry."Original Pmt. Disc. Possible" <> 0 then
                        if WithholdingTaxEntry2.Base <> WithholdingTaxEntry."Unrealized Base" then begin
                            if VendLedgEntry."Remaining Amount" = 0 then begin
                                WithholdingTaxEntry3."Rem Unrealized Amount (LCY)" := WithholdingTaxEntry2."Rem Unrealized Amount (LCY)";
                                WithholdingTaxEntry3."Rem Unrealized Base (LCY)" := WithholdingTaxEntry2."Rem Unrealized Base (LCY)";
                                WithholdingTaxEntry3."Remaining Unrealized Amount" := WithholdingTaxEntry2."Remaining Unrealized Amount";
                                WithholdingTaxEntry3."Remaining Unrealized Base" := WithholdingTaxEntry2."Remaining Unrealized Base";

                                WithholdingTaxEntry4.Reset();
                                WithholdingTaxEntry4.SetCurrentKey("Applies-to Entry No.");
                                WithholdingTaxEntry4.SetFilter("Applies-to Entry No.", '=%1', WithholdingTaxEntry."Entry No.");
                                WithholdingTaxEntry4.CalcSums(WithholdingTaxEntry4.Base);
                                WithholdingTaxEntry3."Pymt. Disc. Diff. Base" := WithholdingTaxEntry."Unrealized Base" - (WithholdingTaxEntry4.Base + WithholdingTaxEntry2.Base);
                                WithholdingTaxEntry3."Pymt. Disc. Diff. Amount" := Round((WithholdingTaxEntry3."Pymt. Disc. Diff. Base" * WithholdingTaxEntry3."Withholding Tax %") / 100);
                                WithholdingTaxEntry3."Withholding Tax Difference" :=
                                  WithholdingTaxEntry3."Withholding Tax Difference" + Abs(Abs(WithholdingTaxEntry3."Pymt. Disc. Diff. Amount") -
                                  Abs(WithholdingTaxEntry."Unrealized Amount" - (WithholdingTaxEntry4.Amount + WithholdingTaxEntry2.Amount)));
                            end;
                        end else begin
                            WithholdingTaxEntry3."Rem Unrealized Amount (LCY)" :=
                              WithholdingTaxEntry."Rem Unrealized Amount (LCY)" - WithholdingTaxEntry2."Amount (LCY)";
                            WithholdingTaxEntry3."Rem Unrealized Base (LCY)" :=
                              WithholdingTaxEntry."Rem Unrealized Base (LCY)" - WithholdingTaxEntry2."Base (LCY)";
                        end;

                    WithholdingTaxEntry2.Insert();
                    WithholdingTaxEntry3.Modify();

                    AdjustWithholdingTaxEntryWithTaxDifference(WithholdingTaxEntry, WithholdingTaxEntry2, WithholdingTaxEntry3);

                    if Source = Source::Vendor then
                        GenJnlTemplate.SetRange(Type, GenJnlTemplate.Type::Purchases);

                    if GenJnlTemplate.FindFirst() then
                        if GenJnlLine."Journal Template Name" <> GenJnlTemplate.Name then
                            if WithholdingTaxEntry2.Amount <> 0 then
                                InsertWithholdingTaxPostingBuffer(WithholdingTaxEntry2, GenJnlLine, 0, AmountWithDisc);
                end;
            until (WithholdingTaxEntry.Next() = 0);

        if (WithholdingPostingSetup."Realized Withholding Tax Type" =
            WithholdingPostingSetup."Realized Withholding Tax Type"::Payment)
        then
            exit(WithholdingTaxEntry2."Entry No." + 1);
    end;

    local procedure AdjustWithholdingTaxEntryWithTaxDifference(WithholdingTaxEntry: Record "Withholding Tax Entry"; var WithholdingTaxEntry2: Record "Withholding Tax Entry"; var WithholdingTaxEntry3: Record "Withholding Tax Entry")
    var
        AmountDifference: Decimal;
    begin
        WithholdingTaxEntry3.Reset();
        WithholdingTaxEntry3.SetCurrentKey("Applies-to Entry No.");
        WithholdingTaxEntry3.SetRange("Applies-to Entry No.", WithholdingTaxEntry."Entry No.");
        WithholdingTaxEntry3.CalcSums(Amount, "Amount (LCY)");
        AmountDifference := Abs(WithholdingTaxEntry3.Amount) - Abs(WithholdingTaxEntry."Unrealized Amount");

        if (Abs(AmountDifference) < 0.1) and
           (Abs(AmountDifference) > 0)
        then begin
            WithholdingTaxEntry2."Withholding Tax Difference" := WithholdingTaxEntry2."Withholding Tax Difference" + Abs(WithholdingTaxEntry."Unrealized Amount" - WithholdingTaxEntry3.Amount);
            WithholdingTaxEntry2.Modify();
        end else
            if WithholdingTaxEntry2."Withholding Tax Difference" = 0 then
                if (Abs(Abs(WithholdingTaxEntry3."Amount (LCY)") - Abs(WithholdingTaxEntry."Unrealized Amount (LCY)")) < 0.1) and
                   (Abs(Abs(WithholdingTaxEntry3."Amount (LCY)") - Abs(WithholdingTaxEntry."Unrealized Amount (LCY)")) > 0)
                then begin
                    WithholdingTaxEntry2."Amount (LCY)" :=
                      WithholdingTaxEntry2."Amount (LCY)" + (WithholdingTaxEntry."Unrealized Amount (LCY)" - WithholdingTaxEntry3."Amount (LCY)");
                    WithholdingTaxEntry2.Modify();
                end;
    end;

    procedure InsertWithholdingTaxPostingBuffer(var WithholdingTaxEntryGL: Record "Withholding Tax Entry"; var GenJnlLine: Record "Gen. Journal Line"; Source: Option Payment,Refund; Oldest: Boolean)
    var
        GLSetup: Record "General Ledger Setup";
        GenJnlLine2: Record "Gen. Journal Line";
        GenJnlLine3: Record "Gen. Journal Line";
        HighestLineNo: Integer;
    begin
        WithholdingPostingSetup.Get(WithholdingTaxEntryGL."Wthldg. Tax Bus. Post. Group", WithholdingTaxEntryGL."Wthldg. Tax Prod. Post. Group");

        GLSetup.Get();

        GenJnlLine2 := GenJnlLine;
        GenJnlLine2.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
        GenJnlLine2.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
        if GenJnlLine2.FindLast() then
            HighestLineNo := GenJnlLine2."Line No." + 10000
        else
            HighestLineNo := 0;

        GenJnlLine3.Reset();
        GenJnlLine3 := GenJnlLine;
        GenJnlLine3.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
        GenJnlLine3.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
        GenJnlLine3."Line No." := HighestLineNo;
        if GenJnlLine3.Next() = 0 then
            GenJnlLine3."Line No." := HighestLineNo + 10000
        else begin
            while GenJnlLine3."Line No." = HighestLineNo + 1 do begin
                HighestLineNo := GenJnlLine3."Line No.";
                if GenJnlLine3.Next() = 0 then
                    GenJnlLine3."Line No." := HighestLineNo + 20000;
            end;
            GenJnlLine3."Line No." := HighestLineNo + 10000;
        end;

        GenJnlLine3.Init();
        GenJnlLine3.Validate("Posting Date", GenJnlLine."Posting Date");
        GenJnlLine3."Document Type" := GenJnlLine."Document Type";
        GenJnlLine3."Account Type" := GenJnlLine3."Account Type"::"G/L Account";
        GenJnlLine3."System-Created Entry" := true;
        GenJnlLine3."Is Withholding Tax" := true;
        if GenJnlLine."Document Type" = GenJnlLine."Document Type"::Refund then begin
            if TType = TType::Purchase then
                GenJnlLine3.Validate("Account No.", WithholdingPostingSetup."Purch. Wthldg. Tax Adj. Acc No");

            if TType = TType::Sale then
                GenJnlLine3.Validate("Account No.", WithholdingPostingSetup."Sales Wthldg. Tax Adj. Acc No");
        end else begin
            if TType = TType::Purchase then
                GenJnlLine3.Validate("Account No.", WithholdingPostingSetup."Payable Wthldg. Tax Acc. Code");

            if TType = TType::Sale then begin
                WithholdingPostingSetup.TestField("Prepaid Wthldg. Tax Acc. Code");
                GenJnlLine3.Validate("Account No.", WithholdingPostingSetup."Prepaid Wthldg. Tax Acc. Code");
            end;
        end;

        GenJnlLine3.Validate("Currency Code", WithholdingTaxEntryGL."Currency Code");

        if GLSetup."Round Amount Wthldg. Tax Calc" then begin
            GenJnlLine3.Validate(Amount, RoundWithholdingTaxAmount(-WithholdingTaxEntryGL.Amount));
            GenJnlLine3."Amount (LCY)" := RoundWithholdingTaxAmount(-WithholdingTaxEntryGL."Amount (LCY)");
        end else begin
            GenJnlLine3.Validate(Amount, -WithholdingTaxEntryGL.Amount);
            GenJnlLine3."Amount (LCY)" := -WithholdingTaxEntryGL."Amount (LCY)";
        end;

        if (GenJnlLine."Gen. Posting Type" = GenJnlLine."Gen. Posting Type"::" ") and
           (GenJnlLine."Document Type" = GenJnlLine."Document Type"::Refund)
        then
            GenJnlLine3."Gen. Posting Type" := GenJnlLine."Gen. Posting Type";

        GenJnlLine3."System-Created Entry" := true; // Payment Method Code
        GLSetup.Get();

        if Oldest then
            if TType = TType::Purchase then begin
                case WithholdingPostingSetup."Bal. Payable Account Type" of
                    WithholdingPostingSetup."Bal. Payable Account Type"::"Bank Account":
                        GenJnlLine3."Bal. Account Type" := GenJnlLine3."Account Type"::"Bank Account";
                    WithholdingPostingSetup."Bal. Payable Account Type"::"G/L Account":
                        GenJnlLine3."Bal. Account Type" := GenJnlLine3."Account Type"::"G/L Account";
                end;
                WithholdingPostingSetup.TestField("Bal. Payable Account No.");
                GenJnlLine3.Validate("Bal. Account No.", WithholdingPostingSetup."Bal. Payable Account No.");
            end;

        GenJnlLine3."Source Code" := GenJnlLine."Source Code";
        GenJnlLine3."Reason Code" := GenJnlLine."Reason Code";
        GenJnlLine3."Shortcut Dimension 1 Code" := GenJnlLine."Shortcut Dimension 1 Code";
        GenJnlLine3."Shortcut Dimension 2 Code" := GenJnlLine."Shortcut Dimension 2 Code";
        GenJnlLine3."Allow Zero-Amount Posting" := true;
        GenJnlLine3."Wthldg. Tax Bus. Post. Group" := WithholdingTaxEntryGL."Wthldg. Tax Bus. Post. Group";
        GenJnlLine3."Wthldg. Tax Prod. Post. Group" := WithholdingTaxEntryGL."Wthldg. Tax Prod. Post. Group";
        GenJnlLine3."Document Type" := GenJnlLine."Document Type";
        GenJnlLine3."Document No." := GenJnlLine."Document No.";
        GenJnlLine3."External Document No." := GenJnlLine."External Document No.";

        if Source = Source::Refund then
            GenJnlLine3."Gen. Posting Type" := GenJnlLine3."Gen. Posting Type"::" ";

        GenJnlLine3.Insert();
    end;

    internal procedure RoundWithholdingTaxAmount(Amount: Decimal): Decimal
    begin
        exit(Round(Amount, 1, '<'));
    end;

    procedure ProcessManualReceipt(var GenJnlLine: Record "Gen. Journal Line"; TransactionNo: Integer; EntryNo: Integer; Source: Option Vendor,Customer) PaymentNo: Integer
    var
        WithholdingTaxEntry: Record "Withholding Tax Entry";
        WithholdingTaxEntry2: Record "Withholding Tax Entry";
        WithholdingTaxEntry3: Record "Withholding Tax Entry";
        WithholdingTaxEntryTemp: Record "Withholding Tax Entry";
        PaymentAmount: Decimal;
        PaymentAmountLCY: Decimal;
        AppldAmount: Decimal;
        PaymentAmount1: Decimal;
        WHTAmount: Decimal;
    begin
        PaymentAmount := GenJnlLine.Amount;
        PaymentAmount1 := GenJnlLine.Amount;
        PaymentAmountLCY := GenJnlLine."Amount (LCY)";
        WithholdingTaxEntry.Reset();
        WithholdingTaxEntry.SetCurrentKey("Transaction Type", "Document No.", "Document Type", "Bill-to/Pay-to No.");

        case Source of
            Source::Vendor:
                WithholdingTaxEntry.SetRange("Transaction Type", WithholdingTaxEntry."Transaction Type"::Purchase);
        end;

        if GenJnlLine."Applies-to Doc. No." <> '' then
            WithholdingTaxEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.")
        else
            WithholdingTaxEntry.SetRange("Bill-to/Pay-to No.", GenJnlLine."Account No.");

        if GenJnlLine."Applies-to Doc. Type" = GenJnlLine."Applies-to Doc. Type"::Invoice then
            WithholdingTaxEntry.SetRange("Document Type", WithholdingTaxEntry."Document Type"::Invoice)
        else
            if GenJnlLine."Applies-to Doc. Type" = GenJnlLine."Applies-to Doc. Type"::"Credit Memo" then
                WithholdingTaxEntry.SetRange("Document Type", WithholdingTaxEntry."Document Type"::"Credit Memo");

        if WithholdingTaxEntry.FindSet() then
            repeat
                WithholdingTaxEntryTemp.Reset();
                WithholdingTaxEntryTemp := WithholdingTaxEntry;

                case Source of
                    Source::Vendor:
                        begin
                            if GenJnlLine."Applies-to Doc. No." = '' then
                                exit;

                            WithholdingTaxEntry3.Reset();
                            WHTAmount := 0;
                            WithholdingTaxEntry3.Copy(WithholdingTaxEntry);
                            if WithholdingTaxEntry3.FindSet() then
                                repeat
                                    WHTAmount := WHTAmount + WithholdingTaxEntry3."Unrealized Amount";
                                until WithholdingTaxEntry3.Next() = 0;

                            AppldAmount := -Round(GenJnlLine.Amount * WithholdingTaxEntry."Unrealized Amount" / WHTAmount);

                            if AppldAmount = 0 then
                                AppliedBase := WithholdingTaxEntry."Remaining Unrealized Base"
                            else
                                AppliedBase := Round(AppldAmount * 100 / WithholdingTaxEntry."Withholding Tax %");

                            if WithholdingTaxEntry."Withholding Tax %" <> 0 then
                                WithholdingTaxEntryTemp."Remaining Unrealized Base" :=
                                  Round(WithholdingTaxEntry."Remaining Unrealized Base" - Round(AppldAmount * 100 / WithholdingTaxEntry."Withholding Tax %"))
                            else
                                WithholdingTaxEntryTemp."Remaining Unrealized Base" := 0;

                            WithholdingTaxEntryTemp."Remaining Unrealized Amount" :=
                              Round(
                                WithholdingTaxEntry."Remaining Unrealized Amount" -
                                Round(AppldAmount));
                            PaymentAmount := PaymentAmount + AppldAmount;
                            TType := TType::Purchase;
                        end;
                end;

                if GenJnlLine."Currency Code" <> WithholdingTaxEntry."Currency Code" then
                    Error(CurrencyCodeSameErr);

                WithholdingTaxEntry2.Init();
                WithholdingTaxEntry2."Posting Date" := GenJnlLine."Document Date";
                WithholdingTaxEntry2."Entry No." := NextEntryNo();
                WithholdingTaxEntry2."Document Date" := WithholdingTaxEntry."Document Date";
                WithholdingTaxEntry2."Document Type" := GenJnlLine."Document Type";
                WithholdingTaxEntry2."Document No." := WithholdingTaxEntry."Document No.";
                WithholdingTaxEntry2."Gen. Bus. Posting Group" := WithholdingTaxEntry."Gen. Bus. Posting Group";
                WithholdingTaxEntry2."Gen. Prod. Posting Group" := WithholdingTaxEntry."Gen. Prod. Posting Group";
                WithholdingTaxEntry2."Bill-to/Pay-to No." := WithholdingTaxEntry."Bill-to/Pay-to No.";
                WithholdingTaxEntry2."Wthldg. Tax Bus. Post. Group" := WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group";
                WithholdingTaxEntry2."Wthldg. Tax Prod. Post. Group" := WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group";
                WithholdingTaxEntry2."Withholding Tax Revenue Type" := WithholdingTaxEntry."Withholding Tax Revenue Type";
                WithholdingTaxEntry2."Currency Code" := GenJnlLine."Currency Code";
                WithholdingTaxEntry2."Applies-to Entry No." := WithholdingTaxEntry."Entry No.";
                WithholdingTaxEntry2."User ID" := UserId;
                WithholdingTaxEntry2."External Document No." := GenJnlLine."External Document No.";
                WithholdingTaxEntry2."Original Document No." := GenJnlLine."Document No.";
                WithholdingTaxEntry2."Source Code" := GenJnlLine."Source Code";
                WithholdingTaxEntry2."Transaction No." := TransactionNo;

                if TType = TType::Sale then
                    WithholdingTaxEntry2."Transaction Type" := WithholdingTaxEntry2."Transaction Type"::Sale
                else
                    WithholdingTaxEntry2."Transaction Type" := WithholdingTaxEntry2."Transaction Type"::Purchase;

                WithholdingTaxEntry2."Withholding Tax %" := WithholdingTaxEntry."Withholding Tax %";
                WithholdingTaxEntry2."Unreal. Wthldg. Tax Entry No." := WithholdingTaxEntry."Entry No.";
                WithholdingTaxEntry2.Base := Round(AppliedBase);
                WithholdingTaxEntry2.Amount := Round(AppldAmount);

                if WithholdingTaxEntry2."Currency Code" <> '' then begin
                    CurrFactor :=
                      CurrExchRate.ExchangeRate(WithholdingTaxEntry2."Posting Date", WithholdingTaxEntry2."Currency Code");
                    WithholdingTaxEntry2."Base (LCY)" :=
                      Round(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                          GenJnlLine."Document Date",
                          WithholdingTaxEntry2."Currency Code",
                          WithholdingTaxEntry2.Base, CurrFactor));
                    WithholdingTaxEntry2."Amount (LCY)" := Round(WithholdingTaxEntry2."Base (LCY)");
                end else begin
                    WithholdingTaxEntry2."Amount (LCY)" := WithholdingTaxEntry2.Amount;
                    WithholdingTaxEntry2."Base (LCY)" := WithholdingTaxEntry2.Base;
                end;

                WithholdingTaxEntry2.Insert();
                WithholdingTaxEntryTemp."Rem Unrealized Amount (LCY)" :=
                  WithholdingTaxEntry."Rem Unrealized Amount (LCY)" - WithholdingTaxEntry2."Amount (LCY)";
                WithholdingTaxEntryTemp."Rem Unrealized Base (LCY)" :=
                  WithholdingTaxEntry."Rem Unrealized Base (LCY)" - WithholdingTaxEntry2."Base (LCY)";
                WithholdingTaxEntryTemp.Modify();

                if WithholdingTaxEntry2.Amount <> 0 then
                    InsertWithholdingTaxPostingBuffer(WithholdingTaxEntry2, GenJnlLine, 0, false);

            until (WithholdingTaxEntry.Next() = 0);

        exit(WithholdingTaxEntry2."Entry No." + 1);
    end;

    procedure ApplyVendInvoiceWHTPosted(var VendLedgerEntry: Record "Vendor Ledger Entry"; var GenJnlLine: Record "Gen. Journal Line"; TransNo: Integer) EntryNo: Integer
    var
        Currency: Option Vendor,Customer;
        RemainingAmt: Decimal;
        NextEntry: Integer;
    begin
        VendorLedgerEntries.Reset();
        if GenJnlLine."Applies-to Doc. No." = '' then begin
            VendorLedgerEntries1.SetRange("Applies-to ID", GenJnlLine."Document No.");
            VendorLedgerEntries1.SetRange(Open, true);
            if VendorLedgerEntries1.FindSet() then
                repeat
                    VendorLedgerEntries1.CalcFields(
                      Amount,
                      "Amount (LCY)",
                      "Remaining Amount",
                      "Remaining Amt. (LCY)",
                      "Original Amount",
                      "Original Amt. (LCY)");

                    if VendorLedgerEntries1."Rem. Amt for Withholding Tax" = 0 then
                        VendorLedgerEntries1."Rem. Amt for Withholding Tax" := VendorLedgerEntries1."Remaining Amt. (LCY)";

                    RemainingAmt := RemainingAmt + VendorLedgerEntries1."Rem. Amt for Withholding Tax";

                    if VendorLedgerEntries1."Document Type" = VendorLedgerEntries1."Document Type"::"Credit Memo" then
                        RemainingAmt := RemainingAmt + VendorLedgerEntries1."Rem. Amt for Withholding Tax";
                until VendorLedgerEntries1.Next() = 0;

            TotAmt := Abs(GenJnlLine.Amount);

            if GenJnlLine."Applies-to ID" <> '' then
                VendorLedgerEntries.SetRange("Applies-to ID", GenJnlLine."Applies-to ID")
            else
                VendorLedgerEntries.SetRange("Applies-to ID", GenJnlLine."Document No.");

            VendorLedgerEntries.SetRange("Document Type", VendorLedgerEntries."Document Type"::"Credit Memo");

            if VendorLedgerEntries.FindSet() then
                repeat
                    VendorLedgerEntries.CalcFields(
                      Amount,
                      "Amount (LCY)",
                      "Remaining Amount",
                      "Remaining Amt. (LCY)",
                      "Original Amount",
                      "Original Amt. (LCY)");

                    if (GenJnlLine."Posting Date" <= VendorLedgerEntries."Pmt. Discount Date") and
                       (Abs(TotAmt) >= (Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax") -
                                        Abs(VendorLedgerEntries."Original Pmt. Disc. Possible")))
                    then
                        TotAmt := TotAmt - VendorLedgerEntries."Original Pmt. Disc. Possible";

                    if (Abs(RemainingAmt) < Abs(TotAmt)) or
                       (Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax") < Abs(TotAmt))
                    then begin
                        if (GenJnlLine."Posting Date" <= VendorLedgerEntries."Pmt. Discount Date") and
                           (Abs(TotAmt) >= (Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax") -
                                            Abs(VendorLedgerEntries."Original Pmt. Disc. Possible")))
                        then begin
                            GenJnlLine.Validate(
                              Amount,
                              -Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax" +
                                VendorLedgerEntries."Original Pmt. Disc. Possible"));

                            if VendorLedgerEntries."Document Type" <> VendorLedgerEntries."Document Type"::"Credit Memo" then
                                TotAmt := TotAmt - VendorLedgerEntries."Rem. Amt for Withholding Tax";

                            RemainingAmt :=
                              RemainingAmt - VendorLedgerEntries."Rem. Amt for Withholding Tax" + VendorLedgerEntries."Original Pmt. Disc. Possible";
                        end else begin
                            GenJnlLine.Validate(Amount, -Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"));

                            if VendorLedgerEntries."Document Type" <> VendorLedgerEntries."Document Type"::"Credit Memo" then
                                TotAmt := TotAmt - VendorLedgerEntries."Rem. Amt for Withholding Tax";

                            RemainingAmt := RemainingAmt - VendorLedgerEntries."Rem. Amt for Withholding Tax";
                        end;
                    end else begin
                        if (GenJnlLine."Posting Date" <= VendorLedgerEntries."Pmt. Discount Date") and
                           (Abs(TotAmt) >= (Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax") -
                                            Abs(VendorLedgerEntries."Original Pmt. Disc. Possible")))
                        then
                            GenJnlLine.Validate(Amount, TotAmt + VendorLedgerEntries."Original Pmt. Disc. Possible")
                        else
                            GenJnlLine.Validate(Amount, TotAmt);

                        ExitLoop := true;
                    end;

                    if VendorLedgerEntries."Document Type" = VendorLedgerEntries."Document Type"::Invoice then
                        GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice
                    else begin
                        if VendorLedgerEntries."Document Type" = VendorLedgerEntries."Document Type"::"Credit Memo" then
                            GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::"Credit Memo";

                        RemainingAmt := RemainingAmt - VendorLedgerEntries."Rem. Amt for Withholding Tax";
                        TotAmt := TotAmt + VendorLedgerEntries."Rem. Amt for Withholding Tax";
                        ExitLoop := false;
                    end;

                    GenJnlLine."Applies-to Doc. No." := VendorLedgerEntries."Document No.";
                    NextEntry :=
                      ProcessPaymentPosted(
                        GenJnlLine, TransNo, VendLedgerEntry."Entry No.", Currency::Vendor);

                    if ExitLoop then
                        exit(NextEntry);
                until VendorLedgerEntries.Next() = 0;

            ExitLoop := false;
            VendorLedgerEntries.Reset();
            if GenJnlLine."Applies-to ID" <> '' then
                VendorLedgerEntries.SetRange("Applies-to ID", GenJnlLine."Applies-to ID")
            else
                VendorLedgerEntries.SetRange("Applies-to ID", GenJnlLine."Document No.");

            VendorLedgerEntries.SetFilter("Document Type", '<>%1', VendorLedgerEntries."Document Type"::"Credit Memo");
            if VendorLedgerEntries.FindSet() then begin
                repeat
                    VendorLedgerEntries.CalcFields(
                      Amount, "Amount (LCY)",
                      "Remaining Amount",
                      "Remaining Amt. (LCY)",
                      "Original Amount",
                      "Original Amt. (LCY)");

                    if (GenJnlLine."Posting Date" <= VendorLedgerEntries."Pmt. Discount Date") and
                       (Abs(TotAmt) >= (Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax") -
                                        Abs(VendorLedgerEntries."Original Pmt. Disc. Possible")))
                    then
                        TotAmt := TotAmt - VendorLedgerEntries."Original Pmt. Disc. Possible";

                    if (Abs(RemainingAmt) < Abs(TotAmt)) or
                       (Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax") < Abs(TotAmt))
                    then begin
                        if (GenJnlLine."Posting Date" <= VendorLedgerEntries."Pmt. Discount Date") and
                           (Abs(TotAmt) >= (Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax") -
                                            Abs(VendorLedgerEntries."Original Pmt. Disc. Possible")))
                        then begin
                            GenJnlLine.Validate(
                              Amount,
                              Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax" -
                                VendorLedgerEntries."Original Pmt. Disc. Possible"));

                            if VendorLedgerEntries."Document Type" <> VendorLedgerEntries."Document Type"::"Credit Memo" then
                                TotAmt := TotAmt + VendorLedgerEntries."Rem. Amt for Withholding Tax";

                            RemainingAmt :=
                              RemainingAmt -
                              VendorLedgerEntries."Rem. Amt for Withholding Tax" +
                              VendorLedgerEntries."Original Pmt. Disc. Possible";
                        end else begin
                            GenJnlLine.Validate(Amount, Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"));

                            if VendorLedgerEntries."Document Type" <>
                               VendorLedgerEntries."Document Type"::"Credit Memo"
                            then
                                TotAmt := TotAmt + VendorLedgerEntries."Rem. Amt for Withholding Tax";

                            RemainingAmt := RemainingAmt - VendorLedgerEntries."Rem. Amt for Withholding Tax";
                        end;
                    end else begin
                        if (GenJnlLine."Posting Date" <= VendorLedgerEntries."Pmt. Discount Date") and
                           (Abs(TotAmt) >= (Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax") -
                                            Abs(VendorLedgerEntries."Original Pmt. Disc. Possible")))
                        then
                            GenJnlLine.Validate(Amount, TotAmt + VendorLedgerEntries."Original Pmt. Disc. Possible")
                        else
                            GenJnlLine.Validate(Amount, TotAmt);

                        ExitLoop := true;
                    end;

                    if VendorLedgerEntries."Document Type" = VendorLedgerEntries."Document Type"::Invoice then
                        GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice
                    else begin
                        if VendorLedgerEntries."Document Type" = VendorLedgerEntries."Document Type"::"Credit Memo" then
                            GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::"Credit Memo";

                        RemainingAmt := RemainingAmt + VendorLedgerEntries."Rem. Amt for Withholding Tax";
                        TotAmt := TotAmt + VendorLedgerEntries."Rem. Amt for Withholding Tax";
                        ExitLoop := false;
                    end;

                    GenJnlLine."Applies-to Doc. No." := VendorLedgerEntries."Document No.";
                    NextEntry :=
                      ProcessPaymentPosted(
                        GenJnlLine, TransNo, VendLedgerEntry."Entry No.", Currency::Vendor);

                    if ExitLoop then
                        exit(NextEntry);
                until VendorLedgerEntries.Next() = 0;

                exit(NextEntry);
            end;

            exit(
              ProcessPaymentPosted(
                GenJnlLine, TransNo, VendLedgerEntry."Entry No.", Currency::Vendor));
        end;

        exit(
          ProcessPaymentPosted(
            GenJnlLine, TransNo, VendLedgerEntry."Entry No.", Currency::Vendor));
    end;

    procedure ProcessPaymentPosted(var GenJnlLine: Record "Gen. Journal Line"; TransactionNo: Integer; EntryNo: Integer; Source: Option Vendor,Customer) PaymentNo: Integer
    var
        WithholdingTaxEntry: Record "Withholding Tax Entry";
        WithholdingTaxEntry2: Record "Withholding Tax Entry";
        WithholdingTaxEntry3: Record "Withholding Tax Entry";
        WithholdingTaxEntryTemp: Record "Withholding Tax Entry";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        VendLedgEntry1: Record "Vendor Ledger Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
        TempWithholdingTaxEntry: Record "Temp Withholding Tax Entry";
        GLSetup: Record "General Ledger Setup";
        Vendor: Record Vendor;
        NoSeries: Codeunit "No. Series";
        PaymentAmount: Decimal;
        PaymentAmountLCY: Decimal;
        AppldAmount: Decimal;
        ExpectedAmount: Decimal;
        PaymentAmount1: Decimal;
    begin
        GLSetup.Get();
        if GLSetup."Enable Withholding Tax" then
            if GenJnlLine."Bill-to/Pay-to No." = '' then
                Vendor.Get(GenJnlLine."Account No.")
            else
                Vendor.Get(GenJnlLine."Bill-to/Pay-to No.");

        PaymentAmount := GenJnlLine.Amount;
        PaymentAmount1 := GenJnlLine.Amount;
        PaymentAmountLCY := GenJnlLine."Amount (LCY)";

        WithholdingTaxEntry.Reset();
        WithholdingTaxEntry.SetCurrentKey("Transaction Type", "Document No.", "Document Type", "Bill-to/Pay-to No.");
        if GenJnlLine."Applies-to Doc. Type" = GenJnlLine."Applies-to Doc. Type"::Invoice then
            WithholdingTaxEntry.SetRange("Document Type", WithholdingTaxEntry."Document Type"::Invoice);

        if GenJnlLine."Applies-to Doc. Type" = GenJnlLine."Applies-to Doc. Type"::"Credit Memo" then
            WithholdingTaxEntry.SetRange("Document Type", WithholdingTaxEntry."Document Type"::"Credit Memo");

        case Source of
            Source::Vendor:
                WithholdingTaxEntry.SetRange("Transaction Type", WithholdingTaxEntry."Transaction Type"::Purchase);
        end;

        WithholdingTaxEntry.SetRange(Closed, false);
        if GenJnlLine."Applies-to Doc. No." <> '' then begin
            WithholdingTaxEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
            WithholdingTaxEntry.SetRange("Document Type", GenJnlLine."Applies-to Doc. Type");
        end else
            WithholdingTaxEntry.SetRange("Bill-to/Pay-to No.", GenJnlLine."Account No.");

        if WithholdingTaxEntry.FindSet() then
            repeat
                WithholdingPostingSetup.Get(WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                if (WithholdingPostingSetup."Realized Withholding Tax Type" =
                    WithholdingPostingSetup."Realized Withholding Tax Type"::Payment)
                then begin
                    WithholdingTaxEntry3.Reset();
                    WithholdingTaxEntry3 := WithholdingTaxEntry;

                    case Source of
                        Source::Vendor:
                            begin
                                if GenJnlLine."Applies-to Doc. No." = '' then
                                    exit;

                                PurchCrMemoHeader.Reset();
                                PurchCrMemoHeader.SetRange("Applies-to Doc. No.", GenJnlLine."Applies-to Doc. No.");
                                PurchCrMemoHeader.SetRange("Applies-to Doc. Type", PurchCrMemoHeader."Applies-to Doc. Type"::Invoice);
                                if PurchCrMemoHeader.FindFirst() then begin
                                    TempRemAmt := 0;

                                    VendLedgEntry1.SetRange("Document Type", VendLedgEntry1."Document Type"::"Credit Memo");
                                    VendLedgEntry1.SetRange("Document No.", PurchCrMemoHeader."No.");
                                    if VendLedgEntry1.FindFirst() then
                                        VendLedgEntry1.CalcFields(Amount, "Remaining Amount");

                                    WithholdingTaxEntryTemp.Reset();
                                    WithholdingTaxEntryTemp.SetRange("Document No.", PurchCrMemoHeader."No.");
                                    WithholdingTaxEntryTemp.SetRange("Document Type", WithholdingTaxEntry."Document Type"::"Credit Memo");
                                    WithholdingTaxEntryTemp.SetRange("Transaction Type", WithholdingTaxEntry."Transaction Type"::Purchase);
                                    WithholdingTaxEntryTemp.SetRange("Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group");
                                    WithholdingTaxEntryTemp.SetRange("Wthldg. Tax Prod. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                                    if WithholdingTaxEntryTemp.FindFirst() then begin
                                        TempRemBase := WithholdingTaxEntryTemp."Unrealized Amount";
                                        TempRemAmt := WithholdingTaxEntryTemp."Unrealized Base";
                                    end;
                                end;

                                VendLedgEntry.Reset();
                                VendLedgEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
                                if GenJnlLine."Applies-to Doc. Type" = GenJnlLine."Applies-to Doc. Type"::Invoice then
                                    VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::Invoice)
                                else
                                    if GenJnlLine."Applies-to Doc. Type" = GenJnlLine."Applies-to Doc. Type"::"Credit Memo" then
                                        VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::"Credit Memo");

                                if VendLedgEntry.FindFirst() then
                                    VendLedgEntry.CalcFields(Amount, "Remaining Amount");

                                ExpectedAmount := -(VendLedgEntry.Amount + VendLedgEntry1.Amount);

                                if VendLedgEntry1."Amount (LCY)" = 0 then
                                    VendLedgEntry1."Rem. Amt for Withholding Tax" := 0;
                                if (GenJnlLine."Posting Date" <= VendLedgEntry."Pmt. Discount Date") and
                                   (Abs(PaymentAmount1) >=
                                    (Abs(VendLedgEntry."Rem. Amt for Withholding Tax" + VendLedgEntry1."Rem. Amt for Withholding Tax") -
                                     Abs(VendLedgEntry."Original Pmt. Disc. Possible")))
                                then begin
                                    AppldAmount :=
                                      Round(
                                        ((PaymentAmount1 - VendLedgEntry."Original Pmt. Disc. Possible") *
                                         (WithholdingTaxEntry."Unrealized Base" + TempRemAmt)) / ExpectedAmount);
                                    WithholdingTaxEntry3."Remaining Unrealized Base" :=
                                      Round(
                                        WithholdingTaxEntry."Remaining Unrealized Base" -
                                        Round(
                                          ((PaymentAmount1 - VendLedgEntry."Original Pmt. Disc. Possible") *
                                           (WithholdingTaxEntry."Unrealized Base" + TempRemAmt)) / ExpectedAmount));
                                    WithholdingTaxEntry3."Remaining Unrealized Amount" :=
                                      Round(
                                        WithholdingTaxEntry."Remaining Unrealized Amount" -
                                        Round(
                                          ((PaymentAmount1 - VendLedgEntry."Original Pmt. Disc. Possible") *
                                           (WithholdingTaxEntry."Unrealized Amount" + TempRemBase)) / ExpectedAmount));
                                end else begin
                                    AppldAmount :=
                                      Round(
                                        (PaymentAmount1 * (WithholdingTaxEntry."Unrealized Base" + TempRemAmt)) /
                                        ExpectedAmount);

                                    WithholdingTaxEntry3."Remaining Unrealized Base" :=
                                      Round(
                                        WithholdingTaxEntry."Remaining Unrealized Base" -
                                        Round(
                                          (PaymentAmount1 * (WithholdingTaxEntry."Unrealized Base" + TempRemAmt)) /
                                          ExpectedAmount));

                                    WithholdingTaxEntry3."Remaining Unrealized Amount" :=
                                      Round(
                                        WithholdingTaxEntry."Remaining Unrealized Amount" -
                                        Round(
                                          (PaymentAmount1 * (WithholdingTaxEntry."Unrealized Amount" + TempRemBase)) /
                                          ExpectedAmount));
                                end;

                                PaymentAmount := PaymentAmount + AppldAmount;
                            end;
                    end;

                    if (WithholdingTaxEntry."Remaining Unrealized Base" = 0) and
                       (WithholdingTaxEntry."Remaining Unrealized Amount" = 0)
                    then
                        WithholdingTaxEntry3.Closed := true;

                    if GenJnlLine."Source Currency Code" <> WithholdingTaxEntry."Currency Code" then
                        Error(CurrencyCodeSameErr);

                    if AppldAmount = 0 then
                        exit(WithholdingTaxEntry2."Entry No.");

                    WithholdingTaxEntry2.Init();
                    WithholdingTaxEntry2."Posting Date" := GenJnlLine."Document Date";
                    WithholdingTaxEntry2."Entry No." := NextEntryNo();
                    WithholdingTaxEntry2."Document Date" := WithholdingTaxEntry."Document Date";
                    WithholdingTaxEntry2."Document Type" := GenJnlLine."Document Type";
                    WithholdingTaxEntry2."Document No." := WithholdingTaxEntry."Document No.";
                    WithholdingTaxEntry2."Gen. Bus. Posting Group" := WithholdingTaxEntry."Gen. Bus. Posting Group";
                    WithholdingTaxEntry2."Gen. Prod. Posting Group" := WithholdingTaxEntry."Gen. Prod. Posting Group";
                    WithholdingTaxEntry2."Bill-to/Pay-to No." := WithholdingTaxEntry."Bill-to/Pay-to No.";
                    WithholdingTaxEntry2."Wthldg. Tax Bus. Post. Group" := WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group";
                    WithholdingTaxEntry2."Wthldg. Tax Prod. Post. Group" := WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group";
                    WithholdingTaxEntry2."Withholding Tax Revenue Type" := WithholdingTaxEntry."Withholding Tax Revenue Type";
                    WithholdingTaxEntry2."Unreal. Wthldg. Tax Entry No." := WithholdingTaxEntry."Entry No.";
                    WithholdingTaxEntry2."Currency Code" := GenJnlLine."Source Currency Code";
                    WithholdingTaxEntry2."Applies-to Entry No." := WithholdingTaxEntry."Entry No.";
                    WithholdingTaxEntry2."User ID" := UserId;
                    WithholdingTaxEntry2."External Document No." := GenJnlLine."External Document No.";
                    WithholdingTaxEntry2."Actual Vendor No." := GenJnlLine."WHT Actual Vendor No.";
                    WithholdingTaxEntry2."Original Document No." := GenJnlLine."Document No.";
                    WithholdingTaxEntry2."Source Code" := GenJnlLine."Source Code";
                    WithholdingTaxEntry2."Transaction No." := TransactionNo;
                    WithholdingTaxEntry2."Withholding Tax %" := WithholdingTaxEntry."Withholding Tax %";

                    case Source of
                        Source::Vendor:
                            begin
                                WithholdingTaxEntry2.Base := Round(AppldAmount);
                                WithholdingTaxEntry2.Amount := Round(WithholdingTaxEntry2.Base * WithholdingTaxEntry2."Withholding Tax %" / 100);
                                WithholdingTaxEntry2."Transaction Type" := WithholdingTaxEntry2."Transaction Type"::Purchase;
                                WithholdingPostingSetup.Get(WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");

                                if GenJnlLine."WHT Certificate Printed" then begin
                                    WithholdingTaxEntry2."Wthldg. Tax Report Line No" := GenJnlLine."Wthldg. Tax Report Line No.";
                                    TempWithholdingTaxEntry.SetRange("Document No.", WithholdingTaxEntry2."Document No.");
                                    if TempWithholdingTaxEntry.FindFirst() then
                                        WithholdingTaxEntry2."Wthldg. Tax Certificate No." := TempWithholdingTaxEntry."Wthldg. Tax Certificate No.";
                                end else begin
                                    if ((Source = Source::Vendor) and
                                        (WithholdingTaxEntry."Document Type" = WithholdingTaxEntry."Document Type"::Invoice)) or
                                       ((Source = Source::Customer) and
                                        (WithholdingTaxEntry."Document Type" = WithholdingTaxEntry."Document Type"::"Credit Memo"))
                                    then
                                        if (WithholdingReportLineNo = '') and (WithholdingTaxEntry2.Amount <> 0) and
                                           (WithholdingPostingSetup."Wthldg. Tax Rep Line No Series" <> '')
                                        then
                                            WithholdingReportLineNo := NoSeries.GetNextNo(WithholdingPostingSetup."Wthldg. Tax Rep Line No Series", WithholdingTaxEntry2."Posting Date");

                                    WithholdingTaxEntry2."Wthldg. Tax Report Line No" := WithholdingReportLineNo;
                                end;
                            end;
                    end;

                    WithholdingTaxEntry2."Payment Amount" := PaymentAmount1;

                    if WithholdingTaxEntry2."Currency Code" <> '' then begin
                        CurrFactor :=
                          CurrExchRate.ExchangeRate(
                            WithholdingTaxEntry2."Posting Date", WithholdingTaxEntry2."Currency Code");

                        WithholdingTaxEntry2."Base (LCY)" :=
                          Round(
                            CurrExchRate.ExchangeAmtFCYToLCY(
                              GenJnlLine."Document Date",
                              WithholdingTaxEntry2."Currency Code",
                              WithholdingTaxEntry2.Base, CurrFactor));

                        WithholdingTaxEntry2."Amount (LCY)" :=
                          Round(
                            CurrExchRate.ExchangeAmtFCYToLCY(
                              GenJnlLine."Document Date",
                              WithholdingTaxEntry2."Currency Code",
                              WithholdingTaxEntry2.Amount, CurrFactor));
                    end else begin
                        WithholdingTaxEntry2."Amount (LCY)" := WithholdingTaxEntry2.Amount;
                        WithholdingTaxEntry2."Base (LCY)" := WithholdingTaxEntry2.Base;
                    end;

                    WithholdingTaxEntry2.Insert();
                    TType := TType::Purchase;
                    WithholdingTaxEntry3.Modify();

                    WithholdingTaxEntry3.Reset();
                    WithholdingTaxEntry3.SetCurrentKey("Applies-to Entry No.");
                    WithholdingTaxEntry3.SetRange("Applies-to Entry No.", WithholdingTaxEntry."Entry No.");
                    WithholdingTaxEntry3.CalcSums(Amount, "Amount (LCY)");
                    if (Abs(Abs(WithholdingTaxEntry3.Amount) - Abs(WithholdingTaxEntry."Unrealized Amount")) < 0.1) and
                       (Abs(Abs(WithholdingTaxEntry3.Amount) - Abs(WithholdingTaxEntry."Unrealized Amount")) > 0)
                    then begin
                        WithholdingTaxEntry2."Withholding Tax Difference" := WithholdingTaxEntry."Unrealized Amount" - WithholdingTaxEntry3.Amount;
                        WithholdingTaxEntry2.Amount := WithholdingTaxEntry2.Amount - WithholdingTaxEntry2."Withholding Tax Difference";
                        WithholdingTaxEntry2.Modify();
                    end;

                    if (Abs(Abs(WithholdingTaxEntry3."Amount (LCY)") -
                          Abs(WithholdingTaxEntry."Unrealized Amount (LCY)")) < 0.1) and
                       (Abs(Abs(WithholdingTaxEntry3."Amount (LCY)") - Abs(WithholdingTaxEntry."Unrealized Amount (LCY)")) > 0)
                    then begin
                        WithholdingTaxEntry2."Amount (LCY)" := WithholdingTaxEntry2."Amount (LCY)" -
                          WithholdingTaxEntry."Unrealized Amount (LCY)" + WithholdingTaxEntry3."Amount (LCY)";
                        WithholdingTaxEntry2.Modify();
                    end;
                end;
            until (WithholdingTaxEntry.Next() = 0);

        if (WithholdingPostingSetup."Realized Withholding Tax Type" =
            WithholdingPostingSetup."Realized Withholding Tax Type"::Payment)
        then
            exit(WithholdingTaxEntry2."Entry No." + 1);
    end;

    procedure CheckVendorWithholdingTaxLiable(GenJnlLine: Record "Gen. Journal Line"): Boolean
    var
        Vendor: Record Vendor;
    begin
        if Vendor.Get(GetVendorNo(GenJnlLine)) then
            exit(Vendor."Withholding Tax Liable");
    end;

    local procedure GetVendorNo(GenJnlLine: Record "Gen. Journal Line"): Code[20]
    begin
        if GenJnlLine."Account Type" = GenJnlLine."Account Type"::Vendor then
            exit(GenJnlLine."Account No.")
        else
            if GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::Vendor then
                exit(GenJnlLine."Bal. Account No.");
    end;

    procedure InitTextVariable()
    begin
        OnesText[1] := OneLbl;
        OnesText[2] := TwoLbl;
        OnesText[3] := ThreeLbl;
        OnesText[4] := FourLbl;
        OnesText[5] := FiveLbl;
        OnesText[6] := SixLbl;
        OnesText[7] := SevenLbl;
        OnesText[8] := EightLbl;
        OnesText[9] := NineLbl;
        OnesText[10] := TenLbl;
        OnesText[11] := ElevenLbl;
        OnesText[12] := TwelveLbl;
        OnesText[13] := ThirteenLbl;
        OnesText[14] := FourteenLbl;
        OnesText[15] := FifteenLbl;
        OnesText[16] := SixteenLbl;
        OnesText[17] := SeventeenLbl;
        OnesText[18] := EighteenLbl;
        OnesText[19] := NinteenLbl;

        TensText[1] := '';
        TensText[2] := TwentyLbl;
        TensText[3] := ThirtyLbl;
        TensText[4] := FortyLbl;
        TensText[5] := FiftyLbl;
        TensText[6] := SixtyLbl;
        TensText[7] := SeventyLbl;
        TensText[8] := EightyLbl;
        TensText[9] := NinetyLbl;

        ExponentText[1] := '';
        ExponentText[2] := ThousandLbl;
        ExponentText[3] := MillionLbl;
        ExponentText[4] := BillionLbl;
    end;

    procedure FormatNoText(var NoText: array[2] of Text[80]; No: Decimal; CurrencyCode: Code[10])
    var
        PrintExponent: Boolean;
        Ones: Integer;
        Tens: Integer;
        Hundreds: Integer;
        Exponent: Integer;
        NoTextIndex: Integer;
    begin
        Clear(NoText);
        NoTextIndex := 1;
        NoText[1] := '****';

        if No < 1 then
            AddToNoText(NoText, NoTextIndex, PrintExponent, ZeroLbl)
        else
            for Exponent := 4 downto 1 do begin
                PrintExponent := false;
                Ones := No div Power(1000, Exponent - 1);
                Hundreds := Ones div 100;
                Tens := (Ones mod 100) div 10;
                Ones := Ones mod 10;
                if Hundreds > 0 then begin
                    AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Hundreds]);
                    AddToNoText(NoText, NoTextIndex, PrintExponent, HundredLbl);
                end;
                if Tens >= 2 then begin
                    AddToNoText(NoText, NoTextIndex, PrintExponent, TensText[Tens]);
                    if Ones > 0 then
                        AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Ones]);
                end else
                    if (Tens * 10 + Ones) > 0 then
                        AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Tens * 10 + Ones]);
                if PrintExponent and (Exponent > 1) then
                    AddToNoText(NoText, NoTextIndex, PrintExponent, ExponentText[Exponent]);
                No := No - (Hundreds * 100 + Tens * 10 + Ones) * Power(1000, Exponent - 1);
            end;

        AddToNoText(NoText, NoTextIndex, PrintExponent, AndLbl);
        AddToNoText(NoText, NoTextIndex, PrintExponent, Format(No * 100) + '/100');

        if CurrencyCode <> '' then
            AddToNoText(NoText, NoTextIndex, PrintExponent, CurrencyCode);
    end;

    local procedure AddToNoText(var NoText: array[2] of Text[80]; var NoTextIndex: Integer; var PrintExponent: Boolean; AddText: Text[30])
    begin
        PrintExponent := true;

        while StrLen(NoText[NoTextIndex] + ' ' + AddText) > MaxStrLen(NoText[1]) do begin
            NoTextIndex := NoTextIndex + 1;
            if NoTextIndex > ArrayLen(NoText) then
                Error(MustbeNegativeLbl, AddText);
        end;

        NoText[NoTextIndex] := DelChr(NoText[NoTextIndex] + ' ' + AddText, '<');
    end;
}