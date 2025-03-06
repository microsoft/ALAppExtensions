// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

using System.Utilities;

page 6397 "Con. E-Doc. Serv. Net.Profiles"
{
    ApplicationArea = All;
    Caption = 'E-Document Service Network Profiles';
    Editable = false;
    Extensible = false;
    PageType = List;
    Permissions = tabledata "Continia Activated Net. Prof." = RIMD;
    SourceTable = "Continia Activated Net. Prof.";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Network; NetworkName)
                {
                    Caption = 'Network';
                    ToolTip = 'Specifies Network name of the Network Profile.';
                }
                field(Participation; ParticipationInfo)
                {
                    Caption = 'Participation';
                    ToolTip = 'Specifies information about the Participation of the Network Profile.';
                }
                field("Network Profile Description"; Rec."Network Profile Description") { }
                field("Profile Direction"; Rec."Profile Direction") { }
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref(AddCreation; Add) { }
            actionref(RemoveProcessing; Remove) { }
        }
        area(Creation)
        {
            action(Add)
            {
                Caption = 'Add';
                Image = Add;
                Scope = Repeater;
                ToolTip = 'Adds network profiles to the E-Document Service.';

                trigger OnAction()
                begin
                    AddNetworkProfile();
                end;
            }
        }
        area(Processing)
        {
            action(Remove)
            {
                Caption = 'Remove';
                Image = Delete;
                Scope = Repeater;
                ToolTip = 'Removes selected network profiles from E-Document Service.';

                trigger OnAction()
                begin
                    RemoveNetworkProfiles();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        NetworkIdentifier: Record "Continia Network Identifier";
        ParticipationInfoPatternTxt: Label '%1 %2', Comment = '%1 - Scheme Id, %2 - Identifier Value';
        TemporaryParticipationInfo: Text;
    begin
        ResetPreviousRecordParticipationInfo();
        Clear(ParticipationInfo);
        Clear(NetworkName);
        if NetworkIdentifier.Get(Rec."Identifier Type Id") then
            TemporaryParticipationInfo := StrSubstNo(ParticipationInfoPatternTxt, NetworkIdentifier."Scheme Id", Rec."Identifier Value");

        if PreviousRecordParticipationInfo = TemporaryParticipationInfo then
            exit;
        PreviousRecordParticipationInfo := TemporaryParticipationInfo;
        ParticipationInfo := TemporaryParticipationInfo;
        NetworkName := Format(Rec.Network);
    end;

    internal procedure SetEDocumentServiceCode(PassedEDocumentServiceCode: Code[20])
    begin
        EDocumentServiceCode := PassedEDocumentServiceCode;
    end;

    local procedure AddNetworkProfile()
    var
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
        EDocServiceNetProfSel: Page "Con. E-Doc. Serv. Prof. Sel.";
        SelectedNetworkNames: List of [Text];
    begin
        EDocServiceNetProfSel.SetEDocumentServiceCode(EDocumentServiceCode);
        EDocServiceNetProfSel.FillRecords();
        EDocServiceNetProfSel.LookupMode(true);
        if EDocServiceNetProfSel.RunModal() <> Action::LookupOK then
            exit;

        EDocServiceNetProfSel.GetSelectedProfilesAndNetworks(ActivatedNetProf, SelectedNetworkNames);
        if HandleMultipleNetworkNames(SelectedNetworkNames) then
            UpdateNetworkProfilesBySelection(ActivatedNetProf);
        CurrPage.Update();
    end;

    local procedure RemoveNetworkProfiles()
    var
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
    begin
        CurrPage.SetSelectionFilter(ActivatedNetProf);
        ActivatedNetProf.ModifyAll("E-Document Service Code", '', true);
        CurrPage.Update();
    end;

    local procedure UpdateNetworkProfilesBySelection(var ActivatedNetProf: Record "Continia Activated Net. Prof.")
    begin
        if ActivatedNetProf.FindSet() then
            repeat
                ActivatedNetProf.Validate("E-Document Service Code", EDocumentServiceCode);
                ActivatedNetProf.Modify(true);
            until ActivatedNetProf.Next() = 0;
    end;

    local procedure HandleMultipleNetworkNames(var SelectedNetworkNames: List of [Text]): Boolean
    var
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
        ConfirmManagement: Codeunit "Confirm Management";
        LinkedNetworkNames: List of [Text];
        SelectedNetworkName: Text;
        InitialCountOfLinkedNetworks: Integer;
        DifferentLinkedAndSelectedNetworkNamesQst: Label 'You have selected Network Profile(s) that belong to different Networks than those already linked to the E-Document Service. Are you sure you want to proceed?';
        MultipleNetworksSelectedQst: Label 'You have selected Network Profiles from %1 different Networks. Are you sure you want to proceed?', Comment = '%1 - Number of selected Networks';
    begin
        LinkedNetworkNames := ActivatedNetProf.GetEDocServiceNetworkNames(EDocumentServiceCode);
        InitialCountOfLinkedNetworks := LinkedNetworkNames.Count();

        foreach SelectedNetworkName in SelectedNetworkNames do
            if not LinkedNetworkNames.Contains(SelectedNetworkName) then
                LinkedNetworkNames.Add(SelectedNetworkName);

        if (LinkedNetworkNames.Count() > InitialCountOfLinkedNetworks) and (InitialCountOfLinkedNetworks > 0) then
            if not ConfirmManagement.GetResponse(DifferentLinkedAndSelectedNetworkNamesQst) then
                exit;

        if SelectedNetworkNames.Count() > 1 then
            if not ConfirmManagement.GetResponse(StrSubstNo(MultipleNetworksSelectedQst, SelectedNetworkNames.Count())) then
                exit;
        exit(true);
    end;

    local procedure ResetPreviousRecordParticipationInfo()
    var
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
    begin
        ActivatedNetProf.SetView(Rec.GetView());
        if not ActivatedNetProf.FindFirst() then
            exit;
        if Rec.RecordId() = ActivatedNetProf.RecordId() then
            Clear(PreviousRecordParticipationInfo);
    end;

    var
        EDocumentServiceCode: Code[20];
        ParticipationInfo: Text;
        PreviousRecordParticipationInfo: Text;
        NetworkName: Text;

}