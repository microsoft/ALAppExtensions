codeunit 5295 "Create Payment Method"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPayments: Codeunit "Contoso Payments";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoPayments.InsertBankPaymentMethod(Account(), PaymentAccountLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
        ContosoPayments.InsertBankPaymentMethod(Bank(), BankTransferLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
        ContosoPayments.InsertBankPaymentMethod(Bnkconvdom(), DomesticBanksLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
        ContosoPayments.InsertBankPaymentMethod(Bnkconvint(), InternationalBankLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
        ContosoPayments.InsertBankPaymentMethod(Card(), CardPaymentLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
        ContosoPayments.InsertBankPaymentMethod(Cash(), CashPaymentLbl, Enum::"Payment Balance Account Type"::"G/L Account", CreateGLAccount.Cash());
        ContosoPayments.InsertBankPaymentMethod(Check(), CheckPaymentLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
        ContosoPayments.InsertBankPaymentMethod(Giro(), GiroTransferLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
        ContosoPayments.InsertBankPaymentMethod(Intercom(), IntercompanyPaymentLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
        ContosoPayments.InsertBankPaymentMethod(Multiple(), MultiplePaymentMethodsLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
        ContosoPayments.InsertBankPaymentMethod(PayPal(), PayPalPaymentLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
    end;

    procedure Account(): Code[10]
    begin
        exit(AccountTok);
    end;

    procedure Bank(): Code[10]
    begin
        exit(BankTok);
    end;

    procedure Bnkconvdom(): Code[10]
    begin
        exit(BnkconvdomTok);
    end;

    procedure Bnkconvint(): Code[10]
    begin
        exit(BnkconvintTok);
    end;

    procedure Card(): Code[10]
    begin
        exit(CardTok);
    end;

    procedure Cash(): Code[10]
    begin
        exit(CashTok);
    end;

    procedure Check(): Code[10]
    begin
        exit(CheckTok);
    end;

    procedure Giro(): Code[10]
    begin
        exit(GiroTok);
    end;

    procedure Intercom(): Code[10]
    begin
        exit(IntercomTok);
    end;

    procedure Multiple(): Code[10]
    begin
        exit(MultipleTok);
    end;

    procedure PayPal(): Code[10]
    begin
        exit(PayPalTok);
    end;

    var
        AccountTok: Label 'ACCOUNT', MaxLength = 10;
        PaymentAccountLbl: Label 'Payment on account', MaxLength = 100;
        BankTok: Label 'BANK', MaxLength = 10;
        BankTransferLbl: Label 'Bank Transfer', MaxLength = 100;
        BnkconvdomTok: Label 'BNKCONVDOM', MaxLength = 10;
        DomesticBanksLbl: Label 'Bank Data Conversion for Domestic Banks', MaxLength = 100;
        BnkconvintTok: Label 'BNKCONVINT', MaxLength = 10;
        InternationalBankLbl: Label 'Bank Data Conversion for International Banks', MaxLength = 100;
        CardTok: Label 'CARD', MaxLength = 10;
        CardPaymentLbl: Label 'Card payment', MaxLength = 100;
        CashTok: Label 'CASH', MaxLength = 10;
        CashPaymentLbl: Label 'Cash payment', MaxLength = 100;
        CheckTok: Label 'CHECK', MaxLength = 10;
        CheckPaymentLbl: Label 'Check payment', MaxLength = 100;
        GiroTok: Label 'GIRO', MaxLength = 10;
        GiroTransferLbl: Label 'Giro transfer', MaxLength = 100;
        MultipleTok: Label 'MULTIPLE', MaxLength = 10;
        MultiplePaymentMethodsLbl: Label 'Multiple payment methods', MaxLength = 100;
        IntercomTok: Label 'INTERCOM', MaxLength = 10;
        IntercompanyPaymentLbl: Label 'Intercompany payment', MaxLength = 100;
        PayPalTok: Label 'PAYPAL', MaxLength = 10;
        PayPalPaymentLbl: Label 'PayPal payment', MaxLength = 100;
}