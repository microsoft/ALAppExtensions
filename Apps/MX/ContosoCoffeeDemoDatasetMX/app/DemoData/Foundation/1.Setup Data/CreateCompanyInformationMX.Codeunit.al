codeunit 14102 "Create Company Information MX"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateCompanyInformation();
    end;

    local procedure UpdateCompanyInformation()
    begin
        ValidateRecordSEelds(CityLbl, PostCodeLbl, VatRegNoLbl);
    end;

    local procedure ValidateRecordSEelds(City: Text[30]; PostCode: Code[20]; VatRegNo: Text[20])
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();

        CompanyInformation.Validate(City, City);
        CompanyInformation.Validate("Post Code", PostCodeLbl);
        CompanyInformation.Validate("Ship-to City", City);
        CompanyInformation.Validate("Ship-to Post Code", PostCode);
        CompanyInformation.Validate("VAT Registration No.", VatRegNo);
        CompanyInformation.Modify(true);
    end;

    var
        CityLbl: Label 'Mexico City', Maxlength = 30, Locked = true;
        PostCodeLbl: Label '01030', MaxLength = 20;
        VatRegNoLbl: Label 'MX777777777', MaxLength = 20;
}