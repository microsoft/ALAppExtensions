codeunit 10811 "Create ES Installment"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoESInstallment: Codeunit "Contoso ES Installment";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
        CreateESPaymentTerms: Codeunit "Create ES Payment Terms";
    begin
        ContosoESInstallment.SetOverwriteData(true);
        ContosoESInstallment.InsertInstallment(CreatePaymentTerms.PaymentTermsDAYS14(), 1, 100, '');
        ContosoESInstallment.InsertInstallment(CreatePaymentTerms.PaymentTermsM8D(), 1, 100, '');
        ContosoESInstallment.InsertInstallment(CreateESPaymentTerms.PaymentTermsDays1x30(), 1, 100, '');
        ContosoESInstallment.InsertInstallment(CreatePaymentTerms.PaymentTermsDAYS21(), 1, 100, '');
        ContosoESInstallment.InsertInstallment(CreateESPaymentTerms.PaymentTermsDAYS2x45(), 1, 50, '<45D>');
        ContosoESInstallment.InsertInstallment(CreateESPaymentTerms.PaymentTermsDAYS2x45(), 2, 50, '');
        ContosoESInstallment.InsertInstallment(CreateESPaymentTerms.PaymentTermsDAYS3x30(), 1, 55, '<30D>');
        ContosoESInstallment.InsertInstallment(CreateESPaymentTerms.PaymentTermsDAYS3x30(), 2, 30, '<30D>');
        ContosoESInstallment.InsertInstallment(CreateESPaymentTerms.PaymentTermsDAYS3x30(), 3, 15, '');
        ContosoESInstallment.InsertInstallment(CreatePaymentTerms.PaymentTermsDAYS7(), 1, 100, '');
        ContosoESInstallment.InsertInstallment(CreatePaymentTerms.PaymentTermsCM(), 1, 100, '');
        ContosoESInstallment.InsertInstallment(CreatePaymentTerms.PaymentTermsCOD(), 1, 100, '');
        ContosoESInstallment.SetOverwriteData(false);
    end;
}