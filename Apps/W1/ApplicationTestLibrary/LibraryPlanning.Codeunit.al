/// <summary>
/// Provides utility functions for creating and managing planning-related entities in test scenarios, including requisition worksheets and planning components.
/// </summary>
codeunit 132203 "Library - Planning"
{

    trigger OnRun()
    begin
    end;

    var
        InventorySetup: Record "Inventory Setup";
        LibraryUtility: Codeunit "Library - Utility";

#if not CLEAN27
#pragma warning disable AL0801
    [Obsolete('Moved to codeunit LibraryManufacturing', '27.0')]
    procedure CreateProdOrderUsingPlanning(var ProductionOrder: Record "Production Order"; Status: Enum "Production Order Status"; DocumentNo: Code[20]; SourceNo: Code[20])
    var
        LibraryManufacturing: Codeunit "Library - Manufacturing";
    begin
        LibraryManufacturing.CreateProdOrderUsingPlanning(ProductionOrder, Status, DocumentNo, SourceNo);
    end;
#pragma warning restore AL0801
#endif

    [Normal]
    procedure CreateRequisitionWkshName(var RequisitionWkshName: Record "Requisition Wksh. Name"; WorksheetTemplateName: Code[10])
    begin
        // Create Requisition Wksh. Name with a random Name of String length less than 10.
        RequisitionWkshName.Init();
        RequisitionWkshName.Validate("Worksheet Template Name", WorksheetTemplateName);
        RequisitionWkshName.Validate(
          Name,
          CopyStr(
            LibraryUtility.GenerateRandomCode(RequisitionWkshName.FieldNo(Name), DATABASE::"Requisition Wksh. Name"),
            1, LibraryUtility.GetFieldLength(DATABASE::"Requisition Wksh. Name", RequisitionWkshName.FieldNo(Name))));
        RequisitionWkshName.Insert(true);
    end;

    procedure CalculateLowLevelCode()
    var
        LowLevelCodeCalculator: Codeunit "Low-Level Code Calculator";
    begin
        Clear(LowLevelCodeCalculator);
        LowLevelCodeCalculator.Run();
    end;

    procedure CalculateOrderPlanProduction(var RequisitionLine: Record "Requisition Line")
    var
        OrderPlanningMgt: Codeunit "Order Planning Mgt.";
    begin
        OrderPlanningMgt.SetDemandType("Demand Order Source Type"::"Production Demand");
        OrderPlanningMgt.GetOrdersToPlan(RequisitionLine);
    end;

    procedure CalculateOrderPlanAssembly(var RequisitionLine: Record "Requisition Line")
    var
        OrderPlanningMgt: Codeunit "Order Planning Mgt.";
    begin
        OrderPlanningMgt.SetDemandType("Demand Order Source Type"::"Assembly Demand");
        OrderPlanningMgt.GetOrdersToPlan(RequisitionLine);
    end;

    procedure CalculateOrderPlanSales(var RequisitionLine: Record "Requisition Line")
    var
        OrderPlanningMgt: Codeunit "Order Planning Mgt.";
    begin
        OrderPlanningMgt.SetDemandType("Demand Order Source Type"::"Sales Demand");
        OrderPlanningMgt.GetOrdersToPlan(RequisitionLine);
    end;

    procedure CalculateOrderPlanService(var RequisitionLine: Record "Requisition Line")
    var
        OrderPlanningMgt: Codeunit "Order Planning Mgt.";
    begin
        OrderPlanningMgt.SetDemandType("Demand Order Source Type"::"Service Demand");
        OrderPlanningMgt.GetOrdersToPlan(RequisitionLine);
    end;

    procedure CalculateOrderPlanJob(var RequisitionLine: Record "Requisition Line")
    var
        OrderPlanningMgt: Codeunit "Order Planning Mgt.";
    begin
        OrderPlanningMgt.SetDemandType("Demand Order Source Type"::"Job Demand");
        OrderPlanningMgt.GetOrdersToPlan(RequisitionLine);
    end;

    procedure CalculatePlanForReqWksh(var Item: Record Item; TemplateName: Code[10]; WorksheetName: Code[10]; StartDate: Date; EndDate: Date)
    var
        TmpItem: Record Item;
        CalculatePlanReqWksh: Report "Calculate Plan - Req. Wksh.";
    begin
        CalculatePlanReqWksh.SetTemplAndWorksheet(TemplateName, WorksheetName);
        CalculatePlanReqWksh.InitializeRequest(StartDate, EndDate);
        if Item.HasFilter then
            TmpItem.CopyFilters(Item)
        else begin
            Item.Get(Item."No.");
            TmpItem.SetRange("No.", Item."No.");
        end;
        CalculatePlanReqWksh.SetTableView(TmpItem);
        CalculatePlanReqWksh.UseRequestPage(false);
        CalculatePlanReqWksh.RunModal();
    end;

    procedure CalcRequisitionPlanForReqWksh(var Item: Record Item; StartDate: Date; EndDate: Date)
    var
        RequisitionWkshName: Record "Requisition Wksh. Name";
    begin
        SelectRequisitionWkshName(RequisitionWkshName, RequisitionWkshName."Template Type"::"Req.");
        CalculatePlanForReqWksh(Item, RequisitionWkshName."Worksheet Template Name", RequisitionWkshName.Name, StartDate, EndDate);
    end;

    procedure CalcRequisitionPlanForReqWkshAndGetLines(var RequisitionLine: Record "Requisition Line"; var Item: Record Item; StartDate: Date; EndDate: Date)
    var
        RequisitionWkshName: Record "Requisition Wksh. Name";
    begin
        SelectRequisitionWkshName(RequisitionWkshName, RequisitionWkshName."Template Type"::"Req.");
        CalculatePlanForReqWksh(Item, RequisitionWkshName."Worksheet Template Name", RequisitionWkshName.Name, StartDate, EndDate);

        FindRequisitionLine(RequisitionLine, RequisitionWkshName, Item."No.");
    end;

    local procedure CalculatePlanOnPlanningWorksheet(var ItemRec: Record Item; OrderDate: Date; ToDate: Date; RespectPlanningParameters: Boolean; Regenerative: Boolean)
    var
        TmpItemRec: Record Item;
        RequisitionWkshName: Record "Requisition Wksh. Name";
        CalculatePlanPlanWksh: Report "Calculate Plan - Plan. Wksh.";
    begin
        SelectRequisitionWkshName(RequisitionWkshName, RequisitionWkshName."Template Type"::Planning);  // Find Requisition Worksheet Name to Calculate Plan.
        Commit();
        CalculatePlanPlanWksh.InitializeRequest(OrderDate, ToDate, RespectPlanningParameters);
        CalculatePlanPlanWksh.SetTemplAndWorksheet(RequisitionWkshName."Worksheet Template Name", RequisitionWkshName.Name, Regenerative);
        if ItemRec.HasFilter then
            TmpItemRec.CopyFilters(ItemRec)
        else begin
            ItemRec.Get(ItemRec."No.");
            TmpItemRec.SetRange("No.", ItemRec."No.");
        end;
        CalculatePlanPlanWksh.SetTableView(TmpItemRec);
        CalculatePlanPlanWksh.UseRequestPage(false);
        CalculatePlanPlanWksh.RunModal();
    end;

    procedure CalcRegenPlanForPlanWksh(var ItemRec: Record Item; OrderDate: Date; ToDate: Date)
    begin
        CalcRegenPlanForPlanWkshPlanningParams(ItemRec, OrderDate, ToDate, false);
    end;

    procedure CalcRegenPlanForPlanWkshPlanningParams(var ItemRec: Record Item; OrderDate: Date; ToDate: Date; RespectPlanningParameters: Boolean)
    begin
        CalculatePlanOnPlanningWorksheet(ItemRec, OrderDate, ToDate, RespectPlanningParameters, true);  // Passing True for Regenerative Boolean.
    end;

    procedure CalcNetChangePlanForPlanWksh(var ItemRec: Record Item; OrderDate: Date; ToDate: Date; RespectPlanningParameters: Boolean)
    begin
        CalculatePlanOnPlanningWorksheet(ItemRec, OrderDate, ToDate, RespectPlanningParameters, false);  // Passing False for Regenerative Boolean.
    end;

    procedure CarryOutActionMsgPlanWksh(var ReqLineRec: Record "Requisition Line")
    var
        TmpReqLineRec: Record "Requisition Line";
        CarryOutActionMsgPlan: Report "Carry Out Action Msg. - Plan.";
    begin
        Commit();
        CarryOutActionMsgPlan.InitializeRequest(2, 1, 1, 1);
        if ReqLineRec.HasFilter then
            TmpReqLineRec.CopyFilters(ReqLineRec)
        else begin
            ReqLineRec.Get(ReqLineRec."Worksheet Template Name",
              ReqLineRec."Journal Batch Name", ReqLineRec."Line No.");
            TmpReqLineRec.SetRange("Worksheet Template Name", ReqLineRec."Worksheet Template Name");
            TmpReqLineRec.SetRange("Journal Batch Name", ReqLineRec."Journal Batch Name");
            TmpReqLineRec.SetRange("Line No.", ReqLineRec."Line No.");
        end;
        CarryOutActionMsgPlan.SetReqWkshLine(ReqLineRec);
        CarryOutActionMsgPlan.SetTableView(TmpReqLineRec);
        CarryOutActionMsgPlan.UseRequestPage(false);
        CarryOutActionMsgPlan.RunModal();
    end;

    procedure CarryOutPlanWksh(var RequisitionLine: Record "Requisition Line"; NewProdOrderChoice: Option; NewPurchOrderChoice: Option; NewTransOrderChoice: Option; NewAsmOrderChoice: Option; NewReqWkshTemp: Code[10]; NewReqWksh: Code[10]; NewTransWkshTemp: Code[10]; NewTransWkshName: Code[10])
    var
        CarryOutActionMsgPlan: Report "Carry Out Action Msg. - Plan.";
    begin
        CarryOutActionMsgPlan.SetReqWkshLine(RequisitionLine);
        CarryOutActionMsgPlan.InitializeRequest2(
          NewProdOrderChoice, NewPurchOrderChoice, NewTransOrderChoice, NewAsmOrderChoice,
          NewReqWkshTemp, NewReqWksh, NewTransWkshTemp, NewTransWkshName);
        CarryOutActionMsgPlan.SetTableView(RequisitionLine);
        CarryOutActionMsgPlan.UseRequestPage(false);
        CarryOutActionMsgPlan.Run();
    end;

    procedure CarryOutReqWksh(var RequisitionLine: Record "Requisition Line"; ExpirationDate: Date; OrderDate: Date; PostingDate: Date; ExpectedReceiptDate: Date; YourRef: Text[50])
    var
        CarryOutActionMsgReq: Report "Carry Out Action Msg. - Req.";
    begin
        CarryOutActionMsgReq.SetReqWkshLine(RequisitionLine);
        CarryOutActionMsgReq.InitializeRequest(ExpirationDate, OrderDate, PostingDate, ExpectedReceiptDate, YourRef);
        CarryOutActionMsgReq.UseRequestPage(false);
        CarryOutActionMsgReq.Run();
        CarryOutActionMsgReq.GetReqWkshLine(RequisitionLine);
    end;

    procedure CarryOutAMSubcontractWksh(var RequisitionLine: Record "Requisition Line")
    var
        CarryOutActionMsgReq: Report "Carry Out Action Msg. - Req.";
    begin
        CarryOutActionMsgReq.SetReqWkshLine(RequisitionLine);
        CarryOutActionMsgReq.UseRequestPage(false);
        CarryOutActionMsgReq.RunModal();
    end;

    procedure CreateManufUserTemplate(var ManufacturingUserTemplate: Record "Manufacturing User Template"; UserID: Code[50]; MakeOrders: Option; CreatePurchaseOrder: Enum "Planning Create Purchase Order"; CreateProductionOrder: Enum "Planning Create Prod. Order"; CreateTransferOrder: Enum "Planning Create Transfer Order")
    begin
        ManufacturingUserTemplate.Init();
        ManufacturingUserTemplate."User ID" := UserID;
        ManufacturingUserTemplate.Insert(true);
        ManufacturingUserTemplate.Validate("Make Orders", MakeOrders);
        ManufacturingUserTemplate.Validate("Create Purchase Order", CreatePurchaseOrder);
        ManufacturingUserTemplate.Validate("Create Production Order", CreateProductionOrder);
        ManufacturingUserTemplate.Validate("Create Transfer Order", CreateTransferOrder);
        ManufacturingUserTemplate.Modify(true);
    end;

    procedure CreateRequisitionLine(var RequisitionLine: Record "Requisition Line"; WorksheetTemplateName: Code[10]; JournalBatchName: Code[10])
    var
        RecRef: RecordRef;
    begin
        RequisitionLine.Init();
        RequisitionLine.Validate("Worksheet Template Name", WorksheetTemplateName);
        RequisitionLine.Validate("Journal Batch Name", JournalBatchName);
        RecRef.GetTable(RequisitionLine);
        RequisitionLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, RequisitionLine.FieldNo("Line No.")));
        RequisitionLine.Insert(true);
    end;

    procedure CreatePlanningComponent(var PlanningComponent: Record "Planning Component"; var RequisitionLine: Record "Requisition Line")
    var
        RecRef: RecordRef;
    begin
        PlanningComponent.Init();
        PlanningComponent.Validate("Worksheet Template Name", RequisitionLine."Worksheet Template Name");
        PlanningComponent.Validate("Worksheet Batch Name", RequisitionLine."Journal Batch Name");
        PlanningComponent.Validate("Worksheet Line No.", RequisitionLine."Line No.");
        RecRef.GetTable(PlanningComponent);
        PlanningComponent.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, PlanningComponent.FieldNo("Line No.")));
        PlanningComponent.Insert(true);
    end;

