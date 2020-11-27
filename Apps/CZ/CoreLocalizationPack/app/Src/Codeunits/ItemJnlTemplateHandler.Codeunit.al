codeunit 11789 "Item Jnl. Template Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Item Journal Template", 'OnAfterValidateEvent', 'Type', false, false)]
    local procedure PostingReportIDOnAfterValidateEventType(var Rec: Record "Item Journal Template")
    begin
        if Rec.Type <> Rec.Type::Revaluation then
            Rec."Posting Report ID" := Report::"Posted Inventory Document CZL";
    end;
}