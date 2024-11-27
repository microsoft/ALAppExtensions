codeunit 11123 "Contoso DE Digital Audit"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Data Export" = rim,
                tabledata "Data Export Record Type" = rim,
                tabledata "Data Export Record Definition" = rim,
                tabledata "Data Export Record Field" = rim,
                tabledata "Data Export Record Source" = rim,
                tabledata "Data Export Table Relation" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertDataExport(Code: Code[10]; Description: Text[50])
    var
        DataExport: Record "Data Export";
        Exists: Boolean;
    begin
        if DataExport.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        DataExport.Validate(Code, Code);
        DataExport.Validate(Description, Description);

        if Exists then
            DataExport.Modify(true)
        else
            DataExport.Insert(true);
    end;

    procedure InsertDataExportRecordType(Code: Code[10]; Description: Text[50])
    var
        DataExportRecordType: Record "Data Export Record Type";
        Exists: Boolean;
    begin
        if DataExportRecordType.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        DataExportRecordType.Validate(Code, Code);
        DataExportRecordType.Validate(Description, Description);

        if Exists then
            DataExportRecordType.Modify(true)
        else
            DataExportRecordType.Insert(true);
    end;

    procedure InsertDataExportRecordDefinition(DataExportCode: Code[10]; DataExpRecTypeCode: Code[10])
    var
        DataExportRecordDefinition: Record "Data Export Record Definition";
        Exists: Boolean;
    begin
        if DataExportRecordDefinition.Get(DataExportCode, DataExpRecTypeCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        DataExportRecordDefinition.Validate("Data Export Code", DataExportCode);
        DataExportRecordDefinition.Validate("Data Exp. Rec. Type Code", DataExpRecTypeCode);

        if Exists then
            DataExportRecordDefinition.Modify(true)
        else
            DataExportRecordDefinition.Insert(true);
    end;

    procedure InsertDataExportRecordSource(DataExportCode: Code[10]; DataExpRecTypeCode: Code[10]; LineNo: Integer; TableNo: Integer; Indentation: Integer; RelationToTableNo: Integer; RelationToLineNo: Integer; PeriodFieldNo: Integer; Filename: Text[250])
    var
        DataExportRecordSource: Record "Data Export Record Source";
        Exists: Boolean;
    begin
        if DataExportRecordSource.Get(DataExportCode, DataExpRecTypeCode, LineNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        DataExportRecordSource.Validate("Data Export Code", DataExportCode);
        DataExportRecordSource.Validate("Data Exp. Rec. Type Code", DataExpRecTypeCode);
        DataExportRecordSource.Validate("Table No.", TableNo);
        DataExportRecordSource.Indentation := Indentation;
        DataExportRecordSource."Relation To Table No." := RelationToTableNo;
        DataExportRecordSource."Relation To Line No." := RelationToLineNo;
        DataExportRecordSource.Validate("Period Field No.", PeriodFieldNo);
        DataExportRecordSource.Validate("Line No.", LineNo);
        DataExportRecordSource.Validate("Export File Name", Filename);

        if Exists then
            DataExportRecordSource.Modify(true)
        else
            DataExportRecordSource.Insert(true);
    end;

    procedure InsertDataExportRecordField(DataExportCode: Code[10]; DataExpRecTypeCode: Code[10]; SourceLineNo: Integer; TableNo: Integer; FieldNo: Integer; LineNo: Integer; DateFilterHandling: Integer)
    var
        DataExportRecordField: Record "Data Export Record Field";
        Exists: Boolean;
    begin
        if DataExportRecordField.Get(DataExportCode, DataExpRecTypeCode, SourceLineNo, TableNo, LineNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        DataExportRecordField.Validate("Data Export Code", DataExportCode);
        DataExportRecordField.Validate("Data Exp. Rec. Type Code", DataExpRecTypeCode);
        DataExportRecordField.Validate("Source Line No.", SourceLineNo);
        DataExportRecordField.Validate("Table No.", TableNo);
        DataExportRecordField.Validate("Field No.", FieldNo);
        DataExportRecordField.Validate("Line No.", LineNo);
        if DateFilterHandling <> 0 then
            DataExportRecordField.Validate("Date Filter Handling", DateFilterHandling);

        if Exists then
            DataExportRecordField.Modify(true)
        else
            DataExportRecordField.Insert(true);
    end;

    procedure InsertDataExportTableRelation(DataExportCode: Code[10]; DataExpRecTypeCode: Code[10]; FromTableNo: Integer; FromFieldNo: Integer; ToTableNo: Integer; ToFieldNo: Integer)
    var
        DataExportTableRelation: Record "Data Export Table Relation";
        Exists: Boolean;
    begin
        if DataExportTableRelation.Get(DataExportCode, DataExpRecTypeCode, FromTableNo, FromFieldNo, ToTableNo, ToFieldNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        DataExportTableRelation.Validate("Data Export Code", DataExportCode);
        DataExportTableRelation.Validate("Data Exp. Rec. Type Code", DataExpRecTypeCode);
        DataExportTableRelation.Validate("From Table No.", FromTableNo);
        DataExportTableRelation.Validate("From Field No.", FromFieldNo);
        DataExportTableRelation.Validate("To Table No.", ToTableNo);
        DataExportTableRelation.Validate("To Field No.", ToFieldNo);

        if Exists then
            DataExportTableRelation.Modify(true)
        else
            DataExportTableRelation.Insert(true);
    end;
}