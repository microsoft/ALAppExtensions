table 1450 "MS - Yodlee Bank Service Setup"
{
    ReplicateData = false;

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
                WebRequestHelper: Codeunit 1299;
                MSYodleeServiceMgt: Codeunit 1450;
                YodleeServiceUrlValue: Text;
            begin
                IF "Service URL" <> '' THEN
                    WebRequestHelper.IsSecureHttpUrl("Service URL");

                // If we have a service URL in our AKV
                // it must match otherwise we will not use our built in cobrand.
                // Notify the user so they know why things stopped working when it is changed.
                IF GUIALLOWED() AND MSYodleeServiceMgt.GetYodleeServiceURLFromAzureKeyVault(YodleeServiceUrlValue) THEN
                    IF (xRec."Service URL" = YodleeServiceUrlValue) AND
                       ("Service URL" <> YodleeServiceUrlValue)
                    THEN
                        MESSAGE(CobrandMustBeSpecifiedMsg);
            end;
        }
        field(7; "Bank Acc. Linking URL"; Text[250])
        {
            ExtendedDatatype = URL;

            trigger OnValidate();
            var
                WebRequestHelper: Codeunit 1299;
            begin
                IF "Bank Acc. Linking URL" <> '' THEN
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
            begin
                TESTFIELD("Bank Feed Import Format");
                IF NOT MSYodleeServiceMgt.HasCustomCredentialsInAzureKeyVault() THEN BEGIN
                    HasCobrandEnvironmentName("Cobrand Environment Name");
                    HasCobrandName("Cobrand Name");
                    HasCobrandPassword("Cobrand Password");
                    TESTFIELD("Service URL");
                    TESTFIELD("Bank Acc. Linking URL");
                END;
                TESTFIELD("User Profile Email Address");
            end;
        }
        field(21; "Log Web Requests"; Boolean)
        {
        }
        field(30; "Bank Feed Import Format"; Code[20])
        {
            TableRelation = "Bank Export/Import Setup".Code WHERE(Direction = CONST(Import));
        }
        field(40; "Cobrand Session Token"; BLOB)
        {
            ObsoleteReason = 'This field is no longer used after refactoring.';
            ObsoleteState = Removed;
        }
        field(41; "Cob. Token Last Date Updated"; DateTime)
        {
            Editable = false;
            ObsoleteReason = 'This field is no longer used after refactoring.';
            ObsoleteState = Removed;
        }
        field(42; "Consumer Session Token"; BLOB)
        {
            ObsoleteReason = 'This field is no longer used after refactoring.';
            ObsoleteState = Removed;
        }
        field(43; "Cons. Token Last Date Updated"; DateTime)
        {
            Editable = false;
            ObsoleteReason = 'This field is no longer used after refactoring.';
            ObsoleteState = Removed;
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
        MSYodleeServiceMgt: Codeunit 1450;
        CobrandMustBeSpecifiedMsg: Label 'By modifying the Service URL you must specify your own Cobrand credentials.';
        EncryptionIsNotActivatedQst: Label 'Data encryption is not activated. It is recommended that you encrypt data. \Do you want to open the Data Encryption Management window?';

    procedure GetCobrandEnvironmentName(NameKey: Guid): Text;
    var
        CompanyInformationMgt: Codeunit 1306;
        CryptographyManagement: Codeunit "Cryptography Management";
        YodleeServiceUrlValue: Text;
        YodleeNameValue: Text;
        CobrandValue: Text;
    begin
        // do not return Cobrand name if Encryption is disabled
        IF NOT CryptographyManagement.IsEncryptionEnabled() THEN
            EXIT('');

        IF NOT ISNULLGUID(NameKey) THEN
            IF IsolatedStorage.Get(NameKey, DataScope::Company, CobrandValue) THEN
                EXIT(CobrandValue);

        // If we are CRONUS don't use our cobrand
        IF CompanyInformationMgt.IsDemoCompany() THEN
            EXIT('');

        // Only hand out the username if our service url is not modified or Service URL is empty
        IF "Service URL" <> '' THEN BEGIN
            IF NOT MSYodleeServiceMgt.GetYodleeServiceURLFromAzureKeyVault(YodleeServiceUrlValue) THEN
                EXIT('');
            IF "Service URL" <> YodleeServiceUrlValue THEN
                EXIT('');
        END;

        IF MSYodleeServiceMgt.GetYodleeCobrandEnvironmentNameFromAzureKeyVault(YodleeNameValue) THEN
            EXIT(YodleeNameValue);

        EXIT('');
    end;

    procedure GetCobrandName(NameKey: Guid): Text;
    var
        CompanyInformationMgt: Codeunit 1306;
        CryptographyManagement: Codeunit "Cryptography Management";
        YodleeServiceUrlValue: Text;
        YodleeNameValue: Text;
        CobrandValue: Text;
    begin
        // do not return Cobrand name if Encryption is disabled
        IF NOT CryptographyManagement.IsEncryptionEnabled() THEN
            EXIT('');

        IF NOT ISNULLGUID(NameKey) THEN
            IF IsolatedStorage.Get(NameKey, DataScope::Company, CobrandValue) THEN
                EXIT(CobrandValue);

        // If we are CRONUS don't use our cobrand
        IF CompanyInformationMgt.IsDemoCompany() THEN
            EXIT('');

        // Only hand out the username if our service url is not modified or Service URL is empty
        IF "Service URL" <> '' THEN BEGIN
            IF NOT MSYodleeServiceMgt.GetYodleeServiceURLFromAzureKeyVault(YodleeServiceUrlValue) THEN
                EXIT('');
            IF "Service URL" <> YodleeServiceUrlValue THEN
                EXIT('');
        END;

        IF MSYodleeServiceMgt.GetYodleeCobrandNameFromAzureKeyVault(YodleeNameValue) THEN
            IF NOT HasPassword("Cobrand Password") THEN
                EXIT(YodleeNameValue);

        EXIT('');
    end;

    procedure GetCobrandPassword(PasswordKey: Guid): Text;
    var
        CompanyInformationMgt: Codeunit 1306;
        CryptographyManagement: Codeunit "Cryptography Management";
        YodleeServiceURL: Text;
        YodleePasswordValue: Text;
        CobrandPassword: Text;
    begin
        // do not return Cobrand password if Encryption is disabled
        IF NOT CryptographyManagement.IsEncryptionEnabled() THEN
            EXIT('');

        IF NOT ISNULLGUID(PasswordKey) THEN
            IF IsolatedStorage.Get(PasswordKey, DataScope::Company, CobrandPassword) THEN
                IF CobrandPassword <> '' THEN
                    EXIT(CobrandPassword);

        // If we are CRONUS don't use our cobrand
        IF CompanyInformationMgt.IsDemoCompany() THEN
            EXIT('');

        // Only hand out the password if our service url is present and not modified
        IF NOT MSYodleeServiceMgt.GetYodleeServiceURLFromAzureKeyVault(YodleeServiceURL) THEN
            EXIT('');

        IF "Service URL" <> YodleeServiceURL THEN
            EXIT('');

        IF MSYodleeServiceMgt.GetYodleeCobrandPassFromAzureKeyVault(YodleePasswordValue) THEN
            IF NOT HasPassword("Cobrand Name") THEN
                EXIT(YodleePasswordValue);

        EXIT('');
    end;

    procedure GetPassword(PasswordKey: Guid): Text;
    var
        PasswordValue: Text;
    begin
        IF NOT IsolatedStorage.Get(PasswordKey, DataScope::Company, PasswordValue) THEN
            EXIT('');

        EXIT(PasswordValue);
    end;

    local procedure DeletePassword(PasswordKey: Guid);
    var
    begin
        IF IsolatedStorage.Contains(PasswordKey, DataScope::Company) THEN
            IsolatedStorage.Delete(PasswordKey, DataScope::Company);
    end;

    procedure HasPassword(PasswordKey: Guid): Boolean;
    var
        PasswordValue: Text;
    begin
        IF ISNULLGUID(PasswordKey) OR (NOT IsolatedStorage.Get(PasswordKey, DataScope::Company, PasswordValue)) THEN
            EXIT(FALSE);

        EXIT(PasswordValue <> '');
    end;

    procedure HasCobrandEnvironmentName(NameKey: Guid): Boolean;
    begin
        EXIT(GetCobrandEnvironmentName(NameKey) <> '');
    end;

    procedure HasCobrandName(NameKey: Guid): Boolean;
    begin
        EXIT(GetCobrandName(NameKey) <> '');
    end;

    procedure HasCobrandPassword(PasswordKey: Guid): Boolean;
    begin
        EXIT(GetCobrandPassword(PasswordKey) <> '');
    end;

    procedure HasDefaultCredentials(): Boolean;
    var
        HasNoCustomCredentials: Boolean;
        HasCredentials: Boolean;
        HasCobrandEnvName: Boolean;
    begin
        IF MSYodleeServiceMgt.HasCustomCredentialsInAzureKeyVault() THEN
            EXIT(TRUE);

        HasNoCustomCredentials := ISNULLGUID("Cobrand Environment Name") AND ISNULLGUID("Cobrand Name") AND ISNULLGUID("Cobrand Password");
        HasCredentials := HasCobrandName("Cobrand Name") AND HasCobrandPassword("Cobrand Password");
        HasCobrandEnvName := HasCobrandEnvironmentName("Cobrand Environment Name");

        if GetServiceURL().Contains('ysl') then
            exit(HasNoCustomCredentials AND HasCredentials AND HasCobrandEnvName);

        exit(HasNoCustomCredentials AND HasCredentials);
    end;

    procedure SetValuesToDefault();
    begin
        MSYodleeServiceMgt.SetValuesToDefault(Rec);
    end;

    local procedure CheckEncryption();
    begin
        IF NOT ENCRYPTIONENABLED() THEN
            IF CONFIRM(EncryptionIsNotActivatedQst) THEN
                PAGE.RUN(PAGE::"Data Encryption Management");
    end;

    procedure CheckSetup();
    begin
        MSYodleeServiceMgt.CheckSetup();
    end;

    local procedure DeleteSessionTokens();
    var
        MSYodleeBankSession: Record 1453;
    begin
        IF MSYodleeBankSession.GET() THEN BEGIN
            MSYodleeBankSession.LOCKTABLE();
            MSYodleeBankSession.DELETE();
        END;
    end;

    procedure ResetDefaultBankStatementImportFormat();
    var
        MSYodleeDataExchangeDef: Record 1452;
    begin
        MSYodleeDataExchangeDef.ResetDataExchToDefault();
        VALIDATE("Bank Feed Import Format", 'YODLEE11BANKFEED');
    end;

    procedure SetDefaultBankStatementImportCode();
    var
        BankExportImportSetup: Record 1200;
    begin
        BankExportImportSetup.SetRange(Code, 'YODLEE11BANKFEED');
        IF BankExportImportSetup.IsEmpty() THEN
            EXIT;

        VALIDATE("Bank Feed Import Format", 'YODLEE11BANKFEED');
    end;

    [Scope('OnPrem')]
    procedure SaveCobrandEnvironmentName(var CobrandEnvironmentNameKey: Guid; CobrandEnvironmentNameValue: Text);
    begin
        CobrandEnvironmentNameValue := DELCHR(CobrandEnvironmentNameValue, '=', ' ');

        IF ISNULLGUID(CobrandEnvironmentNameKey) OR NOT IsolatedStorage.Contains(CobrandEnvironmentNameKey, DataScope::Company) THEN
            CobrandEnvironmentNameKey := FORMAT(CreateGuid());

        SetSecretIntoIsolatedStorage(CobrandEnvironmentNameKey, CobrandEnvironmentNameValue);

        IF CobrandEnvironmentNameValue <> '' THEN
            CheckEncryption();
    end;

    [Scope('OnPrem')]
    procedure SaveCobrandName(var CobrandNameKey: Guid; CobrandNameValue: Text);
    begin
        CobrandNameValue := DELCHR(CobrandNameValue, '=', ' ');

        IF ISNULLGUID(CobrandNameKey) OR NOT IsolatedStorage.Contains(CobrandNameKey, DataScope::Company) THEN
            CobrandNameKey := FORMAT(CreateGuid());

        SetSecretIntoIsolatedStorage(CobrandNameKey, CobrandNameValue);

        IF CobrandNameValue <> '' THEN
            CheckEncryption();
    end;

    [Scope('OnPrem')]
    procedure SaveCobrandPassword(var CobrandPasswordKey: Guid; CobrandPasswordValue: Text);
    begin
        CobrandPasswordValue := DELCHR(CobrandPasswordValue, '=', ' ');

        IF ISNULLGUID(CobrandPasswordKey) OR NOT IsolatedStorage.Contains(CobrandPasswordKey, DataScope::Company) THEN
            CobrandPasswordKey := FORMAT(CreateGuid());
        SetSecretIntoIsolatedStorage(CobrandPasswordKey, CobrandPasswordValue);

        IF CobrandPasswordValue <> '' THEN
            CheckEncryption();
    end;

    [Scope('OnPrem')]
    procedure SaveConsumerPassword(var ConsumerPasswordKey: Guid; ConsumerPasswordValue: Text);
    begin
        ConsumerPasswordValue := DELCHR(ConsumerPasswordValue, '=', ' ');

        IF ISNULLGUID(ConsumerPasswordKey) OR NOT IsolatedStorage.Contains(ConsumerPasswordKey, DataScope::Company) THEN
            ConsumerPasswordKey := FORMAT(CreateGuid());

        SetSecretIntoIsolatedStorage(ConsumerPasswordKey, ConsumerPasswordValue);

        IF ConsumerPasswordValue <> '' THEN
            CheckEncryption();
    end;

    local procedure SetSecretIntoIsolatedStorage(SecretKey: Text; SecretValue: Text): Boolean
    var
    begin
        IF NOT EncryptionEnabled() THEN
            EXIT(IsolatedStorage.Set(COPYSTR(SecretKey, 1, 200), SecretValue, Datascope::Company));

        EXIT(IsolatedStorage.SetEncrypted(SecretKey, SecretValue, Datascope::Company));
    end;

    [Scope('OnPrem')]
    procedure DeleteFromIsolatedStorage(SecretKey: Text): Boolean
    var
    begin
        IF NOT IsolatedStorage.Contains(COPYSTR(SecretKey, 1, 200), Datascope::Company) THEN
            EXIT(FALSE);

        EXIT(IsolatedStorage.Delete(COPYSTR(SecretKey, 1, 200), Datascope::Company));
    end;

    procedure GetServiceURL(): Text;
    var
        SecretValue: Text;
    begin
        IF MSYodleeServiceMgt.GetYodleeServiceURLFromAzureKeyVault(SecretValue) THEN
            EXIT(DELCHR(SecretValue, '>', ' '));

        EXIT(DELCHR("Service URL", '>', ' '));
    end;
}

