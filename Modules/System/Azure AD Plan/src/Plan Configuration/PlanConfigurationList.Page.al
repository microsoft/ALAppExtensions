// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// List page to show all available plan configurations.
/// </summary>
page 9061 "Plan Configuration List"
{
    ApplicationArea = All;
    Caption = 'License Configuration';
    PageType = List;
    SourceTable = "Plan Configuration";
    UsageCategory = Administration;
    Extensible = false;
    Permissions = tabledata "Plan Configuration" = rimd;
    ContextSensitiveHelpPage = 'ui-how-users-permissions#licensespermissions';
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Plan Name"; Rec."Plan Name")
                {
                    ApplicationArea = All;
                    Caption = 'License';
                    ToolTip = 'Specifies the name of the license.';
                    Editable = Rec."Plan Name" = '';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Plan Configuration Card", Rec);
                    end;
                }
                field(Customized; Rec.Customized)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Permissions Customized';
                    ToolTip = 'Specifies if the permissions are customized.';
                }
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref(New_Promoted; New)
            {
            }

            actionref(Configure_Promoted; Configure)
            {
            }
        }

        area(Creation)
        {
            action(New)
            {
                ApplicationArea = All;
                Caption = 'Add License Configuration';
                Image = Add;
                ToolTip = 'Add a configuration for a license.';

                trigger OnAction()
                var
                    PlanConfigurationImpl: Codeunit "Plan Configuration Impl.";
                begin
                    PlanConfigurationImpl.AddLicenseEntry();
                end;
            }
        }

        area(Processing)
        {
            action(Configure)
            {
                ApplicationArea = All;
                Caption = 'Configure';
                Image = Setup;
                RunObject = Page "Plan Configuration Card";
                RunPageLink = "Plan ID" = Field("Plan ID");
                Scope = Repeater;
                ToolTip = 'Customize license permissions.';
            }
        }
    }

    trigger OnOpenPage()
    var
        PlanConfiguration: Record "Plan Configuration";
        PlanConfigurationImpl: Codeunit "Plan Configuration Impl.";
    begin
        PlanConfiguration.SetRange(Customized, false);

        if not PlanConfiguration.IsEmpty() then
            PlanConfigurationImpl.ShowDefaultConfigurationNotification();
    end;
}
