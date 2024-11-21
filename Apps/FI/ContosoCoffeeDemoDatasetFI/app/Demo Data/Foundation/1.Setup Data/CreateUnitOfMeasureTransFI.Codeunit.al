codeunit 13451 "Create UnitOfMeasureTrans. FI"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Unit of Measure Translation", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertUnitofMeasureTranslation(var Rec: Record "Unit of Measure Translation")
    var
        CreateLanguage: Codeunit "Create Language";
        CreateUnitofMeasure: Codeunit "Create Unit of Measure";
    begin
        if (Rec.Code = CreateUnitofMeasure.Piece()) and (Rec."Language Code" = CreateLanguage.DEU()) then
            Rec.Validate(Description, 'stück');
    end;
}