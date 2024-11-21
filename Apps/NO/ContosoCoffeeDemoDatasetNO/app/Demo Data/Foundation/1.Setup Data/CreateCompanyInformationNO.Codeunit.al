codeunit 10705 "Create Company Information NO"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    begin
        UpdateCompanyInformation();
    end;

    local procedure UpdateCompanyInformation()
    begin
        ValidateRecordSEelds(CityLbl, PostCodeLbl, VatRegNoLbl, SwiftCodeLbl);
    end;

    local procedure ValidateRecordSEelds(City: Text[30]; PostCode: Code[20]; VatRegNo: Text[20]; SwiftCode: Code[20])
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation.Validate(City, City);
        CompanyInformation.Validate("Post Code", PostCodeLbl);
        CompanyInformation.Validate("Ship-to City", City);
        CompanyInformation.Validate("Ship-to Post Code", PostCode);
        CompanyInformation.Validate("VAT Registration No.", VatRegNo);
        CompanyInformation.Validate("SWIFT Code", SwiftCode);
        CompanyInformation.Modify(true);
    end;

    var
        CityLbl: Label 'OSLO', Maxlength = 30, Locked = true;
        PostCodeLbl: Label '0102', MaxLength = 20;
        SwiftCodeLbl: Label 'DBASBANO00ABC', MaxLength = 20;
        VatRegNoLbl: Label 'NO 777 777 777', MaxLength = 20;
}