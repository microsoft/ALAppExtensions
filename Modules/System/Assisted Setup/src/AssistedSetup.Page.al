// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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
    UsageCategory = Administration;
    Extensible = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Run();
                        CurrPage.Update(false);
                    end;
                }
                field(Completed; Completed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the setup is complete.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Run();
                        CurrPage.Update(false);
                    end;
                }
                field(Help; HelpAvailable)
                {
                    ApplicationArea = All;
                    Caption = 'Help';
                    Width = 3;

                    trigger OnDrillDown()
                    begin
                        NavigateHelpPage();
                    end;
                }
                field(Video; VideoAvailable)
                {
                    ApplicationArea = All;
                    Caption = 'Video';
                    Width = 3;

                    trigger OnDrillDown()
                    var
                        Video: Codeunit Video;
                    begin
                        if "Video Url" <> '' then
                            Video.Play("Video Url");
                    end;
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
                    Run();
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

    trigger OnAfterGetRecord()
    begin
        HelpAvailable := '';
        VideoAvailable := '';
        if "Help Url" <> '' then
            HelpAvailable := HelpLinkTxt;
        if "Video Url" <> '' then
            VideoAvailable := VideoLinkTxt;
    end;

    trigger OnOpenPage()
    var
        AssistedSetupApi: Codeunit "Assisted Setup";
    begin
        AssistedSetupApi.OnRegister();
        SetCurrentKey("App ID");
        Ascending(true);
    end;

    var
        HelpLinkTxt: Label 'Read';
        VideoLinkTxt: Label 'Watch';
        HelpAvailable: Text;
        VideoAvailable: Text;
}

