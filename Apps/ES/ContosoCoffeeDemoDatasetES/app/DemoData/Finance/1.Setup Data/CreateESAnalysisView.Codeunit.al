codeunit 10798 "Create ES Analysis View"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Analysis View", 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnInsertRecords(var Rec: Record "Analysis View")
    var
        CreateAnalysisView: Codeunit "Create Analysis View";
        CreateESGLAccount: Codeunit "Create ES GL Accounts";
    begin
        case Rec.Code of
            CreateAnalysisView.SalesRevenue():
                ValidateRecordFields(Rec, '', CreateESGLAccount.NationalGoodsSales() + '..' + CreateESGLAccount.GoodsSalesReturnAllow());
        end;
    end;

    local procedure ValidateRecordFields(var AnalysisView: Record "Analysis View"; Dimension3Code: Code[20]; AccountFilter: Text[250])
    begin
        AnalysisView.Validate("Date Compression", AnalysisView."Date Compression"::Month);
        AnalysisView.Validate("Account Filter", AccountFilter);
        AnalysisView."Dimension 3 Code" := Dimension3Code;
    end;
}