codeunit 31263 "Upgrade Application CZC"
{
    Subtype = Upgrade;

    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitionsCZC: Codeunit "Upgrade Tag Definitions CZC";

    trigger OnUpgradePerDatabase()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();
        SetDatabaseUpgradeTags();
    end;

    trigger OnUpgradePerCompany()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();
        UpgradeCompensationLanguage();
        UpgradePostedCompensationLanguage();
        SetCompanyUpgradeTags();
    end;

    local procedure UpgradeCompensationLanguage()
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZC.GetCompensationLanguageCodeUpgradeTag()) then
            exit;

        CompensationHeaderCZC.SetLoadFields("Company Type", "Company No.", "Language Code");
        if CompensationHeaderCZC.FindSet(true) then
            repeat
                CompensationHeaderCZC."Language Code" :=
                    GetLanguageCode(CompensationHeaderCZC."Company Type", CompensationHeaderCZC."Company No.");
                CompensationHeaderCZC.Modify();
            until CompensationHeaderCZC.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZC.GetCompensationLanguageCodeUpgradeTag());
    end;

    local procedure UpgradePostedCompensationLanguage()
    var
        PostedCompensationHeaderCZC: Record "Posted Compensation Header CZC";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZC.GetPostedCompensationLanguageCodeUpgradeTag()) then
            exit;

        PostedCompensationHeaderCZC.SetLoadFields("Company Type", "Company No.", "Language Code");
        if PostedCompensationHeaderCZC.FindSet(true) then
            repeat
                PostedCompensationHeaderCZC."Language Code" :=
                    GetLanguageCode(PostedCompensationHeaderCZC."Company Type", PostedCompensationHeaderCZC."Company No.");
                PostedCompensationHeaderCZC.Modify();
            until PostedCompensationHeaderCZC.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZC.GetPostedCompensationLanguageCodeUpgradeTag());
    end;

    internal procedure GetLanguageCode(CompanyType: Enum "Compensation Company Type CZC"; CompanyNo: Code[20]): Code[10]
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Contact: Record Contact;
    begin
        case CompanyType of
            CompanyType::Customer:
                begin
                    Customer.SetLoadFields("Language Code");
                    if Customer.Get(CompanyNo) then
                        exit(Customer."Language Code");
                end;
            CompanyType::Contact:
                begin
                    Contact.SetLoadFields("Language Code");
                    if Contact.Get(CompanyNo) then
                        exit(Contact."Language Code");
                end;
            CompanyType::Vendor:
                begin
                    Vendor.SetLoadFields("Language Code");
                    if Vendor.Get(CompanyNo) then
                        exit(Vendor."Language Code");
                end;
        end;
    end;

    local procedure SetDatabaseUpgradeTags();
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZC.GetDataVersion180PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZC.GetDataVersion180PerDatabaseUpgradeTag());
    end;

    local procedure SetCompanyUpgradeTags();
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZC.GetDataVersion180PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZC.GetDataVersion180PerCompanyUpgradeTag());
    end;
}
