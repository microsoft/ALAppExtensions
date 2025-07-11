namespace Microsoft.Integration.Shopify;

/// <summary>
/// Table Shpfy Tag (ID 30104).
/// </summary>
table 30104 "Shpfy Tag"
{
    Caption = 'Shopify Tag';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Parent Table No."; Integer)
        {
            Caption = 'Parent Table No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(2; "Parent Id"; BigInteger)
        {
            Caption = 'Parent Entry No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(3; Tag; Text[255])
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Parent Id", Tag)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        Tag: Record "Shpfy Tag";
        MaxTagsErr: Label 'You can only specify 250 tags.';
    begin
        Tag.SetRange("Parent Id", "Parent Id");
        if Tag.Count() >= 250 then
            Error(MaxTagsErr);
    end;

    /// <summary> 
    /// Get Comma Seperated Tags.
    /// </summary>
    /// <param name="ParentId">Parameter of type BigInteger.</param>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetCommaSeparatedTags(ParentId: BigInteger): Text
    var
        Tags: TextBuilder;
    begin
        Rec.SetRange("Parent Id", ParentId);
        if Rec.FindSet(false) then begin
            repeat
                Tags.Append(',');
                Tags.Append(Rec.Tag);
            until Rec.Next() = 0;
            Tags.Remove(1, 1);
        end;
        exit(Tags.ToText());
    end;

    /// <summary> 
    /// Update Tags.
    /// </summary>
    /// <param name="ParentTableNo">Parameter of type Integer.</param>
    /// <param name="ParentId">Parameter of type BigInteger.</param>
    /// <param name="CommaSeperatedTags">Parameter of type Text.</param>
    internal procedure UpdateTags(ParentTableNo: Integer; ParentId: BigInteger; CommaSeperatedTags: Text)
    var
        Tag: Record "Shpfy Tag";
        Tags: List of [Text];
        TagTxt: Text;
    begin
        Tag.SetRange("Parent Id", ParentId);
        if not Tag.IsEmpty() then
            Tag.DeleteAll();
        Tags := CommaSeperatedTags.Split(',');
        foreach TagTxt in Tags do begin
            TagTxt := TagTxt.Trim();
            if TagTxt <> '' then begin
                Clear(Tag);
                Tag."Parent Table No." := ParentTableNo;
                Tag."Parent Id" := ParentId;
                Tag.Tag := CopyStr(TagTxt, 1, MaxStrLen(Tag.Tag));
                Tag.Insert();
            end;
        end;
    end;
}