codeunit 139518 "Dig. Vouchers Enable Enforce"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Digital Voucher Feature", 'OnBeforeEnforceDigitalVoucherFunctionality', '', false, false)]
    local procedure EnableOnBeforeEnforceDigitalVoucherFunctionality(var IsEnabled: Boolean; var IsHandled: Boolean)
    begin
        IsEnabled := true;
        IsHandled := true;
    end;

}