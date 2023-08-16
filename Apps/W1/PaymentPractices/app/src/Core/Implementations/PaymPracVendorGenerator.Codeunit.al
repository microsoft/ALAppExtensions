codeunit 691 "Paym. Prac. Vendor Generator" implements PaymentPracticeDataGenerator
{
    Access = Internal;

    procedure GenerateData(var PaymentPracticeData: Record "Payment Practice Data"; PaymentPracticeHeader: Record "Payment Practice Header")
    var
        PaymentPracticeBuilders: Codeunit "Payment Practice Builders";
    begin
        PaymentPracticeBuilders.BuildPaymentPracticeDataForVendor(PaymentPracticeData, PaymentPracticeHeader);
    end;
}