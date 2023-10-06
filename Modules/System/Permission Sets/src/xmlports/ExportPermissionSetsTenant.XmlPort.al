// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

/// <summary>
/// Xmlport for exporting tenant permission sets.
/// </summary>
xmlport 9863 "Export Permission Sets Tenant"
{
    Caption = 'Export Permission Sets';
    Direction = Export;
    Encoding = UTF8;
    PreserveWhiteSpace = true;
    UseRequestPage = false;

    schema
    {
        textelement(PermissionSets)
        {
            textattribute(Version)
            {
            }
            tableelement("Tenant Permission Set"; "Tenant Permission Set")
            {
                MinOccurs = Zero;
                XmlName = 'TenantPermissionSet';
                fieldattribute(AppID; "Tenant Permission Set"."App ID")
                {
                    Occurrence = Optional;

                    trigger OnBeforePassField()
                    begin
                        if ExportInExtensionSchema = true then
                            currXMLport.Skip();
                    end;
                }
                fieldattribute(RoleID; "Tenant Permission Set"."Role ID")
                {
                }
                fieldattribute(RoleName; "Tenant Permission Set".Name)
                {
                }
                fieldattribute(Assignable; "Tenant Permission Set".Assignable)
                {
                }
                tableelement("Tenant Permission Set Rel."; "Tenant Permission Set Rel.")
                {
                    LinkTable = "Tenant Permission Set";
                    LinkFields = "App ID" = field("App ID"), "Role ID" = field("Role ID");
                    MinOccurs = Zero;
                    XmlName = 'TenantPermissionSetRel';
                    SourceTableView = sorting("App ID", "Role ID", "Related App ID", "Related Role ID");
                    fieldelement(ObjectType; "Tenant Permission Set Rel.".Type)
                    {
                    }
                    fieldelement(ObjectRelatedScope; "Tenant Permission Set Rel."."Related Scope")
                    {
                    }
                    fieldelement(ObjectRelatedRoleId; "Tenant Permission Set Rel."."Related Role ID")
                    {
                    }
                    fieldelement(ObjectRelatedAppId; "Tenant Permission Set Rel."."Related App ID")
                    {
                    }
                }
                tableelement("Tenant Permission"; "Tenant Permission")
                {
                    LinkFields = "App ID" = field("App ID"), "Role ID" = field("Role ID");
                    LinkTable = "Tenant Permission Set";
                    MinOccurs = Zero;
                    XmlName = 'TenantPermission';
                    SourceTableView = sorting("Role ID", "Object Type", "Object ID");
                    fieldelement(ObjectType; "Tenant Permission"."Object Type")
                    {
                    }
                    fieldelement(ObjectID; "Tenant Permission"."Object ID")
                    {
                    }
                    fieldelement(ReadPermission; "Tenant Permission"."Read Permission")
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassField()
                        begin
                            if "Tenant Permission"."Read Permission" = "Tenant Permission"."Read Permission"::" " then
                                currXMLport.Skip();
                        end;
                    }
                    fieldelement(InsertPermission; "Tenant Permission"."Insert Permission")
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassField()
                        begin
                            if "Tenant Permission"."Insert Permission" = "Tenant Permission"."Insert Permission"::" " then
                                currXMLport.Skip();
                        end;
                    }
                    fieldelement(ModifyPermission; "Tenant Permission"."Modify Permission")
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassField()
                        begin
                            if "Tenant Permission"."Modify Permission" = "Tenant Permission"."Modify Permission"::" " then
                                currXMLport.Skip();
                        end;
                    }
                    fieldelement(DeletePermission; "Tenant Permission"."Delete Permission")
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassField()
                        begin
                            if "Tenant Permission"."Delete Permission" = "Tenant Permission"."Delete Permission"::" " then
                                currXMLport.Skip();
                        end;
                    }
                    fieldelement(ExecutePermission; "Tenant Permission"."Execute Permission")
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassField()
                        begin
                            if "Tenant Permission"."Execute Permission" = "Tenant Permission"."Execute Permission"::" " then
                                currXMLport.Skip();
                        end;
                    }
                    fieldelement(SecurityFilter; "Tenant Permission"."Security Filter")
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassField()
                        begin
                            if Format("Tenant Permission"."Security Filter") = '' then
                                currXMLport.Skip();
                        end;
                    }
                    fieldelement(PermissionType; "Tenant Permission".Type)
                    {
                    }
                }
            }
        }
    }

    trigger OnInitXmlPort()
    begin
        Version := '2.0';
    end;

    var
        ExportInExtensionSchema: Boolean;

    procedure SetExportToExtensionSchema(ExtensionSchema: Boolean)
    begin
        ExportInExtensionSchema := ExtensionSchema;
    end;
}