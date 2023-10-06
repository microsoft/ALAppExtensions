codeunit 5130 "Create Common Unit Of Measure"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
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
        ContosoUnitOfMeasure.InsertUnitOfMeasure(Gram(), GramTok, 'GRM');
        ContosoUnitOfMeasure.InsertUnitOfMeasure(L(), LiterTok, 'LTR');
    end;

    var
        HourLbl: Label 'Hour', MaxLength = 10;
        HourTok: Label 'HOUR', MaxLength = 10;
        DayLbl: Label 'Day', MaxLength = 10;
        DayTok: Label 'DAY', MaxLength = 10;
        PieceLbl: Label 'Piece', MaxLength = 10;
        PieceTok: Label 'PCS', MaxLength = 10;
        CanLbl: Label 'Can', MaxLength = 10;
        CanTok: Label 'CAN', MaxLength = 10;
        BoxLbl: Label 'Box', MaxLength = 10;
        BoxTok: Label 'BOX', MaxLength = 10;
        PalletLbl: Label 'Pallet', MaxLength = 10;
        PalletTok: Label 'PALLET', MaxLength = 10;
        PackLbl: Label 'Pack', MaxLength = 10;
        PackTok: Label 'PACK', MaxLength = 10;
        MilesLbl: Label 'Miles', MaxLength = 10;
        MilesTok: Label 'MILES', MaxLength = 10;
        KilometerLbl: Label 'Kilometer', MaxLength = 10;
        KMLbl: Label 'KM', MaxLength = 10;
        KGLbl: Label 'KG', MaxLength = 10;
        KiloLbl: Label 'Kilo', MaxLength = 10;
        SetTok: Label 'SET', MaxLength = 10;
        SetLbl: Label 'Set', MaxLength = 10;
        BagTok: Label 'BAG', MaxLength = 10;
        BagLbl: Label 'Bag', MaxLength = 10;
        GRTok: Label 'GR', MaxLength = 10;
        GramTok: Label 'Gram', MaxLength = 10;
        LTok: Label 'L', MaxLength = 10;
        LiterTok: Label 'Liter', MaxLength = 10;

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

}