codeunit 12202 "Create Payment Term IT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPayments: Codeunit "Contoso Payments";
    begin
        ContosoPayments.InsertPaymentTerms(PaymentTermsDAYS30X2(), '', '', 0, Net3060DaysDescLbl);
        ContosoPayments.InsertPaymentTerms(PaymentTermsDAYS30X3FM(), '', '', 0, Net306090DaysDescLbl);

        InsertPaymentLines();
    end;

    local procedure InsertPaymentLines()
    var
        PaymentLines: Record "Payment Lines";
        ContosoPaymentLines: Codeunit "Contoso Payment Lines";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
        DueDateCalculation: DateFormula;
        DiscountDateCalculation: DateFormula;
    begin
        Evaluate(DueDateCalculation, '<CM>');
        Evaluate(DiscountDateCalculation, '<0D>');
        ContosoPaymentLines.InsertPaymentLines(PaymentLines.Type::"Payment Terms", CreatePaymentTerms.PaymentTermsCM(), 10000, 100, DueDateCalculation,
                           DiscountDateCalculation, 0, PaymentLines."Sales/Purchase"::" ", '', 0);

        Evaluate(DueDateCalculation, '<0D>');
        ContosoPaymentLines.InsertPaymentLines(PaymentLines.Type::"Payment Terms", CreatePaymentTerms.PaymentTermsCOD(), 10000, 100, DueDateCalculation,
                           DiscountDateCalculation, 0, PaymentLines."Sales/Purchase"::" ", '', 0);

        Evaluate(DueDateCalculation, '<1M>');
        Evaluate(DiscountDateCalculation, '<8D>');
        ContosoPaymentLines.InsertPaymentLines(PaymentLines.Type::"Payment Terms", CreatePaymentTerms.PaymentTermsM8D(), 10000, 100, DueDateCalculation,
                           DiscountDateCalculation, 2, PaymentLines."Sales/Purchase"::" ", '', 0);

        Evaluate(DueDateCalculation, '<14D>');
        Evaluate(DiscountDateCalculation, '<0D>');
        ContosoPaymentLines.InsertPaymentLines(PaymentLines.Type::"Payment Terms", CreatePaymentTerms.PaymentTermsDAYS14(), 10000, 100, DueDateCalculation,
                           DiscountDateCalculation, 0, PaymentLines."Sales/Purchase"::" ", '', 0);

        Evaluate(DueDateCalculation, '<21D>');
        ContosoPaymentLines.InsertPaymentLines(PaymentLines.Type::"Payment Terms", CreatePaymentTerms.PaymentTermsDAYS21(), 10000, 100, DueDateCalculation,
                           DiscountDateCalculation, 0, PaymentLines."Sales/Purchase"::" ", '', 0);

        Evaluate(DueDateCalculation, '<30D>');
        ContosoPaymentLines.InsertPaymentLines(PaymentLines.Type::"Payment Terms", PaymentTermsDAYS30X2(), 10000, 50, DueDateCalculation,
                           DiscountDateCalculation, 0, PaymentLines."Sales/Purchase"::" ", '', 0);
        Evaluate(DueDateCalculation, '<60D>');
        ContosoPaymentLines.InsertPaymentLines(PaymentLines.Type::"Payment Terms", PaymentTermsDAYS30X2(), 20000, 50, DueDateCalculation,
                           DiscountDateCalculation, 0, PaymentLines."Sales/Purchase"::" ", '', 0);

        Evaluate(DueDateCalculation, '<30D+CM>');
        ContosoPaymentLines.InsertPaymentLines(PaymentLines.Type::"Payment Terms", PaymentTermsDAYS30X3FM(), 10000, 33.33, DueDateCalculation,
                           DiscountDateCalculation, 0, PaymentLines."Sales/Purchase"::" ", '', 0);
        Evaluate(DueDateCalculation, '<60D+CM>');
        ContosoPaymentLines.InsertPaymentLines(PaymentLines.Type::"Payment Terms", PaymentTermsDAYS30X3FM(), 20000, 33.33, DueDateCalculation,
                           DiscountDateCalculation, 0, PaymentLines."Sales/Purchase"::" ", '', 0);

        Evaluate(DueDateCalculation, '<90D+CM>');
        ContosoPaymentLines.InsertPaymentLines(PaymentLines.Type::"Payment Terms", PaymentTermsDAYS30X3FM(), 30000, 33.34, DueDateCalculation,
                           DiscountDateCalculation, 0, PaymentLines."Sales/Purchase"::" ", '', 0);

        Evaluate(DueDateCalculation, '<7D>');
        ContosoPaymentLines.InsertPaymentLines(PaymentLines.Type::"Payment Terms", CreatePaymentTerms.PaymentTermsDAYS7(), 10000, 100, DueDateCalculation,
                           DiscountDateCalculation, 0, PaymentLines."Sales/Purchase"::" ", '', 0);
    end;

    procedure PaymentTermsDAYS30X2(): code[10]
    begin
        exit(Days30X2Tok);
    end;

    procedure PaymentTermsDAYS30X3FM(): code[10]
    begin
        exit(Days30X3FMTok);
    end;

    var
        Days30X2Tok: Label '30X2', Locked = true;
        Days30X3FMTok: Label '30X3FM', Locked = true;
        Net3060DaysDescLbl: Label 'Net 30, 60 Days', MaxLength = 100;
        Net306090DaysDescLbl: Label 'Net 30,60,90 Days E.M.', MaxLength = 100;
}