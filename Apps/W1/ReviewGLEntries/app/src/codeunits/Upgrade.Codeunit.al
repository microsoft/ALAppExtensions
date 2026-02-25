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
    end;

    local procedure UpgradeReviewGLEntryTag(): Code[250]
    begin
        exit('MS-547765-UpdateReviewGLEntry-20250704');
    end;

    local procedure UpgradeFixGLEntryReviewLogWithReviewedAmountZeroWithDataTransferTag(): Code[250]
    begin
        exit('MS-621701-UpgradeFixGLEntryReviewLogWithReviewedAmountZero-20260212');
    end;

}