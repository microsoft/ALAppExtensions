codeunit 11181 "Create Payment Term AT"
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

    local procedure ValidateRecordFields(var PaymentTerms: Record "Payment Terms"; CalcPmtDisc: Boolean)
    begin
        PaymentTerms.Validate("Calc. Pmt. Disc. on Cr. Memos", CalcPmtDisc);
    end;
}