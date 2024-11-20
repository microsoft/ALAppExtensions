codeunit 11143 "Create Company Information AT"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    // TODO: Picture Name to Be Inserted

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        UpdateCompanyInformation(CityLbl, PhoneNoLbl, FaxNoLbl, PostcodeLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", CompanyRegNoLbl, SalesAuthorizedNoLbl, PurchaseAuthorizedNoLbl, TaxOfficeNameLbl, TaxOfficeAddressLbl, TaxofficePostCodeLbl, TaxOfficeNoLbl);
    end;

    local procedure UpdateCompanyInformation(City: Text[30]; PhoneNo: Text[30]; FaxNo: Text[30]; PostCode: Code[20]; CountryCode: Code[10]; RegistrationNo: Text[20]; SalesAuthorizeNo: Code[8]; PurchAuthorizedNo: Code[8]; TaxOfficeName: Text[50]; TaxOfficeAddress: Text[50];
           TaxOfficePostCode: Code[20]; TaxOfficeNumber: Code[4])
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation."Demo Company" := true;
        CompanyInformation.Validate(Address, CompanyAddressLbl);
        CompanyInformation.Validate("Address 2", CompanyAddress2Lbl);
        CompanyInformation.Validate(City, City);
        CompanyInformation.Validate("Phone No.", PhoneNo);
        CompanyInformation.Validate("Fax No.", FaxNo);
        CompanyInformation.Validate("Post Code", PostCode);
        CompanyInformation.Validate("Country/Region Code", CountryCode);
        CompanyInformation.Validate("Registration No.", RegistrationNo);
        CompanyInformation.Validate("VAT Registration No.", VatRegistrationNoLbl);
        CompanyInformation.Validate("Sales Authorized No.", SalesAuthorizeNo);
        CompanyInformation.Validate("Purch. Authorized No.", PurchAuthorizedNo);
        CompanyInformation.Validate("Tax Office Address", TaxOfficeAddress);
        CompanyInformation.Validate("Tax Office City", CityLbl);//City := CreatePostCode.FindCity(CompanyInformation."Post Code");
        CompanyInformation.Validate("Tax Office Post Code", TaxOfficePostCode);// "Post Code" := CreatePostCode.FindPostCode(CreatePostCode.Convert('GB-W2 8HG'));
        CompanyInformation.Validate("Tax Office Name", TaxOfficeName);
        CompanyInformation.Validate("Tax Office Number", TaxOfficeNumber);
        CompanyInformation.Validate("Tax Office Country/Region Code", '');
        CompanyInformation.Validate("Ship-to Address", CompanyAddressLbl);
        CompanyInformation.Validate("Ship-to Address 2", CompanyAddress2Lbl);
        CompanyInformation.Validate("Ship-to City", CityLbl);
        CompanyInformation.Validate("Ship-to Post Code", PostcodeLbl);

        // todo add picture from attached files
        // CompanyInformation.Picture.Import();

        CompanyInformation.Modify(true);
    end;

    var
        CompanyAddressLbl: Label 'Dr. Karl Renner', MaxLength = 100;
        CompanyAddress2Lbl: Label 'Ring 3', MaxLength = 50;
        SalesAuthorizedNoLbl: Label 'VK', MaxLength = 8;
        VatRegistrationNoLbl: Label 'ATU12345678', MaxLength = 20;
        PurchaseAuthorizedNoLbl: Label 'EK', MaxLength = 8;
        CityLbl: Label 'Wien', Maxlength = 30;
        PostcodeLbl: Label '1100', MaxLength = 20;
        PhoneNoLbl: Label '999 / 9 99 99 99', MaxLength = 30;
        FaxNoLbl: Label '999 / 9 99 99 90', MaxLength = 30;
        CompanyRegNoLbl: Label '123/4567', MaxLength = 20;
        TaxOfficeAddressLbl: Label 'Hohe Weide 101', MaxLength = 50;
        TaxofficePostCodeLbl: Label '1010', MaxLength = 20;
        TaxOfficeNoLbl: Label '99', MaxLength = 4;
        TaxOfficeNameLbl: Label 'Finanzamt f. d. 24. Bezirk', MaxLength = 50;
}
