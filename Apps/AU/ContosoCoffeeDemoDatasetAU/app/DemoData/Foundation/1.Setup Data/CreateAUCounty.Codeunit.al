codeunit 17149 "Create AU County"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoAUCounty: Codeunit "Contoso AU County";
    begin
        ContosoAUCounty.SetOverwriteData(true);
        ContosoAUCounty.InsertCounty(Act(), AustralianCapitolTerritoryLbl);
        ContosoAUCounty.InsertCounty(Bangkok(), BangkokLbl);
        ContosoAUCounty.InsertCounty(BuriRam(), BuriRamLbl);
        ContosoAUCounty.InsertCounty(ChaiNat(), ChaiNatLbl);
        ContosoAUCounty.InsertCounty(ChiangMai(), ChiangMaiLbl);
        ContosoAUCounty.InsertCounty(EdoState(), EdoStateLbl);
        ContosoAUCounty.InsertCounty(Guanajuato(), GuanajuatoLbl);
        ContosoAUCounty.InsertCounty(KualaLumpur(), KualaLumpurLbl);
        ContosoAUCounty.InsertCounty(Nsw(), NewSouthWalesLbl);
        ContosoAUCounty.InsertCounty(Nt(), NorthernTerritoryLbl);
        ContosoAUCounty.InsertCounty(NuevoLeon(), NuevoLeonLbl);
        ContosoAUCounty.InsertCounty(PlateauState(), PlateauStateLbl);
        ContosoAUCounty.InsertCounty(Qld(), QueenslandLbl);
        ContosoAUCounty.InsertCounty(Sa(), SouthAustraliaLbl);
        ContosoAUCounty.InsertCounty(Sabah(), SabahLbl);
        ContosoAUCounty.InsertCounty(SanLuis(), SanLuisLbl);
        ContosoAUCounty.InsertCounty(Sarawak(), SarawakLbl);
        ContosoAUCounty.InsertCounty(Selangor(), SelangorLbl);
        ContosoAUCounty.InsertCounty(Sinaloa(), SinaloaLbl);
        ContosoAUCounty.InsertCounty(Tas(), TasmaniaLbl);
        ContosoAUCounty.InsertCounty(Vic(), VictoriaLbl);
        ContosoAUCounty.InsertCounty(Wa(), WesternAustraliaLbl);
        ContosoAUCounty.SetOverwriteData(false);
    end;

    procedure Act(): Text[30]
    begin
        exit(ActTok);
    end;

    procedure Bangkok(): Text[30]
    begin
        exit(BangkokTok);
    end;

    procedure BuriRam(): Text[30]
    begin
        exit(BuriRamTok);
    end;

    procedure ChaiNat(): Text[30]
    begin
        exit(ChaiNatTok);
    end;

    procedure ChiangMai(): Text[30]
    begin
        exit(ChiangMaiTok);
    end;

    procedure EdoState(): Text[30]
    begin
        exit(EdoStateTok);
    end;

    procedure Guanajuato(): Text[30]
    begin
        exit(GuanajuatoTok);
    end;

    procedure KualaLumpur(): Text[30]
    begin
        exit(KualaLumpurTok);
    end;

    procedure Nsw(): Text[30]
    begin
        exit(NswTok);
    end;

    procedure Nt(): Text[30]
    begin
        exit(NtTok);
    end;

    procedure NuevoLeon(): Text[30]
    begin
        exit(NuevoLeonTok);
    end;

    procedure PlateauState(): Text[30]
    begin
        exit(PlateauStateTok);
    end;

    procedure Qld(): Text[30]
    begin
        exit(QldTok);
    end;

    procedure Sa(): Text[30]
    begin
        exit(SaTok);
    end;

    procedure Sabah(): Text[30]
    begin
        exit(SabahTok);
    end;

    procedure SanLuis(): Text[30]
    begin
        exit(SanLuisTok);
    end;

    procedure Sarawak(): Text[30]
    begin
        exit(SarawakTok);
    end;

    procedure Selangor(): Text[30]
    begin
        exit(SelangorTok);
    end;

    procedure Sinaloa(): Text[30]
    begin
        exit(SinaloaTok);
    end;

    procedure Tas(): Text[30]
    begin
        exit(TasTok);
    end;

    procedure Vic(): Text[30]
    begin
        exit(VicTok);
    end;

    procedure Wa(): Text[30]
    begin
        exit(WaTok);
    end;

    var
        ActTok: Label 'ACT', MaxLength = 30;
        BangkokTok: Label 'Bangkok', MaxLength = 30;
        BuriRamTok: Label 'Buri Ram', MaxLength = 30;
        ChaiNatTok: Label 'Chai Nat', MaxLength = 30;
        ChiangMaiTok: Label 'Chiang Mai', MaxLength = 30;
        EdoStateTok: Label 'Edo state', MaxLength = 30;
        GuanajuatoTok: Label 'Guanajuato', MaxLength = 30;
        KualaLumpurTok: Label 'KUALA LUMPUR', MaxLength = 30;
        NswTok: Label 'NSW', MaxLength = 30;
        NtTok: Label 'NT', MaxLength = 30;
        NuevoLeonTok: Label 'Nuevo Leon', MaxLength = 30;
        PlateauStateTok: Label 'Plateau state', MaxLength = 30;
        QldTok: Label 'QLD', MaxLength = 30;
        SaTok: Label 'SA', MaxLength = 30;
        SabahTok: Label 'Sabah', MaxLength = 30;
        SanLuisTok: Label 'San Luis', MaxLength = 30;
        SarawakTok: Label 'Sarawak', MaxLength = 30;
        SelangorTok: Label 'Selangor', MaxLength = 30;
        SinaloaTok: Label 'Sinaloa', MaxLength = 30;
        TasTok: Label 'TAS', MaxLength = 30;
        VicTok: Label 'VIC', MaxLength = 30;
        WaTok: Label 'WA', MaxLength = 30;
        AustralianCapitolTerritoryLbl: Label 'Australian Capitol Territory', MaxLength = 30;
        BangkokLbl: Label 'Bangkok', MaxLength = 30;
        BuriRamLbl: Label 'Buri Ram', MaxLength = 30;
        ChaiNatLbl: Label 'Chai Nat', MaxLength = 30;
        ChiangMaiLbl: Label 'Chiang Mai', MaxLength = 30;
        EdoStateLbl: Label 'Edo state', MaxLength = 30;
        GuanajuatoLbl: Label 'Guanajuato', MaxLength = 30;
        KualaLumpurLbl: Label 'KUALA LUMPUR', MaxLength = 30;
        NewSouthWalesLbl: Label 'New South Wales', MaxLength = 30;
        NorthernTerritoryLbl: Label 'Northern Territory', MaxLength = 30;
        NuevoLeonLbl: Label 'Nuevo Leon', MaxLength = 30;
        PlateauStateLbl: Label 'Plateau state', MaxLength = 30;
        QueenslandLbl: Label 'Queensland', MaxLength = 30;
        SouthAustraliaLbl: Label 'South Australia', MaxLength = 30;
        SabahLbl: Label 'Sabah', MaxLength = 30;
        SanLuisLbl: Label 'San Luis', MaxLength = 30;
        SarawakLbl: Label 'Sarawak', MaxLength = 30;
        SelangorLbl: Label 'Selangor', MaxLength = 30;
        SinaloaLbl: Label 'Sinaloa', MaxLength = 30;
        TasmaniaLbl: Label 'Tasmania', MaxLength = 30;
        VictoriaLbl: Label 'Victoria', MaxLength = 30;
        WesternAustraliaLbl: Label 'Western Australia', MaxLength = 30;
}