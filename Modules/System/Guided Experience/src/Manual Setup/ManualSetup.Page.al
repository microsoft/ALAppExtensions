// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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
                field(Name; "Short Title")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the manual setup.';
                }
                field(ExtensionName; "Extension Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the extension which has added this setup.';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the manual setup.';
                }
                field(Category; "Manual Setup Category")
                {
                    ApplicationArea = All;
                    Caption = 'Category';
                    ToolTip = 'Specifies the category enum to which the setup belongs';
                }
                field(Keywords; Keywords)
                {
                    ApplicationArea = All;
                    Caption = 'Keywords';
                    ToolTip = 'Specifies which keywords relate to the manual setup on the line.';
                }
                field(ExpectedDuration; "Expected Duration")
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
                Enabled = ("Object Type to Run" = "Object Type to Run"::Page) and ("Object ID to Run" <> 0);

                trigger OnAction()
                begin
                    if ("Object Type to Run" = "Object Type to Run"::Page) and ("Object ID to Run" <> 0) then
                        Page.Run("Object ID to Run");
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
#if not CLEAN18
#pragma warning disable AL0432
        ManualSetup: Codeunit "Manual Setup";
#pragma warning restore
#endif
    begin
        GuidedExperience.OnRegisterManualSetup();
#if not CLEAN18
#pragma warning disable AL0432
        ManualSetup.OnRegisterManualSetup();
#pragma warning restore
#endif

        GuidedExperienceImpl.GetContentForSetupPage(Rec, Rec."Guided Experience Type"::"Manual Setup");

        if FilterSet then
            SetRange("Manual Setup Category", ManualSetupCategory);
    end;

    internal procedure SetCategoryToDisplay(ManualSetupCategoryValue: Enum "Manual Setup Category")
    begin
        FilterSet := true;
        ManualSetupCategory := ManualSetupCategoryValue;
    end;
}

