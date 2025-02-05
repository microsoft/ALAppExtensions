codeunit 10810 "Contoso ES Installment"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata Installment = rim;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertInstallment(PaymentTermsCode: Code[10]; LineNo: Integer; PercantageOfTotal: Decimal; GapBetweenInstallments: Code[20])
    var
        Installment: Record Installment;
        Exists: Boolean;
    begin
        if Installment.Get() then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Installment.Validate("Payment Terms Code", PaymentTermsCode);
        Installment.Validate("Line No.", LineNo);
        Installment.Validate("% of Total", PercantageOfTotal);
        Installment.Validate("Gap between Installments", GapBetweenInstallments);

        if Exists then
            Installment.Modify(true)
        else
            Installment.Insert(true);
    end;

    var
        OverwriteData: Boolean;
}