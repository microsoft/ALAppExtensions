tableextension 2630 StatAccSourceCodeSetup extends "Source Code Setup"
{
    fields
    {
        field(50050; "Statistical Account Journal"; Code[10])
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
        if SourceCodeSetup."Statistical Account Journal" <> '' then
            exit;

        SourceCodeSetup."Statistical Account Journal" := StatistAccJnlTok;
        SourceCodeSetup.Modify();
        InsertSourceCode(SourceCodeSetup."Statistical Account Journal", PageName(PAGE::"Statistical Accounts Journal"));
        exit(SourceCodeSetup."Statistical Account Journal");
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