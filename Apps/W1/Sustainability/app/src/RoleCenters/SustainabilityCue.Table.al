namespace Microsoft.Sustainability.RoleCenters;

using Microsoft.Assembly.Document;
using Microsoft.EServices.EDocument;
using Microsoft.Foundation.Task;
using Microsoft.Inventory.Transfer;
using Microsoft.Manufacturing.Document;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Document;
using Microsoft.Sales.Receivables;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Setup;
using System.Automation;

table 6220 "Sustainability Cue"
{
    Caption = 'Sustainability Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
#pragma warning disable AA0232
        field(2; "Emission CO2"; Decimal)
#pragma warning restore AA0232
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CO2';
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission CO2" where("Posting Date" = field("Date Filter"), "Emission Scope" = field("Scope Filter")));
        }
        field(3; "Emission CH4"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CH4';
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission CH4" where("Posting Date" = field("Date Filter"), "Emission Scope" = field("Scope Filter")));
        }
        field(4; "Emission N2O"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission N2O';
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission N2O" where("Posting Date" = field("Date Filter"), "Emission Scope" = field("Scope Filter")));
        }
        field(6; "Ongoing Purchase Orders"; Integer)
        {
            Caption = 'Ongoing Purchase Orders';
            FieldClass = FlowField;
            CalcFormula = count("Purchase Header" where("Document Type" = const(Order), "Sustainability Lines Exist" = const(true)));
            Editable = false;
        }
        field(7; "Ongoing Purchase Invoices"; Integer)
        {
            Caption = 'Ongoing Purchase Invoices';
            FieldClass = FlowField;
            CalcFormula = count("Purchase Header" where("Document Type" = const(Invoice), "Sustainability Lines Exist" = const(true)));
            Editable = false;
        }
        field(8; "Purch. Invoices Due Next Week"; Integer)
        {
            CalcFormula = count("Vendor Ledger Entry" where("Document Type" = filter(Invoice | "Credit Memo"),
                                                             "Due Date" = field("Due Next Week Filter"),
                                                             Open = const(true)));
            Caption = 'Purch. Invoices Due Next Week';
            Editable = false;
            FieldClass = FlowField;
        }
        field(9; "My Incoming Documents"; Integer)
        {
            CalcFormula = count("Incoming Document" where(Processed = const(false)));
            Caption = 'My Incoming Documents';
            FieldClass = FlowField;
        }
        field(15; "Inc. Doc. Awaiting Verfication"; Integer)
        {
            CalcFormula = count("Incoming Document" where("OCR Status" = const("Awaiting Verification")));
            Caption = 'Inc. Doc. Awaiting Verfication';
            FieldClass = FlowField;
        }
        field(20; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
            Caption = 'Date Filter';
        }
        field(21; "Due Next Week Filter"; Date)
        {
            Caption = 'Due Next Week Filter';
            FieldClass = FlowFilter;
        }
        field(22; "Scope Filter"; Enum "Emission Scope")
        {
            Caption = 'Scope Filter';
            FieldClass = FlowFilter;
        }
        field(23; "Water/Waste Int. Type Filter"; Enum "Water/Waste Intensity Type")
        {
            Caption = 'Water/Waste Intensity Type Filter';
            FieldClass = FlowFilter;
        }
        field(24; "Water Type Filter"; Enum "Water Type")
        {
            Caption = 'Water Type Filter';
            FieldClass = FlowFilter;
        }
        field(25; "User ID Filter"; Code[50])
        {
            Caption = 'User ID Filter';
            FieldClass = FlowFilter;
        }
        field(29; "Discharged Into Water"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Discharged Into Water';
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Discharged Into Water" where("Posting Date" = field("Date Filter"), "Water/Waste Intensity Type" = field("Water/Waste Int. Type Filter"), "Water Type" = field("Water Type Filter")));
        }
        field(30; "Water Intensity"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Water Intensity';
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Water Intensity" where("Posting Date" = field("Date Filter"), "Water/Waste Intensity Type" = field("Water/Waste Int. Type Filter"), "Water Type" = field("Water Type Filter")));
        }
        field(31; "Waste Intensity"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Waste Intensity';
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Waste Intensity" where("Posting Date" = field("Date Filter"), "Water/Waste Intensity Type" = field("Water/Waste Int. Type Filter")));
        }
        field(32; "Ongoing Sales Orders"; Integer)
        {
            Caption = 'Ongoing Sales Orders';
            FieldClass = FlowField;
            CalcFormula = count("Sales Header" where("Document Type" = const(Order), "Sustainability Lines Exist" = const(true)));
            Editable = false;
        }
        field(33; "Ongoing Sales Invoices"; Integer)
        {
            Caption = 'Ongoing Sales Invoices';
            FieldClass = FlowField;
            CalcFormula = count("Sales Header" where("Document Type" = const(Invoice), "Sustainability Lines Exist" = const(true)));
            Editable = false;
        }
        field(34; "Sales Invoices Due Next Week"; Integer)
        {
            CalcFormula = count("Cust. Ledger Entry" where("Document Type" = filter(Invoice | "Credit Memo"),
                                                             "Due Date" = field("Due Next Week Filter"),
                                                             Open = const(true)));
            Caption = 'Sales Invoices Due Next Week';
            Editable = false;
            FieldClass = FlowField;
        }
        field(35; "Released Prod. Orders"; Integer)
        {
            Caption = 'Released Prod. Orders';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("Production Order" where(Status = const(Released), "Creation Date" = field("Date Filter"), "Sustainability Lines Exist" = const(true)));
        }
        field(36; "Assembly Orders"; Integer)
        {
            Caption = 'Assembly Orders';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("Assembly Header" where("Document Type" = const(order), "Posting Date" = field("Date Filter"), "Sust. Account No." = filter('<>''''')));
        }
        field(37; "Ongoing Transfer Orders"; Integer)
        {
            Caption = 'Ongoing Transfer Orders';
            FieldClass = FlowField;
            CalcFormula = count("Transfer Header" where("Sustainability Lines Exist" = const(true)));
            Editable = false;
        }
        field(38; "Requests to Approve"; Integer)
        {
            CalcFormula = count("Approval Entry" where("Approver ID" = field("User ID Filter"),
                                                        Status = filter(Open)));
            Caption = 'Requests to Approve';
            FieldClass = FlowField;
        }
        field(39; "Requests Sent for Approval"; Integer)
        {
            CalcFormula = count("Approval Entry" where("Sender ID" = field("User ID Filter"),
                                                        Status = filter(Open)));
            Caption = 'Requests Sent for Approval';
            FieldClass = FlowField;
        }
        field(40; "CO2e Emission"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CO2';
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."CO2e Emission" where("Posting Date" = field("Date Filter")));
        }
        field(41; "DateTime Filter"; DateTime)
        {
            FieldClass = FlowFilter;
            Caption = 'DateTime Filter';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
        NoneStyleLbl: Label 'None';
        FavorableStyleLbl: Label 'Favorable';
        AmbiguousStyleLbl: Label 'Ambiguous';
        UnfavorableStyleLbl: Label 'Unfavorable';

    internal procedure GetMyPendingUserTasksThisMonthCount(): Integer
    var
        UserTask: Record "User Task";
        UserTaskManagement: Codeunit "User Task Management";
    begin
        UserTask.Reset();
        UserTaskManagement.SetFiltersToShowMyUserTasks(UserTask, 0);
        UserTask.SetFilter("Due DateTime", Rec.GetFilter("DateTime Filter"));
        exit(UserTask.Count);
    end;

    internal procedure ShowMyPendingUserTasksThisMonthCount(): Integer
    var
        UserTask: Record "User Task";
        UserTaskManagement: Codeunit "User Task Management";
        UserTaskList: Page "User Task List";
    begin
        UserTask.Reset();
        UserTaskManagement.SetFiltersToShowMyUserTasks(UserTask, 0);
        UserTask.SetFilter("Due DateTime", Rec.GetFilter("DateTime Filter"));

        UserTaskList.SetTableView(UserTask);
        UserTaskList.Run();
    end;

    internal procedure GetMyOverDueUserTasksCount(): Integer
    var
        UserTask: Record "User Task";
        UserTaskManagement: Codeunit "User Task Management";
    begin
        UserTask.Reset();
        UserTaskManagement.SetFiltersToShowMyUserTasks(UserTask, 0);
        UserTask.SetFilter("Due DateTime", '<>%1 & <%2', 0DT, CreateDateTime(WorkDate(), 0T));
        exit(UserTask.Count);
    end;

    internal procedure ShowMyPendingUserTasksOverDueCount(): Integer
    var
        UserTask: Record "User Task";
        UserTaskManagement: Codeunit "User Task Management";
        UserTaskList: Page "User Task List";
    begin
        UserTask.Reset();
        UserTaskManagement.SetFiltersToShowMyUserTasks(UserTask, 0);
        UserTask.SetFilter("Due DateTime", '<>%1 & <%2', 0DT, CreateDateTime(WorkDate(), 0T));
        UserTaskList.SetTableView(UserTask);
        UserTaskList.Run();
    end;

    internal procedure GetEmissionCO2Style(): Text
    begin
        if Rec."Emission CO2" <= 1000 then
            exit(FavorableStyleLbl);

        if Rec."Emission CO2" <= 2500 then
            exit(AmbiguousStyleLbl);

        exit(UnfavorableStyleLbl);
    end;

    internal procedure GetPurchInvDueNextWeekStyle(): Text
    begin
        if Rec."Purch. Invoices Due Next Week" <= 5 then
            exit(NoneStyleLbl);

        if Rec."Purch. Invoices Due Next Week" <= 10 then
            exit(AmbiguousStyleLbl);

        exit(UnfavorableStyleLbl);
    end;

    internal procedure GetSalesInvDueNextWeekStyle(): Text
    begin
        if Rec."Sales Invoices Due Next Week" <= 10 then
            exit(NoneStyleLbl);

        if Rec."Sales Invoices Due Next Week" <= 30 then
            exit(AmbiguousStyleLbl);

        exit(UnfavorableStyleLbl);
    end;

    internal procedure GetRequestsSentForApprovalStyle(): Text
    begin
        if Rec."Requests Sent for Approval" <= 5 then
            exit(FavorableStyleLbl);

        if Rec."Requests Sent for Approval" <= 20 then
            exit(AmbiguousStyleLbl);

        exit(UnfavorableStyleLbl);
    end;

    internal procedure GetRequestsToApprovalStyle(): Text
    begin
        if Rec."Requests to Approve" <= 2 then
            exit(FavorableStyleLbl);

        if Rec."Requests to Approve" <= 5 then
            exit(AmbiguousStyleLbl);

        exit(UnfavorableStyleLbl);
    end;

    internal procedure GetTasksThisMonthStyle(): Text
    begin
        if Rec.GetMyPendingUserTasksThisMonthCount() <= 5 then
            exit(FavorableStyleLbl);

        if Rec.GetMyPendingUserTasksThisMonthCount() <= 10 then
            exit(AmbiguousStyleLbl);

        exit(UnfavorableStyleLbl);
    end;

    internal procedure GetOverdueTasksStyle(): Text
    begin
        if Rec.GetMyOverDueUserTasksCount() <= 1 then
            exit(FavorableStyleLbl);

        if Rec.GetMyOverDueUserTasksCount() <= 5 then
            exit(AmbiguousStyleLbl);

        exit(UnfavorableStyleLbl);
    end;
}