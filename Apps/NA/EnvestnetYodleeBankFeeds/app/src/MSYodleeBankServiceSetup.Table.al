namespace Microsoft.Bank.StatementImport.Yodlee;

using Microsoft.Bank.Setup;
using Microsoft.Foundation.Company;
using System.Integration;
using System.Telemetry;
using System.Security.Encryption;
using System.Privacy;

table 1450 "MS - Yodlee Bank Service Setup"
{
    ReplicateData = false;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
        }
        field(5; "Service URL"; Text[250])
        {
            ExtendedDatatype = URL;

            trigger OnValidate();
            var
                WebRequestHelper: Codeunit "Web Request Helper";
                MSYodleeServiceMgt: Codeunit "MS - Yodlee Service Mgt.";
                YodleeServiceUrlValue: Text;
            begin
                if "Service URL" <> '' then
                    WebRequestHelper.IsSecureHttpUrl("Service URL");

                // If we have a service URL in our AKV
                // it must match otherwise we will not use our built in cobrand.
                // Notify the user so they know why things stopped working when it is changed.
                if GUIALLOWED() and MSYodleeServiceMgt.GetYodleeServiceURLFromAzureKeyVault(YodleeServiceUrlValue) then
                    if (xRec."Service URL" = YodleeServiceUrlValue) and
                       ("Service URL" <> YodleeServiceUrlValue)
                    then
                        MESSAGE(CobrandMustBeSpecifiedMsg);
            end;
        }
        field(7; "Bank Acc. Linking URL"; Text[250])
        {
            ExtendedDatatype = URL;

            trigger OnValidate();
            var
                WebRequestHelper: Codeunit "Web Request Helper";
            begin
                if "Bank Acc. Linking URL" <> '' then
                    WebRequestHelper.IsSecureHttpUrl("Bank Acc. Linking URL");
            end;
        }
        field(12; "Cobrand Environment Name"; Guid)
        {
        }
        field(8; "Cobrand Name"; Guid)
        {
        }
        field(9; "Cobrand Password"; Guid)
        {
        }
        field(10; "Consumer Name"; Text[250])
        {
        }
        field(11; "Consumer Password"; Guid)
        {
        }
        field(20; Enabled; Boolean)
        {

            trigger OnValidate();
            var
                CustomerConsentMgt: Codeunit "Customer Consent Mgt.";
                FeatureTelemetry: Codeunit "Feature Telemetry";
            begin
                if not xRec."Enabled" and Rec."Enabled" then
                    Rec."Enabled" := CustomerConsentMgt.ConfirmUserConsent();

                if Rec.Enabled then begin
                    TESTFIELD("Bank Feed Import Format");
                    if not MSYodleeServiceMgt.HasCustomCredentialsInAzureKeyVault() then begin
                        HasCobrandEnvironmentName("Cobrand Environment Name");
                        HasCobrandName("Cobrand Name");
                        HasCobrandPassword("Cobrand Password");
                        TESTFIELD("Service URL");
                        TESTFIELD("Bank Acc. Linking URL");
                    end;
                    TESTFIELD("User Profile Email Address");
                    FeatureTelemetry.LogUptake('0000GY2', 'Yodlee', Enum::"Feature Uptake Status"::"Set up");
                end;
            end;
        }
        field(21; "Log Web Requests"; Boolean)
        {
        }
        field(30; "Bank Feed Import Format"; Code[20])
        {
            TableRelation = "Bank Export/Import Setup".Code where(Direction = const(Import));
        }
        field(40; "Cobrand Session Token"; BLOB)
        {
            ObsoleteReason = 'This field is no longer used after refactoring.';
            ObsoleteState = Removed;
            ObsoleteTag = '18.0';
        }
        field(41; "Cob. Token Last Date Updated"; DateTime)
        {
            Editable = false;
            ObsoleteReason = 'This field is no longer used after refactoring.';
            ObsoleteState = Removed;
            ObsoleteTag = '18.0';
        }
        field(42; "Consumer Session Token"; BLOB)
        {
            ObsoleteReason = 'This field is no longer used after refactoring.';
            ObsoleteState = Removed;
            ObsoleteTag = '18.0';
        }
        field(43; "Cons. Token Last Date Updated"; DateTime)
        {
            Editable = false;
            ObsoleteReason = 'This field is no longer used after refactoring.';
            ObsoleteState = Removed;
            ObsoleteTag = '18.0';
        }
        field(50; "Accept Terms of Use"; Boolean)
        {
        }
        field(51; "User Profile Email Address"; Text[250])
        {
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    begin
        DeletePassword("Cobrand Name");
        DeletePassword("Cobrand Password");
        DeletePassword("Consumer Password");
        DeleteSessionTokens();
    end;

    trigger OnInsert();
    begin
        TESTFIELD("Primary Key", '');
    end;

    var
        MSYodleeServiceMgt: Codeunit "MS - Yodlee Service Mgt.";
        CobrandMustBeSpecifiedMsg: Label 'By modifying the Service URL you must specify your own Cobrand credentials.';
        EncryptionIsNotActivatedQst: Label 'Data encryption is not activated. It is recommended that you encrypt data. \Do you want to open the Data Encryption Management window?';

    procedure GetCobrandEnvironmentName(NameKey: Guid): Text;
    var
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
        CryptographyManagement: Codeunit "Cryptography Management";
        YodleeServiceUrlValue: Text;
        YodleeNameValue: Text;
        CobrandValue: Text;
    begin
        // do not return Cobrand name if Encryption is disabled
        if not CryptographyManagement.IsEncryptionEnabled() then
            exit('');

        if not ISNULLGUID(NameKey) then
            if IsolatedStorage.Get(NameKey, DataScope::Company, CobrandValue) then
                exit(CobrandValue);

        // If we are CRONUS don't use our cobrand
        if CompanyInformationMgt.IsDemoCompany() then
            exit('');

        // Only hand out the username if our service url is not modified or Service URL is empty
        if "Service URL" <> '' then begin
            if not MSYodleeServiceMgt.GetYodleeServiceURLFromAzureKeyVault(YodleeServiceUrlValue) then
                exit('');
            if "Service URL" <> YodleeServiceUrlValue then
                exit('');
        end;

        if MSYodleeServiceMgt.GetYodleeCobrandEnvironmentNameFromAzureKeyVault(YodleeNameValue) then
            exit(YodleeNameValue);

        exit('');
    end;

    procedure GetCobrandName(NameKey: Guid): Text;
    var
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
        CryptographyManagement: Codeunit "Cryptography Management";
        YodleeServiceUrlValue: Text;
        YodleeNameValue: Text;
        CobrandValue: Text;
    begin
        // do not return Cobrand name if Encryption is disabled
        if not CryptographyManagement.IsEncryptionEnabled() then
            exit('');

        if not ISNULLGUID(NameKey) then
            if IsolatedStorage.Get(NameKey, DataScope::Company, CobrandValue) then
                exit(CobrandValue);

        // If we are CRONUS don't use our cobrand
        if CompanyInformationMgt.IsDemoCompany() then
            exit('');

        // Only hand out the username if our service url is not modified or Service URL is empty
        if "Service URL" <> '' then begin
            if not MSYodleeServiceMgt.GetYodleeServiceURLFromAzureKeyVault(YodleeServiceUrlValue) then
                exit('');
            if "Service URL" <> YodleeServiceUrlValue then
                exit('');
        end;

        if MSYodleeServiceMgt.GetYodleeCobrandNameFromAzureKeyVault(YodleeNameValue) then
            if not HasPassword("Cobrand Password") then
                exit(YodleeNameValue);

        exit('');
    end;

    [NonDebuggable]
    procedure GetCobrandPassword(PasswordKey: Guid): Text;
    var
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
        CryptographyManagement: Codeunit "Cryptography Management";
        YodleeServiceURL: Text;
        YodleePasswordValue: Text;
        CobrandPassword: Text;
    begin
        // do not return Cobrand password if Encryption is disabled
        if not CryptographyManagement.IsEncryptionEnabled() then
            exit('');

        if not ISNULLGUID(PasswordKey) then
            if IsolatedStorage.Get(PasswordKey, DataScope::Company, CobrandPassword) then
                if CobrandPassword <> '' then
                    exit(CobrandPassword);

        // If we are CRONUS don't use our cobrand
        if CompanyInformationMgt.IsDemoCompany() then
            exit('');

        // Only hand out the password if our service url is present and not modified
        if not MSYodleeServiceMgt.GetYodleeServiceURLFromAzureKeyVault(YodleeServiceURL) then
            exit('');

        if "Service URL" <> YodleeServiceURL then
            exit('');

        if MSYodleeServiceMgt.GetYodleeCobrandPassFromAzureKeyVault(YodleePasswordValue) then
            if not HasPassword("Cobrand Name") then
                exit(YodleePasswordValue);

        exit('');
    end;

    [NonDebuggable]
    procedure GetPassword(PasswordKey: Guid): Text;
    var
        PasswordValue: Text;
    begin
        if not IsolatedStorage.Get(PasswordKey, DataScope::Company, PasswordValue) then
            exit('');

        exit(PasswordValue);
    end;

    [Scope('OnPrem')]
    procedure DeletePassword(PasswordKey: Guid);
    begin
        if IsolatedStorage.Contains(PasswordKey, DataScope::Company) then
            IsolatedStorage.Delete(PasswordKey, DataScope::Company);
    end;

    [NonDebuggable]
    procedure HasPassword(PasswordKey: Guid): Boolean;
    var
        PasswordValue: Text;
    begin
        if ISNULLGUID(PasswordKey) or (not IsolatedStorage.Get(PasswordKey, DataScope::Company, PasswordValue)) then
            exit(false);

        exit(PasswordValue <> '');
    end;

    procedure HasCobrandEnvironmentName(NameKey: Guid): Boolean;
    begin
        exit(GetCobrandEnvironmentName(NameKey) <> '');
    end;

    procedure HasCobrandName(NameKey: Guid): Boolean;
    begin
        exit(GetCobrandName(NameKey) <> '');
    end;

    [NonDebuggable]
    procedure HasCobrandPassword(PasswordKey: Guid): Boolean;
    begin
        exit(GetCobrandPassword(PasswordKey) <> '');
    end;

    procedure HasDefaultCredentials(): Boolean;
    var
        HasNoCustomCredentials: Boolean;
        HasCredentials: Boolean;
        HasCobrandEnvName: Boolean;
    begin
        if MSYodleeServiceMgt.HasCustomCredentialsInAzureKeyVault() then
            exit(true);

        HasNoCustomCredentials := ISNULLGUID("Cobrand Environment Name") and ISNULLGUID("Cobrand Name") and ISNULLGUID("Cobrand Password");
        HasCredentials := HasCobrandName("Cobrand Name") and HasCobrandPassword("Cobrand Password");
        HasCobrandEnvName := HasCobrandEnvironmentName("Cobrand Environment Name");

        if GetServiceURL().Contains('ysl') then
            exit(HasNoCustomCredentials and HasCredentials and HasCobrandEnvName);

        exit(HasNoCustomCredentials and HasCredentials);
    end;

    procedure SetValuesToDefault();
    begin
        MSYodleeServiceMgt.SetValuesToDefault(Rec);
    end;

    local procedure CheckEncryption();
    begin
        if not ENCRYPTIONENABLED() then
            if CONFIRM(EncryptionIsNotActivatedQst) then
                PAGE.RUN(PAGE::"Data Encryption Management");
    end;

    procedure CheckSetup();
    begin
        MSYodleeServiceMgt.CheckSetup();
    end;

    [Scope('OnPrem')]
    procedure DeleteSessionTokens();
    var
        MSYodleeBankSession: Record "MS - Yodlee Bank Session";
    begin
        if MSYodleeBankSession.GET() then begin
            MSYodleeBankSession.LOCKTABLE();
            MSYodleeBankSession.DELETE();
        end;
    end;

    procedure ResetDefaultBankStatementImportFormat();
    var
        MSYodleeDataExchangeDef: Record "MS - Yodlee Data Exchange Def";
    begin
        MSYodleeDataExchangeDef.ResetDataExchToDefault();
        VALIDATE("Bank Feed Import Format", 'YODLEE11BANKFEED');
    end;

    procedure SetDefaultBankStatementImportCode();
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        BankExportImportSetup.SetRange(Code, 'YODLEE11BANKFEED');
        if BankExportImportSetup.IsEmpty() then
            exit;

        VALIDATE("Bank Feed Import Format", 'YODLEE11BANKFEED');
    end;

    [Scope('OnPrem')]
    procedure SaveCobrandEnvironmentName(var CobrandEnvironmentNameKey: Guid; CobrandEnvironmentNameValue: Text);
    begin
        CobrandEnvironmentNameValue := DELCHR(CobrandEnvironmentNameValue, '=', ' ');

        if ISNULLGUID(CobrandEnvironmentNameKey) or not IsolatedStorage.Contains(CobrandEnvironmentNameKey, DataScope::Company) then
            CobrandEnvironmentNameKey := FORMAT(CreateGuid());

        SetSecretIntoIsolatedStorage(CobrandEnvironmentNameKey, CobrandEnvironmentNameValue);

        if CobrandEnvironmentNameValue <> '' then
            CheckEncryption();
    end;

    [Scope('OnPrem')]
    procedure SaveCobrandName(var CobrandNameKey: Guid; CobrandNameValue: Text);
    begin
        CobrandNameValue := DELCHR(CobrandNameValue, '=', ' ');

        if ISNULLGUID(CobrandNameKey) or not IsolatedStorage.Contains(CobrandNameKey, DataScope::Company) then
            CobrandNameKey := FORMAT(CreateGuid());

        SetSecretIntoIsolatedStorage(CobrandNameKey, CobrandNameValue);

        if CobrandNameValue <> '' then
            CheckEncryption();
    end;

    [Scope('OnPrem')]
    procedure SaveCobrandPassword(var CobrandPasswordKey: Guid; CobrandPasswordValue: Text);
    begin
        CobrandPasswordValue := DELCHR(CobrandPasswordValue, '=', ' ');

        if ISNULLGUID(CobrandPasswordKey) or not IsolatedStorage.Contains(CobrandPasswordKey, DataScope::Company) then
            CobrandPasswordKey := FORMAT(CreateGuid());
        SetSecretIntoIsolatedStorage(CobrandPasswordKey, CobrandPasswordValue);

        if CobrandPasswordValue <> '' then
            CheckEncryption();
    end;

    [Scope('OnPrem')]
    procedure SaveConsumerPassword(var ConsumerPasswordKey: Guid; ConsumerPasswordValue: Text);
    begin
        ConsumerPasswordValue := DELCHR(ConsumerPasswordValue, '=', ' ');

        if ISNULLGUID(ConsumerPasswordKey) or not IsolatedStorage.Contains(ConsumerPasswordKey, DataScope::Company) then
            ConsumerPasswordKey := FORMAT(CreateGuid());

        SetSecretIntoIsolatedStorage(ConsumerPasswordKey, ConsumerPasswordValue);

        if ConsumerPasswordValue <> '' then
            CheckEncryption();
    end;

    local procedure SetSecretIntoIsolatedStorage(SecretKey: Text; SecretValue: Text): Boolean
    begin
        if not EncryptionEnabled() then
            exit(IsolatedStorage.Set(COPYSTR(SecretKey, 1, 200), SecretValue, Datascope::Company));

        exit(IsolatedStorage.SetEncrypted(SecretKey, SecretValue, Datascope::Company));
    end;

    [Scope('OnPrem')]
    procedure DeleteFromIsolatedStorage(SecretKey: Text): Boolean
    begin
        if not IsolatedStorage.Contains(COPYSTR(SecretKey, 1, 200), Datascope::Company) then
            exit(false);

        exit(IsolatedStorage.Delete(COPYSTR(SecretKey, 1, 200), Datascope::Company));
    end;

    procedure GetServiceURL(): Text;
    var
        SecretValue: Text;
    begin
        if MSYodleeServiceMgt.GetYodleeServiceURLFromAzureKeyVault(SecretValue) then
            exit(DELCHR(SecretValue, '>', ' '));

        exit(DELCHR("Service URL", '>', ' '));
    end;
}

