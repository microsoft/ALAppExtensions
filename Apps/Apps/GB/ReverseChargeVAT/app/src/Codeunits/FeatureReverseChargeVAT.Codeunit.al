#if not CLEAN27
/// <summary>
/// Reverse Charge VAT Feature will be moved to a separate app.
/// </summary>
namespace Microsoft.Finance.VAT.Setup;

using System.Environment.Configuration;
using System.Upgrade;
using Microsoft.Inventory.Item;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Navigate;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Setup;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Setup;

codeunit 10553 "Feature - Reverse Charge VAT" implements "Feature Data Update"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    ObsoleteReason = 'Feature Reverse Charge VAT will be enabled by default in version 30.0.';
    ObsoleteState = Pending;
    ObsoleteTag = '27.0';

    var
        TempDocumentEntry: Record "Document Entry" temporary;
        DescriptionTxt: Label 'Existing records in GB BaseApp fields will be copied to Reverse Charge VAT App fields';

    procedure IsDataUpdateRequired(): Boolean;
    begin
        CountRecords();
        if TempDocumentEntry.IsEmpty() then begin
            SetUpgradeTag(false);
            exit(false);
        end;
        exit(true);
    end;

    procedure ReviewData();
    var
        DataUpgradeOverview: Page "Data Upgrade Overview";
    begin
        Commit();
        Clear(DataUpgradeOverview);
        DataUpgradeOverview.Set(TempDocumentEntry);
        DataUpgradeOverview.RunModal();
    end;

    procedure AfterUpdate(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        UpdateFeatureDataUpdateStatus: Record "Feature Data Update Status";
    begin
        UpdateFeatureDataUpdateStatus.SetRange("Feature Key", FeatureDataUpdateStatus."Feature Key");
        UpdateFeatureDataUpdateStatus.SetFilter("Company Name", '<>%1', FeatureDataUpdateStatus."Company Name");
        UpdateFeatureDataUpdateStatus.ModifyAll("Feature Status", FeatureDataUpdateStatus."Feature Status");

        SetUpgradeTag(true);
    end;

    procedure UpdateData(FeatureDataUpdateStatus: Record "Feature Data Update Status");
    var
        FeatureDataUpdateMgt: Codeunit "Feature Data Update Mgt.";
        StartDateTime: DateTime;
        EndDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, 'Upgrade Reverse Charge VAT', StartDateTime);
        UpgradeReverseChargeVAT();
        EndDateTime := CurrentDateTime;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, 'Upgrade Reverse Charge VAT', EndDateTime);
    end;

    procedure GetTaskDescription() TaskDescription: Text;
    begin
        TaskDescription := DescriptionTxt;
    end;

    local procedure CountRecords()
    var
        GLSetup: Record "General Ledger Setup";
        Item: Record Item;
        ItemTempl: Record "Item Templ.";
        PurchaseLine: Record "Purchase Line";
        PurchaseSetup: Record "Purchases & Payables Setup";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        PurchInvLine: Record "Purch. Inv. Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesInvLine: Record "Sales Invoice Line";
        SalesLine: Record "Sales Line";
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        TempDocumentEntry.Reset();
        TempDocumentEntry.DeleteAll();

        InsertDocumentEntry(Database::"General Ledger Setup", GLSetup.TableCaption, GLSetup.Count());
        InsertDocumentEntry(Database::Item, Item.TableCaption, Item.Count());
        InsertDocumentEntry(Database::"Item Templ.", ItemTempl.TableCaption, ItemTempl.Count());
        InsertDocumentEntry(Database::"Purchase Line", PurchaseLine.TableCaption, PurchaseLine.Count());
        InsertDocumentEntry(Database::"Purchases & Payables Setup", PurchaseSetup.TableCaption, PurchaseSetup.Count());
        InsertDocumentEntry(Database::"Purch. Cr. Memo Line", PurchCrMemoLine.TableCaption, PurchCrMemoLine.Count());
        InsertDocumentEntry(Database::"Purch. Inv. Line", PurchInvLine.TableCaption, PurchInvLine.Count());
        InsertDocumentEntry(Database::"Sales Cr.Memo Line", SalesCrMemoLine.TableCaption, SalesCrMemoLine.Count());
        InsertDocumentEntry(Database::"Sales Invoice Line", SalesInvLine.TableCaption, SalesInvLine.Count());
        InsertDocumentEntry(Database::"Sales Line", SalesLine.TableCaption, SalesLine.Count());
        InsertDocumentEntry(Database::"Sales & Receivables Setup", SalesSetup.TableCaption, SalesSetup.Count());
    end;

    local procedure InsertDocumentEntry(TableID: Integer; TableName: Text; RecordCount: Integer)
    begin
        if RecordCount = 0 then
            exit;

        TempDocumentEntry.Init();
        TempDocumentEntry."Entry No." += 1;
        TempDocumentEntry."Table ID" := TableID;
        TempDocumentEntry."Table Name" := CopyStr(TableName, 1, MaxStrLen(TempDocumentEntry."Table Name"));
        TempDocumentEntry."No. of Records" := RecordCount;
        TempDocumentEntry.Insert();
    end;

    local procedure UpgradeReverseChargeVAT()
    var
        GLSetup: Record "General Ledger Setup";
        Item: Record Item;
        ItemTempl: Record "Item Templ.";
        PurchaseLine: Record "Purchase Line";
        PurchaseSetup: Record "Purchases & Payables Setup";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        PurchInvLine: Record "Purch. Inv. Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesInvLine: Record "Sales Invoice Line";
        SalesLine: Record "Sales Line";
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        if GLSetup.Get() then begin
#pragma warning disable AL0432
            GLSetup."Threshold applies GB" := GLSetup."Threshold applies";
            GLSetup."Threshold Amount GB" := GLSetup."Threshold Amount";
