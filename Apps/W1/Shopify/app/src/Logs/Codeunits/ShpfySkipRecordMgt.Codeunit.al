namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Skip Record Mgt. (ID 30168).
/// </summary>
codeunit 30168 "Shpfy Skip Record Mgt."
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
    internal procedure LogSkippedRecord(ShopifyId: BigInteger; TableId: Integer; RecordId: RecordID; SkippedReason: Text[250]; Shop: Record "Shpfy Shop")
    var
        ShpfySkippedRecord: Record "Shpfy Skipped Record";
    begin
        if Shop."Logging Mode" = Enum::"Shpfy Logging Mode"::Disabled then
            exit;
        ShpfySkippedRecord.Init();
        ShpfySkippedRecord.Validate("Shopify Id", ShopifyId);
        ShpfySkippedRecord.Validate("Table ID", TableId);
        ShpfySkippedRecord.Validate("Record ID", RecordId);
        ShpfySkippedRecord.Validate("Skipped Reason", SkippedReason);
        ShpfySkippedRecord.Validate("Created On", CurrentDateTime);
        ShpfySkippedRecord.Validate("Created Time", DT2Time(CurrentDateTime));
        ShpfySkippedRecord.Insert(false);
    end;

}
