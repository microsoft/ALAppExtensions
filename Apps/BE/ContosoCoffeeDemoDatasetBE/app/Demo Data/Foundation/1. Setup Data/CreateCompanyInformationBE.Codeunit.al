codeunit 11356 "Create Company Information BE"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        UpdateCompanyInformation(CityLbl, PostcodeLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", '01', EnterpriseNoAccountantLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company Information", 'OnBeforeValidateEvent', 'VAT Registration No.', false, false)]
    local procedure OnValidateVATRegstrationNo(var Rec: Record "Company Information")
    begin
        Rec."VAT Registration No." := '';
    end;

    local procedure UpdateCompanyInformation(City: Text[30]; PostCode: Code[20]; CountryCode: Code[10]; IntrastateNo: Text[2]; EnterpriseNo: Text[50])
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation."Demo Company" := true;
        CompanyInformation.Validate(City, City);
        CompanyInformation.Validate("Post Code", PostCode);
        CompanyInformation.Validate("Country/Region Code", CountryCode);
        CompanyInformation.Validate("Registration No.", '');
        CompanyInformation.Validate("VAT Registration No.", '');
        CompanyInformation.Validate("Ship-to City", CityLbl);
        CompanyInformation.Validate("Ship-to Post Code", PostcodeLbl);
        CompanyInformation.Validate("Ship-to Country/Region Code", CountryCode);
        CompanyInformation.Validate("Intrastat Establishment No.", IntrastateNo);
        CompanyInformation.Validate("Enterprise No. Accountant", EnterpriseNo);
        CompanyInformation.Validate("Enterprise No.", EnterpriseNo);

        CompanyInformation.Modify(true);
    end;

    var
        CityLbl: Label 'MECHELEN', Maxlength = 30;
        PostcodeLbl: Label '2800', MaxLength = 20;
        EnterpriseNoAccountantLbl: Label '0058.315.707', MaxLength = 50;
}