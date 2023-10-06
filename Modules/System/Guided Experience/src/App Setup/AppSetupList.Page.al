// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

/// <summary>This page shows all registered setups.</summary>
page 1991 "App Setup List"
{
    Caption = 'App Setups';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "Guided Experience Item";
    SourceTableTemporary = true;
    Extensible = true;
    ContextSensitiveHelpPage = 'ui-get-ready-business';
    Permissions = TableData "Guided Experience Item" = r,
                  TableData "Primary Guided Experience Item" = r;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Title)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name.';
                    StyleExpr = StatusStyleTxt;
                    Caption = 'Page';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        RunPage();
                    end;
                }
                field("Extension Name"; Rec."Extension Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the app that this page is used to set up.';
                    StyleExpr = StatusStyleTxt;
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the setup.';
                    StyleExpr = StatusStyleTxt;
                }
                field("Extension Publisher"; Rec."Extension Publisher")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the publisher of the app that this page is used to set up.';
                    StyleExpr = StatusStyleTxt;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Start Setup")
            {
                ApplicationArea = All;
                Caption = 'Start Setup';
                Image = Setup;
                Scope = Repeater;
                ShortCutKey = 'Return';
                ToolTip = 'Start setup.';

                trigger OnAction()
                begin
                    RunPage();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
    begin
        GuidedExperience.OnRegisterAssistedSetup();
        GuidedExperience.OnRegisterManualSetup();
        GuidedExperienceImpl.GetContentForAllSetups(Rec);

        Rec.SetCurrentKey("Guided Experience Type");

        if Rec.Count() = 0 then begin
            Message(SetupNotDefinedErr);
            Error('');
        end;

        if Rec.FindFirst() then begin// Set selected record to first record
            Rec.CalcFields("Extension Name");
            CurrPage.Caption(StrSubstNo(CaptionTok, Rec."Extension Name"));
            CurrPage.Update(false);
        end;

        FirstRun := true;
    end;

    trigger OnAfterGetRecord()
    var
        PrimaryGuidedExperienceItem: Record "Primary Guided Experience Item";
    begin
        PrimaryGuidedExperienceItem.SetRange("Primary Setup", Rec.SystemId);
        if not PrimaryGuidedExperienceItem.IsEmpty then
            StatusStyleTxt := 'Strong'
        else
            StatusStyleTxt := 'None';
    end;

    trigger OnAfterGetCurrRecord()
    var
        SelectedGuidedExperienceItem: Record "Guided Experience Item";
        PrimaryGuidedExperienceItem: Record "Primary Guided Experience Item";
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
    begin
        if not FirstRun then
            exit;

        FirstRun := false;
        if PrimaryGuidedExperienceItem.Get(Rec."Extension ID") then
            if SelectedGuidedExperienceItem.GetBySystemId(PrimaryGuidedExperienceItem."Primary Setup") then
                if Confirm(RunInitialSetupQst) then begin
                    Commit();
                    GuidedExperienceImpl.RunAndRefreshAssistedSetup(SelectedGuidedExperienceItem);
                end;
    end;

    local procedure RunPage()
    var
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
    begin
        if GuidedExperienceImpl.IsAssistedSetupSetupRecord(Rec) then begin
            GuidedExperienceImpl.RunAndRefreshAssistedSetup(Rec);
            CurrPage.Update(false);
        end;
    end;

    procedure SetExtensionId(AppID: Guid)
    begin
        Rec.SetRange("Extension ID", AppID);
    end;

    var
        StatusStyleTxt: Text;
        SetupNotDefinedErr: Label 'This app doesn''t require set-up.';
        CaptionTok: Label 'Setups for %1', Comment = '%1 = App Name';
        RunInitialSetupQst: Label 'Do you want to run the initial setup?';
        FirstRun: Boolean;
}


