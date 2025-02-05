codeunit 17125 "Create AU Payment Method"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Payment Method", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertPaymentMethod(var Rec: Record "Payment Method"; RunTrigger: Boolean)
    var
        CreatePaymentMethod: Codeunit "Create Payment Method";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case Rec.Code of
            CreatePaymentMethod.Cash():
                ValidateRecordFields(Rec, CreateGLAccount.Cash());
        end;
    end;

    local procedure ValidateRecordFields(var PaymentMethod: Record "Payment Method"; BalAccountNo: Code[20])
    begin
        PaymentMethod.Validate("Bal. Account No.", BalAccountNo);
    end;
}