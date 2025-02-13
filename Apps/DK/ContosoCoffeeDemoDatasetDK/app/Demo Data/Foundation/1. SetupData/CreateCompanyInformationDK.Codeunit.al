codeunit 13702 "Create Company Information DK"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateCompanyInformation();
    end;

    local procedure UpdateCompanyInformation()
    begin
        ValidateRecordFields(VATRegNoLbl, CityLbl, PostcodeLbl, '<90D>', RegNoLbl);
    end;

    local procedure ValidateRecordFields(VATRegistrationNo: Text[20]; City: Text[30]; PostCode: Code[20]; CheckAvailPeriodCalc: Text; RegNo: Text[20])
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation.Validate("VAT Registration No.", VATRegistrationNo);
        CompanyInformation.Validate(City, City);
        CompanyInformation.Validate("Post Code", PostcodeLbl);
        CompanyInformation.Validate("Ship-to City", City);
        CompanyInformation.Validate("Ship-to Post Code", PostCode);
        Evaluate(CompanyInformation."Check-Avail. Period Calc.", CheckAvailPeriodCalc);
        CompanyInformation.Validate("Check-Avail. Period Calc.");
        CompanyInformation.Validate("Registration No.", RegNo);
        CompanyInformation.Modify(true);
    end;

    var
        CityLbl: Label 'Kugleby', Maxlength = 30;
        PostcodeLbl: Label '9900', MaxLength = 20;
        VATRegNoLbl: Label 'DK77777777', MaxLength = 20;
        RegNoLbl: Label '12345678', MaxLength = 20;
}
