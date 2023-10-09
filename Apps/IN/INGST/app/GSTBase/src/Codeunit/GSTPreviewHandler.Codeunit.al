// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Preview;
using Microsoft.Finance.GST.Payments;
using Microsoft.Foundation.Navigate;
using Microsoft.Inventory.Transfer;
using Microsoft.Purchases.Posting;
using Microsoft.Sales.Posting;
using Microsoft.Sales.Receivables;
using Microsoft.Service.Posting;

codeunit 18003 "GST Preview Handler"
{
    SingleInstance = true;

    var
        TempGSTLedgerEntry: Record "GST Ledger Entry" temporary;
        TempDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry" temporary;
        TempGSTTDSTCSEntry: Record "GST TDS/TCS Entry" temporary;
        TempDetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info" temporary;
        PreviewPosting: Boolean;
        FromDetailedGSTLedgerEntryNo: Integer;
        ToDetailedGSTLedgerEntryNo: Integer;
        DocumentNoTxt: Label '***', Locked = true;

    procedure UpdateTempDetailedGSTLedgerEntry(DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry")
    begin
        if not TempDetailedGSTLedgerEntry.Get(DetailedGSTLedgerEntry."Entry No.") then
            exit;

        TempDetailedGSTLedgerEntry := DetailedGSTLedgerEntry;
        TempDetailedGSTLedgerEntry."Document No." := DocumentNoTxt;
        TempDetailedGSTLedgerEntry.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnGetEntries', '', false, false)]
    local procedure GSTLedgerEntry(TableNo: Integer; var RecRef: RecordRef)
    begin
        case TableNo of
            Database::"GST Ledger Entry":
                RecRef.GetTable(TempGSTLedgerEntry);
            Database::"Detailed GST Ledger Entry":
                RecRef.GetTable(TempDetailedGSTLedgerEntry);
            Database::"GST TDS/TCS Entry":
                RecRef.GetTable(TempGSTTDSTCSEntry);
            Database::"Detailed GST Ledger Entry Info":
                RecRef.GetTable(TempDetailedGSTLedgerEntryInfo);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnAfterShowEntries', '', false, false)]
    local procedure GSTShowWntries(TableNo: Integer)
    begin
        case TableNo of
            Database::"GST Ledger Entry":
                Page.Run(Page::"GST Ledger Entry", TempGSTLedgerEntry);
            Database::"Detailed GST Ledger Entry":
                Page.Run(Page::"Detailed GST Ledger Entry", TempDetailedGSTLedgerEntry);
            Database::"GST TDS/TCS Entry":
                Page.Run(Page::"GST TDS/TCS Entry", TempGSTTDSTCSEntry);
            Database::"Detailed GST Ledger Entry Info":
                Page.Run(Page::"Detailed GST Ledger Entry Info", TempDetailedGSTLedgerEntryInfo);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnAfterFillDocumentEntry', '', false, false)]
    local procedure FillGSTentries(var DocumentEntry: Record "Document Entry")
    var
        PostingPreviewEventHandler: Codeunit "Posting Preview Event Handler";
    begin
        PostingPreviewEventHandler.InsertDocumentEntry(TempGSTLedgerEntry, DocumentEntry);
        PostingPreviewEventHandler.InsertDocumentEntry(TempDetailedGSTLedgerEntry, DocumentEntry);
        PostingPreviewEventHandler.InsertDocumentEntry(TempGSTTDSTCSEntry, DocumentEntry);
        PostingPreviewEventHandler.InsertDocumentEntry(TempDetailedGSTLedgerEntryInfo, DocumentEntry);
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure SavePreviewGSTEntry(var Rec: Record "GST Ledger Entry"; RunTrigger: Boolean)
    begin
        if not PreviewPosting then
            exit;

        if Rec.IsTemporary() then
            exit;

        TempGSTLedgerEntry := Rec;
        TempGSTLedgerEntry."Document No." := DocumentNoTxt;
        TempGSTLedgerEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Detailed GST Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure SavePreviewDetailedGSTEntry(var Rec: Record "Detailed GST Ledger Entry")
    begin
        if not PreviewPosting then
            exit;

        if Rec.IsTemporary() then
            exit;

        TempDetailedGSTLedgerEntry := Rec;
        TempDetailedGSTLedgerEntry."Document No." := DocumentNoTxt;
        TempDetailedGSTLedgerEntry.Insert();

        if FromDetailedGSTLedgerEntryNo = 0 then
            FromDetailedGSTLedgerEntryNo := Rec."Entry No."
        else
            ToDetailedGSTLedgerEntryNo := Rec."Entry No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST TDS/TCS Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure SavePreviewGSTTDSTCSEntry(var Rec: Record "GST TDS/TCS Entry")
    begin
        if not PreviewPosting then
            exit;

        if Rec.IsTemporary() then
            exit;

        TempGSTTDSTCSEntry := Rec;
        TempGSTTDSTCSEntry."Document No." := DocumentNoTxt;
        TempGSTTDSTCSEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Detailed GST Ledger Entry Info", 'OnAfterInsertEvent', '', false, false)]
    local procedure SavePreviewDetailedGSTEntryInfo(var Rec: Record "Detailed GST Ledger Entry Info")
    begin
        if not PreviewPosting then
            exit;

        if Rec.IsTemporary() then
            exit;

        TempDetailedGSTLedgerEntryInfo := Rec;
        TempDetailedGSTLedgerEntryInfo.Insert();
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateShowRecords', '', false, false)]
    local procedure ShowEntries(TableID: Integer; DocNoFilter: Text; PostingDateFilter: Text; var TempDocumentEntry: Record "Document Entry")
    var
        GSTLedgerEntries: Record "GST Ledger Entry";
        DetailedGSTLedgerEntries: Record "Detailed GST Ledger Entry";
        GSTTDSTCSEntry: Record "GST TDS/TCS Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        case TableID of
            Database::"GST Ledger Entry":
                begin
                    GSTLedgerEntries.Reset();
                    GSTLedgerEntries.SetRange("Document No.", DocNoFilter);
                    GSTLedgerEntries.SetFilter("Posting Date", PostingDateFilter);
                    Page.Run(0, GSTLedgerEntries);
                end;
            Database::"Detailed GST Ledger Entry":
                begin
                    DetailedGSTLedgerEntries.Reset();
                    DetailedGSTLedgerEntries.SetRange("Document No.", DocNoFilter);
                    DetailedGSTLedgerEntries.SetFilter("Posting Date", PostingDateFilter);
                    Page.Run(0, DetailedGSTLedgerEntries);
                end;
            Database::"GST TDS/TCS Entry":
                begin
                    GSTTDSTCSEntry.Reset();
                    GSTTDSTCSEntry.SetRange("Document No.", DocNoFilter);
                    GSTTDSTCSEntry.SetFilter("Posting Date", PostingDateFilter);
                    Page.Run(0, GSTTDSTCSEntry);
                end;
            Database::"Detailed GST Ledger Entry Info":
                begin
                    DetailedGSTLedgerEntryInfo.SetRange("Entry No.", FromDetailedGSTLedgerEntryNo, ToDetailedGSTLedgerEntryNo);
                    Page.Run(0, DetailedGSTLedgerEntryInfo);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure OnBeforePostPurchaseDoc()
    begin
        TempGSTLedgerEntry.Reset();
        if not TempGSTLedgerEntry.IsEmpty() then
            TempGSTLedgerEntry.DeleteAll();

        TempDetailedGSTLedgerEntry.Reset();
        if not TempDetailedGSTLedgerEntry.IsEmpty() then
            TempDetailedGSTLedgerEntry.DeleteAll();

        TempGSTTDSTCSEntry.Reset();
        if not TempGSTTDSTCSEntry.IsEmpty() then
            TempGSTTDSTCSEntry.DeleteAll();

        TempDetailedGSTLedgerEntryInfo.Reset();
        if not TempDetailedGSTLedgerEntryInfo.IsEmpty() then
            TempDetailedGSTLedgerEntryInfo.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure OnBeforePostSalesDoc()
    begin
        TempGSTLedgerEntry.Reset();
        if not TempGSTLedgerEntry.IsEmpty() then
            TempGSTLedgerEntry.DeleteAll();

        TempDetailedGSTLedgerEntry.Reset();
        if not TempDetailedGSTLedgerEntry.IsEmpty() then
            TempDetailedGSTLedgerEntry.DeleteAll();

        TempGSTTDSTCSEntry.Reset();
        if not TempGSTTDSTCSEntry.IsEmpty() then
            TempGSTTDSTCSEntry.DeleteAll();

        TempDetailedGSTLedgerEntryInfo.Reset();
        if not TempDetailedGSTLedgerEntryInfo.IsEmpty() then
            TempDetailedGSTLedgerEntryInfo.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnBeforePostWithLines', '', false, false)]
    local procedure OnBeforePostServiceDoc()
    begin
        TempGSTLedgerEntry.Reset();
        if not TempGSTLedgerEntry.IsEmpty() then
            TempGSTLedgerEntry.DeleteAll();

        TempDetailedGSTLedgerEntry.Reset();
        if not TempDetailedGSTLedgerEntry.IsEmpty() then
            TempDetailedGSTLedgerEntry.DeleteAll();

        TempGSTTDSTCSEntry.Reset();
        if not TempGSTTDSTCSEntry.IsEmpty() then
            TempGSTTDSTCSEntry.DeleteAll();

        TempDetailedGSTLedgerEntryInfo.Reset();
        if not TempDetailedGSTLedgerEntryInfo.IsEmpty() then
            TempDetailedGSTLedgerEntryInfo.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post", 'OnBeforeCode', '', false, false)]
    local procedure OnBeforeCode()
    begin
        ClearBuffers();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post (Yes/No)", 'OnBeforePost', '', false, false)]
    local procedure OnBeforePostTransferDoc()
    begin
        ClearBuffers();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnAfterBindSubscription', '', false, false)]
    local procedure OnAfterBindSubscription()
    begin
        FromDetailedGSTLedgerEntryNo := 0;
        ToDetailedGSTLedgerEntryNo := 0;
        PreviewPosting := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnAfterUnBindSubscription', '', false, false)]
    local procedure OnAfterUnBindSubscription()
    begin
        PreviewPosting := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", 'OnBeforeCustPostApplyCustLedgEntry', '', false, false)]
    local procedure OnBeforeCustPostApplyCustLedgEntry()
    begin
        ClearBuffers();
    end;

    procedure ClearBuffers()
    begin
        TempGSTLedgerEntry.Reset();
        if not TempGSTLedgerEntry.IsEmpty() then
            TempGSTLedgerEntry.DeleteAll();

        TempDetailedGSTLedgerEntry.Reset();
        if not TempDetailedGSTLedgerEntry.IsEmpty() then
            TempDetailedGSTLedgerEntry.DeleteAll();

        TempGSTTDSTCSEntry.Reset();
        if not TempGSTTDSTCSEntry.IsEmpty() then
            TempGSTTDSTCSEntry.DeleteAll();

        TempDetailedGSTLedgerEntryInfo.Reset();
        if not TempDetailedGSTLedgerEntryInfo.IsEmpty() then
            TempDetailedGSTLedgerEntryInfo.DeleteAll();
    end;
}
