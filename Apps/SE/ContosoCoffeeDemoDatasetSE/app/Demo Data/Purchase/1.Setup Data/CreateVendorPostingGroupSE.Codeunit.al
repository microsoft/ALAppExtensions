codeunit 11224 "Create Vendor Posting Group SE"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVendorPostingGroup(var Rec: Record "Vendor Posting Group")
    var
        CreateVendorPostingGroup: Codeunit "Create Vendor Posting Group";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case Rec.Code of

            CreateVendorPostingGroup.Domestic(),
              CreateVendorPostingGroup.EU():
                ValidateRecordFields(Rec, CreateGLAccount.VendorsDomestic(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted());
            CreateVendorPostingGroup.Foreign():
                ValidateRecordFields(Rec, CreateGLAccount.VendorsForeign(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted());
        end;
    end;

    local procedure ValidateRecordFields(var VendorPostingGroup: Record "Vendor Posting Group"; PayablesAccount: Code[20]; PaymentToleranceDebitAcc: Code[20]; PaymentToleranceCreditAcc: Code[20])
    begin
        VendorPostingGroup.Validate("Payables Account", PayablesAccount);
        VendorPostingGroup.Validate("Payment Tolerance Debit Acc.", PaymentToleranceDebitAcc);
        VendorPostingGroup.Validate("Payment Tolerance Credit Acc.", PaymentToleranceCreditAcc);
    end;
}