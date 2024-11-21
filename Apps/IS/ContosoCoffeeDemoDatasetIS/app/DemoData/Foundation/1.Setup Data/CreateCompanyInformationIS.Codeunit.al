codeunit 14607 "Create Company Information IS"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateCompanyInformation();
    end;

    local procedure UpdateCompanyInformation()
    begin
        ValidateRecordsFields(CityLbl, PostCodeLbl);
    end;

    local procedure ValidateRecordsFields(City: Text[30]; PostCode: Code[20])
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation.Validate(City, City);
        CompanyInformation.Validate("Post Code", PostCodeLbl);
        CompanyInformation.Validate("Ship-to City", City);
        CompanyInformation.Validate("Ship-to Post Code", PostCode);
        CompanyInformation.Modify(true);
    end;

    var
        CityLbl: Label 'Vesturvík', Maxlength = 30, Locked = true;
        PostCodeLbl: Label '999', MaxLength = 20;
}