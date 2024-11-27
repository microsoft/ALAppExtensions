codeunit 13715 "Create Analysis View DK"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Analysis View", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertAnalysisView(var Rec: Record "Analysis View")
    var
        CreateAnalysisView: Codeunit "Create Analysis View";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case Rec.Code of
            CreateAnalysisView.SalesRevenue():
                ValidateRecordFields(Rec, CreateGLAccount.Revenue() + '..' + CreateGLAccount.TotalRevenue());
        end;
    end;

    local procedure ValidateRecordFields(var AnalysisView: Record "Analysis View"; AccountFilter: Code[250])
    begin
        AnalysisView.Validate("Account Filter", AccountFilter);
    end;
}