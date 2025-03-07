codeunit 19058 "Create IN Payment Method"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPayments: Codeunit "Contoso Payments";
    begin
        ContosoPayments.InsertBankPaymentMethod(Cheque(), ChequePaymentLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
    end;

    procedure Cheque(): Code[10]
    begin
        exit(ChequeTok);
    end;

    var
        ChequeTok: Label 'CHEQUE', MaxLength = 10;
        ChequePaymentLbl: Label 'Cheque payment', MaxLength = 100;
}