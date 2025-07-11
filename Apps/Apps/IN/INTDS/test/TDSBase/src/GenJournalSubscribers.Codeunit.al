codeunit 18801 "Gen. Journal Subscribers"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnBeforeCheckBalAccountNo', '', true, false)]
    local procedure HandleOnBeforeCheckBalAccountNo(var CheckDone: Boolean)
    begin
        CheckDone := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnBeforeCheckAccountNo', '', true, false)]
    local procedure HandleOnBeforeCheckAccountNo(var CheckDone: Boolean)
    begin
        CheckDone := true;
    end;

}