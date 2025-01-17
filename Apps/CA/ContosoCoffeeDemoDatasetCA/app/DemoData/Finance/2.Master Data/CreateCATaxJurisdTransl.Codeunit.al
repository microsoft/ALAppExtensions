codeunit 27048 "Create CA Tax Jurisd. Transl."
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
        ContosoCATax: Codeunit "Contoso CA Tax";
        CreateLanguage: Codeunit "Create Language";
        CreateCATaxJurisdiction: Codeunit "Create CA Tax Jurisdiction";
    begin
        ContosoCATax.InsertTaxJurisdictionTranslation(CreateCATaxJurisdiction.GovernmentofCanadaGST(), CreateLanguage.FRC(), GovernmentofCanadaGSTLbl, TPSPrintDescriptionLbl);
        ContosoCATax.InsertTaxJurisdictionTranslation(CreateCATaxJurisdiction.ProvinceofBritishColumbiaPST(), CreateLanguage.FRC(), ProvinceofBritishColumbiaPSTLbl, TVPPrintDescriptionLbl);
        ContosoCATax.InsertTaxJurisdictionTranslation(CreateCATaxJurisdiction.ProvinceofManitobaPST(), CreateLanguage.FRC(), ProvinceofManitobaPSTLbl, TVPPrintDescriptionLbl);
        ContosoCATax.InsertTaxJurisdictionTranslation(CreateCATaxJurisdiction.ProvinceofNewBrunswickHST(), CreateLanguage.FRC(), ProvinceofNewBrunswickHSTLbl, TVHPrintDescriptionLbl);
        ContosoCATax.InsertTaxJurisdictionTranslation(CreateCATaxJurisdiction.ProvinceofNewfoundlandandLabradorHST(), CreateLanguage.FRC(), ProvinceofNewfoundlandandLabradorHSTLbl, TVHPrintDescriptionLbl);
        ContosoCATax.InsertTaxJurisdictionTranslation(CreateCATaxJurisdiction.ProvinceofNovaScotiaHST(), CreateLanguage.FRC(), ProvinceofNovaScotiaHSTLbl, TVHPrintDescriptionLbl);
        ContosoCATax.InsertTaxJurisdictionTranslation(CreateCATaxJurisdiction.ProvinceofOntarioHST(), CreateLanguage.FRC(), ProvinceofOntarioHSTLbl, TVHPrintDescriptionLbl);
        ContosoCATax.InsertTaxJurisdictionTranslation(CreateCATaxJurisdiction.ProvinceofPrinceEdwardIslandHST(), CreateLanguage.FRC(), ProvinceofPrinceEdwardIslandHSTLbl, TVHPrintDescriptionLbl);
        ContosoCATax.InsertTaxJurisdictionTranslation(CreateCATaxJurisdiction.ProvinceofQuebecQST(), CreateLanguage.FRC(), ProvinceofQuebecQSTLbl, TVQPrintDescriptionLbl);
        ContosoCATax.InsertTaxJurisdictionTranslation(CreateCATaxJurisdiction.ProvinceofSaskatchewanPST(), CreateLanguage.FRC(), ProvinceofSaskatchewanPSTLbl, TVPPrintDescriptionLbl);
    end;

    var
        GovernmentofCanadaGSTLbl: Label 'Gouvernement du Canada TPS', MaxLength = 100;
        ProvinceofBritishColumbiaPSTLbl: Label 'Province de la Colombie-Britannique TVP', MaxLength = 100;
        ProvinceofManitobaPSTLbl: Label 'Province du Manitoba TVP', MaxLength = 100;
        ProvinceofNewBrunswickHSTLbl: Label 'Province du Nouveau-Brunswick TVH', MaxLength = 100;
        ProvinceofNewfoundlandandLabradorHSTLbl: Label 'Province de Terre-Neuve-et-Labrador TVH', MaxLength = 100;
        ProvinceofNovaScotiaHSTLbl: Label 'Province de la Nouvelle-Écosse TVH', MaxLength = 100;
        ProvinceofOntarioHSTLbl: Label 'Province de l''Ontario TVH', MaxLength = 100;
        ProvinceofPrinceEdwardIslandHSTLbl: Label 'Province de l''Île-du-Prince-Édouard TVH', MaxLength = 100;
        ProvinceofQuebecQSTLbl: Label 'Province de Québec TVQ', MaxLength = 100;
        ProvinceofSaskatchewanPSTLbl: Label 'Province de la Saskatchewan TVP', MaxLength = 100;
        TPSPrintDescriptionLbl: Label 'TPS', MaxLength = 30;
        TVPPrintDescriptionLbl: Label 'TVP', MaxLength = 30;
        TVHPrintDescriptionLbl: Label 'TVH', MaxLength = 30;
        TVQPrintDescriptionLbl: Label 'TVQ', MaxLength = 30;
}