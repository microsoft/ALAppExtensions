// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Avalara;

table 6372 "Connection Setup"
{
    fields
    {
        field(1; Id; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Client Id - Key"; Guid)
        {
            Caption = 'Client Id';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Client Secret - Key"; Guid)
        {
            Caption = 'Client Secret';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "Authentication URL"; Text[250])
        {
            Caption = 'Authentication URL';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "API URL"; Text[250])
        {
            Caption = 'API URL';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; "Sandbox Authentication URL"; Text[250])
        {
            Caption = 'Sandbox Authentication URL';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7; "Sandbox API URL"; Text[250])
        {
            Caption = 'Sandbox Authentication URL';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; "Token - Key"; Guid)
        {
            Caption = 'Token';
            DataClassification = CustomerContent;
        }
        field(9; "Token Expiry"; DateTime)
        {
            Caption = 'Token Expiry';
            DataClassification = CustomerContent;
        }
        field(10; "Company Id"; Text[250])
        {
            Caption = 'Company ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Company Name"; Text[250])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Avalara Send Mode"; Enum "Avalara Send Mode")
        {
            Caption = 'Send Mode';
            DataClassification = CustomerContent;

#if not CLEAN27
#pragma warning disable AL0432
            trigger OnValidate()
            begin
                case Rec."Avalara Send Mode" of
                    Enum::"Avalara Send Mode"::Production:
                        Rec."Send Mode" := Rec."Send Mode"::Production;
                    Enum::"Avalara Send Mode"::Test:
                        Rec."Send Mode" := Rec."Send Mode"::Test;
                    Enum::"Avalara Send Mode"::Certification:
                        Rec."Send Mode" := Rec."Send Mode"::Certification;
                end;
            end;
#pragma warning restore AL0432
#endif
        }
#if not CLEANSCHEMA30
#pragma warning disable AL0432, AS0105
        field(13; "Send Mode"; Enum "E-Doc. Ext. Send Mode")
#pragma warning restore AL0432, AS0105
        {
            Caption = 'Send Mode';
            DataClassification = EndUserIdentifiableInformation;
            ObsoleteReason = 'Use "Avalara Send Mode" instead.';
#if not CLEAN27
            ObsoleteState = Pending;
            ObsoleteTag = '27.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '30.0';
#endif
        }
#endif
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
    }

}