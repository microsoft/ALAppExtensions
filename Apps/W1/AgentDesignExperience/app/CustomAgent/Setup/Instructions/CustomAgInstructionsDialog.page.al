// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

page 4354 "Custom Ag. Instructions Dialog"
{
    PageType = StandardDialog;
    ApplicationArea = All;
    InherentEntitlements = X;
    InherentPermissions = X;
    Caption = 'Agent instructions';

    layout
    {
        area(Content)
        {
            part(InstructionsPart; "Custom Agent Instructions Part")
            {
                ApplicationArea = All;
            }
        }
    }

    procedure SetUserSecurityId(NewUserSecId: Guid)
    begin
        CurrPage.InstructionsPart.Page.SetUserSecurityId(NewUserSecId);
    end;

    procedure GetInstructions(): Text
    begin
        exit(CurrPage.InstructionsPart.Page.GetInstructions());
    end;

    procedure SetInstructions(NewInstructions: Text): Text
    begin
        CurrPage.InstructionsPart.Page.SetInstructions(NewInstructions);
    end;

    procedure SetReadOnlyMode(NewIsReadOnly: Boolean)
    begin
        CurrPage.InstructionsPart.Page.SetReadOnlyMode(NewIsReadOnly);
        if NewIsReadOnly then
            CurrPage.Caption(ViewAgentInstructionsLbl)
        else
            CurrPage.Caption(EditAgentInstructionsLbl);
    end;

    procedure SetIsTemporary(NewIsTemporary: Boolean)
    begin
        CurrPage.InstructionsPart.Page.SetIsTemporary(NewIsTemporary);
    end;

    var
        EditAgentInstructionsLbl: Label 'Edit agent instructions';
        ViewAgentInstructionsLbl: Label 'View agent instructions';
}
