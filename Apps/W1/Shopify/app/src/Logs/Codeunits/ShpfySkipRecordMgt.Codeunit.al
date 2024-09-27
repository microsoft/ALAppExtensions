namespace Microsoft.Integration.Shopify;

codeunit 30168 "Shpfy Skip Record Mgt."
{
    Access = Internal;
    Permissions = tabledata "Shpfy Skipped Record" = rimd;

    internal procedure LogSkippedRecord(ShopifyId: BigInteger; TableId: Integer; RecordId: RecordID; SkippedReason: Text[250])
    var
        ShpfySkippedRecord: Record "Shpfy Skipped Record";
    begin
        ShpfySkippedRecord.Init();
        ShpfySkippedRecord.Validate("Shopify Id", ShopifyId);
        ShpfySkippedRecord.Validate("Table ID", TableId);
        ShpfySkippedRecord.Validate("Record ID", RecordId);
        ShpfySkippedRecord.Validate("Skipped Reason", SkippedReason);
        ShpfySkippedRecord.Validate("Created On", CURRENTDATETIME);
        ShpfySkippedRecord.Insert(false);
    end;

}
