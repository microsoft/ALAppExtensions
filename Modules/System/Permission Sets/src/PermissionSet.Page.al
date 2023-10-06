// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

using System.Telemetry;

/// <summary>
/// Card page for the permission set.
/// </summary>
page 9855 "Permission Set"
{
    PageType = Card;
    DataCaptionFields = Scope, "Role ID";
    DataCaptionExpression = StrSubstNo(PermissionSetCaptionTok, Rec."Role ID", Rec.Scope);
    SourceTable = "PermissionSet Buffer";
    SourceTableTemporary = true;
    PromotedActionCategories = 'Navigation';
    Caption = 'Permission Set';
    DeleteAllowed = true;
    ModifyAllowed = true;
    InsertAllowed = false;
    AboutTitle = 'About Permission Sets';
    AboutText = 'Permission sets let admins manage multiple permissions for multiple objects in one record.';

    layout
    {
        area(Content)
        {
            group(Description)
            {
                Caption = 'General';

                field("Role ID"; Rec."Role ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Permission Set';
                    ToolTip = 'Specifies the permission set.';
                }

                field("Name"; Rec.Name)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the permission set.';
                }
            }

            part(Permissions; "Tenant Permission Subform")
            {
                ShowFilter = true;
                Visible = IsTenant;
                ApplicationArea = All;
                UpdatePropagation = Both;
                SubPageLink = "Role ID" = field("Role ID"), "App ID" = field("App ID");
            }

            part(MetadataPermissions; "Metadata Permission Subform")
            {
                ShowFilter = true;
                Visible = not IsTenant;
                Editable = false;
                ApplicationArea = All;
                SubPageLink = "Role ID" = field("Role ID"), Type = filter(0);
            }

            group(PermissionSetsGroup)
            {
                ShowCaption = false;

                part(PermissionSets; "Permission Set Subform")
                {
                    Caption = 'Permission Sets';
                    ShowFilter = false;
                    ApplicationArea = All;
                    Editable = IsTenant;
                    UpdatePropagation = Both;
                    AboutText = 'The Permission Sets FastTab lets admins add permission sets to the current set. Admins can exclude specific permission sets for each set. An excluded permission set is excluded in all other permission sets.';
                    AboutTitle = 'About permission sets fasttab';
                }

                part(PermissionSetTree; "Permission Set Tree")
                {
                    Caption = 'Result';
                    ShowFilter = false;
                    ApplicationArea = All;
                    Editable = IsTenant;
                    UpdatePropagation = Both;
                    AboutText = 'The Results FastTab shows the permission set structure after applying the inclusions and exclusions.';
                    AboutTitle = 'About results fasttab';
                }
            }
        }

#if not CLEAN22
        area(factboxes)
        {
            part(PermissionsRelated; "Expanded Permissions Factbox")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'Factbox no longer used. Use the "View Permissions In Set" actions on the Permission Set parts instead.';
                ObsoleteTag = '22.0';
                Visible = false;
                ApplicationArea = All;
                Caption = 'Included permissions';
                ShowFilter = true;
                SubPageLink = "Role ID" = field("Related Role ID"), "App ID" = field("Related App ID");
                Provider = PermissionSetTree;
                AboutTitle = 'About included permissions factbox';
                AboutText = 'The Included permissions FactBox lists the permissions that are included in permissions sets that have been added to this set.';
            }
        }
