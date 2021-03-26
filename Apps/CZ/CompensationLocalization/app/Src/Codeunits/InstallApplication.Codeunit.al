#pragma warning disable AL0432,AL0603
codeunit 31270 "Install Application CZC"
{
    Subtype = Install;

    trigger OnInstallAppPerDatabase()
    begin
        CopyPermission();
    end;

    trigger OnInstallAppPerCompany()
    begin
        if not InitializeDone() then
            CopyData();

        CompanyInitialize();
    end;

    local procedure InitializeDone(): boolean
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(AppInfo.DataVersion() <> Version.Create('0.0.0.0'));
    end;

    local procedure CopyData()
    begin
        CopySourceCodeSetup();
        CopyCompensationSetup();
        CopyCustLedgerEntry();
        CopyVendLedgerEntry();
        CopyGenJournalLine();
        CopyCreditHeader();
        CopyCreditLine();
        CopyPostedCreditHeader();
        CopyPostedCreditLine();
        CopyPostedGenJournalLine();
    end;

    local procedure CopySourceCodeSetup();
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        if SourceCodeSetup.Get() then begin
            SourceCodeSetup."Compensation CZC" := SourceCodeSetup.Credit;
            SourceCodeSetup.Modify(false);
        end;
    end;

    local procedure CopyCompensationSetup();
    var
        CreditsSetup: Record "Credits Setup";
        CompensationSetupCZC: Record "Compensations Setup CZC";
    begin
        if CreditsSetup.Get() then begin
            if not CompensationSetupCZC.Get() then begin
                CompensationSetupCZC.Init();
                CompensationSetupCZC.Insert();
            end;
            CompensationSetupCZC."Compensation Nos." := CreditsSetup."Credit Nos.";
            CompensationSetupCZC."Compensation Bal. Account No." := CreditsSetup."Credit Bal. Account No.";
            CompensationSetupCZC."Max. Rounding Amount" := CreditsSetup."Max. Rounding Amount";
            CompensationSetupCZC."Debit Rounding Account" := CreditsSetup."Debit Rounding Account";
            CompensationSetupCZC."Credit Rounding Account" := CreditsSetup."Credit Rounding Account";
            CompensationSetupCZC."Compensation Proposal Method" := CreditsSetup."Credit Proposal By";
            CompensationSetupCZC."Show Empty when not Found" := CreditsSetup."Show Empty when not Found";
            CompensationSetupCZC.Modify(false);
        end;
    end;

    local procedure CopyCustLedgerEntry();
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if CustLedgerEntry.FindSet(true) then
            repeat
                CustLedgerEntry."Compensation CZC" := CustLedgerEntry.Compensation;
                CustLedgerEntry.Modify(false);
            until CustLedgerEntry.Next() = 0;
    end;

    local procedure CopyVendLedgerEntry();
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        if VendorLedgerEntry.FindSet(true) then
            repeat
                VendorLedgerEntry."Compensation CZC" := VendorLedgerEntry.Compensation;
                VendorLedgerEntry.Modify(false);
            until VendorLedgerEntry.Next() = 0;
    end;

    local procedure CopyGenJournalLine();
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        if GenJournalLine.FindSet(true) then
            repeat
                GenJournalLine."Compensation CZC" := GenJournalLine.Compensation;
                GenJournalLine.Modify(false);
            until GenJournalLine.Next() = 0;
    end;

    local procedure CopyCreditHeader();
    var
        CreditHeader: Record "Credit Header";
        CompensationHeaderCZC: Record "Compensation Header CZC";
    begin
        if CreditHeader.FindSet() then
            repeat
                if not CompensationHeaderCZC.Get(CreditHeader."No.") then begin
                    CompensationHeaderCZC.Init();
                    CompensationHeaderCZC."No." := CreditHeader."No.";
                    CompensationHeaderCZC.Insert();
                end;
                CompensationHeaderCZC.Description := CreditHeader.Description;
                CompensationHeaderCZC."Company No." := CreditHeader."Company No.";
                CompensationHeaderCZC."Company Name" := CreditHeader."Company Name";
                CompensationHeaderCZC."Company Name 2" := CreditHeader."Company Name 2";
                CompensationHeaderCZC."Company Address" := CreditHeader."Company Address";
                CompensationHeaderCZC."Company Address 2" := CreditHeader."Company Address 2";
                CompensationHeaderCZC."Company City" := CreditHeader."Company City";
                CompensationHeaderCZC."Company Contact" := CreditHeader."Company Contact";
                CompensationHeaderCZC."Company County" := CreditHeader."Company County";
                CompensationHeaderCZC."Company Country/Region Code" := CreditHeader."Company Country/Region Code";
                CompensationHeaderCZC."Company Post Code" := CreditHeader."Company Post Code";
                CompensationHeaderCZC."User ID" := CreditHeader."User ID";
                CompensationHeaderCZC.Status := CreditHeader.Status;
                CompensationHeaderCZC."Salesperson/Purchaser Code" := CreditHeader."Salesperson Code";
                CompensationHeaderCZC."Document Date" := CreditHeader."Document Date";
                CompensationHeaderCZC."Posting Date" := CreditHeader."Posting Date";
                CompensationHeaderCZC."No. Series" := CreditHeader."No. Series";
                CompensationHeaderCZC."Company Type" := CreditHeader.Type;
                CompensationHeaderCZC."Incoming Document Entry No." := CreditHeader."Incoming Document Entry No.";
                CompensationHeaderCZC.Modify(false);
            until CreditHeader.Next() = 0;
    end;

    local procedure CopyCreditLine();
    var
        CreditLine: Record "Credit Line";
        CompensationLineCZC: Record "Compensation Line CZC";
    begin
        if CreditLine.FindSet() then
            repeat
                if not CompensationLineCZC.Get(CreditLine."Credit No.", CreditLine."Line No.") then begin
                    CompensationLineCZC.Init();
                    CompensationLineCZC."Compensation No." := CreditLine."Credit No.";
                    CompensationLineCZC."Line No." := CreditLine."Line No.";
                    CompensationLineCZC.Insert();
                end;
                CompensationLineCZC."Source Type" := CreditLine."Source Type";
                CompensationLineCZC."Source No." := CreditLine."Source No.";
                CompensationLineCZC."Posting Group" := CreditLine."Posting Group";
                CompensationLineCZC."Shortcut Dimension 1 Code" := CreditLine."Global Dimension 1 Code";
                CompensationLineCZC."Shortcut Dimension 2 Code" := CreditLine."Global Dimension 2 Code";
                CompensationLineCZC."Source Entry No." := CreditLine."Source Entry No.";
                CompensationLineCZC."Posting Date" := CreditLine."Posting Date";
                CompensationLineCZC."Document Type" := CreditLine."Document Type";
                CompensationLineCZC."Document No." := CreditLine."Document No.";
                CompensationLineCZC.Description := CreditLine.Description;
                CompensationLineCZC."Variable Symbol" := CreditLine."Variable Symbol";
                CompensationLineCZC."Currency Code" := CreditLine."Currency Code";
                CompensationLineCZC."Currency Factor" := CreditLine."Currency Factor";
                CompensationLineCZC."Ledg. Entry Original Amount" := CreditLine."Ledg. Entry Original Amount";
                CompensationLineCZC."Ledg. Entry Remaining Amount" := CreditLine."Ledg. Entry Remaining Amount";
                CompensationLineCZC.Amount := CreditLine.Amount;
                CompensationLineCZC."Remaining Amount" := CreditLine."Remaining Amount";
                CompensationLineCZC."Ledg. Entry Original Amt.(LCY)" := CreditLine."Ledg. Entry Original Amt.(LCY)";
                CompensationLineCZC."Ledg. Entry Rem. Amt. (LCY)" := CreditLine."Ledg. Entry Rem. Amt. (LCY)";
                CompensationLineCZC."Amount (LCY)" := CreditLine."Amount (LCY)";
                CompensationLineCZC."Remaining Amount (LCY)" := CreditLine."Remaining Amount (LCY)";
                CompensationLineCZC."Manual Change Only" := CreditLine."Manual Change Only";
                CompensationLineCZC."Dimension Set ID" := CreditLine."Dimension Set ID";
                CompensationLineCZC.Modify(false);
            until CreditLine.Next() = 0;
    end;

    local procedure CopyPostedCreditHeader();
    var
        PostedCreditHeader: Record "Posted Credit Header";
        PostedCompensationHeaderCZC: Record "Posted Compensation Header CZC";
    begin
        if PostedCreditHeader.FindSet() then
            repeat
                if not PostedCompensationHeaderCZC.Get(PostedCreditHeader."No.") then begin
                    PostedCompensationHeaderCZC.Init();
                    PostedCompensationHeaderCZC."No." := PostedCreditHeader."No.";
                    PostedCompensationHeaderCZC.Insert();
                end;
                PostedCompensationHeaderCZC.Description := PostedCreditHeader.Description;
                PostedCompensationHeaderCZC."Company No." := PostedCreditHeader."Company No.";
                PostedCompensationHeaderCZC."Company Name" := PostedCreditHeader."Company Name";
                PostedCompensationHeaderCZC."Company Name 2" := PostedCreditHeader."Company Name 2";
                PostedCompensationHeaderCZC."Company Address" := PostedCreditHeader."Company Address";
                PostedCompensationHeaderCZC."Company Address 2" := PostedCreditHeader."Company Address 2";
                PostedCompensationHeaderCZC."Company City" := PostedCreditHeader."Company City";
                PostedCompensationHeaderCZC."Company Contact" := PostedCreditHeader."Company Contact";
                PostedCompensationHeaderCZC."Company County" := PostedCreditHeader."Company County";
                PostedCompensationHeaderCZC."Company Country/Region Code" := PostedCreditHeader."Company Country/Region Code";
                PostedCompensationHeaderCZC."Company Post Code" := PostedCreditHeader."Company Post Code";
                PostedCompensationHeaderCZC."User ID" := PostedCreditHeader."User ID";
                PostedCompensationHeaderCZC."Salesperson/Purchaser Code" := PostedCreditHeader."Salesperson Code";
                PostedCompensationHeaderCZC."Document Date" := PostedCreditHeader."Document Date";
                PostedCompensationHeaderCZC."Posting Date" := PostedCreditHeader."Posting Date";
                PostedCompensationHeaderCZC."No. Series" := PostedCreditHeader."No. Series";
                PostedCompensationHeaderCZC."Company Type" := PostedCreditHeader.Type;
                PostedCompensationHeaderCZC.Modify(false);
            until PostedCreditHeader.Next() = 0;
    end;

    local procedure CopyPostedCreditLine();
    var
        PostedCreditLine: Record "Posted Credit Line";
        PostedCompensationLineCZC: Record "Posted Compensation Line CZC";
    begin
        if PostedCreditLine.FindSet() then
            repeat
                if not PostedCompensationLineCZC.Get(PostedCreditLine."Credit No.", PostedCreditLine."Line No.") then begin
                    PostedCompensationLineCZC.Init();
                    PostedCompensationLineCZC."Compensation No." := PostedCreditLine."Credit No.";
                    PostedCompensationLineCZC."Line No." := PostedCreditLine."Line No.";
                    PostedCompensationLineCZC.Insert();
                end;
                PostedCompensationLineCZC."Source Type" := PostedCreditLine."Source Type";
                PostedCompensationLineCZC."Source No." := PostedCreditLine."Source No.";
                PostedCompensationLineCZC."Posting Group" := PostedCreditLine."Posting Group";
                PostedCompensationLineCZC."Shortcut Dimension 1 Code" := PostedCreditLine."Global Dimension 1 Code";
                PostedCompensationLineCZC."Shortcut Dimension 2 Code" := PostedCreditLine."Global Dimension 2 Code";
                PostedCompensationLineCZC."Source Entry No." := PostedCreditLine."Source Entry No.";
                PostedCompensationLineCZC."Posting Date" := PostedCreditLine."Posting Date";
                PostedCompensationLineCZC."Document Type" := PostedCreditLine."Document Type";
                PostedCompensationLineCZC."Document No." := PostedCreditLine."Document No.";
                PostedCompensationLineCZC.Description := PostedCreditLine.Description;
                PostedCompensationLineCZC."Variable Symbol" := PostedCreditLine."Variable Symbol";
                PostedCompensationLineCZC."Currency Code" := PostedCreditLine."Currency Code";
                PostedCompensationLineCZC."Currency Factor" := PostedCreditLine."Currency Factor";
                PostedCompensationLineCZC."Ledg. Entry Original Amount" := PostedCreditLine."Ledg. Entry Original Amount";
                PostedCompensationLineCZC."Ledg. Entry Remaining Amount" := PostedCreditLine."Ledg. Entry Remaining Amount";
                PostedCompensationLineCZC.Amount := PostedCreditLine.Amount;
                PostedCompensationLineCZC."Remaining Amount" := PostedCreditLine."Remaining Amount";
                PostedCompensationLineCZC."Ledg. Entry Original Amt.(LCY)" := PostedCreditLine."Ledg. Entry Original Amt.(LCY)";
                PostedCompensationLineCZC."Ledg. Entry Rem. Amt. (LCY)" := PostedCreditLine."Ledg. Entry Rem. Amt. (LCY)";
                PostedCompensationLineCZC."Amount (LCY)" := PostedCreditLine."Amount (LCY)";
                PostedCompensationLineCZC."Remaining Amount (LCY)" := PostedCreditLine."Remaining Amount (LCY)";
                PostedCompensationLineCZC."Dimension Set ID" := PostedCreditLine."Dimension Set ID";
                PostedCompensationLineCZC.Modify(false);
            until PostedCreditLine.Next() = 0;
    end;

    local procedure CopyPostedGenJournalLine();
    var
        PostedGenJournalLine: Record "Posted Gen. Journal Line";
    begin
        if PostedGenJournalLine.FindSet(true) then
            repeat
                PostedGenJournalLine."Compensation CZC" := PostedGenJournalLine.Compensation;
                PostedGenJournalLine.Modify(false);
            until PostedGenJournalLine.Next() = 0;
    end;

    local procedure CopyPermission();
    begin
        InsertTableDataPermissions(Database::"Credits Setup", Database::"Compensations Setup CZC");
        InsertTableDataPermissions(Database::"Credit Report Selections", Database::"Compens. Report Selections CZC");
        InsertTableDataPermissions(Database::"Credit Header", Database::"Compensation Line CZC");
        InsertTableDataPermissions(Database::"Credit Line", Database::"Compensation Line CZC");
        InsertTableDataPermissions(Database::"Posted Credit Header", Database::"Posted Compensation Header CZC");
        InsertTableDataPermissions(Database::"Posted Credit Line", Database::"Posted Compensation Line CZC");
    end;

    local procedure InsertTableDataPermissions(OldTableID: Integer; NewTableID: Integer)
    var
        Permission: Record Permission;
        NewPermission: Record Permission;
    begin
        Permission.SetRange("Object Type", Permission."Object Type"::"Table Data");
        Permission.SetRange("Object ID", OldTableID);
        if not Permission.FindSet() then
            exit;
        repeat
            if not NewPermission.Get(Permission."Role ID", Permission."Object Type", Permission."Object ID") then begin
                NewPermission.Init();
                NewPermission := Permission;
                NewPermission."Object ID" := NewTableID;
                NewPermission.Insert();
            end;
        until Permission.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    var
        DataClassEvalHandlerCZC: Codeunit "Data Class. Eval. Handler CZC";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        InitCompensationSourceCode();
        InitCompensationReportSelections();

        DataClassEvalHandlerCZC.ApplyEvaluationClassificationsForPrivacy();
        UpgradeTag.SetAllUpgradeTags();
    end;

    local procedure InitCompensationSourceCode()
    var
        CompensationSourceCodeTxt: Label 'COMPENS', MaxLength = 10;
        CompensationSourceDescriptionTxt: Label 'Compensation Evidence', MaxLength = 100;
    begin
        InsertSourceCode(CompensationSourceCodeTxt, CompensationSourceDescriptionTxt);
        SetupSourceCode(CompensationSourceCodeTxt);
    end;

    local procedure InsertSourceCode(SourceCodeCode: Code[10]; SourceCodeDescription: Text[100])
    var
        SourceCode: Record "Source Code";
    begin
        if SourceCode.Get(SourceCodeCode) then
            exit;
        SourceCode.Init();
        SourceCode.Code := SourceCodeCode;
        SourceCode.Description := SourceCodeDescription;
        SourceCode.Insert();
    end;

    local procedure SetupSourceCode(SourceCodeCode: Code[10])
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        if not SourceCodeSetup.Get() then
            exit;
        if SourceCodeSetup."Compensation CZC" = SourceCodeCode then
            exit;
        SourceCodeSetup."Compensation CZC" := SourceCodeCode;
        SourceCodeSetup.Modify();
    end;

    local procedure InitCompensationReportSelections()
    var
        ReportUsage: Enum "Compens. Report Sel. Usage CZC";
    begin
        InsertCompensationReportSelectionsCZC(ReportUsage::"Compensation", '1', Report::"Compensation CZC");
        InsertCompensationReportSelectionsCZC(ReportUsage::"Posted Compensation", '1', Report::"Posted Compensation CZC");
    end;

    local procedure InsertCompensationReportSelectionsCZC(ReportUsage: Enum "Compens. Report Sel. Usage CZC"; ReportSequence: Code[10]; ReportID: Integer)
    var
        CompensReportSelectionsCZC: Record "Compens. Report Selections CZC";
    begin
        if CompensReportSelectionsCZC.Get(ReportUsage, ReportSequence) then
            exit;

        CompensReportSelectionsCZC.Init();
        CompensReportSelectionsCZC.Validate(Usage, ReportUsage);
        CompensReportSelectionsCZC.Validate(Sequence, ReportSequence);
        CompensReportSelectionsCZC.Validate("Report ID", ReportID);
        CompensReportSelectionsCZC.Insert();
    end;
}
