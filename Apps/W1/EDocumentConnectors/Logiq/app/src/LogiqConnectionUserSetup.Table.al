// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

using System.Security.AccessControl;

table 6431 "Logiq Connection User Setup"
{
    Caption = 'Logiq Connection User Setup';
    DataClassification = CustomerContent;
    ReplicateData = false;
    Access = Internal;

    fields
    {
        field(1; "User ID"; Code[50])
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
        field(31; "API Engine"; Enum "Logiq API Engine")
        {
            Caption = 'API Engine';
            ToolTip = 'Specifies the value of the API Engine field.';
            DataClassification = SystemMetadata;
            trigger OnValidate()
            begin
                case Rec."API Engine" of
                    Rec."API Engine"::"Engine 1":
                        begin
                            Rec."Document Transfer Endpoint" := Engine1TransferTok;
                            Rec."Document Status Endpoint" := Engine1StatusTok;
                        end;
                    Rec."API Engine"::"Engine 3":
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
            ToolTip = 'Specifies the Document Transfer Endpoint.';
        }
        field(33; "Document Status Endpoint"; Text[100])
        {
            Caption = 'Document Status Endpoint';
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

    internal procedure FindUserSetup(UserID: Code[50])
    begin
        if not Rec.Get(UserID) then begin
            Rec.Init();
            Rec."User ID" := UserID;
            Rec.Insert();
        end;
    end;

    var
        Engine1StatusTok: Label '2.0/transfer-status/externalId/', Locked = true;
        Engine1TransferTok: Label '2.0/transfer', Locked = true;
        Engine3StatusTok: Label '2.0/status/externalId/', Locked = true;
        Engine3TransferTok: Label '2.0/send', Locked = true;
}