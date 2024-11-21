codeunit 5206 "Create Payment Terms"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPayments: Codeunit "Contoso Payments";
    begin
        ContosoPayments.InsertPaymentTerms(PaymentTermsCM(), '<CM>', '', 0, CurrentMonthLbl);
        ContosoPayments.InsertPaymentTerms(PaymentTermsCOD(), '<0D>', '', 0, CashOnDeliveryLbl);
        ContosoPayments.InsertPaymentTerms(PaymentTermsM8D(), '<1M>', '<8D>', 2, Month2Percent8DaysLbl);
        ContosoPayments.InsertPaymentTerms(PaymentTermsDAYS2(), '<2D>', '', 0, Net2DaysLbl);
        ContosoPayments.InsertPaymentTerms(PaymentTermsDAYS7(), '<7D>', '', 0, Net7DaysLbl);
        ContosoPayments.InsertPaymentTerms(PaymentTermsDAYS10(), '<10D>', '', 0, Net10DaysLbl);
        ContosoPayments.InsertPaymentTerms(PaymentTermsDAYS14(), '<14D>', '', 0, Net14DaysLbl);
        ContosoPayments.InsertPaymentTerms(PaymentTermsDAYS15(), '<15D>', '', 0, Net15DaysLbl);
        ContosoPayments.InsertPaymentTerms(PaymentTermsDAYS21(), '<21D>', '', 0, Net21DaysLbl);
        ContosoPayments.InsertPaymentTerms(PaymentTermsDAYS30(), '<30D>', '', 0, Net30DaysLbl);
        ContosoPayments.InsertPaymentTerms(PaymentTermsDAYS60(), '<60D>', '', 0, Net60DaysLbl);
    end;

    procedure PaymentTermsCM(): code[10]
    begin
        exit(CMTok);
    end;

    procedure PaymentTermsCOD(): code[10]
    begin
        exit(CODTok);
    end;

    procedure PaymentTermsM8D(): code[10]
    begin
        exit(M8DTok);
    end;

    procedure PaymentTermsDAYS2(): code[10]
    begin
        exit(Days2Tok);
    end;

    procedure PaymentTermsDAYS7(): code[10]
    begin
        exit(Days7Tok);
    end;

    procedure PaymentTermsDAYS10(): code[10]
    begin
        exit(Days10Tok);
    end;

    procedure PaymentTermsDAYS14(): code[10]
    begin
        exit(Days14Tok);
    end;

    procedure PaymentTermsDAYS15(): code[10]
    begin
        exit(Days15Tok);
    end;

    procedure PaymentTermsDAYS21(): code[10]
    begin
        exit(Days21Tok);
    end;

    procedure PaymentTermsDAYS30(): code[10]
    begin
        exit(Days30Tok);
    end;

    procedure PaymentTermsDAYS60(): code[10]
    begin
        exit(Days60Tok);
    end;

    var
        CMTok: Label 'CM', MaxLength = 10;
        CODTok: Label 'COD', MaxLength = 10;
        M8DTok: Label '1M(8D)', MaxLength = 10;
        Days2Tok: Label '2 DAYS', MaxLength = 10;
        Days7Tok: Label '7 DAYS', MaxLength = 10;
        Days10Tok: Label '10 DAYS', MaxLength = 10;
        Days14Tok: Label '14 DAYS', MaxLength = 10;
        Days15Tok: Label '15 DAYS', MaxLength = 10;
        Days21Tok: Label '21 DAYS', MaxLength = 10;
        Days30Tok: Label '30 DAYS', MaxLength = 10;
        Days60Tok: Label '60 DAYS', MaxLength = 10;
        CurrentMonthLbl: Label 'Current Month', MaxLength = 100;
        CashOnDeliveryLbl: Label 'Cash on delivery', MaxLength = 100;
        Month2Percent8DaysLbl: Label '1 Month/2% 8 days', MaxLength = 100;
        Net2DaysLbl: Label 'Net 2 days', MaxLength = 100;
        Net7DaysLbl: Label 'Net 7 days', MaxLength = 100;
        Net10DaysLbl: Label 'Net 10 days', MaxLength = 100;
        Net14DaysLbl: Label 'Net 14 days', MaxLength = 100;
        Net15DaysLbl: Label 'Net 15 days', MaxLength = 100;
        Net21DaysLbl: Label 'Net 21 days', MaxLength = 100;
        Net30DaysLbl: Label 'Net 30 days', MaxLength = 100;
        Net60DaysLbl: Label 'Net 60 days', MaxLength = 100;
}