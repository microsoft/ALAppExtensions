codeunit 4515 "SMTP Connector Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        ApplyEvaluationClassificationsForPrivacy();
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
        Account: Record "SMTP Account";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetFieldToPersonal(Database::"SMTP Account", Account.FieldNo(Name));
        DataClassificationMgt.SetFieldToPersonal(Database::"SMTP Account", Account.FieldNo("Email Address"));
        DataClassificationMgt.SetFieldToPersonal(Database::"SMTP Account", Account.FieldNo("User Name"));
        DataClassificationMgt.SetFieldToNormal(Database::"SMTP Account", Account.FieldNo("Secure Connection"));
        DataClassificationMgt.SetFieldToNormal(Database::"SMTP Account", Account.FieldNo(Server));
        DataClassificationMgt.SetFieldToNormal(Database::"SMTP Account", Account.FieldNo("Server Port"));
        DataClassificationMgt.SetFieldToNormal(Database::"SMTP Account", Account.FieldNo(Authentication));
    end;
}