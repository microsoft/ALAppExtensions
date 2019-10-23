// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>This page shows all registered videos.</summary>
page 1470 "Product Videos"
{
    Extensible = false;
    Caption = 'Product Videos';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Product Video Buffer";
    SourceTableTemporary = true;
    UsageCategory = Administration;
    ApplicationArea = All;
    ContextSensitiveHelpPage = 'across-videos';

    layout
    {
        area(content)
        {
            repeater("Available Videos")
            {
                Caption = 'Available Videos';
                Editable = false;
                field(Title; Title)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the title of the video.';

                    trigger OnDrillDown()
                    var
                        Video: Codeunit Video;
                    begin
                        Video.Play("Video Url");
                        Video.OnVideoPlayed("Table Num", "System ID");
                    end;
                }
                field(Category; Category)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the video category.';
                    Visible = false;
                }
                field("App ID"; "App ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the source extension identifier.';
                    Visible = false;
                }
                field("Extension Name"; "Extension Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the source extension name.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        Video: Codeunit Video;
    begin
        Video.OnRegisterVideo();
        Video.GetTemporaryRecord(Rec);
        if ShowSpecificCategory then
            Rec.SetRange(Category, CategoryToShowVideosFor);
    end;

    internal procedure SetSpecificCategory(Category: Enum "Video Category")
    begin
        ShowSpecificCategory := true;
        CategoryToShowVideosFor := Category;
    end;

    var
        ShowSpecificCategory: Boolean;
        CategoryToShowVideosFor: Enum "Video Category";
}

