table 10677 "SAF-T Mapping Source"
{
    DataClassification = CustomerContent;
    Caption = 'SAF-T Mapping Source';

    fields
    {
        field(1; ID; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'ID';
            AutoIncrement = true;
        }
        field(2; "Source Type"; Enum "SAF-T Mapping Source Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Source Type';
        }
        field(3; "Source No."; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Source No.';
            Editable = false;
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }

    var
        SourceExistsErr: Label 'There is a mapping source with this file name already loaded.';

    procedure ImportMappingSource()
    var
        MediaResources: Record "Media Resources";
        SAFTMappingSource: Record "SAF-T Mapping Source";
        SAFTXMLImport: Codeunit "SAF-T XML Import";
    begin
        testfield("Source Type");
        SAFTXMLImport.ImportXmlFileIntoMediaResources(MediaResources);
        if MediaResources.Code = '' then
            exit;

        "Source No." := MediaResources.Code;
        SAFTMappingSource.SetFilter(Id, '<>%1', ID);
        SAFTMappingSource.SetRange("Source No.", "Source No.");
        if not SAFTMappingSource.IsEmpty() then
            error(SourceExistsErr);
    end;

}
