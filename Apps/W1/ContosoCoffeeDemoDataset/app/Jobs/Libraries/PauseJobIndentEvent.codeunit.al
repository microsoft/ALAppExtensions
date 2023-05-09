codeunit 5120 "Pause Job Indent Event"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Task-Indent", 'OnRunOnBeforeConfirm', '', false, false)]
    local procedure SuppressConfirmOfIndent(var JobTask: Record "Job Task"; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;
}