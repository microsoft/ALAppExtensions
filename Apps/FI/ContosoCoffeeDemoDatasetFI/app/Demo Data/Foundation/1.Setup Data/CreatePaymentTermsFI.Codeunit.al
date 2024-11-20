codeunit 13438 "Create Payment Terms FI"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Payment Terms", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertPaymentTerms(var Rec: Record "Payment Terms")
    var
        CreatePaymentTerms: Codeunit "Create Payment Terms";
    begin
        case Rec.Code of
            CreatePaymentTerms.PaymentTermsM8D():
                ValidateRecordFields(Rec, true);
        end;
    end;

    local procedure ValidateRecordFields(var PaymentTerms: Record "Payment Terms"; DisregPmtDiscatFullPmt: Boolean)
    begin
        PaymentTerms.Validate("Disreg. Pmt. Disc. at Full Pmt", DisregPmtDiscatFullPmt);
    end;
}