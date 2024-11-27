codeunit 10804 "Create ES Territory"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
    begin
        ContosoCRM.SetOverwriteData(true);
        ContosoCRM.InsertTerritory(Andalucia(), AndaluciaLbl);
        ContosoCRM.InsertTerritory(Ara(), AragónLbl);
        ContosoCRM.InsertTerritory(Ast(), AsturiasLbl);
        ContosoCRM.InsertTerritory(Bal(), BalearesLbl);
        ContosoCRM.InsertTerritory(Can(), CanariasLbl);
        ContosoCRM.InsertTerritory(Cant(), CantabriaLbl);
        ContosoCRM.InsertTerritory(Casleo(), CastillaLeónLbl);
        ContosoCRM.InsertTerritory(Casman(), CastillaLaManchaLbl);
        ContosoCRM.InsertTerritory(Cat(), CataluñaLbl);
        ContosoCRM.InsertTerritory(Ceu(), CeutaLbl);
        ContosoCRM.InsertTerritory(Ext(), ExtremaduraLbl);
        ContosoCRM.InsertTerritory(Gal(), GaliciaLbl);
        ContosoCRM.InsertTerritory(Mad(), MadridLbl);
        ContosoCRM.InsertTerritory(Mel(), MelillaLbl);
        ContosoCRM.InsertTerritory(Mur(), MurciaLbl);
        ContosoCRM.InsertTerritory(Nav(), NavarraLbl);
        ContosoCRM.InsertTerritory(Rio(), RiojaLbl);
        ContosoCRM.InsertTerritory(Val(), ValenciaLbl);
        ContosoCRM.SetOverwriteData(false);
    end;

    procedure Andalucia(): Code[10]
    begin
        exit(AndTok);
    end;

    procedure Ara(): Code[10]
    begin
        exit(AraTok);
    end;

    procedure Ast(): Code[10]
    begin
        exit(AstTok);
    end;

    procedure Bal(): Code[10]
    begin
        exit(BalTok);
    end;

    procedure Can(): Code[10]
    begin
        exit(CanTok);
    end;

    procedure Cant(): Code[10]
    begin
        exit(CantTok);
    end;

    procedure Casleo(): Code[10]
    begin
        exit(CasleoTok);
    end;

    procedure Casman(): Code[10]
    begin
        exit(CasmanTok);
    end;

    procedure Cat(): Code[10]
    begin
        exit(CatTok);
    end;

    procedure Ceu(): Code[10]
    begin
        exit(CeuTok);
    end;

    procedure Ext(): Code[10]
    begin
        exit(ExtTok);
    end;

    procedure Gal(): Code[10]
    begin
        exit(GalTok);
    end;

    procedure Mad(): Code[10]
    begin
        exit(MadTok);
    end;

    procedure Mel(): Code[10]
    begin
        exit(MelTok);
    end;

    procedure Mur(): Code[10]
    begin
        exit(MurTok);
    end;

    procedure Nav(): Code[10]
    begin
        exit(NavTok);
    end;

    procedure Rio(): Code[10]
    begin
        exit(RioTok);
    end;

    procedure Val(): Code[10]
    begin
        exit(ValTok);
    end;

    var
        AndTok: Label 'AND', MaxLength = 10;
        AraTok: Label 'ARA', MaxLength = 10;
        AstTok: Label 'AST', MaxLength = 10;
        BalTok: Label 'BAL', MaxLength = 10;
        CanTok: Label 'CAN', MaxLength = 10;
        CantTok: Label 'CANT', MaxLength = 10;
        CasleoTok: Label 'CASLEO', MaxLength = 10;
        CasmanTok: Label 'CASMAN', MaxLength = 10;
        CatTok: Label 'CAT', MaxLength = 10;
        CeuTok: Label 'CEU', MaxLength = 10;
        ExtTok: Label 'EXT', MaxLength = 10;
        GalTok: Label 'GAL', MaxLength = 10;
        MadTok: Label 'MAD', MaxLength = 10;
        MelTok: Label 'MEL', MaxLength = 10;
        MurTok: Label 'MUR', MaxLength = 10;
        NavTok: Label 'NAV', MaxLength = 10;
        RioTok: Label 'RIO', MaxLength = 10;
        ValTok: Label 'VAL', MaxLength = 10;
        AndaluciaLbl: Label 'Andalucia', MaxLength = 50;
        AragónLbl: Label 'Aragón', MaxLength = 50;
        AsturiasLbl: Label 'Asturias', MaxLength = 50;
        BalearesLbl: Label 'Baleares', MaxLength = 50;
        CanariasLbl: Label 'Canarias', MaxLength = 50;
        CantabriaLbl: Label 'Cantabria', MaxLength = 50;
        CastillaLeónLbl: Label 'Castilla - León', MaxLength = 50;
        CastillaLaManchaLbl: Label 'Castilla - La Mancha', MaxLength = 50;
        CataluñaLbl: Label 'Cataluña', MaxLength = 50;
        CeutaLbl: Label 'Ceuta', MaxLength = 50;
        ExtremaduraLbl: Label 'Extremadura', MaxLength = 50;
        GaliciaLbl: Label 'Galicia', MaxLength = 50;
        MadridLbl: Label 'Madrid', MaxLength = 50;
        MelillaLbl: Label 'Melilla', MaxLength = 50;
        MurciaLbl: Label 'Murcia', MaxLength = 50;
        NavarraLbl: Label 'Navarra', MaxLength = 50;
        RiojaLbl: Label 'Rioja', MaxLength = 50;
        ValenciaLbl: Label 'Valencia', MaxLength = 50;
}