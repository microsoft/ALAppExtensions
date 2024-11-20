codeunit 10813 "Create ES Payment Method"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPayments: Codeunit "Contoso Payments";
    begin
        ContosoPayments.SetOverwriteData(true);
        ContosoPayments.InsertBankPaymentMethod(BnkDomConv(), DomesticBanksLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
        ContosoPayments.InsertBankPaymentMethod(BnkIntConv(), InternationalBankLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
        ContosoPayments.InsertBankPaymentMethod(Efecto(), NegotiableBillLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
        ContosoPayments.InsertBankPaymentMethod(Pagare(), PromissoryNoteLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
        ContosoPayments.SetOverwriteData(false);
        UpdatePaymentMethod(Efecto(), true, 1, Enum::"ES Bill Type"::"Bill of Exchange");
        UpdatePaymentMethod(Pagare(), true, 1, Enum::"ES Bill Type"::IOU);
    end;

    local procedure UpdatePaymentMethod(PaymentMethodCode: Code[10]; CreateBills: Boolean; CollectionAgent: option; BillType: Enum "ES Bill Type")
    var
        PaymentMethod: Record "Payment Method";
    begin
        if not PaymentMethod.Get(PaymentMethodCode) then
            exit;

        PaymentMethod.Validate("Create Bills", CreateBills);
        PaymentMethod.Validate("Collection Agent", CollectionAgent);
        PaymentMethod.Validate("Bill Type", BillType);
        PaymentMethod.Modify(true);
    end;

    procedure BnkDomConv(): Code[10]
    begin
        exit(BnkDomConvTok);
    end;

    procedure BnkIntConv(): Code[10]
    begin
        exit(BnkIntConvTok);
    end;

    procedure Efecto(): Code[10]
    begin
        exit(EfectoTok);
    end;

    procedure Pagare(): Code[10]
    begin
        exit(PagareTok);
    end;

    var
        EfectoTok: Label 'EFECTO', MaxLength = 10;
        PagareTok: Label 'PAGARE', MaxLength = 10;
        BnkDomConvTok: Label 'BNKDOMCONV', MaxLength = 10;
        DomesticBanksLbl: Label 'Domestic Bank Transfer with Data Conversion', MaxLength = 100;
        BnkIntConvTok: Label 'BNKINTCONV', MaxLength = 10;
        InternationalBankLbl: Label 'International Bank Transfer with Data Conversion', MaxLength = 100;
        NegotiableBillLbl: Label 'Negotiable Bill', MaxLength = 100;
        PromissoryNoteLbl: Label 'Promissory Note', MaxLength = 100;
}