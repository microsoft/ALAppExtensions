codeunit 11462 "Create Tax Jurisdiction US"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
        TaxJurisdiction: Record "Tax Jurisdiction";
        ContosoTaxUS: Codeunit "Contoso Tax US";
        CreateUSGLAccounts: Codeunit "Create US GL Accounts";
    begin
        ContosoTaxUS.InsertTaxJurisdiction(StateofFlorida(), StateofFloridaLbl, CreateUSGLAccounts.TaxesLiable(), CreateUSGLAccounts.TaxesLiable(), StateofFlorida(), CreateUSGLAccounts.TaxesLiable(), TaxJurisdiction."Country/Region"::US);
        ContosoTaxUS.InsertTaxJurisdiction(DadeCountyFL(), DadeCountyFLLbl, CreateUSGLAccounts.TaxesLiable(), CreateUSGLAccounts.TaxesLiable(), StateofFlorida(), CreateUSGLAccounts.TaxesLiable(), TaxJurisdiction."Country/Region"::US);
        ContosoTaxUS.InsertTaxJurisdiction(CityofMiamiFL(), CityofMiamiFLLbl, CreateUSGLAccounts.TaxesLiable(), CreateUSGLAccounts.TaxesLiable(), StateofFlorida(), CreateUSGLAccounts.TaxesLiable(), TaxJurisdiction."Country/Region"::US);
        ContosoTaxUS.InsertTaxJurisdiction(StateofGeorgia(), StateofGeorgiaLbl, CreateUSGLAccounts.TaxesLiable(), CreateUSGLAccounts.TaxesLiable(), StateofGeorgia(), CreateUSGLAccounts.TaxesLiable(), TaxJurisdiction."Country/Region"::US);
        ContosoTaxUS.InsertTaxJurisdiction(CityofAtlantaGA(), CityofAtlantaGALbl, CreateUSGLAccounts.TaxesLiable(), CreateUSGLAccounts.TaxesLiable(), StateofGeorgia(), CreateUSGLAccounts.TaxesLiable(), TaxJurisdiction."Country/Region"::US);
        ContosoTaxUS.InsertTaxJurisdiction(FultonCountyGA(), FultonCountyGALbl, CreateUSGLAccounts.TaxesLiable(), CreateUSGLAccounts.TaxesLiable(), StateofGeorgia(), CreateUSGLAccounts.TaxesLiable(), TaxJurisdiction."Country/Region"::US);
        ContosoTaxUS.InsertTaxJurisdiction(GwinnettCountyGA(), GwinnettCountyGALbl, CreateUSGLAccounts.TaxesLiable(), CreateUSGLAccounts.TaxesLiable(), StateofGeorgia(), CreateUSGLAccounts.TaxesLiable(), TaxJurisdiction."Country/Region"::US);
        ContosoTaxUS.InsertTaxJurisdiction(MartaDistrictGA(), MartaDistrictGALbl, CreateUSGLAccounts.TaxesLiable(), CreateUSGLAccounts.TaxesLiable(), StateofGeorgia(), CreateUSGLAccounts.TaxesLiable(), TaxJurisdiction."Country/Region"::US);
        ContosoTaxUS.InsertTaxJurisdiction(StateofIllinois(), StateofIllinoisLbl, CreateUSGLAccounts.TaxesLiable(), CreateUSGLAccounts.TaxesLiable(), StateofIllinois(), CreateUSGLAccounts.TaxesLiable(), TaxJurisdiction."Country/Region"::US);
        ContosoTaxUS.InsertTaxJurisdiction(CityofChicagoIL(), CityofChicagoILLbl, CreateUSGLAccounts.TaxesLiable(), CreateUSGLAccounts.TaxesLiable(), StateofIllinois(), CreateUSGLAccounts.TaxesLiable(), TaxJurisdiction."Country/Region"::US);
        ContosoTaxUS.InsertTaxJurisdiction(COOKCountyIL(), COOKCountyILLbl, CreateUSGLAccounts.TaxesLiable(), CreateUSGLAccounts.TaxesLiable(), StateofIllinois(), CreateUSGLAccounts.TaxesLiable(), TaxJurisdiction."Country/Region"::US);
    end;

    procedure StateofFlorida(): Code[10]
    begin
        exit(StateofFloridaTok);
    end;

    procedure DadeCountyFL(): Code[10]
    begin
        exit(DadeCountyFLTok);
    end;

    procedure CityofMiamiFL(): Code[10]
    begin
        exit(CityofMiamiFLTok);
    end;

    procedure StateofGeorgia(): Code[10]
    begin
        exit(StateofGeorgiaTok);
    end;

    procedure CityofAtlantaGA(): Code[10]
    begin
        exit(CityofAtlantaGATok);
    end;

    procedure FultonCountyGA(): Code[10]
    begin
        exit(FultonCountyGATok);
    end;

    procedure GwinnettCountyGA(): Code[10]
    begin
        exit(GwinnettCountyGATok);
    end;

    procedure MartaDistrictGA(): Code[10]
    begin
        exit(MartaDistrictGATok);
    end;

    procedure StateofIllinois(): Code[10]
    begin
        exit(StateofIllinoisTok);
    end;

    procedure CityofChicagoIL(): Code[10]
    begin
        exit(CityofChicagoILTok);
    end;

    procedure COOKCountyIL(): Code[10]
    begin
        exit(COOKCountyILTok);
    end;

    var
        StateofFloridaTok: Label 'FL', MaxLength = 10, Locked = true;
        StateofFloridaLbl: Label 'State of Florida', MaxLength = 100;
        DadeCountyFLTok: Label 'FLDADE', MaxLength = 10, Locked = true;
        DadeCountyFLLbl: Label 'Dade County, FL', MaxLength = 100;
        CityofMiamiFLTok: Label 'FLMIAMI', MaxLength = 10, Locked = true;
        CityofMiamiFLLbl: Label 'City of Miami, FL', MaxLength = 100;
        StateofGeorgiaTok: Label 'GA', MaxLength = 10, Locked = true;
        StateofGeorgiaLbl: Label 'State of Georgia', MaxLength = 100;
        CityofAtlantaGATok: Label 'GAATLANTA', MaxLength = 10, Locked = true;
        CityofAtlantaGALbl: Label 'City of Atlanta, GA', MaxLength = 100;
        FultonCountyGATok: Label 'GAFULTON', MaxLength = 10, Locked = true;
        FultonCountyGALbl: Label 'Fulton County, GA', MaxLength = 100;
        GwinnettCountyGATok: Label 'GAGWINNETT', MaxLength = 10, Locked = true;
        GwinnettCountyGALbl: Label 'Gwinnett County, GA', MaxLength = 100;
        MartaDistrictGATok: Label 'GAMARTA', MaxLength = 10, Locked = true;
        MartaDistrictGALbl: Label 'Marta District, GA', MaxLength = 100;
        StateofIllinoisTok: Label 'IL', MaxLength = 10, Locked = true;
        StateofIllinoisLbl: Label 'State of Illinois', MaxLength = 100;
        CityofChicagoILTok: Label 'ILCHICAGO', MaxLength = 10, Locked = true;
        CityofChicagoILLbl: Label 'City of Chicago, IL', MaxLength = 100;
        COOKCountyILTok: Label 'ILCOOK', MaxLength = 10, Locked = true;
        COOKCountyILLbl: Label 'COOK County, IL', MaxLength = 100;
}