codeunit 12231 "Create Payment Method IT"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPayments: Codeunit "Contoso Payments";
        CreateSourceCodeIT: Codeunit "Create Source Code IT";
        CreateBillCodeIT: Codeunit "Create Bill Code IT";
    begin
        ContosoPayments.SetOverwriteData(true);
        ContosoPayments.InsertBankPaymentMethod(CreateSourceCodeIT.BankTransf(), BankTransferLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
        ContosoPayments.InsertBankPaymentMethod(CreateSourceCodeIT.RIBA(), BankReceiptLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
        ContosoPayments.InsertBankPaymentMethod(BnkDomConv(), DomesticBankTransferWithDataConversionLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
        ContosoPayments.InsertBankPaymentMethod(BnkIntConv(), InternationalBankTransferWithDataConversionLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
        ContosoPayments.SetOverwriteData(false);

        UpdateBillCode(CreateSourceCodeIT.BankTransf(), CreateBillCodeIT.BB(), '');
        UpdateBillCode(CreateSourceCodeIT.RIBA(), CreateBillCodeIT.RB(), '');
        UpdateBillCode(BnkDomConv(), '', BankDataConvServctLbl);
        UpdateBillCode(BnkIntConv(), '', BankDataConvServctLbl);
    end;

    local procedure UpdateBillCode(Code: Code[20]; BillCode: Code[20]; PmtExportLineDefinition: Code[20])
    var
        PaymentMethod: Record "Payment Method";
    begin
        PaymentMethod.Get(Code);
        PaymentMethod.Validate("Bill Code", BillCode);
        PaymentMethod.Validate("Pmt. Export Line Definition", PmtExportLineDefinition);
        PaymentMethod.Modify(true);
    end;

    procedure BnkIntConv(): Code[10]
    begin
        exit(BnkIntConvTok);
    end;

    procedure BnkDomConv(): Code[10]
    begin
        exit(BnkDomConvTok);
    end;

    var
        BnkDomConvTok: Label 'BNKDOMCONV', MaxLength = 10;
        BnkIntConvTok: Label 'BNKINTCONV', MaxLength = 10;
        BankDataConvServctLbl: Label 'BANKDATACONVSERVCT', MaxLength = 20;
        InternationalBankTransferWithDataConversionLbl: Label 'International Bank Transfer with Data Conversion', MaxLength = 100;
        DomesticBankTransferWithDataConversionLbl: Label 'Domestic Bank Transfer with Data Conversion', MaxLength = 100;
        BankTransferLbl: Label 'Bank Transfer', MaxLength = 100;
        BankReceiptLbl: Label 'Bank Receipt', MaxLength = 100;
}