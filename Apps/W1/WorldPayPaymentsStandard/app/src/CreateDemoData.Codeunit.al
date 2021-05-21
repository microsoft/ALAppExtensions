codeunit 1362 "MS - WorldPay Create Demo Data"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        CompanyInitialize();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    begin
        InsertDemoDataAndUpgradeBurntIn();
        ApplyEvaluationClassificationsForPrivacy();
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account";
        MSWorldPayStdTemplate: Record "MS - WorldPay Std. Template";
        MSWorldPayTransaction: Record "MS - WorldPay Transaction";
        Company: Record Company;
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(DataBase::"MS - WorldPay Standard Account");
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - WorldPay Standard Account", MSWorldPayStandardAccount.FieldNo(Name));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - WorldPay Standard Account", MSWorldPayStandardAccount.FieldNo(Description));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - WorldPay Standard Account", MSWorldPayStandardAccount.FieldNo("Account ID"));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - WorldPay Standard Account", MSWorldPayStandardAccount.FieldNo("Target URL"));

        DataClassificationMgt.SetTableFieldsToNormal(DataBase::"MS - WorldPay Std. Template");
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - WorldPay Std. Template", MSWorldPayStdTemplate.FieldNo(Name));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - WorldPay Std. Template", MSWorldPayStdTemplate.FieldNo(Description));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - WorldPay Std. Template", MSWorldPayStdTemplate.FieldNo(Logo));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - WorldPay Std. Template", MSWorldPayStdTemplate.FieldNo("Target URL"));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - WorldPay Std. Template", MSWorldPayStdTemplate.FieldNo("Logo URL"));

        DataClassificationMgt.SetTableFieldsToNormal(DataBase::"MS - WorldPay Transaction");
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - WorldPay Transaction", MSWorldPayTransaction.FieldNo("Payer E-mail"));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - WorldPay Transaction", MSWorldPayTransaction.FieldNo("Payer Name"));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - WorldPay Transaction", MSWorldPayTransaction.FieldNo("Payer Address"));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - WorldPay Transaction", MSWorldPayTransaction.FieldNo(Note));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - WorldPay Transaction", MSWorldPayTransaction.FieldNo(Custom));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - WorldPay Transaction", MSWorldPayTransaction.FieldNo(Details));
    end;

    procedure InsertDemoDataAndUpgradeBurntIn();
    var
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
    begin
        if CompanyInformationMgt.IsDemoCompany() then begin
            InsertSandboxWorldPayTemplate();
            InsertDemoWorldPayAccount();
        end;
    end;

    var
        DemoAccountPrefixTxt: Label 'Demo Sandbox Account - ';
        DemoAccountIDTxt: Label '1182302', Locked = true;

    local procedure InsertSandboxWorldPayTemplate()
    var
        MSWorldPayStdTemplate: Record "MS - WorldPay Std. Template";
        MSWorldPayStandardMgt: Codeunit "MS - WorldPay Standard Mgt.";
    begin
        IF MSWorldPayStdTemplate.GET() THEN
            EXIT;

        MSWorldPayStdTemplate.INIT();
        MSWorldPayStdTemplate.INSERT();

        MSWorldPayStandardMgt.TemplateAssignDefaultValues(MSWorldPayStdTemplate);
        MSWorldPayStdTemplate.SetTargetURL(MSWorldPayStandardMgt.GetSandboxURL());
    end;

    local procedure InsertDemoWorldPayAccount()
    var
        MSWorldPayStdTemplate: Record "MS - WorldPay Std. Template";
        MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account";
        MSWorldPayStandardMgt: Codeunit "MS - WorldPay Standard Mgt.";
    begin
        MSWorldPayStandardAccount.SETRANGE("Always Include on Documents", TRUE);
        IF MSWorldPayStandardAccount.FINDFIRST() THEN
            EXIT;

        MSWorldPayStandardMgt.GetTemplate(MSWorldPayStdTemplate);
        MSWorldPayStandardAccount.TRANSFERFIELDS(MSWorldPayStdTemplate, FALSE);
        MSWorldPayStandardAccount.Name := CopyStr(DemoAccountPrefixTxt + MSWorldPayStandardAccount.Name, 1, MaxStrLen(MSWorldPayStandardAccount.Name));
        MSWorldPayStandardAccount.Description := CopyStr(DemoAccountPrefixTxt + MSWorldPayStandardAccount.Description, 1, MaxStrLen(MSWorldPayStandardAccount.Description));
        MSWorldPayStandardAccount."Account ID" := DemoAccountIDTxt;
        MSWorldPayStandardAccount.INSERT(TRUE);

        MSWorldPayStandardAccount.Enabled := TRUE;
        MSWorldPayStandardAccount."Always Include on Documents" := TRUE;
        MSWorldPayStandardAccount.MODIFY(TRUE);
    end;
}

