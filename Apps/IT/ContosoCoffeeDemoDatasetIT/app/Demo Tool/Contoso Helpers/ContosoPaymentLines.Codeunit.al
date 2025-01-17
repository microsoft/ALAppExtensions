codeunit 12223 "Contoso Payment Lines"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Payment Lines" = rim;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertPaymentLines(Type: Enum "Payment Lines Document Type"; Code: Code[10]; LineNo: Integer; PaymentPerc: Decimal; DueDateCalculation: DateFormula; DiscountDateCalculation: DateFormula; DiscountPerc: Decimal; SalesPurchase: Option; JournalTemplateName: Code[10]; JournalLineNo: Integer)
    var
        PaymentLines: Record "Payment Lines";
        Exists: Boolean;
    begin
        if PaymentLines.Get(SalesPurchase, Type, Code, JournalTemplateName, JournalLineNo, LineNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        PaymentLines.Validate(Type, Type);
        PaymentLines.Validate(Code, Code);
        PaymentLines.Validate("Line No.", LineNo);
        PaymentLines.Validate("Payment %", PaymentPerc);
        PaymentLines.Validate("Due Date Calculation", DueDateCalculation);
        PaymentLines.Validate("Discount Date Calculation", DiscountDateCalculation);
        PaymentLines.Validate("Discount %", DiscountPerc);
        PaymentLines.Validate("Sales/Purchase", SalesPurchase);
        PaymentLines.Validate("Journal Template Name", JournalTemplateName);
        PaymentLines.Validate("Journal Line No.", JournalLineNo);

        if Exists then
            PaymentLines.Modify(true)
        else
            PaymentLines.Insert(true);
    end;

    var
        OverwriteData: Boolean;
}