// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

/// <summary>
/// View and edit the permission sets associated with a security group.
/// </summary>
page 9868 "Security Group Permission Sets"
{
    DataCaptionExpression = PageCaptionExpression;
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
                    Lookup = true;
                    LookupPageId = "Lookup Permission Set";

                    trigger OnAfterLookup(Selected: RecordRef)
                    var
                        AggregatePermissionSet: Record "Aggregate Permission Set";
                    begin
                        AggregatePermissionSet.Get(Selected.RecordId);
                        Rec.Scope := AggregatePermissionSet.Scope;
                        Rec."App ID" := AggregatePermissionSet."App ID";
                        Rec."Role Name" := AggregatePermissionSet.Name;
                    end;
                }
                field("Role Name"; Rec."Role Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Name';
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
                Caption = 'Add multiple';
                Ellipsis = true;
                Image = NewItem;
                ToolTip = 'Add two or more permission sets.';

                trigger OnAction()
                var
                    TempAggregatePermissionSet: Record "Aggregate Permission Set" temporary;
                    AccessControl: Record "Access Control";
                    PermissionSetRelation: Codeunit "Permission Set Relation";
                begin
                    if not PermissionSetRelation.LookupPermissionSet(true, TempAggregatePermissionSet) then
                        exit;

                    if TempAggregatePermissionSet.FindSet() then
                        repeat
                            if not AccessControl.Get(Rec."User Security ID", TempAggregatePermissionSet."Role ID", '', TempAggregatePermissionSet.Scope, TempAggregatePermissionSet."App ID") then begin
                                AccessControl."User Security ID" := Rec."User Security ID";
                                AccessControl."Role ID" := TempAggregatePermissionSet."Role ID";
                                AccessControl.Scope := TempAggregatePermissionSet.Scope;
                                AccessControl."App ID" := TempAggregatePermissionSet."App ID";
                                AccessControl.Insert();
                            end;
                        until TempAggregatePermissionSet.Next() = 0;
                end;
            }
        }
        area(Promoted)
        {
            group(Category_New)
            {
                Caption = 'New';
                ShowAs = SplitButton;

                actionref(SelectPermissionSets_Promoted; SelectPermissionSets)
                {
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        exit(Rec."Role ID" <> '');
    end;

    trigger OnModifyRecord(): Boolean
    begin
        Rec.TestField("Role ID");
    end;

    internal procedure SetGroupCode(GroupCode: Code[20])
    begin
        PageCaptionExpression := GroupCode;
    end;

    var
        PageCaptionExpression: Text;
}

