// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Foundation.Navigate;

codeunit 31069 "Post.Preview Event Handler CZZ"
{
    EventSubscriberInstance = Manual;

    var
        TempSalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ" temporary;
        TempPurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ" temporary;

    [EventSubscriber(ObjectType::Table, Database::"Sales Adv. Letter Entry CZZ", 'OnAfterInsertEvent', '', false, false)]
    local procedure SalesAdvLetterEntryOnAfterInsertEvent(var Rec: Record "Sales Adv. Letter Entry CZZ")
    begin
        if Rec.IsTemporary() then
            exit;

        TempSalesAdvLetterEntryCZZ := Rec;
        TempSalesAdvLetterEntryCZZ."Document No." := '***';
        TempSalesAdvLetterEntryCZZ.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Adv. Letter Entry CZZ", 'OnAfterInsertEvent', '', false, false)]
    local procedure PurchAdvLetterEntryOnAfterInsertEvent(var Rec: Record "Purch. Adv. Letter Entry CZZ")
    begin
        if Rec.IsTemporary() then
            exit;

        TempPurchAdvLetterEntryCZZ := Rec;
        TempPurchAdvLetterEntryCZZ."Document No." := '***';
        TempPurchAdvLetterEntryCZZ.Insert();
    end;

    procedure ClearBuffer()
    begin
        if not TempSalesAdvLetterEntryCZZ.IsEmpty() then
            TempSalesAdvLetterEntryCZZ.DeleteAll();
        if not TempPurchAdvLetterEntryCZZ.IsEmpty() then
            TempPurchAdvLetterEntryCZZ.DeleteAll();
    end;

    procedure InsertAllDocumentEntry(var DocumentEntry: Record "Document Entry")
    begin
        InsertDocumentEntry(TempSalesAdvLetterEntryCZZ, DocumentEntry);
        InsertDocumentEntry(TempPurchAdvLetterEntryCZZ, DocumentEntry);
    end;

    local procedure InsertDocumentEntry(RecVariant: Variant; var TempDocumentEntry: Record "Document Entry")
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(RecVariant);

        if RecordRef.IsEmpty() then
            exit;

        TempDocumentEntry.Init();
        TempDocumentEntry."Entry No." := RecordRef.Number;
        TempDocumentEntry."Table ID" := RecordRef.Number;
        TempDocumentEntry."Table Name" := CopyStr(RecordRef.Caption, 1, MaxStrLen(TempDocumentEntry."Table Name"));
        TempDocumentEntry."No. of Records" := RecordRef.Count();
        TempDocumentEntry.Insert();
    end;

    procedure ShowEntries(TableNo: Integer)
    begin
        case TableNo of
            Database::"Sales Adv. Letter Entry CZZ":
                Page.Run(Page::"Sales Adv. Letter Entries CZZ", TempSalesAdvLetterEntryCZZ);
            Database::"Purch. Adv. Letter Entry CZZ":
                Page.Run(Page::"Purch. Adv. Letter Entries CZZ", TempPurchAdvLetterEntryCZZ);
        end;
    end;
}
