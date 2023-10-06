#if not CLEAN23
codeunit 139506 "MS - WorldPay Std Mock Events"
{
    // version Test,ERM,W1,AT,AU,BE,CA,CH,DE,DK,ES,FI,FR,GB,IS,IT,MX,NL,NO,NZ,SE,US

    EventSubscriberInstance = Manual;
    ObsoleteReason = 'WorldPay Payments Standard extension is discontinued';
    ObsoleteState = Pending;
    ObsoleteTag = '23.0';

    var
        LibraryUtility: Codeunit "Library - Utility";

#if not CLEAN22
#pragma warning disable AA0207
    [Obsolete('The procedure will be made local.', '22.0')]
    [EventSubscriber(ObjectType::Table, Database::"Payment Service Setup", 'OnRegisterPaymentServiceProviders', '', false, false)]
    procedure RegisterDummyPaymentServiceProvider(var PaymentServiceSetup: Record 1060);
#pragma warning restore AA0207
#else
    [EventSubscriber(ObjectType::Table, Database::"Payment Service Setup", 'OnRegisterPaymentServiceProviders', '', false, false)]
    local procedure RegisterDummyPaymentServiceProvider(var PaymentServiceSetup: Record 1060);
#endif
    begin
        CLEAR(PaymentServiceSetup);

        PaymentServiceSetup.Name := COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(20, 0),
            1, MAXSTRLEN(PaymentServiceSetup.Name));
        PaymentServiceSetup.AssignPrimaryKey(PaymentServiceSetup);
        PaymentServiceSetup.INSERT(TRUE);
    end;
}
#endif
