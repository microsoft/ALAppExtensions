codeunit 11098 "Create DE Company Information"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateDEArea: Codeunit "Create DE Area";
    begin
        UpdateCompanyInformation(CityLbl, PhoneNoLbl, FaxNoLbl, PostcodeLbl, CompanyRegNoLbl, CreateDEArea.AreaCode2(), PlaceofDispatcherLbl, PlaceofReceiverLbl, SalesAuthorizedNoLbl, PurchaseAuthorizedNoLbl, TaxOfficeNameLbl, TaxOfficeAddressLbl, TaxofficeCityLbl, TaxofficePostCodeLbl, 2, VATRepresentativeLbl, TaxOfficeNoLbl);
    end;

    local procedure UpdateCompanyInformation(City: Text[30]; PhoneNo: Text[30]; FaxNo: Text[30]; PostCode: Code[20]; RegistrationNo: Text[20]; AreaCode: Code[10]; PlaceofDispatcher: Code[10]; PlaceofReceiver: Code[10]; SalesAuthorizeNo: Code[8]; PurchAuthorizedNo: Code[8]; TaxOfficeName: Text[50]; TaxOfficeAddress: Text[50];
          TaxOfficeCity: Text[50]; TaxOfficePostCode: Code[20]; TaxOfficeArea: Option; VATRepresentative: Text[45]; TaxOfficeNumber: Code[4])
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation."Demo Company" := true;
        CompanyInformation.Validate(City, City);
        CompanyInformation.Validate("Phone No.", PhoneNo);
        CompanyInformation.Validate("Ship-to City", City);
        CompanyInformation.Validate("Fax No.", FaxNo);
        CompanyInformation.Validate("Post Code", PostCode);
        CompanyInformation.Validate("Ship-to Post Code", PostCode);
        // CompanyInformation.Validate("Country/Region Code", CountryCode);
        CompanyInformation.Validate("Registration No.", RegistrationNo);
        CompanyInformation.Validate(Area, AreaCode);
        CompanyInformation.Validate("Place of Dispatcher", PlaceofDispatcher);
        CompanyInformation.Validate("Place of Receiver", PlaceofReceiver);
        CompanyInformation.Validate("Sales Authorized No.", SalesAuthorizeNo);
        CompanyInformation.Validate("Purch. Authorized No.", PurchAuthorizedNo);
        CompanyInformation.Validate("Tax Office Name", TaxOfficeName);
        CompanyInformation.Validate("Tax Office Address", TaxOfficeAddress);
        CompanyInformation.Validate("Tax Office Post Code", TaxOfficePostCode);
        CompanyInformation.Validate("Tax Office City", TaxOfficeCity);
        CompanyInformation.Validate("Tax Office Area", TaxOfficeArea);
        CompanyInformation.Validate("VAT Representative", VATRepresentative);
        CompanyInformation.Validate("Tax Office Number", TaxOfficeNumber);
        CompanyInformation.Validate("Tax Office Country/Region Code", '');

        CompanyInformation.Modify(true);
    end;

    var
        PlaceofDispatcherLbl: Label '1', MaxLength = 10;
        SalesAuthorizedNoLbl: Label 'XYZ123', MaxLength = 8;
        PurchaseAuthorizedNoLbl: Label 'ABC987', MaxLength = 8;
        PlaceofReceiverLbl: Label '1', MaxLength = 10;
        CityLbl: Label 'Hamburg', Maxlength = 30;
        PostcodeLbl: Label '20097', MaxLength = 20;
        PhoneNoLbl: Label '999 / 9 99 99 99', MaxLength = 30;
        FaxNoLbl: Label '999 / 9 99 99 90', MaxLength = 30;
        CompanyRegNoLbl: Label '11/222/33333', MaxLength = 20;
        TaxOfficeAddressLbl: Label 'Hohe Weide 101', MaxLength = 50;
        TaxofficeCityLbl: Label 'Hamburg 36', MaxLength = 50;
        TaxofficePostCodeLbl: Label '22417', MaxLength = 20;
        VATRepresentativeLbl: Label 'KATHERINE HULL', MaxLength = 45;
        TaxOfficeNoLbl: Label '2710', MaxLength = 4;
        TaxOfficeNameLbl: Label 'Finanzamt Hamburg Mitte', MaxLength = 50;
}
