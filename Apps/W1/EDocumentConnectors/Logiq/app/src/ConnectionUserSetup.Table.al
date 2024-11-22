namespace Microsoft.EServices.EDocumentConnector.Logiq;

using System.Security.AccessControl;

table 6381 "Connection User Setup"
{
    Caption = 'Logiq Connection User Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "User ID"; Text[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
        }
        field(21; Username; Text[100])
        {
            Caption = 'Username';
            DataClassification = EndUserIdentifiableInformation;
            ToolTip = 'Specifies the user name.';
        }
        field(22; Password; Guid)
        {
            Caption = 'Password';
        }
        field(23; "Access Token"; Guid)
        {
            Caption = 'Access Token';
        }
        field(24; "Access Token Expiration"; DateTime)
        {
            Caption = 'Access Token Expires At';
            ToolTip = 'Specifies the access token expiration date.';
        }
        field(25; "Refresh Token"; Guid)
        {
            Caption = 'Refresh Token';
        }
        field(26; "Refresh Token Expiration"; DateTime)
        {
            Caption = 'Refresh Token Expires At';
            ToolTip = 'Specifies the refresh token expiration date.';
        }
        field(31; "API Engine"; Enum "API Engine")
        {
            Caption = 'API Engine';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the value of the API Engine field.';
            trigger OnValidate()

            begin
                case Rec."API Engine" of
                    Rec."API Engine"::Engine1:
                        begin
                            Rec."Document Transfer Endpoint" := Engine1TransferTok;
                            Rec."Document Status Endpoint" := Engine1StatusTok;
                        end;
                    Rec."API Engine"::Engine3:
                        begin
                            Rec."Document Transfer Endpoint" := Engine3TransferTok;
                            Rec."Document Status Endpoint" := Engine3StatusTok;
                        end;
                end;
            end;
        }
        field(32; "Document Transfer Endpoint"; Text[100])
        {
            Caption = 'Document Transfer Endpoint';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the Document Transfer Endpoint.';
        }
        field(33; "Document Status Endpoint"; Text[100])
        {
            Caption = 'Document Status Endpoint';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the Document Status Endpoint.';
        }
    }
    keys
    {
        key(PK; "User ID")
        {
            Clustered = true;
        }
    }

    var
        LogiqAuth: Codeunit Auth;

    internal procedure FindUserSetup(UserID: Text[50])
    begin
        if not Rec.Get(UserID) then begin
            Rec.Init();
            Rec."User ID" := UserID;
            Rec.Insert(false);
        end;
    end;

    internal procedure GetPassword(): SecretText
    var
        ClientSecret: SecretText;
    begin
        this.LogiqAuth.GetIsolatedStorageValue(Rec.Password, ClientSecret, DataScope::User);
        exit(ClientSecret);
    end;

    internal procedure GetAccessToken(): SecretText
    var
        AccessToken: SecretText;
    begin
        this.LogiqAuth.GetIsolatedStorageValue(Rec."Access Token", AccessToken, DataScope::User);
        exit(AccessToken);
    end;

    internal procedure GetRefreshToken(): SecretText
    var
        RefreshToken: SecretText;
    begin
        this.LogiqAuth.GetIsolatedStorageValue(Rec."Refresh Token", RefreshToken, DataScope::User);
        exit(RefreshToken);
    end;

    internal procedure DeleteUserTokens()
    begin
        if (not IsNullGuid(Rec."Access Token")) then
            if IsolatedStorage.Contains(Rec."Access Token", DataScope::User) then
                IsolatedStorage.Delete(Rec."Access Token", DataScope::User);
        if (not IsNullGuid(Rec."Refresh Token")) then
            if IsolatedStorage.Contains(Rec."Refresh Token", DataScope::User) then
                IsolatedStorage.Delete(Rec."Refresh Token", DataScope::User);
        Rec."Access Token Expiration" := 0DT;
        Rec."Refresh Token Expiration" := 0DT;
        Rec.Modify(false);
    end;

    internal procedure DeletePassword()
    begin
        if (not IsNullGuid(Rec.Password)) then
            if IsolatedStorage.Contains(Rec.Password, DataScope::User) then
                IsolatedStorage.Delete(Rec.Password, DataScope::User);
    end;

    var
        Engine1StatusTok: Label '2.0/transfer-status/externalId/', Locked = true;
        Engine1TransferTok: Label '2.0/transfer', Locked = true;
        Engine3StatusTok: Label '2.0/status/externalId/', Locked = true;
        Engine3TransferTok: Label '2.0/send', Locked = true;
}