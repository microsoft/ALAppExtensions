// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>This page shows all registered manual setups.</summary>
page 1875 "Manual Setup"
{
    Extensible = false;
    AccessByPermission = TableData "Manual Setup" = R;
    ApplicationArea = All;
    Caption = 'Manual Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Manual Setup";
    SourceTableTemporary = true;
    UsageCategory = Administration;
    ContextSensitiveHelpPage = 'setup';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Name)
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
                field(Category; Category)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the category enum to which the setup belongs';
                }
                field(Keywords; Keywords)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which keywords relate to the manual setup on the line.';
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

                trigger OnAction()
                begin
                    if "Setup Page ID" <> 0 then
                        Page.Run("Setup Page ID");
                end;
            }
        }
    }

    var
        ManualSetupCategory: Enum "Manual Setup Category";
        FilterSet: Boolean;

    trigger OnOpenPage()
    var
        ManualSetup: Codeunit "Manual Setup";
    begin
        ManualSetup.OnRegisterManualSetup();
        ManualSetup.GetTemporaryRecord(Rec);
        if FilterSet then
            SetRange(Category, ManualSetupCategory);
    end;

    internal procedure SetCategoryToDisplay(ManualSetupCategoryValue: Enum "Manual Setup Category")
    begin
        FilterSet := true;
        ManualSetupCategory := ManualSetupCategoryValue;
    end;
}

