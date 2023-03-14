codeunit 2681 "Data Search Defaults"
{
    Permissions = tabledata "Data Search Setup (Table)" = rim,
                  tabledata "Data Search Setup (Field)" = rim;

    var
        BaseLbl: Label '(default)';
        AllProfileDescriptionFilterTxt: Label 'Navigation menu only.';

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
        Case RoleCenterID of
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
        End;
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
        TableList.Add(Database::"Sales Invoice Header");
        TableList.Add(Database::"Sales Invoice Line");
        TableList.Add(Database::"Sales Cr.Memo Header");
        TableList.Add(Database::"Sales Cr.Memo Line");
        TableList.Add(Database::"Purch. Inv. Header");
        TableList.Add(Database::"Purch. Inv. Line");
        TableList.Add(Database::"Purch. Cr. Memo Hdr.");
        TableList.Add(Database::"Purch. Cr. Memo Line");
    end;

    local procedure GetTableListForBusinessManager(var TableList: List of [Integer])
    begin
        TableList.Add(Database::"G/L Entry");
        TableList.Add(Database::Customer);
        TableList.Add(Database::"Cust. Ledger Entry");
        TableList.Add(Database::Vendor);
        TableList.Add(Database::"Vendor Ledger Entry");
        TableList.Add(Database::Item);
        TableList.Add(Database::Contact);
        TableList.Add(Database::"Sales Invoice Header");
        TableList.Add(Database::"Sales Invoice Line");
        TableList.Add(Database::"Sales Cr.Memo Header");
        TableList.Add(Database::"Sales Cr.Memo Line");
        TableList.Add(Database::"Purch. Inv. Header");
        TableList.Add(Database::"Purch. Inv. Line");
        TableList.Add(Database::"Purch. Cr. Memo Hdr.");
        TableList.Add(Database::"Purch. Cr. Memo Line");
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
    end;

    local procedure GetTableListForWarehouseManager(var TableList: List of [Integer])
    begin
        TableList.Add(Database::Item);
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
        if DataSearchSetupTable.Get(TableNo, RoleCenterID) then
            exit;
        DataSearchSetupTable.Init();
        DataSearchSetupTable."Table No." := TableNo;
        DataSearchSetupTable."Role Center ID" := RoleCenterID;
        DataSearchSetupTable."No. of Hits" := 0;
        if DataSearchSetupTable."Table No." in [Database::Contact] then
            DataSearchSetupTable."No. of Hits" := 1; // move to top of list
        DataSearchSetupTable.Insert(true);
        AddTextFields(TableNo);
        AddIndexedFields(TableNo);
    end;

    internal procedure AddTextFields(TableNo: Integer)
    var
        Field: Record Field;
        DataSearchSetupField: Record "Data Search Setup (Field)";
    begin
        Field.SetRange(TableNo, TableNo);
        Field.SetRange(Class, Field.Class::Normal);
        Field.SetRange(Type, Field.Type::Text);
        if Field.FindSet() then
            repeat
                if not DataSearchSetupField.Get(TableNo, Field."No.") then begin
                    DataSearchSetupField.Init();
                    DataSearchSetupField."Table No." := TableNo;
                    DataSearchSetupField."Field No." := Field."No.";
                    DataSearchSetupField."Enable Search" := true;
                    DataSearchSetupField.Insert();
                end;
            until Field.Next() = 0;
    end;

    internal procedure AddIndexedFields(TableNo: Integer)
    var
        DataSearchSetupField: Record "Data Search Setup (Field)";
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
                    if not DataSearchSetupField.Get(TableNo, FldRef.Number) then begin
                        DataSearchSetupField.Init();
                        DataSearchSetupField."Table No." := TableNo;
                        DataSearchSetupField."Field No." := FldRef.Number;
                        DataSearchSetupField."Enable Search" := true;
                        DataSearchSetupField.Insert();
                    end;
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