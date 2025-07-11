namespace Microsoft.DataMigration;

using System.Apps;
using System.Reflection;

page 4009 "Migration Table Mapping"
{
    ApplicationArea = All;
    DelayedInsert = true;
    PageType = List;
    Permissions = tabledata "Migration Table Mapping" = rimd;
    SourceTable = "Migration Table Mapping";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Map)
            {
                field(TargetTableType; Rec."Target Table Type")
                {
                    ApplicationArea = All;
                    Caption = 'Target Table Type';
                    ToolTip = 'Specifies the type of the target table.';
                    Visible = IsBCCloudMigration;
                }

                field("Extension Name"; ExtensionName)
                {
                    ApplicationArea = All;
                    Caption = 'Extension Name';
                    ToolTip = 'Specifies the name of the extension for the mapping.';
                    Lookup = true;

                    // The following properties are to disable user manipulation of locked mapping records.
                    Style = Subordinate;
                    StyleExpr = Rec.Locked;
                    Editable = not Rec.Locked;
                    Enabled = not Rec.Locked;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PublishedApplication: Record "Published Application";
                    begin
                        if not Rec.LookupApp(PublishedApplication) then
                            exit(false);

                        ExtensionName := PublishedApplication.Name;
                        Text := PublishedApplication.Name;
                        Rec.Validate("App ID", PublishedApplication.ID);
                        exit(true);
                    end;

                    trigger OnValidate()
                    var
                        ExtensionNameTemp: Text;
                    begin
                        ExtensionNameTemp := CopyStr(ExtensionName, 1, MaxStrLen(ExtensionName));
                        Rec.UpdateExtensionName(ExtensionNameTemp);
                        ExtensionName := CopyStr(ExtensionNameTemp, 1, MaxStrLen(ExtensionName));
                    end;
                }
                field(TableID; Rec."Table ID")
                {
                    ApplicationArea = All;
                    Caption = 'Table ID';
                    Visible = false;
                    ToolTip = 'Specifies the ID of the target table.';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    Caption = 'Table Name';
                    Tooltip = 'Specifies the name of the table for the mapping.';
                    Lookup = true;

                    // The following properties are to disable user manipulation of locked mapping records.
                    Style = Subordinate;
                    StyleExpr = Rec.Locked;
                    Editable = not Rec.Locked;
                    Enabled = not Rec.Locked;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        AllObj: Record AllObj;
                        AllObjects: Page "All Objects";
                    begin
                        AllObj.SetRange("App Package ID", Rec."Extension Package ID");
                        if Rec."Target Table Type" = Rec."Target Table Type"::Table then
                            AllObj.SetRange("Object Type", AllObj."Object Type"::Table)
                        else
                            AllObj.SetRange("Object Type", AllObj."Object Type"::"TableExtension");

                        AllObjects.SetTableView(AllObj);
                        AllObjects.LookupMode(true);
                        if not (AllObjects.RunModal() in [Action::OK, Action::LookupOK]) then
                            exit(false);

                        AllObjects.GetRecord(AllObj);
                        Text := AllObj."Object Name";
                        if (Rec."Table ID" <> AllObj."Object ID") and (Rec."Target Table Type" = Rec."Target Table Type"::"Table Extension") then
                            // Partners often have the table and table extension that have same ID and they need to map both
                            // Just the ID is the same, the table extended is different
                            Rec."Table ID" := -AllObj."Object ID"
                        else
                            Rec."Table ID" := AllObj."Object ID";
                        exit(true);
                    end;
                }
                field("Source Table Name"; Rec."Source Table Name")
                {
                    ApplicationArea = All;
                    Caption = 'Source Table Name';
                    Tooltip = 'Specifies the name of the source table for the mapping. This is used in the case that the name of the table differs between the source and destination databases.';

                    // The following properties are to disable user manipulation of locked mapping records.
                    Style = Subordinate;
                    StyleExpr = Rec.Locked;
                    Editable = not Rec.Locked;
                    Enabled = not Rec.Locked;

                    trigger OnValidate()
                    begin
                        SourceTableAppID := Rec.GetSourceTableAppID(Rec);
                        if Rec."Target Table Type" = Rec."Target Table Type"::"Table Extension" then
                            Rec."Table Name" := CopyStr(Rec.GetSourceTableName(Rec), 1, MaxStrLen(Rec."Table Name"));
                    end;
                }

                field(SourceTableAppID; SourceTableAppID)
                {
                    ApplicationArea = All;
                    Caption = 'Source Table App ID';
                    Tooltip = 'Specifies the App ID of the source table. This value should be left blank if the source table is in C/AL, otherwise the Application ID should be provided.';
                    Visible = IsBCCloudMigration;

                    // The following properties are to disable user manipulation of locked mapping records.
                    Style = Subordinate;
                    StyleExpr = Rec.Locked;
                    Editable = not Rec.Locked;
                    Enabled = not Rec.Locked;

                    trigger OnValidate()
                    begin
                        Rec.SetSourceTableName(SourceTableAppID);
                    end;
                }
                field("Data Per Company"; Rec."Data Per Company")
                {
                    ApplicationArea = All;
                    Caption = 'Data Per Company';
                    Tooltip = 'Specifies if the table data is per company';
                    Editable = Rec."Target Table Type" = Rec."Target Table Type"::"Table Extension";
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(AddTableMappings)
            {
                ApplicationArea = All;
                Caption = 'Add Table Mappings';
                ToolTip = 'Adds table mappings for the extensions.';
                Image = AddAction;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Visible = IsBCCloudMigration;

                trigger OnAction()
                var
                    AddMigrationTableMappings: Page "Add Migration Table Mappings";
                begin
                    AddMigrationTableMappings.LookupMode(true);
                    if AddMigrationTableMappings.RunModal() in [Action::OK, Action::LookupOK] then
                        CurrPage.Update(false);
                end;

            }
            action(PopulateFromExtension)
            {
                ApplicationArea = All;
                Caption = 'Populate From Extension';
                ToolTip = 'Populate the list with all tables from an existing extension.';
                Image = ItemSubstitution;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ExtensionTableMapping: Record "Migration Table Mapping";
                    PublishedApplication: Record "Published Application";
                    ApplicationObjectMetadata: Record "Application Object Metadata";
                    TableMetadata: Record "Table Metadata";
                begin
                    if not Rec.LookupApp(PublishedApplication) then
                        exit;

                    ApplicationObjectMetadata.SetRange("Package ID", PublishedApplication."Package ID");
                    ApplicationObjectMetadata.SetRange("Object Type", ApplicationObjectMetadata."Object Type"::Table);
                    if ApplicationObjectMetadata.FindSet() then
                        repeat
                            if not ExtensionTableMapping.Get(PublishedApplication.ID, ApplicationObjectMetadata."Object ID") then
                                if TableMetadata.Get(ApplicationObjectMetadata."Object ID") then
                                    if TableMetadata.ReplicateData then begin
                                        Clear(ExtensionTableMapping);
                                        ExtensionTableMapping.Validate("App ID", PublishedApplication.ID);
                                        ExtensionTableMapping.Validate("Table ID", ApplicationObjectMetadata."Object ID");
                                        ExtensionTableMapping.Insert(true);
                                    end;
                        until ApplicationObjectMetadata.Next() = 0
                    else
                        Message(NoTablesInExtensionMsg);
                end;
            }

            action(RestoreDefaultMappings)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Restore Default Mappings';
                Image = Restore;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Delete the current migration table mappings and replace them with the default mappings.';

                trigger OnAction()
                var
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                begin
                    if not Confirm(ResetToDefaultsQst) then
                        exit;

                    HybridCloudManagement.RestoreDefaultMigrationTableMappings(true);
                    CurrPage.Update();
                end;
            }

            action(DeleteAllForExtension)
            {
                ApplicationArea = All;
                Caption = 'Delete All For Extension';
                Tooltip = 'Deletes all records belonging to this extension.';
                Image = RemoveFilterLines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Scope = Repeater;

                trigger OnAction()
                var
                    ExtensionTableMapping: Record "Migration Table Mapping";
                begin
                    ExtensionTableMapping.SetRange("App ID", Rec."App ID");
                    ExtensionTableMapping.DeleteAll();
                end;
            }

            action(ImportTableMappings)
            {
                ApplicationArea = All;
                Caption = 'Import';
                Tooltip = 'Imports table mappings from a file.';
                Image = Import;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Scope = Repeater;

                trigger OnAction()
                begin
                    Rec.ImportMigrationTableMappings();
                    CurrPage.Update();
                end;
            }
            action(ExportTableMappings)
            {
                ApplicationArea = All;
                Caption = 'Export';
                Tooltip = 'Exports table mappings to a file.';
                Image = Export;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Scope = Repeater;

                trigger OnAction()
                begin
                    Rec.DownloadMigrationTableMappings();
                end;
            }
        }
    }

    trigger OnInit()
    begin
        Rec.SetCurrentKey("App ID", "Table Name");
    end;

    trigger OnOpenPage()
    begin
        Rec.SetRange(Locked, false);
        OnIsBCMigration(IsBCCloudMigration);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(ExtensionName);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        CloudMigReplicateDataMgt: Codeunit "Cloud Mig. Replicate Data Mgt.";
    begin
        if Rec."Target Table Type" = Rec."Target Table Type"::"Table Extension" then
            Error(MustUseAddTableMappingsErr);

        if IsBCCloudMigration then
            CloudMigReplicateDataMgt.ShowAddTableMappingsNotification();
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Extension Package ID");
        Rec.CalcFields("Extension Name");
        ExtensionName := Rec."Extension Name";
        SourceTableAppID := Rec.GetSourceTableAppID(Rec);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsBCMigration(var SourceBC: Boolean)
    begin
    end;

    var
        IsBCCloudMigration: Boolean;
        ExtensionName: Text[250];
        SourceTableAppID: Text;
        NoTablesInExtensionMsg: Label 'No tables exist in the specified extension.';
        ResetToDefaultsQst: Label 'All current table mappings for Cloud Migration will be deleted and replaced with the default values.\\Do you want to continue?';
        MustUseAddTableMappingsErr: Label 'You must use the "Add Table Mappings" action to add table mappings for Table Extensions. For more information see https://go.microsoft.com/fwlink/?linkid=2296587.';
}
