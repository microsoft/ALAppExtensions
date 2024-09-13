namespace Microsoft.Foundation.DataSearch;

using Microsoft.Assembly.Document;
using Microsoft.Bank.BankAccount;
using Microsoft.CRM.Campaign;
using Microsoft.CRM.Contact;
using Microsoft.CRM.Interaction;
using Microsoft.CRM.Opportunity;
using Microsoft.CRM.RoleCenters;
using Microsoft.CRM.Task;
using Microsoft.CRM.Team;
using Microsoft.Finance.Consolidation;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.RoleCenters;
using Microsoft.Finance.SalesTax;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Reporting;
using Microsoft.Foundation.Shipping;
using Microsoft.HumanResources.Employee;
using Microsoft.Projects.RoleCenters;
using Microsoft.Inventory.Intrastat;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Manufacturing.RoleCenters;
using Microsoft.Manufacturing.Routing;
using Microsoft.Manufacturing.WorkCenter;
using Microsoft.Manufacturing.MachineCenter;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Planning;
using Microsoft.Projects.Project.Ledger;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.RoleCenters;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.History;
using Microsoft.Sales.Pricing;
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Reminder;
using Microsoft.Sales.RoleCenters;
using Microsoft.Service.Document;
using Microsoft.Service.Item;
using Microsoft.Service.Loaner;
using Microsoft.Service.Contract;
using Microsoft.Service.History;
using Microsoft.Service.RoleCenters;
using Microsoft.Warehouse.Document;
using Microsoft.Warehouse.Activity;
using Microsoft.Warehouse.Activity.History;
using Microsoft.Inventory.Transfer;
using Microsoft.Warehouse.History;
using Microsoft.Warehouse.RoleCenters;
using Microsoft.Warehouse.Worksheet;
using Microsoft.Inventory.Ledger;
using Microsoft.Intercompany.Partner;
using System.Globalization;
using System.Reflection;
using System.Security.AccessControl;

