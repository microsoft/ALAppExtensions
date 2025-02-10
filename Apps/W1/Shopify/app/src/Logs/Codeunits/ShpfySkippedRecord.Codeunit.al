namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Skipped Record (ID 30313).
/// </summary>
codeunit 30313 "Shpfy Skipped Record"
{
    Access = Internal;
    Permissions = tabledata "Shpfy Skipped Record" = rimd;

    var
        NotificationSent: Boolean;
        SkippedRecordsLbl: Label 'Some records were skipped during the synchronization.';
        ViewSkippedRecordsLbl: Label 'View Skipped Records';

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

        SendSkippedNotification();
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

    local procedure SendSkippedNotification()
    var
        SkippedNotification: Notification;
    begin
        if not GuiAllowed then
            exit;

        if NotificationSent then
            exit;

        SkippedNotification.Id := CreateGuid();
        SkippedNotification.Message := SkippedRecordsLbl;
        SkippedNotification.Scope := NotificationScope::LocalScope;
        SkippedNotification.AddAction(ViewSkippedRecordsLbl, Codeunit::"Shpfy Skipped Record", 'ViewSkippedRecords');
        SkippedNotification.Send();

        NotificationSent := true;
    end;

    internal procedure ViewSkippedRecords(SkippedNotification: Notification)
    begin
        Page.Run(Page::"Shpfy Skipped Records");
    end;
}
