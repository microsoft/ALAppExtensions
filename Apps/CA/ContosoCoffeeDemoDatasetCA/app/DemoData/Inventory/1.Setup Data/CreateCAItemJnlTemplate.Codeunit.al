codeunit 27058 "Create CA Item Jnl. Template"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Template", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Item Journal Template")
    var
        CreateItemJournalTemplate: Codeunit "Create Item Journal Template";
    begin
        case Rec.Name of
            CreateItemJournalTemplate.ItemJournalTemplate():
                ValidateRecordFields(Rec, Report::"Item Register");
        end;
    end;

    local procedure ValidateRecordFields(var ItemJournalTemplate: Record "Item Journal Template"; PostingReportID: Integer)
    begin
        ItemJournalTemplate.Validate("Posting Report ID", PostingReportID);
    end;
}