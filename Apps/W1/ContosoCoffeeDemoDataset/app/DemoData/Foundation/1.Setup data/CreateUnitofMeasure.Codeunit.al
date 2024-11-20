codeunit 5248 "Create Unit of Measure"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateUnitOfMeasure();
        CreateUnitOfMeasureTranslation();
    end;

    local procedure CreateUnitOfMeasure()
    var
        ContosoUnitOfMeasure: codeunit "Contoso Unit of Measure";
    begin
        ContosoUnitOfMeasure.InsertUnitOfMeasure(Hour(), HourLbl, 'HUR');
        ContosoUnitOfMeasure.InsertUnitOfMeasure(Day(), DayLbl, 'DAY');
        ContosoUnitOfMeasure.InsertUnitOfMeasure(Piece(), PieceLbl, 'EA');
        ContosoUnitOfMeasure.InsertUnitOfMeasure(Can(), CanLbl, 'CA');
        ContosoUnitOfMeasure.InsertUnitOfMeasure(Box(), BoxLbl, 'BX');
        ContosoUnitOfMeasure.InsertUnitOfMeasure(Pallet(), PalletLbl, 'PF');
        ContosoUnitOfMeasure.InsertUnitOfMeasure(Pack(), PackLbl, 'PK');
        ContosoUnitOfMeasure.InsertUnitOfMeasure(Miles(), MilesLbl, '1A');
        ContosoUnitOfMeasure.InsertUnitOfMeasure(KM(), KilometerLbl, 'KMT');
        ContosoUnitOfMeasure.InsertUnitOfMeasure(KG(), KiloLbl, 'KGM');
        ContosoUnitOfMeasure.InsertUnitOfMeasure(Set(), SetLbl, 'SET');
        ContosoUnitOfMeasure.InsertUnitOfMeasure(Bag(), BagLbl, 'BAG');
        ContosoUnitOfMeasure.InsertUnitOfMeasure(Gram(), GramLbl, 'GRM');
        ContosoUnitOfMeasure.InsertUnitOfMeasure(L(), LiterLbl, 'LTR');
        ContosoUnitOfMeasure.InsertUnitOfMeasure(Ton(), TonneLbl, 'TN');
        ContosoUnitOfMeasure.InsertUnitOfMeasure(KWH(), KWHLbl, 'KWH');
        ContosoUnitOfMeasure.InsertUnitOfMeasure(CM(), CMLbl, 'CM');
    end;

    local procedure CreateUnitOfMeasureTranslation()
    var
        ContosoUnitOfMeasure: codeunit "Contoso Unit of Measure";
        CreateLanguage: Codeunit "Create Language";
    begin
        ContosoUnitOfMeasure.InsertUnitOfMeasureTranslation(Can(), 'ds', CreateLanguage.DAN());
        ContosoUnitOfMeasure.InsertUnitOfMeasureTranslation(Piece(), 'stk', CreateLanguage.DAN());
        ContosoUnitOfMeasure.InsertUnitOfMeasureTranslation(Piece(), 'stück', CreateLanguage.DEU());
        ContosoUnitOfMeasure.InsertUnitOfMeasureTranslation(Piece(), 'stuk', CreateLanguage.NLD());
    end;

    procedure Bag(): Code[10]
    begin
        exit(BagTok);
    end;

    procedure Piece(): Code[10]
    begin
        exit(PieceTok);
    end;

    procedure Can(): Code[10]
    begin
        exit(CanTok);
    end;

    procedure Set(): Code[10]
    begin
        exit(SetTok);
    end;

    procedure Hour(): Code[10]
    begin
        exit(HourTok);
    end;

    procedure Day(): Code[10]
    begin
        exit(DayTok);
    end;

    procedure Box(): Code[10]
    begin
        exit(BoxTok);
    end;

    procedure Pallet(): Code[10]
    begin
        exit(PalletTok);
    end;

    procedure Pack(): Code[10]
    begin
        exit(PackTok);
    end;

    procedure Miles(): Code[10]
    begin
        exit(MilesTok);
    end;

    procedure KM(): Code[10]
    begin
        exit(KMLbl);
    end;

    procedure KG(): Code[10]
    begin
        exit(KGLbl);
    end;

    procedure Gram(): Code[10]
    begin
        exit(GRTok);
    end;

    procedure L(): Code[10]
    begin
        exit(LTok);
    end;

    procedure Ton(): Code[10]
    begin
        exit(TTok);
    end;

    procedure KWH(): Code[10]
    begin
        exit(KWHTok);
    end;

    procedure CM(): Code[10]
    begin
        exit(CMTok);
    end;

    var
        HourLbl: Label 'Hour', MaxLength = 50;
        HourTok: Label 'HOUR', MaxLength = 10;
        DayLbl: Label 'Day', MaxLength = 50;
        DayTok: Label 'DAY', MaxLength = 10;
        PieceLbl: Label 'Piece', MaxLength = 50;
        PieceTok: Label 'PCS', MaxLength = 10;
        CanLbl: Label 'Can', MaxLength = 50;
        CanTok: Label 'CAN', MaxLength = 10;
        BoxLbl: Label 'Box', MaxLength = 50;
        BoxTok: Label 'BOX', MaxLength = 10;
        PalletLbl: Label 'Pallet', MaxLength = 50;
        PalletTok: Label 'PALLET', MaxLength = 10;
        PackLbl: Label 'Pack', MaxLength = 50;
        PackTok: Label 'PACK', MaxLength = 10;
        MilesLbl: Label 'Miles', MaxLength = 50;
        MilesTok: Label 'MILES', MaxLength = 10;
        KilometerLbl: Label 'Kilometer', MaxLength = 50;
        KMLbl: Label 'KM', MaxLength = 10;
        KGLbl: Label 'KG', MaxLength = 10;
        KiloLbl: Label 'Kilo', MaxLength = 10;
        SetTok: Label 'SET', MaxLength = 10;
        SetLbl: Label 'Set', MaxLength = 50;
        BagTok: Label 'BAG', MaxLength = 10;
        BagLbl: Label 'Bag', MaxLength = 50;
        GRTok: Label 'GR', MaxLength = 10;
        GramLbl: Label 'Gram', MaxLength = 50;
        LTok: Label 'L', MaxLength = 10;
        LiterLbl: Label 'Liter', MaxLength = 50;
        TTok: Label 'T', MaxLength = 10;
        TonneLbl: Label 'Tonne', MaxLength = 50;
        KWHTok: Label 'KWH', MaxLength = 10;
        KWHLbl: Label 'KW Hour', MaxLength = 50;
        CMTok: Label 'CM', MaxLength = 10;
        CMLbl: Label 'Centimeter', MaxLength = 50;
}
