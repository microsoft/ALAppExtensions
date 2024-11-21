codeunit 11397 "Create Territory BE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
    begin
        ContosoCRM.InsertTerritory(Coast(), BelgianCoastLbl);
        ContosoCRM.InsertTerritory(Hagel(), HagelandLbl);
        ContosoCRM.InsertTerritory(Kemplimb(), KempenandLimburgLbl);
        ContosoCRM.InsertTerritory(Lierherent(), RegionLierHerentalsLbl);
        ContosoCRM.InsertTerritory(NK(), NoorderkempenLbl);
        ContosoCRM.InsertTerritory(Voeren(), VoerenFouronsLbl);
    end;

    procedure Coast(): Code[10]
    begin
        exit(CoastTok);
    end;

    procedure Hagel(): Code[10]
    begin
        exit(HagelTok);
    end;

    procedure Kemplimb(): Code[10]
    begin
        exit(KemplimbTok);
    end;

    procedure Lierherent(): Code[10]
    begin
        exit(LierherentTok);
    end;

    procedure NK(): Code[10]
    begin
        exit(NKTok);
    end;

    procedure Voeren(): Code[10]
    begin
        exit(VoerenTok);
    end;

    var
        CoastTok: Label 'COAST', Locked = true, MaxLength = 10;
        HagelTok: Label 'HAGEL', Locked = true, MaxLength = 10;
        NKTok: Label 'NK', Locked = true, MaxLength = 10;
        KemplimbTok: Label 'KEMPLIMB', Locked = true, MaxLength = 10;
        LierherentTok: Label 'LIERHERENT', Locked = true, MaxLength = 10;
        VoerenTok: Label 'VOEREN', Locked = true, MaxLength = 10;
        BelgianCoastLbl: Label 'Belgian Coast', MaxLength = 50;
        HagelandLbl: Label 'Hageland', MaxLength = 50;
        KempenandLimburgLbl: Label 'Kempen and Limburg', MaxLength = 50;
        RegionLierHerentalsLbl: Label 'Region Lier-Herentals', MaxLength = 50;
        NoorderkempenLbl: Label 'Noorderkempen', MaxLength = 50;
        VoerenFouronsLbl: Label 'Voeren/Fourons', MaxLength = 50;
}