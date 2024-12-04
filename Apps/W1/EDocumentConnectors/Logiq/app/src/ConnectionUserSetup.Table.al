// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

using System.Security.AccessControl;

table 6431 "Connection User Setup"
{
    Caption = 'Logiq Connection User Setup';
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; "User Security ID"; Guid)
        {
            Caption = 'User Security ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User;
        }
        field(2; "User ID"; Text[50])
        {
            Caption = 'User ID';
            ToolTip = 'Specifies the user ID.';
            FieldClass = FlowField;
            CalcFormula = lookup(User."User Name" where("User Security ID" = field("User Security ID")));
        }
        field(21; Username; Text[100])
        {
            Caption = 'Username';
            DataClassification = EndUserIdentifiableInformation;
            ToolTip = 'Specifies the user name.';
        }
        field(22; "Password - Key"; Guid)
        {
            Caption = 'Password';
            ToolTip = 'Specifies the password key.';
            DataClassification = SystemMetadata;
        }
        field(23; "Access Token - Key"; Guid)
        {
            Caption = 'Access Token Key';
            ToolTip = 'Specifies the access token key.';
            DataClassification = SystemMetadata;
        }
        field(24; "Access Token Expiration"; DateTime)
        {
            Caption = 'Access Token Expires At';
            ToolTip = 'Specifies the access token expiration date.';
            DataClassification = SystemMetadata;
        }
        field(25; "Refresh Token - Key"; Guid)
        {
            Caption = 'Refresh Token Key';
            ToolTip = 'Specifies the refresh token key.';
            DataClassification = SystemMetadata;
        }
        field(26; "Refresh Token Expiration"; DateTime)
        {
            Caption = 'Refresh Token Expires At';
            ToolTip = 'Specifies the refresh token expiration date.';
            DataClassification = SystemMetadata;
        }
        field(31; "API Engine"; Enum "API Engine")
        {
            Caption = 'API Engine';
            ToolTip = 'Specifies the value of the API Engine field.';
            DataClassification = SystemMetadata;
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
        key(PK; "User Security ID")
        {
            Clustered = true;
        }
    }

    var
        LogiqAuth: Codeunit Auth;

    internal procedure FindUserSetup(UserSecurityID: Guid)
    begin
        if not Rec.Get(UserSecurityID) then begin
            Rec.Init();
            Rec."User Security ID" := UserSecurityID;
            Rec.Insert();
        end;
    end;

    internal procedure GetPassword(): SecretText
    var
        ClientSecret: SecretText;
    begin
        this.LogiqAuth.GetIsolatedStorageValue(Rec."Password - Key", ClientSecret, DataScope::User);
        exit(ClientSecret);
    end;

    internal procedure GetAccessToken(): SecretText
    var
        AccessToken: SecretText;
    begin
        this.LogiqAuth.GetIsolatedStorageValue(Rec."Access Token - Key", AccessToken, DataScope::User);
        exit(AccessToken);
    end;

    internal procedure GetRefreshToken(): SecretText
    var
        RefreshToken: SecretText;
    begin
        this.LogiqAuth.GetIsolatedStorageValue(Rec."Refresh Token - Key", RefreshToken, DataScope::User);
        exit(RefreshToken);
    end;

    internal procedure DeleteUserTokens()
    begin
        if (not IsNullGuid(Rec."Access Token - Key")) then
            if IsolatedStorage.Contains(Rec."Access Token - Key", DataScope::User) then
                IsolatedStorage.Delete(Rec."Access Token - Key", DataScope::User);
        if (not IsNullGuid(Rec."Refresh Token - Key")) then
            if IsolatedStorage.Contains(Rec."Refresh Token - Key", DataScope::User) then
                IsolatedStorage.Delete(Rec."Refresh Token - Key", DataScope::User);
        Rec."Access Token Expiration" := 0DT;
        Rec."Refresh Token Expiration" := 0DT;
        Rec.Modify();
    end;

    internal procedure DeletePassword()
    begin
        if (not IsNullGuid(Rec."Password - Key")) then
            if IsolatedStorage.Contains(Rec."Password - Key", DataScope::User) then
                IsolatedStorage.Delete(Rec."Password - Key", DataScope::User);
    end;

    var
        Engine1StatusTok: Label '2.0/transfer-status/externalId/', Locked = true;
        Engine1TransferTok: Label '2.0/transfer', Locked = true;
        Engine3StatusTok: Label '2.0/status/externalId/', Locked = true;
        Engine3TransferTok: Label '2.0/send', Locked = true;
}