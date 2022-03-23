/// <summary>
/// TableExtension Shpfy Job Queue Entry (ID 301000) extends Record Job Queue Entry.
/// </summary>
tableextension 30100 "Shpfy Job Queue Entry" extends "Job Queue Entry"
{
    fields
    {
        field(30100; "Shpfy Filter"; Blob)
        {
            Caption = 'Filter';
            DataClassification = SystemMetadata;
        }
    }

    /// <summary> 
    /// Description for GetFilterString.
    /// </summary>
    internal procedure GetFilterString() Content: Text
    var
        Stream: InStream;
    begin
        CalcFields("Shpfy Filter");
        "Shpfy Filter".CreateInStream(Stream, TextEncoding::UTF8);
        Stream.Read(Content);
    end;

    /// <summary> 
    /// Description for SetFilterString.
    /// </summary>
    /// <param name="Data">Parameter of type Text.</param>
    internal procedure SetFilterString(Data: Text)
    var
        Stream: OutStream;
    begin
        Clear("Shpfy Filter");
        "Shpfy Filter".CreateOutStream(Stream, TextEncoding::UTF8);
        Stream.WriteText(Data);
    end;
}
