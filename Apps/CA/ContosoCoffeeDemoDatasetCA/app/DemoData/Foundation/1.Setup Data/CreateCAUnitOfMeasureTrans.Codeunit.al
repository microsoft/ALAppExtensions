codeunit 27037 "Create CA UnitOfMeasureTrans."
{
    trigger OnRun()
    var
        CreateUnitofMeasure: Codeunit "Create Unit of Measure";
        ContosoCATranslation: Codeunit "Contoso CA Translation";
        CreateLanguage: Codeunit "Create Language";
    begin
        ContosoCATranslation.InsertUnitofMeasureTranslation(CreateUnitofMeasure.Box(), CreateLanguage.FRC(), BoxDescriptionLbl);
        ContosoCATranslation.InsertUnitofMeasureTranslation(CreateUnitofMeasure.Can(), CreateLanguage.FRC(), CanDescriptionLbl);
        ContosoCATranslation.InsertUnitofMeasureTranslation(CreateUnitofMeasure.Day(), CreateLanguage.FRC(), DayDescriptionLbl);
        ContosoCATranslation.InsertUnitofMeasureTranslation(CreateUnitofMeasure.Hour(), CreateLanguage.FRC(), HourDescriptionLbl);
        ContosoCATranslation.InsertUnitofMeasureTranslation(CreateUnitofMeasure.KM(), CreateLanguage.FRC(), KmDescriptionLbl);
        ContosoCATranslation.InsertUnitofMeasureTranslation(CreateUnitofMeasure.Miles(), CreateLanguage.FRC(), MilesDescriptionLbl);
        ContosoCATranslation.InsertUnitofMeasureTranslation(CreateUnitofMeasure.Pack(), CreateLanguage.FRC(), PackDescriptionLbl);
        ContosoCATranslation.InsertUnitofMeasureTranslation(CreateUnitofMeasure.Pallet(), CreateLanguage.FRC(), PalletDescriptionLbl);
        ContosoCATranslation.InsertUnitofMeasureTranslation(CreateUnitofMeasure.Piece(), CreateLanguage.FRC(), PieceDescriptionLbl);
    end;

    var
        BoxDescriptionLbl: Label '', MaxLength = 50;
        CanDescriptionLbl: Label 'Bidon', MaxLength = 50;
        DayDescriptionLbl: Label 'Jour', MaxLength = 50;
        HourDescriptionLbl: Label 'Heure', MaxLength = 50;
        KmDescriptionLbl: Label 'Kilom?átre', MaxLength = 50;
        MilesDescriptionLbl: Label 'Miles', MaxLength = 50;
        PackDescriptionLbl: Label 'Paquet', MaxLength = 50;
        PalletDescriptionLbl: Label 'Palette', MaxLength = 50;
        PieceDescriptionLbl: Label 'Pi?áce', MaxLength = 50;
}