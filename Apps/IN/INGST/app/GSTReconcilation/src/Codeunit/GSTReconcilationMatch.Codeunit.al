// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Reconcilation;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;

codeunit 18280 "GST Reconcilation Match"
{
    var
        GSTTolarance: Decimal;
        Window: Dialog;
        PostedGSTReconErr: Label 'Reconciliation has been already done for GSTIN No. %1,Month %2,Year %3.', Comment = 'Reconciliation has been already done for GSTIN No. %1,Month %2,Year %3.';
        NotReconcileMsg: Label 'No records to reconcile.';
        ReconciledMsg: Label 'Records has been reconciled.';
        ReconRecMsg: Label 'Reconciling Records.';
        ReconciledWithLedgerMsg: Label 'Records has been reconciled with ledger entries.';
        SettlementErr: Label 'GST Settlement has been already done for the given Month %1 and Year %2 for GST Registration No. %3.', Comment = 'GST Settlement has been already done for the given Month %1 and Year %2 for GST Registration No. %3';
        GSTReconMapErr: Label 'GST Recon Mapping must have setup for all components defined in the Retrun & Reco. Components Page';
        ReconLineMsg: Label 'GST Reconcile Line.';
        GSTCrAdjFilterErr: Label 'Filter Criteria is not matching with Detailed GST Ledger Entry.';
        TaxableValErr: Label 'Taxable Value is not Matching with GSTR-2A Data.';
        WindowUpdateMsg: Label '%1,%2', Comment = '%1=GSTIN No. ,%2= External Document No.';

    procedure CalculateMonth(CalMonth: Integer; CalYear: Integer): Date
    begin
        exit(CalcDate('<CM>', DMY2Date(1, CalMonth, CalYear)));
    end;

    procedure CheckMandatoryFields(GSTReconcilation: Record "GST Reconcilation")
    begin
        GSTReconcilation.TestField("GSTIN No.");
        GSTReconcilation.TestField(Month);
        GSTReconcilation.TestField(Year);
        GSTReconcilation.TestField("Posting Date");
    end;

    procedure CheckPostedGSTReconiliation(GSTINNo: Code[20]; InputMonth: Integer; InputYear: Integer)
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        DetailedGSTLedgerEntry.SetCurrentKey(
            "Location  Reg. No.",
            Reconciled,
            "Reconciliation Month",
            "Reconciliation Year");
        DetailedGSTLedgerEntry.SetRange("Location  Reg. No.", GSTINNo);
        DetailedGSTLedgerEntry.SetRange(Reconciled, true);
        DetailedGSTLedgerEntry.SetRange("Reconciliation Month", InputMonth);
        DetailedGSTLedgerEntry.SetRange("Reconciliation Year", InputYear);
        if not DetailedGSTLedgerEntry.IsEmpty() then
            Error(PostedGSTReconErr, GSTINNo, InputMonth, InputYear);
    end;

    procedure ReconcileWithGSTR2AData(GSTRegNo: Code[20]; Month: Integer; Year: Integer; PostingDate: Date)
    var
        PeriodicGSTR2AData: Record "Periodic GSTR-2A Data";
        GSTReconcilationLines: Record "GST Reconcilation Line";
        GSTReconcilationLines2: Record "GST Reconcilation Line";
    begin
        Window.Open('#1#################################\\' + ReconRecMsg);
        GSTReconcilationLines.SetRange("GSTIN No.", GSTRegNo);
        GSTReconcilationLines.SetRange(Month, Month);
        GSTReconcilationLines.SetRange(Year, Year);
        if GSTReconcilationLines.FindFirst() then
            Report.RunModal(Report::"GST Recon. Match Periodic Data", false, false, GSTReconcilationLines);
        Window.Close();

        GSTReconcilationLines2.CopyFilters(GSTReconcilationLines);
        GSTReconcilationLines2.SetRange(Reconciled, true);
        if GSTReconcilationLines2.Count() >= 1 then begin
            GSTReconcilationLines2.ModifyAll("Error Type", '');
            GSTReconcilationLines2.ModifyAll("Reconciliation Date", PostingDate);
            GSTReconcilationLines2.ModifyAll("User Id", UserId());
            Message(ReconciledMsg);
        end else
            Message(NotReconcileMsg);
        PeriodicGSTR2AData.SetRange("GSTIN No.", GSTReconcilationLines."GSTIN No.");
        PeriodicGSTR2AData.SetRange(Month, GSTReconcilationLines.Month);
        PeriodicGSTR2AData.SetRange(Year, GSTReconcilationLines.Year);
        PeriodicGSTR2AData.SetRange(Matched, PeriodicGSTR2AData.Matched::" ");
        PeriodicGSTR2AData.ModifyAll(Matched, PeriodicGSTR2AData.Matched::"No Line");
    end;

    procedure UpdateGSTReconcilationLine(GSTRegNo: Code[20]; GSTMonth: Integer; GSTYear: Integer)
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntry2: array[8] of Record "Detailed GST Ledger Entry";
        GSTReconcilationLines: Record "GST Reconcilation Line";
        GSTReconcilationLines2: Record "GST Reconcilation Line";
        GSTReconMapping: Record "GST Recon. Mapping";
        GSTReconcilationLines3: array[8] of Record "GST Reconcilation Line";
        RecoSettlement: Record "Retrun & Reco. Components";
    begin
        GSTReconMapping.Reset();
        GSTReconMapping.SetFilter("GST Reconciliation Field No.", '<>%1', 0);
        if RecoSettlement.Count() <> GSTReconMapping.Count() then
            Error(GSTReconMapErr);
        begin
            DetailedGSTFilterWithReconciliation(DetailedGSTLedgerEntry, GSTRegNo, GSTMonth, GSTYear);
            if DetailedGSTLedgerEntry.FindSet() then begin
                Window.Open('#1#################################\\' + ReconLineMsg);
                repeat
                    GSTReconcilationLines2.SetRange("Document No.", DetailedGSTLedgerEntry."Document No.");
                    if GSTReconcilationLines2.IsEmpty() then
                        InsertGSTReconLines(
                            GSTReconcilationLines,
                            DetailedGSTLedgerEntry,
                            GSTRegNo,
                            GSTMonth,
                            GSTYear);

                    Window.Update(1, StrSubstNo(
                        WindowUpdateMsg,
                        GSTReconcilationLines."GSTIN No.",
                        GSTReconcilationLines."External Document No."));

                    GSTReconMapping.SetRange("GST Component Code", DetailedGSTLedgerEntry."GST Component Code");
                    if GSTReconMapping.FindFirst() then
                        case GSTReconMapping."GST Reconciliation Field No." of
                            GSTReconcilationLines.FieldNo("Component 1 Amount"):
                                ExtEndedUpdateGSTRecon(
                                    GSTReconcilationLines3[1],
                                    DetailedGSTLedgerEntry2[1],
                                    GSTReconcilationLines,
                                    DetailedGSTLedgerEntry,
                                    GSTReconMapping);
                            GSTReconcilationLines.FieldNo("Component 2 Amount"):
                                ExtEndedUpdateGSTRecon(
                                    GSTReconcilationLines3[2],
                                    DetailedGSTLedgerEntry2[2],
                                    GSTReconcilationLines,
                                    DetailedGSTLedgerEntry,
                                    GSTReconMapping);
                            GSTReconcilationLines.FieldNo("Component 3 Amount"):
                                ExtEndedUpdateGSTRecon(
                                    GSTReconcilationLines3[3],
                                    DetailedGSTLedgerEntry2[3],
                                    GSTReconcilationLines,
                                    DetailedGSTLedgerEntry,
                                    GSTReconMapping);
                            GSTReconcilationLines.FieldNo("Component 4 Amount"):
                                ExtEndedUpdateGSTRecon(
                                    GSTReconcilationLines3[4],
                                    DetailedGSTLedgerEntry2[4],
                                    GSTReconcilationLines,
                                    DetailedGSTLedgerEntry,
                                    GSTReconMapping);
                            GSTReconcilationLines.FieldNo("Component 5 Amount"):
                                ExtEndedUpdateGSTRecon(
                                    GSTReconcilationLines3[5],
                                    DetailedGSTLedgerEntry2[5],
                                    GSTReconcilationLines,
                                    DetailedGSTLedgerEntry,
                                    GSTReconMapping);
                            GSTReconcilationLines.FieldNo("Component 6 Amount"):
                                ExtEndedUpdateGSTRecon(
                                    GSTReconcilationLines3[6],
                                    DetailedGSTLedgerEntry2[6],
                                    GSTReconcilationLines,
                                    DetailedGSTLedgerEntry,
                                    GSTReconMapping);
                            GSTReconcilationLines.FieldNo("Component 7 Amount"):
                                ExtEndedUpdateGSTRecon(
                                    GSTReconcilationLines3[7],
                                    DetailedGSTLedgerEntry2[7],
                                    GSTReconcilationLines,
                                    DetailedGSTLedgerEntry,
                                    GSTReconMapping);
                            GSTReconcilationLines.FieldNo("Component 8 Amount"):
                                ExtEndedUpdateGSTRecon(
                                    GSTReconcilationLines3[8],
                                    DetailedGSTLedgerEntry2[8],
                                    GSTReconcilationLines,
                                    DetailedGSTLedgerEntry,
                                    GSTReconMapping);
                        end;
                until DetailedGSTLedgerEntry.Next() = 0;
            end else
                Error(GSTCrAdjFilterErr);
        end;

        Window.Close();
    end;

    procedure PreparePostGSTReconcilation(GSTRegNo: Code[20]; PostingDate: Date; PostMonth: Integer; PostYear: Integer)
    begin
        UpdateDetailedGSTLedgerEntryAfterRecon(GSTRegNo, PostMonth, PostYear);
        UpdateGST2ADataAfterPosting(GSTRegNo, PostMonth, PostYear, PostingDate);
        DeleteGSTReconcilationLine(GSTRegNo, PostMonth, PostYear);
        Message(ReconciledWithLedgerMsg);
    end;

    procedure UpdateDetailedGSTLedgerEntryAfterRecon(GSTRegNo: Code[20]; PostingMonth: Integer; PostingYear: Integer)
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTReconcilationLines: Record "GST Reconcilation Line";
    begin
        GSTReconcilationLines.SetCurrentKey("GSTIN No.", Reconciled, "Credit Availed", Month, Year);
        GSTReconcilationLines.SetRange("GSTIN No.", GSTRegNo);
        GSTReconcilationLines.SetRange(Reconciled, true);
        GSTReconcilationLines.SetRange(Month, PostingMonth);
        GSTReconcilationLines.SetRange(Year, PostingYear);
        if GSTReconcilationLines.FindSet() then
            repeat
                DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
                if GSTReconcilationLines."Document Type" = GSTReconcilationLines."Document Type"::Invoice then
                    DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice)
                else
                    DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::"Credit Memo");
                DetailedGSTLedgerEntry.SetRange("Document No.", GSTReconcilationLines."Document No.");
                DetailedGSTLedgerEntry.SetRange("GST Exempted Goods", false);
                if DetailedGSTLedgerEntry.FindSet() then
                    repeat
                        DetailedGSTLedgerEntry.Reconciled := true;
                        DetailedGSTLedgerEntry."Reconciliation Month" := GSTReconcilationLines.Month;
                        DetailedGSTLedgerEntry."Reconciliation Year" := GSTReconcilationLines.Year;
                        DetailedGSTLedgerEntry.Modify(true);
                    until DetailedGSTLedgerEntry.Next() = 0;
            until GSTReconcilationLines.Next() = 0;
    end;

    procedure CheckSettlement(GSTINNo: Code[20]; RecMonth: Integer; RecYear: Integer)
    var
        PostedGSTReconciliation: Record "Posted GST Reconciliation";
    begin
        PostedGSTReconciliation.SetCurrentKey("GSTIN No.", "Reconciliation Month", "Reconciliation Year", "Source Type");
        PostedGSTReconciliation.SetRange("GSTIN No.", GSTINNo);
        PostedGSTReconciliation.SetRange("Reconciliation Month", RecMonth);
        PostedGSTReconciliation.SetRange("Reconciliation Year", RecYear);
        PostedGSTReconciliation.SetRange("Source Type", PostedGSTReconciliation."Source Type"::Settlement);
        if not PostedGSTReconciliation.IsEmpty() then
            Error(SettlementErr, RecMonth, RecYear, GSTINNo);
    end;

    procedure ValidateCompAmtWithPeriodicData(
        var GSTReconcilationLine: Record "GST Reconcilation Line";
        var PeriodicGSTR2AData: Record "Periodic GSTR-2A Data"): Boolean
    var
        GenLedgerSetup: Record "General Ledger Setup";
    begin
        GenLedgerSetup.Get();
        GSTTolarance := GenLedgerSetup."GST Recon. Tolerance";
        begin
            if (GSTReconcilationLine."Taxable Value" > PeriodicGSTR2AData."Taxable Value" + GSTTolarance) or
               (GSTReconcilationLine."Taxable Value" < PeriodicGSTR2AData."Taxable Value" - GSTTolarance)
            then
                GSTReconcilationLine."Error Type" := TaxableValErr;

            if GSTReconcilationLine."Component 1 Amount" <> 0 then
                UpdateErrorTypeForCompAmt(
                    GSTReconcilationLine,
                    PeriodicGSTR2AData."Component 1 Amount",
                    GSTReconcilationLine."Component 1 Amount",
                    GSTTolarance,
                    GSTReconcilationLine.FieldNo("Component 1 Amount"));
            if GSTReconcilationLine."Component 2 Amount" <> 0 then
                UpdateErrorTypeForCompAmt(
                    GSTReconcilationLine,
                    PeriodicGSTR2AData."Component 2 Amount",
                    GSTReconcilationLine."Component 2 Amount",
                    GSTTolarance,
                    GSTReconcilationLine.FieldNo("Component 2 Amount"));
            if GSTReconcilationLine."Component 3 Amount" <> 0 then
                UpdateErrorTypeForCompAmt(
                    GSTReconcilationLine,
                    PeriodicGSTR2AData."Component 3 Amount",
                    GSTReconcilationLine."Component 3 Amount",
                    GSTTolarance,
                    GSTReconcilationLine.FieldNo("Component 3 Amount"));
            if GSTReconcilationLine."Component 4 Amount" <> 0 then
                UpdateErrorTypeForCompAmt(
                    GSTReconcilationLine,
                    PeriodicGSTR2AData."Component 4 Amount",
                    GSTReconcilationLine."Component 4 Amount",
                    GSTTolarance,
                    GSTReconcilationLine.FieldNo("Component 4 Amount"));
            if GSTReconcilationLine."Component 5 Amount" <> 0 then
                UpdateErrorTypeForCompAmt(
                    GSTReconcilationLine,
                    PeriodicGSTR2AData."Component 5 Amount",
                    GSTReconcilationLine."Component 5 Amount",
                    GSTTolarance,
                    GSTReconcilationLine.FieldNo("Component 5 Amount"));
            if GSTReconcilationLine."Component 6 Amount" <> 0 then
                UpdateErrorTypeForCompAmt(
                    GSTReconcilationLine,
                    PeriodicGSTR2AData."Component 6 Amount",
                    GSTReconcilationLine."Component 6 Amount",
                    GSTTolarance,
                    GSTReconcilationLine.FieldNo("Component 6 Amount"));
            if GSTReconcilationLine."Component 7 Amount" <> 0 then
                UpdateErrorTypeForCompAmt(
                    GSTReconcilationLine,
                    PeriodicGSTR2AData."Component 7 Amount",
                    GSTReconcilationLine."Component 7 Amount",
                    GSTTolarance,
                    GSTReconcilationLine.FieldNo("Component 7 Amount"));
            if GSTReconcilationLine."Component 8 Amount" <> 0 then
                UpdateErrorTypeForCompAmt(
                    GSTReconcilationLine,
                    PeriodicGSTR2AData."Component 8 Amount",
                    GSTReconcilationLine."Component 8 Amount",
                    GSTTolarance,
                    GSTReconcilationLine.FieldNo("Component 8 Amount"));
        end;

        if GSTReconcilationLine."Error Type" = '' then
            exit(true);
    end;

    local procedure DeleteGSTReconcilationLine(GSTINNo: Code[20]; GSTMonth: Integer; GSTYear: Integer)
    var
        GSTReconcilationLines: Record "GST Reconcilation Line";
        GSTReconcilation: Record "GST Reconcilation";
    begin
        GSTReconcilationLines.SetRange("GSTIN No.", GSTINNo);
        GSTReconcilationLines.SetRange(Month, GSTMonth);
        GSTReconcilationLines.SetRange(Year, GSTYear);
        GSTReconcilationLines.DeleteAll();
        if GSTReconcilation.Get(GSTINNo, GSTMonth, GSTYear) then
            GSTReconcilation.DeleteAll();
    end;

    local procedure UpdateGST2ADataAfterPosting(
        GSTRegNo: Code[20];
        PostingMonth: Integer;
        PostingYear: Integer;
        RecoPostingDate: Date)
    var
        GSTReconcilationLines: Record "GST Reconcilation Line";
        PeriodicGSTR2AData: Record "Periodic GSTR-2A Data";
    begin
        GSTReconcilationLines.SetCurrentKey("GSTIN No.", Reconciled, "Credit Availed", Month, Year);
        GSTReconcilationLines.SetRange("GSTIN No.", GSTRegNo);
        GSTReconcilationLines.SetRange(Reconciled, true);
        GSTReconcilationLines.SetRange(Month, PostingMonth);
        GSTReconcilationLines.SetRange(Year, PostingYear);
        if GSTReconcilationLines.FindSet() then
            repeat
                PeriodicGSTR2AData.SetRange("GSTIN No.", GSTReconcilationLines."GSTIN No.");
                PeriodicGSTR2AData.SetRange(Month, GSTReconcilationLines.Month);
                PeriodicGSTR2AData.SetRange(Year, GSTReconcilationLines.Year);
                PeriodicGSTR2AData.SetRange("Document No.", GSTReconcilationLines."External Document No.");
                PeriodicGSTR2AData.SetRange("HSN/SAC", GSTReconcilationLines."HSN/SAC");
                PeriodicGSTR2AData.SetRange("Component 1 Amount", GSTReconcilationLines."Component 1 Amount");
                PeriodicGSTR2AData.SetRange("Component 2 Amount", GSTReconcilationLines."Component 2 Amount");
                PeriodicGSTR2AData.SetRange("Component 3 Amount", GSTReconcilationLines."Component 3 Amount");
                PeriodicGSTR2AData.SetRange("Component 1 Amount", GSTReconcilationLines."Component 4 Amount");
                PeriodicGSTR2AData.SetRange("Component 2 Amount", GSTReconcilationLines."Component 5 Amount");
                PeriodicGSTR2AData.SetRange("Component 3 Amount", GSTReconcilationLines."Component 6 Amount");
                PeriodicGSTR2AData.SetRange("Component 1 Amount", GSTReconcilationLines."Component 7 Amount");
                PeriodicGSTR2AData.SetRange("Component 2 Amount", GSTReconcilationLines."Component 8 Amount");
                if PeriodicGSTR2AData.FindFirst() then begin
                    PeriodicGSTR2AData.Reconciled := true;
                    PeriodicGSTR2AData."Reconciliation Date" := RecoPostingDate;
                    PeriodicGSTR2AData.Modify(true);
                end;
            until GSTReconcilationLines.Next() = 0;
    end;

    local procedure DetailedGSTFilterWithReconciliation(
        var DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTRegNo: Code[20];
        GSTMonth: Integer;
        GSTYear: Integer)
    begin
        DetailedGSTLedgerEntry.SetCurrentKey(
          "Entry Type",
          "Transaction Type",
          "Location  Reg. No.",
          "Document Type",
          Reconciled,
          "GST VEndor Type",
          Reversed,
          "Posting Date",
          Paid,
          "Credit Adjustment Type");

        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
        DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
        DetailedGSTLedgerEntry.SetRange("Location  Reg. No.", GSTRegNo);
        DetailedGSTLedgerEntry.SetFilter("Document Type", '%1|%2', DetailedGSTLedgerEntry."Document Type"::Invoice, DetailedGSTLedgerEntry."Document Type"::"Credit Memo");
        DetailedGSTLedgerEntry.SetRange(Reconciled, false);
        DetailedGSTLedgerEntry.SetRange("GST VEndor Type", "GST VEndor Type"::Registered);
        DetailedGSTLedgerEntry.SetRange(Reversed, false);
        DetailedGSTLedgerEntry.SetFilter("Posting Date", '<=%1', CalculateMonth(GSTMonth, GSTYear));
        DetailedGSTLedgerEntry.SetRange(Paid, false);
        DetailedGSTLedgerEntry.SetFilter("Credit Adjustment Type", '<>%1', "Credit Adjustment Type"::"Permanent Reversal");
        DetailedGSTLedgerEntry.SetRange("GST Exempted Goods", false);
    end;

    local procedure InsertGSTReconLines(
        var GSTReconcilationLine: Record "GST Reconcilation Line";
        var DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTRegNo: Code[20];
        GSTMonth: Integer;
        GSTYear: Integer)
    var
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        GSTRegistrationNos: Record "GST Registration Nos.";
    begin
        if DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.") then
            GSTReconcilationLine."State Code" := DetailedGSTLedgerEntryInfo."Location State Code";

        GSTReconcilationLine."GSTIN No." := GSTRegNo;
        GSTReconcilationLine.Month := GSTMonth;
        GSTReconcilationLine.Year := GSTYear;
        if DetailedGSTLedgerEntry."Document Type" = DetailedGSTLedgerEntry."Document Type"::Invoice then
            GSTReconcilationLine."Document Type" := GSTReconcilationLine."Document Type"::Invoice
        else
            GSTReconcilationLine."Document Type" := GSTReconcilationLine."Document Type"::"Credit Note";

        GSTReconcilationLine."GSTIN of Supplier" := DetailedGSTLedgerEntry."Buyer/Seller Reg. No.";
        GSTReconcilationLine."Document No." := DetailedGSTLedgerEntry."Document No.";
        GSTReconcilationLine."Document Date" := DetailedGSTLedgerEntry."Posting Date";
        GSTReconcilationLine."Goods/Services" := DetailedGSTLedgerEntry."GST group type";
        GSTReconcilationLine."External Document No." := DetailedGSTLedgerEntry."External Document No.";
        if DetailedGSTLedgerEntry."GST Credit" = DetailedGSTLedgerEntry."GST Credit"::Availment then
            GSTReconcilationLine."GST Credit" := GSTReconcilationLine."GST Credit"::Availment;

        if DetailedGSTLedgerEntry."GST Credit" = DetailedGSTLedgerEntry."GST Credit"::"Non-Availment" then
            GSTReconcilationLine."GST Credit" := GSTReconcilationLine."GST Credit"::"Non-Availment";

        GSTReconcilationLine."Credit Availed" := DetailedGSTLedgerEntry."Credit Availed";
        GSTRegistrationNos.Get(GSTRegNo);
        GSTReconcilationLine."Input Service Distribution" := GSTRegistrationNos."Input Service Distributor";
        GSTReconcilationLine.Insert(true);
    end;

    local procedure ExtEndedUpdateGSTRecon(
        var GSTReconcilationLine2: Record "GST Reconcilation Line";
        var DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        var GSTReconcilationLine: Record "GST Reconcilation Line";
        var DetailedGSTLedgerEntry2: Record "Detailed GST Ledger Entry";
        GSTReconMapping: Record "GST Recon. Mapping")
    begin
        if GSTReconcilationLine2.Get(
            GSTReconcilationLine."GSTIN No.",
            GSTReconcilationLine."State Code",
            GSTReconcilationLine.Month,
            GSTReconcilationLine.Year,
            GSTReconcilationLine."Document No.")
        then begin
            DetailedGSTLedgerEntry.CopyFilters(DetailedGSTLedgerEntry2);
            DetailedGSTLedgerEntry.SetCurrentKey("Document No.", "GST Component Code", "HSN/SAC Code");
            DetailedGSTLedgerEntry.SetRange("Document No.", GSTReconcilationLine."Document No.");
            DetailedGSTLedgerEntry.SetRange("GST Component Code", GSTReconMapping."GST Component Code");
            if DetailedGSTLedgerEntry.FindFirst() then begin
                DetailedGSTLedgerEntry.CalcSums("GST Amount");
                DetailedGSTLedgerEntry.CalcSums("GST Base Amount");
                case GSTReconMapping."GST Reconciliation Field No." of
                    GSTReconcilationLine.FieldNo("Component 1 Amount"):
                        begin
                            GSTReconcilationLine2."Taxable Value" := DetailedGSTLedgerEntry."GST Base Amount";
                            GSTReconcilationLine2."Component 1 Rate" := DetailedGSTLedgerEntry."GST %";
                            GSTReconcilationLine2."Component 1 Amount" := DetailedGSTLedgerEntry."GST Amount";
                            GSTReconcilationLine2."Component 1 Avl. Amount" := CalculateAvailmentAmount(DetailedGSTLedgerEntry);
                        end;
                    GSTReconcilationLine.FieldNo("Component 2 Amount"):
                        begin
                            GSTReconcilationLine2."Taxable Value" := DetailedGSTLedgerEntry."GST Base Amount";
                            GSTReconcilationLine2."Component 2 Rate" := DetailedGSTLedgerEntry."GST %";
                            GSTReconcilationLine2."Component 2 Amount" := DetailedGSTLedgerEntry."GST Amount";
                            GSTReconcilationLine2."Component 2 Avl. Amount" := CalculateAvailmentAmount(DetailedGSTLedgerEntry);
                        end;
                    GSTReconcilationLine.FieldNo("Component 3 Amount"):
                        begin
                            GSTReconcilationLine2."Taxable Value" := DetailedGSTLedgerEntry."GST Base Amount";
                            GSTReconcilationLine2."Component 3 Rate" := DetailedGSTLedgerEntry."GST %";
                            GSTReconcilationLine2."Component 3 Amount" := DetailedGSTLedgerEntry."GST Amount";
                            GSTReconcilationLine2."Component 3 Avl. Amount" := CalculateAvailmentAmount(DetailedGSTLedgerEntry);
                        end;
                    GSTReconcilationLine.FieldNo("Component 4 Amount"):
                        begin
                            GSTReconcilationLine2."Taxable Value" := DetailedGSTLedgerEntry."GST Base Amount";
                            GSTReconcilationLine2."Component 4 Rate" := DetailedGSTLedgerEntry."GST %";
                            GSTReconcilationLine2."Component 4 Amount" := DetailedGSTLedgerEntry."GST Amount";
                            GSTReconcilationLine2."Component 4 Avl. Amount" := CalculateAvailmentAmount(DetailedGSTLedgerEntry);
                        end;
                    GSTReconcilationLine.FieldNo("Component 5 Amount"):
                        begin
                            GSTReconcilationLine2."Taxable Value" := DetailedGSTLedgerEntry."GST Base Amount";
                            GSTReconcilationLine2."Component 5 Rate" := DetailedGSTLedgerEntry."GST %";
                            GSTReconcilationLine2."Component 5 Amount" := DetailedGSTLedgerEntry."GST Amount";
                            GSTReconcilationLine2."Component 5 Avl. Amount" := CalculateAvailmentAmount(DetailedGSTLedgerEntry);
                        end;
                    GSTReconcilationLine.FieldNo("Component 6 Amount"):
                        begin
                            GSTReconcilationLine2."Taxable Value" := DetailedGSTLedgerEntry."GST Base Amount";
                            GSTReconcilationLine2."Component 6 Rate" := DetailedGSTLedgerEntry."GST %";
                            GSTReconcilationLine2."Component 6 Amount" := DetailedGSTLedgerEntry."GST Amount";
                            GSTReconcilationLine2."Component 6 Avl. Amount" := CalculateAvailmentAmount(DetailedGSTLedgerEntry);
                        end;
                    GSTReconcilationLine.FieldNo("Component 7 Amount"):
                        begin
                            GSTReconcilationLine2."Taxable Value" := DetailedGSTLedgerEntry."GST Base Amount";
                            GSTReconcilationLine2."Component 7 Rate" := DetailedGSTLedgerEntry."GST %";
                            GSTReconcilationLine2."Component 7 Amount" := DetailedGSTLedgerEntry."GST Amount";
                            GSTReconcilationLine2."Component 7 Avl. Amount" := CalculateAvailmentAmount(DetailedGSTLedgerEntry);
                        end;
                    GSTReconcilationLine.FieldNo("Component 8 Amount"):
                        begin
                            GSTReconcilationLine2."Taxable Value" := DetailedGSTLedgerEntry."GST Base Amount";
                            GSTReconcilationLine2."Component 8 Rate" := DetailedGSTLedgerEntry."GST %";
                            GSTReconcilationLine2."Component 8 Amount" := DetailedGSTLedgerEntry."GST Amount";
                            GSTReconcilationLine2."Component 8 Avl. Amount" := CalculateAvailmentAmount(DetailedGSTLedgerEntry);
                        end;
                end;
                GSTReconcilationLine2.Modify(true);
            end;
        end;
    end;

    local procedure CalculateAvailmentAmount(var DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"): Decimal
    var
        DetailedGSTLedgerEntry2: Record "Detailed GST Ledger Entry";
    begin
        DetailedGSTLedgerEntry2.CopyFilters(DetailedGSTLedgerEntry);
        DetailedGSTLedgerEntry2.SetRange("GST Credit", DetailedGSTLedgerEntry2."GST Credit"::Availment);
        DetailedGSTLedgerEntry2.CalcSums("GST Amount");
        exit(DetailedGSTLedgerEntry2."GST Amount");
    end;

    local procedure UpdateErrorTypeForCompAmt(
        var GSTReconcilationLine: Record "GST Reconcilation Line";
        PeriodicCompAmt: Decimal;
        RecCompAmt: Decimal;
        GSTTolarance: Decimal;
        FieldNo: Integer)
    var
        GSTReconMapping: Record "GST Recon. Mapping";
        CompAmttxtErr: Label '%1 Amount is not matching with Periodic GSTR-2A Data', Comment = '%1 = GST Component Code';
    begin
        GSTReconMapping.SetRange("GST Reconciliation Field No.", FieldNo);
        if GSTReconMapping.FindFirst() then;
        if (PeriodicCompAmt > RecCompAmt + GSTTolarance) or
            (PeriodicCompAmt < RecCompAmt - GSTTolarance)
        then
            GSTReconcilationLine."Error Type" := StrSubstNo(
                CompAmtTxtErr,
                GSTReconMapping."GST Component Code");
    end;
}
