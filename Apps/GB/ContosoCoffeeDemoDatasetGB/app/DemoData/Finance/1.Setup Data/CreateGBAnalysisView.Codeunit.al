codeunit 10515 "Create GB Analysis View"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Analysis View", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Analysis View"; RunTrigger: Boolean)
    var
        CreateAnalysisView: Codeunit "Create Analysis View";
    begin
        case Rec.Code of
            CreateAnalysisView.SalesRevenue():
                ValidateRecordFields(Rec, '10000..10990');
        end;
    end;

    local procedure ValidateRecordFields(var AnalysisView: Record "Analysis View"; AccountFilter: Code[250])
    begin
        AnalysisView.Validate("Account Filter", AccountFilter);
    end;
}