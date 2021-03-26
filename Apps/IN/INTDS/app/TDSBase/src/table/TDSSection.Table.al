table 18692 "TDS Section"
{
    Caption = 'Section';
    DrillDownPageId = "TDS Sections";
    LookupPageId = "TDS Sections";
    DataCaptionFields = "Code", "Description";
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; ecode; Code[10])
        {
            Caption = 'ecode';
            DataClassification = CustomerContent;
        }
        field(4; Detail; Blob)
        {
            Caption = 'Detail';
            DataClassification = CustomerContent;
        }
        field(5; "Presentation Order"; Integer)
        {
            Caption = 'Presentation Order';
            DataClassification = CustomerContent;
        }
        field(6; "Indentation Level"; Integer)
        {
            Caption = 'Indentation Level';
            DataClassification = CustomerContent;
        }
        field(7; "Parent Code"; Code[20])
        {
            Caption = 'Parent Code';
            DataClassification = CustomerContent;
        }
        field(8; "Section Order"; Integer)
        {
            Caption = 'Section Order';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
        key(Key2; "Presentation Order") { }
    }

    trigger OnInsert()
    var
        TDSSection: Record "TDS Section";
        SubTDSSection: Record "TDS Section";
    begin
        if "Presentation Order" = 0 then begin
            TDSSection.SetCurrentKey("Presentation Order");
            if TDSSection.FindLast() then begin
                SubTDSSection.Reset();
                SubTDSSection.SetCurrentKey("Presentation Order");
                SubTDSSection.SetRange("Parent Code", Code);
                if SubTDSSection.FindLast() then
                    "Presentation Order" := SubTDSSection."Presentation Order" + 1
                else
                    "Presentation Order" := TDSSection."Presentation Order" + 20
            end else
                "Presentation Order" := 1;
        end;

        if "Section Order" = 0 then begin
            TDSSection.Reset();
            TDSSection.SetCurrentKey("Presentation Order");
            TDSSection.SetRange("Parent Code", "Parent Code");
            if TDSSection.FindLast() then
                "Section Order" := TDSSection."Section Order" + 1
            else
                "Section Order" := 1;
        end;
    end;
}