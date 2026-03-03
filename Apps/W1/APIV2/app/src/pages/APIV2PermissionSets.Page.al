// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Security.AccessControl;

page 30003 "APIV2 - Permission Sets"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'Permission Set';
    EntitySetCaption = 'Permission Sets';
    EntityName = 'aggregatePermissionSet';
    EntitySetName = 'aggregatePermissionSets';
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DataAccessIntent = ReadOnly;
    PageType = API;
    SourceTable = "Aggregate Permission Set";
    SourceTableView = where("App Name" = filter('<> *_Exclude_*'));
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                }
                field(appID; Rec."App ID")
                {
                    Caption = 'App Id';
                }
                field(appName; Rec."App Name")
                {
                    Caption = 'App Name';
                }
                field(name; Rec.Name)
                {
                    Caption = 'Name';
                }
                field(roleID; Rec."Role ID")
                {
                    Caption = 'Role Id';
                }
                field(scope; Rec.Scope)
                {
                    Caption = 'Scope';
                }
                part(accessControl; "APIV2 - Access Control")
                {
                    Caption = 'Access Control';
                    EntityName = 'accessControl';
                    EntitySetName = 'accessControls';
                    Multiplicity = Many;
                    SubPageLink = "Role ID" = field("Role ID");
                }
            }
        }
    }
}