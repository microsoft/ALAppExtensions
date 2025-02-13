codeunit 17108 "Create NZ Payment Terms"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Payment Terms", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecords(var Rec: Record "Payment Terms")
    var
        CreatePaymentTerms: Codeunit "Create Payment Terms";
    begin
        case Rec.Code of
            CreatePaymentTerms.PaymentTermsDAYS30():
                ValidateRecordFields(Rec, EndofNextMonthLbl, Days30DueDateCalculationLbl);
        end;
    end;

    local procedure ValidateRecordFields(var PaymentTerms: Record "Payment Terms"; Description: Text[100]; DueDateCalculation: Text[10])
    begin
        PaymentTerms.Validate(Description, Description);
        Evaluate(PaymentTerms."Due Date Calculation", DueDateCalculation);
        PaymentTerms.Validate("Due Date Calculation");
    end;

    var
        EndofNextMonthLbl: Label 'End of Next Month', MaxLength = 100;
        Days30DueDateCalculationLbl: Label '1M+CM', MaxLength = 10;
}