// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// List part that holds the custom permission sets assigned to a plan.
/// </summary>
page 9058 "Custom Permission Set In Plan"
{
    Caption = 'Permission Set Plan Assignment';
    PageType = ListPart;
    DelayedInsert = true;
    SourceTable = "Custom Permission Set In Plan";
    Editable = true;
    Permissions = tabledata "Custom Permission Set In Plan" = rimd,
                  tabledata "Published Application" = r,
                  tabledata "Permission Set" = r;

    layout
    {
        area(content)
        {
            group("Assigned Permission Sets")
            {
                ShowCaption = false;

                repeater(Group)
                {
                    field("Plan Id"; Rec."Plan Id")
                    {
                        ApplicationArea = All;
                        Visible = false;
                        Editable = false;
                        Caption = 'License';
                        ToolTip = 'Specifies the ID of the license.';
                    }

                    field(PermissionSetId; Rec."Role ID")
                    {
                        ApplicationArea = All;
                        Caption = 'Permission Set';
                        ToolTip = 'Specifies the ID of the permission set that will be assigned to users with this license.';
                        Style = Unfavorable;
                        StyleExpr = PermissionSetNotFound;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            PermissionSetLookupRecord: Record "Aggregate Permission Set";
                            LookupPermissionSet: Page "Lookup Permission Set";
                        begin
                            LookupPermissionSet.LookupMode := true;
                            if LookupPermissionSet.RunModal() = ACTION::LookupOK then begin
                                LookupPermissionSet.GetRecord(PermissionSetLookupRecord);
                                Rec.Scope := PermissionSetLookupRecord.Scope;
                                Rec."App ID" := PermissionSetLookupRecord."App ID";
                                Rec."Role ID" := PermissionSetLookupRecord."Role ID";
                                Rec.CalcFields("App Name", "Role Name");
                                SkipValidation := true;
                                PermissionScope := Format(PermissionSetLookupRecord.Scope);
                            end;
                        end;

                        trigger OnValidate()
                        var
                            AggregatePermissionSet: Record "Aggregate Permission Set";
                        begin
                            // If the user used the lookup, skip validation
                            if SkipValidation then begin
                                SkipValidation := false;
                                exit;
                            end;

                            // Get the Scope and App ID for a matching Role ID
                            AggregatePermissionSet.SetRange("Role ID", "Role ID");
                            AggregatePermissionSet.FindFirst();

                            if AggregatePermissionSet.Count > 1 then
                                Error(MultipleRoleIDErr, Rec."Role ID");

                            Rec.Scope := AggregatePermissionSet.Scope;
                            Rec."App ID" := AggregatePermissionSet."App ID";
                            PermissionScope := Format(AggregatePermissionSet.Scope);

                            Rec.CalcFields("App Name", "Role Name");

                            SkipValidation := false; // re-enable validation
                        end;
                    }
                    field(Description; Rec."Role Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Description';
                        DrillDown = false;
                        Editable = false;
                        ToolTip = 'Specifies the description of the permission set.';
                    }
                    field(Company; Rec."Company Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Company';
                        ToolTip = 'Specifies the name of the company that this permission set is limited to for this plan.';
                    }
                    field(ExtensionName; Rec."App Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Extension Name';
                        DrillDown = false;
                        Editable = false;
                        ToolTip = 'Specifies the name of the extension from which the permission set originates.';
                    }
                    field(PermissionScope; PermissionScope)
                    {
                        ApplicationArea = All;
                        Caption = 'Permission Scope';
                        Editable = false;
                        ToolTip = 'Specifies the scope of the permission set.';
                    }
                }
            }
        }
    }

    internal procedure SetPlanId(PlanId: Guid)
    begin
        LocalPlanId := PlanId;
    end;

    trigger OnAfterGetRecord()
    var
        AggregatePermissionSet: Record "Aggregate Permission Set";
    begin
        PermissionScope := Format(Rec.Scope);

        PermissionSetNotFound := false;
        if not (Rec."Role ID" in ['SUPER', 'SECURITY']) then
            PermissionSetNotFound := not AggregatePermissionSet.Get(Rec.Scope, Rec."App ID", Rec."Role ID");
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec."Plan ID" := LocalPlanId;
        Rec.CalcFields("App Name", "Role Name");
    end;

    trigger OnModifyRecord(): Boolean
    begin
        Rec.CalcFields("App Name", "Role Name");
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.CalcFields("App Name", "Role Name");
        PermissionScope := '';
    end;

    trigger OnAfterGetCurrRecord()
    begin
        Rec.CalcFields("App Name", "Role Name");
    end;

    var
        MultipleRoleIDErr: Label 'The permission set %1 is defined multiple times in this context. Use the lookup button to select the relevant permission set.', Comment = '%1 will be replaced with a Role ID code value from the Permission Set table';
        LocalPlanId: Guid;
        SkipValidation: Boolean;
        PermissionScope: Text;
        [InDataSet]
        PermissionSetNotFound: Boolean;
}