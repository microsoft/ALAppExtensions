codeunit 5305 "Create Territory"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
    begin
        ContosoCRM.InsertTerritory(East(), EastLbl);
        ContosoCRM.InsertTerritory(EastAnglia(), EastAngliaLbl);
        ContosoCRM.InsertTerritory(Foreign(), ForeignLbl);
        ContosoCRM.InsertTerritory(London(), LondonLbl);
        ContosoCRM.InsertTerritory(Midlands(), MidlandsLbl);
        ContosoCRM.InsertTerritory(North(), NorthLbl);
        ContosoCRM.InsertTerritory(NorthEast(), NorthEastLbl);
        ContosoCRM.InsertTerritory(NorthWest(), NorthWestLbl);
        ContosoCRM.InsertTerritory(NorthWales(), NorthWalesLbl);
        ContosoCRM.InsertTerritory(South(), SouthLbl);
        ContosoCRM.InsertTerritory(Scotland(), ScotlandLbl);
        ContosoCRM.InsertTerritory(SouthEast(), SouthEastLbl);
        ContosoCRM.InsertTerritory(SouthWest(), SouthWestLbl);
        ContosoCRM.InsertTerritory(SouthWales(), SouthWalesLbl);
        ContosoCRM.InsertTerritory(West(), WestCountryLbl);
    end;

    procedure East(): Code[10]
    begin
        exit(EastTok);
    end;

    procedure EastAnglia(): Code[10]
    begin
        exit(EastAngliaTok);
    end;

    procedure Foreign(): Code[10]
    begin
        exit(ForeignTok);
    end;

    procedure London(): Code[10]
    begin
        exit(LondonTok);
    end;

    procedure Midlands(): Code[10]
    begin
        exit(MidlandsTok);
    end;

    procedure North(): Code[10]
    begin
        exit(NorthTok);
    end;

    procedure NorthEast(): Code[10]
    begin
        exit(NorthEastTok);
    end;

    procedure NorthWest(): Code[10]
    begin
        exit(NorthWestTok);
    end;

    procedure NorthWales(): Code[10]
    begin
        exit(NorthWalesTok);
    end;

    procedure South(): Code[10]
    begin
        exit(SouthTok);
    end;

    procedure Scotland(): Code[10]
    begin
        exit(ScotlandTok);
    end;

    procedure SouthEast(): Code[10]
    begin
        exit(SouthEastTok);
    end;

    procedure SouthWest(): Code[10]
    begin
        exit(SouthWestTok);
    end;

    procedure SouthWales(): Code[10]
    begin
        exit(SouthWalesTok);
    end;

    procedure West(): Code[10]
    begin
        exit(WestTok);
    end;

    var
        EastTok: Label 'E', MaxLength = 10;
        EastAngliaTok: Label 'EANG', MaxLength = 10;
        ForeignTok: Label 'FOREIGN', MaxLength = 10;
        LondonTok: Label 'LND', MaxLength = 10;
        MidlandsTok: Label 'MID', MaxLength = 10;
        NorthTok: Label 'N', MaxLength = 10;
        NorthEastTok: Label 'NE', MaxLength = 10;
        NorthWestTok: Label 'NW', MaxLength = 10;
        NorthWalesTok: Label 'NWAL', MaxLength = 10;
        SouthTok: Label 'S', MaxLength = 10;
        ScotlandTok: Label 'SCOT', MaxLength = 10;
        SouthEastTok: Label 'SE', MaxLength = 10;
        SouthWestTok: Label 'SW', MaxLength = 10;
        SouthWalesTok: Label 'SWAL', MaxLength = 10;
        WestTok: Label 'W', MaxLength = 10;
        EastLbl: Label 'East', MaxLength = 50;
        EastAngliaLbl: Label 'East Anglia', MaxLength = 50;
        ForeignLbl: Label 'Foreign', MaxLength = 50;
        LondonLbl: Label 'London', MaxLength = 50;
        MidlandsLbl: Label 'Midlands', MaxLength = 50;
        NorthLbl: Label 'North', MaxLength = 50;
        NorthEastLbl: Label 'North East', MaxLength = 50;
        NorthWestLbl: Label 'North West', MaxLength = 50;
        NorthWalesLbl: Label 'North Wales', MaxLength = 50;
        SouthLbl: Label 'South', MaxLength = 50;
        ScotlandLbl: Label 'Scotland', MaxLength = 50;
        SouthEastLbl: Label 'South East', MaxLength = 50;
        SouthWestLbl: Label 'South West', MaxLength = 50;
        SouthWalesLbl: Label 'South Wales', MaxLength = 50;
        WestCountryLbl: Label 'West Country', MaxLength = 50;
}