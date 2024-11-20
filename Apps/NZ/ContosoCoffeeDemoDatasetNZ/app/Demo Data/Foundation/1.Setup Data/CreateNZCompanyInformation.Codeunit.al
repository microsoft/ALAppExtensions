codeunit 17110 "Create NZ Company Information"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateCompanyInformation();
    end;

    local procedure UpdateCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
    begin
        CompanyInformation.Get();
        ContosoCoffeeDemoDataSetup.Get();

        CompanyInformation.Validate(City, CityLbl);
        CompanyInformation.Validate("Post Code", '1015');
        CompanyInformation.Validate("Ship-to Post Code", '1015');
        CompanyInformation.Validate("Ship-to City", CityLbl);
        CompanyInformation.Validate("Country/Region Code", ContosoCoffeeDemoDataSetup."Country/Region Code");
        CompanyInformation.Validate("Ship-to Country/Region Code", ContosoCoffeeDemoDataSetup."Country/Region Code");
        CompanyInformation.Modify(true);
    end;

    var
        CityLbl: Label 'Auckland', MaxLength = 30;
}