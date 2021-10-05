#if not CLEAN19
#pragma warning disable AL0432,AL0603
codeunit 31342 "Sync.Dep.Fld-IssPaymOrdLn CZB"
{
    Access = Internal;
    Permissions = tabledata "Issued Payment Order Line" = rimd,
                  tabledata "Iss. Payment Order Line CZB" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Issued Payment Order Line", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameIssuedPaymentOrderLine(var Rec: Record "Issued Payment Order Line"; var xRec: Record "Issued Payment Order Line")
    var
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Issued Payment Order Line") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Iss. Payment Order Line CZB");
        IssPaymentOrderLineCZB.ChangeCompany(Rec.CurrentCompany);
        if IssPaymentOrderLineCZB.Get(xRec."Payment Order No.", xRec."Line No.") then
            IssPaymentOrderLineCZB.Rename(Rec."Payment Order No.", Rec."Line No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Iss. Payment Order Line CZB");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Issued Payment Order Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertIssuedPaymentOrderLine(var Rec: Record "Issued Payment Order Line")
    begin
        SyncIssuedPaymentOrderLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Issued Payment Order Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyIssuedPaymentOrderLine(var Rec: Record "Issued Payment Order Line")
    begin
        SyncIssuedPaymentOrderLine(Rec);
    end;

    local procedure SyncIssuedPaymentOrderLine(var IssuedPaymentOrderLine: Record "Issued Payment Order Line")
    var
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if IssuedPaymentOrderLine.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Issued Payment Order Line") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Iss. Payment Order Line CZB");
        IssPaymentOrderLineCZB.ChangeCompany(IssuedPaymentOrderLine.CurrentCompany);
        if not IssPaymentOrderLineCZB.Get(IssuedPaymentOrderLine."Payment Order No.", IssuedPaymentOrderLine."Line No.") then begin
            IssPaymentOrderLineCZB.Init();
            IssPaymentOrderLineCZB."Payment Order No." := IssuedPaymentOrderLine."Payment Order No.";
            IssPaymentOrderLineCZB."Line No." := IssuedPaymentOrderLine."Line No.";
            IssPaymentOrderLineCZB.SystemId := IssPaymentOrderLineCZB.SystemId;
            IssPaymentOrderLineCZB.Insert(false, true);
        end;
        IssPaymentOrderLineCZB.Type := IssuedPaymentOrderLine.Type;
        IssPaymentOrderLineCZB."No." := IssuedPaymentOrderLine."No.";
        IssPaymentOrderLineCZB."Cust./Vendor Bank Account Code" := IssuedPaymentOrderLine."Cust./Vendor Bank Account Code";
        IssPaymentOrderLineCZB.Description := IssuedPaymentOrderLine.Description;
        IssPaymentOrderLineCZB."Account No." := IssuedPaymentOrderLine."Account No.";
        IssPaymentOrderLineCZB."Variable Symbol" := IssuedPaymentOrderLine."Variable Symbol";
        IssPaymentOrderLineCZB."Constant Symbol" := IssuedPaymentOrderLine."Constant Symbol";
        IssPaymentOrderLineCZB."Specific Symbol" := IssuedPaymentOrderLine."Specific Symbol";
        IssPaymentOrderLineCZB.Amount := IssuedPaymentOrderLine.Amount;
        IssPaymentOrderLineCZB."Amount (LCY)" := IssuedPaymentOrderLine."Amount (LCY)";
        IssPaymentOrderLineCZB."Applies-to Doc. Type" := IssuedPaymentOrderLine."Applies-to Doc. Type";
        IssPaymentOrderLineCZB."Applies-to Doc. No." := IssuedPaymentOrderLine."Applies-to Doc. No.";
        IssPaymentOrderLineCZB."Applies-to C/V/E Entry No." := IssuedPaymentOrderLine."Applies-to C/V/E Entry No.";
        IssPaymentOrderLineCZB.Positive := IssuedPaymentOrderLine.Positive;
        IssPaymentOrderLineCZB."Transit No." := IssuedPaymentOrderLine."Transit No.";
        IssPaymentOrderLineCZB."Currency Code" := IssuedPaymentOrderLine."Currency Code";
        IssPaymentOrderLineCZB."Applied Currency Code" := IssuedPaymentOrderLine."Applied Currency Code";
        IssPaymentOrderLineCZB."Payment Order Currency Code" := IssuedPaymentOrderLine."Payment Order Currency Code";
        IssPaymentOrderLineCZB."Amount(Payment Order Currency)" := IssuedPaymentOrderLine."Amount(Payment Order Currency)";
        IssPaymentOrderLineCZB."Payment Order Currency Factor" := IssuedPaymentOrderLine."Payment Order Currency Factor";
        IssPaymentOrderLineCZB."Due Date" := IssuedPaymentOrderLine."Due Date";
        IssPaymentOrderLineCZB.IBAN := IssuedPaymentOrderLine.IBAN;
        IssPaymentOrderLineCZB."SWIFT Code" := IssuedPaymentOrderLine."SWIFT Code";
        IssPaymentOrderLineCZB.Status := IssuedPaymentOrderLine.Status;
        IssPaymentOrderLineCZB.Name := IssuedPaymentOrderLine.Name;
        IssPaymentOrderLineCZB."VAT Unreliable Payer" := IssuedPaymentOrderLine."VAT Uncertainty Payer";
        IssPaymentOrderLineCZB."Public Bank Account" := IssuedPaymentOrderLine."Public Bank Account";
        IssPaymentOrderLineCZB."Third Party Bank Account" := IssuedPaymentOrderLine."Third Party Bank Account";
        IssPaymentOrderLineCZB."Payment Method Code" := IssuedPaymentOrderLine."Payment Method Code";
        IssPaymentOrderLineCZB.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Iss. Payment Order Line CZB");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Issued Payment Order Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteIssuedPaymentOrderLine(var Rec: Record "Issued Payment Order Line")
    var
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Issued Payment Order Line") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Iss. Payment Order Line CZB");
        IssPaymentOrderLineCZB.ChangeCompany(Rec.CurrentCompany);
        if IssPaymentOrderLineCZB.Get(Rec."Payment Order No.", Rec."Line No.") then
            IssPaymentOrderLineCZB.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Iss. Payment Order Line CZB");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Iss. Payment Order Line CZB", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameIssPaymentOrderLineCZB(var Rec: Record "Iss. Payment Order Line CZB"; var xRec: Record "Iss. Payment Order Line CZB")
    var
        IssuedPaymentOrderLine: Record "Issued Payment Order Line";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Iss. Payment Order Line CZB") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Issued Payment Order Line");
        IssuedPaymentOrderLine.ChangeCompany(Rec.CurrentCompany);
        if IssuedPaymentOrderLine.Get(xRec."Payment Order No.", xRec."Line No.") then
            IssuedPaymentOrderLine.Rename(Rec."Payment Order No.", Rec."Line No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Issued Payment Order Line");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Iss. Payment Order Line CZB", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertIssPaymentOrderLineCZB(var Rec: Record "Iss. Payment Order Line CZB")
    begin
        SyncIssPaymentOrderLineCZB(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Iss. Payment Order Line CZB", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyIssPaymentOrderLineCZB(var Rec: Record "Iss. Payment Order Line CZB")
    begin
        SyncIssPaymentOrderLineCZB(Rec);
    end;

    local procedure SyncIssPaymentOrderLineCZB(var IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB")
    var
        IssuedPaymentOrderLine: Record "Issued Payment Order Line";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if IssPaymentOrderLineCZB.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Iss. Payment Order Line CZB") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Issued Payment Order Line");
        IssuedPaymentOrderLine.ChangeCompany(IssPaymentOrderLineCZB.CurrentCompany);
        if not IssuedPaymentOrderLine.Get(IssPaymentOrderLineCZB."Payment Order No.", IssPaymentOrderLineCZB."Line No.") then begin
            IssuedPaymentOrderLine.Init();
            IssuedPaymentOrderLine."Payment Order No." := IssPaymentOrderLineCZB."Payment Order No.";
            IssuedPaymentOrderLine."Line No." := IssPaymentOrderLineCZB."Line No.";
            IssuedPaymentOrderLine.SystemId := IssPaymentOrderLineCZB.SystemId;
            IssuedPaymentOrderLine.Insert(false, true);
        end;
        IssuedPaymentOrderLine.Type := IssPaymentOrderLineCZB.Type.AsInteger();
        IssuedPaymentOrderLine."No." := IssPaymentOrderLineCZB."No.";
        IssuedPaymentOrderLine."Cust./Vendor Bank Account Code" := IssPaymentOrderLineCZB."Cust./Vendor Bank Account Code";
        IssuedPaymentOrderLine.Description := IssPaymentOrderLineCZB.Description;
        IssuedPaymentOrderLine."Account No." := IssPaymentOrderLineCZB."Account No.";
        IssuedPaymentOrderLine."Variable Symbol" := IssPaymentOrderLineCZB."Variable Symbol";
        IssuedPaymentOrderLine."Constant Symbol" := IssPaymentOrderLineCZB."Constant Symbol";
        IssuedPaymentOrderLine."Specific Symbol" := IssPaymentOrderLineCZB."Specific Symbol";
        IssuedPaymentOrderLine.Amount := IssPaymentOrderLineCZB.Amount;
        IssuedPaymentOrderLine."Amount (LCY)" := IssPaymentOrderLineCZB."Amount (LCY)";
        IssuedPaymentOrderLine."Applies-to Doc. Type" := IssPaymentOrderLineCZB."Applies-to Doc. Type";
        IssuedPaymentOrderLine."Applies-to Doc. No." := IssPaymentOrderLineCZB."Applies-to Doc. No.";
        IssuedPaymentOrderLine."Applies-to C/V/E Entry No." := IssPaymentOrderLineCZB."Applies-to C/V/E Entry No.";
        IssuedPaymentOrderLine.Positive := IssPaymentOrderLineCZB.Positive;
        IssuedPaymentOrderLine."Transit No." := IssPaymentOrderLineCZB."Transit No.";
        IssuedPaymentOrderLine."Currency Code" := IssPaymentOrderLineCZB."Currency Code";
        IssuedPaymentOrderLine."Applied Currency Code" := IssPaymentOrderLineCZB."Applied Currency Code";
        IssuedPaymentOrderLine."Payment Order Currency Code" := IssPaymentOrderLineCZB."Payment Order Currency Code";
        IssuedPaymentOrderLine."Amount(Payment Order Currency)" := IssPaymentOrderLineCZB."Amount(Payment Order Currency)";
        IssuedPaymentOrderLine."Payment Order Currency Factor" := IssPaymentOrderLineCZB."Payment Order Currency Factor";
        IssuedPaymentOrderLine."Due Date" := IssPaymentOrderLineCZB."Due Date";
        IssuedPaymentOrderLine.IBAN := IssPaymentOrderLineCZB.IBAN;
        IssuedPaymentOrderLine."SWIFT Code" := IssPaymentOrderLineCZB."SWIFT Code";
        IssuedPaymentOrderLine.Status := IssPaymentOrderLineCZB.Status.AsInteger();
        IssuedPaymentOrderLine.Name := IssPaymentOrderLineCZB.Name;
        IssuedPaymentOrderLine."VAT Uncertainty Payer" := IssPaymentOrderLineCZB."VAT Unreliable Payer";
        IssuedPaymentOrderLine."Public Bank Account" := IssPaymentOrderLineCZB."Public Bank Account";
        IssuedPaymentOrderLine."Third Party Bank Account" := IssPaymentOrderLineCZB."Third Party Bank Account";
        IssuedPaymentOrderLine."Payment Method Code" := IssPaymentOrderLineCZB."Payment Method Code";
        IssuedPaymentOrderLine.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Issued Payment Order Line");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Iss. Payment Order Line CZB", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteIssPaymentOrderLineCZB(var Rec: Record "Iss. Payment Order Line CZB")
    var
        IssuedPaymentOrderLine: Record "Issued Payment Order Line";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Iss. Payment Order Line CZB") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Issued Payment Order Line");
        IssuedPaymentOrderLine.ChangeCompany(Rec.CurrentCompany);
        if IssuedPaymentOrderLine.Get(Rec."Payment Order No.", Rec."Line No.") then
            IssuedPaymentOrderLine.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Issued Payment Order Line");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif