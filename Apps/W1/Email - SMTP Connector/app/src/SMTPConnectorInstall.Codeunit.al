codeunit 4515 "SMTP Connector Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        ApplyEvaluationClassificationsForPrivacy();

        MigrateSMTPAccount();
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
        DataClassificationMgt.SetFieldToPersonal(Database::"SMTP Account", Account.FieldNo("Created By"));
        DataClassificationMgt.SetFieldToPersonal(Database::"SMTP Account", Account.FieldNo("User Name"));
        DataClassificationMgt.SetFieldToNormal(Database::"SMTP Account", Account.FieldNo("Secure Connection"));
        DataClassificationMgt.SetFieldToNormal(Database::"SMTP Account", Account.FieldNo(Server));
        DataClassificationMgt.SetFieldToNormal(Database::"SMTP Account", Account.FieldNo("Server Port"));
        DataClassificationMgt.SetFieldToNormal(Database::"SMTP Account", Account.FieldNo(Authentication));
    end;

    [Obsolete('Temporary solution. SMTP Mail Setup is being deprecated itself.', '17.0')]
    local procedure MigrateSMTPAccount()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetEmailSMTPUpgradeTag()) then
            exit;

        CreateDefaultSMTPAccount();

        UpgradeTag.SetUpgradeTag(GetEmailSMTPUpgradeTag());
    end;

    [Obsolete('Temporary solution. SMTP Mail Setup is being deprecated itself.', '17.0')]
    [NonDebuggable]
    local procedure CreateDefaultSMTPAccount()
    var
        OldSMTPAccount: Record "SMTP Mail Setup";
        NewSMTPAccount: Record "SMTP Account";
        EmailAccount: Record "Email Account";
        EmailScenario: Codeunit "Email Scenario";
    begin
        // Create an SMTP account if the legacy SMTP Mail Setup has an entry.

        if not (NewSMTPAccount.WritePermission() and OldSMTPAccount.ReadPermission()) then
            exit; // no permissions, do nothing;

        if not NewSMTPAccount.IsEmpty() then
            exit; // if there's an SMTP account already, don't create another

        if not OldSMTPAccount.FindFirst() then
            exit; // no account, nothing to do

        if OldSMTPAccount.Authentication = OldSMTPAccount.Authentication::NTLM then
            exit; // the new SMTP account doesn't support NTLM

        if OldSMTPAccount."User ID" = '' then
            exit; // Unsupported case

        // Set ID
        NewSMTPAccount.Id := CreateGuid();

        // Set Name
        NewSMTPAccount.Name := OldSMTPAccount."User ID";

        // Set Server
        NewSMTPAccount.Server := OldSMTPAccount."SMTP Server";

        // Set Server Port
        NewSMTPAccount."Server Port" := OldSMTPAccount."SMTP Server Port";

        // Set Email Address
        NewSMTPAccount."Email Address" := OldSMTPAccount."User ID";

        // Set User Name
        NewSMTPAccount."User Name" := OldSMTPAccount."User ID";

        // Set Password
        NewSMTPAccount.SetPassword(OldSMTPAccount.GetPassword());

        // Set Authentication
        if OldSMTPAccount.Authentication = OldSMTPAccount.Authentication::Anonymous then
            NewSMTPAccount.Authentication := NewSMTPAccount.Authentication::Anonymous;

        if OldSMTPAccount.Authentication = OldSMTPAccount.Authentication::Basic then
            NewSMTPAccount.Authentication := NewSMTPAccount.Authentication::Basic;

        // Set Secure Connection 
        NewSMTPAccount."Secure Connection" := OldSMTPAccount."Secure Connection";

        // Set Created By
        NewSMTPAccount."Created By" := CopyStr(UserId(), 1, MaxStrLen(NewSMTPAccount."Created By"));

        if NewSMTPAccount.Insert() then begin
            // Set the newly added account as default

            EmailAccount."Account Id" := NewSMTPAccount.Id;
            EmailAccount.Connector := enum::"Email Connector"::SMTP;

            EmailScenario.SetEmailAccount(Enum::"Email Scenario"::Default, EmailAccount);
        end;
    end;

    local procedure GetEmailSMTPUpgradeTag(): Code[250];
    begin
        exit('MS-368162-EmailSMTP-20200815');
    end;
}