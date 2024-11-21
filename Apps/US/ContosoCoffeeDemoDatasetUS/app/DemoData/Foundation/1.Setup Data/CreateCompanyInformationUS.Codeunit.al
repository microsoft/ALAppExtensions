codeunit 11491 "Create Company Information US"
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
    begin
        CompanyInformation.Get();

        CompanyInformation.Validate(Address, SouthAshfordStreetLbl);
        CompanyInformation.Validate("Post Code", '31772');
        CompanyInformation.Validate(City, AtlantaLbl);
        CompanyInformation.Validate(County, GaLbl);
        CompanyInformation.Validate("Phone No.", '+1 425 555 0100');
        CompanyInformation.Validate("Fax No.", '+1 425 555 0101');
        CompanyInformation.Validate("Ship-to Address", SouthAshfordStreetLbl);
        CompanyInformation.Validate("Ship-to Post Code", '31772');
        CompanyInformation.Validate("Ship-to City", AtlantaLbl);
        CompanyInformation.Validate("Ship-to County", '');
        CompanyInformation.Validate("VAT Registration No.", '');
        Evaluate(CompanyInformation."Check-Avail. Period Calc.", '90D');
        CompanyInformation.Validate("Check-Avail. Period Calc.");
        CompanyInformation.Modify(true);
    end;

    var
        SouthAshfordStreetLbl: Label '7122 South Ashford Street', MaxLength = 100, Locked = true;
        AtlantaLbl: Label 'Atlanta', MaxLength = 30, Locked = true;
        GaLbl: Label 'GA', MaxLength = 30, Locked = true;
}