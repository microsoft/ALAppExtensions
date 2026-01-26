// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.BatchProcessing;
using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.Reporting;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Setup;

codeunit 6788 "Withholding Tax Invoice Mgmt."
{
    Permissions = TableData "Cust. Ledger Entry" = rimd,
                  TableData "Vendor Ledger Entry" = rimd,
                  TableData "G/L Register" = rimd,
                  TableData "Sales Invoice Header" = rimd,
                  TableData "Sales Cr.Memo Header" = rimd,
                  TableData "Purch. Inv. Header" = rimd,
                  TableData "Purch. Cr. Memo Hdr." = rimd;

    var
        PurchTaxInvoiceHeader: Record "WHT Purch. Tax Inv. Header";
        PurchTaxCrMemoHeader: Record "WHT Purch. Tax Cr. Memo Hdr.";
        PurchSetup: Record "Purchases & Payables Setup";
        GLSetup: Record "General Ledger Setup";
        VendorLedgerEntries: Record "Vendor Ledger Entry";
        VendorLedgerEntries1: Record "Vendor Ledger Entry";
        WHTAmount: Decimal;
        TotAmt: Decimal;
        Payment1: Decimal;
        Payment2: Decimal;
        ExpectedAmount: Decimal;
        RemainingAmt: Decimal;
        GenLineAmount: Decimal;
        WHTUsed1: Boolean;
        InvNo: Code[20];
        LastTaxInvoice: Code[20];
        WarningNoSeriesCode: Code[20];
        OnesText: array[20] of Text[30];
        TensText: array[10] of Text[30];
        ExponentText: array[5] of Text[30];
        PostTaxInvoiceLbl: Label 'Are you sure you wish to post the Tax Invoice(s)?';
        PostPrintTaxInvoiceLbl: Label 'Are you sure you wish to post and print the Tax Invoice(s)?';
        TaxInvoiceAlreadyPostedErr: Label 'Tax Invoice already posted for Invoice %1.', Comment = '%1 - Tax Invoice No.';
        TaxInvoicePostedLbl: Label 'Tax Invoice(s) %1 posted successfully.', Comment = '%1 - Tax Invoice No.';
        TaxInvoicePostedPrintLbl: Label 'Tax Invoice(s) %1 posted and printed successfully.', Comment = '%1 - Tax Invoice No.';
        PostTaxCrMemoLbl: Label 'Are you sure you wish to post the Tax Credit Memo(s)?';
        PostPrintTaxCrMemoLbl: Label 'Are you sure you wish to post and print the Tax Credit Memo(s)?';
        TaxCrMemoAlreadyPostedErr: Label 'Tax Credit Memo already posted for Credit Memo %1.', Comment = '%1 - Tax CrMemo No.';
        TaxCrMemoPostedLbl: Label 'Tax Credit Memo(s) %1 posted successfully.', Comment = '%1 - Tax CrMemo No.';
        TaxCrMemoPostPrintLbl: Label 'Tax Credit Memo(s) %1 posted and printed successfully.', Comment = '%1 - Tax CrMemo No.';
        CannotAssignNewOnDateErr: Label 'You cannot assign new numbers from the number series %1 on %2.', Comment = '%1=No. Series Code,%2=Date';
        CannotAssignNewErr: Label 'You cannot assign new numbers from the number series %1.', Comment = '%1=No. Series Code';
        CannotAssignNewBeforeDateErr: Label 'You cannot assign new numbers from the number series %1 on a date before %2.', Comment = '%1=No. Series Code,%2=Date';
        CannotAssignGreaterErr: Label 'You cannot assign numbers greater than %1 from the number series %2.', Comment = '%1=Last No.,%2=No. Series Code';
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
        NuengLbl: Label 'NUENG';
        SawngLbl: Label 'SAWNG';
        SarmLbl: Label 'SARM';
        SiLbl: Label 'SI';
        HaLbl: Label 'HA';
        HokLbl: Label 'HOK';
        ChedLbl: Label 'CHED';
        PaedLbl: Label 'PAED';
        KowLbl: Label 'KOW';
        SibLbl: Label 'SIB';
        SibEdLbl: Label 'SIB-ED';
        SibSawngLbl: Label 'SIB-SAWNG';
        SibSarmLbl: Label 'SIB-SARM';
        SibSiLbl: Label 'SIB-SI';
        SibHaLbl: Label 'SIB-HA';
        SibHokLbl: Label 'SIB-HOK';
        SibChedLbl: Label 'SIB-CHED';
        SibPaedLbl: Label 'SIB-PAED';
        SibKowLbl: Label 'SIB-KOW';
        YiSibLbl: Label 'YI-SIB';
        SarmSibLbl: Label 'SARM-SIB';
        SiSibLbl: Label 'SI-SIB';
        HaSibLbl: Label 'HA-SIB';
        HokSibLbl: Label 'HOK-SIB';
        ChedSibLbl: Label 'CHED-SIB';
        PaedSibLbl: Label 'PAED-SIB';
        KowSibLbl: Label 'KOW-SIB';
        PhanLbl: Label 'PHAN';
        LaanLbl: Label 'LAAN?';
        PhaanLaanLbl: Label 'PHAN-LAAN?';
        HundredLbl: Label 'HUNDRED';
        ZeroLbl: Label 'ZERO';
        AndLbl: Label 'AND';

    procedure ApplyVendInvoiceWHT(var VendLedgerEntry: Record "Vendor Ledger Entry"; var GenJnlLine: Record "Gen. Journal Line")
    var
        PurchTaxInvHeader: Record "WHT Purch. Tax Inv. Header";
        PurchTaxInvLine: Record "WHT Purch. Tax Inv. Line";
    begin
        VendorLedgerEntries.Reset();
        if GenJnlLine."Applies-to Doc. No." = '' then begin
            VendorLedgerEntries1.SetRange("Applies-to ID", GenJnlLine."Document No.");
            if VendorLedgerEntries1.FindSet() then
                repeat
                    VendorLedgerEntries1.CalcFields(
                      Amount, "Amount (LCY)", "Remaining Amount", "Remaining Amt. (LCY)",
                      "Original Amount", "Original Amt. (LCY)");
                    if VendorLedgerEntries1."Rem. Amt for Withholding Tax" = 0 then
                        VendorLedgerEntries1."Rem. Amt for Withholding Tax" := VendorLedgerEntries1."Remaining Amt. (LCY)";
                    RemainingAmt := RemainingAmt + VendorLedgerEntries1."Rem. Amt for Withholding Tax";
                    if VendorLedgerEntries1."Document Type" = VendorLedgerEntries1."Document Type"::"Credit Memo" then
                        RemainingAmt := RemainingAmt + VendorLedgerEntries1."Rem. Amt for Withholding Tax";
                until VendorLedgerEntries1.Next() = 0;

            TotAmt := Abs(GenJnlLine.Amount);

            VendorLedgerEntries.SetRange("Applies-to ID", GenJnlLine."Document No.");
            VendorLedgerEntries.SetRange("Document Type", VendorLedgerEntries."Document Type"::"Credit Memo");
            if VendorLedgerEntries.FindSet() then
                repeat
                    VendorLedgerEntries.CalcFields(
                      Amount, "Amount (LCY)", "Remaining Amount", "Remaining Amt. (LCY)",
                      "Original Amount", "Original Amt. (LCY)");

                    if CheckPmtDisc(GenJnlLine."Posting Date", VendorLedgerEntries."Pmt. Discount Date", Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"),
                         Abs(VendorLedgerEntries."WHT Rem. Amt"), Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"), Abs(TotAmt))
                    then
                        TotAmt := TotAmt - VendorLedgerEntries."Original Pmt. Disc. Possible";

                    if (Abs(RemainingAmt) <= Abs(TotAmt)) or (Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax") < Abs(TotAmt)) then begin
                        if CheckPmtDisc(
                             GenJnlLine."Posting Date", VendorLedgerEntries."Pmt. Discount Date", Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"),
                             Abs(VendorLedgerEntries."WHT Rem. Amt"), Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"), Abs(TotAmt))
                        then begin
                            GenJnlLine.Validate(
                              Amount, -Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax" + VendorLedgerEntries."Original Pmt. Disc. Possible"));
                            if VendorLedgerEntries."Document Type" <> VendorLedgerEntries."Document Type"::"Credit Memo" then
                                TotAmt := TotAmt - VendorLedgerEntries."Rem. Amt for Withholding Tax";
                            RemainingAmt := RemainingAmt - VendorLedgerEntries."Rem. Amt for Withholding Tax" + VendorLedgerEntries."Original Pmt. Disc. Possible";
                        end else begin
                            GenJnlLine.Validate(Amount, -Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"));
                            if VendorLedgerEntries."Document Type" <> VendorLedgerEntries."Document Type"::"Credit Memo" then
                                TotAmt := TotAmt - VendorLedgerEntries."Rem. Amt for Withholding Tax";
                            RemainingAmt := RemainingAmt - VendorLedgerEntries."Rem. Amt for Withholding Tax";
                        end;
                    end else begin
                        if CheckPmtDisc(
                             GenJnlLine."Posting Date", VendorLedgerEntries."Pmt. Discount Date", Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"),
                             Abs(VendorLedgerEntries."WHT Rem. Amt"), Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"), Abs(TotAmt))
                        then
                            GenJnlLine.Validate(Amount, TotAmt + VendorLedgerEntries."Original Pmt. Disc. Possible")
                        else
                            GenJnlLine.Validate(Amount, TotAmt);
                        TotAmt := -1;
                    end;

                    if VendorLedgerEntries."Document Type" = VendorLedgerEntries."Document Type"::Invoice then
                        GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice
                    else begin
                        if VendorLedgerEntries."Document Type" = VendorLedgerEntries."Document Type"::"Credit Memo" then
                            GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::"Credit Memo";
                        RemainingAmt := RemainingAmt - VendorLedgerEntries."Rem. Amt for Withholding Tax";
                        TotAmt := TotAmt + VendorLedgerEntries."Rem. Amt for Withholding Tax";
                    end;

                    GenJnlLine."Applies-to Doc. No." := VendorLedgerEntries."Document No.";
                    TaxInvoicePurchase(GenJnlLine, false);
                    GenJnlLine."Withholding Tax Payment" := true;
                    VendLedgerEntry."Applies-to ID" := '';
                    VendLedgerEntry.Modify();
                until (VendorLedgerEntries.Next() = 0) or (TotAmt = -1);

            VendorLedgerEntries.Reset();
            VendorLedgerEntries.SetRange("Applies-to ID", GenJnlLine."Document No.");
            VendorLedgerEntries.SetFilter("Document Type", '<>%1', VendorLedgerEntries."Document Type"::"Credit Memo");
            if VendorLedgerEntries.FindSet() then
                repeat
                    VendorLedgerEntries.CalcFields(
                      Amount, "Amount (LCY)", "Remaining Amount", "Remaining Amt. (LCY)",
                      "Original Amount", "Original Amt. (LCY)");

                    if CheckPmtDisc(GenJnlLine."Posting Date", VendorLedgerEntries."Pmt. Discount Date", Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"),
                         Abs(VendorLedgerEntries."WHT Rem. Amt"), Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"), Abs(TotAmt))
                    then
                        TotAmt := TotAmt - VendorLedgerEntries."Original Pmt. Disc. Possible";

                    if (Abs(RemainingAmt) <= Abs(TotAmt)) or (Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax") < Abs(TotAmt)) then begin
                        if CheckPmtDisc(
                             GenJnlLine."Posting Date", VendorLedgerEntries."Pmt. Discount Date", Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"),
                             Abs(VendorLedgerEntries."WHT Rem. Amt"), Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"), Abs(TotAmt))
                        then begin
                            GenJnlLine.Validate(
                              Amount, Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax" - VendorLedgerEntries."Original Pmt. Disc. Possible"));
                            if VendorLedgerEntries."Document Type" <> VendorLedgerEntries."Document Type"::"Credit Memo" then
                                TotAmt := TotAmt + VendorLedgerEntries."Rem. Amt for Withholding Tax";
                            RemainingAmt := RemainingAmt - VendorLedgerEntries."Rem. Amt for Withholding Tax" + VendorLedgerEntries."Original Pmt. Disc. Possible";
                        end else begin
                            GenJnlLine.Validate(Amount, Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"));
                            if VendorLedgerEntries."Document Type" <> VendorLedgerEntries."Document Type"::"Credit Memo" then
                                TotAmt := TotAmt + VendorLedgerEntries."Rem. Amt for Withholding Tax";
                            RemainingAmt := RemainingAmt - VendorLedgerEntries."Rem. Amt for Withholding Tax";
                        end;
                    end else begin
                        if CheckPmtDisc(
                             GenJnlLine."Posting Date", VendorLedgerEntries."Pmt. Discount Date", Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"),
                             Abs(VendorLedgerEntries."WHT Rem. Amt"), Abs(VendorLedgerEntries."Original Pmt. Disc. Possible"), Abs(TotAmt))
                        then
                            GenJnlLine.Validate(Amount, TotAmt + VendorLedgerEntries."Original Pmt. Disc. Possible")
                        else
                            GenJnlLine.Validate(Amount, TotAmt);
                        TotAmt := -1;
                    end;

                    if VendorLedgerEntries."Document Type" = VendorLedgerEntries."Document Type"::Invoice then
                        GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice
                    else begin
                        if VendorLedgerEntries."Document Type" = VendorLedgerEntries."Document Type"::"Credit Memo" then
                            GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::"Credit Memo";
                        RemainingAmt := RemainingAmt + VendorLedgerEntries."Rem. Amt for Withholding Tax";
                        TotAmt := TotAmt + VendorLedgerEntries."Rem. Amt for Withholding Tax";
                    end;

                    GenJnlLine."Applies-to Doc. No." := VendorLedgerEntries."Document No.";
                    TaxInvoicePurchase(GenJnlLine, false);
                    GenJnlLine."Withholding Tax Payment" := true;
                    VendLedgerEntry."Applies-to ID" := '';
                    VendLedgerEntry.Modify();
                until (VendorLedgerEntries.Next() = 0) or (TotAmt = -1);
        end else
            TaxInvoicePurchase(GenJnlLine, false);

        if InvNo <> '' then begin
            PurchTaxInvLine.SetRange("Document No.", InvNo);
            if not PurchTaxInvLine.FindFirst() then
                if PurchTaxInvHeader.Get(InvNo) then begin
                    PurchTaxInvHeader.Delete();
                    PurchSetup.Get();
                    if CheckTaxableNoSeries(VendLedgerEntry."Vendor No.", 0) then
                        ReverseGetNextNo(PurchSetup."WHT Posted Non Tax Inv. Nos.", PurchTaxInvHeader."Posting Date")
                    else
                        ReverseGetNextNo(PurchSetup."WHT Posted Tax Invoice Nos.", PurchTaxInvHeader."Posting Date");
                end;
        end;

        PurchTaxInvHeader.SetRange("Posting Description", GenJnlLine."Document No.");
        if PurchTaxInvHeader.FindFirst() then
            BuildTaxPostBuffer(PurchTaxInvHeader."No.", PurchTaxInvHeader."Posting Description", 0);
    end;

    procedure ApplyVendCreditWHT(var VendLedgerEntry: Record "Vendor Ledger Entry"; var GenJnlLine: Record "Gen. Journal Line")
    var
        PurchTaxCrMemoHeader: Record "WHT Purch. Tax Cr. Memo Hdr.";
        PurchTaxCrMemoLine: Record "WHT Purch. Tax Cr. Memo Line";
    begin
        VendorLedgerEntries.Reset();
        WHTUsed1 := false;

        if GenJnlLine."Applies-to Doc. No." = '' then begin
            VendorLedgerEntries1.SetRange("Applies-to ID", GenJnlLine."Document No.");
            if VendorLedgerEntries1.FindSet() then
                repeat
                    VendorLedgerEntries1.CalcFields(
                      Amount, "Amount (LCY)", "Remaining Amount", "Remaining Amt. (LCY)",
                      "Original Amount", "Original Amt. (LCY)");
                    if VendorLedgerEntries1."Rem. Amt for Withholding Tax" = 0 then
                        VendorLedgerEntries1."Rem. Amt for Withholding Tax" := VendorLedgerEntries1."Remaining Amt. (LCY)";
                    RemainingAmt := RemainingAmt + VendorLedgerEntries1."Rem. Amt for Withholding Tax";
                    if VendorLedgerEntries1."Document Type" = VendorLedgerEntries1."Document Type"::"Credit Memo" then
                        RemainingAmt := RemainingAmt + VendorLedgerEntries1."Rem. Amt for Withholding Tax";
                until VendorLedgerEntries1.Next() = 0;

            TotAmt := Abs(GenJnlLine.Amount);

            VendorLedgerEntries.SetRange("Applies-to ID", GenJnlLine."Document No.");
            VendorLedgerEntries.SetRange("Document Type", VendorLedgerEntries."Document Type"::"Credit Memo");
            if VendorLedgerEntries.FindSet() then
                repeat
                    VendorLedgerEntries.CalcFields(
                      Amount, "Amount (LCY)", "Remaining Amount", "Remaining Amt. (LCY)",
                      "Original Amount", "Original Amt. (LCY)");

                    if Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax") >= (Abs(VendorLedgerEntries."WHT Rem. Amt") - Abs(
                                                                       VendorLedgerEntries."Original Pmt. Disc. Possible"))
                    then
                        if (GenJnlLine."Posting Date" <= VendorLedgerEntries."Pmt. Discount Date") and
                           (Abs(TotAmt) >= (Abs(VendorLedgerEntries."WHT Rem. Amt") - Abs(
                                              VendorLedgerEntries."Original Pmt. Disc. Possible")))
                        then
                            TotAmt := TotAmt - VendorLedgerEntries."Original Pmt. Disc. Possible";

                    if (Abs(RemainingAmt) <= Abs(TotAmt)) or (Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax") < Abs(TotAmt)) then begin
                        if (GenJnlLine."Posting Date" <= VendorLedgerEntries."Pmt. Discount Date") and
                           (Abs(TotAmt) >= (Abs(VendorLedgerEntries."WHT Rem. Amt") - Abs(
                                              VendorLedgerEntries."Original Pmt. Disc. Possible"))) and
                           (Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax") >= (Abs(VendorLedgerEntries."WHT Rem. Amt") - Abs(
                                                                            VendorLedgerEntries."Original Pmt. Disc. Possible")))
                        then begin
                            GenJnlLine.Validate(
                              Amount, -Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax" + VendorLedgerEntries."Original Pmt. Disc. Possible"));
                            if VendorLedgerEntries."Document Type" <> VendorLedgerEntries."Document Type"::"Credit Memo" then
                                TotAmt := TotAmt - VendorLedgerEntries."Rem. Amt for Withholding Tax";
                            RemainingAmt := RemainingAmt - VendorLedgerEntries."Rem. Amt for Withholding Tax" + VendorLedgerEntries."Original Pmt. Disc. Possible";
                        end else begin
                            GenJnlLine.Validate(Amount, -Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax"));
                            if VendorLedgerEntries."Document Type" <> VendorLedgerEntries."Document Type"::"Credit Memo" then
                                TotAmt := TotAmt - VendorLedgerEntries."Rem. Amt for Withholding Tax";
                            RemainingAmt := RemainingAmt - VendorLedgerEntries."Rem. Amt for Withholding Tax";
                        end;
                    end else begin
                        if (GenJnlLine."Posting Date" <= VendorLedgerEntries."Pmt. Discount Date") and
                           (Abs(TotAmt) >= (Abs(VendorLedgerEntries."WHT Rem. Amt") - Abs(
                                              VendorLedgerEntries."Original Pmt. Disc. Possible"))) and
                           (Abs(VendorLedgerEntries."Rem. Amt for Withholding Tax") >= (Abs(VendorLedgerEntries."WHT Rem. Amt") - Abs(
                                                                            VendorLedgerEntries."Original Pmt. Disc. Possible")))
                        then
                            GenJnlLine.Validate(Amount, TotAmt + VendorLedgerEntries."Original Pmt. Disc. Possible")
                        else
                            GenJnlLine.Validate(Amount, TotAmt);
                        TotAmt := -1;
                    end;

                    if VendorLedgerEntries."Document Type" = VendorLedgerEntries."Document Type"::Invoice then
                        GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice
                    else begin
                        if VendorLedgerEntries."Document Type" = VendorLedgerEntries."Document Type"::"Credit Memo" then
                            GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::"Credit Memo";
                        RemainingAmt := RemainingAmt - VendorLedgerEntries."Rem. Amt for Withholding Tax";
                        TotAmt := TotAmt + VendorLedgerEntries."Rem. Amt for Withholding Tax";
                    end;

                    GenJnlLine."Applies-to Doc. No." := VendorLedgerEntries."Document No.";
                    TaxInvoicePurchaseCrMemo(GenJnlLine, WHTUsed1, false);
                    WHTUsed1 := true;
                    VendLedgerEntry."Applies-to ID" := '';
                    VendLedgerEntry.Modify();
                until (VendorLedgerEntries.Next() = 0) or (TotAmt = -1);
        end else
            TaxInvoicePurchaseCrMemo(GenJnlLine, WHTUsed1, false);
        if InvNo <> '' then begin
            PurchTaxCrMemoLine.SetRange("Document No.", InvNo);
            if not PurchTaxCrMemoLine.FindFirst() then
                if PurchTaxCrMemoHeader.Get(InvNo) then begin
                    PurchTaxCrMemoHeader.Delete();
                    PurchSetup.Get();
                    if CheckTaxableNoSeries(VendLedgerEntry."Vendor No.", 0) then
                        ReverseGetNextNo(PurchSetup."WHT Pstd. Non Tax Cr. Memo Nos", PurchTaxCrMemoHeader."Posting Date")
                    else
                        ReverseGetNextNo(PurchSetup."WHT Posted Tax Credit Memo Nos", PurchTaxCrMemoHeader."Posting Date");
                end;
        end;

        PurchTaxCrMemoHeader.SetRange("Posting Description", GenJnlLine."Document No.");
        if PurchTaxCrMemoHeader.FindFirst() then
            BuildTaxPostBuffer(PurchTaxCrMemoHeader."No.", PurchTaxCrMemoHeader."Posting Description", 2);
    end;

    procedure PurchTaxInvPost(PurchInvHeader: Record "Purch. Inv. Header") TaxInvNo: Code[20]
    var
        PurchTaxInvHeader: Record "WHT Purch. Tax Inv. Header";
        PurchInvHeader2: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchTaxInvLine: Record "WHT Purch. Tax Inv. Line";
        VATPostingSetup: Record "VAT Posting Setup";
        PurchTaxInvLine1: Record "WHT Purch. Tax Inv. Line";
    begin
        PurchInvHeader2.Reset();
        PurchInvHeader2.SetRange("No.", PurchInvHeader."No.");
        PurchInvHeader2.FindFirst();
        PurchInvLine.Reset();
        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
        PurchInvLine.FindFirst();
        PurchTaxInvHeader.Init();
        PurchTaxInvHeader.TransferFieldsFrom(PurchInvHeader2);
        PurchTaxInvHeader."No." := '';
        PurchTaxInvHeader."Posting Date" := WorkDate();
        PurchTaxInvHeader.Insert(true);
        repeat
            if VATPostingSetup.Get(PurchInvLine."VAT Bus. Posting Group", PurchInvLine."VAT Prod. Posting Group") then
                if VATPostingSetup."Unrealized VAT Type" = VATPostingSetup."Unrealized VAT Type"::" " then begin
                    PurchTaxInvLine.Init();
                    PurchTaxInvLine.TransferFieldsFrom(PurchInvLine);
                    PurchTaxInvLine."Document No." := PurchTaxInvHeader."No.";
                    PurchTaxInvLine."Paid Amount Incl. VAT" := PurchTaxInvLine."Amount Including VAT";
                    PurchTaxInvLine."Paid VAT" := PurchTaxInvLine."Amount Including VAT" - PurchTaxInvLine."VAT Base Amount";
                    PurchTaxInvLine."External Document No." := PurchInvHeader."No.";
                    PurchTaxInvLine.Insert();
                end;
        until PurchInvLine.Next() = 0;

        PurchTaxInvLine1.Reset();
        PurchTaxInvLine1.SetRange("Document No.", PurchTaxInvHeader."No.");
        if not PurchTaxInvLine1.FindFirst() then begin
            PurchTaxInvHeader.Delete();
            PurchSetup.Get();
            if CheckTaxableNoSeries(PurchInvHeader."Buy-from Vendor No.", 0) then
                ReverseGetNextNo(PurchSetup."WHT Posted Non Tax Inv. Nos.", PurchTaxInvHeader."Posting Date")
            else
                ReverseGetNextNo(PurchSetup."WHT Posted Tax Invoice Nos.", PurchTaxInvHeader."Posting Date");
        end else begin
            BuildTaxPostBuffer(PurchTaxInvHeader."No.", PurchTaxInvHeader."Posting Description", 0);
            PurchInvHeader2."WHT Printed Tax Document" := true;
            PurchInvHeader2.Modify();
        end;
    end;

    procedure PurchTaxCrMemoPost(PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.") TaxInvNo: Code[20]
    var
        PurchTaxCrMemoHeader: Record "WHT Purch. Tax Cr. Memo Hdr.";
        PurchCrMemoHeader2: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        PurchTaxCrMemoLine: Record "WHT Purch. Tax Cr. Memo Line";
        VatPostingSetup: Record "VAT Posting Setup";
        PurchTaxCrMemoLine1: Record "WHT Purch. Tax Cr. Memo Line";
    begin
        PurchCrMemoHeader2.Reset();
        PurchCrMemoHeader2.SetRange("No.", PurchCrMemoHeader."No.");
        PurchCrMemoHeader2.FindFirst();
        PurchCrMemoLine.Reset();
        PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHeader."No.");
        PurchCrMemoLine.FindFirst();
        PurchTaxCrMemoHeader.Init();
        PurchTaxCrMemoHeader.TransferFieldsFrom(PurchCrMemoHeader2);
        PurchTaxCrMemoHeader."No." := '';
        PurchTaxCrMemoHeader."Posting Date" := WorkDate();
        PurchTaxCrMemoHeader.Insert(true);
        repeat
            PurchTaxCrMemoLine.Init();
            if VatPostingSetup.Get(PurchCrMemoLine."VAT Bus. Posting Group", PurchCrMemoLine."VAT Prod. Posting Group") then
                if VatPostingSetup."Unrealized VAT Type" = VatPostingSetup."Unrealized VAT Type"::" " then begin
                    PurchTaxCrMemoLine.TransferFieldsFrom(PurchCrMemoLine);
                    PurchTaxCrMemoLine."Document No." := PurchTaxCrMemoHeader."No.";
                    PurchTaxCrMemoLine."External Document No." := PurchCrMemoHeader."No.";
                    PurchTaxCrMemoLine.Insert();
                end;
        until PurchCrMemoLine.Next() = 0;

        PurchTaxCrMemoLine1.Reset();
        PurchTaxCrMemoLine1.SetRange("Document No.", PurchTaxCrMemoHeader."No.");
        if not PurchTaxCrMemoLine1.FindFirst() then begin
            PurchTaxCrMemoHeader.Delete();
            PurchSetup.Get();
            if CheckTaxableNoSeries(PurchCrMemoHeader."Buy-from Vendor No.", 0) then
                ReverseGetNextNo(PurchSetup."WHT Pstd. Non Tax Cr. Memo Nos", PurchTaxCrMemoHeader."Posting Date")
            else
                ReverseGetNextNo(PurchSetup."WHT Posted Tax Credit Memo Nos", PurchTaxCrMemoHeader."Posting Date");
        end else begin
            BuildTaxPostBuffer(PurchTaxCrMemoHeader."No.", PurchTaxCrMemoHeader."Posting Description", 2);
            PurchCrMemoHeader2."WHT Printed Tax Document" := true;
            PurchCrMemoHeader2.Modify();
        end;
    end;

    procedure PurchTaxInvPosted(PurchInvHeader: Record "Purch. Inv. Header"; Print: Boolean) TaxInvNo: Code[20]
    var
        PurchTaxInvHeader: Record "WHT Purch. Tax Inv. Header";
        ReportSelection: Record "Report Selections";
        PurchSetup: Record "Purchases & Payables Setup";
        TaxInvoiceNo: Code[20];
    begin
        if PurchInvHeader."WHT Posted Tax Document" then
            Error(TaxInvoiceAlreadyPostedErr, PurchInvHeader."No.");

        if Print then
            if not Confirm(PostPrintTaxInvoiceLbl) then
                exit;

        if not Print then
            if not Confirm(PostTaxInvoiceLbl) then
                exit;

        TaxInvoiceNo := PurchTaxInvPost(PurchInvHeader);
        PurchInvHeader."WHT Posted Tax Document" := true;

        if Print then begin
            PurchTaxInvoiceHeader.Get(TaxInvoiceNo);
            ReportSelection.Reset();
            ReportSelection.SetRange(Usage, ReportSelection.Usage::"P. Withholding Tax Invoice");
            if ReportSelection.FindSet() then
                repeat
                    REPORT.Run(ReportSelection."Report ID", PurchSetup."WHT Print Dialog", false, PurchTaxInvHeader);
                until ReportSelection.Next() = 0;
            PurchInvHeader."WHT Printed Tax Document" := true;
            Message(TaxInvoicePostedPrintLbl, TaxInvoiceNo);
        end else
            Message(TaxInvoicePostedLbl, TaxInvoiceNo);
        PurchInvHeader.Modify();
    end;

    procedure PurchTaxCrMemoPosted(PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; Print: Boolean) TaxInvNo: Code[20]
    var
        PurchTaxCrMemoHeader: Record "WHT Purch. Tax Cr. Memo Hdr.";
        ReportSelection: Record "Report Selections";
        PurchSetup: Record "Purchases & Payables Setup";
        TaxInvoiceNo: Code[20];
    begin
        if PurchCrMemoHeader."WHT Posted Tax Document" then
            Error(TaxCrMemoAlreadyPostedErr, PurchCrMemoHeader."No.");

        if Print then
            if not Confirm(PostPrintTaxCrMemoLbl) then
                exit;

        if not Print then
            if not Confirm(PostTaxCrMemoLbl) then
                exit;

        TaxInvoiceNo := PurchTaxCrMemoPost(PurchCrMemoHeader);
        PurchCrMemoHeader."WHT Posted Tax Document" := true;

        if Print then begin
            PurchTaxCrMemoHeader.Get(TaxInvoiceNo);
            ReportSelection.Reset();
            ReportSelection.SetRange(Usage, ReportSelection.Usage::"P. Withholding Tax Credit Memo");
            if ReportSelection.FindSet() then
                repeat
                    REPORT.Run(ReportSelection."Report ID", PurchSetup."WHT Print Dialog", false, PurchTaxCrMemoHeader);
                until ReportSelection.Next() = 0;
            PurchCrMemoHeader."WHT Printed Tax Document" := true;
            Message(TaxCrMemoPostPrintLbl, TaxInvoiceNo);
        end else
            Message(TaxCrMemoPostedLbl, TaxInvoiceNo);
        PurchCrMemoHeader.Modify();
    end;

    procedure TaxInvoicePurchase(var GenJnlLine: Record "Gen. Journal Line"; AmountWithDisc: Boolean)
    var
        WithholdingTaxEntry: Record "Withholding Tax Entry";
        WithholdingTaxEntry1: Record "Withholding Tax Entry";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchTaxInvHeader: Record "WHT Purch. Tax Inv. Header";
        PurchInvoiceLine: Record "Purch. Inv. Line";
        PurchTaxInvLine: Record "WHT Purch. Tax Inv. Line";
        VendLedgEntry: Record "Vendor Ledger Entry";
        VendLedgEntry1: Record "Vendor Ledger Entry";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        VATPostingSetup: Record "VAT Posting Setup";
        WHTAmount1: Decimal;
        LineNo: Integer;
    begin
        WHTAmount := 0;

        if GenJnlLine."Applies-to Doc. Type" = GenJnlLine."Applies-to Doc. Type"::"Credit Memo" then begin
            if not PurchCrMemoHeader.Get(GenJnlLine."Applies-to Doc. No.") then
                exit;

            if not PurchCrMemoHeader."WHT Posted Tax Document" then
                exit;

            if not GenJnlLine."Withholding Tax Payment" then begin
                PurchTaxInvHeader.Init();
                PurchTaxInvHeader.TransferFields(PurchCrMemoHeader);
                PurchTaxInvHeader."Posting Date" := GenJnlLine."Posting Date";
                PurchTaxInvHeader."Posting Description" := GenJnlLine."Document No.";
                PurchTaxInvLine."External Document No." := PurchCrMemoHeader."No.";
                PurchTaxInvHeader."No." := '';
                PurchTaxInvHeader.Insert(true);
            end;

            PurchCrMemoLine.Reset();
            PurchCrMemoLine.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
            if PurchCrMemoLine.FindSet() then
                repeat
                    WHTAmount := 0;
                    WithholdingTaxEntry.Reset();
                    WithholdingTaxEntry.SetRange("Document No.", PurchCrMemoLine."Document No.");
                    WithholdingTaxEntry.SetRange("Applies-to Entry No.", 0);
                    if WithholdingTaxEntry.FindSet() then
                        repeat
                            WHTAmount := WHTAmount + WithholdingTaxEntry.Amount;
                        until WithholdingTaxEntry.Next() = 0;

                    Payment1 := 0;
                    Payment2 := 0;

                    PurchTaxInvHeader.SetRange("Posting Description", GenJnlLine."Document No.");
                    if PurchTaxInvHeader.FindFirst() then begin
                        PurchTaxInvLine.SetRange("Document No.", PurchTaxInvHeader."No.");
                        if PurchTaxInvLine.FindLast() then
                            LineNo := PurchTaxInvLine."Line No." + 10000;
                    end;

                    if LineNo = 0 then
                        LineNo := 10000;

                    VendLedgEntry.Reset();
                    VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::"Credit Memo");
                    VendLedgEntry.SetRange("Document No.", PurchCrMemoLine."Document No.");
                    if VendLedgEntry.FindFirst() then begin
                        VendLedgEntry.CalcFields("Amount (LCY)", "Remaining Amt. (LCY)", Amount, "Remaining Amount");

                        PurchTaxInvLine.Init();
                        if VATPostingSetup.Get(PurchCrMemoLine."VAT Bus. Posting Group", PurchCrMemoLine."VAT Prod. Posting Group") then
                            if VATPostingSetup."Unrealized VAT Type" <> VATPostingSetup."Unrealized VAT Type"::" " then begin
                                PurchTaxInvLine.TransferFieldsFrom(PurchCrMemoLine);
                                PurchTaxInvLine."Line No." := LineNo;
                                PurchTaxInvLine."Document No." := PurchTaxInvHeader."No.";
                                PurchTaxInvLine.Amount := -PurchTaxInvLine.Amount;
                                PurchTaxInvLine."Amount Including VAT" := -PurchTaxInvLine."Amount Including VAT";
                                PurchTaxInvLine."Direct Unit Cost" := -PurchTaxInvLine."Direct Unit Cost";
                                PurchTaxInvLine."Unit Cost (LCY)" := -PurchTaxInvLine."Unit Cost (LCY)";
                                PurchTaxInvLine."Line Amount" := -PurchTaxInvLine."Line Amount";
                                PurchTaxInvLine."VAT Base Amount" := -PurchTaxInvLine."VAT Base Amount";
                                PurchTaxInvLine."External Document No." := PurchCrMemoHeader."No.";
                                if (GenJnlLine."Posting Date" <= VendLedgEntry."Pmt. Discount Date") and
                                   (Abs(GenJnlLine.Amount) >= (Abs(VendLedgEntry."WHT Rem. Amt") -
                                                               Abs(VendLedgEntry."Original Pmt. Disc. Possible"))) and (not AmountWithDisc)
                                then
                                    GenLineAmount := GenJnlLine.Amount + VendLedgEntry."Original Pmt. Disc. Possible"
                                else
                                    GenLineAmount := GenJnlLine.Amount;

                                ExpectedAmount := -VendLedgEntry.Amount;
                                PurchTaxInvLine."Paid Amount Incl. VAT" := Round(Abs(GenLineAmount) *
                                    PurchCrMemoLine."Amount Including VAT" / ExpectedAmount);
                                PurchTaxInvLine."Paid VAT" := Round(Abs(GenLineAmount)
                                    * (PurchCrMemoLine."Amount Including VAT" - PurchCrMemoLine."VAT Base Amount")
                                    / ExpectedAmount);

                                if PurchTaxInvLine."Paid VAT" <> 0 then
                                    PurchTaxInvLine.Insert();

                                LineNo := LineNo + 10000;
                            end;
                    end;
                until PurchCrMemoLine.Next() = 0;
        end else begin
            if not PurchInvHeader.Get(GenJnlLine."Applies-to Doc. No.") then
                exit;

            if not PurchInvHeader."WHT Posted Tax Document" then
                exit;

            if not GenJnlLine."Withholding Tax Payment" then begin
                PurchTaxInvHeader.Init();
                PurchTaxInvHeader.TransferFieldsFrom(PurchInvHeader);
                PurchTaxInvHeader."Posting Date" := GenJnlLine."Posting Date";
                PurchTaxInvHeader."Posting Description" := GenJnlLine."Document No.";
                PurchTaxInvLine."External Document No." := PurchInvHeader."No.";
                PurchTaxInvHeader."No." := '';
                PurchTaxInvHeader.Insert(true);
            end;

            PurchInvoiceLine.Reset();
            PurchInvoiceLine.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
            if PurchInvoiceLine.FindSet() then
                repeat
                    WHTAmount := 0;
                    WithholdingTaxEntry.Reset();
                    WithholdingTaxEntry.SetRange("Document No.", PurchInvoiceLine."Document No.");
                    WithholdingTaxEntry.SetRange("Applies-to Entry No.", 0);
                    if WithholdingTaxEntry.FindSet() then
                        repeat
                            WHTAmount := WHTAmount + WithholdingTaxEntry.Amount;
                        until WithholdingTaxEntry.Next() = 0;

                    Payment1 := 0;
                    Payment2 := 0;

                    PurchCrMemoHeader.SetRange("Applies-to Doc. Type", PurchCrMemoHeader."Applies-to Doc. Type"::Invoice);
                    PurchCrMemoHeader.SetRange("Applies-to Doc. No.", PurchInvoiceLine."Document No.");
                    if PurchCrMemoHeader.FindFirst() then begin
                        VendLedgEntry1.SetRange("Document Type", VendLedgEntry1."Document Type"::"Credit Memo");
                        VendLedgEntry1.SetRange("Document No.", PurchCrMemoHeader."No.");
                        if VendLedgEntry1.FindFirst() then
                            VendLedgEntry1.CalcFields("Amount (LCY)", "Remaining Amt. (LCY)", Amount, "Remaining Amount");

                        WHTAmount1 := 0;
                        WithholdingTaxEntry1.Reset();
                        WithholdingTaxEntry1.SetRange("Document No.", PurchCrMemoHeader."No.");
                        WithholdingTaxEntry1.SetRange("Applies-to Entry No.", 0);
                        if WithholdingTaxEntry1.FindSet() then
                            repeat
                                WHTAmount1 := WHTAmount1 + WithholdingTaxEntry1.Amount;
                            until WithholdingTaxEntry1.Next() = 0;
                        WHTAmount := WHTAmount + WHTAmount1;
                    end;

                    PurchTaxInvHeader.SetRange("Posting Description", GenJnlLine."Document No.");
                    if PurchTaxInvHeader.FindFirst() then begin
                        PurchTaxInvLine.SetRange("Document No.", PurchTaxInvHeader."No.");
                        if PurchTaxInvLine.FindLast() then
                            LineNo := PurchTaxInvLine."Line No." + 10000;
                    end;

                    if LineNo = 0 then
                        LineNo := 10000;

                    VendLedgEntry.Reset();
                    VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::Invoice);
                    VendLedgEntry.SetRange("Document No.", PurchInvoiceLine."Document No.");
                    if VendLedgEntry.FindFirst() then begin
                        VendLedgEntry.CalcFields("Amount (LCY)", "Remaining Amt. (LCY)", Amount, "Remaining Amount");
                        PurchTaxInvLine.Init();
                        if VATPostingSetup.Get(PurchInvoiceLine."VAT Bus. Posting Group", PurchInvoiceLine."VAT Prod. Posting Group") then
                            if VATPostingSetup."Unrealized VAT Type" <> VATPostingSetup."Unrealized VAT Type"::" " then begin
                                PurchTaxInvLine.TransferFieldsFrom(PurchInvoiceLine);
                                PurchTaxInvLine."Line No." := LineNo;
                                PurchTaxInvLine."Document No." := PurchTaxInvHeader."No.";
                                PurchTaxInvLine."External Document No." := PurchInvHeader."No.";

                                if VendLedgEntry1."Amount (LCY)" = 0 then
                                    VendLedgEntry1."WHT Rem. Amt" := 0;

                                if (GenJnlLine."Posting Date" <= VendLedgEntry."Pmt. Discount Date") and
                                   (Abs(GenJnlLine.Amount) >= (Abs(VendLedgEntry."WHT Rem. Amt" + VendLedgEntry1."WHT Rem. Amt") -
                                                               Abs(VendLedgEntry."Original Pmt. Disc. Possible"))) and (not AmountWithDisc)
                                then
                                    GenLineAmount := GenJnlLine.Amount - VendLedgEntry."Original Pmt. Disc. Possible"
                                else
                                    GenLineAmount := GenJnlLine.Amount;

                                ExpectedAmount := -(VendLedgEntry.Amount + VendLedgEntry1.Amount);
                                PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHeader."No.");
                                PurchCrMemoLine.SetRange(Type, PurchInvoiceLine.Type);
                                PurchCrMemoLine.SetRange("No.", PurchInvoiceLine."No.");
                                if PurchCrMemoLine.FindFirst() then begin
                                    PurchTaxInvLine."Paid Amount Incl. VAT" := Round(Abs(GenLineAmount) *
                                        (PurchInvoiceLine."Amount Including VAT" - PurchCrMemoLine."Amount Including VAT") / ExpectedAmount);
                                    PurchTaxInvLine."Paid VAT" := Round(Abs(GenLineAmount)
                                        *
                                        (PurchInvoiceLine."Amount Including VAT" -
                                         PurchInvoiceLine."VAT Base Amount" - PurchCrMemoLine."Amount Including VAT" +
                                         PurchCrMemoLine."VAT Base Amount") / ExpectedAmount);
                                end else begin
                                    PurchTaxInvLine."Paid Amount Incl. VAT" := Round(Abs(GenLineAmount) *
                                        PurchInvoiceLine."Amount Including VAT" / ExpectedAmount);
                                    PurchTaxInvLine."Paid VAT" := Round(Abs(GenLineAmount)
                                        * (PurchInvoiceLine."Amount Including VAT" - PurchInvoiceLine."VAT Base Amount")
                                        / ExpectedAmount);
                                end;

                                if (GenJnlLine."Currency Code" <> WithholdingTaxEntry."Currency Code") and (WHTAmount <> 0) then
                                    Error('');

                                if PurchTaxInvLine."Paid VAT" <> 0 then
                                    PurchTaxInvLine.Insert();

                                LineNo := LineNo + 10000;
                            end;
                    end;
                until PurchInvoiceLine.Next() = 0;

            InvNo := PurchTaxInvHeader."No.";
            PurchInvHeader."WHT Printed Tax Document" := true;
            PurchInvHeader.Modify();
        end;
    end;

    procedure TaxInvoicePurchaseCrMemo(var GenJnlLine: Record "Gen. Journal Line"; WHTUsed: Boolean; AmountWithDisc: Boolean)
    var
        PurchTaxCrMemoHeader: Record "WHT Purch. Tax Cr. Memo Hdr.";
        PurchTaxCrMemoLine: Record "WHT Purch. Tax Cr. Memo Line";
        VendLedgEntry: Record "Vendor Ledger Entry";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        VATPostingSetup: Record "VAT Posting Setup";
        WithholdingTaxEntry: Record "Withholding Tax Entry";
        LineNo: Integer;
        WHTAmount1: Decimal;
    begin
        if GenJnlLine."Applies-to Doc. Type" = GenJnlLine."Applies-to Doc. Type"::"Credit Memo" then begin
            if not PurchCrMemoHeader.Get(GenJnlLine."Applies-to Doc. No.") then
                exit;

            if not PurchCrMemoHeader."WHT Posted Tax Document" then
                exit;

            if GenJnlLine."Withholding Tax Payment" then
                exit;

            if not WHTUsed then begin
                PurchTaxCrMemoHeader.Init();
                PurchTaxCrMemoHeader.TransferFieldsFrom(PurchCrMemoHeader);
                PurchTaxCrMemoHeader."Posting Date" := GenJnlLine."Posting Date";
                PurchTaxCrMemoHeader."Posting Description" := GenJnlLine."Document No.";
                PurchTaxCrMemoLine."External Document No." := PurchCrMemoHeader."No.";
                PurchTaxCrMemoHeader."No." := '';
                PurchTaxCrMemoHeader.Insert(true);
            end;

            PurchCrMemoLine.Reset();
            PurchCrMemoLine.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
            if PurchCrMemoLine.FindSet() then
                repeat
                    Payment1 := 0;
                    Payment2 := 0;

                    PurchTaxCrMemoHeader.SetRange("Posting Description", GenJnlLine."Document No.");
                    if PurchTaxCrMemoHeader.FindFirst() then begin
                        PurchTaxCrMemoLine.Reset();
                        PurchTaxCrMemoLine.SetRange("Document No.", PurchTaxCrMemoHeader."No.");
                        if PurchTaxCrMemoLine.FindLast() then
                            LineNo := PurchTaxCrMemoLine."Line No." + 10000;
                    end;

                    if LineNo = 0 then
                        LineNo := 10000;

                    VendLedgEntry.Reset();
                    VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::"Credit Memo");
                    VendLedgEntry.SetRange("Document No.", PurchCrMemoLine."Document No.");
                    if VendLedgEntry.FindFirst() then begin
                        VendLedgEntry.CalcFields("Amount (LCY)", "Remaining Amt. (LCY)", Amount, "Remaining Amount");

                        PurchTaxCrMemoLine.Init();
                        if VATPostingSetup.Get(PurchCrMemoLine."VAT Bus. Posting Group", PurchCrMemoLine."VAT Prod. Posting Group") then
                            if VATPostingSetup."Unrealized VAT Type" <> VATPostingSetup."Unrealized VAT Type"::" " then begin
                                PurchTaxCrMemoLine.TransferFieldsFrom(PurchCrMemoLine);
                                PurchTaxCrMemoLine."Line No." := LineNo;
                                PurchTaxCrMemoLine."Document No." := PurchTaxCrMemoHeader."No.";
                                PurchTaxCrMemoLine."External Document No." := PurchCrMemoHeader."No.";
                                WHTAmount := 0;
                                WHTAmount1 := 0;
                                WithholdingTaxEntry.Reset();
                                WithholdingTaxEntry.SetRange("Document No.", PurchCrMemoHeader."No.");
                                WithholdingTaxEntry.SetFilter("Applies-to Entry No.", '%1', 0);
                                if WithholdingTaxEntry.FindSet() then
                                    repeat
                                        WHTAmount1 := WHTAmount1 + WithholdingTaxEntry."Unrealized Amount (LCY)";
                                    until WithholdingTaxEntry.Next() = 0;

                                WHTAmount := WHTAmount - WHTAmount1;

                                GLSetup.Get();
                                if GLSetup."Manual Sales Wthldg. Tax Calc." then begin
                                    if not GenJnlLine."Withholding Tax Payment" then begin
                                        if (GenJnlLine."Posting Date" <= VendLedgEntry."Pmt. Discount Date") and
                                           ((Abs(GenJnlLine.Amount) + Abs(WHTAmount)) >= (Abs(VendLedgEntry."WHT Rem. Amt") -
                                                                                          Abs(VendLedgEntry."Original Pmt. Disc. Possible"))) and
                                           (not AmountWithDisc)
                                        then
                                            GenLineAmount := GenJnlLine.Amount - VendLedgEntry."Original Pmt. Disc. Possible"
                                        else
                                            GenLineAmount := GenJnlLine.Amount;

                                        ExpectedAmount := -VendLedgEntry.Amount + WHTAmount;
                                    end;
                                end else begin
                                    if (GenJnlLine."Posting Date" <= VendLedgEntry."Pmt. Discount Date") and
                                       (Abs(GenJnlLine.Amount) >= (Abs(VendLedgEntry."WHT Rem. Amt") -
                                                                   Abs(VendLedgEntry."Original Pmt. Disc. Possible"))) and (not AmountWithDisc)
                                    then
                                        GenLineAmount := GenJnlLine.Amount - VendLedgEntry."Original Pmt. Disc. Possible"
                                    else
                                        GenLineAmount := GenJnlLine.Amount;

                                    ExpectedAmount := -VendLedgEntry.Amount;
                                end;
                                PurchTaxCrMemoLine."Paid Amount Incl. VAT" := Round(Abs(GenLineAmount) *
                                    PurchCrMemoLine."Amount Including VAT" / ExpectedAmount);
                                PurchTaxCrMemoLine."Paid VAT" := Round(Abs(GenLineAmount)
                                    * (PurchCrMemoLine."Amount Including VAT" - PurchCrMemoLine."VAT Base Amount")
                                    / ExpectedAmount);

                                if PurchTaxCrMemoLine."Paid VAT" <> 0 then
                                    PurchTaxCrMemoLine.Insert();

                                LineNo := LineNo + 10000;
                            end;
                    end;
                until PurchCrMemoLine.Next() = 0;
        end;

        InvNo := PurchTaxCrMemoHeader."No.";
        PurchCrMemoHeader."WHT Printed Tax Document" := true;
        PurchCrMemoHeader.Modify();
    end;

    procedure BuildTaxPostBuffer(SourceNo: Code[20]; OrigNo: Text[30]; Type: Option "Purchase Invoice","Sales Invoice","Purchase Credit Memo","Sales Credit Memo")
    var
        TaxPostBuffer: Record "Withholding Tax Posting Buffer";
    begin
        TaxPostBuffer.DeleteAll();
        TaxPostBuffer.Init();
        TaxPostBuffer."Tax Invoice No." := SourceNo;
        TaxPostBuffer."Invoice No." := OrigNo;
        case Type of
            Type::"Purchase Invoice":
                TaxPostBuffer.Type := TaxPostBuffer.Type::"Purchase Invoice";
            Type::"Sales Invoice":
                TaxPostBuffer.Type := TaxPostBuffer.Type::"Sales Invoice";
            Type::"Purchase Credit Memo":
                TaxPostBuffer.Type := TaxPostBuffer.Type::"Purchase Credit Memo";
            Type::"Sales Credit Memo":
                TaxPostBuffer.Type := TaxPostBuffer.Type::"Sales Credit Memo";
        end;
        TaxPostBuffer.Insert();
    end;

    procedure PrintTaxInvoices(ScheduleInJobQueue: Boolean)
    var
        TaxInvBuffer: Record "Withholding Tax Posting Buffer";
        ReportSelection: Record "Report Selections";
        PurchSetup: Record "Purchases & Payables Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        BatchPostingPrintMgt: Codeunit "Batch Posting Print Mgt.";
    begin
        GLSetup.Get();

        if not GLSetup."WHT Print Tax Inv. on Posting" then
            exit;

        PurchSetup.Get();
        SalesSetup.Get();

        LastTaxInvoice := '';
        Commit();

        TaxInvBuffer.Reset();
        TaxInvBuffer.SetRange(Type, TaxInvBuffer.Type::"Purchase Invoice");
        if TaxInvBuffer.FindSet() then
            repeat
                if TaxInvBuffer."Tax Invoice No." <> LastTaxInvoice then begin
                    PurchTaxInvoiceHeader.Reset();
                    PurchTaxInvoiceHeader.SetRange("No.", TaxInvBuffer."Tax Invoice No.");
                    if PurchTaxInvoiceHeader.FindFirst() then begin
                        ReportSelection.Reset();
                        ReportSelection.SetRange(Usage, ReportSelection.Usage::"P. Withholding Tax Invoice");
                        if ReportSelection.FindSet() then
                            repeat
                                if ScheduleInJobQueue then
                                    BatchPostingPrintMgt.SchedulePrintJobQueueEntry(PurchTaxInvoiceHeader, ReportSelection."Report ID", GLSetup."Report Output Type".AsInteger())
                                else
                                    REPORT.Run(ReportSelection."Report ID", PurchSetup."WHT Print Dialog", false, PurchTaxInvoiceHeader);
                            until ReportSelection.Next() = 0;
                    end;
                end;
                LastTaxInvoice := TaxInvBuffer."Tax Invoice No.";
            until TaxInvBuffer.Next() = 0;

        LastTaxInvoice := '';

        TaxInvBuffer.Reset();
        TaxInvBuffer.SetRange(Type, TaxInvBuffer.Type::"Purchase Credit Memo");
        if TaxInvBuffer.FindSet() then
            repeat
                if TaxInvBuffer."Tax Invoice No." <> LastTaxInvoice then begin
                    PurchTaxCrMemoHeader.Reset();
                    PurchTaxCrMemoHeader.SetRange("No.", TaxInvBuffer."Tax Invoice No.");
                    if PurchTaxCrMemoHeader.FindFirst() then begin
                        ReportSelection.Reset();
                        ReportSelection.SetRange(Usage, ReportSelection.Usage::"P. Withholding Tax Credit Memo");
                        if ReportSelection.FindSet() then
                            repeat
                                if ScheduleInJobQueue then
                                    BatchPostingPrintMgt.SchedulePrintJobQueueEntry(PurchTaxCrMemoHeader, ReportSelection."Report ID", GLSetup."Report Output Type".AsInteger())
                                else
                                    REPORT.Run(ReportSelection."Report ID", PurchSetup."WHT Print Dialog", false, PurchTaxCrMemoHeader);
                            until ReportSelection.Next() = 0;
                    end;
                end;

                LastTaxInvoice := TaxInvBuffer."Tax Invoice No.";
            until TaxInvBuffer.Next() = 0;
    end;

    procedure CheckPmtDisc(PostingDate: Date; PmtDiscDate: Date; Amount1: Decimal; Amount2: Decimal; Amount3: Decimal; Amount4: Decimal): Boolean
    begin
        if (PostingDate <= PmtDiscDate) and (Amount1 >= (Amount2 - Amount3)) and (Amount4 >= (Amount2 - Amount3)) then
            exit(true);

        exit(false);
    end;

    procedure CheckTaxableNoSeries("No.": Code[20]; "Vend/Cust": Option Vendor,Customer): Boolean
    var
        Vendor: Record Vendor;
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        case "Vend/Cust" of
            "Vend/Cust"::Vendor:
                begin
                    Vendor.Reset();
                    Vendor.SetFilter("No.", "No.");
                    if Vendor.FindFirst() then
                        VendorPostingGroup.SetFilter(Code, Vendor."Vendor Posting Group");
                    if VendorPostingGroup.FindFirst() then
                        exit(VendorPostingGroup."WHT Non-Taxable");
                end;
        end;
    end;

    local procedure ReverseGetNextNo(NoSeriesCode: Code[20]; SeriesDate: Date): Code[20]
    var
        NoSeriesLine: Record "No. Series Line";
        NoSeries: Record "No. Series";
        NoSeriesCodeunit: Codeunit "No. Series";
    begin
        if SeriesDate = 0D then
            SeriesDate := WorkDate();

        NoSeriesLine.LockTable();
        NoSeries.Get(NoSeriesCode);
        if not NoSeriesCodeunit.GetNoSeriesLine(NoSeriesLine, NoSeriesCode, SeriesDate, false) then begin
            NoSeriesLine.SetRange("Starting Date");
            if NoSeriesLine.FindSet() then
                Error(CannotAssignNewOnDateErr, NoSeriesCode, SeriesDate);
            Error(CannotAssignNewErr, NoSeriesCode);
        end;

        NoSeriesLine.TestField(Implementation, "No. Series Implementation"::Normal);

        if NoSeries."Date Order" and (SeriesDate < NoSeriesLine."Last Date Used") then
            Error(CannotAssignNewBeforeDateErr, NoSeries.Code, NoSeriesLine."Last Date Used");

        NoSeriesLine."Last Date Used" := SeriesDate;

        if NoSeriesLine."Last No. Used" = '' then begin
            NoSeriesLine.TestField("Starting No.");
            NoSeriesLine."Last No. Used" := NoSeriesLine."Starting No.";
        end else
            NoSeriesLine."Last No. Used" := IncStr(NoSeriesLine."Last No. Used", -NoSeriesLine."Increment-by No.");

        if (NoSeriesLine."Ending No." <> '') and (NoSeriesLine."Last No. Used" > NoSeriesLine."Ending No.") then
            Error(CannotAssignGreaterErr, NoSeriesLine."Ending No.", NoSeriesCode);

        if (NoSeriesLine."Ending No." <> '') and (NoSeriesLine."Warning No." <> '') and (NoSeriesLine."Last No. Used" >= NoSeriesLine."Warning No.") and (NoSeriesCode <> WarningNoSeriesCode) then begin
            WarningNoSeriesCode := NoSeriesCode;
            Message(CannotAssignGreaterErr, NoSeriesLine."Ending No.", NoSeriesCode);
        end;

        NoSeriesLine.Validate(Open);

        NoSeriesLine.Modify();
        exit(NoSeriesLine."Last No. Used");
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

    procedure InitTextVariableTH()
    begin
        OnesText[1] := NuengLbl;
        OnesText[2] := SawngLbl;
        OnesText[3] := SarmLbl;
        OnesText[4] := SiLbl;
        OnesText[5] := HaLbl;
        OnesText[6] := HokLbl;
        OnesText[7] := ChedLbl;
        OnesText[8] := PaedLbl;
        OnesText[9] := KowLbl;
        OnesText[10] := SibLbl;
        OnesText[11] := SibEdLbl;
        OnesText[12] := SibSawngLbl;
        OnesText[13] := SibSarmLbl;
        OnesText[14] := SibSiLbl;
        OnesText[15] := SibHaLbl;
        OnesText[16] := SibHokLbl;
        OnesText[17] := SibChedLbl;
        OnesText[18] := SibPaedLbl;
        OnesText[19] := SibKowLbl;

        TensText[1] := '';
        TensText[2] := YiSibLbl;
        TensText[3] := SarmSibLbl;
        TensText[4] := SiSibLbl;
        TensText[5] := HaSibLbl;
        TensText[6] := HokSibLbl;
        TensText[7] := ChedSibLbl;
        TensText[8] := PaedSibLbl;
        TensText[9] := KowSibLbl;

        ExponentText[1] := '';
        ExponentText[2] := PhanLbl;
        ExponentText[3] := LaanLbl;
        ExponentText[4] := PhaanLaanLbl;
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

    procedure FormatNoTextTH(var NoText: array[2] of Text[80]; No: Decimal; CurrencyCode: Code[10])
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