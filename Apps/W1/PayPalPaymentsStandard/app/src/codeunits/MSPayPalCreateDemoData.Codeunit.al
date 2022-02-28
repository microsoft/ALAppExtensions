codeunit 1072 "MS - PayPal Create Demo Data"
{
    Subtype = install;

    trigger OnInstallAppPerCompany()
    begin
        CompanyInitialize();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    begin
        InsertDemoData();
        ApplyEvaluationClassificationsForPrivacy();
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        MSPaypalTransaction: Record "MS - PayPal Transaction";
        Company: Record Company;
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;
        DataClassificationMgt.SetTableFieldsToNormal(Database::"MS - PayPal Standard Account");
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - PayPal Standard Account", MSPayPalStandardAccount.FieldNo("Account ID"));

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MS - PayPal Standard Template");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MS - PayPal Transaction");
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - PayPal Transaction", MSPaypalTransaction.FieldNo("Payer Address"));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - PayPal Transaction", MSPaypalTransaction.FieldNo("Payer E-mail"));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS - PayPal Transaction", MSPaypalTransaction.FieldNo("Payer Name"));
    end;

    procedure InsertDemoData();
    var
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
    begin
        if not CompanyInformationMgt.IsDemoCompany() then
            exit;
        InsertSandboxPayPalTemplate();
        InsertDemoPayPalAccount();
    end;

    var
        DemoAccountPrefixTxt: Label 'Demo Sandbox Account - ';
#pragma warning disable AA0240
        DemoAccountIDTxt: Label 'donotreply@dynamics.com', Locked = true;
#pragma warning restore

    local procedure InsertSandboxPayPalTemplate();
    var
        MSPayPalStandardTemplate: Record "MS - PayPal Standard Template";
        MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
    begin
        IF MSPayPalStandardTemplate.GET() THEN
            EXIT;

        MSPayPalStandardTemplate.INIT();
        MSPayPalStandardTemplate.INSERT();

        MSPayPalStandardMgt.TemplateAssignDefaultValues(MSPayPalStandardTemplate);
        MSPayPalStandardTemplate.SetTargetURLNoVerification(MSPayPalStandardMgt.GetSandboxURL());
    end;

    local procedure InsertDemoPayPalAccount();
    var
        MSPayPalStandardTemplate: Record "MS - PayPal Standard Template";
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
    begin
        if not MSPayPalStandardAccount.IsEmpty() then
            exit;

        MSPayPalStandardMgt.GetTemplate(MSPayPalStandardTemplate);
        MSPayPalStandardAccount.TransferFields(MSPayPalStandardTemplate, false);
        MSPayPalStandardAccount.Name := CopyStr(DemoAccountPrefixTxt + MSPayPalStandardAccount.Name, 1, 250);
        MSPayPalStandardAccount.Description := CopyStr(DemoAccountPrefixTxt + MSPayPalStandardAccount.Description, 1, 250);
        MSPayPalStandardAccount."Account ID" := DemoAccountIDTxt;
        if not MSPayPalStandardAccount.Insert(true) then
            exit;

        MSPayPalStandardAccount."Always Include on Documents" := true;
        if MSPayPalStandardAccount.Modify(true) then;
    end;
}

