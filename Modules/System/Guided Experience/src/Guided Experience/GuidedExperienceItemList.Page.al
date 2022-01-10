// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Lists guided experience items.
/// </summary>
page 1996 "Guided Experience Item List"
{
    Caption = 'Guided Experience Item List';
    PageType = List;
    SourceTable = "Guided Experience Item";
    SourceTableTemporary = true;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    Permissions = tabledata "Guided Experience Item" = r;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;

                field(Title; Title)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the item.';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the item.';
                }
                field(Extension; "Extension Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the app that added the guided experience item.';
                }
                field(Link; Link)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the link to start the guided experience.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if Rec.FindFirst() then; // Set selected record to first record
    end;

    internal procedure SetGuidedExperienceType(GuidedExperienceType: Enum "Guided Experience Type")
    var
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
    begin
        GuidedExperienceImpl.GetContentForSetupPage(Rec, GuidedExperienceType);
    end;
}