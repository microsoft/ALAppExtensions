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

                field("Extension Name"; ExtensionName)
                {
                    ApplicationArea = All;
                    Caption = 'Extension Name';
                    ToolTip = 'Specifies the name of the extension for the mapping.';
                    Lookup = true;

                    // The following properties are to disable user manipulation of locked mapping records.
                    Style = Subordinate;
                    StyleExpr = Locked;
                    Editable = not Locked;
                    Enabled = not Locked;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PublishedApplication: Record "Published Application";
                    begin
                        if not LookupApp(PublishedApplication) then
                            exit(false);

                        ExtensionName := PublishedApplication.Name;
                        Text := PublishedApplication.Name;
                        Validate("App ID", PublishedApplication.ID);
                        exit(true);
                    end;

                    trigger OnValidate()                    
                    begin
                        Rec.UpdateExtensionName(ExtensionName);
                    end;
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                    Caption = 'Table Name';
                    Tooltip = 'Specifies the name of the table for the mapping.';
                    Lookup = true;

                    // The following properties are to disable user manipulation of locked mapping records.
                    Style = Subordinate;
                    StyleExpr = Locked;
                    Editable = not Locked;
                    Enabled = not Locked;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        AllObj: Record AllObj;
                        AllObjects: Page "All Objects";
                    begin
                        AllObj.SetRange("App Package ID", "Extension Package ID");
                        AllObj.SetRange("Object Type", AllObj."Object Type"::Table);
                        AllObjects.SetTableView(AllObj);
                        AllObjects.LookupMode(true);
                        if not (AllObjects.RunModal() in [Action::OK, Action::LookupOK]) then
                            exit(false);

                        AllObjects.GetRecord(AllObj);
                        Text := AllObj."Object Name";
                        exit(true);
                    end;
                }
                field("Source Table Name"; "Source Table Name")
                {
                    ApplicationArea = All;
                    Caption = 'Source Table Name';
                    Tooltip = 'Specifies the name of the source table for the mapping. This is used in the case that the name of the table differs between the source and destination databases.';

                    // The following properties are to disable user manipulation of locked mapping records.
                    Style = Subordinate;
                    StyleExpr = Locked;
                    Editable = not Locked;
                    Enabled = not Locked;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
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
                    if not LookupApp(PublishedApplication) then
                        exit;

                    ApplicationObjectMetadata.SetRange("Package ID", PublishedApplication."Package ID");
                    ApplicationObjectMetadata.SetRange("Object Type", ApplicationObjectMetadata."Object Type"::Table);
                    if ApplicationObjectMetadata.FindSet() then
                        repeat
                            if not ExtensionTableMapping.Get(PublishedApplication.ID, ApplicationObjectMetadata."Object ID") then
                                if TableMetadata.Get(ApplicationObjectMetadata."Object ID") then
                                    if TableMetadata.ReplicateData then begin
                                        ExtensionTableMapping.Init();
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
                    ExtensionTableMapping.SetRange("App ID", "App ID");
                    ExtensionTableMapping.DeleteAll();
                end;
            }
        }
    }

    trigger OnInit()
    begin
        SetCurrentKey("App ID", "Table Name");
    end;

    trigger OnOpenPage()
    begin
        SetRange(Locked, false);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(ExtensionName);
    end;

    trigger OnAfterGetRecord()
    begin
        CalcFields("Extension Package ID");
        CalcFields("Extension Name");
        ExtensionName := "Extension Name";
    end;

    local procedure LookupApp(var PublishedApplication: Record "Published Application"): Boolean
    var
        ExtensionManagement: Page "Extension Management";
        BlacklistExtensionFilter: Text;
        BlacklistPublisher: Text;
        BlacklistFilterTxt: Label '<>%1&', Comment = '%1 - extension publisher', Locked = true;
    begin
        foreach BlacklistPublisher in InvalidExtensionPublishers().Split(',') do
            BlacklistExtensionFilter += StrSubstNo(BlacklistFilterTxt, BlacklistPublisher);

        BlacklistExtensionFilter := BlacklistExtensionFilter.TrimEnd('&');
        PublishedApplication.SetFilter(Publisher, BlacklistExtensionFilter);

        ExtensionManagement.SetTableView(PublishedApplication);
        ExtensionManagement.LookupMode(true);
        if not (ExtensionManagement.RunModal() in [Action::LookupOK, Action::OK]) then
            exit;

        ExtensionManagement.GetRecord(PublishedApplication);
        exit(true);
    end;

    var
        ExtensionName: Text[250];
        NoTablesInExtensionMsg: Label 'No tables exist in the specified extension.';
        ResetToDefaultsQst: Label 'All current table mappings for Cloud Migration will be deleted and replaced with the default values.\\Do you want to continue?';
}