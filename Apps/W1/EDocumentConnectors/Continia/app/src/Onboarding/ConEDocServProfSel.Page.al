// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

page 6398 "Con. E-Doc. Serv. Prof. Sel."
{
    ApplicationArea = All;
    Caption = 'E-Document Service Network Profile Selection';
    Editable = false;
    Extensible = false;
    PageType = List;
    SourceTable = "Con. E-Doc. Serv. Prof. Sel.";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                IndentationColumn = Rec.Indent;
                ShowAsTree = true;

                field(Network; Rec."Network Name") { }
                field("Participation Description"; Rec."Participation Description") { }
                field(Description; Rec.Description) { }
                field("Profile Direction"; Rec."Profile Direction") { }
                field("E-Document Service Code"; Rec."E-Document Service Code") { }
            }
        }
    }

    internal procedure FillRecords(): Boolean
    var
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
    begin
        ActivatedNetProf.SetFilter("E-Document Service Code", '<>%1', EDocumentServiceCode);
        if ActivatedNetProf.FindSet() then
            repeat
                Rec.FillNetworkProfile(ActivatedNetProf);
                Rec.FillParticipation(ActivatedNetProf);
                Rec.FillNetwork(ActivatedNetProf);
            until ActivatedNetProf.Next() = 0;
    end;

    internal procedure GetSelectedProfilesAndNetworks(var ActivatedNetProf: Record "Continia Activated Net. Prof."; var SelectedNetworkNames: List of [Text])
    begin
        ActivatedNetProf.Reset();
        Clear(SelectedNetworkNames);

        CurrPage.SetSelectionFilter(Rec);
        if Rec.FindSet() then
            repeat
                if Rec."Is Profile" then begin
                    if ActivatedNetProf.Get(Rec.Network, Rec."Identifier Type Id", Rec."Identifier Value", Rec."Network Profile Id") then
                        ActivatedNetProf.Mark(true);
                    if not SelectedNetworkNames.Contains(Format(Rec.Network)) then
                        SelectedNetworkNames.Add(Format(Rec.Network));
                end;
            until Rec.Next() = 0;
        ActivatedNetProf.MarkedOnly(true);
    end;

    internal procedure SetEDocumentServiceCode(PassedEDocumentServiceCode: Code[20])
    begin
        EDocumentServiceCode := PassedEDocumentServiceCode;
    end;

    var
        EDocumentServiceCode: Code[20];
}