#endif
    }

    actions
    {
        area(Processing)
        {
            action(AllPermissions)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Permission;
                Caption = 'View all permissions';
                ToolTip = 'View a flat list of the permissions in the set you''re working with and all added sets.';
                RunObject = page "Expanded Permissions";
                RunPageLink = "Role ID" = field("Role ID"), "App ID" = field("App ID");
                AboutTitle = 'About view all permissions';
                AboutText = 'View all permissions gives you the big picture. It opens a flat list of the permissions in the set you''re working with and all added sets';
            }
            group("Record Permissions")
            {
                Caption = 'Record Permissions';
                action(Start)
                {
                    AccessByPermission = tabledata "Tenant Permission" = I;
                    ApplicationArea = All;
                    Caption = 'Start';
                    Enabled = not PermissionLoggingRunning;
                    Image = Start;
                    ToolTip = 'Start recording UI activities to generate the required permissions.';

                    trigger OnAction()
                    begin
                        if not Confirm(StartRecordingQst) then
                            exit;

                        LogTablePermissions.Start();
                        PermissionLoggingRunning := true;
                    end;
                }
                action(Stop)
                {
                    AccessByPermission = tabledata "Tenant Permission" = I;
                    ApplicationArea = All;
                    Caption = 'Stop';
                    Enabled = PermissionLoggingRunning;
                    Image = Stop;
                    ToolTip = 'Stop recording.';

                    trigger OnAction()
                    var
                        TempTablePermissionBuffer: Record "Tenant Permission" temporary;
                    begin
                        LogTablePermissions.Stop(TempTablePermissionBuffer);
                        PermissionLoggingRunning := false;
                        if not Confirm(AddPermissionsQst) then
                            exit;

                        AddLoggedPermissions(TempTablePermissionBuffer);
                        CurrPage.MetadataPermissions.Page.Update(false);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000HZJ', ComposablePermissionSetsTok, Enum::"Feature Uptake Status"::Discovered);
        UpdatePageParts();
    end;

    trigger OnInit()
    var
        AggregatePermissionSet: Record "Aggregate Permission Set";
    begin
        if Rec."Role ID" = '' then begin
            AggregatePermissionSet.FindFirst();
            Rec."App ID" := AggregatePermissionSet."App ID";
            Rec."Role ID" := AggregatePermissionSet."Role ID";
            Rec.Scope := AggregatePermissionSet.Scope;
        end;

        Rec.Insert();
        SetPageVariables();
    end;

    local procedure UpdatePageParts()
    var
        TempPermissionSetRelationBufferList: Record "Permission Set Relation Buffer" temporary;
        TempPermissionSetRelationBufferTree: Record "Permission Set Relation Buffer" temporary;
    begin
        CurrPage.Permissions.Page.SetPermissionSet(Rec."Role ID", Rec."App ID", IsTenant);
        CurrPage.PermissionSets.Page.SetPermissionSet(Rec."Role ID", Rec."App ID", IsTenant);
        CurrPage.PermissionSetTree.Page.SetPermissionSet(Rec."Role ID", Rec."App ID", IsTenant);
        CurrPage.Permissions.Page.SetPermissionSetRelation(PermissionSetRelationImpl);
        CurrPage.PermissionSets.Page.SetPermissionSetRelation(PermissionSetRelationImpl);
        CurrPage.PermissionSetTree.Page.SetPermissionSetRelation(PermissionSetRelationImpl);
        CurrPage.PermissionSets.Page.GetSourceRecord(TempPermissionSetRelationBufferList);
        CurrPage.PermissionSetTree.Page.GetSourceRecord(TempPermissionSetRelationBufferTree);

        PermissionSetRelationImpl.AddPermissionSetRelationBufferList(TempPermissionSetRelationBufferList);
        PermissionSetRelationImpl.AddPermissionSetRelationBufferTree(TempPermissionSetRelationBufferTree);
    end;

    local procedure SetPageVariables()
    begin
        IsTenant := Rec.Scope = Rec.Scope::Tenant;
    end;

    local procedure AddLoggedPermissions(var TablePermissionBuffer: Record "Tenant Permission" temporary)
    var
        PermissionSetCopyImpl: Codeunit "Permission Set Copy Impl.";
    begin
        if TablePermissionBuffer.FindSet() then
            repeat
                PermissionSetCopyImpl.AddToTenantPermission(
                  Rec."App ID",
                  Rec."Role ID",
                  TablePermissionBuffer."Object Type",
                  TablePermissionBuffer."Object ID",
                  TablePermissionBuffer."Read Permission",
                  TablePermissionBuffer."Insert Permission",
                  TablePermissionBuffer."Modify Permission",
                  TablePermissionBuffer."Delete Permission",
                  TablePermissionBuffer."Execute Permission");
            until TablePermissionBuffer.Next() = 0;
        TablePermissionBuffer.DeleteAll();
    end;

    var
        LogTablePermissions: Codeunit "Log Activity Permissions";
        PermissionSetRelationImpl: Codeunit "Permission Set Relation Impl.";
        IsTenant: Boolean;
        ComposablePermissionSetsTok: Label 'Composable Permission Sets', Locked = true;
        StartRecordingQst: Label 'Do you want to start the recording now?';
        AddPermissionsQst: Label 'Do you want to add the recorded permissions?';
        PermissionSetCaptionTok: Label '%1 (%2)', Locked = true;
        PermissionLoggingRunning: Boolean;
}