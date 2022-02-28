#if not CLEAN20
codeunit 1086 "MS Wallet Install"
{
    Subtype = install;
    ObsoleteState = Pending;
    ObsoleteReason = 'MS Wallet have been deprecated';
    ObsoleteTag = '20.0';

    trigger OnInstallAppPerCompany()
    begin
        CompanyInitialize();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    begin
        ApplyEvaluationClassificationsForPrivacy();
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
        MSWalletMerchantAccount: Record "MS - Wallet Merchant Account";
        MSWalletPayment: Record "MS - Wallet Payment";
        MSWalletCharge: Record "MS - Wallet Charge";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MS - Wallet Merchant Account");
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - Wallet Merchant Account", MSWalletMerchantAccount.FieldNo("Merchant ID"));

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MS - Wallet Merchant Template");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MS - Wallet Payment");
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - Wallet Payment", MSWalletPayment.FieldNo("Merchant ID"));

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MS - Wallet Charge");
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - Wallet Charge", MSWalletCharge.FieldNo("Merchant ID"));
    end;
}
#endif