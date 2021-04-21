codeunit 2051 "Data Sharing Install"
{
    Subtype = install;

    trigger OnInstallAppPerCompany()
    begin
        CompanyInitialize();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    begin
        ApplyEvaluationClassificationsForPrivacy();
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
        MSDataSharingSetup: Record "MS - Data Sharing Setup";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetFieldToNormal(Database::"MS - Data Sharing Setup", MSDataSharingSetup.FieldNo(Enabled));
        DataClassificationMgt.SetFieldToPersonal(DataBase::"MS - Data Sharing Setup", MSDataSharingSetup.FieldNo("Company Id"));
    end;
}