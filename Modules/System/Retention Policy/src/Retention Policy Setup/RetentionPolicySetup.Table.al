// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This table stores the retention policy setup records.
/// </summary>
table 3901 "Retention Policy Setup"
{
    DataCaptionFields = "Table Name", "Retention Period";

    fields
    {
        field(1; "Table Id"; Integer)
        {
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = Const(Table));
            BlankZero = true;
            NotBlank = true;
            MinValue = 0;
            MaxValue = 1999999999;

            trigger OnValidate()
            var
                RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
            begin
                RetenPolAllowedTables.IsAllowedTable(Rec."Table Id");
                Rec.Validate("Date Field No.", RetenPolAllowedTables.GetDefaultDateFieldNo(Rec."Table Id"));
            end;

            trigger OnLookup()
            var
                RetentionPolicy: Codeunit "Retention Policy Setup";
            begin
                Rec.Validate("Table Id", RetentionPolicy.TableIdLookup(Rec."Table Id"));
            end;
        }
        field(2; "Table Name"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Table), "Object ID" = Field("Table Id")));
            Editable = false;

            trigger OnLookup()
            var
                RetentionPolicy: Codeunit "Retention Policy Setup";
            begin
                Rec.Validate("Table Id", RetentionPolicy.TableIdLookup(Rec."Table Id"));
            end;

        }
        field(3; "Table Caption"; Text[249])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = Field("Table Id")));
            Editable = false;
        }
        field(4; "Retention Period"; Code[20])
        {
            TableRelation = "Retention Period".Code;

            trigger OnValidate()
            var
                RetentionPolicySetupImpl: Codeunit "Retention Policy Setup Impl.";
            begin
                RetentionPolicySetupImpl.ValidateRetentionPeriod(Rec);
                if Rec."Retention Period" <> '' then
                    Rec.Validate(Enabled, true);
            end;
        }
        field(5; Enabled; Boolean)
        {
            trigger OnValidate()
            var
                RetentionPolicySetupLine: Record "Retention Policy Setup Line";
            begin
                if Rec.Enabled then
                    if Rec."Apply to all records" then
                        Rec.TestField("Retention Period")
                    else begin
                        RetentionPolicySetupLine.SetRange(Enabled, true);
                        if RetentionPolicySetupLine.IsEmpty() then
                            error(NoLinesEnabledErr)
                    end;
            end;
        }
        field(6; "Apply to all records"; Boolean)
        {
            InitValue = true;

            trigger OnValidate()
            var
                RetentionPolicySetupLine: Record "Retention Policy Setup Line";
                RetentionPolicyLog: Codeunit "Retention Policy Log";
            begin
                if Rec."Apply to all records" then begin
                    RetentionPolicySetupLine.SetRange("Table ID", Rec."Table Id");
                    RetentionPolicySetupLine.SetRange(Locked, true);
                    if not RetentionPolicySetupLine.IsEmpty() then begin
                        Rec.CalcFields("Table Caption");
                        RetentionPolicyLog.LogError(LogCategory(), StrSubstNo(CannotApplyToAllRecordsErr, Rec."Table Id", Rec."Table Caption"))
                    end;
                end;

                if not Rec."Apply to all records" then
                    Rec."Retention Period" := '';
                Rec.Enabled := false;
            end;
        }
        field(7; "Date Field No."; Integer)
        {
            TableRelation = Field."No." where(TableNo = field("Table ID"), "Type" = filter(Date | DateTime));

            trigger OnValidate()
            begin
                Rec.CalcFields("Date Field Name", "Date Field Caption");
            end;

            trigger OnLookup()
            var
                RetentionPolicy: Codeunit "Retention Policy Setup";
            begin
                Rec.Validate("Date Field No.", RetentionPolicy.DateFieldNoLookup(Rec."Table Id", Rec."Date Field No."));
            end;
        }
        field(8; "Date Field Name"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Field.FieldName where(TableNo = field("Table ID"), "No." = field("Date Field No.")));
            Editable = false;
        }
        field(9; "Date Field Caption"; Text[80])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Table ID"), "No." = field("Date Field No.")));
            Editable = false;
        }
        field(10; Manual; Boolean)
        {
        }
        field(100; "Number Of Records Deleted"; Integer)
        {
            DataClassification = SystemMetadata;
            Access = Internal;
            Editable = false;
        }
    }

    keys
    {
        key(PrimaryKey; "Table ID")
        {
            Clustered = true;
        }
    }

    var
        NoLinesEnabledErr: Label 'You must enable at least one line.';
        CannotApplyToAllRecordsErr: Label 'You cannot toggle "Apply to all records" because the retention policy for table %1, %2 contains mandatory filters.', Comment = '%1 = table number, %2 = table caption';

    trigger OnDelete()
    var
        RetentionPolicySetupImpl: Codeunit "Retention Policy Setup Impl.";
    begin
        RetentionPolicySetupImpl.DeleteRetentionPolicySetup(Rec);
    end;

    local procedure LogCategory() RetentionPolicyLogCategory: Enum "Retention Policy Log Category"
    begin
        exit(RetentionPolicyLogCategory::"Retention Policy - Setup")
    end;
}