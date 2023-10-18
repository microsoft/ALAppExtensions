// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

using System.Media;
using System.Globalization;

/// <summary>This page shows all registered assisted setup guides.</summary>
page 1801 "Assisted Setup"
{
    ApplicationArea = All;
    Caption = 'Assisted Setup';
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
    UsageCategory = Administration;
    Extensible = true;
    ContextSensitiveHelpPage = 'ui-get-ready-business';
    Permissions = TableData "Guided Experience Item" = r;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = NameIndent;
                IndentationControls = Name;
                ShowAsTree = true;
                field(Name; Rec.Title)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name.';
                    Style = Strong;
                    StyleExpr = NameEmphasize;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        RunPage();
                    end;
                }
                field(Completed; Rec.Completed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the setup is complete.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        RunPage();
                    end;
                }
                field(Help; HelpAvailable)
                {
                    ApplicationArea = All;
                    Caption = 'Learn more';
#pragma warning disable AA0219
                    ToolTip = 'Learn more about the process.';
#pragma warning restore AA0219
                    Width = 3;

                    trigger OnDrillDown()
                    var
                        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
                    begin
                        GuidedExperienceImpl.NavigateToAssistedSetupHelpPage(Rec);
                    end;
                }
                field(Video; VideoAvailable)
                {
                    ApplicationArea = All;
                    Caption = 'Video';
#pragma warning disable AA0219
                    ToolTip = 'Play a video that describes the process.';
#pragma warning restore AA0219
                    Width = 3;
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        Video: Codeunit Video;
                    begin
                        if Rec."Video Url" <> '' then
                            Video.Play(Rec."Video Url");
                    end;
                }
                field(TranslatedName; TranslatedNameValue)
                {
                    Caption = 'Translated Name';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name translated locally.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        GuidedExperienceItem: Record "Guided Experience Item";
                        Translation: Codeunit Translation;
                    begin
                        if GuidedExperienceItem.Get(Rec.Code, Rec.Version) then
                            Translation.Show(GuidedExperienceItem, GuidedExperienceItem.FieldNo(Title));
                    end;
                }
                field("Extension Name"; Rec."Extension Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the extension which has added this setup.';
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the set up.';
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
                ToolTip = 'Start the assisted setup guide.';

                trigger OnAction()
                begin
                    RunPage();
                end;
            }
            action("General videos")
            {
                ApplicationArea = All;
                Caption = 'General Videos';
                Image = Help;
                Scope = Page;
                ToolTip = 'See other videos that can help you set up the app.';

                trigger OnAction()
                begin
                    Page.Run(Page::"Product Videos");
                end;
            }
        }
        area(Promoted)
        {
            actionref("Start Setup Ref"; "Start Setup")
            {
            }
            actionref("General videos Ref"; "General videos")
            {
            }
        }
    }

    trigger OnOpenPage()
    var
        GuidedExperience: Codeunit "Guided Experience";
        ChecklistImplementation: Codeunit "Checklist Implementation";
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
    begin
        GuidedExperience.OnRegisterAssistedSetup();
        GuidedExperienceImpl.GetContentForAssistedSetup(Rec);
        Rec.SetCurrentKey("Assisted Setup Group");

        if FilterSet then
            Rec.SetRange("Assisted Setup Group", AssistedSetupGroup);

        if Rec.FindFirst() then; // Set selected record to first record

        ChecklistImplementation.ShowChecklistBannerVisibilityNotification();
    end;

    trigger OnAfterGetRecord()
    var
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
    begin
        HelpAvailable := '';
        VideoAvailable := '';
        if Rec."Help Url" <> '' then
            HelpAvailable := HelpLinkTxt;
        if Rec."Video Url" <> '' then
            VideoAvailable := VideoLinkTxt;
        if GuidedExperienceImpl.IsAssistedSetupSetupRecord(Rec) then
            SetPageVariablesForSetupRecord()
        else
            SetPageVariablesForSetupGroup();
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

    local procedure SetPageVariablesForSetupRecord()
    var
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
    begin
        TranslatedNameValue := GuidedExperienceImpl.GetTranslationForField(Rec, Rec.FieldNo(Title));
        NameIndent := 1;
        NameEmphasize := false;
    end;

    local procedure SetPageVariablesForSetupGroup()
    begin
        TranslatedNameValue := '';
        NameEmphasize := true;
        NameIndent := 0;
    end;

    internal procedure SetGroupToDisplay(AssistedSetupGroupValue: Enum "Assisted Setup Group")
    begin
        FilterSet := true;
        AssistedSetupGroup := AssistedSetupGroupValue;
    end;

    var
        HelpLinkTxt: Label 'Read';
        VideoLinkTxt: Label 'Watch';
        HelpAvailable: Text;
        VideoAvailable: Text;
        TranslatedNameValue: Text;
        NameIndent: Integer;
        NameEmphasize: Boolean;
        AssistedSetupGroup: Enum "Assisted Setup Group";
        FilterSet: Boolean;
}


