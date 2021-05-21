codeunit 11722 "Transformation CZ"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    var
        CountryCodeCZTxt: Label 'CZ', Locked = true;
        BaseAppExtensionIdTxt: Label '437dbf0e-84ff-417a-965d-ed2bb9650972', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnAfterPopulateW1TableMappingForVersion', '', false, false)]
    local procedure PopulateTableMappingsCZ_15x(CountryCode: Text; TargetVersion: Decimal)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        StgVATPostingSetup: Record "Stg VAT Posting Setup";
        VATControlReportLine: Record "VAT Control Report Line";
        StgVATControlReportLine: Record "Stg VAT Control Report Line";
        SourceTableMapping: Record "Source Table Mapping";
        HybridBCLastManagement: Codeunit "Hybrid BC Last Management";
        ExtensionInfo: ModuleInfo;
        W1AppId: Guid;
    begin
        if CountryCode <> CountryCodeCZTxt then
            exit;

        if TargetVersion <> 15.0 then
            exit;

        NavApp.GetCurrentModuleInfo(ExtensionInfo);
        W1AppId := HybridBCLastManagement.GetAppId();
        with SourceTableMapping do begin
            SetRange("Country Code", CountryCodeCZTxt);
            DeleteAll();

            MapTable(VATPostingSetup.TableName(), CountryCodeCZTxt, StgVATPostingSetup.TableName(), true, BaseAppExtensionIdTxt, ExtensionInfo.Id());
            MapTable(VATPostingSetup.TableName(), CountryCodeCZTxt, VATPostingSetup.TableName(), false, BaseAppExtensionIdTxt, BaseAppExtensionIdTxt);
            MapTable(VATControlReportLine.TableName(), CountryCodeCZTxt, StgVATControlReportLine.TableName(), true, BaseAppExtensionIdTxt, ExtensionInfo.Id());
            MapTable(VATControlReportLine.TableName(), CountryCodeCZTxt, VATControlReportLine.TableName(), false, BaseAppExtensionIdTxt, BaseAppExtensionIdTxt);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnAfterPopulateW1TableMappingForVersion', '', false, false)]

    local procedure PopulateTableMappingsCZ_18x(CountryCode: Text; TargetVersion: Decimal)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        StgVATPostingSetup: Record "Stg VAT Posting Setup";
        VATControlReportLine: Record "VAT Control Report Line";
        StgVATControlReportLine: Record "Stg VAT Control Report Line";
        SourceTableMapping: Record "Source Table Mapping";
        IntrastatJnlLine: Record "Intrastat Jnl. Line";
        StgIntrastatJnlLine: Record "Stg Intrastat Jnl. Line";
        ItemJournalLine: Record "Item Journal Line";
        StgItemJournalLine: Record "Stg Item Journal Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        StgItemLedgerEntry: Record "Stg Item Ledger Entry";
        HybridBCLastManagement: Codeunit "Hybrid BC Last Management";
        ExtensionInfo: ModuleInfo;
        W1AppId: Guid;
    begin
        if TargetVersion <> 18.0 then
            exit;

        NavApp.GetCurrentModuleInfo(ExtensionInfo);
        W1AppId := HybridBCLastManagement.GetAppId();
        with SourceTableMapping do begin
            SetRange("Country Code", CountryCodeCZTxt);
            DeleteAll();

            MapTable(VATPostingSetup.TableName(), CountryCodeCZTxt, StgVATPostingSetup.TableName(), true, BaseAppExtensionIdTxt, ExtensionInfo.Id());
            MapTable(VATPostingSetup.TableName(), CountryCodeCZTxt, VATPostingSetup.TableName(), false, BaseAppExtensionIdTxt, BaseAppExtensionIdTxt);
            MapTable(VATControlReportLine.TableName(), CountryCodeCZTxt, StgVATControlReportLine.TableName(), true, BaseAppExtensionIdTxt, ExtensionInfo.Id());
            MapTable(VATControlReportLine.TableName(), CountryCodeCZTxt, VATControlReportLine.TableName(), false, BaseAppExtensionIdTxt, BaseAppExtensionIdTxt);
            MapTable(IntrastatJnlLine.TableName(), CountryCodeCZTxt, StgIntrastatJnlLine.TableName(), true, BaseAppExtensionIdTxt, ExtensionInfo.Id());
            MapTable(IntrastatJnlLine.TableName(), CountryCodeCZTxt, IntrastatJnlLine.TableName(), false, BaseAppExtensionIdTxt, BaseAppExtensionIdTxt);
            MapTable(ItemJournalLine.TableName(), CountryCodeCZTxt, StgItemJournalLine.TableName(), true, BaseAppExtensionIdTxt, ExtensionInfo.Id());
            MapTable(ItemJournalLine.TableName(), CountryCodeCZTxt, ItemJournalLine.TableName(), false, BaseAppExtensionIdTxt, BaseAppExtensionIdTxt);
            MapTable(ItemLedgerEntry.TableName(), CountryCodeCZTxt, StgItemLedgerEntry.TableName(), true, BaseAppExtensionIdTxt, ExtensionInfo.Id());
            MapTable(ItemLedgerEntry.TableName(), CountryCodeCZTxt, ItemLedgerEntry.TableName(), false, BaseAppExtensionIdTxt, BaseAppExtensionIdTxt);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Transformation", 'OnAfterW1TransformationForVersion', '', false, false)]
    local procedure TransformTablesForCZ_15x(CountryCode: Text; TargetVersion: Decimal)
    begin
        if CountryCode <> CountryCodeCZTxt then
            exit;

        if TargetVersion <> 15.0 then
            exit;

        UpdateVATPostingSetup();
        UpdateVATControlReportLine();
    end;

    local procedure UpdateVATPostingSetup()
    var
        StgVATPostingSetup: Record "Stg VAT Posting Setup";
    begin
        // This code is based on app upgrade logic for CZ.
        // Matching file: .\App\Layers\CZ\BaseApp\Upgrade\UpgradeLocalApp.Codeunit.al
        // Based on commit: d4aef6b7
        with StgVATPostingSetup do
            if FindSet() then
                repeat
                    // "Insolvency Proceedings (p.44)" field replaced by "Corrections for Bad Receivable" field
                    "Corrections for Bad Receivable" := "Corrections for Bad Receivable"::" ";
                    if "Insolvency Proceedings (p.44)" then begin
                        "Corrections for Bad Receivable" := "Corrections for Bad Receivable"::"Insolvency Proceedings (p.44)";
                        Modify();
                    end;
                until Next() = 0;
    end;

    local procedure UpdateVATControlReportLine()
    var
        StgVATControlReportLine: Record "Stg VAT Control Report Line";
    begin
        // This code is based on app upgrade logic for CZ.
        // Matching file: .\App\Layers\CZ\BaseApp\Upgrade\UpgradeLocalApp.Codeunit.al
        // Based on commit: d4aef6b7
        with StgVATControlReportLine do
            if FindSet() then
                repeat
                    // "Insolvency Proceedings (p.44)" field replaced by "Corrections for Bad Receivable" field
                    "Corrections for Bad Receivable" := "Corrections for Bad Receivable"::" ";
                    if "Insolvency Proceedings (p.44)" then begin
                        "Corrections for Bad Receivable" := "Corrections for Bad Receivable"::"Insolvency Proceedings (p.44)";
                        Modify();
                    end;
                until Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Transformation", 'OnAfterW1TransformationForVersion', '', false, false)]
    local procedure TransformTablesForCZ_18x(CountryCode: Text; TargetVersion: Decimal)
    begin
        if CountryCode <> CountryCodeCZTxt then
            exit;

        if TargetVersion <> 18.0 then
            exit;

        UpdateIntrastatJnlLine();
        UpdateItemJournalLine();
        UpdateItemLedgerEntry();
    end;

    local procedure UpdateIntrastatJnlLine()
    var
        StgIntrastatJnlLine: Record "Stg Intrastat Jnl. Line";
    begin
        StgIntrastatJnlLine.SetFilter("Shipment Method Code", '<>%1', '');
        if StgIntrastatJnlLine.FindSet() then
            repeat
                StgIntrastatJnlLine."Shpt. Method Code" := StgIntrastatJnlLine."Shipment Method Code";
                StgIntrastatJnlLine.Modify();
            until StgIntrastatJnlLine.Next() = 0;
    end;

    local procedure UpdateItemJournalLine()
    var
        StgItemJournalLine: Record "Stg Item Journal Line";
    begin
        StgItemJournalLine.SetFilter("Shipment Method Code", '<>%1', '');
        if StgItemJournalLine.FindSet() then
            repeat
                StgItemJournalLine."Shpt. Method Code" := StgItemJournalLine."Shipment Method Code";
                StgItemJournalLine.Modify();
            until StgItemJournalLine.Next() = 0;
    end;

    local procedure UpdateItemLedgerEntry()
    var
        StgItemLedgerEntry: Record "Stg Item Ledger Entry";
    begin
        StgItemLedgerEntry.SetFilter("Shipment Method Code", '<>%1', '');
        if StgItemLedgerEntry.FindSet() then
            repeat
                StgItemLedgerEntry."Shpt. Method Code" := StgItemLedgerEntry."Shipment Method Code";
                StgItemLedgerEntry.Modify();
            until StgItemLedgerEntry.Next() = 0;
    end;
}