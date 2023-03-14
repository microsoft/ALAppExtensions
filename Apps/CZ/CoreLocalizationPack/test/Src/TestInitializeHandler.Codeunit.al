codeunit 148104 "Test Initialize Handler CZL"
{
#if not CLEAN20
    SingleInstance = true;

    var
        ERMMulPostGrHandlerCZL: Codeunit "ERM Mul. Post. Gr. Handler CZL";

#endif
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
#if not CLEAN20
            134195: // "ERM Multiple Posting Groups"
                BindERMMulPostGrHandler();
#endif
        end;
#if not CLEAN20

        if CallerCodeunitID <> 134195 then
            TryUnbindERMMulPostGrHandler();
#endif
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
#if not CLEAN20
    local procedure BindERMMulPostGrHandler()
    begin
        BindSubscription(ERMMulPostGrHandlerCZL);
    end;

    local procedure TryUnbindERMMulPostGrHandler(): Boolean
    begin
        exit(UnbindSubscription(ERMMulPostGrHandlerCZL));
    end;
#endif
}
