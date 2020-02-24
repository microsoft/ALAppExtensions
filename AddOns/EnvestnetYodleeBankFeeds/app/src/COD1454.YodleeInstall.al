codeunit 1454 "Yodlee Install"
{
    Subtype = install;

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
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        Company: Record Company;
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MS - Yodlee Bank Service Setup");
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - Yodlee Bank Service Setup", MSYodleeBankServiceSetup.FieldNo("Service URL"));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - Yodlee Bank Service Setup", MSYodleeBankServiceSetup.FieldNo("Bank Acc. Linking URL"));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - Yodlee Bank Service Setup", MSYodleeBankServiceSetup.FieldNo("User Profile Email Address"));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - Yodlee Bank Service Setup", MSYodleeBankServiceSetup.FieldNo("Cobrand Name"));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - Yodlee Bank Service Setup", MSYodleeBankServiceSetup.FieldNo("Cobrand Password"));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - Yodlee Bank Service Setup", MSYodleeBankServiceSetup.FieldNo("Consumer Name"));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - Yodlee Bank Service Setup", MSYodleeBankServiceSetup.FieldNo("Consumer Password"));

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MS - Yodlee Bank Acc. Link");
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - Yodlee Bank Acc. Link", MSYodleeBankAccLink.FieldNo("Bank Account No."));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - Yodlee Bank Acc. Link", MSYodleeBankAccLink.FieldNo(Contact));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - Yodlee Bank Acc. Link", MSYodleeBankAccLink.FieldNo("Online Bank Account ID"));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - Yodlee Bank Acc. Link", MSYodleeBankAccLink.FieldNo("Temp Linked Bank Account No."));

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MS - Yodlee Data Exchange Def");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MS - Yodlee Bank Session");
    end;

}