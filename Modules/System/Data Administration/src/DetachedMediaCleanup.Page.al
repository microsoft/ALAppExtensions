// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.DataAdministration;

using System.Environment;
using System.Security.AccessControl;

page 1927 "Detached Media Cleanup"
{
    PageType = Worksheet;
    ApplicationArea = All;
    SourceTable = "Tenant Media";
    Extensible = false;
    Caption = 'Detached Media Cleanup';
    SourceTableTemporary = true;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            label(PageInformation)
            {
                Caption = 'This page provides an overview of what kinds of detached media you have. Detached media is media which is not directly referenced. All Microsoft extensions references media directly. You can either delete individual detached media or schedule a background task to clear all detached media when you are ready.';
            }
            field(LoadLimitField; LoadLimit)
            {
                ApplicationArea = All;
                Caption = 'Load Limit';
                Tooltip = 'Specifies the maximum number of records to load. Depending on the limit, this may take a long time to complete.';
                MinValue = 1;
            }
            field(CompanyFilterField; CompanyFilter)
            {
                ApplicationArea = All;
                Caption = 'Company Filter';
                ToolTip = 'Specifies the filter to a specific company.';
                TableRelation = Company.Name;

                trigger OnValidate()
                begin
                    if CompanyFilter <> '' then
                        Rec.SetRange("Company Name", CompanyFilter)
                    else
                        Rec.SetRange("Company Name");
                end;
            }
            field(LoadDetachedMediaSetField; LoadDetachedMediaSet)
            {
                ApplicationArea = All;
                Caption = 'Load Detached Media Set';
                ToolTip = 'Specifies whether media from detached media sets should be included.';
            }
            repeater(DetachedMedia)
            {
                field(FileName; Rec."File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the file.';
                }
                field(MimeType; Rec."Mime Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the file type';
                }
                field(CompanyName; Rec."Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which company this media is created in.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the media.';
                }
                field(CreatingUser; Rec."Creating User")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the user who created the media.';
                    TableRelation = User."User Name";
                }
                field(CreatedBy; Rec.SystemCreatedBy)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the user who created the media.';
                }
                field(Id; Rec.ID)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies a unique identifier for this media.';
                }
                field(SecurityToken; Rec."Security Token")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the security token of this media.';
                }
            }
        }
        area(FactBoxes)
        {
            part(MediaFactBox; "Media Cleanup FactBox")
            {
                ApplicationArea = All;
                SubPageLink = ID = field(ID);
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref(Refresh_Promoted; Refresh)
            {
            }
            actionref(Delete_Promoted; Delete)
            {
            }
            actionref(DownloadContent_Promoted; DownloadContent)
            {
            }
        }
        area(Processing)
        {
            action(DeleteAllOrphans)
            {
                ApplicationArea = All;
                Caption = 'Schedule cleanup task';
                ToolTip = 'Schedules a task to cleanup all all detached media entries in the database.';
                Image = Delete;

                trigger OnAction()
                begin
                    if Confirm(DeleteAllDetachedMediaQst) then
                        MediaCleanup.ScheduleCleanupDetachedMedia();
                end;
            }
            action(Refresh)
            {
                ApplicationArea = All;
                Caption = 'Load Detached Media';
                ToolTip = 'Load detached media based on the settings.';
                Image = Refresh;

                trigger OnAction()
                begin
                    RefreshDetachedMedia();
                end;
            }
            action(Delete)
            {
                ApplicationArea = All;
                Caption = 'Delete';
                ToolTip = 'Deletes the selected rows.';
                Image = Delete;

                trigger OnAction()
                var
                    TempTenantMedia: Record "Tenant Media" temporary;
                begin
                    if not Confirm(DeleteRowsQst) then
                        exit;

                    TempTenantMedia.Copy(Rec, true);
                    CurrPage.SetSelectionFilter(TempTenantMedia);
                    MediaCleanup.DeleteDetachedTenantMedia(TempTenantMedia);
                end;
            }
            action(DownloadContent)
            {
                ApplicationArea = All;
                Scope = Repeater;
                Caption = 'Download Media';
                ToolTip = 'Downloads the content of the media.';
                Image = Download;

                trigger OnAction()
                begin
                    if not MediaCleanup.DownloadTenantMedia(Rec.ID) then
                        Error(NoMediaContentErr);
                end;
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    var
        TenantMedia: Record "Tenant Media";
    begin
        TenantMedia := Rec;
        TenantMedia.Delete();
    end;

    trigger OnOpenPage()
    var
    begin
        LoadLimit := 10000;
    end;

    local procedure RefreshDetachedMedia()
    var
        TenantMediaFilters: Record "Tenant Media";
    begin
        TenantMediaFilters.CopyFilters(Rec); // Clearing filters to set marks and then re-apply filters afterwards again

        Rec.Reset();
        Rec.DeleteAll();
        MediaCleanup.GetDetachedTenantMedia(Rec, false, LoadLimit);
        if LoadDetachedMediaSet then
            MediaCleanup.GetTenantMediaFromDetachedMediaSet(Rec, false, LoadLimit);

        Rec.CopyFilters(TenantMediaFilters);
        if Rec.FindFirst() then; // Set focus on the first record
    end;

    var
        MediaCleanup: Codeunit "Media Cleanup";
        LoadDetachedMediaSet: Boolean;
        NoMediaContentErr: Label 'The selected media does not have any content.';
        DeleteAllDetachedMediaQst: Label 'This will immediately schedule a background task to delete all detached media and media sets in the database, not just media on the page. Depending on the amount of detached media this may take a while. Do you want to continue?';
        DeleteRowsQst: Label 'Do you want to delete the selected rows?';
        LoadLimit: Integer;
        CompanyFilter: Text;
}
