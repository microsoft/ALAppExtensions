codeunit 17114 "Create AU Company Information"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
    begin
        UpdateCompanyInformation();
    end;

    local procedure UpdateCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();

        CompanyInformation.Validate(City, CityLbl);
        CompanyInformation.Validate("Ship-to City", CityLbl);
        CompanyInformation.Validate("Post Code", '2600');
        CompanyInformation.Validate(County, NewSouthWalesCountyLbl);
        CompanyInformation.Validate("Ship-to Post Code", '2600');
        CompanyInformation.Validate("Ship-to County", NewSouthWalesCountyLbl);
        CompanyInformation.Validate(ABN, '53001003000');
        CompanyInformation.Modify(true);
    end;

    var
        CityLbl: Label 'CANBERRA', MaxLength = 30;
        NewSouthWalesCountyLbl: Label 'NSW', MaxLength = 10;
}