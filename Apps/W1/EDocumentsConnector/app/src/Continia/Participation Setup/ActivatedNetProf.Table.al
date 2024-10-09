// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

table 6392 "Activated Net. Prof."
{
    Caption = 'Activated Network Profile';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Network; Enum "E-Delivery Network")
        {
            Caption = 'Network';
            DataClassification = CustomerContent;
        }
        field(2; "Identifier Type Id"; Guid)
        {
            Caption = 'Identifier Type Id';
            DataClassification = CustomerContent;
            TableRelation = "Network Identifier".Id where(Network = field(Network));
        }
        field(3; "Identifier Value"; Code[50])
        {
            Caption = 'Identifier Value';
            DataClassification = CustomerContent;
        }
        field(4; "Network Profile Id"; Guid)
        {
            Caption = 'Network Profile Id';
            DataClassification = CustomerContent;
            TableRelation = "Network Profile".Id where(Network = field(Network));
        }
        field(5; "Profile Direction"; Enum "Profile Direction")
        {
            Caption = 'Profile Direction';
            DataClassification = CustomerContent;
        }
        field(6; Id; Guid)
        {
            Caption = 'ID';
            DataClassification = SystemMetadata;
        }
        field(7; Created; DateTime)
        {
            Caption = 'Created Date-Time';
            DataClassification = SystemMetadata;
        }
        field(8; Updated; DateTime)
        {
            Caption = 'Updated Date-Time';
            DataClassification = SystemMetadata;
        }
        field(9; Disabled; DateTime)
        {
            Caption = 'Disabled Date-Time';
            DataClassification = SystemMetadata;
        }
        field(10; "Network Profile Description"; Text[250])
        {
            Caption = 'Profile Description';
            FieldClass = FlowField;
            CalcFormula = lookup("Network Profile".Description where(Id = field("Network Profile Id")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; Network, "Identifier Type Id", "Identifier Value", "Network Profile Id")
        {
            Clustered = true;
        }
        key(Key2; Id)
        {

        }
    }

    internal procedure ValidateApiDirection(Direction: Text)
    begin
        case Direction of
            'BothEnum':
                Validate("Profile Direction", "Profile Direction"::Both);
            'InboundEnum':
                Validate("Profile Direction", "Profile Direction"::Inbound);
            'OutboundEnum':
                Validate("Profile Direction", "Profile Direction"::Outbound);
        end;
    end;

    internal procedure GetParticipApiDirectionEnum(): Text
    begin
        case "Profile Direction" of
            "Profile Direction"::Both:
                exit('BothEnum');
            "Profile Direction"::Inbound:
                exit('InboundEnum');
            "Profile Direction"::Outbound:
                exit('OutboundEnum');
        end;
    end;

    internal procedure GetNetworkProfile(var NetworkProfile: Record "Network Profile"): Boolean
    begin
        if not IsNullGuid("Network Profile Id") then
            exit(NetworkProfile.Get("Network Profile Id"));
    end;

}