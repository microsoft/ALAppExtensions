codeunit 11417 "Create UOM Translation BE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateUnitOfMeasureTranslation();
    end;

    local procedure CreateUnitOfMeasureTranslation()
    var
        ContosoUnitOfMeasure: codeunit "Contoso Unit of Measure";
        CreateUnitofMeasure: Codeunit "Create Unit of Measure";
        CreateLanguage: Codeunit "Create Language";
    begin
        UpdateUnitOfMeasureTranslation();

        ContosoUnitOfMeasure.InsertUnitOfMeasureTranslation(CreateUnitofMeasure.Piece(), 'pi?áce', CreateLanguage.FRB());
        ContosoUnitOfMeasure.InsertUnitOfMeasureTranslation(CreateUnitofMeasure.Piece(), 'stuk', CreateLanguage.NLB());
    end;

    local procedure UpdateUnitOfMeasureTranslation()
    var
        UnitOfMeasureTranslation: Record "Unit of Measure Translation";
        CreateUnitofMeasure: Codeunit "Create Unit of Measure";
        CreateLanguage: Codeunit "Create Language";
    begin
        UnitOfMeasureTranslation.Get(CreateUnitofMeasure.Piece(), CreateLanguage.DEU());
        UnitOfMeasureTranslation.Validate(Description, 'st?ück');
        UnitOfMeasureTranslation.Modify(true);
    end;
}
