namespace Microsoft.Finance.GeneralLedger.Review;

using Microsoft.Finance.GeneralLedger.Ledger;
using System.Upgrade;
codeunit 22201 "Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;
    Permissions = TableData "G/L Entry" = rimd;

    trigger OnUpgradePerCompany()
    begin
        MovetoGLEntryReviewLog();
        FixGLEntryReviewLogWithReviewAmountZeroWithDataTransfer();
        FixGLEntryReviewLogSetReviewedAt();
    end;

    local procedure FixGLEntryReviewLogWithReviewAmountZeroWithDataTransfer()
    var
        GLEntryReviewLog: Record "G/L Entry Review Log";
        GlEntry: Record "G/L Entry";
        UpgradeTag: Codeunit "Upgrade Tag";
        GLEntryDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeFixGLEntryReviewLogWithReviewedAmountZeroWithDataTransferTag()) then exit;

        GLEntryDataTransfer.SetTables(Database::"G/L Entry", Database::"G/L Entry Review Log");
        GLEntryDataTransfer.AddFieldValue(GLEntry.FieldNo(Amount), GLEntryReviewLog.FieldNo("Reviewed Amount"));
        GLEntryDataTransfer.AddJoin(GLEntry.FieldNo("Entry No."), GLEntryReviewLog.FieldNo("G/L Entry No."));
        GLEntryDataTransfer.AddDestinationFilter(GLEntryReviewLog.FieldNo("Reviewed Amount"), '=0');
        GLEntryDataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeFixGLEntryReviewLogWithReviewedAmountZeroWithDataTransferTag());
    end;

    local procedure FixGLEntryReviewLogSetReviewedAt()
    var
        GLEntryReviewLog: Record "G/L Entry Review Log";
        GLEntryReviewEntry: Record "G/L Entry Review Entry";
        UpgradeTag: Codeunit "Upgrade Tag";
        GLEntryReviewDataTransfer, GLEntryReviewLogDataTransfer : DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeFixGLEntryReviewLogSetReviewedAtTag()) then
            exit;

        // Pass 1: initialize Reviewed At for all new-table rows
        // This covers rows created by the new review mechanism (27.x).
        GLEntryReviewLogDataTransfer.SetTables(Database::"G/L Entry Review Log", Database::"G/L Entry Review Log");
        GLEntryReviewLogDataTransfer.AddFieldValue(GLEntryReviewLog.FieldNo(SystemCreatedAt), GLEntryReviewLog.FieldNo("Reviewed At"));
        GLEntryReviewLogDataTransfer.CopyFields();

        // Pass 2: overwrite with authoritative legacy review (pre-27.0) timestamps, if they exist
        // Legacy values are expected to be earlier and correct.
        GLEntryReviewDataTransfer.SetTables(Database::"G/L Entry Review Entry", Database::"G/L Entry Review Log");
        GLEntryReviewDataTransfer.AddJoin(GLEntryReviewEntry.FieldNo("G/L Entry No."), GLEntryReviewLog.FieldNo("G/L Entry No."));
        GLEntryReviewDataTransfer.AddFieldValue(GLEntryReviewEntry.FieldNo(SystemCreatedAt), GLEntryReviewLog.FieldNo("Reviewed At"));
        GLEntryReviewDataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeFixGLEntryReviewLogSetReviewedAtTag());
    end;

    local procedure MovetoGLEntryReviewLog()
    var
        GLEntryReviewEntry: Record "G/L Entry Review Entry";
        GLEntryReviewLog: Record "G/L Entry Review Log";
        GLEntry: Record "G/L Entry";
        UpgradeTag: Codeunit "Upgrade Tag";
        GLEntryReviewDataTransfer, GLEntryDataTransfer : DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeReviewGLEntryTag()) then
            exit;

        GLEntryReviewDataTransfer.SetTables(Database::"G/L Entry Review Entry", Database::"G/L Entry Review Log");
        GLEntryReviewDataTransfer.AddFieldValue(GLEntryReviewEntry.FieldNo("G/L Entry No."), GLEntryReviewLog.FieldNo("G/L Entry No."));
        GLEntryReviewDataTransfer.AddFieldValue(GLEntryReviewEntry.FieldNo("Reviewed Identifier"), GLEntryReviewLog.FieldNo("Reviewed Identifier"));
        GLEntryReviewDataTransfer.AddFieldValue(GLEntryReviewEntry.FieldNo("Reviewed By"), GLEntryReviewLog.FieldNo("Reviewed By"));
        GLEntryReviewDataTransfer.AddFieldValue(GLEntryReviewEntry.FieldNo(SystemCreatedAt), GLEntryReviewLog.FieldNo("Reviewed At"));
        GLEntryReviewDataTransfer.CopyRows();
        GLEntryDataTransfer.SetTables(Database::"G/L Entry", Database::"G/L Entry Review Log");
        GLEntryDataTransfer.AddJoin(GLEntry.FieldNo("Entry No."), GLEntryReviewLog.FieldNo("G/L Entry No."));
        GLEntryDataTransfer.AddFieldValue(GLEntry.FieldNo("G/L Account No."), GLEntryReviewLog.FieldNo("G/L Account No."));
        GLEntryDataTransfer.AddFieldValue(GLEntry.FieldNo(Amount), GLEntryReviewLog.FieldNo("Reviewed Amount"));
        GLEntryDataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeReviewGLEntryTag());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(UpgradeReviewGLEntryTag());
        PerCompanyUpgradeTags.Add(UpgradeFixGLEntryReviewLogWithReviewedAmountZeroWithDataTransferTag());
        PerCompanyUpgradeTags.Add(UpgradeFixGLEntryReviewLogSetReviewedAtTag());
    end;

    local procedure UpgradeReviewGLEntryTag(): Code[250]
    begin
        exit('MS-547765-UpdateReviewGLEntry-20250704');
    end;

    local procedure UpgradeFixGLEntryReviewLogWithReviewedAmountZeroWithDataTransferTag(): Code[250]
    begin
        exit('MS-621701-UpgradeFixGLEntryReviewLogWithReviewedAmountZero-20260212');
    end;

    local procedure UpgradeFixGLEntryReviewLogSetReviewedAtTag(): Code[250]
    begin
        exit('MS-624894-UpgradeFixGLEntryReviewLogSetReviewedAt-20260311');
    end;

}