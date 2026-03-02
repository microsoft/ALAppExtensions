// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Preview;
using Microsoft.Foundation.Navigate;
using Microsoft.Purchases.Posting;

codeunit 6792 "Wthldg Tax Preview Handler"
{
    SingleInstance = true;

    var
        TempWithholdingTaxEntry: Record "Withholding Tax Entry" temporary;
        PreviewPosting: Boolean;
        DocumentNoTxt: Label '***', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnGetEntries', '', false, false)]
    local procedure WithholdingTaxEntry(TableNo: Integer; var RecRef: RecordRef)
    begin
        case TableNo of
            Database::"Withholding Tax Entry":
                RecRef.GetTable(TempWithholdingTaxEntry);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnAfterShowEntries', '', false, false)]
    local procedure WithholdingTaxShowEntries(TableNo: Integer)
    begin
        case TableNo of
            Database::"Withholding Tax Entry":
                Page.Run(Page::"Withholding Tax Entries", TempWithholdingTaxEntry);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnAfterFillDocumentEntry', '', false, false)]
    local procedure FillWithholdingTaxEntries(var DocumentEntry: Record "Document Entry")
    var
        PostingPreviewEventHandler: Codeunit "Posting Preview Event Handler";
    begin
        PostingPreviewEventHandler.InsertDocumentEntry(TempWithholdingTaxEntry, DocumentEntry);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Withholding Tax Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure SavePreviewWithholdingTaxEntry(var Rec: Record "Withholding Tax Entry"; RunTrigger: Boolean)
    begin
        if not PreviewPosting then
            exit;

        if Rec.IsTemporary() then
            exit;

        TempWithholdingTaxEntry := Rec;
        TempWithholdingTaxEntry."Document No." := DocumentNoTxt;
        TempWithholdingTaxEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnBeforeShowRecords', '', false, false)]
    local procedure ShowEntries(DocNoFilter: Text; PostingDateFilter: Text; var TempDocumentEntry: Record "Document Entry"; var IsHandled: Boolean)
    var
        WithholdingTaxEntries: Record "Withholding Tax Entry";
    begin
        case TempDocumentEntry."Table ID" of
            Database::"Withholding Tax Entry":
                begin
                    WithholdingTaxEntries.Reset();
                    WithholdingTaxEntries.SetRange("Document No.", DocNoFilter);
                    WithholdingTaxEntries.SetFilter("Posting Date", PostingDateFilter);
                    Page.Run(0, WithholdingTaxEntries);
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure OnBeforePostPurchaseDoc()
    begin
        TempWithholdingTaxEntry.Reset();
        if not TempWithholdingTaxEntry.IsEmpty() then
            TempWithholdingTaxEntry.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post", OnBeforeCode, '', false, false)]
    local procedure OnBeforeGenJnlDoc()
    begin
        TempWithholdingTaxEntry.Reset();
        if not TempWithholdingTaxEntry.IsEmpty() then
            TempWithholdingTaxEntry.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnAfterBindSubscription', '', false, false)]
    local procedure OnAfterBindSubscription()
    begin
        PreviewPosting := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnAfterUnBindSubscription', '', false, false)]
    local procedure OnAfterUnBindSubscription()
    begin
        PreviewPosting := false;
    end;
}