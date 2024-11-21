codeunit 5682 "Create Salutation Formula"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateSalutations: Codeunit "Create Salutations";
        ContosoCRM: Codeunit "Contoso CRM";
        CreateLanguage: Codeunit "Create Language";
    begin
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Company(), '', Enum::"Salutation Formula Salutation Type"::Formal, DearSirsLbl, Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Company(), '', Enum::"Salutation Formula Salutation Type"::Informal, BlankSalutationLbl, Enum::"Salutation Formula Name"::"Company Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Company(), CreateLanguage.DAN(), Enum::"Salutation Formula Salutation Type"::Formal, TilRetteVedkommendeLbl, Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Company(), CreateLanguage.DAN(), Enum::"Salutation Formula Salutation Type"::Informal, BlankSalutationLbl, Enum::"Salutation Formula Name"::"Company Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Company(), CreateLanguage.DEU(), Enum::"Salutation Formula Salutation Type"::Formal, SehrGeehrteDamenUndHerrenLbl, Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Company(), CreateLanguage.DEU(), Enum::"Salutation Formula Salutation Type"::Informal, BlankSalutationLbl, Enum::"Salutation Formula Name"::"Company Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Company(), CreateLanguage.ENU(), Enum::"Salutation Formula Salutation Type"::Formal, DearSirsLbl, Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Company(), CreateLanguage.ENU(), Enum::"Salutation Formula Salutation Type"::Informal, BlankSalutationLbl, Enum::"Salutation Formula Name"::"Company Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Company(), CreateLanguage.ESP(), Enum::"Salutation Formula Salutation Type"::Formal, EstimadoSeñorOLaSeñoraLbl, Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Company(), CreateLanguage.ESP(), Enum::"Salutation Formula Salutation Type"::Informal, BlankSalutationLbl, Enum::"Salutation Formula Name"::"Company Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Company(), CreateLanguage.FRA(), Enum::"Salutation Formula Salutation Type"::Formal, CherMonsieurOuMadameLbl, Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Company(), CreateLanguage.FRA(), Enum::"Salutation Formula Salutation Type"::Informal, BlankSalutationLbl, Enum::"Salutation Formula Name"::"Company Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Company(), CreateLanguage.ITA(), Enum::"Salutation Formula Salutation Type"::Formal, SpettabileDittaLbl, Enum::"Salutation Formula Name"::"Company Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Company(), CreateLanguage.ITA(), Enum::"Salutation Formula Salutation Type"::Informal, BlankSalutationLbl, Enum::"Salutation Formula Name"::"Company Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");

        ContosoCRM.InsertSalutationFormula(CreateSalutations.Female(), '', Enum::"Salutation Formula Salutation Type"::Formal, DearMsLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Female(), '', Enum::"Salutation Formula Salutation Type"::Informal, HiLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Female(), CreateLanguage.DAN(), Enum::"Salutation Formula Salutation Type"::Formal, KæreFrLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Female(), CreateLanguage.DAN(), Enum::"Salutation Formula Salutation Type"::Informal, HejLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Female(), CreateLanguage.DEU(), Enum::"Salutation Formula Salutation Type"::Formal, SehrGeehrteFrauLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Female(), CreateLanguage.DEU(), Enum::"Salutation Formula Salutation Type"::Informal, HalloLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Female(), CreateLanguage.ENU(), Enum::"Salutation Formula Salutation Type"::Formal, DearMsLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Female(), CreateLanguage.ENU(), Enum::"Salutation Formula Salutation Type"::Informal, HiLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Female(), CreateLanguage.ESP(), Enum::"Salutation Formula Salutation Type"::Formal, EstimadaSeñoraLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Female(), CreateLanguage.ESP(), Enum::"Salutation Formula Salutation Type"::Informal, EstimadaSeñoraLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Female(), CreateLanguage.FRA(), Enum::"Salutation Formula Salutation Type"::Formal, ChèreMadameLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Female(), CreateLanguage.FRA(), Enum::"Salutation Formula Salutation Type"::Informal, BlankSalutationLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Female(), CreateLanguage.ITA(), Enum::"Salutation Formula Salutation Type"::Formal, GentileSignoraLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Female(), CreateLanguage.ITA(), Enum::"Salutation Formula Salutation Type"::Informal, CaraLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");

        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleMarried(), '', Enum::"Salutation Formula Salutation Type"::Formal, DearMsLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleMarried(), '', Enum::"Salutation Formula Salutation Type"::Informal, HiLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleMarried(), CreateLanguage.DAN(), Enum::"Salutation Formula Salutation Type"::Formal, KæreFruLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleMarried(), CreateLanguage.DAN(), Enum::"Salutation Formula Salutation Type"::Informal, HejLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleMarried(), CreateLanguage.DEU(), Enum::"Salutation Formula Salutation Type"::Formal, SehrGeehrteFrauLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleMarried(), CreateLanguage.DEU(), Enum::"Salutation Formula Salutation Type"::Informal, HalloLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleMarried(), CreateLanguage.ENU(), Enum::"Salutation Formula Salutation Type"::Formal, DearMsLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleMarried(), CreateLanguage.ENU(), Enum::"Salutation Formula Salutation Type"::Informal, HiLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleMarried(), CreateLanguage.ESP(), Enum::"Salutation Formula Salutation Type"::Formal, EstimadaSeñoraLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleMarried(), CreateLanguage.ESP(), Enum::"Salutation Formula Salutation Type"::Informal, EstimadaSeñoraLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleMarried(), CreateLanguage.FRA(), Enum::"Salutation Formula Salutation Type"::Formal, ChèreMadameLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleMarried(), CreateLanguage.FRA(), Enum::"Salutation Formula Salutation Type"::Informal, BlankSalutationLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleMarried(), CreateLanguage.ITA(), Enum::"Salutation Formula Salutation Type"::Formal, GentileSignora2Lbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Surname", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleMarried(), CreateLanguage.ITA(), Enum::"Salutation Formula Salutation Type"::Informal, CaraLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");

        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleUnMarried(), '', Enum::"Salutation Formula Salutation Type"::Formal, DearMsLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleUnMarried(), '', Enum::"Salutation Formula Salutation Type"::Informal, HiLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleUnMarried(), CreateLanguage.DAN(), Enum::"Salutation Formula Salutation Type"::Formal, KæreFrkLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleUnMarried(), CreateLanguage.DAN(), Enum::"Salutation Formula Salutation Type"::Informal, HejLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleUnMarried(), CreateLanguage.DEU(), Enum::"Salutation Formula Salutation Type"::Formal, SehrGeehrteFrauLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleUnMarried(), CreateLanguage.DEU(), Enum::"Salutation Formula Salutation Type"::Informal, HalloLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleUnMarried(), CreateLanguage.ENU(), Enum::"Salutation Formula Salutation Type"::Formal, DearMsLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleUnMarried(), CreateLanguage.ENU(), Enum::"Salutation Formula Salutation Type"::Informal, HiLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleUnMarried(), CreateLanguage.ESP(), Enum::"Salutation Formula Salutation Type"::Formal, EstimadaSeñoraLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleUnMarried(), CreateLanguage.ESP(), Enum::"Salutation Formula Salutation Type"::Informal, EstimadaSeñoraLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleUnMarried(), CreateLanguage.FRA(), Enum::"Salutation Formula Salutation Type"::Formal, ChèreMadameLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleUnMarried(), CreateLanguage.FRA(), Enum::"Salutation Formula Salutation Type"::Informal, BlankSalutationLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleUnMarried(), CreateLanguage.ITA(), Enum::"Salutation Formula Salutation Type"::Formal, GentileSignorinaLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Surname", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.FemaleUnMarried(), CreateLanguage.ITA(), Enum::"Salutation Formula Salutation Type"::Informal, CaraLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");

        ContosoCRM.InsertSalutationFormula(CreateSalutations.Male(), '', Enum::"Salutation Formula Salutation Type"::Formal, DearMrLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Male(), '', Enum::"Salutation Formula Salutation Type"::Informal, HiLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Male(), CreateLanguage.DAN(), Enum::"Salutation Formula Salutation Type"::Formal, KæreHrLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Male(), CreateLanguage.DAN(), Enum::"Salutation Formula Salutation Type"::Informal, HejLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Male(), CreateLanguage.DEU(), Enum::"Salutation Formula Salutation Type"::Formal, SehrGeehrterHerrLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Male(), CreateLanguage.DEU(), Enum::"Salutation Formula Salutation Type"::Informal, HalloLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Male(), CreateLanguage.ENU(), Enum::"Salutation Formula Salutation Type"::Formal, DearMrLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Male(), CreateLanguage.ENU(), Enum::"Salutation Formula Salutation Type"::Informal, HiLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Male(), CreateLanguage.ESP(), Enum::"Salutation Formula Salutation Type"::Formal, EstimadoSeñorLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Male(), CreateLanguage.ESP(), Enum::"Salutation Formula Salutation Type"::Informal, EstimadoSeñorLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Male(), CreateLanguage.FRA(), Enum::"Salutation Formula Salutation Type"::Formal, ChèreMonsieurLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Male(), CreateLanguage.FRA(), Enum::"Salutation Formula Salutation Type"::Informal, BlankSalutationLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Male(), CreateLanguage.ITA(), Enum::"Salutation Formula Salutation Type"::Formal, GentileSignorLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Male(), CreateLanguage.ITA(), Enum::"Salutation Formula Salutation Type"::Informal, CaroLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");

        ContosoCRM.InsertSalutationFormula(CreateSalutations.Unisex(), '', Enum::"Salutation Formula Salutation Type"::Formal, DearLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Unisex(), '', Enum::"Salutation Formula Salutation Type"::Informal, HiLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Unisex(), CreateLanguage.DAN(), Enum::"Salutation Formula Salutation Type"::Formal, KæreLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Unisex(), CreateLanguage.DAN(), Enum::"Salutation Formula Salutation Type"::Informal, HejLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Unisex(), CreateLanguage.DEU(), Enum::"Salutation Formula Salutation Type"::Formal, SehrGeehrteRLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Unisex(), CreateLanguage.DEU(), Enum::"Salutation Formula Salutation Type"::Informal, HalloLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Unisex(), CreateLanguage.ENU(), Enum::"Salutation Formula Salutation Type"::Formal, DearLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Unisex(), CreateLanguage.ENU(), Enum::"Salutation Formula Salutation Type"::Informal, HiLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Unisex(), CreateLanguage.ESP(), Enum::"Salutation Formula Salutation Type"::Formal, EstimadoALbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Unisex(), CreateLanguage.ESP(), Enum::"Salutation Formula Salutation Type"::Informal, HolaLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Unisex(), CreateLanguage.FRA(), Enum::"Salutation Formula Salutation Type"::Formal, ChèreLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Unisex(), CreateLanguage.FRA(), Enum::"Salutation Formula Salutation Type"::Informal, BlankSalutationLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Unisex(), CreateLanguage.ITA(), Enum::"Salutation Formula Salutation Type"::Formal, GentileLbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::"Middle Name", Enum::"Salutation Formula Name"::"Surname");
        ContosoCRM.InsertSalutationFormula(CreateSalutations.Unisex(), CreateLanguage.ITA(), Enum::"Salutation Formula Salutation Type"::Informal, CaroALbl, Enum::"Salutation Formula Name"::"First Name", Enum::"Salutation Formula Name"::" ", Enum::"Salutation Formula Name"::" ");
    end;

    var
        DearSirsLbl: Label 'Dear Sirs,', MaxLength = 50;
        TilRetteVedkommendeLbl: Label 'Til rette vedkommende,', Locked = true;
        SehrGeehrteDamenUndHerrenLbl: Label 'Sehr geehrte Damen und Herren,', Locked = true;
        EstimadoSeñorOLaSeñoraLbl: Label 'Estimado Señor o la Señora,', Locked = true;
        CherMonsieurOuMadameLbl: Label 'Cher Monsieur ou Madame,', Locked = true;
        SpettabileDittaLbl: Label 'Spettabile Ditta %1,', Locked = true;
        DearMsLbl: Label 'Dear Ms. %1 %2 %3,', Comment = '%1 is Name 1, %2 is Name2, %3 is Name3', MaxLength = 50;
        HiLbl: Label 'Hi %1,', Comment = '%1 is Name 1', MaxLength = 50;
        KæreFrLbl: Label 'Kære Fr. %1 %2 %3,', Locked = true;
        HejLbl: Label 'Hej %1,', Locked = true;
        SehrGeehrteFrauLbl: Label 'Sehr geehrte Frau %1 %2 %3,', Locked = true;
        HalloLbl: Label 'Hallo %1,', Comment = '%1 is Name 1', MaxLength = 50;
        EstimadaSeñoraLbl: Label 'Estimada Señora %1 %2 %3,', Locked = true;
        ChèreMadameLbl: Label 'Chère Madame %1 %2 %3,', Locked = true;
        CaraLbl: Label 'Cara %1,', Locked = true;
        KæreFruLbl: Label 'Kære Fru. %1 %2 %3,', Locked = true;
        GentileSignoraLbl: Label 'Gentile Signora %1,', Locked = true;
        GentileSignora2Lbl: Label 'Gentile Signora %1 %2,', Locked = true;
        KæreFrkLbl: Label 'Kære Frk. %1 %2 %3,', Locked = true;
        GentileSignorinaLbl: Label 'Gentile Signorina %1 %2,', Locked = true;
        DearMrLbl: Label 'Dear Mr. %1 %2 %3,', Comment = '%1 is Name 1, %2 is Name2, %3 is Name3', MaxLength = 50;
        KæreHrLbl: Label 'Kære Hr. %1 %2 %3,', Locked = true;
        SehrGeehrterHerrLbl: Label 'Sehr geehrter Herr %1 %2 %3,', Locked = true;
        EstimadoSeñorLbl: Label 'Estimado Señor %1 %2 %3,', Locked = true;
        ChèreMonsieurLbl: Label 'Chère Monsieur %1 %2 %3,', Locked = true;
        GentileSignorLbl: Label 'Gentile Signor %1,', Locked = true;
        CaroLbl: Label 'Caro %1,', Locked = true;
        DearLbl: Label 'Dear %1 %2 %3,', Comment = '%1 is Name 1, %2 is Name2, %3 is Name3', MaxLength = 50;
        KæreLbl: Label 'Kære %1 %2 %3,', Locked = true;
        SehrGeehrteRLbl: Label 'Sehr geehrte/r %1 %2 %3,', Locked = true;
        EstimadoALbl: Label 'Estimado/a %1 %2 %3,', Locked = true;
        HolaLbl: Label 'Hola %1,', Locked = true;
        ChèreLbl: Label 'Chère %1 %2 %3,', Locked = true;
        GentileLbl: Label 'Gentile %1 %2 %3,', Locked = true;
        CaroALbl: Label 'Caro/a %1,', Locked = true;
        BlankSalutationLbl: Label '%1,', Locked = true;
}