tableextension 1680 "Attachment Internet Message Id" extends Attachment
{
    fields
    {
        field(1680; "Internet Message ID"; Blob)
        {
            Caption = 'Internet Message ID';
        }
        field(1681; "Internet Message Checksum"; Integer)
        {
            Caption = 'Internet Message Checksum';
        }
    }
    keys
    {
        key(Key1680; "Internet Message Checksum")
        {
        }
    }

    internal procedure GetInternetMessageID() Return: Text
    var
        InStream: InStream;
    begin
        CalcFields("Internet Message ID");
        "Internet Message ID".CreateInStream(InStream);
        InStream.ReadText(Return);
    end;

    internal procedure SetInternetMessageID(InternetMessageID: Text)
    var
        OutStream: OutStream;
    begin
        Clear("Internet Message ID");
        "Internet Message ID".CreateOutStream(OutStream);
        OutStream.WriteText(InternetMessageID);
        "Internet Message Checksum" := Checksum(InternetMessageId);
    end;
}