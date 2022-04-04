// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// List page that contains all plans that can be assigned to users.
/// </summary>
page 9824 Plans
{
    Caption = 'Plans';
    Editable = false;
    Extensible = false;
    LinksAllowed = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = Plan;
    ContextSensitiveHelpPage = 'ui-how-users-permissions';
    Permissions = tabledata Plan = r;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the plan.';
                }
            }
        }
        area(factboxes)
        {
            part("Users in the Plan"; "User Plan Members FactBox")
            {
                Caption = 'Users in Plan';
                ApplicationArea = All;
                SubPageLink = "Plan ID" = field("Plan ID");
            }
        }
    }

    /// <summary>
    /// Set selected plan when the page is used in lookup mode.
    /// </summary>
    /// <param name="PlanId">The ID of the plan to select.</param>
    procedure SetSelectedPlan(PlanId: Guid)
    var
        SelectedPlan: Record Plan;
    begin
        if SelectedPlan.Get(PlanId) then
            CurrPage.SetRecord(SelectedPlan);
    end;

    /// <summary>
    /// Gets the selected plan.
    /// </summary>
    /// <param name="PlanId">The ID of the selected plan.</param>
    /// <param name="PlanName">The name of the selected plan.</param>
    procedure GetSelectedPlan(var PlanId: Guid; var PlanName: Text[50])
    var
        SelectedPlan: Record Plan;
    begin
        CurrPage.GetRecord(SelectedPlan);

        PlanId := SelectedPlan."Plan ID";
        PlanName := SelectedPlan.Name
    end;

}

