// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSBase;

using Microsoft.Foundation.Navigate;
using Microsoft.Finance.GeneralLedger.Preview;
using Microsoft.Purchases.Posting;
using Microsoft.Sales.Posting;
using Microsoft.Finance.GeneralLedger.Posting;

codeunit 18809 "TCS Preview Handler"
{
    SingleInstance = true;

    var
        TempTCSEntry: Record "TCS Entry" temporary;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnGetEntries', '', false, false)]
    local procedure TCSLedgerEntry(TableNo: Integer; var RecRef: RecordRef)
    begin
        if TableNo = DATABASE::"TCS Entry" then
            RecRef.GetTable(TempTCSEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnAfterShowEntries', '', false, false)]
    local procedure TCSShowWntries(TableNo: Integer)
    begin
        if TableNo = DATABASE::"TCS Entry" then
            Page.Run(Page::"TCS Entries", TempTCSEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnAfterFillDocumentEntry', '', false, false)]
    local procedure FillTCSentries(var DocumentEntry: Record "Document Entry")
    var
        PostingPreviewEventHandler: Codeunit "Posting Preview Event Handler";
    begin
        PostingPreviewEventHandler.InsertDocumentEntry(TempTCSEntry, DocumentEntry);
    end;

    [EventSubscriber(ObjectType::Table, database::"TCS Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure SavePreviewTCSEntry(var Rec: Record "TCS Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        TempTCSEntry := Rec;
        TempTCSEntry."Document No." := '***';
        TempTCSEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure OnBeforePostPurchaseDoc()
    begin
        TempTCSEntry.Reset();
        if not TempTCSEntry.IsEmpty() then
            TempTCSEntry.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure OnBeforePostSalesDoc()
    begin
        TempTCSEntry.Reset();
        if not TempTCSEntry.IsEmpty() then
            TempTCSEntry.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post", 'OnBeforeCode', '', false, false)]
    local procedure OnBeforeCode()
    begin
        TempTCSEntry.Reset();
        if not TempTCSEntry.IsEmpty() then
            TempTCSEntry.DeleteAll();
    end;
}
