// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>This page shows all registered assisted setup guides.</summary>
page 1801 "Assisted Setup"
{
    AccessByPermission = TableData "Assisted Setup" = R;
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
    SourceTable = "Assisted Setup";
    SourceTableTemporary = true;
    UsageCategory = Administration;
    Extensible = true;
    ContextSensitiveHelpPage = 'ui-get-ready-business';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = NameIndent;
                IndentationControls = Name;
                ShowAsTree = true;
                field(Name; Name)
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
                field(Completed; Completed)
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
                    Caption = 'Help';
                    ToolTip = 'Learn more about the process.';
                    Width = 3;

                    trigger OnDrillDown()
                    var
                        AssistedSetupImpl: Codeunit "Assisted Setup Impl.";
                    begin
                        AssistedSetupImpl.NavigateHelpPage(Rec);
                    end;
                }
                field(Video; VideoAvailable)
                {
                    ApplicationArea = All;
                    Caption = 'Video';
                    ToolTip = 'Play a video that describes the process.';
                    Width = 3;

                    trigger OnDrillDown()
                    var
                        Video: Codeunit Video;
                    begin
                        if "Video Url" <> '' then
                            Video.Play("Video Url");
                    end;
                }
                field(GroupName; "Group Name")
                {
                    ApplicationArea = All;
                    Caption = 'Group';
                    ToolTip = 'Group Name';
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'The groups now appear as headings in the page, so this column is redundant.';
                    ObsoleteTag = '16.0';
                }
                field(TranslatedName; TranslatedNameValue)
                {
                    Caption = 'Translated Name';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name translated locally.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        AssistedSetup: Record "Assisted Setup";
                        Translation: Codeunit Translation;
                    begin
                        if AssistedSetup.Get("Page ID") then
                            Translation.Show(AssistedSetup, AssistedSetup.FieldNo(Name));
                    end;
                }
                field("Extension Name"; "Extension Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the extension which has added this setup.';
                    Visible = false;
                }
                field(Description; Description)
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
    }

    trigger OnOpenPage()
    var
        AssistedSetupApi: Codeunit "Assisted Setup";
        AssistedSetupImpl: Codeunit "Assisted Setup Impl.";
    begin
        AssistedSetupApi.OnRegister();
        SetCurrentKey("Group Name");
        AssistedSetupImpl.RefreshBuffer(Rec);
        if FilterSet then
            SetRange("Group Name", AssistedSetupGroup);

        if Rec.FindFirst() then; // Set selected record to first record
    end;

    trigger OnAfterGetRecord()
    var
        AssistedSetupImpl: Codeunit "Assisted Setup Impl.";
    begin
        HelpAvailable := '';
        VideoAvailable := '';
        if "Help Url" <> '' then
            HelpAvailable := HelpLinkTxt;
        if "Video Url" <> '' then
            VideoAvailable := VideoLinkTxt;
        if AssistedSetupImpl.IsSetupRecord(Rec) then
            SetPageVariablesForSetupRecord()
        else
            SetPageVariablesForSetupGroup();
    end;

    local procedure RunPage()
    var
        AssistedSetupImpl: Codeunit "Assisted Setup Impl.";
    begin
        if AssistedSetupImpl.IsSetupRecord(Rec) then begin
            AssistedSetupImpl.RunAndRefreshRecord(Rec);
            CurrPage.Update(false);
        end;
    end;

    local procedure SetPageVariablesForSetupRecord()
    var
        AssistedSetupImpl: Codeunit "Assisted Setup Impl.";
    begin
        TranslatedNameValue := AssistedSetupImpl.GetTranslatedName("Page ID");
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
        [InDataSet]
        TranslatedNameValue: Text;
        [InDataSet]
        NameIndent: Integer;
        [InDataSet]
        NameEmphasize: Boolean;
        AssistedSetupGroup: Enum "Assisted Setup Group";
        FilterSet: Boolean;
}

