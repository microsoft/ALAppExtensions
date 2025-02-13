codeunit 27019 "Create CA Tax Area"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        TaxArea: Record "Tax Area";
        ContosoCATax: Codeunit "Contoso CA Tax";
        CreateLanguage: Codeunit "Create Language";
    begin
        ContosoCATax.InsertTaxArea(Alberta(), AlbertaLbl, TaxArea."Country/Region"::CA, TaxArea."Round Tax"::"To Nearest");
        ContosoCATax.InsertTaxArea(BritishColumbia(), BritishColumbiaLbl, TaxArea."Country/Region"::CA, TaxArea."Round Tax"::"To Nearest");
        ContosoCATax.InsertTaxArea(Manitoba(), ManitobaLbl, TaxArea."Country/Region"::CA, TaxArea."Round Tax"::"To Nearest");
        ContosoCATax.InsertTaxArea(NewBrunswick(), NewBrunswickLbl, TaxArea."Country/Region"::CA, TaxArea."Round Tax"::"To Nearest");
        ContosoCATax.InsertTaxArea(NewfoundlandandLabrador(), NewfoundlandandLabradorLbl, TaxArea."Country/Region"::CA, TaxArea."Round Tax"::"To Nearest");
        ContosoCATax.InsertTaxArea(NovaScotia(), NovaScotiaLbl, TaxArea."Country/Region"::CA, TaxArea."Round Tax"::"To Nearest");
        ContosoCATax.InsertTaxArea(NorthWestTerritories(), NorthWestTerritoriesLbl, TaxArea."Country/Region"::CA, TaxArea."Round Tax"::"To Nearest");
        ContosoCATax.InsertTaxArea(Nunavut(), NunavutLbl, TaxArea."Country/Region"::CA, TaxArea."Round Tax"::"To Nearest");
        ContosoCATax.InsertTaxArea(Ontario(), OntarioLbl, TaxArea."Country/Region"::CA, TaxArea."Round Tax"::"To Nearest");
        ContosoCATax.InsertTaxArea(PrinceEdwardIsland(), PrinceEdwardIslandLbl, TaxArea."Country/Region"::CA, TaxArea."Round Tax"::"To Nearest");
        ContosoCATax.InsertTaxArea(Quebec(), QuebecLbl, TaxArea."Country/Region"::CA, TaxArea."Round Tax"::"To Nearest");
        ContosoCATax.InsertTaxArea(Saskatchewan(), SaskatchewanLbl, TaxArea."Country/Region"::CA, TaxArea."Round Tax"::"To Nearest");
        ContosoCATax.InsertTaxArea(Yukon(), YukonLbl, TaxArea."Country/Region"::CA, TaxArea."Round Tax"::"To Nearest");

        ContosoCATax.InsertTaxAreaTranslation(BritishColumbia(), CreateLanguage.FRC(), BCTaxAreaTranslationLbl);
        ContosoCATax.InsertTaxAreaTranslation(NewBrunswick(), CreateLanguage.FRC(), NBTaxAreaTranslationLbl);
        ContosoCATax.InsertTaxAreaTranslation(NewfoundlandandLabrador(), CreateLanguage.FRC(), NLTaxAreaTranslationLbl);
        ContosoCATax.InsertTaxAreaTranslation(NovaScotia(), CreateLanguage.FRC(), NSTaxAreaTranslationLbl);
        ContosoCATax.InsertTaxAreaTranslation(NorthWestTerritories(), CreateLanguage.FRC(), NTTaxAreaTranslationLbl);
        ContosoCATax.InsertTaxAreaTranslation(PrinceEdwardIsland(), CreateLanguage.FRC(), PETaxAreaTranslationLbl);
        ContosoCATax.InsertTaxAreaTranslation(Quebec(), CreateLanguage.FRC(), QCTaxAreaTranslationLbl);

        UpdateTaxAreaOnCompanyInformation(Ontario());
    end;

    local procedure UpdateTaxAreaOnCompanyInformation(TaxAreaCode: Code[20])
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation.Validate("Tax Area Code", TaxAreaCode);
        CompanyInformation.Modify(true);
    end;

    procedure Alberta(): Code[20]
    begin
        exit(AlbertaTok);
    end;

    procedure BritishColumbia(): Code[20]
    begin
        exit(BritishColumbiaTok);
    end;

    procedure Manitoba(): Code[20]
    begin
        exit(ManitobaTok);
    end;

    procedure NewBrunswick(): Code[20]
    begin
        exit(NewBrunswickTok);
    end;

    procedure NewfoundlandandLabrador(): Code[20]
    begin
        exit(NewfoundlandandLabradorTok);
    end;

    procedure NovaScotia(): Code[20]
    begin
        exit(NovaScotiaTok);
    end;

    procedure NorthWestTerritories(): Code[20]
    begin
        exit(NorthWestTerritoriesTok);
    end;

    procedure Nunavut(): Code[20]
    begin
        exit(NunavutTok);
    end;

    procedure Ontario(): Code[20]
    begin
        exit(OntarioTok);
    end;

    procedure PrinceEdwardIsland(): Code[20]
    begin
        exit(PrinceEdwardIslandTok);
    end;

    procedure Quebec(): Code[20]
    begin
        exit(QuebecTok);
    end;

    procedure Saskatchewan(): Code[20]
    begin
        exit(SaskatchewanTok);
    end;

    procedure Yukon(): Code[20]
    begin
        exit(YukonTok);
    end;

    var
        AlbertaTok: Label 'AB', MaxLength = 20;
        BritishColumbiaTok: Label 'BC', MaxLength = 20;
        ManitobaTok: Label 'MB', MaxLength = 20;
        NewBrunswickTok: Label 'NB', MaxLength = 20;
        NewfoundlandandLabradorTok: Label 'NL', MaxLength = 20;
        NovaScotiaTok: Label 'NS', MaxLength = 20;
        NorthWestTerritoriesTok: Label 'NT', MaxLength = 20;
        NunavutTok: Label 'NU', MaxLength = 20;
        OntarioTok: Label 'ON', MaxLength = 20;
        PrinceEdwardIslandTok: Label 'PE', MaxLength = 20;
        QuebecTok: Label 'QC', MaxLength = 20;
        SaskatchewanTok: Label 'SK', MaxLength = 20;
        YukonTok: Label 'YK', MaxLength = 20;
        AlbertaLbl: Label 'Alberta', MaxLength = 100;
        BritishColumbiaLbl: Label 'British Columbia', MaxLength = 100;
        ManitobaLbl: Label 'Manitoba', MaxLength = 100;
        NewBrunswickLbl: Label 'New Brunswick', MaxLength = 100;
        NewfoundlandandLabradorLbl: Label 'Newfoundland and Labrador', MaxLength = 100;
        NovaScotiaLbl: Label 'Nova Scotia', MaxLength = 100;
        NorthWestTerritoriesLbl: Label 'North West Territories', MaxLength = 100;
        NunavutLbl: Label 'Nunavut', MaxLength = 100;
        OntarioLbl: Label 'Ontario', MaxLength = 100;
        PrinceEdwardIslandLbl: Label 'Prince Edward Island', MaxLength = 100;
        QuebecLbl: Label 'Quebec', MaxLength = 100;
        SaskatchewanLbl: Label 'Saskatchewan', MaxLength = 100;
        YukonLbl: Label 'Yukon', MaxLength = 100;
        BCTaxAreaTranslationLbl: Label 'Colombie-Britannique', MaxLength = 100;
        NBTaxAreaTranslationLbl: Label 'Nouveau-Brunswick', MaxLength = 100;
        NLTaxAreaTranslationLbl: Label 'Terre-Neuve-et-Labrador', MaxLength = 100;
        NSTaxAreaTranslationLbl: Label 'Nouvelle-Écosse', MaxLength = 100;
        NTTaxAreaTranslationLbl: Label 'Territoires du Nord-Ouest', MaxLength = 100;
        PETaxAreaTranslationLbl: Label 'Île-du-Prince-Édouard', MaxLength = 100;
        QCTaxAreaTranslationLbl: Label 'Québec', MaxLength = 100;
}