codeunit 31176 "Supp. Updt. Source Handler CZF"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeUpdateSource', '', false, false)]
    local procedure SuppressOnBeforeUpdateSource(var GenJournalLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        IsHandled := true;
    end;
}