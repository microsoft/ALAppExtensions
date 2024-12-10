codeunit 10866 "Create Company Information FR"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateCompanyInformation(CityLbl, PostcodeLbl, TradeRegisterLbl, ApeCodeLbl, LegalFormLbl, StockCapitalLbl);
    end;

    local procedure UpdateCompanyInformation(City: Text[30]; PostCode: Code[20]; TradeRegistrationNo: Text[30]; APECode: Code[10]; LegalFormNo: Text[30]; StockCapital: Text[30])
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation."Demo Company" := true;
        CompanyInformation.Validate(City, City);
        CompanyInformation.Validate("Post Code", PostCode);
        CompanyInformation.Validate("Registration No.", '2041746010022');
        CompanyInformation.Validate("VAT Registration No.", 'FR77777777777');
        CompanyInformation.Validate("Ship-to City", CityLbl);
        CompanyInformation.Validate("Ship-to Post Code", PostcodeLbl);
        CompanyInformation.Validate("Trade Register", TradeRegistrationNo);
        CompanyInformation.Validate("APE Code", ApeCode);
        CompanyInformation.Validate("Legal Form", LegalFormNo);
        CompanyInformation.Validate("Stock Capital", StockCapital);

        CompanyInformation.Modify(true);
    end;

    var
        CityLbl: Label 'Paris', Maxlength = 30, Locked = true;
        PostcodeLbl: Label '75008', MaxLength = 20;
        TradeRegisterLbl: Label 'R.C.S. : Paris', MaxLength = 30;
        ApeCodeLbl: Label '361C', MaxLength = 10;
        LegalFormLbl: Label 'SA', MaxLength = 30;
        StockCapitalLbl: Label '115.000 Euros', MaxLength = 30;
}