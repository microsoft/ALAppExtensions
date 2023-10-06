// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.StockTransfer;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Posting;
using Microsoft.Inventory.Tracking;
using Microsoft.Purchases.Vendor;

codeunit 18320 "GST Journal Post"
{

    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTAdjustmentBuffer: Record "GST Adjustment Buffer";
        TempGSTPostingBuffer: array[2] of Record "GST Posting Buffer" temporary;
        TempNoSeries: Record "No. Series" temporary;
        ReservationEngineMgt: Codeunit "Reservation Engine Mgt.";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        NoSeriesMgt: Codeunit "NoSeriesManagement";
        NoSeriesMgt2: array[10] of Codeunit "NoSeriesManagement";
        GSTHelpers: Codeunit "GST Helpers";
        DiffAmt: Decimal;
        DocNo: Code[20];
        LastDocNo: Code[20];
        LastPostedDocNo: Code[20];
        PostingNoSeriesNo: Integer;
        NoOfPostingNoSeries: Integer;
        NoSeriesErr: Label 'A maximum of %1 posting number series can be used in each journal.', Comment = '%1 =Integer';
        RemQtyErr: Label 'Quantity Adjusted %1 must not be greater than remaining quantity %2 for Detailed GST Ledger Entry No %3.', Comment = '%1 = Adjusted Quantity, %2 = Remaining Quantity, %3 = Entry No.';
        GSTAdjustMsg: Label 'GST Adjustment Entry', Locked = true;
        LotNoErr: Label 'The Lot/Serial No %1  selected in item tracking does not belongs to posted document %2 selected in adjustment journal.', Comment = '%1 = Lot/Serial No, %2 = Document No.';

        PostingMsgQst: Label 'Do you want to post the journal lines?';
        JournalBatchMsg: Label 'Journal Batch Name    #4##########\\', Comment = '%4 =Dialog';
        ChangeLineMsg: Label 'Checking lines        #1######\', Comment = '%1 =Dialog';
        PostLineMsg: Label 'Posting lines         #2###### @3@@@@@@@@@@@@@\', Comment = '%2 =Dialog,%3 =Dialog';
        JournalMsg: Label 'Journal lines posted successfully.';
        ConversionErr: Label 'Document Type %1 is not a valid option.', Comment = '%1 = Gen. Journal Document Type';

    procedure PostGSTJournal(GSTJnlLine: Record "GST Journal Line")
    var
        GSTJournalLine: Record "GST Journal Line";
        Window: Dialog;
        LineCount: Integer;
    begin
        if not Confirm(PostingMsgQst) then
            exit;

        ClearAll();
        GSTJournalLine.Copy(GSTJnlLine);
        GSTJournalLine.SetRange("Journal Template Name", GSTJnlLine."Journal Template Name");
        GSTJournalLine.SetRange("Journal Batch Name", GSTJnlLine."Journal Batch Name");
        if GSTJournalLine.FindSet() then begin
            Window.Open(JournalBatchMsg + ChangeLineMsg + PostLineMsg);
            LineCount := 0;
            repeat
                LineCount := LineCount + 1;
                Window.Update(1, LineCount);
            until GSTJournalLine.Next() = 0;

            LineCount := 0;
            if GSTJournalLine.FindFirst() then
                repeat
                    PostGenJnlLine(GSTJournalLine);
                    LineCount := LineCount + 1;
                    Window.Update(2, LineCount);
                    Window.Update(3, Round(LineCount / GSTJournalLine.Count * 10000, 1));
                until GSTJournalLine.Next() = 0;
            Clear(GenJnlPostLine);

            GSTAdjustmentBuffer.Reset();
            GSTAdjustmentBuffer.SetRange("Journal Template Name", GSTJnlLine."Journal Template Name");
            GSTAdjustmentBuffer.SetRange("Journal Batch Name", GSTJnlLine."Journal Batch Name");
            GSTAdjustmentBuffer.DeleteAll();

            GSTJournalLine.DeleteAll(true);
            Window.Close();
            Message(JournalMsg);
        end;
        GSTJnlLine := GSTJournalLine;
    end;

    local procedure PostGenJnlLine(var GSTJournalLine: Record "GST Journal Line")
    begin
        if (GSTJournalLine."Journal Batch Name" = '') and (GSTJournalLine."Journal Template Name" = '') then
            DocNo := GSTJournalLine."Document No."
        else
            DocNo := CheckDocumentNo(GSTJournalLine);

        FillGSTPostingBuffer(GSTJournalLine);
        InitGenJnlLine(GSTJournalLine);
        RunGenPostLineGSTAdjustment(GenJournalLine, GSTJournalLine);

        GenJournalLine.SetRange("Journal Template Name", GSTJournalLine."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GSTJournalLine."Journal Batch Name");
        GenJournalLine.SetRange("GST Adjustment Entry", true);
        GenJournalLine.DeleteAll();
    end;

    local procedure CheckDocumentNo(GSTJnlLine: Record "GST Journal Line"): Code[20]
    var
        GSTJournalBatch: Record "GST Journal Batch";
    begin
        if (GSTJnlLine."Journal Template Name" = '') and (GSTJnlLine."Journal Batch Name" = '') and (GSTJnlLine."Document No." <> '') then
            exit(GSTJnlLine."Document No.");

        GSTJournalBatch.Get(GSTJnlLine."Journal Template Name", GSTJnlLine."Journal Batch Name");
        if GSTJnlLine."Posting No. Series" = '' then begin
            GSTJnlLine."Posting No. Series" := GSTJournalBatch."No. Series";
            GSTJnlLine."Document No." := NoSeriesMgt.GetNextNo(GSTJnlLine."Posting No. Series", GSTJnlLine."Posting Date", true);
        end else
            if GSTJnlLine."Document No." = LastDocNo then
                GSTJnlLine."Document No." := LastPostedDocNo
            else begin
                if not TempNoSeries.Get(GSTJnlLine."Posting No. Series") then begin
                    NoOfPostingNoSeries := NoOfPostingNoSeries + 1;
                    if NoOfPostingNoSeries > ArrayLen(NoSeriesMgt2) then
                        Error(NoSeriesErr, ArrayLen(NoSeriesMgt2));
                    TempNoSeries.Code := GSTJnlLine."Posting No. Series";
                    TempNoSeries.Description := Format(NoOfPostingNoSeries);
                    TempNoSeries.Insert();
                end;
                LastDocNo := GSTJnlLine."Document No.";
                Evaluate(PostingNoSeriesNo, TempNoSeries.Description);
                GSTJnlLine."Document No." := NoSeriesMgt2[PostingNoSeriesNo].GetNextNo(GSTJnlLine."Posting No. Series", GSTJnlLine."Posting Date", true);
                LastPostedDocNo := GSTJnlLine."Document No.";
            end;
        exit(GSTJnlLine."Document No.");
    end;

    local procedure FillGSTPostingBuffer(GSTJournalLine: Record "GST Journal Line")
    var
        Vend: Record Vendor;
        Item: Record Item;
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        Clear(TempGSTPostingBuffer[1]);
        GSTAdjustmentBuffer.Reset();
        GSTAdjustmentBuffer.SetRange("Journal Template Name", GSTJournalLine."Journal Template Name");
        GSTAdjustmentBuffer.SetRange("Journal Batch Name", GSTJournalLine."Journal Batch Name");
        GSTAdjustmentBuffer.SetRange("Document No.", GSTJournalLine."Document No.");
        GSTAdjustmentBuffer.SetRange("Document Line No.", GSTJournalLine."Document Line No.");
        GSTAdjustmentBuffer.SetRange("Transaction No", GSTJournalLine."GST Transaction No.");
        GSTAdjustmentBuffer.SetRange("GST Credit Type", GSTAdjustmentBuffer."GST Credit Type"::Availment);
        if GSTAdjustmentBuffer.FindSet() then
            repeat
                DetailedGSTLedgerEntry.Get(GSTAdjustmentBuffer."DGL Entry No.");
                DetailedGSTLedgerEntryInfo.Get(GSTAdjustmentBuffer."DGL Entry No.");
                Clear(TempGSTPostingBuffer[1]);
                if GSTAdjustmentBuffer."Source Type" = GSTAdjustmentBuffer."Source Type"::Vendor then
                    Vend.Get(GSTAdjustmentBuffer."Source No.");
                if GSTAdjustmentBuffer.Type = GSTAdjustmentBuffer.Type::Item then
                    Item.Get(GSTAdjustmentBuffer."No.");
                TempGSTPostingBuffer[1]."Transaction Type" := TempGSTPostingBuffer[1]."Transaction Type"::Purchase;
                TempGSTPostingBuffer[1]."Gen. Bus. Posting Group" := Vend."Gen. Bus. Posting Group";
                TempGSTPostingBuffer[1]."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
                TempGSTPostingBuffer[1]."Global Dimension 1 Code" := GSTJournalLine."Shortcut Dimension 1 Code";
                TempGSTPostingBuffer[1]."Global Dimension 2 Code" := GSTJournalLine."Shortcut Dimension 2 Code";
                TempGSTPostingBuffer[1]."Bal. Account No." := '';
                TempGSTPostingBuffer[1]."Party Code" := GSTJournalLine."Source Code";
                TempGSTPostingBuffer[1]."GST Base Amount" := GSTAdjustmentBuffer."GST Base Amount";
                TempGSTPostingBuffer[1]."GST Amount" := GSTAdjustmentBuffer."Amount to be Adjusted";
                TempGSTPostingBuffer[1]."Account No." :=
                    GSTHelpers.GetGSTPayableAccountNo(DetailedGSTLedgerEntryInfo."Location State Code", GSTAdjustmentBuffer."GST Component Code");
                TempGSTPostingBuffer[1]."GST %" := GSTAdjustmentBuffer."GST %";
                TempGSTPostingBuffer[1]."GST Component Code" := GSTAdjustmentBuffer."GST Component Code";
                UpdateGSTPostingBuffer(GSTJournalLine);
            until GSTAdjustmentBuffer.Next() = 0;
    end;

    local procedure UpdateGSTPostingBuffer(GSTJournalLine: Record "GST Journal Line")
    var
        DimensionManagement: Codeunit "DimensionManagement";
    begin
        TempGSTPostingBuffer[1]."Dimension Set ID" := GSTJournalLine."Dimension Set ID";
        DimensionManagement.UpdateGlobalDimFromDimSetID(
            TempGSTPostingBuffer[1]."Dimension Set ID",
            TempGSTPostingBuffer[1]."Global Dimension 1 Code",
            TempGSTPostingBuffer[1]."Global Dimension 2 Code");
        TempGSTPostingBuffer[2] := TempGSTPostingBuffer[1];
        if TempGSTPostingBuffer[2].Find() then begin
            TempGSTPostingBuffer[2]."GST Base Amount" += TempGSTPostingBuffer[1]."GST Base Amount";
            TempGSTPostingBuffer[2]."GST Amount" += TempGSTPostingBuffer[1]."GST Amount";
            TempGSTPostingBuffer[2]."Interim Amount" += TempGSTPostingBuffer[1]."Interim Amount";
            TempGSTPostingBuffer[2]."Custom Duty Amount" += TempGSTPostingBuffer[1]."Custom Duty Amount";
            TempGSTPostingBuffer[2].Modify();
        end else
            TempGSTPostingBuffer[1].Insert();
    end;

    local procedure InitGenJnlLine(var GSTJournalLine: Record "GST Journal Line")
    var
        GenJnlLine: Record "Gen. Journal Line";
        GLAcc: Record "G/L Account";
    begin
        if TempGSTPostingBuffer[1]."GST Amount" <> 0 then begin
            GLAcc.Get(GSTJournalLine."Account No.");
            GenJournalLine.Init();
            GenJournalLine."Journal Template Name" := GSTJournalLine."Journal Template Name";
            GenJournalLine."Journal Batch Name" := GSTJournalLine."Journal Batch Name";
            GenJournalLine."Line No." += 10000;
            GenJournalLine."Account Type" := GSTJournalLine."Account Type";
            GenJournalLine."Account No." := GSTJournalLine."Account No.";
            GenJournalLine."Posting Date" := GSTJournalLine."Posting Date";
            GenJournalLine."Document Type" := GSTJournalLine."Document Type";
            GenJournalLine."Document No." := DocNo;
            GenJournalLine."Gen. Bus. Posting Group" := GLAcc."Gen. Bus. Posting Group";
            GenJournalLine."Gen. Posting Type" := GLAcc."Gen. Posting Type";
            GenJournalLine."Gen. Prod. Posting Group" := GLAcc."Gen. Prod. Posting Group";
            GenJournalLine."Posting No. Series" := GSTJournalLine."Posting No. Series";
            GenJournalLine.Description := GSTJournalLine.Description;
            GenJournalLine.Validate(Amount, (GSTJournalLine."Amount of Adjustment" - GSTJournalLine."Amount to be Loaded on Invento"));
            GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
            GenJournalLine."Bal. Account No." := '';
            GenJournalLine."Shortcut Dimension 1 Code" := GSTJournalLine."Shortcut Dimension 1 Code";
            GenJournalLine."Shortcut Dimension 2 Code" := GSTJournalLine."Shortcut Dimension 2 Code";
            GenJournalLine."Dimension Set ID" := GSTJournalLine."Dimension Set ID";
            GenJournalLine."Source Code" := GSTJournalLine."Source Code";
            GenJournalLine."Reason Code" := GSTJournalLine."Reason Code";
            GenJournalLine."External Document No." := GSTJournalLine."Document No.";
            GenJournalLine."Location Code" := GSTJournalLine."Location Code";
            GenJournalLine."GST Adjustment Entry" := GSTJournalLine."GST Adjustment Entry";
            GenJournalLine."System-Created Entry" := true;
            if GenJournalLine."GST Adjustment Entry" then begin
                GenJnlLine.Reset();
                GenJnlLine.SetRange("Journal Batch Name", GSTJournalLine."Journal Batch Name");
                GenJnlLine.SetRange("Journal Template Name", GSTJournalLine."Journal Batch Name");
                GenJnlLine.SetRange("Line No.", GSTJournalLine."Line No.");
                GenJnlLine.SetRange("Document No.", GSTJournalLine."Document No.");
                if GenJnlLine.FindFirst() then
                    GenJournalLine.Modify()
                else
                    GenJournalLine.Insert();
            end;
        end;

        InitBalGenJnlLine(GSTJournalLine);
    end;

    local procedure InitBalGenJnlLine(var GSTJournalLine: Record "GST Journal Line")
    var
        GenJnlLine: Record "Gen. Journal Line";
        GLAcc: Record "G/L Account";
    begin
        if TempGSTPostingBuffer[1].Find('+') then
            repeat
                if TempGSTPostingBuffer[1]."GST Amount" <> 0 then begin
                    GenJournalLine.Init();
                    GenJournalLine."Journal Template Name" := GSTJournalLine."Journal Template Name";
                    GenJournalLine."Journal Batch Name" := GSTJournalLine."Journal Batch Name";
                    GenJournalLine."Line No." += 10000;
                    GLAcc.Get(GSTJournalLine."Account No.");
                    GenJournalLine."Account Type" := GSTJournalLine."Account Type";
                    GenJournalLine."Account No." := TempGSTPostingBuffer[1]."Account No.";
                    GenJournalLine."Posting Date" := GSTJournalLine."Posting Date";
                    GenJournalLine."Document Type" := GSTJournalLine."Document Type";
                    GenJournalLine."Document No." := DocNo;
                    GenJournalLine."Posting No. Series" := GSTJournalLine."Posting No. Series";
                    GenJournalLine.Description := GSTJournalLine.Description;
                    GenJournalLine.Validate(Amount, -TempGSTPostingBuffer[1]."GST Amount");
                    GenJournalLine."Gen. Bus. Posting Group" := GLAcc."Gen. Bus. Posting Group";
                    GenJournalLine."Gen. Posting Type" := GLAcc."Gen. Posting Type";
                    GenJournalLine."Gen. Prod. Posting Group" := GLAcc."Gen. Prod. Posting Group";
                    GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
                    GenJournalLine."Bal. Account No." := '';
                    GenJournalLine."Shortcut Dimension 1 Code" := GSTJournalLine."Shortcut Dimension 1 Code";
                    GenJournalLine."Shortcut Dimension 2 Code" := GSTJournalLine."Shortcut Dimension 2 Code";
                    GenJournalLine."Dimension Set ID" := GSTJournalLine."Dimension Set ID";
                    GenJournalLine."Source Code" := GSTJournalLine."Source Code";
                    GenJournalLine."Reason Code" := GSTJournalLine."Reason Code";
                    GenJournalLine."External Document No." := GSTJournalLine."Document No.";
                    GenJournalLine."Location Code" := GSTJournalLine."Location Code";
                    GenJournalLine."GST Adjustment Entry" := GSTJournalLine."GST Adjustment Entry";
                    GenJournalLine."System-Created Entry" := true;
                    if GenJournalLine."GST Adjustment Entry" then begin
                        GenJnlLine.Reset();
                        GenJnlLine.SetRange("Journal Batch Name", GSTJournalLine."Journal Batch Name");
                        GenJnlLine.SetRange("Journal Template Name", GSTJournalLine."Journal Batch Name");
                        GenJnlLine.SetRange("Line No.", GSTJournalLine."Line No.");
                        GenJnlLine.SetRange("Document No.", GSTJournalLine."Document No.");
                        if GenJnlLine.FindFirst() then
                            GenJournalLine.Modify()
                        else
                            GenJournalLine.Insert();
                    end;
                end;
            until TempGSTPostingBuffer[1].Next(-1) = 0
    end;

    local procedure RunGenPostLineGSTAdjustment(var GenJournalLine: Record "Gen. Journal Line"; var GSTJournalLine: Record "GST Journal Line")
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine := GenJournalLine;
        AdjustDetailedGSTEntry(true, GSTJournalLine);
        GenJnlLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        GenJnlLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        GenJnlLine.SetRange("Document No.", GenJournalLine."Document No.");
        GenJnlLine.SetRange("GST Adjustment Entry", true);
        if GenJnlLine.FindSet() then
            repeat
                GenJnlPostLine.RunWithCheck(GenJnlLine);
            until GenJnlLine.Next() = 0;
    end;

    procedure CallItemTracking(var GSTJournalLine: Record "GST Journal Line")
    var
        TrackingSpecification: Record "Tracking Specification";
        ItemTrackingLines: Page "Item Tracking Lines";
    begin
        InitTrackingSpecification(GSTJournalLine, TrackingSpecification);
        ItemTrackingLines.SetSourceSpec(TrackingSpecification, GSTJournalLine."Posting Date");
        ItemTrackingLines.SetInbound(false);
        ItemTrackingLines.RunModal();
    end;

    local procedure InitTrackingSpecification(var GSTJournalLine: Record "GST Journal Line"; var TrackingSpecification: Record "Tracking Specification")
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        Item: Record Item;
        GSTDocumentType: Enum "GST Document Type";
    begin
        GSTDocumentType := GenJnlDocumentType2GSTDocumentType(GSTJournalLine."Document Type");
        TrackingSpecification.Init();
        TrackingSpecification."Source Type" := Database::"GST Journal Line";
        DetailedGSTLedgerEntry.SetRange("Document No.", GSTJournalLine."Document No.");
        DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocumentType);
        DetailedGSTLedgerEntry.SetRange("Document Line No.", GSTJournalLine."Document Line No.");
        if DetailedGSTLedgerEntry.FindFirst() then
            TrackingSpecification."Item No." := DetailedGSTLedgerEntry."No.";
        if TrackingSpecification."Item No." <> '' then
            Item.Get(TrackingSpecification."Item No.");
        if Item."Item Tracking Code" = '' then
            exit;
        TrackingSpecification.Description := Item.Description;
        TrackingSpecification."Location Code" := GSTJournalLine."Original Location";
        TrackingSpecification."Source Subtype" := TrackingSpecification."Source Subtype"::"0";
        TrackingSpecification."Source ID" := GSTJournalLine."Journal Template Name";
        TrackingSpecification."Source Batch Name" := GSTJournalLine."Journal Batch Name";
        TrackingSpecification."Source Prod. Order Line" := 0;
        TrackingSpecification."Source Ref. No." := GSTJournalLine."Line No.";
        TrackingSpecification."Quantity (Base)" := GSTJournalLine."Quantity to be Adjusted";
        TrackingSpecification."Qty. to Handle" := GSTJournalLine."Quantity to be Adjusted";
        TrackingSpecification."Qty. to Handle (Base)" := GSTJournalLine."Quantity to be Adjusted";
        TrackingSpecification."Qty. to Invoice" := GSTJournalLine."Quantity to be Adjusted";
        TrackingSpecification."Qty. to Invoice (Base)" := GSTJournalLine."Quantity to be Adjusted";
        TrackingSpecification."Quantity Handled (Base)" := 0;
        TrackingSpecification."Quantity Invoiced (Base)" := 0;
    end;

    procedure AdjustDetailedGSTEntry(InsertRecord: Boolean; var GSTJnlLine: Record "GST Journal Line")
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        AmountAdjusted: Decimal;
        DiffAmountAdjustment: Decimal;
    begin
        Clear(DiffAmt);
        Clear(DiffAmountAdjustment);
        AmountAdjusted := 0;
        TempGSTPostingBuffer[1].DeleteAll();
        if not GSTJnlLine."GST Adjustment Entry" then
            exit;

        GSTJnlLine.TestField("Adjustment Type");
        GSTJnlLine.TestField("Document No.");
        GSTJnlLine.TestField("Quantity to be Adjusted");

        DetailedGSTLedgerEntry.Get(GSTJnlLine."GST Transaction No.");
        GSTAdjustmentBuffer.Reset();
        GSTAdjustmentBuffer.SetRange("Document No.", DetailedGSTLedgerEntry."Document No.");
        GSTAdjustmentBuffer.SetRange("Document Line No.", DetailedGSTLedgerEntry."Document Line No.");
        if GSTAdjustmentBuffer.FindSet() then begin
            repeat
                DetailedGSTLedgerEntry.SetRange("Document No.", GSTAdjustmentBuffer."Document No.");
                DetailedGSTLedgerEntry.SetRange("Entry No.", GSTAdjustmentBuffer."DGL Entry No.");
                if DetailedGSTLedgerEntry.FindFirst() then begin
                    ReverseItemGSTEntry(DetailedGSTLedgerEntry, InsertRecord, GSTJnlLine);
                    DetailedGSTLedgerEntry."Remaining Quantity" := DetailedGSTLedgerEntry."Remaining Quantity" - GSTJnlLine."Quantity to be Adjusted";
                    if InsertRecord then
                        DetailedGSTLedgerEntry.Modify();
                end;
                AmountAdjusted += Round(GSTAdjustmentBuffer."Amount to be Adjusted");
                DiffAmountAdjustment += Round(GSTAdjustmentBuffer."Amount to be Adjusted");
                GSTAdjustmentBuffer.Modify();
            until GSTAdjustmentBuffer.Next() = 0;
            if not InsertRecord then
                GSTJnlLine.Validate(Amount, AmountAdjusted);
        end;
        AmountAdjustment(GSTJnlLine, GSTAdjustmentBuffer, DiffAmountAdjustment);
        ReverseItemGSTEntry2(DetailedGSTLedgerEntry, InsertRecord, GSTJnlLine);
    end;

    local procedure ReverseItemGSTEntry(DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; InsertRecord: Boolean; var GSTJournalLine: Record "GST Journal Line")
    var
        NewDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        NewDetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        AmountOnItemReversed: Decimal;
        DummyUpdatedAmountOnItem: Decimal;
    begin
        NewDetailedGSTLedgerEntry := DetailedGSTLedgerEntry;
        NewDetailedGSTLedgerEntry."Entry No." := 0;
        NewDetailedGSTLedgerEntry."Entry Type" := NewDetailedGSTLedgerEntry."Entry Type"::"Adjustment Entry";
        NewDetailedGSTLedgerEntry.Quantity := -GSTJournalLine."Quantity to be Adjusted";
        NewDetailedGSTLedgerEntry."GST Base Amount" := (NewDetailedGSTLedgerEntry."GST Base Amount" / DetailedGSTLedgerEntry.Quantity) * -GSTJournalLine."Quantity to be Adjusted";
        NewDetailedGSTLedgerEntry."GST Amount" := (NewDetailedGSTLedgerEntry."GST Amount" / DetailedGSTLedgerEntry.Quantity) * -GSTJournalLine."Quantity to be Adjusted";
        NewDetailedGSTLedgerEntry."Remaining Quantity" := 0;
        NewDetailedGSTLedgerEntry."Posting Date" := GSTJournalLine."Posting Date";
        NewDetailedGSTLedgerEntry."Reversal Entry" := true;
        NewDetailedGSTLedgerEntry."Credit Availed" := false;
        if DetailedGSTLedgerEntry."GST Credit" = DetailedGSTLedgerEntry."GST Credit"::Availment then
            NewDetailedGSTLedgerEntry."Liable to Pay" := true;
        if InsertRecord then begin
            NewDetailedGSTLedgerEntry.Insert(true);

            DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.");
            NewDetailedGSTLedgerEntryInfo := DetailedGSTLedgerEntryInfo;
            NewDetailedGSTLedgerEntryInfo."Entry No." := NewDetailedGSTLedgerEntry."Entry No.";
            NewDetailedGSTLedgerEntryInfo."Adjustment Type" := GSTJournalLine."Adjustment Type";
            NewDetailedGSTLedgerEntryInfo."GST Journal Type" := "GST Journal Type"::"GST Adjustment Journal";
            NewDetailedGSTLedgerEntryInfo."User ID" := UserId;
            NewDetailedGSTLedgerEntryInfo."Reason Code" := GSTJournalLine."Reason Code";
            NewDetailedGSTLedgerEntryInfo.Positive := NewDetailedGSTLedgerEntry."GST Amount" > 0;
            NewDetailedGSTLedgerEntryInfo.Insert(true);
        end;
        AmountOnItemReversed := -NewDetailedGSTLedgerEntry."GST Amount";
        if not InsertRecord then begin
            GSTAdjustmentBuffer.Validate("Amount to be Adjusted", AmountOnItemReversed - DummyUpdatedAmountOnItem);
            GSTAdjustmentBuffer."Adjustment Type" := GSTJournalLine."Adjustment Type";
        end;
    end;

    local procedure ReverseItemGSTEntry2(DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; InsertRecord: Boolean; var GSTJournalLine: Record "GST Journal Line")
    begin
        if InsertRecord then
            case GSTJournalLine."Adjustment Type" of
                GSTJournalLine."Adjustment Type"::"Lost/Destroyed":
                    if DetailedGSTLedgerEntry.Type = DetailedGSTLedgerEntry.Type::Item then
                        PostNegativeAdjustment(
                            GSTJournalLine."Quantity to be Adjusted", GSTJournalLine."Posting Date", GSTJournalLine."DGL From Entry No.",
                            GSTJournalLine."DGL From To No.", DetailedGSTLedgerEntry."Entry No.", GSTJournalLine."Dimension Set ID",
                            GSTJournalLine."Amount of Adjustment");
                GSTJournalLine."Adjustment Type"::Consumed:
                    if DetailedGSTLedgerEntry.Type = DetailedGSTLedgerEntry.Type::Item then
                        PostNegativeAdjustment(
                            GSTJournalLine."Quantity to be Adjusted", GSTJournalLine."Posting Date", GSTJournalLine."DGL From Entry No.",
                            GSTJournalLine."DGL From To No.", GSTJournalLine."GST Transaction No.", GSTJournalLine."Dimension Set ID",
                            GSTJournalLine."Amount of Adjustment");
            end;
    end;

    local procedure AmountAdjustment(var GSTJournalLine: Record "GST Journal Line"; var GSTAdjustmentBuffer: Record "GST Adjustment Buffer"; AdjustmentAmount: Decimal)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        if GSTJournalLine.Amount <> AdjustmentAmount then begin
            DiffAmt := Abs(AdjustmentAmount - GSTJournalLine.Amount);
            if DiffAmt <= GeneralLedgerSetup."Inv. Rounding Precision (LCY)" then
                if GSTJournalLine.Amount < AdjustmentAmount then begin
                    GSTAdjustmentBuffer.Validate("Amount to be Adjusted", GSTAdjustmentBuffer."Amount to be Adjusted" - DiffAmt);
                    GSTAdjustmentBuffer.Modify();
                end else
                    if GSTJournalLine.Amount > AdjustmentAmount then begin
                        GSTAdjustmentBuffer.Validate("Amount to be Adjusted", GSTAdjustmentBuffer."Amount to be Adjusted" + DiffAmt);
                        GSTAdjustmentBuffer.Modify();
                    end;
        end;
    end;

    local procedure PostNegativeAdjustment(
        Quantity: Decimal;
        PostingDate: Date;
        GSTFromEntryNo: Integer;
        GSTToEntryNo: Integer;
        GSTEntryNo: Integer;
        DimSetID: Integer;
        AdjustmentAmount: Decimal)
    var
        ItemJnlLine: Record "Item Journal Line";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTTrackingEntry: Record "GST Tracking Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        GSTJournalLine: Record "GST Journal Line";
        Item: Record Item;
        ReservationEntry: Record "Reservation Entry";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        DimMgt: Codeunit DimensionManagement;
        QtytoApply: Decimal;
        RemQuantity: Decimal;
    begin
        DetailedGSTLedgerEntry.Get(GSTEntryNo);
        if CheckQuantity(GSTFromEntryNo, GSTToEntryNo, Quantity) then
            Error(RemQtyErr, Quantity, RemQuantity, DetailedGSTLedgerEntry."Entry No.");

        GSTJournalLine.SetRange("Document No.", DetailedGSTLedgerEntry."Document No.");
        GSTJournalLine.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type");
        GSTJournalLine.SetRange("Document Line No.", DetailedGSTLedgerEntry."Document Line No.");
        if GSTJournalLine.FindLast() then begin
            ItemJnlLine.Init();
            ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");
            ItemJnlLine.Validate("Item No.", DetailedGSTLedgerEntry."No.");
            ItemJnlLine.Validate(Quantity, GSTJournalLine."Quantity to be Adjusted");
            ItemJnlLine.Validate("Posting Date", PostingDate);
            ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");
            ItemJnlLine.Validate("Location Code", DetailedGSTLedgerEntry."Location Code");
            ItemJnlLine.Validate("Document No.", DetailedGSTLedgerEntry."Document No.");
            ItemJnlLine.Validate(Description, GSTAdjustMsg);
            ItemJnlLine."Dimension Set ID" := DimSetID;
            if DetailedGSTLedgerEntry."GST Credit" = DetailedGSTLedgerEntry."GST Credit"::Availment then begin
                ItemJnlLine.Validate("Unit Cost", ItemJnlLine."Unit Cost" + (AdjustmentAmount * (RemQuantity / ItemJnlLine.Quantity)));
                ItemJnlLine.Validate(Amount, ItemJnlLine.Amount + AdjustmentAmount);
            end;
            DimMgt.UpdateGlobalDimFromDimSetID(DimSetID, ItemJnlLine."Shortcut Dimension 1 Code", ItemJnlLine."Shortcut Dimension 2 Code");
            if Item.Get(DetailedGSTLedgerEntry."No.") then
                if Item."Item Tracking Code" <> '' then begin
                    TransferGSTJnlLineToItemJnlLine(GSTJournalLine, ItemJnlLine, GSTJournalLine."Quantity to be Adjusted", DetailedGSTLedgerEntry."No.");
                    GSTTrackingEntry.Reset();
                    ReservationEntry.SetRange("Source Type", Database::"Item Journal Line");
                    ReservationEntry.SetRange("Item No.", Item."No.");
                    ReservationEntry.SetRange("Location Code", ItemJnlLine."Location Code");
                    if ReservationEntry.FindSet() then
                        repeat
                            GSTTrackingEntry.SetRange("From Entry No.", GSTFromEntryNo);
                            GSTTrackingEntry.SetRange("From To No.", GSTToEntryNo);
                            GSTTrackingEntry.SetFilter("Remaining Quantity", '<>%1', 0);
                            if GSTTrackingEntry.FindSet() then
                                repeat
                                    if ItemLedgerEntry.Get(GSTTrackingEntry."Item Ledger Entry No.") then
                                        if ItemLedgerEntry."Lot No." <> '' then begin
                                            ItemLedgerEntry.SetRange("Entry No.", GSTTrackingEntry."Item Ledger Entry No.");
                                            if ItemLedgerEntry.FindFirst() then
                                                if ItemLedgerEntry."Lot No." = ReservationEntry."Lot No." then begin
                                                    GSTTrackingEntry."Remaining Quantity" := GSTTrackingEntry."Remaining Quantity" + ReservationEntry.Quantity;
                                                    GSTTrackingEntry.Modify();
                                                end;
                                        end;
                                until GSTTrackingEntry.Next() = 0;
                        until ReservationEntry.Next() = 0;
                end;
            ItemJnlPostLine.RunWithCheck(ItemJnlLine);
        end;

        QtytoApply := Quantity;
        GSTTrackingEntry.Reset();
        GSTTrackingEntry.SetRange("From Entry No.", GSTFromEntryNo);
        GSTTrackingEntry.SetRange("From To No.", GSTToEntryNo);
        GSTTrackingEntry.SetFilter("Remaining Quantity", '<>%1', 0);
        if GSTTrackingEntry.FindSet() then
            repeat
                if ItemLedgerEntry.Get(GSTTrackingEntry."Item Ledger Entry No.") then
                    if ItemLedgerEntry."Lot No." = '' then begin
                        RemQuantity := GSTTrackingEntry."Remaining Quantity";
                        if QtytoApply <= GSTTrackingEntry."Remaining Quantity" then begin
                            ItemJnlLine.Validate(Quantity, QtytoApply);
                            GSTTrackingEntry."Remaining Quantity" -= QtytoApply;
                            QtytoApply := 0;
                        end else begin
                            ItemJnlLine.Validate(Quantity, GSTTrackingEntry."Remaining Quantity");
                            QtytoApply -= GSTTrackingEntry."Remaining Quantity";
                            GSTTrackingEntry."Remaining Quantity" := 0;
                        end;
                        GSTTrackingEntry.Modify();
                    end;
            until (GSTTrackingEntry.Next() = 0) or (QtytoApply = 0);
    end;

    local procedure CheckQuantity(FromEntryNo: Integer; ToEntryNo: Integer; Quantity: Decimal): Boolean
    var
        GSTTrackingEntry: Record "GST Tracking Entry";
    begin
        GSTTrackingEntry.Reset();
        GSTTrackingEntry.SetRange("From Entry No.", FromEntryNo);
        GSTTrackingEntry.SetRange("From To No.", ToEntryNo);
        GSTTrackingEntry.SetFilter("Remaining Quantity", '<>%1', 0);
        GSTTrackingEntry.CalcSums("Remaining Quantity");
        if Quantity > GSTTrackingEntry."Remaining Quantity" then
            exit(true);

        exit(false);
    end;

    local procedure TransferGSTJnlLineToItemJnlLine(var GSTJournalLine: Record "GST Journal Line"; var ItemJnlLine: Record "Item Journal Line"; TransferQty: Decimal; ItemNo: Code[20])
    var
        OldReservEntry: Record "Reservation Entry";
        ValueEntry: Record "Value Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        if not FindReservEntry(GSTJournalLine, OldReservEntry) then
            exit;

        OldReservEntry.Lock();

        ItemJnlLine.TestField("Item No.", ItemNo);

        if TransferQty = 0 then
            exit;

        if ReservationEngineMgt.InitRecordSet(OldReservEntry) then
            repeat
                OldReservEntry.TestField("Item No.", ItemNo);
                OldReservEntry.TestField("Variant Code", '');
                OldReservEntry.TestField("Location Code", ItemJnlLine."Location Code");
                OldReservEntry."New Serial No." := OldReservEntry."Serial No.";
                OldReservEntry."New Lot No." := OldReservEntry."Lot No.";
                if OldReservEntry."Lot No." <> '' then begin
                    ItemLedgerEntry.SetRange("Lot No.", OldReservEntry."Lot No.");
                    ItemLedgerEntry.FindFirst();
                    ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
                    ValueEntry.SetRange("Document No.", GSTJournalLine."Document No.");
                    ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
                    if not ValueEntry.FindFirst() then
                        Error(LotNoErr, Format(OldReservEntry."Lot No."), GSTJournalLine."Document No.");
                end else begin
                    ItemLedgerEntry.SetRange("Serial No.", OldReservEntry."Serial No.");
                    ItemLedgerEntry.FindFirst();
                    ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
                    ValueEntry.SetRange("Document No.", GSTJournalLine."Document No.");
                    ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
                    if not ValueEntry.FindFirst() then
                        Error(LotNoErr, Format(OldReservEntry."Serial No."), GSTJournalLine."Document No.");
                end;

                TransferQty := CreateReservEntry.TransferReservEntry(
                    Database::"Item Journal Line",
                    ItemJnlLine."Entry Type",
                    ItemJnlLine."Journal Template Name",
                    ItemJnlLine."Journal Batch Name",
                    0,
                    ItemJnlLine."Line No.",
                    ItemJnlLine."Qty. per Unit of Measure",
                    OldReservEntry, TransferQty);
            until (ReservationEngineMgt.NEXTRecord(OldReservEntry) = 0) or (TransferQty = 0);
    end;

    local procedure FindReservEntry(GSTJournalLine: Record "GST Journal Line"; var ReservEntry: Record "Reservation Entry"): Boolean
    begin
        ReservationEngineMgt.InitFilterAndSortingLookupFor(ReservEntry, false);
        FilterReservFor(ReservEntry, GSTJournalLine);
        exit(ReservEntry.FindLast());
    end;

    local procedure FilterReservFor(var FilterReservEntry: Record "Reservation Entry"; GSTJournalLine: Record "GST Journal Line")
    begin
        FilterReservEntry.SetRange("Source Type", Database::"GST Journal Line");
        FilterReservEntry.SetRange("Source ID", GSTJournalLine."Journal Template Name");
        FilterReservEntry.SetRange("Source Batch Name", GSTJournalLine."Journal Batch Name");
        FilterReservEntry.SetRange("Source Prod. Order Line", 0);
        FilterReservEntry.SetRange("Source Ref. No.", GSTJournalLine."Line No.");
    end;

    local procedure GenJnlDocumentType2GSTDocumentType(GenJournalDocumentType: Enum "Gen. Journal Document Type"): Enum "GST Document Type"
    begin
        case GenJournalDocumentType of
            GenJournalDocumentType::" ":
                exit("GST Document Type"::" ");
            GenJournalDocumentType::"Credit Memo":
                exit("GST Document Type"::"Credit Memo");
            GenJournalDocumentType::Invoice:
                exit("GST Document Type"::Invoice);
            GenJournalDocumentType::Payment:
                exit("GST Document Type"::Payment);
            GenJournalDocumentType::Refund:
                exit("GST Document Type"::Refund);
            else
                Error(ConversionErr, GenJournalDocumentType);
        end;
    end;

}
