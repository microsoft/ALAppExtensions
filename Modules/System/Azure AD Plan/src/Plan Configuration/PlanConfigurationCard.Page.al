// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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

    trigger OnAfterGetCurrRecord()
    var
        PlanConfigurationImpl: Codeunit "Plan Configuration Impl.";
    begin
        CurrPage.DefaultPermissionSets.Page.Refresh(Rec."Plan ID");
        CurrPage.CustomPermissionSets.Page.SetPlanId(Rec."Plan ID");

        PlanConfigurationImpl.ShowCustomPermissionsEffectNotification(Rec);
        CurrPage.Update(false);
    end;
}