// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.AI;

/// <summary>
/// Page for listing the Copilot Capabilities which are in Preview.
/// </summary>
page 7773 "Copilot Capabilities Preview"
{
    PageType = ListPart;
    ApplicationArea = All;
    InsertAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    Extensible = false;
    SourceTable = "Copilot Settings";
    SourceTableView = where(Availability = const(Preview));
    Permissions = tabledata "Copilot Settings" = rm;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            repeater(Capabilities)
            {
                field(Capability; Rec.Capability)
                {
                    ApplicationArea = All;
                    Caption = 'Capability';
                    ToolTip = 'Specifies the Copilot capability''s name.';
                    Editable = false;
                    Width = 30;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    ToolTip = 'Specifies if the Copilot is active and can be used in this environment.';
                    StyleExpr = StatusStyleExpr;

                    trigger OnValidate()
                    begin
                        SetStatusStyle();
                    end;
                }
                field(Publisher; Rec.Publisher)
                {
                    ApplicationArea = All;
                    Caption = 'Publisher';
                    ToolTip = 'Specifies the publisher of this Copilot.';
                    Editable = false;
                }
                field("Learn More"; LearnMore)
                {
                    ApplicationArea = All;
                    Caption = ' ';
#pragma warning disable AA0219
                    ToolTip = 'Opens the Copilot''s url to learn more about the capability.';
#pragma warning restore AA0219
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        if Rec."Learn More Url" <> '' then
                            Hyperlink(Rec."Learn More Url");
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Activate)
            {
                Caption = 'Activate';
                ToolTip = 'Activates the selected Copilot Capability.';
                Image = Start;
                Enabled = ActionsEnabled and not CapabilityEnabled;
                Visible = ActionsEnabled and not CapabilityEnabled;
                Scope = Repeater;

                trigger OnAction()
                begin
                    Rec.Status := Rec.Status::Active;
                    Rec.Modify(true);

                    CopilotCapabilityImpl.SendActivateTelemetry(Rec.Capability, Rec."App Id");
                end;
            }
            action(Deactivate)
            {
                Caption = 'Deactivate';
                ToolTip = 'Deactivates the selected Copilot Capability.';
                Image = Stop;
                Enabled = ActionsEnabled and CapabilityEnabled;
                Visible = ActionsEnabled and CapabilityEnabled;
                Scope = Repeater;

                trigger OnAction()
                var
                    CopilotDeactivate: Page "Copilot Deactivate Capability";
                begin
                    CopilotDeactivate.SetCaption(Format(Rec.Capability));
                    if CopilotDeactivate.RunModal() = Action::OK then begin
                        Rec.Status := Rec.Status::Inactive;
                        Rec.Modify(true);

                        CopilotCapabilityImpl.SendDeactivateTelemetry(Rec.Capability, Rec."App Id", CopilotDeactivate.GetReason());
                    end;
                end;
            }
            action(SupplementalTerms)
            {
                Caption = 'Supplemental Terms of Use';
                ToolTip = 'Opens the supplemental terms of use for production ready preview capabilities.';
                Image = Info;

                trigger OnAction()
                begin
                    Hyperlink(SupplementalTermsLinkTxt);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Rec."Learn More Url" <> '' then
            LearnMore := LearnMoreLbl
        else
            LearnMore := '';

        SetStatusStyle();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetStatusStyle();
        SetActionsEnabled();
    end;

    var
        CopilotCapabilityImpl: Codeunit "Copilot Capability Impl";
        StatusStyleExpr: Text;
        LearnMore: Text;
        LearnMoreLbl: Label 'Learn More';
        SupplementalTermsLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2227013', Locked = true;
        ActionsEnabled: Boolean;
        CapabilityEnabled: Boolean;
        DataMovementEnabled: Boolean;

    internal procedure SetDataMovement(Value: Boolean)
    begin
        DataMovementEnabled := Value;
        SetActionsEnabled();
        CurrPage.Update(false);
    end;

    local procedure SetStatusStyle()
    begin
        if (Rec.Status = Rec.Status::Active) then
            StatusStyleExpr := 'Favorable'
        else
            StatusStyleExpr := '';
    end;

    local procedure SetActionsEnabled()
    begin
        if CopilotCapabilityImpl.IsAdmin() then begin
            ActionsEnabled := (Rec.Capability.AsInteger() <> 0) and DataMovementEnabled;
            CapabilityEnabled := Rec.Status = Rec.Status::Active;
        end
        else begin
            ActionsEnabled := false;
            CapabilityEnabled := false;
        end;
    end;
}