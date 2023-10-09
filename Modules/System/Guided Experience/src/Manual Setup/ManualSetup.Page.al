// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

/// <summary>This page shows all registered manual setups.</summary>
page 1875 "Manual Setup"
{
    Extensible = false;
    ApplicationArea = All;
    Caption = 'Manual Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Guided Experience Item";
    SourceTableTemporary = true;
    UsageCategory = Administration;
    ContextSensitiveHelpPage = 'setup';
    Permissions = TableData "Guided Experience Item" = r;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec."Short Title")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the manual setup.';
                }
                field(ExtensionName; Rec."Extension Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the extension which has added this setup.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the manual setup.';
                }
                field(Category; Rec."Manual Setup Category")
                {
                    ApplicationArea = All;
                    Caption = 'Category';
                    ToolTip = 'Specifies the category enum to which the setup belongs';
                }
                field(Keywords; Rec.Keywords)
                {
                    ApplicationArea = All;
                    Caption = 'Keywords';
                    ToolTip = 'Specifies which keywords relate to the manual setup on the line.';
                }
                field(ExpectedDuration; Rec."Expected Duration")
                {
                    ApplicationArea = All;
                    Caption = 'Expected Duration';
                    ToolTip = 'Specifies how long the manual setup will take in minutes.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Open Manual Setup")
            {
                ApplicationArea = All;
                Caption = 'Open Manual Setup';
                Image = Edit;
                Scope = Repeater;
                ShortCutKey = 'Return';
                ToolTip = 'View or edit the setup for the application feature.';
                Enabled = (Rec."Object Type to Run" = Rec."Object Type to Run"::Page) and (Rec."Object ID to Run" <> 0);

                trigger OnAction()
                begin
                    if (Rec."Object Type to Run" = Rec."Object Type to Run"::Page) and (Rec."Object ID to Run" <> 0) then
                        Page.Run(Rec."Object ID to Run");
                end;
            }
        }
    }

    var
        ManualSetupCategory: Enum "Manual Setup Category";
        FilterSet: Boolean;

    trigger OnOpenPage()
    var
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.OnRegisterManualSetup();
        GuidedExperienceImpl.GetContentForSetupPage(Rec, Rec."Guided Experience Type"::"Manual Setup");

        if FilterSet then
            Rec.SetRange("Manual Setup Category", ManualSetupCategory);
    end;

    internal procedure SetCategoryToDisplay(ManualSetupCategoryValue: Enum "Manual Setup Category")
    begin
        FilterSet := true;
        ManualSetupCategory := ManualSetupCategoryValue;
    end;
}


