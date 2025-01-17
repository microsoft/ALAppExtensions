codeunit 13724 "Create Job DK"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Job, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertJob(var Rec: Record Job)
    var
        CreateLanguage: Codeunit "Create Language";
    begin
        ValidateRecordFieldsJob(Rec, CreateLanguage.DAN());
    end;

    local procedure ValidateRecordFieldsJob(var Job: Record Job; LanguageCode: Code[10])
    begin
        Job.Validate("Language Code", LanguageCode);
    end;
}