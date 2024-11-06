namespace Microsoft.Finance.Analysis.StatisticalAccount;

using Microsoft.Foundation.AuditCodes;
using System.Globalization;

tableextension 2630 StatAccSourceCodeSetup extends "Source Code Setup"
{
    fields
    {
#pragma warning disable PTE0022
        field(50050; "Statistical Account Journal"; Code[10])
        {
            Caption = 'Statistical Account Journal';
            TableRelation = "Source Code";
            ObsoleteReason = 'Moved to new field - Stat. Account Journal';
            ObsoleteState = Removed;
            ObsoleteTag = '26.0';
        }
#pragma warning restore PTE0022

        field(2630; "Stat. Account Journal"; Code[10])
        {
            Caption = 'Statistical Account Journal';
            TableRelation = "Source Code";
        }
    }

    internal procedure GetSourceCodeSetupSafe(): Code[10]
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.FindFirst();

        if SourceCodeSetup."Stat. Account Journal" <> '' then
            exit;

        SourceCodeSetup."Stat. Account Journal" := StatistAccJnlTok;
        SourceCodeSetup.Modify();
        InsertSourceCode(SourceCodeSetup."Stat. Account Journal", PageName(PAGE::"Statistical Accounts Journal"));
        exit(SourceCodeSetup."Stat. Account Journal");
    end;


    local procedure InsertSourceCode(SourceCodeKey: Code[10]; Description: Text[100])
    var
        SourceCode: Record "Source Code";
    begin
        if SourceCode.Get(SourceCodeKey) then
            exit;
        SourceCode.Code := SourceCodeKey;
        SourceCode.Description := Description;
        SourceCode.Insert();
    end;

    local procedure PageName(PageID: Integer): Text[100]
    var
        ObjectTranslation: Record "Object Translation";
    begin
        exit(CopyStr(ObjectTranslation.TranslateObject(ObjectTranslation."Object Type"::Page, PageID), 1, 100));
    end;

    var
        StatistAccJnlTok: Label 'STATACC', Comment = 'Statistical Account Journal Code';
}