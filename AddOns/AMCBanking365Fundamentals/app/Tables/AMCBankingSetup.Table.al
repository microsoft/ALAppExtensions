table 20101 "AMC Banking Setup"
{
    Caption = 'AMC Banking Setup';

    fields
    {
        field(20100; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(20101; "User Name"; Text[50])
        {
            Caption = 'User Name';
            DataClassification = EndUserIdentifiableInformation;
            Editable = true;
        }
        field(20102; "Password Key"; Guid)
        {
            Caption = 'Password Key';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(20103; "Sign-up URL"; Text[250])
        {
            Caption = 'Sign-up URL';
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
        }
        field(20104; "Service URL"; Text[250])
        {
            Caption = 'Service URL';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                WebRequestHelper: Codeunit "Web Request Helper";
            begin
                if "Service URL" <> '' then
                    WebRequestHelper.IsSecureHttpUrl("Service URL");
            end;
        }
        field(20105; "Support URL"; Text[250])
        {
            Caption = 'Support URL';
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
        }
        field(20106; "Namespace API Version"; Text[10])
        {
            Caption = 'Namespace API Version';
            DataClassification = CustomerContent;
        }
        field(20107; "Solution"; Text[50])
        {
            Caption = 'Solution';
            DataClassification = CustomerContent;
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

    trigger OnDelete()
    begin
        DeletePassword();
    end;

    trigger OnInsert()
    var
        AMCBankServMgt: Codeunit "AMC Banking Mgt.";
    begin
        if "User Name" = '' then begin
            "User Name" := GetUserName(); // Set username to demo user, if new record for user to try the funtionality
            if "User Name" <> '' then
                SavePassword(GetPassword()); // Set Password to demo password, if new record for user to try the funtionality
            if "User Name" = GetDemoUserName() then
                Solution := AMCBankServMgt.GetDemoSolutionCode();
        end;
        AMCBankServMgt.InitDefaultURLs(Rec);
    end;

    var
        DemoUserNameTxt: Label 'demouser', Locked = true;
        DemoPasswordTxt: Label 'DemoPassword', Locked = true;

    internal procedure SavePassword(PasswordText: Text)
    begin
        if IsNullGuid("Password Key") then
            "Password Key" := CreateGuid();

        if (PasswordText <> '') then begin
            if not EncryptionEnabled() then
                IsolatedStorage.Set(CopyStr("Password Key", 1, 200), PasswordText, Datascope::Company)
            else
                IsolatedStorage.SetEncrypted(CopyStr("Password Key", 1, 200), PasswordText, Datascope::Company);
        end
        else
            if HasPassword() then
                DeletePassword();
    end;

    internal procedure GetUserName(): Text[50]
    var
        ServiceUserName: Text[50];
    begin
        if ("User Name" = '') then
            exit(GetDemoUserName());

        ServiceUserName := "User Name";
        OnGetUserName(ServiceUserName);

        exit(ServiceUserName);
    end;

    internal procedure GetPassword(): Text
    var
        Value: Text;
    begin
        if ("User Name" = GetDemoUserName()) then
            exit(GetDemoPass());

        IsolatedStorage.Get(CopyStr("Password Key", 1, 200), Datascope::Company, Value);
        exit(Value);
    end;

    internal procedure DeletePassword()
    begin
        if IsolatedStorage.Contains(CopyStr("Password Key", 1, 200), Datascope::Company) then
            IsolatedStorage.Delete(CopyStr("Password Key", 1, 200), DataScope::Company);
    end;

    procedure HasUserName(): Boolean
    begin
        exit("User Name" <> '');
    end;

    internal procedure HasPassword(): Boolean
    begin
        if ("User Name" = GetDemoUserName()) then
            exit(true);

        exit(IsolatedStorage.Contains(CopyStr("Password Key", 1, 200), Datascope::Company));
    end;

    procedure SetURLsToDefault()
    var
        AMCBankServMgt: Codeunit "AMC Banking Mgt.";
    begin
        AMCBankServMgt.SetURLsToDefault(Rec);
    end;

    procedure GetDemoUserName(): Text[50]
    var
    begin
        exit(CopyStr(DemoUserNameTxt, 1, 50));
    end;

    local procedure GetDemoPass(): Text
    var
    begin
        exit(DemoPasswordTxt);
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetUserName(var UserName: Text[50])
    begin
    end;
}

