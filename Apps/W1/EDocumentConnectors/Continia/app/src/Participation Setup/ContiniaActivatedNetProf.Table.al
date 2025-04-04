// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

using Microsoft.eServices.EDocument;

table 6392 "Continia Activated Net. Prof."
{
    Access = Internal;
    Caption = 'Activated Network Profile';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Network; Enum "Continia E-Delivery Network")
        {
            Caption = 'Network';
            ToolTip = 'Specifies E-Document Network.';
        }
        field(2; "Identifier Type Id"; Guid)
        {
            Caption = 'Identifier Type Id';
            TableRelation = "Continia Network Identifier".Id where(Network = field(Network));
        }
        field(3; "Identifier Value"; Code[50])
        {
            Caption = 'Identifier Value';
        }
        field(4; "Network Profile Id"; Guid)
        {
            Caption = 'Network Profile Id';
            TableRelation = "Continia Network Profile".Id where(Network = field(Network));
        }
        field(5; "Profile Direction"; Enum "Continia Profile Direction")
        {
            Caption = 'Profile Direction';
            ToolTip = 'Specifies the direction of the profile.';
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
            CalcFormula = lookup("Continia Network Profile".Description where(Id = field("Network Profile Id")));
            Caption = 'Profile Description';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the description of the profile.';
        }
        field(11; "E-Document Service Code"; Code[20])
        {
            Caption = 'E-Document Service Code';
            TableRelation = "E-Document Service";
            ToolTip = 'Specifies the E-Document Service that would be linked to selected Network Profile.';
        }
    }

    keys
    {
        key(PK; Network, "Identifier Type Id", "Identifier Value", "Network Profile Id")
        {
            Clustered = true;
        }
        key(Key2; Id) { }
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

    internal procedure GetNetworkProfile(var NetworkProfile: Record "Continia Network Profile"): Boolean
    begin
        if not IsNullGuid("Network Profile Id") then
            exit(NetworkProfile.Get("Network Profile Id"));
    end;

    internal procedure FilterByParticipation(Participation: Record "Continia Participation")
    begin
        SetRange(Network, Participation.Network);
        SetRange("Identifier Type Id", Participation."Identifier Type Id");
        SetRange("Identifier Value", Participation."Identifier Value");
    end;

    internal procedure GetEDocServiceNetworkNames(EDocServiceNames: Text) NetworkNames: List of [Text]
    begin
        SetRange("E-Document Service Code", EDocServiceNames);
        if FindSet() then
            repeat
                if not NetworkNames.Contains(Format(Network)) then
                    NetworkNames.Add(Format(Network));
            until Next() = 0;
    end;
}