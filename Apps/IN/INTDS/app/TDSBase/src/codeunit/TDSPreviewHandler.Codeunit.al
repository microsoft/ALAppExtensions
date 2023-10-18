// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

using Microsoft.Finance.GeneralLedger.Preview;
using Microsoft.Purchases.Posting;
using Microsoft.Sales.Posting;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Foundation.Navigate;

codeunit 18687 "TDS Preview Handler"
{
    SingleInstance = true;

    var
        TempTDSEntry: Record "TDS Entry" temporary;

    procedure UpdateInvoiceAmountOnTempTDSEntry(TDSEntry: Record "TDS Entry")
    begin
        if not TempTDSEntry.Get(TDSEntry."Entry No.") then
            exit;

        TempTDSEntry."Invoice Amount" := TDSEntry."Invoice Amount";
        TempTDSEntry.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnGetEntries', '', false, false)]
    local procedure TDSLedgerEntry(TableNo: Integer; var RecRef: RecordRef)
    begin
        case TableNo of
            Database::"TDS Entry":
                RecRef.GetTable(TempTDSEntry);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnAfterShowEntries', '', false, false)]
    local procedure TDSShowEntries(TableNo: Integer)
    begin
        case TableNo of
            Database::"TDS Entry":
                Page.Run(Page::"TDS Entries", TempTDSEntry);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnAfterFillDocumentEntry', '', false, false)]
    local procedure FillTDSEntries(var DocumentEntry: Record "Document Entry")
    var
        PostingPreviewEventHandler: Codeunit "Posting Preview Event Handler";
    begin
        PostingPreviewEventHandler.InsertDocumentEntry(TempTDSEntry, DocumentEntry);
    end;

    [EventSubscriber(ObjectType::Table, database::"TDS Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure SavePreviewTDSEntry(var Rec: Record "TDS Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        TempTDSEntry := Rec;
        TempTDSEntry."Document No." := '***';
        TempTDSEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure OnBeforePostPurchaseDoc()
    begin
        DeleteTempTDSEntry();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure OnBeforePostSalesDoc()
    begin
        DeleteTempTDSEntry();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post", 'OnBeforeCode', '', false, false)]
    local procedure OnBeforeCode()
    begin
        DeleteTempTDSEntry();
    end;

    local procedure DeleteTempTDSEntry()
    begin
        TempTDSEntry.Reset();
        if not TempTDSEntry.IsEmpty() then
            TempTDSEntry.DeleteAll();
    end;
}
