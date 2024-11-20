codeunit 11590 "Create CH Company Information"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    //TODO: Post Code hardcoded.
    trigger OnRun()
    begin
        UpdateCompanyInformation();
    end;

    local procedure UpdateCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        CompanyInformation.Get();

        CompanyInformation.Validate("Post Code", '6300');
        CompanyInformation.Validate(City, ZugCityLbl);
        CompanyInformation.Validate(County, '');
        CompanyInformation.Validate("Country/Region Code", ContosoCoffeeDemoDataSetup."Country/Region Code");
        CompanyInformation.Validate("Bank Branch No.", BankBranchNoLbl);
        CompanyInformation.Validate("Ship-to Post Code", '6300');
        CompanyInformation.Validate("Ship-to City", ZugCityLbl);
        CompanyInformation.Validate("Ship-to County", '');
        CompanyInformation.Validate("Ship-to Country/Region Code", ContosoCoffeeDemoDataSetup."Country/Region Code");
        CompanyInformation.Validate("VAT Registration No.", VATRegistrationNoLbl);
        CompanyInformation.Modify(true);
    end;

    var
        ZugCityLbl: Label 'Zug', MaxLength = 30, Locked = true;
        BankBranchNoLbl: Label '100', MaxLength = 20, Locked = true;
        VATRegistrationNoLbl: Label 'CHE-777.777.777MWST', MaxLength = 20, Locked = true;
}