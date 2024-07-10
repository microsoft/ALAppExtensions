namespace System.DataAdministration;

table 6205 "Trans. Storage Export Data"
{
    Access = Internal;
    DataClassification = OrganizationIdentifiableInformation;
    InherentEntitlements = rimdX;
    InherentPermissions = rimdX;
    Permissions = tabledata "Trans. Storage Export Data" = rimd;

    fields
    {
        field(1; "Table ID"; Integer)
        {
        }
        field(2; Part; Integer)
        {
        }
        field(3; Content; Blob)
        {
        }
        field(4; "Record Count"; Integer)
        {

        }
    }

    keys
    {
        key(PK; "Table ID", Part)
        {
            Clustered = true;
        }
    }

    internal procedure Add(var NewPart: Integer; var JsonArray: JsonArray; TableID: Integer; RecordCount: Integer)
    var
        OutStream: OutStream;
    begin
        Rec.Init();
        Rec."Table ID" := TableID;
        NewPart += 1;
        Rec.Part := NewPart;
        Rec.Content.CreateOutStream(OutStream, TextEncoding::UTF8);
        JsonArray.WriteTo(OutStream);
        Rec."Record Count" := RecordCount;
        Rec.Insert();
    end;
}