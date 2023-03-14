/// <summary>
/// Codeunit Shpfy Hash (ID 30156).
/// </summary>
codeunit 30156 "Shpfy Hash"
{
    Access = Internal;

    /// <summary> X
    /// Calc Hash.
    /// </summary>
    /// <param name="TenantMedia">Parameter of type Record "Tenant Media".</param>
    /// <returns>Return value of type Integer.</returns>
    local procedure CalcHash(TenantMedia: Record "Tenant Media"): Integer
    var
        InStream: InStream;
    begin
        TenantMedia.CalcFields(Content);
        if TenantMedia.Content.HasValue then begin
            TenantMedia.Content.CreateInStream(InStream);
            exit(CalcHash(InStream, TenantMedia.Content.Length));
        end;
    end;

    /// <summary> 
    /// Calc Hash.
    /// </summary>
    /// <param name="Stream">Parameter of type InStream.</param>
    /// <param name="Length">Parameter of type Integer.</param>
    /// <returns>Return value of type Integer.</returns>
    local procedure CalcHash(Stream: InStream; Length: Integer): Integer
    var
        Hash: BigInteger;
        MaxInt: BigInteger;
        ByteData: Byte;
        Index: Integer;
    begin
        MaxInt := Power(2, 31);
        while not Stream.EOS() do begin
            Index += 1;
            Stream.Read(ByteData);
            Hash += ByteData * Power(7, (Length - Index) mod (13));
            if Hash > MaxInt then
                Hash := Hash mod MaxInt;
        end;
        exit(Hash);
    end;

    /// <summary> 
    /// Calc Hash.
    /// </summary>
    /// <param name="Data">Parameter of type Text.</param>
    /// <returns>Return value of type Integer.</returns>
    internal procedure CalcHash(Data: Text): Integer
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        Length: Integer;
        OutStream: OutStream;
    begin
        if Data = '' then
            exit(0);
        TempBlob.CreateOutStream(OutStream);
        TempBlob.CreateInStream(InStream);
        Length := OutStream.WriteText(Data);
        exit(CalcHash(InStream, Length));
    end;

    /// <summary> 
    /// Calc Item Image Hash.
    /// </summary>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <returns>Return value of type Integer.</returns>
    internal procedure CalcItemImageHash(Item: Record Item): Integer
    var
        TenantMedia: Record "Tenant Media";
        MediaId: Guid;
    begin
        if Item.Picture.Count > 0 then begin
            MediaId := Item.Picture.Item(1);
            if TenantMedia.Get(MediaId) then
                exit(CalcHash(TenantMedia));
        end;
    end;
}