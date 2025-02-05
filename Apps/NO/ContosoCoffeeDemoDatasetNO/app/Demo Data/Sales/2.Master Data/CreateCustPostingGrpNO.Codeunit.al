codeunit 10713 "Create Cust. Posting Grp NO"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCustomerPostingGrp(var Rec: Record "Customer Posting Group")
    var
        CreateCustomerPostingGrp: Codeunit "Create Customer Posting Group";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case Rec.Code of
            CreateCustomerPostingGrp.Domestic(),
            CreateCustomerPostingGrp.Foreign():
                ValidateCustomerPostingGroup(Rec, CreateGLAccount.PaymentDiscountsReceived(), CreateGLAccount.PaymentToleranceReceived());
        end;
    end;

    local procedure ValidateCustomerPostingGroup(var CustomerPostingGroup: Record "Customer Posting Group"; PaymentDiscCreditAcc: Code[20]; PaymentToleranceCreditAcc: Code[20])
    begin
        CustomerPostingGroup.Validate("Payment Disc. Credit Acc.", PaymentDiscCreditAcc);
        CustomerPostingGroup.Validate("Payment Tolerance Credit Acc.", PaymentToleranceCreditAcc);
    end;
}