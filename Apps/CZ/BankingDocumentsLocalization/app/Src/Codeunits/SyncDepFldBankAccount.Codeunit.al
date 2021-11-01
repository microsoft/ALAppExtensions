#if not CLEAN19
#pragma warning disable AL0432
codeunit 31340 "Sync.Dep.Fld-BankAccount CZB"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertBankAccount(var Rec: Record "Bank Account")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyBankAccount(var Rec: Record "Bank Account")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var BankAccount: Record "Bank Account")
    var
        PreviousBankAccount: Record "Bank Account";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(BankAccount, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousBankAccount);

        DepFieldTxt := BankAccount."Default Constant Symbol";
        NewFieldTxt := BankAccount."Default Constant Symbol CZB";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousBankAccount."Default Constant Symbol", PreviousBankAccount."Default Constant Symbol CZB");
        BankAccount."Default Constant Symbol" := CopyStr(DepFieldTxt, 1, MaxStrLen(BankAccount."Default Constant Symbol"));
        BankAccount."Default Constant Symbol CZB" := CopyStr(NewFieldTxt, 1, MaxStrLen(BankAccount."Default Constant Symbol CZB"));
        DepFieldTxt := BankAccount."Default Specific Symbol";
        NewFieldTxt := BankAccount."Default Specific Symbol CZB";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousBankAccount."Default Specific Symbol", PreviousBankAccount."Default Specific Symbol CZB");
        BankAccount."Default Specific Symbol" := CopyStr(DepFieldTxt, 1, MaxStrLen(BankAccount."Default Specific Symbol"));
        BankAccount."Default Specific Symbol CZB" := CopyStr(NewFieldTxt, 1, MaxStrLen(BankAccount."Default Specific Symbol CZB"));
        SyncDepFldUtilities.SyncFields(BankAccount."Domestic Payment Order", BankAccount."Domestic Payment Order ID CZB", PreviousBankAccount."Domestic Payment Order", PreviousBankAccount."Domestic Payment Order ID CZB");
        SyncDepFldUtilities.SyncFields(BankAccount."Foreign Payment Order", BankAccount."Foreign Payment Order ID CZB", PreviousBankAccount."Foreign Payment Order", PreviousBankAccount."Foreign Payment Order ID CZB");
        SyncDepFldUtilities.SyncFields(BankAccount."Dimension from Apply Entry", BankAccount."Dimension from Apply Entry CZB", PreviousBankAccount."Dimension from Apply Entry", PreviousBankAccount."Dimension from Apply Entry CZB");
        SyncDepFldUtilities.SyncFields(BankAccount."Check Ext. No. by Current Year", BankAccount."Check Ext. No. Curr. Year CZB", PreviousBankAccount."Check Ext. No. by Current Year", PreviousBankAccount."Check Ext. No. Curr. Year CZB");
        SyncDepFldUtilities.SyncFields(BankAccount."Check Czech Format on Issue", BankAccount."Check CZ Format on Issue CZB", PreviousBankAccount."Check Czech Format on Issue", PreviousBankAccount."Check CZ Format on Issue CZB");
        SyncDepFldUtilities.SyncFields(BankAccount."Variable S. to Description", BankAccount."Variable S. to Description CZB", PreviousBankAccount."Variable S. to Description", PreviousBankAccount."Variable S. to Description CZB");
        SyncDepFldUtilities.SyncFields(BankAccount."Variable S. to Variable S.", BankAccount."Variable S. to Variable S. CZB", PreviousBankAccount."Variable S. to Variable S.", PreviousBankAccount."Variable S. to Variable S. CZB");
        SyncDepFldUtilities.SyncFields(BankAccount."Variable S. to Ext. Doc.No.", BankAccount."Variable S. to Ext.Doc.No. CZB", PreviousBankAccount."Variable S. to Ext. Doc.No.", PreviousBankAccount."Variable S. to Variable S. CZB");
        SyncDepFldUtilities.SyncFields(BankAccount."Foreign Payment Orders", BankAccount."Foreign Payment Orders CZB", PreviousBankAccount."Foreign Payment Orders", PreviousBankAccount."Foreign Payment Orders CZB");
        SyncDepFldUtilities.SyncFields(BankAccount."Post Per Line", BankAccount."Post Per Line CZB", PreviousBankAccount."Post Per Line", PreviousBankAccount."Post Per Line CZB");
        SyncDepFldUtilities.SyncFields(BankAccount."Payment Partial Suggestion", BankAccount."Payment Partial Suggestion CZB", PreviousBankAccount."Payment Partial Suggestion", PreviousBankAccount."Payment Partial Suggestion CZB");
        DepFieldTxt := BankAccount."Payment Order Line Description";
        NewFieldTxt := BankAccount."Payment Order Line Descr. CZB";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousBankAccount."Payment Order Line Description", PreviousBankAccount."Payment Order Line Descr. CZB");
        BankAccount."Payment Order Line Description" := CopyStr(DepFieldTxt, 1, MaxStrLen(BankAccount."Payment Order Line Description"));
        BankAccount."Payment Order Line Descr. CZB" := CopyStr(NewFieldTxt, 1, MaxStrLen(BankAccount."Payment Order Line Descr. CZB"));
        DepFieldTxt := BankAccount."Non Associated Payment Account";
        NewFieldTxt := BankAccount."Non Assoc. Payment Account CZB";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousBankAccount."Non Associated Payment Account", PreviousBankAccount."Non Assoc. Payment Account CZB");
        BankAccount."Non Associated Payment Account" := CopyStr(DepFieldTxt, 1, MaxStrLen(BankAccount."Non Associated Payment Account"));
        BankAccount."Non Assoc. Payment Account CZB" := CopyStr(NewFieldTxt, 1, MaxStrLen(BankAccount."Non Assoc. Payment Account CZB"));
        DepFieldTxt := BankAccount."Base Calendar Code";
        NewFieldTxt := BankAccount."Base Calendar Code CZB";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousBankAccount."Base Calendar Code", PreviousBankAccount."Base Calendar Code CZB");
        BankAccount."Base Calendar Code" := CopyStr(DepFieldTxt, 1, MaxStrLen(BankAccount."Base Calendar Code"));
        BankAccount."Base Calendar Code CZB" := CopyStr(NewFieldTxt, 1, MaxStrLen(BankAccount."Base Calendar Code CZB"));
        DepFieldTxt := BankAccount."Payment Jnl. Template Name";
        NewFieldTxt := BankAccount."Payment Jnl. Template Name CZB";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousBankAccount."Payment Jnl. Template Name", PreviousBankAccount."Payment Jnl. Template Name CZB");
        BankAccount."Payment Jnl. Template Name" := CopyStr(DepFieldTxt, 1, MaxStrLen(BankAccount."Payment Jnl. Template Name"));
        BankAccount."Payment Jnl. Template Name CZB" := CopyStr(NewFieldTxt, 1, MaxStrLen(BankAccount."Payment Jnl. Template Name CZB"));
        DepFieldTxt := BankAccount."Payment Jnl. Batch Name";
        NewFieldTxt := BankAccount."Payment Jnl. Batch Name CZB";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousBankAccount."Payment Jnl. Batch Name", PreviousBankAccount."Payment Jnl. Batch Name CZB");
        BankAccount."Payment Jnl. Batch Name" := CopyStr(DepFieldTxt, 1, MaxStrLen(BankAccount."Payment Jnl. Batch Name"));
        BankAccount."Payment Jnl. Batch Name CZB" := CopyStr(NewFieldTxt, 1, MaxStrLen(BankAccount."Payment Jnl. Batch Name CZB"));
        DepFieldTxt := BankAccount."Foreign Payment Export Format";
        NewFieldTxt := BankAccount."Foreign Payment Ex. Format CZB";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousBankAccount."Foreign Payment Export Format", PreviousBankAccount."Foreign Payment Ex. Format CZB");
        BankAccount."Foreign Payment Export Format" := CopyStr(DepFieldTxt, 1, MaxStrLen(BankAccount."Foreign Payment Export Format"));
        BankAccount."Foreign Payment Ex. Format CZB" := CopyStr(NewFieldTxt, 1, MaxStrLen(BankAccount."Foreign Payment Ex. Format CZB"));
        DepFieldTxt := BankAccount."Payment Import Format";
        NewFieldTxt := BankAccount."Payment Import Format CZB";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousBankAccount."Payment Import Format", PreviousBankAccount."Payment Import Format CZB");
        BankAccount."Payment Import Format" := CopyStr(DepFieldTxt, 1, MaxStrLen(BankAccount."Payment Import Format"));
        BankAccount."Payment Import Format CZB" := CopyStr(NewFieldTxt, 1, MaxStrLen(BankAccount."Payment Import Format CZB"));
        DepFieldTxt := BankAccount."Payment Order Nos.";
        NewFieldTxt := BankAccount."Payment Order Nos. CZB";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousBankAccount."Payment Order Nos.", PreviousBankAccount."Payment Order Nos. CZB");
        BankAccount."Payment Order Nos." := CopyStr(DepFieldTxt, 1, MaxStrLen(BankAccount."Payment Order Nos."));
        BankAccount."Payment Order Nos. CZB" := CopyStr(NewFieldTxt, 1, MaxStrLen(BankAccount."Payment Order Nos. CZB"));
        DepFieldTxt := BankAccount."Issued Payment Order Nos.";
        NewFieldTxt := BankAccount."Issued Payment Order Nos. CZB";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousBankAccount."Issued Payment Order Nos.", PreviousBankAccount."Issued Payment Order Nos. CZB");
        BankAccount."Issued Payment Order Nos." := CopyStr(DepFieldTxt, 1, MaxStrLen(BankAccount."Issued Payment Order Nos."));
        BankAccount."Issued Payment Order Nos. CZB" := CopyStr(NewFieldTxt, 1, MaxStrLen(BankAccount."Issued Payment Order Nos. CZB"));
        DepFieldTxt := BankAccount."Bank Statement Nos.";
        NewFieldTxt := BankAccount."Bank Statement Nos. CZB";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousBankAccount."Bank Statement Nos.", PreviousBankAccount."Bank Statement Nos. CZB");
        BankAccount."Bank Statement Nos." := CopyStr(DepFieldTxt, 1, MaxStrLen(BankAccount."Bank Statement Nos."));
        BankAccount."Bank Statement Nos. CZB" := CopyStr(NewFieldTxt, 1, MaxStrLen(BankAccount."Bank Statement Nos. CZB"));
        DepFieldTxt := BankAccount."Issued Bank Statement Nos.";
        NewFieldTxt := BankAccount."Issued Bank Statement Nos. CZB";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousBankAccount."Issued Bank Statement Nos.", PreviousBankAccount."Issued Bank Statement Nos. CZB");
        BankAccount."Issued Bank Statement Nos." := CopyStr(DepFieldTxt, 1, MaxStrLen(BankAccount."Issued Bank Statement Nos."));
        BankAccount."Issued Bank Statement Nos. CZB" := CopyStr(NewFieldTxt, 1, MaxStrLen(BankAccount."Issued Bank Statement Nos. CZB"));
    end;
}
#endif
