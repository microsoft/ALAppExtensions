// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSOnPayments;

using Microsoft.Finance.GeneralLedger.Preview;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Foundation.Navigate;

codeunit 18769 "Provisional Post Preview"
{
    SingleInstance = true;

    var
        TempProvisionalEntry: Record "Provisional Entry" temporary;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnGetEntries', '', false, false)]
    local procedure ProvisionalEntry(TableNo: Integer; var RecRef: RecordRef)
    begin
        if TableNo = Database::"Provisional Entry" then
            RecRef.GetTable(TempProvisionalEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnAfterShowEntries', '', false, false)]
    local procedure ShowProvisionalEntries(TableNo: Integer)
    begin
        if TableNo = Database::"Provisional Entry" then
            Page.Run(Page::"Provisional Entries Preview", TempProvisionalEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnAfterFillDocumentEntry', '', false, false)]
    local procedure FillProvisionalEntries(var DocumentEntry: Record "Document Entry")
    var
        PreviewHandler: Codeunit "Posting Preview Event Handler";
    begin
        PreviewHandler.InsertDocumentEntry(TempProvisionalEntry, DocumentEntry);
    end;

    [EventSubscriber(ObjectType::Table, database::"Provisional Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure SavePreviewProvisionalEntry(var Rec: Record "Provisional Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        TempProvisionalEntry := Rec;
        TempProvisionalEntry."Posted Document No." := '***';
        TempProvisionalEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post", 'OnBeforeCode', '', false, false)]
    local procedure DeleteTempProvisionalEntry()
    begin
        TempProvisionalEntry.Reset();
        if not TempProvisionalEntry.IsEmpty() then
            TempProvisionalEntry.DeleteAll();
    end;
}
