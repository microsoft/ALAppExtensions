codeunit 31109 "Gen.Jnl.-Check Ln. Handler CZZ"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnBeforeCheckSalesDocNoIsNotUsed', '', false, false)]
    local procedure GenJnlCheckLineOnBeforeCheckSalesDocNoIsNotUsed(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnBeforeCheckPurchDocNoIsNotUsed', '', false, false)]
    local procedure GenJnlCheckLineOnBeforeCheckPurchDocNoIsNotUsed(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCheckPurchExtDocNo', '', false, false)]
    local procedure GenJnlPostLineOnBeforeCheckPurchExtDocNo(var Handled: Boolean)
    begin
        Handled := true;
    end;
}