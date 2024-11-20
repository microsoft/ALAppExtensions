codeunit 10785 "Create ES Company Information"
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

        CompanyInformation.Validate(Address, AddressLbl);
        CompanyInformation.Validate("Address 2", Address2Lbl);
        CompanyInformation.Validate(City, CityLbl);
        CompanyInformation.Validate("Phone No.", '91-2229788');
        CompanyInformation.Validate("Fax No.", '91-2229700');
        CompanyInformation.Validate("Giro No.", '');
        CompanyInformation.Validate("Bank Name", '');
        CompanyInformation.Validate("Bank Branch No.", '');
        CompanyInformation.Validate("Bank Account No.", '');
        CompanyInformation.Validate("Payment Routing No.", '');
        CompanyInformation.Validate("VAT Registration No.", VatRegistrationLbl);
        CompanyInformation.Validate("Post Code", '28023');
        CompanyInformation.Validate("Ship-to Post Code", '28023');
        CompanyInformation.Validate("Ship-to Address", AddressLbl);
        CompanyInformation.Validate("Ship-to Address 2", Address2Lbl);
        CompanyInformation.Validate("Ship-to City", CityLbl);
        CompanyInformation.Validate("Country/Region Code", ContosoCoffeeDemoDataSetup."Country/Region Code");
        CompanyInformation.Validate("CCC Bank No.", '1111');
        CompanyInformation.Validate("CCC Bank Branch No.", '2222');
        CompanyInformation.Validate("CCC Control Digits", '33');
        CompanyInformation.Validate("CCC Bank Account No.", '1234567890');
        CompanyInformation.Validate("CCC No.", '11112222331234567890');
        CompanyInformation.Validate("CNAE Description", CnaeDescriptionLbl);
        CompanyInformation.Validate("Payment Days Code", EvalLbl);
        CompanyInformation.Validate("Non-Paymt. Periods Code", EvalLbl);
        CompanyInformation.Validate(IBAN, '');
        CompanyInformation.Validate(County, CityLbl);
        CompanyInformation.Modify(true);
    end;

    var
        AddressLbl: Label 'Avenida Aragón, 5', MaxLength = 100;
        Address2Lbl: Label 'Centro Negocios', MaxLength = 50;
        CityLbl: Label 'Madrid', MaxLength = 30;
        VatRegistrationLbl: Label '77777777A', MaxLength = 20;
        CnaeDescriptionLbl: Label 'Distribución muebles', MaxLength = 80;
        EvalLbl: Label 'EVALUATION', MaxLength = 10;
}