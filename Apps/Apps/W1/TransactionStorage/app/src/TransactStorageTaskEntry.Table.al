namespace System.DataAdministration;

using System.Reflection;

table 6202 "Transact. Storage Task Entry"
{
    DataClassification = SystemMetadata;
    Access = Internal;
    InherentEntitlements = rimX;
    InherentPermissions = rimX;
    Permissions = tabledata "Transact. Storage Task Entry" = rim;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(3; "Task ID"; Guid)
        {
            Editable = false;
        }
        field(4; Status; Enum "Trans. Storage Export Status")
        {
            Editable = false;
        }
        field(5; "Error Message"; Text[1024])
        {
            Editable = false;
        }
        field(6; "Error Call Stack"; Blob)
        {
        }
        field(7; "Starting Date/Time"; DateTime)
        {
            Editable = false;
        }
        field(8; "Ending Date/Time"; DateTime)
        {
            Editable = false;
        }
        field(9; "Is First Attempt"; Boolean)
        {
            Editable = false;
        }
        field(10; "Scheduled Date/Time"; DateTime)
        {
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Is First Attempt")
        {
        }
    }

    procedure SetStatusStarted()
    begin
        Rec.Status := Rec.Status::Started;
        Rec."Error Message" := '';
        Clear(Rec."Error Call Stack");
        Rec."Starting Date/Time" := CurrentDateTime();
        Rec."Ending Date/Time" := 0DT;
        Rec.Modify();
    end;

    procedure SetStatusCompleted()
    begin
        Rec.Status := Rec.Status::Completed;
        Rec."Ending Date/Time" := CurrentDateTime();
        Rec.Modify();
    end;

    procedure SetStatusFailed(ErrorText: Text; ErrorCallStack: Text)
    begin
        Rec.Status := Rec.Status::Failed;
        Rec."Error Message" := CopyStr(ErrorText, 1, MaxStrLen(Rec."Error Message"));
        Rec.SetErrorCallStack(ErrorCallStack);
        Rec.Modify();
    end;

    procedure GetErrorCallStack(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        if not "Error Call Stack".HasValue() then
            exit('');
        CalcFields("Error Call Stack");
        "Error Call Stack".CreateInStream(InStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    procedure SetErrorCallStack(NewCallStack: Text)
    var
        OutStream: OutStream;
    begin
        "Error Call Stack".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.Write(NewCallStack);
    end;

    procedure ShowErrorCallStack()
    var
        CallStack: Text;
    begin
        CallStack := GetErrorCallStack();
        if CallStack <> '' then
            Message(CallStack);
    end;
}