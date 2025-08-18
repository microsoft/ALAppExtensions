// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

page 6394 "Continia Profile Selection"
{
    ApplicationArea = All;
    Caption = 'Network Profile Selection';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Continia Activated Net. Prof.";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Profile Name"; ProfileName)
                {
                    Caption = 'Profile Name';
                    Lookup = true;
                    ToolTip = 'Specifies the name of the profile.';
                    Width = 20;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        NetworkProfile: Record "Continia Network Profile";
                        NetworkProfileList: Page "Continia Network Profile List";
                    begin
                        NetworkProfile.FilterGroup(2);
                        NetworkProfile.SetRange(Network, CurrentNetwork);
                        NetworkProfile.FilterGroup(0);
                        NetworkProfileList.LookupMode(true);

                        if not IsNullGuid(Rec."Network Profile Id") then
                            NetworkProfile.Get(Rec."Network Profile Id")
                        else
                            if Text <> '' then
                                NetworkProfile.SetFilter(Description, StrSubstNo('@*%1*', Text));

                        NetworkProfileList.SetTableView(NetworkProfile);
                        NetworkProfileList.SetRecord(NetworkProfile);
                        if NetworkProfileList.RunModal() = Action::LookupOK then begin
                            NetworkProfileList.GetRecord(NetworkProfile);
                            Rec."Network Profile Id" := NetworkProfile.Id;
                            ProfileName := NetworkProfile.Description;
                            Text := NetworkProfile.Description;
                            exit(true);
                        end;
                    end;
                }
                field("Profile Direction"; Rec."Profile Direction")
                {
                    trigger OnValidate()
                    begin
                        ValidateProfileDirection();
                    end;
                }
                field("E-Document Service Code"; Rec."E-Document Service Code") { }
            }
        }
    }

    var
        ParticipConnected: Boolean;
        EditRemoveNetworkProfileErr: Label 'The following network profiles are about to be unregistered: %1.\\Do you want to continue?', Comment = '%1 - Profile Name';
        ValueChangedInfoMsg: Label 'Please be aware that when changing %1 your participation must go through the approval process with Continia before you can send or receive network documents.\\This can take up to 2 days.', Comment = '%1 - Participation description';
        ProfileName: Text;

    trigger OnAfterGetRecord()
    begin
        if not IsNullGuid(Rec."Network Profile Id") then begin
            Rec.CalcFields("Network Profile Description");
            ProfileName := Rec."Network Profile Description";
        end else
            ProfileName := '';
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ProfileName := '';
    end;

    local procedure ValidateProfileDirection()
    begin
        if not ParticipConnected then
            exit;

        if (xRec."Profile Direction" = xRec."Profile Direction"::Outbound) and
          (Rec."Profile Direction" in [Rec."Profile Direction"::Both, Rec."Profile Direction"::Inbound])
          then
            if not Confirm(StrSubstNo(ValueChangedInfoMsg, StrSubstNo(Rec.FieldCaption("Profile Direction"),
              xRec."Profile Direction", Rec."Profile Direction")))
            then
                Error('');

        if ((xRec."Profile Direction" in [xRec."Profile Direction"::Both, xRec."Profile Direction"::Inbound])) and
          (Rec."Profile Direction" = Rec."Profile Direction"::Outbound)
          then
            if not Confirm(StrSubstNo(EditRemoveNetworkProfileErr, ProfileName)) then
                Error('');
    end;

    internal procedure ClearProfileSelections()
    begin
        Rec.Reset();
        Rec.DeleteAll();
    end;

    internal procedure GetProfileSelection(var ActivatedNetworkProfiles: Record "Continia Activated Net. Prof." temporary)
    begin
        Clear(ActivatedNetworkProfiles);

        if Rec.FindSet() then
            repeat
                ActivatedNetworkProfiles.Init();
                ActivatedNetworkProfiles.TransferFields(Rec, true);
                ActivatedNetworkProfiles.Insert();
            until Rec.Next() = 0;
        if not ActivatedNetworkProfiles.IsEmpty() then
            ActivatedNetworkProfiles.FindFirst();
    end;

    internal procedure SetProfileSelection(var ActivatedNetworkProfiles: Record "Continia Activated Net. Prof." temporary)
    var
        Original: Record "Continia Activated Net. Prof.";
    begin
        Original := ActivatedNetworkProfiles;
        ActivatedNetworkProfiles.SetFilter(Disabled, '=%1', 0DT);
        if ActivatedNetworkProfiles.FindSet() then
            repeat
                Rec.Init();
                Rec.TransferFields(ActivatedNetworkProfiles, true);
                Rec.Insert();
            until ActivatedNetworkProfiles.Next() = 0;
        ActivatedNetworkProfiles.SetRange(Disabled);
        CurrPage.Update(false);

        ActivatedNetworkProfiles := Original;
    end;

    internal procedure SetCurrentNetwork(NewCurrentNetwork: Enum "Continia E-Delivery Network")
    begin
        CurrentNetwork := NewCurrentNetwork;
    end;

    var
        CurrentNetwork: Enum "Continia E-Delivery Network";
}

