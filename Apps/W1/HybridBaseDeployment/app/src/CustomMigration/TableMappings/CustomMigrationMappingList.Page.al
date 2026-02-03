// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration;

page 40017 "Custom Migration Mapping List"
{
    ApplicationArea = All;
    PageType = List;
    SourceTable = "Custom Migration Table Buffer";
    SourceTableTemporary = true;
    SourceTableView = sorting("Mapping Type", "Table Name") order(ascending);
    Caption = 'Custom Migration Table Mappings';
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            repeater(TableMappings)
            {
                field(MappingType; Rec."Mapping Type")
                {
                    ApplicationArea = All;
                }
                field(TableName; Rec."Table Name")
                {
                    ApplicationArea = All;
                }
                field(CompanyName; Rec."Company Name")
                {
                    ApplicationArea = All;
                }
                field(PreserveCloudData; Rec."Preserve Cloud Data")
                {
                    ApplicationArea = All;
                }
                field(SourceSqlTableName; Rec."Source Sql Table Name")
                {
                    ApplicationArea = All;
                }
                field(DestinationSqlTableName; Rec."Destination Sql Table Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(AddTableMapping)
            {
                ApplicationArea = All;
                Caption = 'Add Table Mapping';
                ToolTip = 'Add a new table mapping for custom migration.';
                Image = Add;

                trigger OnAction()
                begin
                    Page.RunModal(Page::"Add Custom Migration Mapping");
                    Rec.LoadData();
                    CurrPage.Update(false);
                end;
            }
            action(DeleteTableMapping)
            {
                ApplicationArea = All;
                Caption = 'Delete';
                ToolTip = 'Delete the selected table mapping.';
                Image = Delete;

                trigger OnAction()
                begin
                    DeleteSelectedMappings();
                    CurrPage.Update(false);
                end;
            }
            action(ImportMappings)
            {
                ApplicationArea = All;
                Caption = 'Import';
                ToolTip = 'Import table mappings from a JSON file.';
                Image = Import;

                trigger OnAction()
                var
                    JsonInStream: InStream;
                    FileName: Text;
                    JsonText: Text;
                begin
                    FileName := DefaultTableMappingsFileNameLbl;
                    if not UploadIntoStream(ImportDialogTitleLbl, '', JsonFileFilterLbl, FileName, JsonInStream) then
                        exit;

                    JsonInStream.ReadText(JsonText);
                    Rec.ImportFromJson(JsonText);
                    Message(ImportSuccessMsg);
                end;
            }
            action(ExportMappings)
            {
                ApplicationArea = All;
                Caption = 'Export';
                ToolTip = 'Export table mappings to a JSON file.';
                Image = Export;

                trigger OnAction()
                begin
                    Rec.ExportToFile();
                end;
            }
            action(ResetToDefaults)
            {
                ApplicationArea = All;
                Caption = 'Reset to Defaults';
                ToolTip = 'Delete all table mappings and restore the default mappings.';
                Image = Restore;

                trigger OnAction()
                begin
                    if not Confirm(ResetToDefaultsQst, false) then
                        exit;

                    Rec.RestoreDefaultMappings();
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(AddTableMapping_Promoted; AddTableMapping)
                {
                }
                actionref(DeleteTableMapping_Promoted; DeleteTableMapping)
                {
                }
                actionref(ImportMappings_Promoted; ImportMappings)
                {
                }
                actionref(ExportMappings_Promoted; ExportMappings)
                {
                }
                actionref(ResetToDefaults_Promoted; ResetToDefaults)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        ViewText: Text;
    begin
        ViewText := Rec.GetView();
        Rec.LoadData();
        Rec.SetView(ViewText);
    end;

    local procedure DeleteSelectedMappings()
    var
        BackupRec: Record "Custom Migration Table Buffer";
    begin

        if not Confirm(DeleteConfirmQst, false) then
            exit;
        BackupRec.Copy(Rec);
        CurrPage.SetSelectionFilter(Rec);
        Rec.DeleteAll(true);
        Rec.LoadData();
        Rec.Copy(BackupRec);
        Rec.Next(-1);
        CurrPage.Update(false);
    end;

    var
        ImportDialogTitleLbl: Label 'Import Table Mappings';
        ImportSuccessMsg: Label 'Table mappings were imported successfully.';
        DeleteConfirmQst: Label 'Are you sure you want to delete the selected table mapping(s)?';
        ResetToDefaultsQst: Label 'This will delete all current table mappings and restore the default mappings. Do you want to continue?';
        DefaultTableMappingsFileNameLbl: Label 'TableMappings.json', Locked = true;
        JsonFileFilterLbl: Label 'JSON Files (*.json)|*.json|All Files (*.*)|*.*', Locked = true;
}
