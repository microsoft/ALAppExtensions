/// <summary>
/// Codeunit Shpfy Suppress ASM Warning (ID 30210).
/// </summary>
codeunit 30220 "Shpfy Suppress Asm Warning"
{
    Access = Internal;
    //Set the event subscribers to manual binding;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeCheckItemAvailable', '', false, false)]
    local procedure BeforeCheckItemAvailable(var SalesLine: Record "Sales Line"; CalledByFieldNo: Integer; IsHandled: Boolean; CurrentFieldNo: Integer; xSalesLine: Record "Sales Line")
    begin
        IsHandled := true;
    end;
}