// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

/// <summary>
/// Displays the scenarios that could be linked to a provided e-mail account.
/// </summary>
page 8894 "Email Scenarios for Account"
{
    PageType = List;
    Extensible = false;
    SourceTable = "Email Account Scenario";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    ShowFilter = false;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(ScenariosByEmail)
            {
                field(Name; Rec."Display Name")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the email scenario.';
                    Caption = 'Email scenario';
                    Editable = false;
                }
            }
        }
    }

    internal procedure GetSelectedScenarios(var ResultEmailAccountScenario: Record "Email Account Scenario")
    begin
        ResultEmailAccountScenario.Reset();
        ResultEmailAccountScenario.DeleteAll();

        CurrPage.SetSelectionFilter(Rec);

        if not Rec.FindSet() then
            exit;

        repeat
            ResultEmailAccountScenario.Copy(Rec);
            ResultEmailAccountScenario.Insert();
        until Rec.Next() = 0;
    end;

    internal procedure SetIncludeDefaultEmailScenario(NewIncludeDefaultEmailScenario: Boolean)
    begin
        IncludeDefaultEmailScenario := NewIncludeDefaultEmailScenario;
    end;

    trigger OnOpenPage()
    begin
        EmailScenarioImpl.GetAvailableScenariosForAccount(Rec, Rec, IncludeDefaultEmailScenario);
        Rec.SetCurrentKey("Display Name");
        if Rec.FindFirst() then; // set the selection to the first record
    end;

    var
        EmailScenarioImpl: Codeunit "Email Scenario Impl.";
        IncludeDefaultEmailScenario: Boolean;
}