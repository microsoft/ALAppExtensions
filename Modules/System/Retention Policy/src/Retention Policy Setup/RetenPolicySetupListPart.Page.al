// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This page lists all of the retention policies that have been defined.
/// </summary>
page 3905 "Reten. Policy Setup ListPart"
{
    PageType = ListPart;
    Caption = 'Retention Policies';
    SourceTable = "Retention Policy Setup";
    CardPageId = "Retention Policy Setup Card";
    Editable = false;
    RefreshOnActivate = true;
    PromotedActionCategories = 'New, Process, Report, Navigate';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the table to which the retention policy applies.';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the table to which the retention policy applies.';
                    Visible = false;
                }
                field("Table Caption"; Rec."Table Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the caption of the table to which the retention policy applies. The caption is the translated, if applicable, name of the table.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the retention policy is enabled.';
                }
                field(Manual; Rec.Manual)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the retention policy can only be run manually.';
                }
                field("Retention Period"; Rec."Retention Period")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an identifier for the retention period.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ApplyManually)
            {
                Caption = 'Apply Manually';
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = TestDatabase;
                ToolTip = 'Apply the retention policy and delete all expired records in the table.';

                trigger OnAction()
                var
                    ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
                begin
                    ApplyRetentionPolicy.ApplyRetentionPolicy(Rec, true);
                end;
            }
            action(ApplyAll)
            {
                Caption = 'Apply All';
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = TestDatabase;
                ToolTip = 'Apply all non-manual and enabled retention policies now and delete any expired records.';

                trigger OnAction()
                var
                    ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
                begin
                    ApplyRetentionPolicy.ApplyRetentionPolicy(true);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000FVY', 'Retention policies', Enum::"Feature Uptake Status"::Discovered);
    end;
}