codeunit 17110 "Create AU Payment Terms"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Payment Terms", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecords(var Rec: Record "Payment Terms"; RunTrigger: Boolean)
    var
        CreatePaymentTerms: Codeunit "Create Payment Terms";
    begin
        case Rec.Code of
            CreatePaymentTerms.PaymentTermsDAYS30():
                ValidateRecordFields(Rec, '<1M+CM>', EndOfNextMonthLbl);
        end;
    end;

    local procedure ValidateRecordFields(var PaymentTerms: Record "Payment Terms"; DueDateCalculation: Text[30]; Description: Text[100])
    begin
        Evaluate(PaymentTerms."Due Date Calculation", DueDateCalculation);
        PaymentTerms.Validate("Due Date Calculation");
        PaymentTerms.Validate(Description, Description);
    end;

    var
        EndOfNextMonthLbl: Label 'End of Next Month', MaxLength = 100;
}