codeunit 2681 "Data Search Defaults"
{
    Permissions = tabledata "Data Search Setup (Table)" = rim,
                  tabledata "Data Search Setup (Field)" = rim;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        BaseLbl: Label '(default)';
        AllProfileDescriptionFilterTxt: Label 'Navigation menu only.';

    // OnRun mainly provided for test, but can also be used for default init
    trigger OnRun()
    begin
        InitSetupForAllProfiles();
    end;

    internal procedure InitSetupForAllProfiles()
    var
        TempAllProfile: Record "All Profile" temporary;
    begin
        PopulateProfiles(TempAllProfile);
        if TempAllProfile.FindSet() then
            repeat
                InitSetupForProfile(TempAllProfile."Role Center ID");
            until TempAllProfile.Next() = 0;
    end;

    internal procedure InitSetupForProfile(RoleCenterID: Integer)
    var
        DataSearchEvents: Codeunit "Data Search Events";
        TableList: List of [Integer];
        TableNo: Integer;
    begin
        case RoleCenterID of
            Page::"Order Processor Role Center":
                GetTableListForOrderProcessor(TableList);
            Page::"Accountant Role Center":
                GetTableListForAccountant(TableList);
            Page::"Business Manager Role Center":
                GetTableListForBusinessManager(TableList);
            Page::"Service Dispatcher Role Center", Page::"Service Manager Role Center":
                GetTableListForServiceManager(TableList);
            Page::"Production Planner Role Center":
                GetTableListForManufacturingManager(TableList);
            Page::"Project Manager Role Center", Page::"Job Project Manager RC":
                GetTableListForProjectManager(TableList);
            Page::"Sales & Relationship Mgr. RC":
                GetTableListForSalesAndRelManager(TableList);
            Page::"Security Admin Role Center":
                GetTableListForUserAdmin(TableList);
            Page::"Whse. Basic Role Center":
                GetTableListForInventoryManager(TableList);
            Page::"Whse. WMS Role Center":
                GetTableListForWarehouseManager(TableList);
            Page::"Whse. Worker WMS Role Center":
                GetTableListForWarehouseEmployee(TableList);
            Page::"Team Member Role Center":
                GetTableListForTeamMember(TableList);
            else
                GetDefaultTableList(TableList);
        end;
        OnAfterGetTableList(RoleCenterID, TableList);
        DataSearchEvents.OnAfterGetRolecCenterTableList(RoleCenterID, TableList);
        foreach TableNo in TableList do
            InitSetupForTable(RoleCenterID, TableNo);
    end;

    local procedure GetDefaultTableList(var TableList: List of [Integer])
    begin
        TableList.Add(Database::Customer);
        TableList.Add(Database::Vendor);
        TableList.Add(Database::Contact);
        TableList.Add(Database::"Sales Header");
        TableList.Add(Database::"Sales Line");
        TableList.Add(Database::"Purchase Header");
        TableList.Add(Database::"Purchase Line");
        TableList.Add(Database::"Cust. Ledger Entry");
        TableList.Add(Database::"Vendor Ledger Entry");
        TableList.Add(Database::Item);
        TableList.Add(Database::"Sales Invoice Header");
        TableList.Add(Database::"Sales Invoice Line");
        TableList.Add(Database::"Sales Shipment Header");
        TableList.Add(Database::"Sales Shipment Line");
        TableList.Add(Database::"Sales Cr.Memo Header");
        TableList.Add(Database::"Sales Cr.Memo Line");
        TableList.Add(Database::"Purch. Inv. Header");
        TableList.Add(Database::"Purch. Inv. Line");
        TableList.Add(Database::"Purch. Rcpt. Header");
        TableList.Add(Database::"Purch. Rcpt. Line");
        TableList.Add(Database::"Purch. Cr. Memo Hdr.");
        TableList.Add(Database::"Purch. Cr. Memo Line");
    end;

    local procedure GetTableListForOrderProcessor(var TableList: List of [Integer])
    begin
        TableList.Add(Database::Customer);
        TableList.Add(Database::Contact);
        TableList.Add(Database::"Sales Header");
        TableList.Add(Database::"Sales Line");
        TableList.Add(Database::"Cust. Ledger Entry");
        TableList.Add(Database::Item);
        TableList.Add(Database::Resource);
        TableList.Add(Database::Location);
        TableList.Add(Database::"Sales Invoice Header");
        TableList.Add(Database::"Sales Invoice Line");
        TableList.Add(Database::"Sales Shipment Header");
        TableList.Add(Database::"Sales Shipment Line");
        TableList.Add(Database::"Sales Cr.Memo Header");
        TableList.Add(Database::"Sales Cr.Memo Line");
        TableList.Add(Database::"Assembly Header");
        TableList.Add(Database::"Assembly Line");
    end;

    local procedure GetTableListForAccountant(var TableList: List of [Integer])
    begin
        TableList.Add(Database::"G/L Entry");
        TableList.Add(Database::Customer);
        TableList.Add(Database::"Cust. Ledger Entry");
        TableList.Add(Database::Vendor);
        TableList.Add(Database::"Vendor Ledger Entry");
        TableList.Add(Database::"Gen. Journal Line");
        TableList.Add(Database::"Sales Invoice Header");
        TableList.Add(Database::"Sales Invoice Line");
        TableList.Add(Database::"Sales Cr.Memo Header");
        TableList.Add(Database::"Sales Cr.Memo Line");
        TableList.Add(Database::"Purch. Inv. Header");
        TableList.Add(Database::"Purch. Inv. Line");
        TableList.Add(Database::"Purch. Cr. Memo Hdr.");
        TableList.Add(Database::"Purch. Cr. Memo Line");
        TableList.Add(Database::"Reminder Header");
        TableList.Add(Database::"Reminder Line");
        TableList.Add(Database::"Issued Reminder Header");
        TableList.Add(Database::"Issued Reminder Line");
    end;

    local procedure GetTableListForBusinessManager(var TableList: List of [Integer])
    begin
        GetTableListForAccountant(TableList);
        TableList.Add(Database::Item);
        TableList.Add(Database::Contact);
    end;

    local procedure GetTableListForServiceManager(var TableList: List of [Integer])
    begin
        TableList.Add(Database::Customer);
        TableList.Add(Database::"Cust. Ledger Entry");
        TableList.Add(Database::"Sales Invoice Header");
        TableList.Add(Database::"Sales Invoice Line");
        TableList.Add(Database::"Sales Cr.Memo Header");
        TableList.Add(Database::"Sales Cr.Memo Line");
        TableList.Add(Database::"Service Header");
        TableList.Add(Database::"Service Item Line");
        TableList.Add(Database::"Service Line");
        TableList.Add(Database::"Service Item");
        TableList.Add(Database::"Loaner");
        TableList.Add(Database::"Service Contract Header");
        TableList.Add(Database::"Service Contract Line");
        TableList.Add(Database::"Service Invoice Header");
        TableList.Add(Database::"Service Invoice Line");
        TableList.Add(Database::"Service Shipment Header");
        TableList.Add(Database::"Service Shipment Item Line");
        TableList.Add(Database::"Service Shipment Line");
        TableList.Add(Database::"Service Cr.Memo Header");
        TableList.Add(Database::"Service Cr.Memo Line");
    end;

    local procedure GetTableListForManufacturingManager(var TableList: List of [Integer])
    begin
        TableList.Add(Database::Item);
        TableList.Add(Database::"Production Order");
        TableList.Add(Database::"Prod. Order Line");
        TableList.Add(Database::"Production BOM Header");
        TableList.Add(Database::"Production BOM Line");
        TableList.Add(Database::"Routing Header");
        TableList.Add(Database::"Routing Line");
        TableList.Add(Database::"Assembly Header");
        TableList.Add(Database::"Assembly Line");
        TableList.Add(Database::"Work Center");
        TableList.Add(Database::"Machine Center");
        TableList.Add(Database::Resource);
    end;

    local procedure GetTableListForProjectManager(var TableList: List of [Integer])
    begin
        TableList.Add(Database::Customer);
        TableList.Add(Database::"Sales Invoice Header");
        TableList.Add(Database::"Sales Invoice Line");
        TableList.Add(Database::"Sales Cr.Memo Header");
        TableList.Add(Database::"Sales Cr.Memo Line");
        TableList.Add(Database::Job);
        TableList.Add(Database::"Job Task");
        TableList.Add(Database::"Job Planning Line");
        TableList.Add(Database::"Job Ledger Entry");
        TableList.Add(Database::Resource);
    end;

    local procedure GetTableListForSalesAndRelManager(var TableList: List of [Integer])
    begin
        TableList.Add(Database::Customer);
        TableList.Add(Database::Contact);
        TableList.Add(Database::"Interaction Log Entry");
        TableList.Add(Database::"To-Do");
        TableList.Add(Database::Campaign);
        TableList.Add(Database::Opportunity);
    end;

    local procedure GetTableListForUserAdmin(var TableList: List of [Integer])
    begin
        TableList.Add(Database::Employee);
        TableList.Add(Database::User);
    end;

    local procedure GetTableListForInventoryManager(var TableList: List of [Integer])
    begin
        TableList.Add(Database::Item);
        TableList.Add(Database::"Item Ledger Entry");
        TableList.Add(Database::Location);
    end;

    local procedure GetTableListForWarehouseManager(var TableList: List of [Integer])
    begin
        TableList.Add(Database::Item);
        TableList.Add(Database::Location);
        TableList.Add(Database::"Sales Shipment Header");
        TableList.Add(Database::"Sales Shipment Line");
        TableList.Add(Database::"Purch. Rcpt. Header");
        TableList.Add(Database::"Purch. Rcpt. Line");
        TableList.Add(Database::"Warehouse Shipment Header");
        TableList.Add(Database::"Warehouse Shipment Line");
        TableList.Add(Database::"Warehouse Receipt Header");
        TableList.Add(Database::"Warehouse Receipt Line");
        TableList.Add(Database::"Warehouse Activity Header");
        TableList.Add(Database::"Warehouse Activity Line");
        TableList.Add(Database::"Whse. Worksheet Line");
        TableList.Add(Database::"Transfer Header");
        TableList.Add(Database::"Transfer Line");
        TableList.Add(Database::"Registered Whse. Activity Hdr.");
        TableList.Add(Database::"Registered Whse. Activity Line");
        TableList.Add(Database::"Posted Whse. Receipt Header");
        TableList.Add(Database::"Posted Whse. Receipt Line");
        TableList.Add(Database::"Assembly Header");
        TableList.Add(Database::"Assembly Line");
    end;

    local procedure GetTableListForWarehouseEmployee(var TableList: List of [Integer])
    begin
        TableList.Add(Database::Location);
        TableList.Add(Database::"Sales Shipment Header");
        TableList.Add(Database::"Sales Shipment Line");
        TableList.Add(Database::"Purch. Rcpt. Header");
        TableList.Add(Database::"Purch. Rcpt. Line");
        TableList.Add(Database::"Warehouse Shipment Header");
        TableList.Add(Database::"Warehouse Shipment Line");
        TableList.Add(Database::"Warehouse Receipt Header");
        TableList.Add(Database::"Warehouse Receipt Line");
        TableList.Add(Database::"Warehouse Activity Header");
        TableList.Add(Database::"Warehouse Activity Line");
        TableList.Add(Database::"Transfer Header");
        TableList.Add(Database::"Transfer Line");
        TableList.Add(Database::"Posted Whse. Receipt Header");
        TableList.Add(Database::"Posted Whse. Receipt Line");
    end;

    local procedure GetTableListForTeamMember(var TableList: List of [Integer])
    begin
        TableList.Add(Database::Customer);
        TableList.Add(Database::Item);
    end;

    internal procedure InitSetupForTable(RoleCenterID: Integer; TableNo: Integer)
    var
        DataSearchSetupTable: Record "Data Search Setup (Table)";
    begin
        DataSearchSetupTable.SetRange("Table No.", TableNo);
        DataSearchSetupTable.SetRange("Role Center ID", RoleCenterID);
        if not DataSearchSetupTable.IsEmpty then
            exit;
        DataSearchSetupTable.Reset();
        DataSearchSetupTable.Init();
        DataSearchSetupTable."Table No." := TableNo;
        DataSearchSetupTable."Role Center ID" := RoleCenterID;
        DataSearchSetupTable."No. of Hits" := 0;
        if DataSearchSetupTable."Table No." in [Database::Contact] then
            DataSearchSetupTable."No. of Hits" := 1; // move to top of list
        DataSearchSetupTable.InsertRec(true);
        AddDefaultFields(TableNo);
    end;

    internal procedure AddDefaultFields(TableNo: Integer)
    var
        FieldList: List of [Integer];
    begin
        if not AddFullTextIndexedFields(TableNo, FieldList) then begin
            AddTextFields(TableNo, FieldList);
            AddIndexedFields(TableNo, FieldList);
            AddOtherFields(TableNo, FieldList);
        end;
        InsertFields(TableNo, FieldList);
    end;

    internal procedure AddFullTextIndexedFields(TableNo: Integer; var FieldList: List of [Integer]): Boolean
    var
        Field: Record Field;
    begin
        Field.SetRange(TableNo, TableNo);
        Field.SetRange(Class, Field.Class::Normal);
        Field.SetRange(OptimizeForTextSearch, true);
        if not Field.FindSet() then
            exit(false);
        repeat
            if not FieldList.Contains(Field."No.") then
                FieldList.Add(Field."No.");
        until Field.Next() = 0;
        exit(true);
    end;

    internal procedure AddTextFields(TableNo: Integer; var FieldList: List of [Integer])
    var
        Field: Record Field;
    begin
        Field.SetRange(TableNo, TableNo);
        Field.SetRange(Class, Field.Class::Normal);
        Field.SetRange(Type, Field.Type::Text);
        if Field.FindSet() then
            repeat
                if not FieldList.Contains(Field."No.") then
                    FieldList.Add(Field."No.");
            until Field.Next() = 0;
    end;

    internal procedure AddIndexedFields(TableNo: Integer; var FieldList: List of [Integer])
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        KeyRef: KeyRef;
        i: Integer;
        j: Integer;
    begin
        if TableNo = 0 then
            exit;
        RecRef.Open(TableNo);
        for i := 1 to RecRef.KeyCount do begin
            KeyRef := RecRef.KeyIndex(i);
            for j := 1 to KeyRef.FieldCount do begin
                FldRef := KeyRef.FieldIndex(j);
                if (FldRef.Type in [FldRef.Type::Text, FldRef.Type::Code]) and (FldRef.Class = FldRef.Class::Normal) and not ExcludedField(FldRef) then
                    if not FieldList.Contains(FldRef.Number) then
                        FieldList.Add(FldRef.Number);
            end;
        end;
    end;

    local procedure ExcludedField(var FldRef: FieldRef): Boolean
    var
        DataSearchEvents: Codeunit "Data Search Events";
        FieldIsExcluded: Boolean;
    begin
        if FldRef.Relation = 0 then
            exit;
        FieldIsExcluded := (
            FldRef.Relation in [
                Database::User, Database::"Dimension Value", Database::"Source Code", Database::"Business Unit", Database::"Reason Code", Database::"Gen. Business Posting Group",
                Database::"Gen. Product Posting Group", Database::"No. Series", Database::"Tax Area", Database::"Tax Group", Database::"VAT Business Posting Group", Database::"VAT Product Posting Group",
                Database::"IC Partner", Database::"Document Sending Profile", Database::Territory, Database::"Customer Posting Group", Database::"Customer Price Group",
                Database::Language, Database::"Payment Terms", Database::"Finance Charge Terms", Database::"Salesperson/Purchaser", Database::"Shipment Method", Database::"Customer Discount Group",
                Database::"Country/Region", Database::"Payment Method", Database::Location, Database::"Reminder Terms", Database::Currency, Database::"Responsibility Center"
        ]);
        if not FieldIsExcluded then
            DataSearchEvents.OnGetExcludedRelatedTableField(FldRef.Relation, FieldIsExcluded);
        exit(FieldIsExcluded);
    end;

    local procedure AddOtherFields(TableNo: Integer; var ListOfFieldNumbers: List of [Integer])
    var
        DataSearchEvents: Codeunit "Data Search Events";
    begin
        DataSearchEvents.OnAfterGetFieldListForTable(TableNo, ListOfFieldNumbers);
    end;

    local procedure InsertFields(TableNo: Integer; var FieldList: List of [Integer])
    var
        DataSearchSetupField: Record "Data Search Setup (Field)";
        FieldNo: Integer;
    begin
        if FieldList.Count = 0 then
            exit;
        foreach Fieldno in FieldList do
            if not DataSearchSetupField.Get(TableNo, FieldNo) then begin
                DataSearchSetupField.Init();
                DataSearchSetupField."Table No." := TableNo;
                DataSearchSetupField."Field No." := FieldNo;
                DataSearchSetupField."Enable Search" := true;
                DataSearchSetupField.Insert();
            end;
    end;

    internal procedure PopulateProfiles(var TempAllProfile: Record "All Profile" temporary)
    var
        AllProfile: Record "All Profile";
    begin
        TempAllProfile.Reset();
        TempAllProfile.DeleteAll();
        TempAllProfile.Caption := CopyStr(BaseLbl, 1, MaxStrLen(TempAllProfile.Caption));
        TempAllProfile."Profile ID" := '';  // default
        TempAllProfile.Insert();
        AllProfile.SetRange(Enabled, true);
        AllProfile.SetFilter(Description, '<> %1', AllProfileDescriptionFilterTxt);
        if AllProfile.FindSet() then
            repeat
                TempAllProfile := AllProfile;
                if IsNullGuid(TempAllProfile."App ID") then
                    clear(TempAllProfile."App Name");
                TempAllProfile.Insert();
            until AllProfile.Next() = 0;
    end;


    /// <summary>
    /// Enables adding and removing tables from the default initial setup for tables to search.
    /// </summary>
    /// <param name="RoleCenterID">Page ID for the selected role center</param>
    /// <param name="ListOfTableNumbers">List of integer. Already filled with standard tables.</param>
    [IntegrationEvent(false, false)]
    local procedure OnAfterGetTableList(RoleCenterID: Integer; var ListOfTableNumbers: List of [Integer])
    begin
    end;
}