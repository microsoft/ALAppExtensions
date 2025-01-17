namespace Microsoft.Sustainability.Posting;

using Microsoft.Finance.GeneralLedger.Preview;
using Microsoft.Sustainability.Ledger;
using Microsoft.Foundation.Navigate;

codeunit 6226 "Sust. Preview Post. Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnAfterFillDocumentEntry', '', false, false)]
    local procedure OnAfterFillDocumentEntry(var DocumentEntry: Record "Document Entry" temporary)
    begin
        SustPreviewPostInstance.InsertDocumentEntry(DocumentEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnAfterShowEntries', '', false, false)]
    local procedure OnAfterShowEntries(TableNo: Integer)
    begin
        case TableNo of
            Database::"Sustainability Ledger Entry":
                SustPreviewPostInstance.ShowEntries();
            Database::"Sustainability Value Entry":
                SustPreviewPostInstance.ShowSustValueEntries();
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterFindPostedDocuments', '', false, false)]
    local procedure OnAfterFindPostedDocuments(sender: Page Navigate; var DocNoFilter: Text; var DocumentEntry: Record "Document Entry" temporary; var PostingDateFilter: Text)
    var
        SustLedgEntry: Record "Sustainability Ledger Entry";
        SustValueEntry: Record "Sustainability Value Entry";
    begin
        if SustLedgEntry.ReadPermission() then begin
            SustLedgEntry.Reset();
            SustLedgEntry.SetFilter("Document No.", DocNoFilter);
            SustLedgEntry.SetFilter("Posting Date", PostingDateFilter);
            DocumentEntry.InsertIntoDocEntry(Database::"Sustainability Ledger Entry", SustLedgEntry.TableCaption(), SustLedgEntry.Count);
        end;
        if SustValueEntry.ReadPermission() then begin
            SustValueEntry.Reset();
            SustValueEntry.SetFilter("Document No.", DocNoFilter);
            SustValueEntry.SetFilter("Posting Date", PostingDateFilter);
            DocumentEntry.InsertIntoDocEntry(Database::"Sustainability Value Entry", SustValueEntry.TableCaption(), SustValueEntry.Count);
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnBeforeShowRecords', '', false, false)]
    local procedure OnBeforeShowRecords(var TempDocumentEntry: Record "Document Entry" temporary; DocNoFilter: Text; PostingDateFilter: Text; sender: Page Navigate)
    var
        SustLedgEntry: Record "Sustainability Ledger Entry";
        SustValueEntry: Record "Sustainability Value Entry";
    begin
        case TempDocumentEntry."Table ID" of
            Database::"Sustainability Ledger Entry":
                if SustLedgEntry.ReadPermission() then begin
                    SustLedgEntry.Reset();
                    SustLedgEntry.SetFilter("Document No.", DocNoFilter);
                    SustLedgEntry.SetFilter("Posting Date", PostingDateFilter);
                    Page.Run(Page::"Sustainability Ledger Entries", SustLedgEntry);
                end;
            Database::"Sustainability Value Entry":
                if SustValueEntry.ReadPermission() then begin
                    SustValueEntry.Reset();
                    SustValueEntry.SetFilter("Document No.", DocNoFilter);
                    SustValueEntry.SetFilter("Posting Date", PostingDateFilter);
                    Page.Run(Page::"Sustainability Value Entries", SustValueEntry);
                end;
        end;
    end;

    var
        SustPreviewPostInstance: Codeunit "Sust. Preview Post Instance";
}