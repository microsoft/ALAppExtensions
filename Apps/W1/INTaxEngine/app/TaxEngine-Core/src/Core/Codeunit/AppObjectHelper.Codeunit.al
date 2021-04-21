codeunit 20130 "App Object Helper"
{
    procedure GetObjectName(Type: ObjectType; ObjectID: Integer): Text[30];
    var
        AllObj: Record AllObj;
    begin
        if ObjectID = 0 then
            exit('');

        AllObj.Reset();
        AllObj.SetRange("Object Type", ObjectTypeToOption(Type));
        AllObj.SetRange("Object ID", ObjectID);
        if AllObj.FindFirst() then
            exit(AllObj."Object Name");
    end;

    procedure GetFieldName(TableID: Integer; FieldID: Integer): Text[30];
    var
        Field: Record Field;
    begin
        Field.Reset();
        Field.SetRange(TableNo, TableID);
        Field.SetRange("No.", FieldID);
        if Field.FindFirst() then
            exit(Field.FieldName);
    end;

    procedure GetFieldID(TableID: Integer; FieldNameTxt: Text[30]): Integer
    var
        Field: Record Field;
    begin
        Field.Reset();
        Field.SetRange(TableNo, TableID);
        Field.SetRange(FieldName, FieldNameTxt);
        if Field.FindFirst() then
            exit(Field."No.");
    end;

    procedure SearchTableField(TableID: Integer; var FieldID: Integer; var FieldName: Text[30]);
    var
        Field: Record Field;
        TmpFieldID: Integer;
        IsInteger: Boolean;
    begin
        if FieldName = '' then begin
            FieldID := 0;
            exit;
        end;

        IsInteger := Evaluate(TmpFieldID, FieldName, 2);

        Field.Reset();
        Field.SetRange(TableNo, TableID);
        if IsInteger then
            Field.SetRange("No.", TmpFieldID)
        else begin
            Field.SetCurrentKey(TableNo, "No.");
            Field.SetFilter(FieldName, '%1', '@' + FieldName + '*');
        end;

        if Field.FindFirst() then begin
            FieldID := Field."No.";
            FieldName := Field.FieldName;
        end else
            Error(InvalidFieldNoErr, FieldName);
    end;

    procedure SearchTableFieldOfType(TableID: Integer; var FieldID: Integer; var FieldName: Text[30]; Datatype: Enum "Symbol Data Type");
    var
        Field: Record Field;
        TmpFieldID: Integer;
        IsInteger: Boolean;
    begin
        if FieldName = '' then begin
            FieldID := 0;
            exit;
        end;

        IsInteger := Evaluate(TmpFieldID, FieldName, 2);

        Field.Reset();
        Field.SetRange(TableNo, TableID);
        SetFieldDataTypeFilter(Field, Datatype);
        if IsInteger then
            Field.SetRange("No.", TmpFieldID)
        else begin
            Field.SetCurrentKey(TableNo, "No.");
            Field.SetFilter(FieldName, '%1', '@' + FieldName + '*');
        end;

        if Field.FindFirst() then begin
            FieldID := Field."No.";
            FieldName := Field.FieldName;
        end else
            Error(InvalidFieldNoErr, FieldName);
    end;

    procedure OpenFieldLookup(TableID: Integer; var FieldID: Integer; var FieldName: Text[30]; SearchText: Text);
    var
        Field: Record Field;
    begin
        if TableID = 0 then
            exit;

        Field.Reset();
        Field.SetRange(TableNo, TableID);
        Field.TableNo := TableID;
        if FieldID <> 0 then begin
            Field."No." := FieldID;
            Field.Find();
        end else
            if SearchText <> '' then begin
                Field.FieldName := CopyStr(SearchText, 1, 30);
                Field.Find('<>=');
            end;

        if Page.RunModal(Page::"Field Lookup", Field) = Action::LookupOK then begin
            FieldID := Field."No.";
            FieldName := Field.FieldName;
        end;
    end;

    procedure OpenFieldLookupOfType(TableID: Integer; var FieldID: Integer; var FieldName: Text[30]; SearchText: Text; Datatype: Enum "Symbol Data Type");
    var
        Field: Record Field;
    begin
        if TableID = 0 then
            exit;

        Field.Reset();
        Field.SetRange(TableNo, TableID);
        Field.TableNo := TableID;
        Field.FilterGroup(2);
        SetFieldDataTypeFilter(Field, Datatype);
        Field.FilterGroup(0);
        if FieldID <> 0 then begin
            Field."No." := FieldID;
            Field.Find();
        end else
            if SearchText <> '' then begin
                Field.FieldName := CopyStr(SearchText, 1, 30);
                Field.Find('<>=');
            end;

        if Page.RunModal(Page::"Field Lookup", Field) = Action::LookupOK then begin
            FieldID := Field."No.";
            FieldName := Field.FieldName;
        end;
    end;

    procedure SearchObject(Type: ObjectType; var ObjectID: Integer; var ObjectName: Text[30]);
    var
        AllObj: Record AllObj;
        TmpObjectID: Integer;
        IsInteger: Boolean;
    begin
        IsInteger := Evaluate(TmpObjectID, ObjectName, 2);

        AllObj.Reset();
        AllObj.SetRange("Object Type", ObjectTypeToOption(Type));
        if IsInteger then
            AllObj.SetRange("Object ID", TmpObjectID)
        else begin
            AllObj.SetCurrentKey("Object Type", "Object Name");
            AllObj.SetFilter("Object Name", '%1', '@' + ObjectName + '*');
        end;
        if AllObj.FindFirst() then begin
            ObjectID := AllObj."Object ID";
            ObjectName := AllObj."Object Name";
        end else
            if IsInteger and (TmpObjectID = 0) then begin
                ObjectID := 0;
                ObjectName := '';
            end else
                Error(InvalidObjectNoErr, ObjectName);
    end;

    procedure GetObjectID(Type: ObjectType; Name: Text[30]): Integer;
    var
        AllObj: Record AllObj;
    begin
        if Name = '' then
            exit(0);

        AllObj.Reset();
        AllObj.SetRange("Object Type", ObjectTypeToOption(Type));
        AllObj.SetRange("Object Name", Name);
        if AllObj.FindFirst() then
            exit(AllObj."Object ID");
    end;

    procedure OpenObjectLookup(Type: ObjectType; SearchText: Text; var ObjectID: Integer; var ObjectName: Text[30]);
    var
        AllObj: Record AllObj;
    begin
        AllObj.Reset();
        AllObj.SetRange("Object Type", ObjectTypeToOption(Type));
        AllObj."Object Type" := ObjectTypeToOption(Type);
        if ObjectID <> 0 then begin
            AllObj."Object ID" := ObjectID;
            AllObj.Find('=');
        end else
            if SearchText <> '' then begin
                AllObj."Object Name" := CopyStr(SearchText, 1, 30);
                AllObj.Find('<>=');
            end;

        if Page.RunModal(Page::"All Objects", AllObj) = Action::LookupOK then begin
            ObjectID := AllObj."Object ID";
            ObjectName := AllObj."Object Name";
        end;
    end;

    local procedure ObjectTypeToOption(Type: ObjectType): Option;
    var
        AllObj: Record AllObj;
    begin
        case Type of
            Type::Codeunit:
                exit(AllObj."Object Type"::Codeunit);
            Type::MenuSuite:
                exit(AllObj."Object Type"::MenuSuite);
            Type::Page:
                exit(AllObj."Object Type"::Page);
            Type::Query:
                exit(AllObj."Object Type"::Query);
            Type::Report:
                exit(AllObj."Object Type"::Report);
            Type::Table:
                exit(AllObj."Object Type"::Table);
            Type::XmlPort:
                exit(AllObj."Object Type"::XmlPort);
        end;
    end;

    local procedure SetFieldDataTypeFilter(var Field: Record Field; DataType: Enum "Symbol Data Type")
    begin
        case Datatype of
            "Symbol Data Type"::String:
                Field.SetFilter(type, '%1|%2', Field.Type::Code, Field.Type::Text);
            "Symbol Data Type"::Option:
                Field.SetFilter(Type, '%1|%2', Field.Type::Option, Field.Type::Integer);
            "Symbol Data Type"::Boolean:
                Field.SetRange(Type, Field.Type::Boolean);
            "Symbol Data Type"::Date:
                Field.SetRange(Type, Field.Type::Date);
            "Symbol Data Type"::Time:
                Field.SetRange(Type, Field.Type::Time);
            "Symbol Data Type"::Datetime:
                Field.SetRange(Type, Field.Type::DateTime);
            "Symbol Data Type"::Number:
                Field.SetFilter(Type, '%1|%2|%3|%4', Field.Type::Option, Field.Type::Integer, Field.Type::Decimal, Field.Type::BigInteger);
        end;
    end;

    var
        InvalidFieldNoErr: Label 'You cannot enter ''%1'' in FieldNo.', Comment = '%1 = Field Name or Field No.';
        InvalidObjectNoErr: Label 'You cannot enter ''%1'' in ObjectNo.', Comment = '%1 = Object Name or Object No.';
}