codeunit 31112 "Post. Prev. Handler CZL"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnAfterBindSubscription', '', false, false)]
    local procedure BindPostPrevEventHandlerOnAfterBindSubscription(var PostingPreviewEventHandler: Codeunit "Posting Preview Event Handler")
    begin
        TryBindPostPrevTableHandlerCZL();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnAfterUnbindSubscription', '', false, false)]
    local procedure UnbindPostPrecEventHandlerOnAfterUnbindSubscription()
    begin
        TryUnbindPostPrevTableHandlerCZL();
    end;

    local procedure TryBindPostPrevTableHandlerCZL(): Boolean
    var
        PostPrevTableHandlerCZL: Codeunit "Post. Prev. Table Handler CZL";
    begin
        PostPrevTableHandlerCZL.DeleteAll();
        exit(BindSubscription(PostPrevTableHandlerCZL));
    end;

    local procedure TryUnbindPostPrevTableHandlerCZL(): Boolean
    var
        PostPrevTableHandlerCZL: Codeunit "Post. Prev. Table Handler CZL";
    begin
        exit(UnbindSubscription(PostPrevTableHandlerCZL));
    end;
}