codeunit 12200 "Create Company Information IT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    // TODO: Picture Name to Be Inserted

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        UpdateCompanyInformation(AddressLbl, Address2Lbl, CityLbl, PostcodeLbl, BankAccNoLbl, SIACodeLbl, AuthorityCountyLbl, AutorizeNoLbl, SignatureOnBillLbl);
    end;

    local procedure UpdateCompanyInformation(CompAddress: Text[100]; CompAddress2: Text[50]; City: Text[30]; PostCode: Code[20]; BankAccountNo: Text[30]; SIACode: Code[5]; AuthorityCounty: Code[20]; AutorizeNo: Code[10]; SignatureOnBill: Text[20])
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CompanyInformation: Record "Company Information";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        CompanyInformation.Get();
        CompanyInformation."Demo Company" := true;
        CompanyInformation.Validate(Address, CompAddress);
        CompanyInformation.Validate("Address 2", CompAddress2);
        CompanyInformation.Validate(City, City);
        CompanyInformation.Validate("Post Code", PostCode);
        CompanyInformation.Validate("Phone No.", '+39-02-660-6666');
        CompanyInformation.Validate("Fax No.", '+39-02-660-6660');
        CompanyInformation.Validate("Bank Account No.", BankAccountNo);
        CompanyInformation.Validate("VAT Registration No.", '28051977200');
        CompanyInformation.Validate("Ship-to Address", CompAddress);
        CompanyInformation.Validate("Ship-to Address 2", CompAddress2);
        CompanyInformation.Validate("Ship-to City", CityLbl);
        CompanyInformation.Validate("Ship-to Post Code", PostcodeLbl);
        CompanyInformation.Validate("Ship-to Country/Region Code", ContosoCoffeeDemoDataSetup."Country/Region Code");
        CompanyInformation.Validate("SIA Code", SIACode);
        CompanyInformation.Validate("Authority County", AuthorityCounty);
        CompanyInformation.Validate("Autoriz. No.", AutorizeNo);
        CompanyInformation.Validate("Autoriz. Date", 20020101D);
        CompanyInformation.Validate("Signature on Bill", SignatureOnBill);

        // todo add picture from attached files
        // CompanyInformation.Picture.Import();

        CompanyInformation.Modify(true);
    end;

    var
        AddressLbl: Label 'Piazza Duomo, 1', MaxLength = 100;
        Address2Lbl: Label 'Milano', MaxLength = 50;
        CityLbl: Label 'Milano', Maxlength = 30;
        PostcodeLbl: Label '20100', MaxLength = 20;
        BankAccNoLbl: Label '9999888', MaxLength = 30;
        SIACodeLbl: Label '12345', MaxLength = 5;
        AuthorityCountyLbl: Label 'LND', MaxLength = 20;
        AutorizeNoLbl: Label '56701', MaxLength = 10;
        SignatureOnBillLbl: Label 'CRONUS', MaxLength = 20;
}