// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// List page that hold the custom user groups assigned to a plan.
/// </summary>
page 9059 "Custom User Groups In Plan"
{
    Caption = 'Custom User Group In License';
    PageType = ListPart;
    SourceTable = "Custom User Group In Plan";
    DelayedInsert = true;
    Editable = true;
    Permissions = tabledata "Custom User Group In Plan" = rimd;
    Extensible = false;

    layout
    {
        area(content)
        {
            group("Assigned User Groups")
            {
                ShowCaption = false;
                repeater(Group)
                {
                    field("User Group"; Rec."User Group Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Code';
                        ToolTip = 'Specifies the ID of the user group.';
                        NotBlank = true;
                    }
                    field("User Group Name"; Rec."User Group Name")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Caption = 'Name';
                        ToolTip = 'Specifies the name of the user group.';
                    }
                    field("Company"; Rec."Company Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Company';
                        ToolTip = 'Specifies the company that the user group will have access to.';
                    }
                }
            }
        }
    }

    internal procedure SetPlanId(PlanId: Guid)
    begin
        LocalPlanId := PlanId;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Plan ID" := LocalPlanId;
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.Update(false);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        CurrPage.Update(false);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        CurrPage.Update(false);
    end;

    var
        LocalPlanId: Guid;
}