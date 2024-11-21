codeunit 5408 "Contoso Company"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Company Information" = rim;
    EventSubscriberInstance = Manual;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertCompanyInformation(CompanyName: Text[100]; Address: Text[100])
    var
        CompanyInformation: Record "Company Information";
    begin
        if OverwriteData then
            if CompanyInformation.Get() then;

        InsertCompanyInformation(CompanyName, Address, CompanyInformation."Address 2", CompanyInformation."Country/Region Code", CompanyInformation."Post Code", CompanyInformation.City, CompanyInformation."Contact Person", CompanyInformation."Phone No.", CompanyInformation."Fax No.", CompanyInformation."Giro No.", CompanyInformation."Bank Name", CompanyInformation."Bank Branch No.", CompanyInformation."Bank Account No.", CompanyInformation.IBAN, CompanyInformation."Payment Routing No.", CompanyInformation."VAT Registration No.", CompanyInformation."Ship-to Name", CompanyInformation."Ship-to Address", CompanyInformation."Ship-to Address 2", CompanyInformation."Ship-to Country/Region Code", CompanyInformation."Ship-to Post Code", CompanyInformation."Ship-to City", '', '');
    end;

    procedure InsertCompanyInformation(CompanyName: Text[100]; Address: Text[100]; Address2: Text[50]; CountryRegionCode: Code[10]; PostCode: Code[20]; City: Text[30]; ContactPerson: Text[50]; PhoneNo: Text[30]; FaxNo: Text[30]; GiroNo: Text[20]; BankName: Text[100]; BankBranchNo: Text[30]; BankAccountNo: Text[30]; IBAN: Code[50]; PaymentRoutingNo: Text[20]; VATRegistrationNo: Text[20]; ShipToName: Text[100]; ShipToAddress: Text[100]; ShipToAddress2: Text[50]; ShipToCountryRegionCode: Code[10]; ShipToPostCode: Code[20]; ShipToCity: Text[30]; PictureName: Text[100]; CheckAvailPeriodCalc: Text[10])
    var
        CompanyInformation: Record "Company Information";
        Exists: Boolean;
    begin
        if CompanyInformation.Get() then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CompanyInformation."Demo Company" := true;
        CompanyInformation.Validate("Primary Key", '');
        CompanyInformation.Validate(Name, CompanyName);
        CompanyInformation.Validate(Address, Address);
        CompanyInformation.Validate("Address 2", Address2);
        CompanyInformation.Validate("Country/Region Code", CountryRegionCode);
        CompanyInformation.Validate("Post Code", PostCode);// "Post Code" := CreatePostCode.FindPostCode(CreatePostCode.Convert('GB-W2 8HG'));
        CompanyInformation.Validate(City, City); //City := CreatePostCode.FindCity(CompanyInformation."Post Code");
        CompanyInformation.Validate("Contact Person", ContactPerson);
        CompanyInformation.Validate("Phone No.", PhoneNo);
        CompanyInformation.Validate("Fax No.", FaxNo);
        CompanyInformation.Validate("Giro No.", GiroNo);
        CompanyInformation.Validate("Bank Name", BankName);
        CompanyInformation.Validate("Bank Branch No.", BankBranchNo);
        CompanyInformation.Validate("Bank Account No.", BankAccountNo);
        CompanyInformation.Validate(IBAN, IBAN);
        CompanyInformation.Validate("Payment Routing No.", PaymentRoutingNo);
        CompanyInformation.Validate("VAT Registration No.", VATRegistrationNo);
        CompanyInformation.Validate("Ship-to Name", ShipToName);
        CompanyInformation.Validate("Ship-to Address", ShipToAddress);
        CompanyInformation.Validate("Ship-to Address 2", ShipToAddress2);
        CompanyInformation.Validate("Ship-to Country/Region Code", ShipToCountryRegionCode);
        CompanyInformation.Validate("Ship-to Post Code", ShipToPostCode);
        CompanyInformation.Validate("Ship-to City", ShipToCity);
        CompanyInformation.Validate("Check-Avail. Time Bucket", CompanyInformation."Check-Avail. Time Bucket"::Week);
        Evaluate(CompanyInformation."Check-Avail. Period Calc.", CheckAvailPeriodCalc);
        CompanyInformation.Validate("Check-Avail. Period Calc.");

        if Exists then
            CompanyInformation.Modify(true)
        else
            CompanyInformation.Insert(true);
    end;
}