#pragma warning restore AL0432
            GLSetup.Modify();
        end;

        if Item.FindSet() then
            repeat
#pragma warning disable AL0432
                Item."Reverse Charge Applies GB" := Item."Reverse Charge Applies";
#pragma warning restore AL0432
                Item.Modify();
            until Item.Next() = 0;

        if ItemTempl.FindSet() then
            repeat
#pragma warning disable AL0432
                ItemTempl."Reverse Charge Applies GB" := ItemTempl."Reverse Charge Applies";
#pragma warning restore AL0432
                ItemTempl.Modify();
            until ItemTempl.Next() = 0;

        if PurchaseLine.FindSet() then
            repeat
#pragma warning disable AL0432
                PurchaseLine."Reverse Charge Item GB" := PurchaseLine."Reverse Charge Item";
#pragma warning restore AL0432
                PurchaseLine.Modify();
            until PurchaseLine.Next() = 0;

        if PurchaseSetup.Get() then begin
#pragma warning disable AL0432
            PurchaseSetup."Reverse Charge VAT Post. Gr." := PurchaseSetup."Reverse Charge VAT Posting Gr.";
            PurchaseSetup."Domestic Vendors GB" := PurchaseSetup."Domestic Vendors";
#pragma warning restore AL0432
            PurchaseSetup.Modify();
        end;

        if PurchCrMemoLine.FindSet() then
            repeat
#pragma warning disable AL0432
                PurchCrMemoLine."Reverse Charge Item GB" := PurchCrMemoLine."Reverse Charge Item";
                PurchCrMemoLine."Reverse Charge GB" := PurchCrMemoLine."Reverse Charge";
#pragma warning restore AL0432
                PurchCrMemoLine.Modify();
            until PurchCrMemoLine.Next() = 0;

        if PurchInvLine.FindSet() then
            repeat
#pragma warning disable AL0432
                PurchInvLine."Reverse Charge Item GB" := PurchInvLine."Reverse Charge Item";
                PurchInvLine."Reverse Charge GB" := PurchInvLine."Reverse Charge";
#pragma warning restore AL0432
                PurchInvLine.Modify();
            until PurchInvLine.Next() = 0;

        if SalesCrMemoLine.FindSet() then
            repeat
#pragma warning disable AL0432
                SalesCrMemoLine."Reverse Charge Item GB" := SalesCrMemoLine."Reverse Charge Item";
                SalesCrMemoLine."Reverse Charge GB" := SalesCrMemoLine."Reverse Charge";
#pragma warning restore AL0432
                SalesCrMemoLine.Modify();
            until SalesCrMemoLine.Next() = 0;

        if SalesInvLine.FindSet() then
            repeat
#pragma warning disable AL0432
                SalesInvLine."Reverse Charge Item GB" := SalesInvLine."Reverse Charge Item";
                SalesInvLine."Reverse Charge GB" := SalesInvLine."Reverse Charge";
#pragma warning restore AL0432
                SalesInvLine.Modify();
            until SalesInvLine.Next() = 0;

        if SalesLine.FindSet() then
            repeat
#pragma warning disable AL0432
                SalesLine."Reverse Charge Item GB" := SalesLine."Reverse Charge Item";
                SalesLine."Reverse Charge GB" := SalesLine."Reverse Charge";
#pragma warning restore AL0432
                SalesLine.Modify();
            until SalesLine.Next() = 0;

        if SalesSetup.Get() then begin
#pragma warning disable AL0432
            SalesSetup."Reverse Charge VAT Post. Gr." := SalesSetup."Reverse Charge VAT Posting Gr.";
            SalesSetup."Domestic Customers GB" := SalesSetup."Domestic Customers";
            SalesSetup."Invoice Wording GB" := SalesSetup."Invoice Wording";
#pragma warning restore AL0432
            SalesSetup.Modify();
        end;
    end;

    local procedure SetUpgradeTag(DataUpgradeExecuted: Boolean)
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagReverseChargeVAT: Codeunit "Upg. Tag Reverse Charge VAT";
    begin
        // Set the upgrade tag to indicate that the data update is executed/skipped and the feature is enabled.
        // This is needed when the feature is enabled by default in a future version, to skip the data upgrade.
        if UpgradeTag.HasUpgradeTag(UpgTagReverseChargeVAT.GetReverseChargeVATUpgradeTag()) then
            exit;

        UpgradeTag.SetUpgradeTag(UpgTagReverseChargeVAT.GetReverseChargeVATUpgradeTag());
        if not DataUpgradeExecuted then
            UpgradeTag.SetSkippedUpgrade(UpgTagReverseChargeVAT.GetReverseChargeVATUpgradeTag(), true);
    end;
}
#endif