tableextension 4701 "VAT Report Setup Extension" extends "VAT Report Setup"
{

    fields
    {
        field(4700; "VAT Group Role"; Enum "VAT Group Role")
        {
            DataClassification = SystemMetadata;
            Caption = 'VAT Group Role';
        }
        field(4701; "Approved Members"; Integer)
        {
            Caption = 'Approved Members';
            FieldClass = FlowField;
            CalcFormula = count("VAT Group Approved Member");
        }
        field(4702; "Group Member ID"; Guid)
        {
            DataClassification = EndUserPseudonymousIdentifiers;
            Caption = 'Group Member ID';
            Editable = false;
        }
        field(4703; "Group Representative API URL"; Text[250])
        {
            DataClassification = OrganizationIdentifiableInformation;
            Caption = 'Group Representative API URL';
            ExtendedDatatype = URL;
        }
        field(4704; "Authentication Type"; Enum "VAT Group Authentication Type OnPrem")
        {
            DataClassification = CustomerContent;
            Caption = 'Authentication Type';
        }
        field(4705; "User Name Key"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'User Name Key';
            ExtendedDatatype = Masked;
        }
        field(4706; "Web Service Access Key Key"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Web Service Access Key Key';
            ExtendedDatatype = Masked;
        }
        field(4707; "Group Representative Company"; Text[30])
        {
            DataClassification = OrganizationIdentifiableInformation;
            Caption = 'Group Representative Company';
        }
        field(4708; "Client ID Key"; Guid)
        {
            DataClassification = OrganizationIdentifiableInformation;
            Caption = 'Client ID Key';
            ExtendedDatatype = Masked;
        }
        field(4709; "Client Secret Key"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Client Secret Key';
            ExtendedDatatype = Masked;
        }
        field(4710; "Authority URL"; Text[250])
        {
            DataClassification = OrganizationIdentifiableInformation;
            Caption = 'OAuth 2.0 Authority URL';
            ExtendedDatatype = URL;
        }
        field(4711; "Resource URL"; Text[250])
        {
            DataClassification = OrganizationIdentifiableInformation;
            Caption = 'OAuth 2.0 Resource URL';
            ExtendedDatatype = URL;
        }
        field(4712; "Redirect URL"; Text[250])
        {
            DataClassification = OrganizationIdentifiableInformation;
            Caption = 'OAuth 2.0 Redirect URL';
            ExtendedDatatype = URL;
        }
        field(4713; "Group Representative On SaaS"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Group Representative Uses Business Central Online';
        }
        field(4714; "Group Settlement Account"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Group Settlement Account';
            TableRelation = "G/L Account"."No.";
        }
        field(4715; "VAT Settlement Account"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'VAT Settlement Account';
            TableRelation = "G/L Account"."No.";
        }
        field(4716; "VAT Due Box No."; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'VAT Due Box No.';
        }
        field(4717; "Group Settle. Gen. Jnl. Templ."; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Group Settlement General Journal Template';
            TableRelation = "Gen. Journal Template".Name;
        }
        field(4718; "VAT Group BC Version"; Enum "VAT Group BC Version")
        {
            DataClassification = CustomerContent;
            Caption = 'Group Representative Product Version';
        }
    }

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure SetSecret(SecretKey: Guid; ClientSecretText: Text): Guid
    var
        NewSecretKey: Guid;
    begin
        if not IsNullGuid(SecretKey) then
            if not IsolatedStorage.Delete(SecretKey, DataScope::Company) then;

        NewSecretKey := CreateGuid();

        if (not EncryptionEnabled() or (StrLen(ClientSecretText) > 215)) then
            IsolatedStorage.Set(NewSecretKey, ClientSecretText, DataScope::Company)
        else
            IsolatedStorage.SetEncrypted(NewSecretKey, ClientSecretText, DataScope::Company);

        exit(NewSecretKey);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetSecret(SecretKey: Guid): Text
    var
        ClientSecretText: Text;
    begin
        if not IsNullGuid(SecretKey) then
            if not IsolatedStorage.Get(SecretKey, DataScope::Company, ClientSecretText) then;

        exit(ClientSecretText);
    end;

    procedure IsGroupRepresentative(): Boolean
    begin
        exit("VAT Group Role" = "VAT Group Role"::Representative);
    end;

    procedure IsGroupMember(): Boolean
    begin
        exit("VAT Group Role" = "VAT Group Role"::Member);
    end;
}