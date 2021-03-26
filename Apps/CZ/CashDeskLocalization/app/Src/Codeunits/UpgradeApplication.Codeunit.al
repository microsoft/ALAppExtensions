#pragma warning disable AL0432
codeunit 31107 "Upgrade Application CZP"
{
    Subtype = Upgrade;

    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitionsCZP: Codeunit "Upgrade Tag Definitions CZP";

    trigger OnUpgradePerDatabase()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();

        UpdatePermission();

        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion173PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion173PerDatabaseUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion174PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion174PerDatabaseUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion180PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion180PerDatabaseUpgradeTag());
    end;

    trigger OnUpgradePerCompany()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();

        UpdateCashDeskEvent();
        UpdateCashDeskUser();
        UpdateCashDocumentLine();
        UpdatePostedCashDocumentHeader();
        UpdatePostedCashDocumentLine();

        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion173PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion173PerCompanyUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion174PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion174PerCompanyUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion180PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion180PerCompanyUpgradeTag());
    end;

    local procedure UpdateCashDeskUser();
    var
        CashDeskUser: Record "Cash Desk User";
        CashDeskUserCZP: Record "Cash Desk User CZP";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        if CashDeskUser.FindSet() then
            repeat
                if CashDeskUserCZP.Get(CashDeskUser."Cash Desk No.", CashDeskUser."User ID") then begin
                    CashDeskUserCZP."Post EET Only" := CashDeskUser."Post EET Only";
                    CashDeskUserCZP.Modify(false);
                end;
            until CashDeskUser.Next() = 0;
    end;

    local procedure UpdateCashDeskEvent();
    var
        CashDeskEvent: Record "Cash Desk Event";
        CashDeskEventCZP: Record "Cash Desk Event CZP";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        if CashDeskEvent.FindSet() then
            repeat
                if CashDeskEventCZP.Get(CashDeskEvent.Code) then begin
                    CashDeskEventCZP."EET Transaction" := CashDeskEvent."EET Transaction";
                    CashDeskEventCZP.Modify(false);
                end;
            until CashDeskEvent.Next() = 0;
    end;

    local procedure UpdateCashDocumentLine();
    var
        CashDocumentLine: Record "Cash Document Line";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion173PerCompanyUpgradeTag()) and
           UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion174PerCompanyUpgradeTag())
        then
            exit;

        GeneralLedgerSetup.Get();
        if CashDocumentLine.FindSet() then
            repeat
                if CashDocumentLineCZP.Get(CashDocumentLine."Cash Desk No.", CashDocumentLine."Cash Document No.", CashDocumentLine."Line No.") then begin
                    if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion173PerCompanyUpgradeTag()) then
                        if GeneralLedgerSetup."Prepayment Type" = GeneralLedgerSetup."Prepayment Type"::Advances then
                            if CashDocumentLine.Prepayment then
                                CashDocumentLineCZP."Advance Letter Link Code" := CashDocumentLine."Advance Letter Link Code";
                    if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion174PerCompanyUpgradeTag()) then
                        CashDocumentLineCZP."EET Transaction" := CashDocumentLine."EET Transaction";
                    CashDocumentLineCZP.Modify(false);
                end;
            until CashDocumentLine.Next() = 0;
    end;

    local procedure UpdatePostedCashDocumentHeader();
    var
        PostedCashDocumentHeader: Record "Posted Cash Document Header";
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        if PostedCashDocumentHeader.FindSet() then
            repeat
                if PostedCashDocumentHdrCZP.Get(PostedCashDocumentHeader."Cash Desk No.", PostedCashDocumentHeader."No.") then begin
                    PostedCashDocumentHdrCZP."EET Entry No." := PostedCashDocumentHeader."EET Entry No.";
                    PostedCashDocumentHdrCZP.Modify(false);
                end;
            until PostedCashDocumentHeader.Next() = 0;
    end;

    local procedure UpdatePostedCashDocumentLine();
    var
        PostedCashDocumentLine: Record "Posted Cash Document Line";
        PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        if PostedCashDocumentLine.FindSet() then
            repeat
                if PostedCashDocumentLineCZP.Get(PostedCashDocumentLine."Cash Desk No.", PostedCashDocumentLine."Cash Document No.", PostedCashDocumentLine."Line No.") then begin
                    PostedCashDocumentLineCZP."EET Transaction" := PostedCashDocumentLine."EET Transaction";
                    PostedCashDocumentLineCZP.Modify(false);
                end;
            until PostedCashDocumentLine.Next() = 0;
    end;

    local procedure UpdatePermission()
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion174PerDatabaseUpgradeTag()) then
            exit;

        InsertTableDataPermissions(Database::"Cash Document Header", Database::"Cash Document Header CZP");
        InsertTableDataPermissions(Database::"Cash Document Line", Database::"Cash Document Line CZP");
        InsertTableDataPermissions(Database::"Posted Cash Document Header", Database::"Posted Cash Document Hdr. CZP");
        InsertTableDataPermissions(Database::"Posted Cash Document Line", Database::"Posted Cash Document Line CZP");
        InsertTableDataPermissions(Database::"Currency Nominal Value", Database::"Currency Nominal Value CZP");
        InsertTableDataPermissions(Database::"Bank Account", Database::"Cash Desk CZP");
        InsertTableDataPermissions(Database::"Cash Desk User", Database::"Cash Desk User CZP");
        InsertTableDataPermissions(Database::"Cash Desk Event", Database::"Cash Desk Event CZP");
        InsertTableDataPermissions(Database::"Cash Desk Cue", Database::"Cash Desk Cue CZP");
        InsertTableDataPermissions(Database::"Cash Desk Report Selections", Database::"Cash Desk Rep. Selections CZP");
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
}
