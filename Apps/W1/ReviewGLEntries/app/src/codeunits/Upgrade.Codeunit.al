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
        FixGLEntryReviewLogWithReviewAmountZero();
    end;

    local procedure FixGLEntryReviewLogWithReviewAmountZero()
    var
        GLEntryReviewLog, GLEntryReviewLog2: Record "G/L Entry Review Log";
        GlEntry: Record "G/L Entry";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeFixGLEntryReviewLogWithReviewedAmountZeroTag()) then exit;

        GLEntryReviewLog.SetCurrentKey("Reviewed Amount");
        GLEntryReviewLog.SetRange("Reviewed Amount", 0);
        if GLEntryReviewLog.FindSet() then
            repeat
                if GlEntry.Get(GLEntryReviewLog."G/L Entry No.") then begin
                    GLEntryReviewLog2.Copy(GLEntryReviewLog);
                    GLEntryReviewLog2."Reviewed Amount" := GlEntry.Amount;
                    GLEntryReviewLog2.Modify(false);
                end;
            until GLEntryReviewLog.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeFixGLEntryReviewLogWithReviewedAmountZeroTag());
    end;

    local procedure MovetoGLEntryReviewLog()
    var
        GLEntryReviewEntry: Record "G/L Entry Review Entry";
        GLEntryReviewLog: Record "G/L Entry Review Log";
        GlEntry: Record "G/L Entry";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeReviewGLEntryTag()) then
            exit;

        if GLEntryReviewEntry.FindSet() then
            repeat
                GLEntryReviewLog.Init();
                GLEntryReviewLog."G/L Entry No." := GLEntryReviewEntry."G/L Entry No.";
                GLEntryReviewLog."Reviewed Identifier" := GLEntryReviewEntry."Reviewed Identifier";
                GLEntryReviewLog."Reviewed By" := GLEntryReviewEntry."Reviewed By";
                if GlEntry.Get(GLEntryReviewEntry."G/L Entry No.") then begin
                    GLEntryReviewLog."G/L Account No." := GlEntry."G/L Account No.";
                    GLEntryReviewLog."Reviewed Amount" := GlEntry.Amount;
                end;
                GLEntryReviewLog.Insert(true);
            until GLEntryReviewEntry.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeReviewGLEntryTag());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(UpgradeReviewGLEntryTag());
        PerCompanyUpgradeTags.Add(UpgradeFixGLEntryReviewLogWithReviewedAmountZeroTag());
    end;

    local procedure UpgradeReviewGLEntryTag(): Code[250]
    begin
        exit('MS-547765-UpdateReviewGLEntry-20250704');
    end;

    local procedure UpgradeFixGLEntryReviewLogWithReviewedAmountZeroTag(): Code[250]
    begin
        exit('MS-616473-UpgradeFixGLEntryReviewLogWithReviewedAmountZeroTag-20251216');
    end;
}