codeunit 148104 "Test Initialize Handler CZL"
{
    SingleInstance = true;

    var
        SuppConfVATEntUpdate: Codeunit "Supp.Conf. VAT Ent. Update CZL";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Test Initialize", 'OnTestInitialize', '', false, false)]
    local procedure UpdateRecordsOnTestInitialize(CallerCodeunitID: Integer)
    begin
        case CallerCodeunitID of
            137462: // "Phys. Invt. Order Subform UT":
                UpdateInventorySetup();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Test Initialize", 'OnBeforeTestSuiteInitialize', '', false, false)]
    local procedure UpdateRecordsOnBeforeTestSuiteInitialize(CallerCodeunitID: Integer)
    begin
        case CallerCodeunitID of
            136150, // "Service Pages",
            136201, // "Marketing Contacts",
            138000: // "O365 Simplify UI Sales Invoice":
                UpdateReportSelections();
            134475, // "ERM Dimension Sales"
            137460, // "Phys. Invt. Item Tracking",
            137153, // "SCM Warehouse - Journal",
            137294, // "SCM Inventory Miscellaneous II",
            137295, // "SCM Inventory Misc. III",
            137400, // "SCM Inventory - Orders",
            137007, // "SCM Inventory Costing",
            137611: // "SCM Costing Rollup Sev 1":
                UpdateInventorySetup();
            134008, // ERM VAT Settlement with Apply
            134045, // ERM VAT Sales/Purchase
            134088, // ERM Pmt Disc for Cust/Vendor
            134992: // ERM Financial Reports IV
                begin
                    TryBindSuppConfVATEntUpdate();
                    UpdateUserSetup();
                end;
            137161: // SCM Warehouse Orders
                DisableVATDateUsage();
        end;

        if not (CallerCodeunitID in [134008, 134045, 134088, 134992]) then
            TryUnbindSuppConfVATEntUpdate();
    end;

    local procedure UpdateInventorySetup()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        InventorySetup."Def.Tmpl. for Phys.Neg.Adj CZL" := '';
        InventorySetup."Def.Tmpl. for Phys.Pos.Adj CZL" := '';
        InventorySetup.Modify();
    end;

    local procedure UpdateReportSelections()
    var
        ReportSelections: Record "Report Selections";
    begin
        if ReportSelections.Get(ReportSelections.Usage::"S.Quote", 1) then begin
            ReportSelections.Validate("Report ID", Report::"Standard Sales - Quote");
            ReportSelections.Modify();
        end;
        if ReportSelections.Get(ReportSelections.Usage::"SM.Shipment", 1) then begin
            ReportSelections.Validate("Report ID", Report::"Service - Shipment");
            ReportSelections.Modify();
        end;
        if ReportSelections.Get(ReportSelections.Usage::"SM.Invoice", 1) then begin
            ReportSelections.Validate("Report ID", Report::"Service - Invoice");
            ReportSelections.Modify();
        end;
        if ReportSelections.Get(ReportSelections.Usage::"SM.Credit Memo", 1) then begin
            ReportSelections.Validate("Report ID", Report::"Service - Credit Memo");
            ReportSelections.Modify();
        end;
    end;

    local procedure UpdateUserSetup()
    var
        UserSetup: Record "User Setup";
        UserSetupAdvManagement: Codeunit "User Setup Adv. Management CZL";
    begin
        if not UserSetup.Get(UserSetupAdvManagement.GetUserID()) then begin
            UserSetup.Init();
            UserSetup."User ID" := UserSetupAdvManagement.GetUserID();
            UserSetup.Insert();
        end;
        UserSetup."Allow VAT Date Changing CZL" := true;
        UserSetup.Modify();
    end;

    local procedure DisableVATDateUsage()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."VAT Reporting Date Usage" := GeneralLedgerSetup."VAT Reporting Date Usage"::Disabled;
        GeneralLedgerSetup.Modify();
    end;

    local procedure TryBindSuppConfVATEntUpdate(): Boolean
    begin
        exit(BindSubscription(SuppConfVATEntUpdate));
    end;

    local procedure TryUnbindSuppConfVATEntUpdate(): Boolean
    begin
        exit(UnbindSubscription(SuppConfVATEntUpdate));
    end;
}
