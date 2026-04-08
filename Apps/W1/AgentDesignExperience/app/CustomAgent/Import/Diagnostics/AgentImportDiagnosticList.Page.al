// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

page 4357 "Agent Import Diagnostic List"
{
    ApplicationArea = All;
    PageType = List;
    Caption = 'Validation Details';
    SourceTable = "Agent Import Diagnostic";
    SourceTableTemporary = true;
    Extensible = false;
    Editable = false;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(Severity; Rec.Severity)
                {
                    Editable = false;
                    ToolTip = 'Specifies the severity level of this validation message.';
                    StyleExpr = SeverityStyle;
                    Width = 5;
                }
                field(Message; Rec.Message)
                {
                    Editable = false;
                    ToolTip = 'Specifies the validation message details.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateSeverityStyle();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateSeverityStyle();
    end;

    internal procedure SetDiagnosticsForAgent(var TempAllDiagnostics: Record "Agent Import Diagnostic" temporary; AgentName: Text[50]; AgentInitials: Text[4])
    begin
        ResetControls();

        TempAllDiagnostics.SetRange("Agent Name", AgentName);
        TempAllDiagnostics.SetRange("Agent Initials", AgentInitials);
        TempAllDiagnostics.SetFilter(Severity, '<>%1', TempAllDiagnostics.Severity::Hidden);

        if TempAllDiagnostics.FindSet() then
            repeat
                Rec.Copy(TempAllDiagnostics);
                Rec.Insert();
            until TempAllDiagnostics.Next() = 0;

        CurrPage.Update(false);
    end;

    local procedure ResetControls()
    begin
        Rec.Reset();
        Rec.DeleteAll();
    end;

    local procedure UpdateSeverityStyle()
    begin
        case Rec.Severity of
            Rec.Severity::Error:
                SeverityStyle := Format(PageStyle::Attention);
            Rec.Severity::Warning:
                SeverityStyle := Format(PageStyle::AttentionAccent);
            Rec.Severity::Information:
                SeverityStyle := Format(PageStyle::Favorable);
            else
                SeverityStyle := Format(PageStyle::Standard);
        end;
    end;

    var
        SeverityStyle: Text;
}