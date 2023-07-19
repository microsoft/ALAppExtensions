// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// View and edit the permission sets associated with a security group.
/// </summary>
page 9868 "Security Group Permission Sets"
{
    DataCaptionExpression = PageCaption;
    PageType = List;
    SourceTable = "Access Control";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Role ID"; Rec."Role ID")
                {
                    Caption = 'Permission Set';
                    ApplicationArea = All;
                    Editable = true;
                    NotBlank = true;
                    ToolTip = 'Specifies a permission set that defines the role.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        TempAggregatePermissionSet: Record "Aggregate Permission Set" temporary;
                        SecurityGroupImpl: Codeunit "Security Group Impl.";
                    begin
                        if SecurityGroupImpl.LookupPermissionSet(false, Rec, TempAggregatePermissionSet) then begin
                            Text := Rec."Role ID";
                            AppRoleName := TempAggregatePermissionSet.Name;
                        end;
                    end;

                    trigger OnValidate()
                    var
                        AggregatePermissionSet: Record "Aggregate Permission Set";
                    begin
                        AggregatePermissionSet.SetRange("Role ID", Rec."Role ID");
                        AggregatePermissionSet.FindFirst();
                        Rec.Scope := AggregatePermissionSet.Scope;
                        Rec."App ID" := AggregatePermissionSet."App ID";
                        Rec.CalcFields("Role Name");
                        AppRoleName := AggregatePermissionSet.Name;
                    end;
                }
                field("Role Name"; AppRoleName)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Description';
                    ToolTip = 'Specifies the name of the permission set.';
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'Company';
                    ToolTip = 'Specifies the company name for the permission set.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(SelectPermissionSets)
            {
                ApplicationArea = All;
                Caption = 'Select Permission Sets';
                Ellipsis = true;
                Image = NewItem;
                ToolTip = 'Add two or more permission sets.';

                trigger OnAction()
                var
                    TempAggregatePermissionSet: Record "Aggregate Permission Set" temporary;
                    AccessControl: Record "Access Control";
                    SecurityGroupImpl: Codeunit "Security Group Impl.";
                begin
                    if not SecurityGroupImpl.LookupPermissionSet(true, AccessControl, TempAggregatePermissionSet) then
                        exit;

                    if TempAggregatePermissionSet.FindSet() then
                        repeat
                            if not AccessControl.Get(Rec."User Security ID", AccessControl."Role ID", '', AccessControl.Scope, AccessControl."App ID") then begin
                                AccessControl."User Security ID" := Rec."User Security ID";
                                AccessControl.Insert();
                            end;
                        until TempAggregatePermissionSet.Next() = 0;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Rec.Scope = Rec.Scope::Tenant then begin
            if TenantPermissionSetRec.Get(Rec."App ID", Rec."Role ID") then
                AppRoleName := TenantPermissionSetRec.Name
        end else
            if PermissionSetRec.Get(Rec."Role ID") then
                AppRoleName := PermissionSetRec.Name;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        exit(Rec."Role ID" <> '');
    end;

    trigger OnModifyRecord(): Boolean
    begin
        Rec.TestField("Role ID");
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        AppRoleName := '';
    end;

    internal procedure SetGroupCode(GroupCode: Code[20])
    begin
        PageCaption := GroupCode;
    end;

    var
        PermissionSetRec: Record "Permission Set";
        TenantPermissionSetRec: Record "Tenant Permission Set";
        AppRoleName: Text[30];
        PageCaption: Text;
}

