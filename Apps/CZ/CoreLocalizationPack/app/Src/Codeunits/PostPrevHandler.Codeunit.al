codeunit 31112 "Post. Prev. Handler CZL"
{
    var
        PostPrevTableHandlerCZL: Codeunit "Post. Prev. Table Handler CZL";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnAfterBindSubscription', '', false, false)]
    local procedure BindPostPrevEventHandlerOnAfterBindSubscription(var PostingPreviewEventHandler: Codeunit "Posting Preview Event Handler")
    begin
        PostPrevTableHandlerCZL.DeleteAll();
        BindSubscription(PostPrevTableHandlerCZL);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnAfterUnbindSubscription', '', false, false)]
    local procedure UnbindPostPrecEventHandlerOnAfterUnbindSubscription()
    begin
        UnbindSubscription(PostPrevTableHandlerCZL);
    end;
}