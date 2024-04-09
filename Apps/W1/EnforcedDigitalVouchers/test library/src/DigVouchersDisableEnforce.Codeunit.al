codeunit 139517 "Dig. Vouchers Disable Enforce"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Digital Voucher Feature", 'OnBeforeEnforceDigitalVoucherFunctionality', '', false, false)]
    local procedure DisableOnBeforeEnforceDigitalVoucherFunctionality(var IsEnabled: Boolean; var IsHandled: Boolean)
    begin
        IsEnabled := false;
        IsHandled := true;
    end;

}