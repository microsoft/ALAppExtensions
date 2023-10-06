// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

/// <summary>
/// Xmlport for exporting system permission sets.
/// </summary>
xmlport 9862 "Export Permission Sets System"
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
                TextType = Text;
                Description = 'Version';
            }
            tableelement("Metadata Permission Set"; "Metadata Permission Set")
            {
                MinOccurs = Zero;
                XmlName = 'PermissionSet';
                fieldattribute(AppID; "Metadata Permission Set"."App ID")
                {
                    Occurrence = Optional;

                    trigger OnBeforePassField()
                    begin
                        if ExportInExtensionSchema = true then
                            currXMLport.Skip();
                    end;
                }
                fieldattribute(RoleID; "Metadata Permission Set"."Role ID")
                {
                }
                fieldattribute(RoleName; "Metadata Permission Set".Name)
                {
                }
                fieldattribute(Assignable; "Metadata Permission Set".Assignable)
                {
                }
                tableelement("Metadata Permission Set Rel."; "Metadata Permission Set Rel.")
                {
                    LinkTable = "Metadata Permission Set";
                    LinkFields = "App ID" = field("App ID"), "Role ID" = field("Role ID");
                    MinOccurs = Zero;
                    XmlName = 'PermissionSetRel';
                    SourceTableView = sorting("App ID", "Role ID", "Related App ID", "Related Role ID");
                    fieldelement(ObjectType; "Metadata Permission Set Rel.".Type)
                    {
                    }
                    fieldelement(ObjectRelatedRoleId; "Metadata Permission Set Rel."."Related Role ID")
                    {
                    }
                    fieldelement(ObjectRelatedAppId; "Metadata Permission Set Rel."."Related App ID")
                    {
                    }
                }
                tableelement("Metadata Permission"; "Metadata Permission")
                {
                    LinkFields = "Role ID" = field("Role ID");
                    LinkTable = "Metadata Permission Set";
                    MinOccurs = Zero;
                    XmlName = 'Permission';
                    SourceTableView = sorting("Role ID", "Object Type", "Object ID");
                    fieldelement(ObjectType; "Metadata Permission"."Object Type")
                    {
                    }
                    fieldelement(ObjectID; "Metadata Permission"."Object ID")
                    {
                    }
                    fieldelement(ReadPermission; "Metadata Permission"."Read Permission")
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassField()
                        begin
                            if "Metadata Permission"."Read Permission" = "Metadata Permission"."Read Permission"::" " then
                                currXMLport.Skip();
                        end;
                    }
                    fieldelement(InsertPermission; "Metadata Permission"."Insert Permission")
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassField()
                        begin
                            if "Metadata Permission"."Insert Permission" = "Metadata Permission"."Insert Permission"::" " then
                                currXMLport.Skip();
                        end;
                    }
                    fieldelement(ModifyPermission; "Metadata Permission"."Modify Permission")
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassField()
                        begin
                            if "Metadata Permission"."Modify Permission" = "Metadata Permission"."Modify Permission"::" " then
                                currXMLport.Skip();
                        end;
                    }
                    fieldelement(DeletePermission; "Metadata Permission"."Delete Permission")
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassField()
                        begin
                            if "Metadata Permission"."Delete Permission" = "Metadata Permission"."Delete Permission"::" " then
                                currXMLport.Skip();
                        end;
                    }
                    fieldelement(ExecutePermission; "Metadata Permission"."Execute Permission")
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassField()
                        begin
                            if "Metadata Permission"."Execute Permission" = "Metadata Permission"."Execute Permission"::" " then
                                currXMLport.Skip();
                        end;
                    }
                    fieldelement(SecurityFilter; "Metadata Permission"."Security Filter")
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassField()
                        begin
                            if Format("Metadata Permission"."Security Filter") = '' then
                                currXMLport.Skip();
                        end;
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