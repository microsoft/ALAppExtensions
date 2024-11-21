codeunit 11516 "Create Company Information NL"
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
        CityLbl: Label 'Apeldoorn', Maxlength = 30, Locked = true;
        PostCodeLbl: Label '1111 DA', MaxLength = 20;
        VatRegNoLbl: Label 'NL777777770B77', MaxLength = 20;
}