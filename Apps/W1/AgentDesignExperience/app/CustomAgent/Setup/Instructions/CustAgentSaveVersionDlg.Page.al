// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

page 4355 "Cust. Agent Save Version Dlg"
{
    ApplicationArea = All;
    PageType = ConfirmationDialog;
    Caption = 'Save as Version';
    Extensible = false;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            label(InstructionsLbl)
            {
                ApplicationArea = All;
                CaptionClass = InstructionsLbl;
                MultiLine = true;
                ShowCaption = false;
            }
            field(VersionNameField; VersionName)
            {
                ApplicationArea = All;
                Caption = 'Version name';
                ToolTip = 'Specifies the name for the new version of the instructions.';

                trigger OnValidate()
                begin
                    if VersionName = '' then
                        Error(VersionNameRequiredErr);
                end;
            }
            label(ExplanationLbl)
            {
                ApplicationArea = All;
                CaptionClass = ExplanationLbl;
                Style = Subordinate;
                MultiLine = true;
                ShowCaption = false;
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::OK then
            if VersionName = '' then
                Error(VersionNameRequiredErr);
        exit(true);
    end;

    procedure SetVersionName(NewVersionName: Text[100])
    begin
        VersionName := NewVersionName;
    end;

    procedure GetVersionName(): Text[100]
    begin
        exit(VersionName);
    end;

    var
        VersionName: Text[100];
        VersionNameRequiredErr: Label 'You must specify a version name.';
        InstructionsLbl: Label 'Save instructions to history';
        ExplanationLbl: Label 'Instructions are automatically saved to history when you run a task, manual saving is not required. You can still use manual saving to create versions as needed.';
}
