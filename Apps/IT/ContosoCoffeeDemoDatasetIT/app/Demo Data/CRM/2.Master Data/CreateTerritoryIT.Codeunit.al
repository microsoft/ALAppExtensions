codeunit 12230 "Create Territory IT"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
    begin
        ContosoCRM.SetOverwriteData(true);
        ContosoCRM.InsertTerritory(Abruzzo(), AbruzzoLbl);
        ContosoCRM.InsertTerritory(Basilicata(), BasilicataLbl);
        ContosoCRM.InsertTerritory(Calabria(), CalabriaLbl);
        ContosoCRM.InsertTerritory(Campania(), CampaniaLbl);
        ContosoCRM.InsertTerritory(Emromagna(), EmiliaRomagnaLbl);
        ContosoCRM.InsertTerritory(Frvengiu(), FriuliVeneziaGiuliaLbl);
        ContosoCRM.InsertTerritory(Lazio(), LazioLbl);
        ContosoCRM.InsertTerritory(Liguria(), LiguriaLbl);
        ContosoCRM.InsertTerritory(Marche(), MarcheLbl);
        ContosoCRM.InsertTerritory(Molise(), MoliseLbl);
        ContosoCRM.InsertTerritory(Piemonte(), PiemonteLbl);
        ContosoCRM.InsertTerritory(Puglia(), PugliaLbl);
        ContosoCRM.InsertTerritory(Sardegna(), SardegnaLbl);
        ContosoCRM.InsertTerritory(Sicilia(), SiciliaLbl);
        ContosoCRM.InsertTerritory(Toscana(), ToscanaLbl);
        ContosoCRM.InsertTerritory(Traltoadig(), TrentinoAltoAdigeLbl);
        ContosoCRM.InsertTerritory(Umbria(), UmbriaLbl);
        ContosoCRM.InsertTerritory(Valdaosta(), ValleDAostaLbl);
        ContosoCRM.InsertTerritory(Veneto(), VenetoLbl);
        ContosoCRM.SetOverwriteData(false);
    end;

    procedure Abruzzo(): Code[10]
    begin
        exit(AbruzzoTok);
    end;

    procedure Basilicata(): Code[10]
    begin
        exit(BasilicataTok);
    end;

    procedure Calabria(): Code[10]
    begin
        exit(CalabriaTok);
    end;

    procedure Campania(): Code[10]
    begin
        exit(CampaniaTok);
    end;

    procedure Emromagna(): Code[10]
    begin
        exit(EmromagnaTok);
    end;

    procedure Frvengiu(): Code[10]
    begin
        exit(FrvengiuTok);
    end;

    procedure Lazio(): Code[10]
    begin
        exit(LazioTok);
    end;

    procedure Liguria(): Code[10]
    begin
        exit(LiguriaTok);
    end;

    procedure Marche(): Code[10]
    begin
        exit(MarcheTok);
    end;

    procedure Molise(): Code[10]
    begin
        exit(MoliseTok);
    end;

    procedure Piemonte(): Code[10]
    begin
        exit(PiemonteTok);
    end;

    procedure Puglia(): Code[10]
    begin
        exit(PugliaTok);
    end;

    procedure Sardegna(): Code[10]
    begin
        exit(SardegnaTok);
    end;

    procedure Sicilia(): Code[10]
    begin
        exit(SiciliaTok);
    end;

    procedure Toscana(): Code[10]
    begin
        exit(ToscanaTok);
    end;

    procedure Traltoadig(): Code[10]
    begin
        exit(TraltoadigTok);
    end;

    procedure Umbria(): Code[10]
    begin
        exit(UmbriaTok);
    end;

    procedure Valdaosta(): Code[10]
    begin
        exit(ValdaostaTok);
    end;

    procedure Veneto(): Code[10]
    begin
        exit(VenetoTok);
    end;


    var
        AbruzzoTok: Label 'ABRUZZO', MaxLength = 10;
        BasilicataTok: Label 'BASILICATA', MaxLength = 10;
        CalabriaTok: Label 'CALABRIA', MaxLength = 10;
        CampaniaTok: Label 'CAMPANIA', MaxLength = 10;
        EmromagnaTok: Label 'EMROMAGNA', MaxLength = 10;
        FrvengiuTok: Label 'FRVENGIU', MaxLength = 10;
        LazioTok: Label 'LAZIO', MaxLength = 10;
        LiguriaTok: Label 'LIGURIA', MaxLength = 10;
        MarcheTok: Label 'MARCHE', MaxLength = 10;
        MoliseTok: Label 'MOLISE', MaxLength = 10;
        PiemonteTok: Label 'PIEMONTE', MaxLength = 10;
        PugliaTok: Label 'PUGLIA', MaxLength = 10;
        SardegnaTok: Label 'SARDEGNA', MaxLength = 10;
        SiciliaTok: Label 'SICILIA', MaxLength = 10;
        ToscanaTok: Label 'TOSCANA', MaxLength = 10;
        TraltoadigTok: Label 'TRALTOADIG', MaxLength = 10;
        UmbriaTok: Label 'UMBRIA', MaxLength = 10;
        ValdaostaTok: Label 'VALDAOSTA', MaxLength = 10;
        VenetoTok: Label 'VENETO', MaxLength = 10;
        AbruzzoLbl: Label 'Abruzzo', MaxLength = 50;
        BasilicataLbl: Label 'Basilicata', MaxLength = 50;
        CalabriaLbl: Label 'Calabria', MaxLength = 50;
        CampaniaLbl: Label 'Campania', MaxLength = 50;
        EmiliaRomagnaLbl: Label 'Emilia Romagna', MaxLength = 50;
        FriuliVeneziaGiuliaLbl: Label 'Friuli Venezia Giulia', MaxLength = 50;
        LazioLbl: Label 'Lazio', MaxLength = 50;
        LiguriaLbl: Label 'Liguria', MaxLength = 50;
        MarcheLbl: Label 'Marche', MaxLength = 50;
        MoliseLbl: Label 'Molise', MaxLength = 50;
        PiemonteLbl: Label 'Piemonte', MaxLength = 50;
        PugliaLbl: Label 'Puglia', MaxLength = 50;
        SardegnaLbl: Label 'Sardegna', MaxLength = 50;
        SiciliaLbl: Label 'Sicilia', MaxLength = 50;
        ToscanaLbl: Label 'Toscana', MaxLength = 50;
        TrentinoAltoAdigeLbl: Label 'Trentino Alto Adige', MaxLength = 50;
        UmbriaLbl: Label 'Umbria', MaxLength = 50;
        ValleDAostaLbl: Label 'Valle d''Aosta', MaxLength = 50;
        VenetoLbl: Label 'Veneto', MaxLength = 50;

}