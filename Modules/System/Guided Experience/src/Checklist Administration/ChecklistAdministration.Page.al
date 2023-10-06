// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

using System.Globalization;

/// <summary>
/// Provides capabilities to edit and insert new checklist items based on existing guided experience items.
/// </summary>
page 1992 "Checklist Administration"
{
    Caption = 'Checklist Administration';
    PageType = Card;
    SourceTable = "Checklist Item Buffer";
    Editable = true;
    InsertAllowed = false;
    DataCaptionExpression = '';
    Permissions = tabledata "Checklist Item Buffer" = rimd;

    layout
    {
        area(content)
        {
            field(Type; Rec."Guided Experience Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the type of action that the checklist item is for, such as a link to a setup guide or a link to learn more.';
                Editable = true;
            }
            field(Title; Rec.Title)
            {
                Caption = 'Task';
                ApplicationArea = All;
                ToolTip = 'Specifies the title of the checklist item.';
                Lookup = true;

                trigger OnLookup(var Text: Text): Boolean
                begin
                    ChecklistAdministration.LookupGuidedExperienceItem(Rec, Rec."Guided Experience Type");
                    CurrPage.Update();
                end;
            }
            field(Description; Rec.Description)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the description of the checklist item.';
                Editable = false;
            }
            field("Expected Duration"; Rec."Expected Duration")
            {
                Caption = 'Expected Duration (in minutes)';
                ApplicationArea = All;
                ToolTip = 'Specifies how long you expect it will take to complete the checklist item, such as 2 minutes or 10 minutes.';
                Editable = false;
            }
            group("Object to Run")
            {
                Visible = (Rec.Code <> '') and (Rec.Code <> '0')
                    and (Rec."Object Type to Run" <> Rec."Object Type to Run"::Uninitialized)
                    and (Rec."Object ID to Run" <> 0);
                ShowCaption = false;

                field(ObjectCaption; ObjectCaption)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the object that the checklist item will run.';
                    Caption = 'Object to Run';
                    Editable = false;
                }
            }
            group(URL)
            {
                Visible = (Rec.Code <> '') and (Rec.Code <> '0') and (Rec.Link <> '');
                ShowCaption = false;

                field(Link; Rec.Link)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the link that the checklist item will open.';
                    Caption = 'Link to open';
                    Editable = false;
                }
            }
            group(VideoURL)
            {
                Visible = (Rec.Code <> '') and (Rec.Code <> '0') and (Rec."Video Url" <> '');
                ShowCaption = false;

                field("Video Url"; Rec."Video Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the URL of the video that the checklist item will open.';
                    Editable = false;
                    Caption = 'Video URL';
                }
            }
            group("Spotlight Tour")
            {
                Visible = (Rec.Code <> '') and (Rec.Code <> '0')
                    and (Rec."Spotlight Tour Type" <> Rec."Spotlight Tour Type"::None);

                field("Spotlight Tour Type"; Rec."Spotlight Tour Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of spotlight tour that the checklist item will run.';
                    Editable = false;
                    Caption = 'Spotlight Tour Type';
                }
            }
            group("Checklist Item Details")
            {
                Visible = (Rec.Code <> '') and (Rec.Code <> '0');
                ShowCaption = false;

                field("Completion Requirements"; Rec."Completion Requirements")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the completion requirements of the checklist item.';
                    Editable = true;

                    trigger OnValidate()
                    begin
                        if ChecklistAdministration.ConfirmCompletionRequirementsChange(Rec.Code, Rec."Completion Requirements") then
                            ChecklistImplementation.UpdateChecklistItem(Rec.Code, Rec."Completion Requirements", Rec."Order ID");
                    end;
                }
                field("Order ID"; Rec."Order ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which step in the checklist this task will appear at.';
                    Editable = true;

                    trigger OnValidate()
                    begin
                        if Rec."Order ID" < 1 then
                            Error(OrderGreaterThanZeroErr);

                        ChecklistImplementation.UpdateChecklistItem(Rec.Code, Rec."Completion Requirements", Rec."Order ID");
                    end;
                }
            }
            part(Roles; "Checklist Item Roles")
            {
                ApplicationArea = All;
                SubPageLink = Code = field(Code);
                Visible = (Rec.Code <> '') and (Rec.Code <> '0') and
                    ((Rec."Completion Requirements" = Rec."Completion Requirements"::Anyone) or (Rec."Completion Requirements" = Rec."Completion Requirements"::Everyone));
            }
            part(Users; "Checklist Item Users")
            {
                ApplicationArea = All;
                SubPageLink = Code = field(Code), "Assigned to User" = const(true);
                Visible = (Rec.Code <> '') and (Rec.Code <> '0') and (Rec."Completion Requirements" = Rec."Completion Requirements"::"Specific users");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TitleTranslation)
            {
                ApplicationArea = All;
                Caption = 'Manage translations for the title';
                ToolTip = 'Manage translations for the title';
                Image = Translations;

                trigger OnAction()
                var
                    GuidedExperienceItem: Record "Guided Experience Item";
                    Translation: Codeunit Translation;
                begin
                    if GuidedExperienceItem.Get(Rec.Code, Rec.Version) then
                        Translation.Show(GuidedExperienceItem, GuidedExperienceItem.FieldNo(Title));
                end;
            }
            action(ShortTitleTranslation)
            {
                ApplicationArea = All;
                Caption = 'Manage translations for the short title';
                ToolTip = 'Manage translations for the short title';
                Image = Translations;

                trigger OnAction()
                var
                    GuidedExperienceItem: Record "Guided Experience Item";
                    Translation: Codeunit Translation;
                begin
                    if GuidedExperienceItem.Get(Rec.Code, Rec.Version) then
                        Translation.Show(GuidedExperienceItem, GuidedExperienceItem.FieldNo("Short Title"));
                end;
            }
            action(DescriptionTranslation)
            {
                ApplicationArea = All;
                Caption = 'Manage translations for the description';
                ToolTip = 'Manage translations for the description';
                Image = Translations;

                trigger OnAction()
                var
                    GuidedExperienceItem: Record "Guided Experience Item";
                    Translation: Codeunit Translation;
                begin
                    if GuidedExperienceItem.Get(Rec.Code, Rec.Version) then
                        Translation.Show(GuidedExperienceItem, GuidedExperienceItem.FieldNo(Description));
                end;
            }
        }
    }

    var
        ChecklistAdministration: Codeunit "Checklist Administration";
        ChecklistImplementation: Codeunit "Checklist Implementation";
        ObjectCaption: Text[50];
        OrderGreaterThanZeroErr: Label 'The number must be larger than 0.';

    trigger OnAfterGetRecord()
    begin
        if Rec."Order ID" = 0 then
            Rec."Order ID" := 1;

        ObjectCaption := ChecklistAdministration.GetObjectCaption(Rec."Object Type to Run", Rec."Object ID to Run");
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        ChecklistImplementation.Delete(Rec.Code);
    end;
}
