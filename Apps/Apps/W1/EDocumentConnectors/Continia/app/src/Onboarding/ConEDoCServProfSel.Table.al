// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

table 6395 "Con. E-Doc. Serv. Prof. Sel."
{
    Access = Internal;
    Caption = 'E-Document Service Network Profile Selection';
    DataClassification = CustomerContent;
    TableType = Temporary;

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
            ToolTip = 'Specifies ID of E-Document Identifier Type.';
        }
        field(3; "Identifier Value"; Code[50])
        {
            Caption = 'Identifier Value';
            ToolTip = 'Specifies E-Document Identifier Value.';
        }
        field(4; "Network Profile Id"; Guid)
        {
            Caption = 'Network Profile Id';
            TableRelation = "Continia Network Profile".Id where(Network = field(Network));
            ToolTip = 'Specifies ID of E-Document INetwork Profile.';
        }
        field(5; Indent; Integer)
        {
            Caption = 'Indent';
            ToolTip = 'Specifies tree view indentation.';
        }
        field(6; "Participation Description"; Text[100])
        {
            Caption = 'Participation';
            ToolTip = 'Specifies a description of Participation';
        }
        field(7; Description; Text[250])
        {
            Caption = 'Description';
            ToolTip = 'Specifies a description of Network Profile.';
        }
        field(8; "Network Name"; Text[100])
        {
            Caption = 'Network';
            ToolTip = 'Specifies E-Document Network Name';
        }
        field(9; "Profile Direction"; Text[100])
        {
            Caption = 'Profile Direction';
            ToolTip = 'Specifies the direction of the profile.';
        }
        field(10; "E-Document Service Code"; Code[20])
        {
            Caption = 'E-Document Service Code';
            ToolTip = 'Specifies the E-Document Service that would be linked to selected Network Profile.';
        }
        field(11; "Is Profile"; Boolean)
        {
            Caption = 'Is Profile';
            ToolTip = 'Specifies if the record represents Network Profile.';
        }
    }
    keys
    {
        key(PK; Network, "Identifier Type Id", "Identifier Value", "Network Profile Id")
        {
            Clustered = true;
        }
    }

    internal procedure FillNetwork(ActivatedNetProf: Record "Continia Activated Net. Prof.")
    var
        EmptyGuid: Guid;
    begin
        Init();
        Network := ActivatedNetProf.Network;
        "Identifier Type Id" := EmptyGuid;
        "Identifier Value" := '';
        "Network Profile Id" := EmptyGuid;
        "Network Name" := Format(ActivatedNetProf.Network);
        Indent := 0;
        InsertIfPossible();
    end;

    internal procedure FillParticipation(ActivatedNetProf: Record "Continia Activated Net. Prof.")
    var
        Participation: Record "Continia Participation";
        EmptyGuid: Guid;
    begin
        if not Participation.Get(ActivatedNetProf.Network, ActivatedNetProf."Identifier Type Id", ActivatedNetProf."Identifier Value") then
            exit;
        Init();
        Network := Participation.Network;
        "Identifier Type Id" := Participation."Identifier Type Id";
        "Identifier Value" := Participation."Identifier Value";
        "Network Profile Id" := EmptyGuid;
        "Participation Description" := GetParticipationDescription(Participation);
        Indent := 1;
        InsertIfPossible();
    end;

    internal procedure FillNetworkProfile(ActivatedNetProf: Record "Continia Activated Net. Prof.")
    begin
        ActivatedNetProf.CalcFields("Network Profile Description");
        Init();
        Network := ActivatedNetProf.Network;
        "Identifier Type Id" := ActivatedNetProf."Identifier Type Id";
        "Identifier Value" := ActivatedNetProf."Identifier Value";
        "Network Profile Id" := ActivatedNetProf."Network Profile Id";
        "Profile Direction" := Format(ActivatedNetProf."Profile Direction");
        "E-Document Service Code" := ActivatedNetProf."E-Document Service Code";
        Description := ActivatedNetProf."Network Profile Description";
        Indent := 2;
        "Is Profile" := true;
        Insert(false);
    end;

    local procedure GetParticipationDescription(Participation: Record "Continia Participation"): Text[100]
    var
        NetworkIdentifier: Record "Continia Network Identifier";
        ParticipationDescriptionPatternTxt: Label '%1 %2', Comment = '%1 - Scheme Id, %2 - Identifier Value';
    begin
        NetworkIdentifier := Participation.GetNetworkIdentifier();
        exit(StrSubstNo(ParticipationDescriptionPatternTxt, NetworkIdentifier."Scheme Id", Participation."Identifier Value"));
    end;

    local procedure InsertIfPossible()
    begin
        if Find() then
            exit;
        Insert(false);
    end;
}