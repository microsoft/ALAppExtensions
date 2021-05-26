// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This table stores the filter used to apply retention policies to subsets of records in a table.
/// </summary>
table 3902 "Retention Policy Setup Line"
{
    fields
    {
        field(1; "Table ID"; Integer)
        {
            Editable = false;
        }
        field(2; "Table Name"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Table), "Object ID" = Field("Table Id")));
            Editable = false;
        }
        field(3; "Table Caption"; Text[249])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = Field("Table Id")));
            Editable = false;
        }
        field(4; "Line No."; Integer)
        {
            Editable = false;
        }
        field(5; Enabled; Boolean)
        {
            trigger OnValidate()
            begin
                if Rec.Enabled then
                    Rec.TestField("Retention Period")
            end;
        }
        field(6; "Retention Period"; Code[20])
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
        field(7; "Date Field No."; Integer)
        {
            TableRelation = Field."No." where(TableNo = field("Table ID"), "Type" = filter(Date | DateTime));

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
            Editable = False;
        }
        field(9; "Date Field Caption"; Text[80])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Table ID"), "No." = field("Date Field No.")));
            Editable = False;
        }

        field(10; "Table Filter"; Blob)
        {
            Access = Internal;
        }
        field(11; "Table Filter Text"; Text[2048])
        {
            Access = Internal;
        }
        field(12; Locked; Boolean)
        {
            Access = Internal;
            DataClassification = SystemMetadata;
            Editable = false;

            trigger OnValidate()
            begin
                if Locked then
                    validate(Enabled, true);
            end;
        }
    }


    keys
    {
        key(PrimaryKey; "Table ID", "Line No.")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// Use this procedure to open a Filter Page Builder page and store the resulting filter in view format on the current record.
    /// </summary>
    procedure SetTableFilter()
    var
        RetentionPolicySetup: Codeunit "Retention Policy Setup";
    begin
        Rec."Table Filter Text" := RetentionPolicySetup.SetTableFilterView(Rec);
    end;

    /// <summary>
    /// Use this procedure to get the filter in view format stored in the current record.
    /// </summary>
    /// <returns>The filter in the view format. </returns>
    procedure GetTableFilterView(): Text
    var
        RetentionPolicySetup: Codeunit "Retention Policy Setup";
    begin
        exit(RetentionPolicySetup.GetTableFilterView(Rec));
    end;

    /// <summary>
    /// Use this procedure to get the filter in text format stored in the current record.
    /// </summary>
    /// <returns>The Filter in text format.</returns>
    procedure GetTableFilterText(): Text[2048]
    var
        RetentionPolicySetup: Codeunit "Retention Policy Setup";
    begin
        exit(RetentionPolicySetup.GetTableFilterText(Rec));
    end;

    /// <summary>
    /// Use this procedure to verify whether the retention policy setup line is locked.
    /// </summary>
    /// <returns>True if the line is locked.</returns>
    procedure IsLocked(): Boolean
    begin
        exit(Rec.Locked)
    end;
}