codeunit 11547 "Create Payment Method NL"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Payment Method", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertPaymentMethod(var Rec: Record "Payment Method"; RunTrigger: Boolean)
    var
        CreatePaymentMethod: Codeunit "Create Payment Method";
        CreateNLGLAccounts: Codeunit "Create NL GL Accounts";
    begin
        case Rec.Code of
            CreatePaymentMethod.Cash():
                ValidateRecordFields(Rec, CreateNLGLAccounts.PettyCash());
        end;
    end;

    local procedure ValidateRecordFields(var PaymentMethod: Record "Payment Method"; BalAccountNo: Code[20])
    begin
        PaymentMethod.Validate("Bal. Account No.", BalAccountNo);
    end;
}