// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Vendor;

codeunit 18468 "Subcontracting Post GST Liab."
{
    var
        GLSetup: Record "General Ledger Setup";
        SourceCodeSetup: Record "Source Code Setup";
        TempGSTPostingBufferStage: Record "GST Posting Buffer" temporary;
        TempGSTPostingBufferFinal: Record "GST Posting Buffer" temporary;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        NoSeriesMgt: Codeunit "NoSeriesManagement";
        GLSetupRead: Boolean;
        SourceCodeSetupRead: Boolean;
        TransactionNo: Integer;

    procedure PostGSTLiability(Rec: Record "GST Liability Line")
    begin
        FillDetailedGSTPostingBufferSubconGSTLiability(Rec);
        PostSubconGSTLiability(Rec);
        DeleteDetailedGSTPostingBufferSubconGSTLiability(Rec);
    end;

    local procedure GetGLSetup()
    begin
        if GLSetupRead then
            exit;

        GLSetup.Get();
        GLSetupRead := true;

        GLSetup.TestField("Sub-Con Interim Account");
    end;

    local procedure GetSourceCodeSetup()
    begin
        if SourceCodeSetupRead then
            exit;

        SourceCodeSetup.Get();
        SourceCodeSetupRead := true;

        SourceCodeSetup.TestField("GST Liability - Job Work");
    end;

    local procedure FillDetailedGSTPostingBufferSubconGSTLiability(var Rec: Record "GST Liability Line")
    var
        GSTLiabilityLine: Record "GST Liability Line";
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        TaxTransValue: Record "Tax Transaction Value";
        GSTSetup: Record "GST Setup";
        GSTBaseValidation: Codeunit "GST Base Validation";
        LiabilityLineGSTAmount: Decimal;
        Sign: Integer;
        LastEntryNo: Integer;
    begin
        if not GSTSetup.Get() then
            exit;

        GSTSetup.TestField("GST Tax Type");

        Sign := -1;
        if DetailedGSTEntryBuffer.FindLast() then
            LastEntryNo := DetailedGSTEntryBuffer."Entry No." + 1
        else
            LastEntryNo := 1;

        GSTLiabilityLine.Copy(Rec);
        if GSTLiabilityLine.FindSet() then
            repeat
                LiabilityLineGSTAmount := 0;
                GSTLiabilityLine.CalcFields("Remaining Quantity", "Prod. BOM Quantity", "Quantity at Vendor Location");
                TaxTransValue.Reset();
                TaxTransValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
                TaxTransValue.SetRange("Tax Record ID", GSTLiabilityLine.RecordId);
                TaxTransValue.SetRange("Value Type", TaxTransValue."Value Type"::COMPONENT);
                TaxTransValue.SetFilter(Percent, '<>%1', 0);
                if TaxTransValue.FindSet() then
                    repeat
                        DetailedGSTEntryBuffer.Init();
                        DetailedGSTEntryBuffer."Entry No." := LastEntryNo;
                        DetailedGSTEntryBuffer."Document Type" := DetailedGSTEntryBuffer."Document Type"::Quote;
                        DetailedGSTEntryBuffer."Transaction Type" := DetailedGSTEntryBuffer."Transaction Type"::Production;
                        DetailedGSTEntryBuffer."Document No." := GSTLiabilityLine."Delivery Challan No.";
                        DetailedGSTEntryBuffer."Posting Date" := GSTLiabilityLine."Last Date";
                        DetailedGSTEntryBuffer.Type := DetailedGSTEntryBuffer.Type::"Item";
                        DetailedGSTEntryBuffer."No." := GSTLiabilityLine."Item No.";
                        DetailedGSTEntryBuffer."Source No." := '';
                        DetailedGSTEntryBuffer."HSN/SAC Code" := GSTLiabilityLine."HSN/SAC Code";
                        DetailedGSTEntryBuffer."Location Code" := GSTLiabilityLine."Company Location";
                        DetailedGSTEntryBuffer.Quantity := GSTLiabilityLine.Quantity;
                        DetailedGSTEntryBuffer."Line No." := GSTLiabilityLine."Line No.";
                        DetailedGSTEntryBuffer."Source Type" := "Source Type"::" ";
                        DetailedGSTEntryBuffer."GST Input/Output Credit Amount" := Sign * TaxTransValue.Amount;
                        DetailedGSTEntryBuffer."GST Base Amount" := Sign * GSTLiabilityLine."GST Base Amount";
                        DetailedGSTEntryBuffer."GST %" := TaxTransValue.Percent;
                        DetailedGSTEntryBuffer."GST Rounding Precision" := GLSetup."Inv. Rounding Precision (LCY)";
                        DetailedGSTEntryBuffer."GST Rounding Type" := GSTBaseValidation.GenLedInvRoundingType2GSTInvRoundingTypeEnum(GLSetup."Inv. Rounding Type (LCY)");
                        DetailedGSTEntryBuffer."GST Inv. Rounding Precision" := GLSetup."Inv. Rounding Precision (LCY)";
                        DetailedGSTEntryBuffer."GST Inv. Rounding Type" := GSTBaseValidation.GenLedInvRoundingType2GSTInvRoundingTypeEnum(GLSetup."Inv. Rounding Type (LCY)");
                        DetailedGSTEntryBuffer."Currency Factor" := 1;
                        DetailedGSTEntryBuffer."GST Amount" := Sign * TaxTransValue.Amount;
                        DetailedGSTEntryBuffer."GST Input/Output Credit Amount" := Sign * TaxTransValue.Amount;
                        DetailedGSTEntryBuffer."GST Component Code" := GetGSTComponent(TaxTransValue."Value ID");
                        DetailedGSTEntryBuffer."GST Group Code" := GSTLiabilityLine."GST Group Code";
                        DetailedGSTEntryBuffer."Location  Reg. No." := GSTLiabilityLine."Location GST Reg. No.";
                        DetailedGSTEntryBuffer."Location State Code" := GSTLiabilityLine."Location State Code";
                        DetailedGSTEntryBuffer."Buyer/Seller State Code" := GSTLiabilityLine."Vendor State Code";
                        DetailedGSTEntryBuffer."Buyer/Seller Reg. No." := GSTLiabilityLine."Vendor GST Reg. No.";
                        DetailedGSTEntryBuffer.UOM := GSTLiabilityLine."Unit of Measure Code";
                        DetailedGSTEntryBuffer."Delivery Challan Amount" := GSTLiabilityLine."GST Base Amount";
                        DetailedGSTEntryBuffer.Insert();
                        LastEntryNo += 1;
                        LiabilityLineGSTAmount += TaxTransValue.Amount;
                    until TaxTransValue.Next() = 0;

                GSTLiabilityLine."GST Liability Created" := LiabilityLineGSTAmount;
                GSTLiabilityLine."Total GST Amount" := LiabilityLineGSTAmount;
                GSTLiabilityLine.Modify();
            until GSTLiabilityLine.Next() = 0;
    end;

    local procedure PostSubconGSTLiability(var Rec: Record "GST Liability Line")
    var
        GSTLiabilityLine: Record "GST Liability Line";
        DeliveryChallanNo: Code[20];
    begin
        GSTLiabilityLine.Copy(Rec);
        if GSTLiabilityLine.FindSet() then
            repeat
                GSTLiabilityLine.CalcFields("Remaining Quantity", "Prod. BOM Quantity", "Quantity at Vendor Location");

                TempGSTPostingBufferStage.DeleteAll();
                if DeliveryChallanNo <> GSTLiabilityLine."Delivery Challan No." then
                    FillGSTPostingBufferAndPost(GSTLiabilityLine."Delivery Challan No.", GSTLiabilityLine."Liability Document No.");

                DeliveryChallanNo := GSTLiabilityLine."Delivery Challan No.";
                InsertPostedGSLTLiabilityLine(GSTLiabilityLine);
                UpdateDeliveryChallanLine(GSTLiabilityLine);
            until GSTLiabilityLine.Next() = 0;
    end;

    local procedure FillGSTPostingBufferAndPost(DCNo: Code[20]; LiabilityDocumentNo: Code[20])
    var
        Location: Record Location;
        Vendor: Record Vendor;
        GSTLiabilityLine: Record "GST Liability Line";
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";

        DeliveryChallanNo: Code[20];
        DocumentNo: Code[20];
    begin
        GetGLSetup();
        GetSourceCodeSetup();

        Clear(GenJnlPostLine);

        GSTLiabilityLine.Reset();
        GSTLiabilityLine.SetRange("Delivery Challan No.", DCNo);
        GSTLiabilityLine.SetRange("Liability Document No.", LiabilityDocumentNo);
        if GSTLiabilityLine.FindSet() then
            repeat
                GSTLiabilityLine.CalcFields("Remaining Quantity");

                DetailedGSTEntryBuffer.Reset();
                DetailedGSTEntryBuffer.SetCurrentKey("Transaction Type", "Document Type", "Document No.", "Line No.");
                DetailedGSTEntryBuffer.SetRange("Transaction Type", DetailedGSTEntryBuffer."Transaction Type"::Production);
                DetailedGSTEntryBuffer.SetRange("Document No.", GSTLiabilityLine."Delivery Challan No.");
                DetailedGSTEntryBuffer.SetRange("Posting Date", GSTLiabilityLine."Last Date");
                DetailedGSTEntryBuffer.SetRange("No.", GSTLiabilityLine."Item No.");
                DetailedGSTEntryBuffer.SetFilter("GST Base Amount", '<>%1', 0);
                if DetailedGSTEntryBuffer.FindSet() then
                    repeat
                        if Vendor.Get(GSTLiabilityLine."Vendor No.") then;
                        Location.Get(GSTLiabilityLine."Company Location");
                        Location.TestField("GST Liability Invoice");
                        Location.TestField("State Code");
                        Clear(NoSeriesMgt);
                        if GSTLiabilityLine."Delivery Challan No." <> DeliveryChallanNo then
                            DocumentNo := NoSeriesMgt.GetNextNo(Location."GST Liability Invoice", GSTLiabilityLine."Posting Date", true);

                        TempGSTPostingBufferStage."Transaction Type" := TempGSTPostingBufferStage."Transaction Type"::Purchase;
                        TempGSTPostingBufferStage.Type := DetailedGSTEntryBuffer.Type;
                        TempGSTPostingBufferStage."Gen. Bus. Posting Group" := Vendor."Gen. Bus. Posting Group";
                        TempGSTPostingBufferStage."Gen. Prod. Posting Group" := GSTLiabilityLine."Gen. Prod. Posting Group";
                        TempGSTPostingBufferStage."GST Component Code" := DetailedGSTEntryBuffer."GST Component Code";
                        TempGSTPostingBufferStage."GST Group Code" := DetailedGSTEntryBuffer."GST Group Code";
                        TempGSTPostingBufferStage."Global Dimension 1 Code" := GSTLiabilityLine."Shortcut Dimension 1 Code";
                        TempGSTPostingBufferStage."Global Dimension 2 Code" := GSTLiabilityLine."Shortcut Dimension 2 Code";
                        TempGSTPostingBufferStage."GST %" := DetailedGSTEntryBuffer."GST %";
                        TempGSTPostingBufferStage."Party Code" := DetailedGSTEntryBuffer."Source No.";
                        TempGSTPostingBufferStage."GST Base Amount" := DetailedGSTEntryBuffer."GST Base Amount";
                        TempGSTPostingBufferStage."GST Amount" := DetailedGSTEntryBuffer."GST Amount";
                        TempGSTPostingBufferStage."Account No." := GetGSTPayableAccountNo(Location."State Code", TempGSTPostingBufferStage."GST Component Code");
                        TempGSTPostingBufferStage."Bal. Account No." := GLSetup."Sub-Con Interim Account";

                        UpdateGSTPostingBuffer(GSTLiabilityLine."Dimension Set ID");

                        FillGSTLiabilityInGenJnlLine(TempGSTPostingBufferStage, GSTLiabilityLine, DocumentNo, TransactionNo);

                        InsertGSTLedgerEntry(TempGSTPostingBufferStage, GSTLiabilityLine, DocumentNo, SourceCodeSetup."GST Liability - Job Work");
                        InsertDetailedGSTLedgerEntry(TempGSTPostingBufferStage, GSTLiabilityLine, DetailedGSTEntryBuffer, DocumentNo);

                        DeliveryChallanNo := GSTLiabilityLine."Delivery Challan No.";
                    until DetailedGSTEntryBuffer.Next() = 0;
            until GSTLiabilityLine.Next() = 0;
    end;

    local procedure UpdateGSTPostingBuffer(DimensionSetID: Integer)
    var
        DimMgt: Codeunit "DimensionManagement";
    begin
        TempGSTPostingBufferStage."Dimension Set ID" := DimensionSetID;
        DimMgt.UpdateGlobalDimFromDimSetID(
            TempGSTPostingBufferStage."Dimension Set ID",
            TempGSTPostingBufferStage."Global Dimension 1 Code",
            TempGSTPostingBufferStage."Global Dimension 2 Code");

        TempGSTPostingBufferFinal := TempGSTPostingBufferStage;
        if TempGSTPostingBufferFinal.FindFirst() then begin
            TempGSTPostingBufferFinal."GST Base Amount" += TempGSTPostingBufferStage."GST Base Amount";
            TempGSTPostingBufferFinal."GST Amount" += TempGSTPostingBufferStage."GST Amount";
            TempGSTPostingBufferFinal."Interim Amount" += TempGSTPostingBufferStage."Interim Amount";
            TempGSTPostingBufferFinal.Modify();
        end else
            TempGSTPostingBufferFinal.Insert();
    end;

    local procedure FillGSTLiabilityInGenJnlLine(
        GSTPostingBuffer: Record "GST Posting Buffer";
        GSTLiabilityLine: Record "GST Liability Line";
        DocumentNo: Code[20];
        var TransactionNo: Integer)
    var
        GenJournalLine: Record "Gen. Journal Line";
        LineNo: Integer;
    begin
        GetSourceCodeSetup();
        LineNo := 0;
        GenJournalLine.LockTable();
        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", '');
        GenJournalLine.SetRange("Journal Batch Name", '');
        if GenJournalLine.FindLast() then
            LineNo := GenJournalLine."Line No." + 10000
        else
            LineNo := 10000;

        GenJournalLine.Init();
        GenJournalLine."Journal Template Name" := '';
        GenJournalLine."Journal Batch Name" := '';
        GenJournalLine."Line No." := LineNo;
        LineNo += 10000;
        GenJournalLine.Validate("Posting Date", GSTLiabilityLine."Liability Date");
        GenJournalLine.Validate("Document No.", DocumentNo);
        GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"G/L Account");
        GenJournalLine.Validate("Source Code", SourceCodeSetup."GST Liability - Job Work");
        GenJournalLine.Validate("Account No.", GSTPostingBuffer."Account No.");
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
        GenJournalLine.Validate("Bal. Account No.", GSTPostingBuffer."Bal. Account No.");
        Clear(GenJournalLine."Tax ID");
        GenJournalLine.Validate("Shortcut Dimension 1 Code", GSTPostingBuffer."Global Dimension 1 Code");
        GenJournalLine.Validate("Shortcut Dimension 2 Code", GSTPostingBuffer."Global Dimension 2 Code");
        GenJournalLine."Dimension Set ID" := GSTLiabilityLine."Dimension Set ID";
        GenJournalLine.Validate("System-Created Entry", true);
        GenJournalLine.Validate(Amount, GSTPostingBuffer."GST Amount");
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
        GenJournalLine.Validate("Gen. Prod. Posting Group", GSTPostingBuffer."Gen. Prod. Posting Group");
        Clear(GenJournalLine."Tax ID");
        GenJournalLine.Insert();

        GenJnlPostLine.RunWithCheck(GenJournalLine);
        TransactionNo := GenJnlPostLine.GetNextTransactionNo();
    end;

    local procedure InsertGSTLedgerEntry(
        GSTPostingBuffer: Record "GST Posting Buffer";
        GSTLiabilityLine: Record "GST Liability Line";
        DocumentNo: Code[20];
        SourceCode: Code[10])
    var
        GSTLedgerEntry: Record "GST Ledger Entry";
    begin
        GSTLedgerEntry.Init();
        GSTLedgerEntry."Entry No." := 0;
        GSTLedgerEntry."Posting Date" := GSTLiabilityLine."Liability Date";
        GSTLedgerEntry."Document Type" := GSTLedgerEntry."Document Type"::Invoice;
        GSTLedgerEntry."Document No." := DocumentNo;
        GSTLedgerEntry."Transaction Type" := GSTLedgerEntry."Transaction Type"::Sales;
        GSTLedgerEntry."GST Base Amount" := GSTPostingBuffer."GST Base Amount";
        GSTLedgerEntry."GST Amount" := GSTPostingBuffer."GST Amount";
        GSTLedgerEntry."Source Type" := GSTLedgerEntry."Source Type"::"G/L Account";
        GSTLedgerEntry."Source No." := GSTPostingBuffer."Account No.";
        GSTLedgerEntry."Source Code" := SourceCode;
        GSTLedgerEntry."Gen. Bus. Posting Group" := GSTPostingBuffer."Gen. Bus. Posting Group";
        GSTLedgerEntry."Gen. Prod. Posting Group" := GSTPostingBuffer."Gen. Prod. Posting Group";
        GSTLedgerEntry."GST Component Code" := GSTPostingBuffer."GST Component Code";
        GSTLedgerEntry."External Document No." := GSTLiabilityLine."Delivery Challan No.";
        GSTLedgerEntry."Transaction No." := TransactionNo;
        GSTLedgerEntry."User ID" := CopyStr(UserId(), 1, 50);
        GSTLedgerEntry.Insert(true);
    end;

    local procedure InsertDetailedGSTLedgerEntry(
        GSTPostingBuffer: Record "GST Posting Buffer";
        GSTLiabilityLine: Record "GST Liability Line";
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        DocumentNo: Code[20])
    var
        Location: Record Location;
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        GSTBaseValidation: Codeunit "GST Base Validation";
    begin
        GetGLSetup();

        DetailedGSTLedgerEntry.Init();
        DetailedGSTLedgerEntry."Entry No." := 0;
        DetailedGSTLedgerEntry."Entry Type" := DetailedGSTLedgerEntry."Entry Type"::"Initial Entry";
        DetailedGSTLedgerEntry."Transaction Type" := DetailedGSTLedgerEntry."Transaction Type"::Sales;
        DetailedGSTLedgerEntry."Transaction No." := TransactionNo;
        DetailedGSTLedgerEntry."Posting Date" := GSTLiabilityLine."Liability Date";
        DetailedGSTLedgerEntry."Document Type" := DetailedGSTLedgerEntry."Document Type"::Invoice;
        DetailedGSTLedgerEntry."Document No." := DocumentNo;
        DetailedGSTLedgerEntry."External Document No." := GSTLiabilityLine."Delivery Challan No.";
        DetailedGSTLedgerEntry."Source Type" := DetailedGSTLedgerEntry."Source Type"::Vendor;
        DetailedGSTLedgerEntry."Source No." := GSTLiabilityLine."Vendor No.";
        DetailedGSTLedgerEntry."GST Vendor Type" := GSTLiabilityLine."GST Vendor Type";
        DetailedGSTLedgerEntry."GST Customer Type" := DetailedGSTLedgerEntry."GST Customer Type"::Registered;
        DetailedGSTLedgerEntry."G/L Account No." := GSTPostingBuffer."Account No.";
        DetailedGSTLedgerEntry."GST Base Amount" := GSTPostingBuffer."GST Base Amount";
        DetailedGSTLedgerEntry."GST Amount" := GSTPostingBuffer."GST Amount";
        DetailedGSTLedgerEntry."GST %" := GSTPostingBuffer."GST %";
        DetailedGSTLedgerEntry."GST Component Code" := GSTPostingBuffer."GST Component Code";
        DetailedGSTLedgerEntry."HSN/SAC Code" := DetailedGSTEntryBuffer."HSN/SAC Code";
        DetailedGSTLedgerEntry."GST Group Code" := DetailedGSTEntryBuffer."GST Group Code";
        DetailedGSTLedgerEntry.Type := DetailedGSTEntryBuffer.Type;
        DetailedGSTLedgerEntry."No." := DetailedGSTEntryBuffer."No.";
        DetailedGSTLedgerEntry.Quantity := DetailedGSTEntryBuffer.Quantity;
        DetailedGSTLedgerEntry."Document Line No." := GSTLiabilityLine."Line No.";
        DetailedGSTLedgerEntry."Location Code" := DetailedGSTEntryBuffer."Location Code";
        DetailedGSTLedgerEntry."Location  Reg. No." := DetailedGSTEntryBuffer."Location  Reg. No.";
        DetailedGSTLedgerEntry."Buyer/Seller Reg. No." := DetailedGSTEntryBuffer."Buyer/Seller Reg. No.";
        DetailedGSTLedgerEntry."GST Credit" := DetailedGSTLedgerEntry."GST Credit"::Availment;
        DetailedGSTLedgerEntry."Product Type" := DetailedGSTLedgerEntry."Product Type"::Item;
        DetailedGSTLedgerEntry."GST Rounding Precision" := GLSetup."Inv. Rounding Precision (LCY)";
        DetailedGSTLedgerEntry."GST Rounding Type" := GSTBaseValidation.GenLedInvRoundingType2GSTInvRoundingTypeEnum(GLSetup."Inv. Rounding Type (LCY)");
        DetailedGSTLedgerEntry."Liable to Pay" := true;
        DetailedGSTLedgerEntry."GST Jurisdiction Type" := GSTLiabilityLine."GST Jurisdiction Type";
        DetailedGSTLedgerEntry.Insert(true);

        DetailedGSTLedgerEntryInfo.Init();
        DetailedGSTLedgerEntryInfo."Entry No." := DetailedGSTLedgerEntry."Entry No.";
        if Location.Get(DetailedGSTEntryBuffer."Location Code") then
            DetailedGSTLedgerEntryInfo."Location ARN No." := Location."Location ARN No.";
        DetailedGSTLedgerEntryInfo."Location State Code" := DetailedGSTEntryBuffer."Location State Code";
        DetailedGSTLedgerEntryInfo."Buyer/Seller State Code" := DetailedGSTEntryBuffer."Buyer/Seller State Code";
        DetailedGSTLedgerEntryInfo."Delivery Challan Amount" := DetailedGSTEntryBuffer."Delivery Challan Amount";
        DetailedGSTLedgerEntryInfo."Subcon Document No." := GSTLiabilityLine."Document No.";
        DetailedGSTLedgerEntryInfo."User ID" := CopyStr(UserId(), 1, MaxStrLen(DetailedGSTLedgerEntryInfo."User ID"));
        DetailedGSTLedgerEntryInfo."Component Calc. Type" := DetailedGSTEntryBuffer."Component Calc. Type";
        DetailedGSTLedgerEntryInfo."Cess Amount Per Unit Factor" := DetailedGSTEntryBuffer."Cess Amt Per Unit Factor (LCY)";
        DetailedGSTLedgerEntryInfo."Cess UOM" := DetailedGSTEntryBuffer."Cess UOM";
        DetailedGSTLedgerEntryInfo."Cess Factor Quantity" := DetailedGSTEntryBuffer."Cess Factor Quantity";
        DetailedGSTLedgerEntryInfo.UOM := DetailedGSTEntryBuffer.UOM;
        DetailedGSTLedgerEntryInfo.Insert();
    end;

    local procedure InsertPostedGSLTLiabilityLine(GSTLiabilityLine: Record "GST Liability Line")
    var
        PostedGSTLiabilityLine: Record "Posted GST Liability Line";
    begin
        PostedGSTLiabilityLine.Init();
        PostedGSTLiabilityLine.TransferFields(GSTLiabilityLine);
        PostedGSTLiabilityLine."Remaining Quantity" := GSTLiabilityLine."Remaining Quantity";
        PostedGSTLiabilityLine."Prod. BOM Quantity" := GSTLiabilityLine."Prod. BOM Quantity";
        PostedGSTLiabilityLine."Quantity at Vendor Location" := GSTLiabilityLine."Quantity at Vendor Location";
        PostedGSTLiabilityLine."Total GST Amount" := GSTLiabilityLine."Total GST Amount";
        PostedGSTLiabilityLine."GST Liability Created" := GSTLiabilityLine."GST Liability Created";
        PostedGSTLiabilityLine.Insert();
    end;

    local procedure UpdateDeliveryChallanLine(GSTLiabilityLine: Record "GST Liability Line")
    var
        DeliveryChallanLine: Record "Delivery Challan Line";
    begin
        DeliveryChallanLine.Reset();
        DeliveryChallanLine.SetRange("Delivery Challan No.", GSTLiabilityLine."Delivery Challan No.");
        DeliveryChallanLine.SetRange("Line No.", GSTLiabilityLine."Line No.");
        if DeliveryChallanLine.FindFirst() then begin
            DeliveryChallanLine."GST Liability Created" += GSTLiabilityLine."Total GST Amount";
            DeliveryChallanLine."GST Amount Remaining" := DeliveryChallanLine."GST Amount Remaining" - GSTLiabilityLine."Total GST Amount";
            DeliveryChallanLine.Modify();
        end;
    end;

    local procedure GetGSTComponent(ComponentID: Integer): Code[30]
    var
        GSTSetup: Record "GST Setup";
        TaxComponent: Record "Tax Component";
    begin
        if not GSTSetup.Get() then
            exit;

        GSTSetup.TestField("GST Tax Type");

        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxComponent.SetRange(Id, ComponentID);
        if TaxComponent.FindFirst() then
            exit(TaxComponent.Name);

        exit('');
    end;

    local procedure GetGSTPayableAccountNo(LocationCode: Code[10]; GSTComponentCode: Code[30]): Code[20]
    var
        GSTPostingSetup: Record "GST Posting Setup";
    begin
        GSTPostingSetup.Reset();
        GSTPostingSetup.SetRange("State Code", LocationCode);
        GSTPostingSetup.SetRange("Component ID", GSTComponentID(GSTComponentCode));
        GSTPostingSetup.FindFirst();
        exit(GSTPostingSetup."Payable Account")
    end;

    local procedure GSTComponentID(ComponentCode: Code[30]): Integer
    var
        GSTSetup: Record "GST Setup";
        TaxComponent: Record "Tax Component";
    begin
        if not GSTSetup.Get() then
            exit;

        GSTSetup.TestField("GST Tax Type");

        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxComponent.SetRange(Name, ComponentCode);
        if TaxComponent.FindFirst() then
            exit(TaxComponent.Id);

        exit;
    end;

    local procedure DeleteDetailedGSTPostingBufferSubconGSTLiability(var Rec: Record "GST Liability Line")
    var
        GSTLiabilityLine: Record "GST Liability Line";
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
    begin
        GSTLiabilityLine.Copy(Rec);
        if GSTLiabilityLine.FindSet() then
            repeat
                DeleteGSTBuffer(
                    DetailedGSTEntryBuffer."Transaction Type"::Production,
                    DetailedGSTEntryBuffer."Document Type"::Quote,
                    GSTLiabilityLine."Delivery Challan No.",
                    GSTLiabilityLine."Line No.");
            until GSTLiabilityLine.Next() = 0;
    end;

    local procedure DeleteGSTBuffer(
        TransactionType: Enum "Transaction Type Enum";
        DocumentType: Enum "Document Type Enum";
        DocumentNo: Code[20];
        LineNo: Integer)
    var
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
    begin
        DetailedGSTEntryBuffer.SetCurrentKey("Transaction Type", "Document Type", "Document No.", "Line No.");
        DetailedGSTEntryBuffer.SetRange("Transaction Type", TransactionType);
        DetailedGSTEntryBuffer.SetRange("Document Type", DocumentType);
        DetailedGSTEntryBuffer.SetRange("Document No.", DocumentNo);
        if LineNo <> 0 then
            DetailedGSTEntryBuffer.SetRange("Line No.", LineNo);

        DetailedGSTEntryBuffer.DeleteAll();
    end;
}
