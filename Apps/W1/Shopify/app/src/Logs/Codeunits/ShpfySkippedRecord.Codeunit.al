namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Skipped Record (ID 30313).
/// </summary>
codeunit 30313 "Shpfy Skipped Record"
{
    Access = Internal;
    Permissions = tabledata "Shpfy Skipped Record" = rimd;

    /// <summary>
    /// Creates log entry for skipped record.
    /// </summary>
    /// <param name="ShopifyId">Related Shopify Id of the record.</param>
    /// <param name="TableId">Table Id of the record.</param>
    /// <param name="RecordId">Record Id of the record.</param>
    /// <param name="SkippedReason">Reason for skipping the record.</param>
    /// <param name="Shop">Shop record.</param>
    internal procedure LogSkippedRecord(ShopifyId: BigInteger; RecordId: RecordID; SkippedReason: Text[250]; Shop: Record "Shpfy Shop")
    var
        SkippedRecord: Record "Shpfy Skipped Record";
    begin
        if Shop."Logging Mode" = Enum::"Shpfy Logging Mode"::Disabled then
            exit;
        SkippedRecord.Init();
        SkippedRecord.Validate("Shopify Id", ShopifyId);
        SkippedRecord.Validate("Table ID", RecordId.TableNo());
        SkippedRecord.Validate("Record ID", RecordId);
        SkippedRecord.Validate("Skipped Reason", SkippedReason);
        SkippedRecord.Insert(true);
    end;

    /// <summary>
    /// Creates log entry for skipped recordwith empty Shopify Id.
    /// </summary>
    /// <param name="RecordId">Record Id of the record.</param>
    /// <param name="SkippedReason">Reason for skipping the record.</param>
    /// <param name="Shop">Shop record.</param>
    internal procedure LogSkippedRecord(RecordId: RecordID; SkippedReason: Text[250]; Shop: Record "Shpfy Shop")
    begin
        LogSkippedRecord(0, RecordId, SkippedReason, Shop);
    end;

}
