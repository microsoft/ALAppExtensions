/// <summary>
/// Table Shpfy Tag (ID 30104).
/// </summary>
table 30104 "Shpfy Tag"
{
    Access = Internal;
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
        ShopifyTag: Record "Shpfy Tag";
        MaxTagsErr: Label 'You can only specify 250 tags.';
    begin
        ShopifyTag.SetRange("Parent Id", "Parent Id");
        if ShopifyTag.Count() >= 250 then
            Error(MaxTagsErr);
    end;

    /// <summary> 
    /// Get Comma Seperated Tags.
    /// </summary>
    /// <param name="ParentId">Parameter of type BigInteger.</param>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetCommaSeperatedTags(ParentId: BigInteger): Text
    var
        ShopifyTag: Record "Shpfy Tag";
        Tags: TextBuilder;
    begin
        ShopifyTag.SetRange("Parent Id", ParentId);
        if ShopifyTag.FindSet(false, false) then begin
            repeat
                Tags.Append(',');
                Tags.Append(ShopifyTag.Tag);
            until ShopifyTag.Next() = 0;
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
        ShopifyTag: Record "Shpfy Tag";
        Tags: List of [Text];
        TagTxt: Text;
    begin
        ShopifyTag.SetRange("Parent Id", ParentId);
        if not ShopifyTag.IsEmpty() then
            ShopifyTag.DeleteAll();
        Tags := CommaSeperatedTags.Split(',');
        foreach TagTxt in Tags do begin
            TagTxt := TagTxt.Trim();
            if TagTxt <> '' then begin
                Clear(ShopifyTag);
                ShopifyTag."Parent Table No." := ParentTableNo;
                ShopifyTag."Parent Id" := ParentId;
                ShopifyTag.Tag := CopyStr(TagTxt, 1, MaxStrLen(ShopifyTag.Tag));
                ShopifyTag.Insert();
            end;
        end;
    end;

    /// <summary> 
    /// Update Tags.
    /// </summary>
    /// <param name="ParentTableNo">Parameter of type Integer.</param>
    /// <param name="ParentId">Parameter of type BigInteger.</param>
    /// <param name="JTags">Parameter of type JsonArray.</param>
    internal procedure UpdateTags(ParentTableNo: Integer; ParentId: BigInteger; JTags: JsonArray)
    var
        ShopifyTag: Record "Shpfy Tag";
        JTag: JsonToken;
        Index: Integer;
    begin
        ShopifyTag.SetRange("Parent Id", ParentId);
        if not ShopifyTag.IsEmpty() then
            ShopifyTag.DeleteAll();

        for Index := 1 to JTags.Count do
            if JTags.Get(Index, JTag) then
                if JTag.IsValue and not (JTag.AsValue().IsNull or JTag.AsValue().IsUndefined) then begin
                    Clear(ShopifyTag);
                    ShopifyTag."Parent Table No." := ParentTableNo;
                    ShopifyTag."Parent Id" := ParentId;
                    ShopifyTag.Tag := CopyStr(JTag.AsValue().AsText().Trim(), 1, MaxStrLen(ShopifyTag.Tag));
                    ShopifyTag.Insert();
                end;
    end;
}