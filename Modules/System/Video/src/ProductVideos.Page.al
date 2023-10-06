// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Media;

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
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(content)
        {
            repeater("Available Videos")
            {
                Caption = 'Available Videos';
                Editable = false;
                field(Title; Rec.Title)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the title of the video.';

                    trigger OnDrillDown()
                    var
                        Video: Codeunit Video;
                    begin
                        Video.Play(Rec."Video Url");
                        Video.OnVideoPlayed(Rec."Table Num", Rec."System ID");
                    end;
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the video category.';
                    Visible = false;
                }
                field("App ID"; Rec."App ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the source extension identifier.';
                    Visible = false;
                }
                field("Extension Name"; Rec."Extension Name")
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

    internal procedure SetSpecificCategory(VideoCategory: Enum "Video Category")
    begin
        ShowSpecificCategory := true;
        CategoryToShowVideosFor := VideoCategory;
    end;

    var
        ShowSpecificCategory: Boolean;
        CategoryToShowVideosFor: Enum "Video Category";
}