#if not CLEAN27
#pragma warning disable AL0801
    [Obsolete('Moved to codeunit LibraryManufacturing', '27.0')]
    procedure CreatePlanningRoutingLine(var PlanningRoutingLine: Record "Planning Routing Line"; var RequisitionLine: Record "Requisition Line"; OperationNo: Code[10])
    var
        LibraryManfacturing: Codeunit "Library - Manufacturing";
    begin
        LibraryManfacturing.CreatePlanningRoutingLine(PlanningRoutingLine, RequisitionLine, OperationNo);
    end;
#pragma warning restore AL0801
#endif

    local procedure FindRequisitionLine(var RequisitionLine: Record "Requisition Line"; RequisitionWkshName: Record "Requisition Wksh. Name"; ItemNo: Code[20])
    begin
        RequisitionLine.SetRange("Worksheet Template Name", RequisitionWkshName."Worksheet Template Name");
        RequisitionLine.SetRange("Journal Batch Name", RequisitionWkshName.Name);
        RequisitionLine.SetRange("No.", ItemNo);
        RequisitionLine.FindFirst();
    end;

    procedure GetActionMessages(var Item: Record Item)
    var
        TmpItem: Record Item;
        RequisitionWkshName: Record "Requisition Wksh. Name";
        GetActionMessagesReport: Report "Get Action Messages";
    begin
        SelectRequisitionWkshName(RequisitionWkshName, RequisitionWkshName."Template Type"::Planning);
        GetActionMessagesReport.SetTemplAndWorksheet(RequisitionWkshName."Worksheet Template Name", RequisitionWkshName.Name);
        GetActionMessagesReport.UseRequestPage(false);
        if Item.HasFilter then
            TmpItem.CopyFilters(Item)
        else begin
            Item.Get(Item."No.");
            TmpItem.SetRange("No.", Item."No.");
        end;
        GetActionMessagesReport.SetTableView(TmpItem);
        GetActionMessagesReport.Run();
    end;

    procedure GetSalesOrders(SalesLine: Record "Sales Line"; RequisitionLine: Record "Requisition Line"; RetrieveDimensionsFrom: Option)
    var
        GetSalesOrdersReport: Report "Get Sales Orders";
    begin
        SalesLine.SetRange("Document Type", SalesLine."Document Type");
        SalesLine.SetRange("Document No.", SalesLine."Document No.");
        Clear(GetSalesOrdersReport);
        GetSalesOrdersReport.SetTableView(SalesLine);
        GetSalesOrdersReport.InitializeRequest(RetrieveDimensionsFrom);
        GetSalesOrdersReport.SetReqWkshLine(RequisitionLine, 0);
        GetSalesOrdersReport.UseRequestPage(false);
        GetSalesOrdersReport.RunModal();
    end;

    procedure GetSpecialOrder(var RequisitionLine: Record "Requisition Line"; No: Code[20])
    var
        SalesLine: Record "Sales Line";
        GetSalesOrdersReport: Report "Get Sales Orders";
        NewRetrieveDimensionsFrom: Option Item,SalesLine;
    begin
        SalesLine.SetRange("No.", No);
        GetSalesOrdersReport.SetReqWkshLine(RequisitionLine, 1);  // Value required.
        GetSalesOrdersReport.SetTableView(SalesLine);
        GetSalesOrdersReport.InitializeRequest(NewRetrieveDimensionsFrom::Item);
        GetSalesOrdersReport.UseRequestPage(false);
        GetSalesOrdersReport.Run();
    end;

    procedure MakeSupplyOrders(var ManufacturingUserTemplate: Record "Manufacturing User Template"; var RequisitionLine: Record "Requisition Line")
    var
        MakeSupplyOrdersYesNo: Codeunit "Make Supply Orders (Yes/No)";
    begin
        MakeSupplyOrdersYesNo.SetManufUserTemplate(ManufacturingUserTemplate);
        MakeSupplyOrdersYesNo.Run(RequisitionLine);
    end;

    procedure RefreshPlanningLine(var RequisitionLine: Record "Requisition Line"; SchDirection: Option; CalcRouting: Boolean; CalcCompNeed: Boolean)
    var
        TmpRequisitionLine: Record "Requisition Line";
        RefreshPlanningDemand: Report "Refresh Planning Demand";
    begin
        RefreshPlanningDemand.InitializeRequest(SchDirection, CalcRouting, CalcCompNeed);
        if RequisitionLine.HasFilter then
            TmpRequisitionLine.CopyFilters(RequisitionLine)
        else begin
            RequisitionLine.Get(RequisitionLine."Worksheet Template Name",
              RequisitionLine."Journal Batch Name", RequisitionLine."Line No.");
            TmpRequisitionLine.SetRange("Worksheet Template Name", RequisitionLine."Worksheet Template Name");
            TmpRequisitionLine.SetRange("Journal Batch Name", RequisitionLine."Journal Batch Name");
            TmpRequisitionLine.SetRange("Line No.", RequisitionLine."Line No.");
        end;
        RefreshPlanningDemand.SetTableView(TmpRequisitionLine);
        RefreshPlanningDemand.UseRequestPage(false);
        RefreshPlanningDemand.RunModal();
    end;

    procedure SelectRequisitionTemplateName(): Code[10]
    var
        ReqWkshTemplate: Record "Req. Wksh. Template";
    begin
        ReqWkshTemplate.SetRange(Type, ReqWkshTemplate.Type::Planning);
        ReqWkshTemplate.SetRange(Recurring, false);
        if not ReqWkshTemplate.FindFirst() then begin
            ReqWkshTemplate.Init();
            ReqWkshTemplate.Validate(
              Name, LibraryUtility.GenerateRandomCode(ReqWkshTemplate.FieldNo(Name), DATABASE::"Req. Wksh. Template"));
            ReqWkshTemplate.Insert(true);
            ReqWkshTemplate.Validate(Type, ReqWkshTemplate.Type::Planning);
            ReqWkshTemplate.Modify(true);
        end;
        exit(ReqWkshTemplate.Name);
    end;

    procedure SelectRequisitionWkshName(var RequisitionWkshName: Record "Requisition Wksh. Name"; TemplateType: Enum "Req. Worksheet Template Type")
    begin
        RequisitionWkshName.SetRange("Template Type", TemplateType);
        RequisitionWkshName.SetRange(Recurring, false);
        if not RequisitionWkshName.FindFirst() then
            CreateRequisitionWkshName(RequisitionWkshName, SelectRequisitionTemplateName());
    end;

    procedure SetDemandForecast(CurrentDemandForecast: Code[10])
    begin
        InventorySetup.Get();
        InventorySetup.Validate("Current Demand Forecast", CurrentDemandForecast);
        InventorySetup.Modify();
    end;

    procedure SetUseForecastOnVariants(UseForecastOnVariants: Boolean)
    begin
        InventorySetup.Get();
        InventorySetup.Validate("Use Forecast on Variants", UseForecastOnVariants);
        InventorySetup.Modify();
    end;

    procedure SetUseForecastOnLocations(UseForecastOnLocations: Boolean)
    begin
        InventorySetup.Get();
        InventorySetup.Validate("Use Forecast on Locations", UseForecastOnLocations);
        InventorySetup.Modify();
    end;

    procedure SetDefaultDampenerPercent(DampenerPercent: Decimal)
    begin
        InventorySetup.Get();
        InventorySetup.Validate("Default Dampener %", DampenerPercent);
        InventorySetup.Modify();
    end;

    procedure SetDefaultDampenerPeriod(DampenerPeriod: Text)
    begin
        InventorySetup.Get();
        Evaluate(InventorySetup."Default Dampener Period", DampenerPeriod);
        InventorySetup.Modify();
    end;

    procedure SetDefaultSafetyLeadTime(SafetyLeadTime: DateFormula)
    begin
        InventorySetup.Get();
        InventorySetup.Validate("Default Safety Lead Time", SafetyLeadTime);
        InventorySetup.Modify();
    end;

    procedure SetDefaultSafetyLeadTime(SafetyLeadTime: Text)
    begin
        InventorySetup.Get();
        Evaluate(InventorySetup."Default Safety Lead Time", SafetyLeadTime);
        InventorySetup.Modify();
    end;

    procedure SetSafetyWorkDate(): Date
    begin
        InventorySetup.Get();
        exit(CalcDate(InventorySetup."Default Safety Lead Time", WorkDate()));
    end;

    procedure SetBlankOverflowLevel(BlankOverflowLevel: Option)
    begin
        InventorySetup.Get();
        InventorySetup.Validate("Blank Overflow Level", BlankOverflowLevel);
        InventorySetup.Modify();
    end;

    procedure SetCombinedMPSMRPCalculation(CombinedMPSMRPCalculation: Boolean)
    begin
        InventorySetup.Get();
        InventorySetup.Validate("Combined MPS/MRP Calculation", CombinedMPSMRPCalculation);
        InventorySetup.Modify();
    end;

#if not CLEAN27
#pragma warning disable AL0801
    [Obsolete('Moved to codeunit LibraryManufacturing', '27.0')]
    procedure SetComponentsAtLocation(LocationCode: Code[10])
    var
        LibraryManufacturing: Codeunit "Library - Manufacturing";
    begin
        LibraryManufacturing.SetComponentsAtLocation(LocationCode);
    end;
#pragma warning restore AL0801
#endif
}

