// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

/// <summary>
/// Displays the scenarios that could be linked to a provided file account.
/// </summary>
page 70004 "File Scenarios for Account"
{
    PageType = List;
    Extensible = false;
    SourceTable = "File Account Scenario";
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
            repeater(ScenariosByFile)
            {
                field(Name; Rec."Display Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'The file scenario.';
                    Caption = 'File scenario';
                    Editable = false;
                }
            }
        }
    }

    internal procedure GetSelectedScenarios(var ResultFileAccountScenario: Record "File Account Scenario")
    begin
        ResultFileAccountScenario.Reset();
        ResultFileAccountScenario.DeleteAll();

        CurrPage.SetSelectionFilter(Rec);

        if not Rec.FindSet() then
            exit;

        repeat
            ResultFileAccountScenario.Copy(Rec);
            ResultFileAccountScenario.Insert();
        until Rec.Next() = 0;
    end;

    trigger OnOpenPage()
    begin
        FileScenarioImpl.GetAvailableScenariosForAccount(Rec, Rec);
        Rec.SetCurrentKey("Display Name");
        if Rec.FindFirst() then; // set the selection to the first record
    end;

    var
        FileScenarioImpl: Codeunit "File Scenario Impl.";
}