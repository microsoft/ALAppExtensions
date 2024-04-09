namespace Microsoft.Integration.MDM;

using Microsoft.Integration.SyncEngine;
using System.Reflection;


page 7236 "Master Data Synch. Fields"
{
    Caption = 'Synchronization Fields';
    DataCaptionExpression = IntegrationTableCaption();
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Integration Field Mapping";
    Permissions = tabledata "Integration Field Mapping" = rimd,
                  tabledata "Integration Table Mapping" = r;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Status; Rec.Status)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies if field synchronization is enabled or disabled.';
                    StyleExpr = StatusStyle;
                }
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = Suite;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the number of the field in the source company.';
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    ToolTip = 'Specifies the caption of the field.';
                }
                field("Integration Table Field No."; Rec."Integration Table Field No.")
                {
                    ApplicationArea = Suite;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the number of the field in the source company.';
                    Visible = false;
                }
                field(Direction; Rec.Direction)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the direction of the synchronization.';
                    Visible = false;
                }
                field("Constant Value"; Rec."Constant Value")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the constant value that the mapped field will be set to.';
                    Visible = false;
                }
                field("Transformation Rule"; Rec."Transformation Rule")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a rule for transforming the value that is being synchronized from the source company.';
                    Visible = false;
                }
                field("Transformation Direction"; Rec."Transformation Direction")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the direction of the transformation.';
                    Editable = Rec."Direction" = Rec."Direction"::Bidirectional;
                    Visible = false;
                }
                field("Validate Field"; Rec."Validate Field")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies if the field should be validated during assignment.';
                }
                field("Overwrite Local Change"; Rec."Overwrite Local Change")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies if the synchronization should overwrite the local change that was done after the last synchronization.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(FieldMapping)
            {
                ApplicationArea = Suite;
                Caption = 'Update Fields';
                Image = Relationship;
                ToolTip = 'Updates field mappings to match table schema. Use this action if you added fields to the table with an extension.';

                trigger OnAction()
                var
                    IntegrationTableMapping: Record "Integration Table Mapping";
                    IntegrationFieldMapping: Record "Integration Field Mapping";
                    TableField: Record Field;
                    MasterDataManagement: Codeunit "Master Data Management";
                    MasterDataMgtSetupDefault: Codeunit "Master Data Mgt. Setup Default";
                    LocalRecordRef: RecordRef;
                    FieldNumbers: List of [Integer];
                    FieldsAdded: Integer;
                    FieldsRemoved: Integer;
                begin
                    IntegrationTableMapping.Get(Rec."Integration Table Mapping Name");
                    LocalRecordRef.Open(IntegrationTableMapping."Table ID");
                    Session.LogMessage('0000JIO', LocalRecordRef.Caption(), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
                    IntegrationFieldMapping.SetRange("Integration Table Mapping Name", Rec."Integration Table Mapping Name");
                    if IntegrationFieldMapping.FindSet() then
                        repeat
                            FieldNumbers.Add(IntegrationFieldMapping."Field No.");
                        until IntegrationFieldMapping.Next() = 0;
                    IntegrationFieldMapping.Reset();

                    TableField.SetRange(TableNo, IntegrationTableMapping."Table ID");
                    TableField.SetRange(Class, TableField.Class::Normal);
                    TableField.SetRange(ObsoleteState, TableField.ObsoleteState::No);
                    TableField.SetFilter("No.", '<' + Format(LocalRecordRef.SystemIdNo));
                    TableField.SetFilter(RelationFieldNo, '<' + Format(LocalRecordRef.SystemIdNo));
                    if TableField.FindSet() then
                        repeat
                            if not FieldNumbers.Contains(TableField."No.") then begin
                                MasterDataMgtSetupDefault.InsertIntegrationFieldMapping(Rec."Integration Table Mapping Name", IntegrationFieldMapping, TableField."No.", TableField."No.", IntegrationFieldMapping.Direction::FromIntegrationTable, '', false, false);
                                IntegrationFieldMapping.Status := IntegrationFieldMapping.Status::Disabled;
                                IntegrationFieldMapping.Modify();
                                FieldsAdded += 1;
                            end;
                        until TableField.Next() = 0;

                    IntegrationFieldMapping.Reset();
                    IntegrationFieldMapping.SetRange("Integration Table Mapping Name", Rec."Integration Table Mapping Name");
                    if IntegrationFieldMapping.FindSet() then
                        repeat
                            TableField.SetRange("No.", IntegrationFieldMapping."Field No.");
                            if TableField.IsEmpty() then begin
                                IntegrationFieldMapping.Delete();
                                FieldsRemoved += 1;
                            end;
                        until IntegrationFieldMapping.Next() = 0;

                    if FieldsAdded * FieldsRemoved > 0 then begin
                        Message(StrSubstNo(FieldsAddedAndRemovedTxt, FieldsAdded, FieldsRemoved));
                        exit;
                    end;

                    if FieldsAdded > 0 then
                        Message(StrSubstNo(FieldsAddedTxt, FieldsAdded));

                    if FieldsRemoved > 0 then
                        Message(StrSubstNo(FieldsRemovedTxt, FieldsRemoved));
                end;
            }
            action(Enable)
            {
                ApplicationArea = Suite;
                Caption = 'Enable';
                Image = EnableAllBreakpoints;
                ToolTip = 'Enables the synchronization of the selected fields.';

                trigger OnAction()
                var
                    IntegrationFieldMapping: Record "Integration Field Mapping";
                begin
                    CurrPage.SetSelectionFilter(IntegrationFieldMapping);
                    IntegrationFieldMapping.ModifyAll(Status, IntegrationFieldMapping.Status::Enabled);
                    CurrPage.Update(false);
                end;
            }
            action(Disable)
            {
                ApplicationArea = Suite;
                Caption = 'Disable';
                Image = EnableAllBreakpoints;
                ToolTip = 'Disables the synchronization of the selected fields.';

                trigger OnAction()
                var
                    IntegrationFieldMapping: Record "Integration Field Mapping";
                begin
                    CurrPage.SetSelectionFilter(IntegrationFieldMapping);
                    IntegrationFieldMapping.ModifyAll(Status, IntegrationFieldMapping.Status::Disabled);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 4.';

                actionref(FieldMapping_Promoted; FieldMapping)
                {
                }
                actionref(EnableAll_Promoted; Enable)
                {
                }
                actionref(DisableAll_Promoted; Disable)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        StatusStyle := GetStatusStyleExpression(Rec.Status);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        StatusStyle := GetStatusStyleExpression(Rec.Status);
        exit(true);
    end;

    var
        StatusStyle: Text;

    local procedure IntegrationTableCaption(): Text
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        RecRef: RecordRef;
    begin
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange(Name, Rec."Integration Table Mapping Name");
        if IntegrationTableMapping.FindFirst() then
            if IntegrationTableMapping."Table ID" <> 0 then begin
                RecRef.Open(IntegrationTableMapping."Table ID");
                exit(RecRef.Caption());
            end;
        exit('');
    end;

    local procedure GetStatusStyleExpression(FieldStatus: Option): Text
    var
        IntegrationFieldMapping: Record "Integration Field Mapping";
    begin
        case FieldStatus of
            IntegrationFieldMapping.Status::Enabled:
                exit('Favorable');
            else
                exit('Ambiguous');
        end;
    end;

    var
        FieldsAddedTxt: label '%1 fields added.', Comment = '%1 - an integer';
        FieldsRemovedTxt: label '%1 fields removed.', Comment = '%1 - an integer';
        FieldsAddedAndRemovedTxt: label '%1 fields added, %2 fields removed.', Comment = '%1 - an integer, %2 - an integer';
}



