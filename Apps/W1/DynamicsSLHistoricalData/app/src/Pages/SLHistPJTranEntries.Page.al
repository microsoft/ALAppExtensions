// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

page 42804 "SL Hist. PJTran Entries"
{
    AdditionalSearchTerms = 'SL PJ Transactions, SL Historical Entries, SL Historical Project Entries, SL Project Transactions';
    ApplicationArea = Basic, Suite;
    Caption = 'SL Historical Project Transaction Entries';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    MultipleNewLines = false;
    PageType = List;
    Permissions = TableData "SL Hist. PJTran" = m;
    SourceTable = "SL Hist. PJTran";
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Project"; Rec.project)
                {
                    Caption = 'Project';
                    Editable = false;
                    ToolTip = 'Specifies the Project that the entry belongs to.';
                }
                field("Project Description"; ProjectDescription)
                {
                    Caption = 'Project Description';
                    Editable = false;
                    ToolTip = 'Specifies the description of the project.';
                }
                field("Customer"; ProjectCustomer)
                {
                    Caption = 'Customer';
                    Editable = false;
                    ToolTip = 'Specifies the customer associated with the project.';
                }
                field("Task"; Rec.pjt_entity)
                {
                    Caption = 'Task';
                    Editable = false;
                    ToolTip = 'Specifies the task associated with the entry.';
                }
                field("Subtask"; Rec.SubTask_Name)
                {
                    Caption = 'Subtask';
                    Editable = false;
                    ToolTip = 'Specifies the subtask name associated with the entry.';
                }
                field("Company"; Rec.CpnyId)
                {
                    Caption = 'Company';
                    Editable = false;
                    ToolTip = 'Specifies the Company ID that the entry belongs to.';
                }
                field("Account Category"; Rec.acct)
                {
                    Caption = 'Account Category';
                    Editable = false;
                    ToolTip = 'Specifies the account category of the entry.';
                }
                field("Transaction Date"; Rec.trans_date)
                {
                    Caption = 'Transaction Date';
                    Editable = false;
                    ToolTip = 'Specifies the entry''s transaction date.';
                }
                field("Amount"; Rec.amount)
                {
                    Caption = 'Amount';
                    Editable = false;
                    ToolTip = 'Specifies the amount of the entry.';
                }
                field("Units"; Rec.units)
                {
                    Caption = 'Units';
                    Editable = false;
                    ToolTip = 'Specifies the units of the entry.';
                }
                field("Base Currency ID"; Rec.BaseCuryId)
                {
                    Caption = 'Base Currency ID';
                    Editable = false;
                    ToolTip = 'Specifies the base currency ID of the entry.';
                }
                field("Currency ID"; Rec.CuryId)
                {
                    Caption = 'Currency ID';
                    Editable = false;
                    ToolTip = 'Specifies the currency ID of the entry.';
                }
                field("Currency Amount"; Rec.CuryTranamt)
                {
                    Caption = 'Currency Amount';
                    Editable = false;
                    ToolTip = 'Specifies the currency amount of the entry.';
                }
                field("Resource"; Rec.employee)
                {
                    Caption = 'Resource';
                    Editable = false;
                    ToolTip = 'Specifies the resource (employee) associated with the entry.';
                }
                field("Resource Name"; ResourceName)
                {
                    Caption = 'Resource Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the resource (employee) associated with the entry.';
                }
                field("Project Manager"; ProjectManager)
                {
                    Caption = 'Project Manager';
                    Editable = false;
                    ToolTip = 'Specifies the project manager.';
                }
                field("Project Mgr Name"; ProjectMgrName)
                {
                    Caption = 'Project Mgr Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the project manager.';
                }
                field("Transaction Status"; Rec.tr_status)
                {
                    Caption = 'Transaction Status';
                    Editable = false;
                    ToolTip = 'Specifies the transaction status of the entry.';
                }
                field("Transaction Comment"; Rec.tr_comment)
                {
                    Caption = 'Transaction Comment';
                    Editable = false;
                    ToolTip = 'Specifies the transaction comment of the entry.';
                }
                field("G/L Account"; Rec.gl_acct)
                {
                    Caption = 'G/L Account';
                    Editable = false;
                    ToolTip = 'Specifies the G/L account of the entry.';
                }
                field("Subaccount"; Rec.gl_subacct)
                {
                    Caption = 'Subaccount';
                    Editable = false;
                    ToolTip = 'Specifies the subaccount of the entry.';
                }
                field("Labor Class"; Rec.tr_id05)
                {
                    Caption = 'Labor Class';
                    Editable = false;
                    ToolTip = 'Specifies the labor class of the entry.';
                }
                field("Fiscal Period"; Rec.fiscalno)
                {
                    Caption = 'Fiscal Period';
                    Editable = false;
                    ToolTip = 'Specifies the fiscal period of the entry.';
                }
                field("System Code"; Rec.system_cd)
                {
                    Caption = 'System Code';
                    Editable = false;
                    ToolTip = 'Specifies the system code of the entry.';
                }
                field("Batch ID"; Rec.batch_id)
                {
                    Caption = 'Batch ID';
                    Editable = false;
                    ToolTip = 'Specifies the batch ID of the entry.';
                }
                field("Batch Type"; Rec.batch_type)
                {
                    Caption = 'Batch Type';
                    Editable = false;
                    ToolTip = 'Specifies the batch type of the entry.';
                }
                field("Doc Num from T&E"; Rec.bill_batch_id)
                {
                    Caption = 'Doc Num from T&E';
                    Editable = false;
                    ToolTip = 'Specifies the document number from T&E.';
                }
                field("Vendor Number"; Rec.vendor_num)
                {
                    Caption = 'Vendor Number';
                    Editable = false;
                    ToolTip = 'Specifies the vendor number of the entry.';
                }
                field("RefNbr from Source Trans"; Rec.voucher_num)
                {
                    Caption = 'RefNbr from Source Trans';
                    Editable = false;
                    ToolTip = 'Specifies the reference number from the source transaction.';
                }
                field("Allocation Flag"; Rec.alloc_flag)
                {
                    Caption = 'Allocation Flag';
                    Editable = false;
                    ToolTip = 'Specifies the allocation flag of the entry.';
                }
                field("Line from Source Trans"; Rec.voucher_line)
                {
                    Caption = 'Line from Source Trans';
                    Editable = false;
                    ToolTip = 'Specifies the line from the source transaction.';
                }
                field("Invoice Number"; Rec.tr_id02)
                {
                    Caption = 'Invoice Number';
                    Editable = false;
                    ToolTip = 'Specifies the invoice number of the entry.';
                }
                field("PO Number"; Rec.tr_id03)
                {
                    Caption = 'PO Number';
                    Editable = false;
                    ToolTip = 'Specifies the purchase order number of the entry.';
                }
                field("Inventory ID"; InventoryId)
                {
                    Caption = 'Inventory ID';
                    Editable = false;
                    ToolTip = 'Specifies the inventory ID of the entry.';
                }
                field("Detail Number"; Rec.detail_num)
                {
                    Caption = 'Detail Number';
                    Editable = false;
                    ToolTip = 'Specifies the detail number of the entry.';
                }
                field("Subcontract"; Rec.Subcontract)
                {
                    Caption = 'Subcontract';
                    Editable = false;
                    ToolTip = 'Specifies the subcontract of the entry.';
                }
                field("Unit of Measure"; Rec.unit_of_measure)
                {
                    Caption = 'Unit of Measure';
                    Editable = false;
                    ToolTip = 'Specifies the unit of measure of the entry.';
                }
                field("Equipment ID"; EquipmentId)
                {
                    Caption = 'Equipment ID';
                    Editable = false;
                    ToolTip = 'Specifies the equipment ID of the entry.';
                }
                field("Lot Serial Number"; LotSerialNbr)
                {
                    Caption = 'Lot Serial Number';
                    Editable = false;
                    ToolTip = 'Specifies the lot serial number of the entry.';
                }
                field("Sales Order Num"; SalesOrderNum)
                {
                    Caption = 'Sales Order Num';
                    Editable = false;
                    ToolTip = 'Specifies the sales order number of the entry.';
                }
                field("Sales Order Line"; SalesOrderLine)
                {
                    Caption = 'Sales Order Line';
                    Editable = false;
                    ToolTip = 'Specifies the sales order line of the entry.';
                }
                field("Shipper ID"; ShipperId)
                {
                    Caption = 'Shipper ID';
                    Editable = false;
                    ToolTip = 'Specifies the shipper ID of the entry.';
                }
                field("Shipper Line"; ShipperLine)
                {
                    Caption = 'Shipper Line';
                    Editable = false;
                    ToolTip = 'Specifies the shipper line of the entry.';
                }
                field("Site ID"; SiteId)
                {
                    Caption = 'Site ID';
                    Editable = false;
                    ToolTip = 'Specifies the site ID of the entry.';
                }
                field("Warehouse Location"; WarehouseLocation)
                {
                    Caption = 'Warehouse Location';
                    Editable = false;
                    ToolTip = 'Specifies the warehouse location of the entry.';
                }
                field("User1"; Rec.user1)
                {
                    Caption = 'User1';
                    Editable = false;
                    ToolTip = 'Specifies the user1 field of the entry.';
                    Visible = false;
                }
                field("User2"; Rec.user2)
                {
                    Caption = 'User2';
                    Editable = false;
                    ToolTip = 'Specifies the user2 field of the entry.';
                    Visible = false;
                }
                field("User3"; Rec.user3)
                {
                    Caption = 'User3';
                    Editable = false;
                    ToolTip = 'Specifies the user3 field of the entry.';
                    Visible = false;
                }
                field("User4"; Rec.user4)
                {
                    Caption = 'User4';
                    Editable = false;
                    ToolTip = 'Specifies the user4 field of the entry.';
                    Visible = false;
                }
                field("tr_id01"; Rec.tr_id01)
                {
                    Caption = 'tr_id01';
                    Editable = false;
                    ToolTip = 'Specifies the tr_id01 field of the entry.';
                    Visible = false;
                }
                field("Source Batch Num"; Rec.tr_id04)
                {
                    Caption = 'Source Batch Num';
                    Editable = false;
                    ToolTip = 'Specifies the source batch number of the entry.';
                    Visible = false;
                }
                field("tr_id06"; Rec.tr_id06)
                {
                    Caption = 'tr_id06';
                    Editable = false;
                    ToolTip = 'Specifies the tr_id06 field of the entry.';
                    Visible = false;
                }
                field("tr_id07"; Rec.tr_id07)
                {
                    Caption = 'tr_id07';
                    Editable = false;
                    ToolTip = 'Specifies the tr_id07 field of the entry.';
                    Visible = false;
                }
                field("Invoice Date"; Rec.tr_id08)
                {
                    Caption = 'Invoice Date';
                    Editable = false;
                    ToolTip = 'Specifies the invoice date of the entry.';
                    Visible = false;
                }
                field("tr_id09"; Rec.tr_id09)
                {
                    Caption = 'tr_id09';
                    Editable = false;
                    ToolTip = 'Specifies the tr_id09 field of the entry.';
                    Visible = false;
                }
                field("tr_id10"; Rec.tr_id10)
                {
                    Caption = 'tr_id10';
                    Editable = false;
                    ToolTip = 'Specifies the tr_id10 field of the entry.';
                    Visible = false;
                }
                field("tr_id23"; Rec.tr_id23)
                {
                    Caption = 'tr_id23';
                    Editable = false;
                    ToolTip = 'Specifies the tr_id23 field of the entry.';
                    Visible = false;
                }
                field("Hrs Type+Shift+Earn Type"; Rec.tr_id24)
                {
                    Caption = 'Hrs Type+Shift+Earn Type';
                    Editable = false;
                    ToolTip = 'Specifies the hours type, shift, and earn type of the entry.';
                    Visible = false;
                }
                field("tr_id25"; Rec.tr_id25)
                {
                    Caption = 'tr_id25';
                    Editable = false;
                    ToolTip = 'Specifies the tr_id25 field of the entry.';
                    Visible = false;
                }
                field("Utilization Period"; Rec.tr_id26)
                {
                    Caption = 'Utilization Period';
                    Editable = false;
                    ToolTip = 'Specifies the utilization period of the entry.';
                    Visible = false;
                }
                field("tr_id27"; Rec.tr_id27)
                {
                    Caption = 'tr_id27';
                    Editable = false;
                    ToolTip = 'Specifies the tr_id27 field of the entry.';
                    Visible = false;
                }
                field("Original Cost of Allocated Trans"; Rec.tr_id28)
                {
                    Caption = 'Original Cost of Allocated Trans';
                    Editable = false;
                    ToolTip = 'Specifies the original cost of the allocated transaction.';
                    Visible = false;
                }
                field("tr_id29"; Rec.tr_id29)
                {
                    Caption = 'tr_id29';
                    Editable = false;
                    ToolTip = 'Specifies the tr_id29 field of the entry.';
                    Visible = false;
                }
                field("PJInvDet Trans ID"; Rec.tr_id30)
                {
                    Caption = 'PJInvDet Trans ID';
                    Editable = false;
                    ToolTip = 'Specifies the PJInvDet transaction ID of the entry.';
                    Visible = false;
                }
                field("tr_id31"; Rec.tr_id31)
                {
                    Caption = 'tr_id31';
                    Editable = false;
                    ToolTip = 'Specifies the tr_id31 field of the entry.';
                    Visible = false;
                }
                field("tr_id32"; Rec.tr_id32)
                {
                    Caption = 'tr_id32';
                    Editable = false;
                    ToolTip = 'Specifies the tr_id32 field of the entry.';
                    Visible = false;
                }
                field("Key of Originating Trans"; KeyOfOriginatingTrans)
                {
                    Caption = 'Key of Originating Trans';
                    Editable = false;
                    ToolTip = 'Specifies the key of the originating transaction.';
                    Visible = false;
                }
                field("tr_id13"; TrId13)
                {
                    Caption = 'tr_id13';
                    Editable = false;
                    ToolTip = 'Specifies the tr_id13 field of the entry.';
                    Visible = false;
                }
                field("tr_id14"; TrId14)
                {
                    Caption = 'tr_id14';
                    Editable = false;
                    ToolTip = 'Specifies the tr_id14 field of the entry.';
                    Visible = false;
                }
                field("WO Info"; WOInfo)
                {
                    Caption = 'WO Info';
                    Editable = false;
                    ToolTip = 'Specifies the work order info of the entry.';
                    Visible = false;
                }
                field("Payroll Work Loc"; PayrollWorkLoc)
                {
                    Caption = 'Payroll Work Loc';
                    Editable = false;
                    ToolTip = 'Specifies the payroll work location of the entry.';
                    Visible = false;
                }
                field("tr_id17"; TrId17)
                {
                    Caption = 'tr_id17';
                    Editable = false;
                    ToolTip = 'Specifies the tr_id17 field of the entry.';
                    Visible = false;
                }
                field("tr_id18"; TrId18)
                {
                    Caption = 'tr_id18';
                    Editable = false;
                    ToolTip = 'Specifies the tr_id18 field of the entry.';
                    Visible = false;
                }
                field("tr_id19"; TrId19)
                {
                    Caption = 'tr_id19';
                    Editable = false;
                    ToolTip = 'Specifies the tr_id19 field of the entry.';
                    Visible = false;
                }
                field("Offset Cpny, Acct, Sub"; OffsetCpnyAcctSub)
                {
                    Caption = 'Offset Cpny, Acct, Sub';
                    Editable = false;
                    ToolTip = 'Specifies the offset company, account, and subaccount of the entry.';
                    Visible = false;
                }
                field("tr_id21"; TrId21)
                {
                    Caption = 'tr_id21';
                    Editable = false;
                    ToolTip = 'Specifies the tr_id21 field of the entry.';
                    Visible = false;
                }
                field("Timecard Period End"; TimecardPeriodEnd)
                {
                    Caption = 'Timecard Period End';
                    Editable = false;
                    ToolTip = 'Specifies the timecard period end date of the entry.';
                    Visible = false;
                }
                field("Create Date"; Rec.crtd_datetime)
                {
                    Caption = 'Create Date';
                    Editable = false;
                    ToolTip = 'Specifies the creation date of the entry.';
                    Visible = false;
                }
                field("Create Program"; Rec.crtd_prog)
                {
                    Caption = 'Create Program';
                    Editable = false;
                    ToolTip = 'Specifies the program that created the entry.';
                    Visible = false;
                }
                field("Create User"; Rec.crtd_user)
                {
                    Caption = 'Create User';
                    Editable = false;
                    ToolTip = 'Specifies the user that created the entry.';
                    Visible = false;
                }
                field("Last Update Date"; Rec.lupd_datetime)
                {
                    Caption = 'Last Update Date';
                    Editable = false;
                    ToolTip = 'Specifies the last update date of the entry.';
                    Visible = false;
                }
                field("Last Update Program"; Rec.lupd_prog)
                {
                    Caption = 'Last Update Program';
                    Editable = false;
                    ToolTip = 'Specifies the program that last updated the entry.';
                    Visible = false;
                }
                field("Last Update User"; Rec.lupd_user)
                {
                    Caption = 'Last Update User';
                    Editable = false;
                    ToolTip = 'Specifies the user that last updated the entry.';
                    Visible = false;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        SLHistPJTranEx: Record "SL Hist. PJTranEx";
        SLHistPJProj: Record "SL Hist. PJProj";
        SLHistPJEmploy: Record "SL Hist. PJEmploy";
    begin
        // Lookup PJTranEx fields
        if SLHistPJTranEx.Get(Rec.fiscalno, Rec.system_cd, Rec.batch_id, Rec.detail_num) then begin
            InventoryId := SLHistPJTranEx.invtid;
            EquipmentId := SLHistPJTranEx.equip_id;
            LotSerialNbr := SLHistPJTranEx.lotsernbr;
            SalesOrderNum := SLHistPJTranEx.ordnbr;
            SalesOrderLine := SLHistPJTranEx.orderlineref;
            ShipperId := SLHistPJTranEx.shipperid;
            ShipperLine := SLHistPJTranEx.shipperlineref;
            SiteId := SLHistPJTranEx.siteid;
            WarehouseLocation := SLHistPJTranEx.whseloc;
            KeyOfOriginatingTrans := SLHistPJTranEx.tr_id12;
            TrId13 := SLHistPJTranEx.tr_id13;
            TrId14 := SLHistPJTranEx.tr_id14;
            WOInfo := SLHistPJTranEx.tr_id15;
            PayrollWorkLoc := SLHistPJTranEx.tr_id16;
            TrId17 := SLHistPJTranEx.tr_id17;
            TrId18 := SLHistPJTranEx.tr_id18;
            TrId19 := SLHistPJTranEx.tr_id19;
            OffsetCpnyAcctSub := SLHistPJTranEx.tr_id20;
            TrId21 := SLHistPJTranEx.tr_id21;
            TimecardPeriodEnd := SLHistPJTranEx.tr_id22;
        end else
            ClearTranExFields();

        // Lookup PJProj fields
        if SLHistPJProj.Get(Rec.project) then begin
            ProjectDescription := SLHistPJProj.project_desc;
            ProjectCustomer := SLHistPJProj.customer;
            ProjectManager := SLHistPJProj.manager1;

            // Lookup project manager name
            if (ProjectManager <> '') and SLHistPJEmploy.Get(ProjectManager) then
                ProjectMgrName := FormatEmployeeName(SLHistPJEmploy.emp_name)
            else
                ProjectMgrName := '';
        end else begin
            ProjectDescription := '';
            ProjectCustomer := '';
            ProjectManager := '';
            ProjectMgrName := '';
        end;

        // Lookup resource name
        if (Rec.employee <> '') and SLHistPJEmploy.Get(Rec.employee) then
            ResourceName := FormatEmployeeName(SLHistPJEmploy.emp_name)
        else
            ResourceName := '';
    end;

    local procedure FormatEmployeeName(EmpName: Text[60]): Text[60]
    var
        TildePos: Integer;
        FirstPart: Text;
        LastPart: Text;
    begin
        TildePos := StrPos(EmpName, '~');
        if TildePos > 0 then begin
            FirstPart := CopyStr(EmpName, 1, TildePos - 1);
            LastPart := CopyStr(EmpName, TildePos + 1);
            exit(CopyStr(FirstPart.TrimStart() + ', ' + LastPart.Trim(), 1, 60));
        end;
        exit(EmpName);
    end;

    local procedure ClearTranExFields()
    begin
        InventoryId := '';
        EquipmentId := '';
        LotSerialNbr := '';
        SalesOrderNum := '';
        SalesOrderLine := '';
        ShipperId := '';
        ShipperLine := '';
        SiteId := '';
        WarehouseLocation := '';
        KeyOfOriginatingTrans := '';
        TrId13 := '';
        TrId14 := '';
        WOInfo := '';
        PayrollWorkLoc := '';
        TrId17 := '';
        TrId18 := '';
        TrId19 := '';
        OffsetCpnyAcctSub := '';
        TrId21 := '';
        TimecardPeriodEnd := 0D;
    end;

    trigger OnOpenPage()
    begin
        if FilterProject <> '' then
            Rec.SetRange(Project, FilterProject);
    end;

    procedure SetFilterProject(ProjectID: Text[16])
    begin
        FilterProject := ProjectID;
    end;

    var
        FilterProject: Text[16];
        ProjectDescription: Text[60];
        ProjectCustomer: Text[15];
        ProjectManager: Text[10];
        ProjectMgrName: Text[60];
        ResourceName: Text[60];
        InventoryId: Text[30];
        EquipmentId: Text[10];
        LotSerialNbr: Text[25];
        SalesOrderNum: Text[15];
        SalesOrderLine: Text[5];
        ShipperId: Text[15];
        ShipperLine: Text[5];
        SiteId: Text[10];
        WarehouseLocation: Text[10];
        KeyOfOriginatingTrans: Text[30];
        TrId13: Text[30];
        TrId14: Text[16];
        WOInfo: Text[16];
        PayrollWorkLoc: Text[16];
        TrId17: Text[4];
        TrId18: Text[4];
        TrId19: Text[4];
        OffsetCpnyAcctSub: Text[40];
        TrId21: Text[40];
        TimecardPeriodEnd: Date;
}
