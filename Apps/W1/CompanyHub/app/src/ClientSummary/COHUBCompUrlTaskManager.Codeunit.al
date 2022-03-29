codeunit 1155 "COHUB Comp. Url Task Manager"
{
    Access = Internal;

    trigger OnRun()
    var
        CompanyInformation: Record "Company Information";
    begin
        if CompanyInformation.FindFirst() then
            Page.Run(Page::"Company Information", CompanyInformation);
    end;

    var

        OverduePurchInvoiceAmountPropNameTxt: Label 'OverduePurchInvoiceAmount', Locked = true;
        OverdueSalesInvoiceAmountPropNameTxt: Label 'OverdueSalesInvoiceAmount', Locked = true;
        OverduePurchInvoiceAmountDecimalPropNameTxt: Label 'OverduePurchInvoiceAmountDecimal', Locked = true;
        OverdueSalesInvoiceAmountDecimalPropNameTxt: Label 'OverdueSalesInvoiceAmountDecimal', Locked = true;
        CurrencySymbolPropNameTxt: Label 'CurrencySymbol', Locked = true;
        NonAppliedPaymentsAmountPropNameTxt: Label 'NonAppliedPaymentsAmount', Locked = true;
        PurchInvoicesDueNextWeekAmountPropNameTxt: Label 'PurchInvoicesDueNextWeekAmount', Locked = true;
        SalesInvoicesDueNextWeekAmountPropNameTxt: Label 'SalesInvoicesDueNextWeekAmount', Locked = true;
        OngoingPurchaseInvoicesAmountPropNameTxt: Label 'OngoingPurchaseInvoicesAmount', Locked = true;
        OngoingSalesInvoicesAmountPropNameTxt: Label 'OngoingSalesInvoicesAmount', Locked = true;
        SalesThisMonthAmountPropNameTxt: Label 'SalesThisMonthAmount', Locked = true;
        Top10TenantSalesYTDAmountPropNameTxt: Label 'Top10TenantSalesYTDAmount', Locked = true;
        AverageCollectionDaysAmountPropNameTxt: Label 'AverageCollectionDaysAmount', Locked = true;
        OngoingSalesQuotesAmountPropNameTxt: Label 'OngoingSalesQuotesAmount', Locked = true;
        OngoingSalesOrdersAmountPropNameTxt: Label 'OngoingSalesOrdersAmount', Locked = true;
        PurchaseOrdersAmountPropNameTxt: Label 'PurchaseOrdersAmount', Locked = true;
        SalesInvPendDocExchangeAmountPropNameTxt: Label 'SalesInvPendDocExchangeAmount', Locked = true;
        SalesCrMPendDocExchangeAmountPropNameTxt: Label 'SalesCrMPendDocExchangeAmount', Locked = true;
        MyIncomingDocumentsAmountPropNameTxt: Label 'MyIncomingDocumentsAmount', Locked = true;
        IncDocAwaitingVerifAmountPropNameTxt: Label 'IncDocAwaitingVerifAmount', Locked = true;
        ArrayPropertyNameTxt: Label 'value', Locked = true;
        OverduePurchaseDocumentsAmountPropNameTxt: Label 'OverduePurchaseDocumentsAmount', Locked = true;
        PurchaseDiscountsNextWeekAmountPropNameTxt: Label 'PurchaseDiscountsNextWeekAmount', Locked = true;
        OverdueSalesDocumentsAmountPropNameTxt: Label 'OverdueSalesDocumentsAmount', Locked = true;
        PurchaseDocumentsDueTodayAmountPropNameTxt: Label 'PurchaseDocumentsDueTodayAmount', Locked = true;
        VendorsPaymentsOnHoldAmountPropNameTxt: Label 'VendorsPaymentsOnHoldAmount', Locked = true;
        POsPendingApprovalAmountPropNameTxt: Label 'POsPendingApprovalAmount', Locked = true;
        SOsPendingApprovalAmountPropNameTxt: Label 'SOsPendingApprovalAmount', Locked = true;
        ApprovedSalesOrdersAmountPropNameTxt: Label 'ApprovedSalesOrdersAmount', Locked = true;
        ApprovedPurchaseOrdersAmountPropNameTxt: Label 'ApprovedPurchaseOrdersAmount', Locked = true;
        PurchaseReturnOrdersAmountPropNameTxt: Label 'PurchaseReturnOrdersAmount', Locked = true;
        SalesReturnOrdersAllAmountPropNameTxt: Label 'SalesReturnOrdersAllAmount', Locked = true;
        TenantsBlockedAmountPropNameTxt: Label 'TenantsBlockedAmount', Locked = true;
        NewIncomingDocumentsAmountPropNameTxt: Label 'NewIncomingDocumentsAmount', Locked = true;
        ApprovedIncomingDocumentsAmountPropNameTxt: Label 'ApprovedIncomingDocumentsAmount', Locked = true;
        OCRPendingAmountPropNameTxt: Label 'OCRPendingAmount', Locked = true;
        OCRCompletedAmountPropNameTxt: Label 'OCRCompletedAmount', Locked = true;
        RequestsToApproveAmountPropNameTxt: Label 'RequeststoApproveAmount', Locked = true;
        RequestsSentForApprovalAmountPropNameTxt: Label 'RequestsSentForApprovalAmount', Locked = true;
        CashAccountsBalanceAmountPropNameTxt: Label 'CashAccountsBalanceAmount', Locked = true;
        CashAccountsBalanceAmountDecimalPropNameTxt: Label 'CashAccountsBalanceAmountDecimal', Locked = true;
        LastDepreciatedPostedDateAmountPropNameTxt: Label 'LastDepreciatedPostedDateAmount', Locked = true;
        LastLoginDateAmountPropNameTxt: Label 'LastLoginDateAmount', Locked = true;
        ContactNameAmountTxt: Label 'ContactNameAmount', Locked = true;
        OverduePurchInvoiceStylePropNameTxt: Label 'OverduePurchInvoiceStyle', Locked = true;
        OverdueSalesInvoiceStylePropNameTxt: Label 'OverdueSalesInvoiceStyle', Locked = true;
        NonAppliedPaymentsStylePropNameTxt: Label 'NonAppliedPaymentsStyle', Locked = true;
        PurchInvoicesDueNextWeekStylePropNameTxt: Label 'PurchInvoicesDueNextWeekStyle', Locked = true;
        SalesInvoicesDueNextWeekStylePropNameTxt: Label 'SalesInvoicesDueNextWeekStyle', Locked = true;
        OngoingPurchaseInvoicesStylePropNameTxt: Label 'OngoingPurchaseInvoicesStyle', Locked = true;
        OngoingSalesInvoicesStylePropNameTxt: Label 'OngoingSalesInvoicesStyle', Locked = true;
        SalesThisMonthStylePropNameTxt: Label 'SalesThisMonthStyle', Locked = true;
        Top10TenantSalesYTDStylePropNameTxt: Label 'Top10TenantSalesYTDStyle', Locked = true;
        AverageCollectionDaysStylePropNameTxt: Label 'AverageCollectionDaysStyle', Locked = true;
        OngoingSalesQuotesStylePropNameTxt: Label 'OngoingSalesQuotesStyle', Locked = true;
        OngoingSalesOrdersStylePropNameTxt: Label 'OngoingSalesOrdersStyle', Locked = true;
        PurchaseOrdersStylePropNameTxt: Label 'PurchaseOrdersStyle', Locked = true;
        SalesInvPendDocExchangeStylePropNameTxt: Label 'SalesInvPendDocExchangeStyle', Locked = true;
        SalesCrMPendDocExchangeStylePropNameTxt: Label 'SalesCrMPendDocExchangeStyle', Locked = true;
        MyIncomingDocumentsStylePropNameTxt: Label 'MyIncomingDocumentsStyle', Locked = true;
        IncDocAwaitingVerifStylePropNameTxt: Label 'IncDocAwaitingVerifStyle', Locked = true;
        OverduePurchaseDocumentsStylePropNameTxt: Label 'OverduePurchaseDocumentsStyle', Locked = true;
        PurchaseDiscountsNextWeekStylePropNameTxt: Label 'PurchaseDiscountsNextWeekStyle', Locked = true;
        OverdueSalesDocumentsStylePropNameTxt: Label 'OverdueSalesDocumentsStyle', Locked = true;
        PurchaseDocumentsDueTodayStylePropNameTxt: Label 'PurchaseDocumentsDueTodayStyle', Locked = true;
        VendorsPaymentsOnHoldStylePropNameTxt: Label 'VendorsPaymentsOnHoldStyle', Locked = true;
        POsPendingApprovalStylePropNameTxt: Label 'POsPendingApprovalStyle', Locked = true;
        SOsPendingApprovalStylePropNameTxt: Label 'SOsPendingApprovalStyle', Locked = true;
        ApprovedSalesOrdersStylePropNameTxt: Label 'ApprovedSalesOrdersStyle', Locked = true;
        ApprovedPurchaseOrdersStylePropNameTxt: Label 'ApprovedPurchaseOrdersStyle', Locked = true;
        PurchaseReturnOrdersStylePropNameTxt: Label 'PurchaseReturnOrdersStyle', Locked = true;
        SalesReturnOrdersAllStylePropNameTxt: Label 'SalesReturnOrdersAllStyle', Locked = true;
        TenantsBlockedStylePropNameTxt: Label 'TenantsBlockedStyle', Locked = true;
        NewIncomingDocumentsStylePropNameTxt: Label 'NewIncomingDocumentsStyle', Locked = true;
        ApprovedIncomingDocumentsStylePropNameTxt: Label 'ApprovedIncomingDocumentsStyle', Locked = true;
        OCRPendingStylePropNameTxt: Label 'OCRPendingStyle', Locked = true;
        OCRCompletedStylePropNameTxt: Label 'OCRCompletedStyle', Locked = true;
        RequestsToApproveStylePropNameTxt: Label 'RequeststoApproveStyle', Locked = true;
        RequestsSentForApprovalStylePropNameTxt: Label 'RequestsSentForApprovalStyle', Locked = true;
        CashAccountsBalanceStylePropNameTxt: Label 'CashAccountsBalanceStyle', Locked = true;
        LastDepreciatedPostedDateStylePropNameTxt: Label 'LastDepreciatedPostedDateStyle', Locked = true;
        LastLoginDateStylePropNameTxt: Label 'LastLoginDateStyle', Locked = true;
        ContactNameStylePropNameTxt: Label 'ContactNameStyle', Locked = true;
        UserTaskIDPropNameTxt: Label 'ID', Locked = true;
        UserTaskTitlePropNameTxt: Label 'Title', Locked = true;
        UserTaskDueDateTimePropNameTxt: Label 'Due_DateTime', Locked = true;
        UserTaskPercentCompletePropNameTxt: Label 'Percent_Complete', Locked = true;
        UserTaskPriorityPropNameTxt: Label 'Priority', Locked = true;
        UserTaskCreatedByNamePropNameTxt: Label 'Created_By_Name', Locked = true;
        UserTaskCreatedDateTimePropNameTxt: Label 'Created_DateTime', Locked = true;
        UserTaskStartDateTimePropNameTxt: Label 'Start_DateTime', Locked = true;
        UserTaskLinkPropNameTxt: Label 'Link', Locked = true;
        MyUserTaskStylePropNameTxt: Label 'MyUserTaskStyle', Locked = true;
        UserTaskGroupAssignedToPropNameTxt: Label 'User_Task_Group_Assigned_To', Locked = true;

    procedure GatherKPIData(COHUBCompanyEndpoint: Record "COHUB Company Endpoint")
    var
        COHUBCompanyKPI: Record "COHUB Company KPI";
        COHUBEnviroment: Record "COHUB Enviroment";
        COHUBAPIRequest: Codeunit "COHUB API Request";
        ActivityCuesResponse: Text;
        FinanceCuesResponse: Text;
        UserTasksResponse: Text;
        RequestFailed: Boolean;
        COHUBExist: Boolean;
    begin
        COHUBExist := COHUBCompanyKPI.Get(COHUBCompanyEndpoint."Enviroment No.", COHUBCompanyEndpoint."Company Name", COHUBCompanyEndpoint."Assigned To");
        COHUBCompanyKPI."Enviroment No." := COHUBCompanyEndpoint."Enviroment No.";
        COHUBCompanyKPI."Company Name" := COHUBCompanyEndpoint."Company Name";
        COHUBCompanyKPI."Company Display Name" := COHUBCompanyEndpoint."Company Display Name";
        COHUBCompanyKPI."Assigned To" := COHUBCompanyEndpoint."Assigned To";

        if COHUBAPIRequest.InvokeActivityCuesAPI(COHUBCompanyEndpoint, ActivityCuesResponse) then
            ParseActivityCueFromJSON(ActivityCuesResponse, COHUBCompanyKPI)
        else
            RequestFailed := true;

        if COHUBAPIRequest.InvokeFinanceCuesAPI(COHUBCompanyEndpoint, FinanceCuesResponse) then
            ParseFinanceCueFromJSON(FinanceCuesResponse, COHUBCompanyKPI)
        else
            RequestFailed := true;

        if COHUBAPIRequest.InvokeUserTasksAPI(COHUBCompanyEndpoint, UserTasksResponse) then
            ParseUserTasksFromJSON(
              UserTasksResponse, COHUBCompanyEndpoint."Enviroment No.", COHUBCompanyEndpoint."Company Name",
              COHUBCompanyEndpoint."Company Display Name")
        else
            RequestFailed := true;

        COHUBCompanyKPI."Last Refreshed" := CurrentDateTime();

        if COHUBEnviroment.Get(COHUBCompanyEndpoint."Enviroment No.") then
            if (COHUBEnviroment."Contact Name" <> '') and (COHUBCompanyKPI."Contact Name" = '') then
                COHUBCompanyKPI."Contact Name" := CopyStr(COHUBEnviroment."Contact Name", 1, 50);

        if not COHUBExist then
            COHUBCompanyKPI.Insert(true)
        else
            if not RequestFailed then
                COHUBCompanyKPI.Modify(true);
    end;

    procedure SetTaskComplete(COHUBCompanyEndpoint: Record "COHUB Company Endpoint"; TaskId: Integer)
    var
        COHUBUserTask: Record "COHUB User Task";
        COHUBAPIRequest: Codeunit "COHUB API Request";
        UserTaskResponse: Text;
    begin
        if COHUBAPIRequest.InvokePostUserTaskComplete(COHUBCompanyEndpoint, UserTaskResponse, TaskId)
        then begin
            COHUBUserTask.SetRange("Enviroment No.", COHUBCompanyEndpoint."Enviroment No.");
            COHUBUserTask.SetRange("Company Name", COHUBCompanyEndpoint."Company Name");
            COHUBUserTask.SetRange(ID, TaskId);

            if COHUBUserTask.FindFirst() then begin
                COHUBUserTask."Percent Complete" := 100;
                COHUBUserTask.Modify();
            end;
        end;
    end;

    local procedure ParseActivityCueFromJSON(ActivityCueResponseJSON: Text; var COHUBCompanyKPI: Record "COHUB Company KPI")
    var
        COHUBFormatAmount: Codeunit "COHUB Format Amount";
        ActivityCuesJsonObject: JsonObject;
        ActivityCuesJsonArrayToken: JsonToken;
        ActivityCuesJsonArray: JsonArray;
        ActivityCuesValuesJsonToken: JsonToken;
        ActivityCuesValuesJsonObject: JsonObject;
        OverdueSalesInvoiceAmount: Decimal;
        OverduePurchaseInvoiceAmount: Decimal;
        CurrencySymbolTxt: Text[10];
    begin
        ActivityCuesJsonObject.ReadFrom(ActivityCueResponseJSON);
        ActivityCuesJsonObject.SelectToken(ArrayPropertyNameTxt, ActivityCuesJsonArrayToken);
        ActivityCuesJsonArray := ActivityCuesJsonArrayToken.AsArray();
        ActivityCuesJsonArray.Get(0, ActivityCuesValuesJsonToken);
        ActivityCuesValuesJsonObject := ActivityCuesValuesJsonToken.AsObject();

        // SetValueForKPI(JsonObject,OverduePurchInvoiceAmountPropNameTxt,JsonValue);
        COHUBCompanyKPI.Validate("Overdue Purch. Invoice Amount", GetStringKPIValue(ActivityCuesValuesJsonObject, OverduePurchInvoiceAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Overdue Sales Invoice Amount", GetStringKPIValue(ActivityCuesValuesJsonObject, OverdueSalesInvoiceAmountPropNameTxt));
        If COHUBCompanyKPI."Currency Symbol" = '' then
            COHUBCompanyKPI.Validate("Currency Symbol", GetStringKPIValue(ActivityCuesValuesJsonObject, CurrencySymbolPropNameTxt));

        if not GetDecimalKPIValue(ActivityCuesValuesJsonObject, OverduePurchInvoiceAmountDecimalPropNameTxt, OverduePurchaseInvoiceAmount) then
            if COHUBFormatAmount.ParseAmount(COHUBCompanyKPI."Overdue Purch. Invoice Amount", OverduePurchaseInvoiceAmount, CurrencySymbolTxt) then
                if COHUBCompanyKPI."Currency Symbol" = '' then
                    COHUBCompanyKPI."Currency Symbol" := CurrencySymbolTxt;

        COHUBCompanyKPI.Validate("Overdue Purch. Inv. Amt. Dec.", OverduePurchaseInvoiceAmount);

        if not GetDecimalKPIValue(ActivityCuesValuesJsonObject, OverdueSalesInvoiceAmountDecimalPropNameTxt, OverdueSalesInvoiceAmount) then
            if COHUBFormatAmount.ParseAmount(COHUBCompanyKPI."Overdue Sales Invoice Amount", OverdueSalesInvoiceAmount, CurrencySymbolTxt) then
                if COHUBCompanyKPI."Currency Symbol" = '' then
                    COHUBCompanyKPI."Currency Symbol" := CurrencySymbolTxt;

        COHUBCompanyKPI.Validate("Overdue Sales Inv. Amt. Dec.", OverdueSalesInvoiceAmount);

        COHUBCompanyKPI.Validate("Non-Applied Payments", GetStringKPIValue(ActivityCuesValuesJsonObject, NonAppliedPaymentsAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Purch. Invoices Due Next Week", GetStringKPIValue(ActivityCuesValuesJsonObject, PurchInvoicesDueNextWeekAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Sales Invoices Due Next Week", GetStringKPIValue(ActivityCuesValuesJsonObject, SalesInvoicesDueNextWeekAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Ongoing Purchase Invoices", GetStringKPIValue(ActivityCuesValuesJsonObject, OngoingPurchaseInvoicesAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Ongoing Sales Invoices", GetStringKPIValue(ActivityCuesValuesJsonObject, OngoingSalesInvoicesAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Sales This Month", GetStringKPIValue(ActivityCuesValuesJsonObject, SalesThisMonthAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Top 10 Company Sales YTD", GetStringKPIValue(ActivityCuesValuesJsonObject, Top10TenantSalesYTDAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Average Collection Days", GetStringKPIValue(ActivityCuesValuesJsonObject, AverageCollectionDaysAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Ongoing Sales Quotes", GetStringKPIValue(ActivityCuesValuesJsonObject, OngoingSalesQuotesAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Ongoing Sales Orders", GetStringKPIValue(ActivityCuesValuesJsonObject, OngoingSalesOrdersAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Requests to Approve", GetStringKPIValue(ActivityCuesValuesJsonObject, RequestsToApproveAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Purchase Orders", GetStringKPIValue(ActivityCuesValuesJsonObject, PurchaseOrdersAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Sales Inv. - Pending Doc.Exch.", GetStringKPIValue(ActivityCuesValuesJsonObject, SalesInvPendDocExchangeAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Sales CrM. - Pending Doc.Exch.", GetStringKPIValue(ActivityCuesValuesJsonObject, SalesCrMPendDocExchangeAmountPropNameTxt));
        COHUBCompanyKPI.Validate("My Incoming Documents", GetStringKPIValue(ActivityCuesValuesJsonObject, MyIncomingDocumentsAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Inc. Doc. Awaiting Verfication", GetStringKPIValue(ActivityCuesValuesJsonObject, IncDocAwaitingVerifAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Contact Name", GetStringKPIValue(ActivityCuesValuesJsonObject, ContactNameAmountTxt));

        COHUBCompanyKPI.Validate("Overdue Purch. Inv Amt Style", GetStringKPIValue(ActivityCuesValuesJsonObject, OverduePurchInvoiceStylePropNameTxt));
        COHUBCompanyKPI.Validate("Overdue Sales Inv Amt Style", GetStringKPIValue(ActivityCuesValuesJsonObject, OverdueSalesInvoiceStylePropNameTxt));
        COHUBCompanyKPI.Validate("Non-Applied Payments Style", GetStringKPIValue(ActivityCuesValuesJsonObject, NonAppliedPaymentsStylePropNameTxt));
        COHUBCompanyKPI.Validate("Purch. Inv Due Next Week Style", GetStringKPIValue(ActivityCuesValuesJsonObject, PurchInvoicesDueNextWeekStylePropNameTxt));
        COHUBCompanyKPI.Validate("Sales Inv Due Next Week Style", GetStringKPIValue(ActivityCuesValuesJsonObject, SalesInvoicesDueNextWeekStylePropNameTxt));
        COHUBCompanyKPI.Validate("Ongoing Purch. Invoices Style", GetStringKPIValue(ActivityCuesValuesJsonObject, OngoingPurchaseInvoicesStylePropNameTxt));
        COHUBCompanyKPI.Validate("Ongoing Sales Invoices Style", GetStringKPIValue(ActivityCuesValuesJsonObject, OngoingSalesInvoicesStylePropNameTxt));
        COHUBCompanyKPI.Validate("Sales This Month Style", GetStringKPIValue(ActivityCuesValuesJsonObject, SalesThisMonthStylePropNameTxt));
        COHUBCompanyKPI.Validate("Top 10 Cust Sales YTD Style", GetStringKPIValue(ActivityCuesValuesJsonObject, Top10TenantSalesYTDStylePropNameTxt));
        COHUBCompanyKPI.Validate("Average Collection Days Style", GetStringKPIValue(ActivityCuesValuesJsonObject, AverageCollectionDaysStylePropNameTxt));
        COHUBCompanyKPI.Validate("Ongoing Sales Quotes Style", GetStringKPIValue(ActivityCuesValuesJsonObject, OngoingSalesQuotesStylePropNameTxt));
        COHUBCompanyKPI.Validate("Ongoing Sales Orders Style", GetStringKPIValue(ActivityCuesValuesJsonObject, OngoingSalesOrdersStylePropNameTxt));
        COHUBCompanyKPI.Validate("Requests to Approve Style", GetStringKPIValue(ActivityCuesValuesJsonObject, RequestsToApproveStylePropNameTxt));
        COHUBCompanyKPI.Validate("Purchase Orders Style", GetStringKPIValue(ActivityCuesValuesJsonObject, PurchaseOrdersStylePropNameTxt));
        COHUBCompanyKPI.Validate("Sales Inv-Pend DocExch Style", GetStringKPIValue(ActivityCuesValuesJsonObject, SalesInvPendDocExchangeStylePropNameTxt));
        COHUBCompanyKPI.Validate("Sales CrM-Pend DocExch Style", GetStringKPIValue(ActivityCuesValuesJsonObject, SalesCrMPendDocExchangeStylePropNameTxt));
        COHUBCompanyKPI.Validate("My Incoming Documents Style", GetStringKPIValue(ActivityCuesValuesJsonObject, MyIncomingDocumentsStylePropNameTxt));
        COHUBCompanyKPI.Validate("Inc Doc Awaiting Verf Style", GetStringKPIValue(ActivityCuesValuesJsonObject, IncDocAwaitingVerifStylePropNameTxt));
        COHUBCompanyKPI.Validate("Contact Name Style", GetStringKPIValue(ActivityCuesValuesJsonObject, ContactNameStylePropNameTxt));
    end;

    local procedure ParseFinanceCueFromJSON(FinanceCueReponseJSON: Text; var COHUBCompanyKPI: Record "COHUB Company KPI")
    var
        COHUBFormatAmount: Codeunit "COHUB Format Amount";
        FinanceCuesJsonObject: JsonObject;
        FinanceCuesJsonArrayToken: JsonToken;
        FinanceCuesJsonArray: JsonArray;
        FinanceCuesValuesJsonToken: JsonToken;
        FinanceCuesValuesJsonObject: JsonObject;
        CashAccountsBalanceAmount: Decimal;
        CurrencySymbolTxt: Text[10];
    begin
        FinanceCuesJsonObject.ReadFrom(FinanceCueReponseJSON);
        FinanceCuesJsonObject.SelectToken(ArrayPropertyNameTxt, FinanceCuesJsonArrayToken);
        FinanceCuesJsonArray := FinanceCuesJsonArrayToken.AsArray();
        FinanceCuesJsonArray.Get(0, FinanceCuesValuesJsonToken);
        FinanceCuesValuesJsonObject := FinanceCuesValuesJsonToken.AsObject();

        If COHUBCompanyKPI."Currency Symbol" = '' then
            COHUBCompanyKPI.Validate("Currency Symbol", GetStringKPIValue(FinanceCuesValuesJsonObject, CurrencySymbolPropNameTxt));

        COHUBCompanyKPI.Validate("Overdue Purchase Documents", GetStringKPIValue(FinanceCuesValuesJsonObject, OverduePurchaseDocumentsAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Purchase Discounts Next Week", GetStringKPIValue(FinanceCuesValuesJsonObject, PurchaseDiscountsNextWeekAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Overdue Sales Documents", GetStringKPIValue(FinanceCuesValuesJsonObject, OverdueSalesDocumentsAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Purchase Documents Due Today", GetStringKPIValue(FinanceCuesValuesJsonObject, PurchaseDocumentsDueTodayAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Vendors - Payment on Hold", GetStringKPIValue(FinanceCuesValuesJsonObject, VendorsPaymentsOnHoldAmountPropNameTxt));
        COHUBCompanyKPI.Validate("POs Pending Approval", GetStringKPIValue(FinanceCuesValuesJsonObject, POsPendingApprovalAmountPropNameTxt));
        COHUBCompanyKPI.Validate("SOs Pending Approval", GetStringKPIValue(FinanceCuesValuesJsonObject, SOsPendingApprovalAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Approved Sales Orders", GetStringKPIValue(FinanceCuesValuesJsonObject, ApprovedSalesOrdersAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Approved Purchase Orders", GetStringKPIValue(FinanceCuesValuesJsonObject, ApprovedPurchaseOrdersAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Purchase Return Orders", GetStringKPIValue(FinanceCuesValuesJsonObject, PurchaseReturnOrdersAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Sales Return Orders - All", GetStringKPIValue(FinanceCuesValuesJsonObject, SalesReturnOrdersAllAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Enviroments - Blocked", GetStringKPIValue(FinanceCuesValuesJsonObject, TenantsBlockedAmountPropNameTxt));
        COHUBCompanyKPI.Validate("New Incoming Documents", GetStringKPIValue(FinanceCuesValuesJsonObject, NewIncomingDocumentsAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Approved Incoming Documents", GetStringKPIValue(FinanceCuesValuesJsonObject, ApprovedIncomingDocumentsAmountPropNameTxt));
        COHUBCompanyKPI.Validate("OCR Pending", GetStringKPIValue(FinanceCuesValuesJsonObject, OCRPendingAmountPropNameTxt));
        COHUBCompanyKPI.Validate("OCR Completed", GetStringKPIValue(FinanceCuesValuesJsonObject, OCRCompletedAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Requests to Approve", GetStringKPIValue(FinanceCuesValuesJsonObject, RequestsToApproveAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Requests Sent for Approval", GetStringKPIValue(FinanceCuesValuesJsonObject, RequestsSentForApprovalAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Cash Accounts Balance", GetStringKPIValue(FinanceCuesValuesJsonObject, CashAccountsBalanceAmountPropNameTxt));

        if not GetDecimalKPIValue(FinanceCuesValuesJsonObject, CashAccountsBalanceAmountDecimalPropNameTxt, CashAccountsBalanceAmount) then
            if COHUBFormatAmount.ParseAmount(COHUBCompanyKPI."Cash Accounts Balance", CashAccountsBalanceAmount, CurrencySymbolTxt) then
                if COHUBCompanyKPI."Currency Symbol" = '' then
                    COHUBCompanyKPI."Currency Symbol" := CurrencySymbolTxt;

        COHUBCompanyKPI.Validate("Cash Accounts Balance Decimal", CashAccountsBalanceAmount);

        COHUBCompanyKPI.Validate("Last Depreciated Posted Date", GetStringKPIValue(FinanceCuesValuesJsonObject, LastDepreciatedPostedDateAmountPropNameTxt));
        COHUBCompanyKPI.Validate("Last Login Date", GetStringKPIValue(FinanceCuesValuesJsonObject, LastLoginDateAmountPropNameTxt));

        COHUBCompanyKPI.Validate("Overdue Purch. Docs  Style", GetStringKPIValue(FinanceCuesValuesJsonObject, OverduePurchaseDocumentsStylePropNameTxt));
        COHUBCompanyKPI.Validate("Purch. Disc Next Week Style", GetStringKPIValue(FinanceCuesValuesJsonObject, PurchaseDiscountsNextWeekStylePropNameTxt));
        COHUBCompanyKPI.Validate("Overdue Sales Documents Style", GetStringKPIValue(FinanceCuesValuesJsonObject, OverdueSalesDocumentsStylePropNameTxt));
        COHUBCompanyKPI.Validate("Purch. Docs Due Today Style", GetStringKPIValue(FinanceCuesValuesJsonObject, PurchaseDocumentsDueTodayStylePropNameTxt));
        COHUBCompanyKPI.Validate("Vendors-Payment on Hold Style", GetStringKPIValue(FinanceCuesValuesJsonObject, VendorsPaymentsOnHoldStylePropNameTxt));
        COHUBCompanyKPI.Validate("POs Pending Approval Style", GetStringKPIValue(FinanceCuesValuesJsonObject, POsPendingApprovalStylePropNameTxt));
        COHUBCompanyKPI.Validate("SOs Pending Approval Style", GetStringKPIValue(FinanceCuesValuesJsonObject, SOsPendingApprovalStylePropNameTxt));
        COHUBCompanyKPI.Validate("Approved Sales Orders Style", GetStringKPIValue(FinanceCuesValuesJsonObject, ApprovedSalesOrdersStylePropNameTxt));
        COHUBCompanyKPI.Validate("Approved Purchase Orders Style", GetStringKPIValue(FinanceCuesValuesJsonObject, ApprovedPurchaseOrdersStylePropNameTxt));
        COHUBCompanyKPI.Validate("Purchase Return Orders Style", GetStringKPIValue(FinanceCuesValuesJsonObject, PurchaseReturnOrdersStylePropNameTxt));
        COHUBCompanyKPI.Validate("Sales Return Orders-All Style", GetStringKPIValue(FinanceCuesValuesJsonObject, SalesReturnOrdersAllStylePropNameTxt));
        COHUBCompanyKPI.Validate("Enviroments - Blocked Style", GetStringKPIValue(FinanceCuesValuesJsonObject, TenantsBlockedStylePropNameTxt));
        COHUBCompanyKPI.Validate("New Incoming Documents Style", GetStringKPIValue(FinanceCuesValuesJsonObject, NewIncomingDocumentsStylePropNameTxt));
        COHUBCompanyKPI.Validate("Approved Incoming Docs Style", GetStringKPIValue(FinanceCuesValuesJsonObject, ApprovedIncomingDocumentsStylePropNameTxt));
        COHUBCompanyKPI.Validate("OCR Pending Style", GetStringKPIValue(FinanceCuesValuesJsonObject, OCRPendingStylePropNameTxt));
        COHUBCompanyKPI.Validate("OCR Completed Style", GetStringKPIValue(FinanceCuesValuesJsonObject, OCRCompletedStylePropNameTxt));
        COHUBCompanyKPI.Validate("Requests to Approve Style", GetStringKPIValue(FinanceCuesValuesJsonObject, RequestsToApproveStylePropNameTxt));
        COHUBCompanyKPI.Validate("Req Sent for Approval Style", GetStringKPIValue(FinanceCuesValuesJsonObject, RequestsSentForApprovalStylePropNameTxt));
        COHUBCompanyKPI.Validate("Cash Accounts Balance Style", GetStringKPIValue(FinanceCuesValuesJsonObject, CashAccountsBalanceStylePropNameTxt));
        COHUBCompanyKPI.Validate("Last Dep Posted Date Style", GetStringKPIValue(FinanceCuesValuesJsonObject, LastDepreciatedPostedDateStylePropNameTxt));
        COHUBCompanyKPI.Validate("Last Login Date Style", GetStringKPIValue(FinanceCuesValuesJsonObject, LastLoginDateStylePropNameTxt));
        COHUBCompanyKPI.Validate("My User Task Style", GetStringKPIValue(FinanceCuesValuesJsonObject, MyUserTaskStylePropNameTxt));
    end;

    local procedure GetStringKPIValue(KPIJsonObject: JsonObject; KPIPropertyName: Text): Text;
    var
        PropertyBag: JsonToken;
        FoundProperty: Boolean;
    begin
        FoundProperty := KPIJsonObject.Get(KPIPropertyName, PropertyBag);

        if FoundProperty then
            exit(PropertyBag.AsValue().AsText());
    end;

    local procedure GetDateKPIValue(KPIJsonObject: JsonObject; KPIPropertyName: Text): DateTime;
    var
        PropertyBag: JsonToken;
        FoundProperty: Boolean;
    begin
        FoundProperty := KPIJsonObject.Get(KPIPropertyName, PropertyBag);

        if FoundProperty then
            exit(PropertyBag.AsValue().AsDateTime());
    end;

    local procedure GetDecimalKPIValue(KPIJsonObject: JsonObject; KPIPropertyName: Text; var DecimalValue: Decimal): Boolean;
    var
        PropertyBag: JsonToken;
        FoundProperty: Boolean;
    begin
        FoundProperty := KPIJsonObject.Get(KPIPropertyName, PropertyBag);

        if FoundProperty then
            DecimalValue := PropertyBag.AsValue().AsDecimal();

        exit(FoundProperty);
    end;

    local procedure ParseUserTasksFromJSON(UserTasksReponseJSON: Text; EnviromentNo: Code[20]; CompanyName: Text[50]; CompanyDisplayName: Text[50])
    var
        COHUBUserTask: Record "COHUB User Task";
        UserTasksJsonObject: JsonObject;
        UserTasksJsonArrayToken: JsonToken;
        UserTasksJsonArray: JsonArray;
        UserTasksValuesJsonToken: JsonToken;
        UserTasksValuesJsonObject: JsonObject;
        TasksCount: Integer;
        LastRefreshedOn: DateTime;
        FirstRow: Boolean;
    begin
        UserTasksJsonObject.ReadFrom(UserTasksReponseJSON);
        UserTasksJsonObject.SelectToken(ArrayPropertyNameTxt, UserTasksJsonArrayToken);
        UserTasksJsonArray := UserTasksJsonArrayToken.AsArray();

        FirstRow := true;
        TasksCount := 0;

        if UserTasksJsonArray.Count() > 0 then
            while TasksCount < UserTasksJsonArray.Count() do begin
                UserTasksJsonArray.Get(TasksCount, UserTasksValuesJsonToken);
                UserTasksValuesJsonObject := UserTasksValuesJsonToken.AsObject();

                CLEAR(COHUBUserTask);
                EvaluateUserTasksFromJSON(UserTasksValuesJsonObject, COHUBUserTask);
                COHUBUserTask.Validate("Last Refreshed", CurrentDateTime());
                COHUBUserTask.Validate("Enviroment No.", EnviromentNo);
                COHUBUserTask.Validate("Company Display Name", CompanyDisplayName);
                COHUBUserTask.Validate("Company Name", CompanyName);
                // Set assigned to - USERSECURITYID, as we know the user tasks we are saving belongs to the current user.
                COHUBUserTask.Validate("Assigned To", UserSecurityId());
                if not COHUBUserTask.Insert(true) then
                    COHUBUserTask.Modify();
                TasksCount := TasksCount + 1;
                if FirstRow then begin
                    FirstRow := false;
                    LastRefreshedOn := COHUBUserTask."Last Refreshed";
                end;
            end;
        Commit();
        COHUBUserTask.Reset();
        COHUBUserTask.SetFilter("Last Refreshed", '<%1', LastRefreshedOn);
        COHUBUserTask.SetRange("Assigned To", UserSecurityId());
        COHUBUserTask.SetRange("Enviroment No.", EnviromentNo);
        COHUBUserTask.SetRange("Company Display Name", CompanyDisplayName);
        if COHUBUserTask.FindSet() then
            repeat
                COHUBUserTask."Percent Complete" := 100;
                if COHUBUserTask.Modify() then;
            until COHUBUserTask.Next() = 0;
    end;

    local procedure EvaluateUserTasksFromJSON(JsonObject: JsonObject; var COHUBUserTask: Record "COHUB User Task")
    var
        VarID: Integer;
        VarDueDateTime: DateTime;
        VarPercentComplete: Integer;
        VarCreatedDateTime: DateTime;
        VarStartDateTime: DateTime;
        VarCreatedByName: Code[50];
        VarPriorityValue: Text;
        VarGroupAssignedTo: Code[20];
    begin
        // Evaluate ID
        if Evaluate(VarID, GetStringKPIValue(JsonObject, UserTaskIDPropNameTxt)) then
            COHUBUserTask.Validate(ID, VarID);
        // Evaluate Title
        COHUBUserTask.Validate(Title, GetStringKPIValue(JsonObject, UserTaskTitlePropNameTxt));
        // Evaluate Due date time
        VarDueDateTime := GetDateKPIValue(JsonObject, UserTaskDueDateTimePropNameTxt);
        COHUBUserTask.Validate("Due Date", DT2DATE(VarDueDateTime));

        // Evaluate Percent complete
        if Evaluate(VarPercentComplete, GetStringKPIValue(JsonObject, UserTaskPercentCompletePropNameTxt)) then
            COHUBUserTask.Validate("Percent Complete", VarPercentComplete);
        // Evaluate Priority
        // 0 - No priority set
        // 1 - Low, 2 - Normal, 3 - High
        VarPriorityValue := GetStringKPIValue(JsonObject, UserTaskPriorityPropNameTxt);
        case VarPriorityValue of
            '0':
                COHUBUserTask.Validate(Priority, 0);
            'Low':
                COHUBUserTask.Validate(Priority, 1);
            'Normal':
                COHUBUserTask.Validate(Priority, 2);
            'High':
                COHUBUserTask.Validate(Priority, 3);
        end;
        // Evaluate Created date time
        VarCreatedDateTime := GetDateKPIValue(JsonObject, UserTaskCreatedDateTimePropNameTxt);
        COHUBUserTask.Validate("Created Date", DT2DATE(VarCreatedDateTime));
        // Evaluate Start date time
        VarStartDateTime := GetDateKPIValue(JsonObject, UserTaskStartDateTimePropNameTxt);
        COHUBUserTask.Validate("Start Date", DT2DATE(VarStartDateTime));
        // Evaluate Created by name
        if Evaluate(VarCreatedByName, GetStringKPIValue(JsonObject, UserTaskCreatedByNamePropNameTxt)) then
            COHUBUserTask.Validate("Created By", VarCreatedByName);
        // Assign link
        COHUBUserTask.Validate(Link, GetStringKPIValue(JsonObject, UserTaskLinkPropNameTxt));
        // Evaluate user task group assigned to
        if Evaluate(VarGroupAssignedTo, GetStringKPIValue(JsonObject, UserTaskGroupAssignedToPropNameTxt)) then
            COHUBUserTask.Validate("User Task Group Assigned To", VarGroupAssignedTo);
    end;
}

