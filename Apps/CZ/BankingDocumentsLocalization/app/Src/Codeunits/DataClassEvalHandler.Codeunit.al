codeunit 31331 "Data Class. Eval. Handler CZB"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure ApplyEvaluationClassificationsForPrivacyOnAfterClassifyCountrySpecificTables()
    begin
        ApplyEvaluationClassificationsForPrivacy();
    end;

    procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
    // DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

    end;
}
