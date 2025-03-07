codeunit 19037 "Create IN UOM Translation"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoUnitOfMeasure: codeunit "Contoso Unit of Measure";
        CreateLanguage: Codeunit "Create Language";
        CreateUnitofMeasure: Codeunit "Create Unit of Measure";
    begin
        ContosoUnitOfMeasure.InsertUnitOfMeasureTranslation(CreateUnitofMeasure.Box(), 'BOX', CreateLanguage.ENU());
        ContosoUnitOfMeasure.InsertUnitOfMeasureTranslation(CreateUnitofMeasure.CAN(), 'CAN', CreateLanguage.ENU());
        ContosoUnitOfMeasure.InsertUnitOfMeasureTranslation(CreateUnitofMeasure.DAY(), 'DAY', CreateLanguage.ENU());
        ContosoUnitOfMeasure.InsertUnitOfMeasureTranslation(CreateUnitofMeasure.HOUR(), 'HOUR', CreateLanguage.ENU());
        ContosoUnitOfMeasure.InsertUnitOfMeasureTranslation(CreateUnitofMeasure.KG(), 'Kilo', CreateLanguage.ENU());
        ContosoUnitOfMeasure.InsertUnitOfMeasureTranslation(CreateUnitofMeasure.KM(), 'Kilometer', CreateLanguage.ENU());
        ContosoUnitOfMeasure.InsertUnitOfMeasureTranslation(CreateUnitofMeasure.MILES(), 'MILES', CreateLanguage.ENU());
        ContosoUnitOfMeasure.InsertUnitOfMeasureTranslation(CreateUnitofMeasure.PACK(), 'PACK', CreateLanguage.ENU());
        ContosoUnitOfMeasure.InsertUnitOfMeasureTranslation(CreateUnitofMeasure.PALLET(), 'PALLET', CreateLanguage.ENU());
        ContosoUnitOfMeasure.InsertUnitOfMeasureTranslation(CreateUnitofMeasure.Piece(), 'Piece', CreateLanguage.ENU());
        ContosoUnitOfMeasure.InsertUnitOfMeasureTranslation(CreateUnitofMeasure.SET(), 'Set', CreateLanguage.ENU());
    end;
}