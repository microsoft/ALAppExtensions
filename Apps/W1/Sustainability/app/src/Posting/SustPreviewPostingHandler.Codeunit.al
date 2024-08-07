namespace Microsoft.Sustainability.Posting;

using Microsoft.Sustainability.Ledger;

codeunit 6228 "Sust. Preview Posting Handler"
{
    EventSubscriberInstance = Manual;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Table, Database::"Sustainability Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertSustLedgEntry(var Rec: Record "Sustainability Ledger Entry"; RunTrigger: Boolean)
    var
        SustPreviewPostInstance: Codeunit "Sust. Preview Post Instance";
    begin
        SustPreviewPostInstance.InsertSustLedgEntry(Rec, RunTrigger);
    end;
}