// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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
                    ToolTip = 'The email scenario.';
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

    trigger OnOpenPage()
    begin
        EmailScenario.GetAvailableScenariosForAccount(Rec, Rec);
        Rec.SetCurrentKey("Display Name");
        if Rec.FindFirst() then; // set the selection to the first record
    end;

    var
        EmailScenario: Codeunit "Email Scenario Impl.";
}