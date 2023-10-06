// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Identity;

using System.Environment;

/// <summary>
/// Card page to show the permissions for a plan configuration.
/// </summary>
page 9069 "Plan Configuration Card"
{
    DataCaptionExpression = Rec."Plan Name";
    Caption = 'License Configuration';
    Editable = true;
    PageType = Card;
    SourceTable = "Plan Configuration";
    Extensible = true;
    Permissions = tabledata "Plan Configuration" = rimd;
    ContextSensitiveHelpPage = 'ui-how-users-permissions#licensespermissions';
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            grid(GeneralGrid)
            {
                group(General)
                {
                    ShowCaption = false;

                    field(SelectedPlan; Rec."Plan Name")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Importance = Promoted;
                        Caption = 'License';
                        ToolTip = 'Specifies the license that grants access to Business Central.';
                    }

                    field(Customized; Rec.Customized)
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        Caption = 'Customize permissions';
                        ToolTip = 'Specifies whether the default permissions are customized.';
                    }
                }
            }

            part(DefaultPermissionSets; "Default Permission Set In Plan")
            {
                ApplicationArea = All;
                Caption = 'Default Permission Sets';
                Editable = false;
                Enabled = false;
                Visible = not Rec.Customized;
                SubPageLink = "Plan ID" = field("Plan ID");
            }

            part(CustomPermissionSets; "Custom Permission Set In Plan")
            {
                ApplicationArea = All;
                Caption = 'Custom Permission Sets';
                Visible = Rec.Customized;
                SubPageLink = "Plan ID" = field("Plan ID");
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref(BCAdminCenter_Promoted; BCAdminCenter)
            {
            }

            actionref(M365AdminCenter_Promoted; M365AdminCenter)
            {
            }
        }

        area(Navigation)
        {
            action(BCAdminCenter)
            {
                ApplicationArea = All;
                Caption = 'Business Central admin center', Locked = true;
                Image = Setup;
                ToolTip = 'Manage security groups and license-related features for each environment.';
                Visible = IsSaaS;

                trigger OnAction()
                var
                    PlanConfigurationImpl: Codeunit "Plan Configuration Impl.";
                begin
                    PlanConfigurationImpl.OpenBCAdminCenter();
                end;
            }

            action(M365AdminCenter)
            {
                ApplicationArea = All;
                Caption = 'Microsoft 365 admin center', Locked = true;
                Image = Setup;
                ToolTip = 'Assign licenses to existing users or create new users.';


                trigger OnAction()
                var
                    PlanConfigurationImpl: Codeunit "Plan Configuration Impl.";
                begin
                    PlanConfigurationImpl.OpenM365AdminCenter();
                end;
            }
        }
    }

    var
        IsSaaS: Boolean;

    trigger OnAfterGetCurrRecord()
    var
        PlanConfigurationImpl: Codeunit "Plan Configuration Impl.";
    begin
#if not CLEAN22
        CurrPage.DefaultPermissionSets.Page.Refresh(Rec."Plan ID");
#endif
        CurrPage.CustomPermissionSets.Page.SetPlanId(Rec."Plan ID");

        PlanConfigurationImpl.ShowCustomPermissionsEffectNotification(Rec);
        CurrPage.Update(false);
    end;

    trigger OnInit()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        IsSaaS := EnvironmentInformation.IsSaaS();
    end;

    procedure SetPlan(PlanId: Guid)
    begin
        Rec.SetRange("Plan ID", PlanId);
    end;
}