codeunit 10518 "Create Tax Area US"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        TaxArea: Record "Tax Area";
        ContosoTaxUS: Codeunit "Contoso Tax US";
    begin
        ContosoTaxUS.InsertTaxArea(AtlantaGa(), AtlantaGaTok, TaxArea."Country/Region"::US, TaxArea."Round Tax"::"To Nearest");
        ContosoTaxUS.InsertTaxArea(ChicagoIl(), ChicagoIlTok, TaxArea."Country/Region"::US, TaxArea."Round Tax"::"To Nearest");
        ContosoTaxUS.InsertTaxArea(MiamiFl(), MiamiFlTok, TaxArea."Country/Region"::US, TaxArea."Round Tax"::"To Nearest");
        ContosoTaxUS.InsertTaxArea(NAtlGa(), NAtlGaLbl, TaxArea."Country/Region"::US, TaxArea."Round Tax"::"To Nearest");
        UpdateTaxAreaOnCompanyInformation(AtlantaGa());
    end;

    local procedure UpdateTaxAreaOnCompanyInformation(TaxAreaCode: Code[20])
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation.Validate("Tax Area Code", TaxAreaCode);
        CompanyInformation.Modify(true);
    end;

    procedure AtlantaGa(): Code[20]
    begin
        exit(AtlantaGaTok);
    end;

    procedure ChicagoIl(): Code[20]
    begin
        exit(ChicagoIlTok);
    end;

    procedure MiamiFl(): Code[20]
    begin
        exit(MiamiFlTok);
    end;

    procedure NAtlGa(): Code[20]
    begin
        exit(NAtlGaTok);
    end;

    var
        AtlantaGaTok: Label 'ATLANTA, GA', MaxLength = 20;
        ChicagoIlTok: Label 'CHICAGO, IL', MaxLength = 20;
        MiamiFlTok: Label 'MIAMI, FL', MaxLength = 20;
        NAtlGaTok: Label 'N.ATL., GA', MaxLength = 20;
        NAtlGaLbl: Label 'Atlanta, GA - North', MaxLength = 100;
}