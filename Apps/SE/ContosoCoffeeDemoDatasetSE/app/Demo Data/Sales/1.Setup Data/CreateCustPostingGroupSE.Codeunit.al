codeunit 11228 "Create Cust. Posting Group SE"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCustPostingGroup(var Rec: Record "Customer Posting Group")
    var
        CreateCustomerPostingGroup: Codeunit "Create Customer Posting Group";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case Rec.Code of
            CreateCustomerPostingGroup.Domestic(),
            CreateCustomerPostingGroup.EU(),
            CreateCustomerPostingGroup.Foreign():
                ValidateRecordFields(Rec, CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted());
        end;
    end;

    procedure ValidateRecordFields(var CustomerPostingGroup: Record "Customer Posting Group"; PaymentToleranceDebitAcc: Code[20]; PaymentToleranceCreditAcc: Code[20])
    begin
        CustomerPostingGroup.Validate("Payment Tolerance Debit Acc.", PaymentToleranceDebitAcc);
        CustomerPostingGroup.Validate("Payment Tolerance Credit Acc.", PaymentToleranceCreditAcc);
    end;
}