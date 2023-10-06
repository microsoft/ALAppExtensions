codeunit 148121 "Supp.Conf. VAT Ent. Update CZL"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Conf. VAT Ent. Update Mgt. CZL", 'OnBeforeGuiAllowed', '', false, false)]
    local procedure SuppressConfirmVATEntriesUpdateOnBeforeGuiAllowed(var Result: Boolean; var IsHandled: Boolean)
    begin
        Result := false;
        IsHandled := true;
    end;
}