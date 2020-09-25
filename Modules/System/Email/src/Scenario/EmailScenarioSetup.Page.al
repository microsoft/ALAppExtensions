// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Page is used to display email scenarios usage by email accounts.
/// </summary>
page 8893 "Email Scenario Setup"
{
    Caption = 'Email Scenario Assignment';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    Extensible = false;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Email Account Scenario";
    InstructionalText = 'Assign email scenarios';

    layout
    {
        area(Content)
        {
            repeater(ScenariosByEmail)
            {
                IndentationColumn = Indentation;
                IndentationControls = Name;
                ShowAsTree = true;

                field(Name; Rec."Display Name")
                {
                    ApplicationArea = All;
                    Caption = 'Scenarios by email accounts';
                    ToolTip = 'Specifies the scenarios that are using the email account.';
                    Editable = false;
                    StyleExpr = Style;
                }

                field(Default; DefaultTxt)
                {
                    ApplicationArea = All;
                    Caption = 'Default';
                    ToolTip = 'Specifies whether this is the default account to use for scenarios when no other account is specified.';
                    StyleExpr = Style;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Account)
            {
                action(AddScenario)
                {
                    Visible = TypeOfEntry = TypeOfEntry::Account;

                    ApplicationArea = All;
                    Caption = 'Assign scenarios';
                    ToolTip = 'Assign email scenarios for the selected email account. When assigned, everyone will use the account for the scenario. For example, if you assign the Sales Order scenario, everyone will use the account to send sales orders.';
                    Image = NewDocument;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Scope = Repeater;

                    trigger OnAction()
                    begin
                        if EmailScenarioImpl.AddScenarios(Rec) then
                            EmailScenarioImpl.GetScenariosByEmailAccount(Rec);
                    end;
                }
            }

            group(Scenario)
            {
                action(ChangeAccount)
                {
                    Visible = TypeOfEntry = TypeOfEntry::Scenario;

                    ApplicationArea = All;
                    Caption = 'Reassign';
                    ToolTip = 'Reassign the selected scenarios to another email account.';
                    Image = Change;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Scope = Repeater;

                    trigger OnAction()
                    begin
                        CurrPage.SetSelectionFilter(Rec);

                        if EmailScenarioImpl.ChangeAccount(Rec) then
                            EmailScenarioImpl.GetScenariosByEmailAccount(Rec); // refresh the data on the page
                    end;
                }

                action(Unassign)
                {
                    Visible = TypeOfEntry = TypeOfEntry::Scenario;

                    ApplicationArea = All;
                    Caption = 'Unassign';
                    ToolTip = 'Unassign the selected scenarios. Afterward, the default email account will be used to send emails for the scenarios.';
                    Image = Delete;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Scope = Repeater;

                    trigger OnAction()
                    begin
                        CurrPage.SetSelectionFilter(Rec);

                        if EmailScenarioImpl.DeleteScenario(Rec) then
                            EmailScenarioImpl.GetScenariosByEmailAccount(Rec); // refresh the data on the page
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        EmailScenarioImpl.GetScenariosByEmailAccount(Rec);
    end;

    trigger OnAfterGetRecord()
    begin
        DefaultTxt := '';

        TypeOfEntry := Rec.EntryType;

        if TypeOfEntry = TypeOfEntry::Account then begin
            Indentation := 0;
            Style := 'Strong';
            if Rec.Default then
                DefaultTxt := '✓'
        end;

        if TypeOfEntry = TypeOfEntry::Scenario then begin
            Indentation := 1;
            Style := 'Standard';
        end;
    end;

    var
        EmailScenarioImpl: Codeunit "Email Scenario Impl.";
        Style, DefaultTxt : Text;
        TypeOfEntry: Option Account,Scenario;
        Indentation: Integer;
}