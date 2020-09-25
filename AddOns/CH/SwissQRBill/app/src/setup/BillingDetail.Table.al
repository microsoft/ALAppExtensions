table 11518 "Swiss QR-Bill Billing Detail"
{
    DataClassification = CustomerContent;
    DrillDownPageId = "Swiss QR-Bill Billing Details";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Format Code"; Code[10])
        {
            Caption = 'Format Code';
        }
        field(3; "Tag Code"; Code[10])
        {
            Caption = 'Tag';
        }
        field(4; "Tag Value"; Text[100])
        {
            Caption = 'Value';
        }
        field(5; "Tag Type"; Enum "Swiss QR-Bill Billing Detail")
        {
            Caption = 'Type';
        }
        field(6; "Tag Description"; Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    internal procedure AddBufferRecord(FormatCode: Code[10]; TagType: Enum "Swiss QR-Bill Billing Detail"; TagValue: Text; TagDescription: Text)
    begin
        AddBufferRecordLcl(FormatCode, TagType, MapTagTypeToTagCode(FormatCode, TagType), TagValue, TagDescription);
    end;

    internal procedure AddBufferRecord(FormatCode: Code[10]; TagCode: Code[10]; TagValue: Text)
    begin
        AddBufferRecordLcl(FormatCode, MapTagCodeToTagType(FormatCode, TagCode), TagCode, TagValue, '');
    end;

    local procedure AddBufferRecordLcl(FormatCode: Code[10]; TagType: Enum "Swiss QR-Bill Billing Detail"; TagCode: Code[10]; TagValue: Text; TagDescription: Text)
    begin
        "Entry No." += 1;
        "Format Code" := FormatCode;
        "Tag Type" := TagType;
        "Tag Code" := TagCode;
        "Tag Value" := CopyStr(TagValue, 1, MaxStrLen("Tag Value"));
        "Tag Description" := CopyStr(TagDescription, 1, MaxStrLen("Tag Description"));
        Insert();
    end;

    local procedure MapTagTypeToTagCode(FormatCode: Code[10]; TagType: Enum "Swiss QR-Bill Billing Detail"): Code[10]
    begin
        if FormatCode = 'S1' then
            case TagType of
                "Tag Type"::"Document No.":
                    exit('10');
                "Tag Type"::"Document Date":
                    exit('11');
                "Tag Type"::"Creditor Reference":
                    exit('20');
                "Tag Type"::"VAT Registration No.":
                    exit('30');
                "Tag Type"::"VAT Date":
                    exit('31');
                "Tag Type"::"VAT Details":
                    exit('32');
                "Tag Type"::"VAT Purely On Import":
                    exit('33');
                "Tag Type"::"Payment Terms":
                    exit('40');
            end;
    end;

    local procedure MapTagCodeToTagType(FormatCode: Code[10]; TagCode: Code[10]) TagType: Enum "Swiss QR-Bill Billing Detail"
    begin
        TagType := "Tag Type"::Unknown;
        if FormatCode = 'S1' then
            case TagCode of
                '10':
                    TagType := "Tag Type"::"Document No.";
                '11':
                    TagType := "Tag Type"::"Document Date";
                '20':
                    TagType := "Tag Type"::"Creditor Reference";
                '30':
                    TagType := "Tag Type"::"VAT Registration No.";
                '31':
                    TagType := "Tag Type"::"VAT Date";
                '32':
                    TagType := "Tag Type"::"VAT Details";
                '33':
                    TagType := "Tag Type"::"VAT Purely On Import";
                '40':
                    TagType := "Tag Type"::"Payment Terms";
            end;
        exit(TagType);
    end;
}
