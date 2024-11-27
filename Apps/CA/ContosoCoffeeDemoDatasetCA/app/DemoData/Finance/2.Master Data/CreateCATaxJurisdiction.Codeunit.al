codeunit 27052 "Create CA Tax Jurisdiction"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
        TaxJurisdiction: Record "Tax Jurisdiction";
        ContosoCATax: Codeunit "Contoso CA Tax";
        CreateCAGLAccounts: Codeunit "Create CA GL Accounts";
    begin
        ContosoCATax.InsertTaxJurisdiction(GovernmentofCanadaGST(), GovernmentofCanadaGSTLbl, CreateCAGLAccounts.GSTHSTSalesTax(), CreateCAGLAccounts.GSTHSTInputCredits(), GovernmentofCanadaGSTTok, CreateCAGLAccounts.GSTHSTInputCredits(), TaxJurisdiction."Country/Region"::CA, 1, GSTPrintDescriptionLbl);
        ContosoCATax.InsertTaxJurisdiction(ProvinceofBritishColumbiaPST(), ProvinceofBritishColumbiaPSTLbl, CreateCAGLAccounts.ProvincialSalesTax(), CreateCAGLAccounts.GSTHSTInputCredits(), ProvinceofBritishColumbiaPSTTok, CreateCAGLAccounts.GSTHSTInputCredits(), TaxJurisdiction."Country/Region"::CA, 2, PSTPrintDescriptionLbl);
        ContosoCATax.InsertTaxJurisdiction(ProvinceofManitobaPST(), ProvinceofManitobaPSTLbl, CreateCAGLAccounts.ProvincialSalesTax(), CreateCAGLAccounts.GSTHSTInputCredits(), ProvinceofManitobaPSTTok, CreateCAGLAccounts.GSTHSTInputCredits(), TaxJurisdiction."Country/Region"::CA, 3, PSTPrintDescriptionLbl);
        ContosoCATax.InsertTaxJurisdiction(ProvinceofNewBrunswickHST(), ProvinceofNewBrunswickHSTLbl, CreateCAGLAccounts.GSTHSTSalesTax(), CreateCAGLAccounts.GSTHSTInputCredits(), GovernmentofCanadaGSTTok, CreateCAGLAccounts.GSTHSTInputCredits(), TaxJurisdiction."Country/Region"::CA, 4, HSTPrintDescriptionLbl);
        ContosoCATax.InsertTaxJurisdiction(ProvinceofNewfoundlandandLabradorHST(), ProvinceofNewfoundlandandLabradorHSTLbl, CreateCAGLAccounts.GSTHSTSalesTax(), CreateCAGLAccounts.GSTHSTInputCredits(), GovernmentofCanadaGSTTok, CreateCAGLAccounts.GSTHSTInputCredits(), TaxJurisdiction."Country/Region"::CA, 5, HSTPrintDescriptionLbl);
        ContosoCATax.InsertTaxJurisdiction(ProvinceofNovaScotiaHST(), ProvinceofNovaScotiaHSTLbl, CreateCAGLAccounts.GSTHSTSalesTax(), CreateCAGLAccounts.GSTHSTInputCredits(), GovernmentofCanadaGSTTok, CreateCAGLAccounts.GSTHSTInputCredits(), TaxJurisdiction."Country/Region"::CA, 6, HSTPrintDescriptionLbl);
        ContosoCATax.InsertTaxJurisdiction(ProvinceofOntarioHST(), ProvinceofOntarioHSTLbl, CreateCAGLAccounts.GSTHSTSalesTax(), CreateCAGLAccounts.GSTHSTInputCredits(), GovernmentofCanadaGSTTok, CreateCAGLAccounts.GSTHSTInputCredits(), TaxJurisdiction."Country/Region"::CA, 7, HSTPrintDescriptionLbl);
        ContosoCATax.InsertTaxJurisdiction(ProvinceofPrinceEdwardIslandHST(), ProvinceofPrinceEdwardIslandHSTLbl, CreateCAGLAccounts.GSTHSTSalesTax(), CreateCAGLAccounts.GSTHSTInputCredits(), GovernmentofCanadaGSTTok, CreateCAGLAccounts.GSTHSTInputCredits(), TaxJurisdiction."Country/Region"::CA, 8, HSTPrintDescriptionLbl);
        ContosoCATax.InsertTaxJurisdiction(ProvinceofQuebecQST(), ProvinceofQuebecQSTLbl, CreateCAGLAccounts.QSTSalesTaxCollected(), CreateCAGLAccounts.GSTHSTInputCredits(), ProvinceofQuebecQSTTok, CreateCAGLAccounts.GSTHSTInputCredits(), TaxJurisdiction."Country/Region"::CA, 9, QSTPrintDescriptionLbl);
        ContosoCATax.InsertTaxJurisdiction(ProvinceofSaskatchewanPST(), ProvinceofSaskatchewanPSTLbl, CreateCAGLAccounts.ProvincialSalesTax(), CreateCAGLAccounts.GSTHSTInputCredits(), ProvinceofSaskatchewanPSTTok, CreateCAGLAccounts.GSTHSTInputCredits(), TaxJurisdiction."Country/Region"::CA, 10, PSTPrintDescriptionLbl);
    end;

    procedure GovernmentofCanadaGST(): Code[10]
    begin
        exit(GovernmentofCanadaGSTTok);
    end;

    procedure ProvinceofBritishColumbiaPST(): Code[10]
    begin
        exit(ProvinceofBritishColumbiaPSTTok);
    end;

    procedure ProvinceofManitobaPST(): Code[10]
    begin
        exit(ProvinceofManitobaPSTTok);
    end;

    procedure ProvinceofNewBrunswickHST(): Code[10]
    begin
        exit(ProvinceofNewBrunswickHSTTok);
    end;

    procedure ProvinceofNewfoundlandandLabradorHST(): Code[10]
    begin
        exit(ProvinceofNewfoundlandandLabradorHSTTok);
    end;

    procedure ProvinceofNovaScotiaHST(): Code[10]
    begin
        exit(ProvinceofNovaScotiaHSTTok);
    end;

    procedure ProvinceofOntarioHST(): Code[10]
    begin
        exit(ProvinceofOntarioHSTTok);
    end;

    procedure ProvinceofPrinceEdwardIslandHST(): Code[10]
    begin
        exit(ProvinceofPrinceEdwardIslandHSTTok);
    end;

    procedure ProvinceofQuebecQST(): Code[10]
    begin
        exit(ProvinceofQuebecQSTTok);
    end;

    procedure ProvinceofSaskatchewanPST(): Code[10]
    begin
        exit(ProvinceofSaskatchewanPSTTok);
    end;

    var
        GovernmentofCanadaGSTTok: Label 'CA', MaxLength = 10;
        ProvinceofBritishColumbiaPSTTok: Label 'CABC', MaxLength = 10;
        ProvinceofManitobaPSTTok: Label 'CAMB', MaxLength = 10;
        ProvinceofNewBrunswickHSTTok: Label 'CANB', MaxLength = 10;
        ProvinceofNewfoundlandandLabradorHSTTok: Label 'CANL', MaxLength = 10;
        ProvinceofNovaScotiaHSTTok: Label 'CANS', MaxLength = 10;
        ProvinceofOntarioHSTTok: Label 'CAON', MaxLength = 10;
        ProvinceofPrinceEdwardIslandHSTTok: Label 'CAPE', MaxLength = 10;
        ProvinceofQuebecQSTTok: Label 'CAQC', MaxLength = 10;
        ProvinceofSaskatchewanPSTTok: Label 'CASK', MaxLength = 10;
        GovernmentofCanadaGSTLbl: Label 'Government of Canada GST', MaxLength = 100;
        ProvinceofBritishColumbiaPSTLbl: Label 'Province of British Columbia PST', MaxLength = 100;
        ProvinceofManitobaPSTLbl: Label 'Province of Manitoba PST', MaxLength = 100;
        ProvinceofNewBrunswickHSTLbl: Label 'Province of New Brunswick HST', MaxLength = 100;
        ProvinceofNewfoundlandandLabradorHSTLbl: Label 'Province of Newfoundland and Labrador HST', MaxLength = 100;
        ProvinceofNovaScotiaHSTLbl: Label 'Province of Nova Scotia HST', MaxLength = 100;
        ProvinceofOntarioHSTLbl: Label 'Province of Ontario HST', MaxLength = 100;
        ProvinceofPrinceEdwardIslandHSTLbl: Label 'Province of Prince Edward Island HST', MaxLength = 100;
        ProvinceofQuebecQSTLbl: Label 'Province of Quebec QST', MaxLength = 100;
        ProvinceofSaskatchewanPSTLbl: Label 'Province of Saskatchewan PST', MaxLength = 100;
        GSTPrintDescriptionLbl: Label 'GST', MaxLength = 30;
        PSTPrintDescriptionLbl: Label 'PST', MaxLength = 30;
        HSTPrintDescriptionLbl: Label 'HST', MaxLength = 30;
        QSTPrintDescriptionLbl: Label 'QST', MaxLength = 30;
}