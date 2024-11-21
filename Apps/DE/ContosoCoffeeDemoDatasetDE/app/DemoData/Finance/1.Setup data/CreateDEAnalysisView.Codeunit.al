codeunit 11384 "Create DE Analysis View"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Analysis View", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertAnalysisView(var Rec: Record "Analysis View")
    var
        CreateAnalysisView: Codeunit "Create Analysis View";
    begin
        case Rec.Code of
            CreateAnalysisView.SalesRevenue():
                Rec.Validate("Account Filter", '8000..8999');
        end;
    end;
}