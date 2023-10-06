namespace Microsoft.Payroll.Ceridian;

using System.Upgrade;

codeunit 1665 "MS Ceridian Payroll upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeSecretsToIsolatedStorage();
    end;

    trigger OnValidateUpgradePerCompany()
    begin
        VerifySecretsUpgradeToIsolatedStorage();
    end;

    local procedure UpgradeSecretsToIsolatedStorage()
    var
        ServicePassword: Record "Service Password";
        MsCeridianPayrollSetup: Record "MS Ceridian Payroll Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetCeridianSecretsToISUpgradeTag(), '') then
            exit;

        if UpgradeTag.HasUpgradeTag(GetCeridianSecretsToISUpgradeTag()) then
            exit;

        if MsCeridianPayrollSetup.Get() then
            if ServicePassword.Get(MsCeridianPayrollSetup."Password Key") then
                if EncryptionEnabled() then
                    IsolatedStorage.SetEncrypted(MsCeridianPayrollSetup."Password Key", ServicePassword.GetPassword(), DataScope::Company)
                else
                    IsolatedStorage.Set(MsCeridianPayrollSetup."Password Key", ServicePassword.GetPassword(), DataScope::Company);

        UpgradeTag.SetUpgradeTag(GetCeridianSecretsToISUpgradeTag());
    end;

    local procedure VerifySecretsUpgradeToIsolatedStorage()
    var
        ServicePassword: Record "Service Password";
        MsCeridianPayrollSetup: Record "MS Ceridian Payroll Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
        IsolatedStorageValue: Text;
        ServicePasswordValue: Text;
    begin
        if UpgradeTag.HasUpgradeTag(GetCeridianSecretsToISValidationTag(), '') then
            exit;

        if UpgradeTag.HasUpgradeTag(GetCeridianSecretsToISValidationTag()) then
            exit;

        if MsCeridianPayrollSetup.Get() then
            if ServicePassword.Get(MsCeridianPayrollSetup."Password Key") then begin
                if not IsolatedStorage.Get(MsCeridianPayrollSetup."Password Key", DataScope::Company, IsolatedStorageValue) then
                    Error('Could not retrieve the secret from isolated storage after the Upgrade for key "%1"', MsCeridianPayrollSetup."Password Key");
                ServicePasswordValue := ServicePassword.GetPassword();
                if IsolatedStorageValue <> ServicePasswordValue then
                    Error('The secret value for key "%1" in isolated storage does not match the one in service password.', MsCeridianPayrollSetup."Password Key");
            end;

        UpgradeTag.SetUpgradeTag(GetCeridianSecretsToISValidationTag());
    end;

    internal procedure GetCeridianSecretsToISUpgradeTag(): Code[250]
    begin
        exit('MS-328257-CeridianSecretsToIS-20190925');
    end;

    internal procedure GetCeridianSecretsToISValidationTag(): Code[250]
    begin
        exit('MS-328257-CeridianSecretsToIS-Validate-20190925');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetCeridianSecretsToISUpgradeTag());
        PerCompanyUpgradeTags.Add(GetCeridianSecretsToISValidationTag());
    end;
}

