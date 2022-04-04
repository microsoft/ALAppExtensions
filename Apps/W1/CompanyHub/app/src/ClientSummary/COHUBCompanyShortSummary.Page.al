page 1153 "COHUB Company Short Summary"
{
    Caption = 'Company Hub';
    DelayedInsert = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "COHUB Group Company Summary";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                IndentationColumn = Indentation;
                IndentationControls = "Company Display Name";
                FreezeColumn = "Company Display Name";
                field("Company Display Name"; CompanyDisplayNameTxt)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Company Name';
                    ToolTip = 'Specifies the name of the company.';
                    Visible = true;
                    StyleExpr = DisplayNameStyle;
                    Enabled = Not IsGroup;
                    Editable = Not IsGroup;

                    trigger OnDrillDown();
                    var
                        COHUBCore: Codeunit "COHUB Core";
                    begin
                        if IsGroupEntry(Rec) then // this is a group
                            Message(GroupDrillDownMsg)
                        else
                            if COHUBEnviroment.Get(Rec."Enviroment No.") then
                                COHUBCore.GoToCompany(COHUBEnviroment, Rec."Company Name");
                    end;
                }
                field("Name"; Rec."Environment Name")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Enviroment Name';
                    ToolTip = 'Specifies the name of the environment. Specify your own name for the environment, or use the original name that has been defined in this environment.';
                    Visible = true;
                    Enabled = Not IsGroup;
                    Editable = Not IsGroup;

                    trigger OnDrillDown();
                    begin
                        if IsGroupEntry(Rec) then
                            Message(GroupDrillDownMsg)
                        else
                            if COHUBEnviroment.Get(Rec."Enviroment No.") then
                                Page.Run(Page::"COHUB Enviroment Card", COHUBEnviroment);
                    end;
                }
                field("Contact Name"; Rec."Contact Name")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the Company Group.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Enviroment No."; Rec."Enviroment No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'No.';
                    ToolTip = 'Specifies the number used to lookup the setup record more easilly.';
                    Visible = false;
                    DrillDown = false;
                }
                field("My User Tasks"; MyUserTasks)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'My User Tasks';
                    StyleExpr = MyUserTaskStyle;
                    ToolTip = 'Specifies the number of pending tasks that are assigned to you or to a group that you are a member of.';
                    Visible = true;
                }
                field("My Overdue Tasks"; MyOverdueTasks)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'My Overdue Tasks';
                    ToolTip = 'Specifies the number of overdue tasks that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                }
                field("Overdue Sales Documents"; Rec."Overdue Sales Documents")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = OverdueSalesDocumentsStyle;
                    ToolTip = 'Specifies the number of overdue sales documents that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Purchase Documents Due Today"; Rec."Purchase Documents Due Today")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = PurchaseDocumentsDueTodayStyle;
                    ToolTip = 'Specifies the number of purchase documents due for today that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("POs Pending Approval"; Rec."POs Pending Approval")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = POsPendingApprovalStyle;
                    ToolTip = 'Specifies the number of purchase orders pending approval that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("SOs Pending Approval"; Rec."SOs Pending Approval")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = SOsPendingApprovalStyle;
                    ToolTip = 'Specifies the number of sales orders pending approval that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Approved Sales Orders"; Rec."Approved Sales Orders")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = ApprovedSalesOrdersStyle;
                    ToolTip = 'Specifies the number of approved sales orders that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }

                field("Approved Purchase Orders"; Rec."Approved Purchase Orders")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = ApprovedPurchaseOrdersStyle;
                    ToolTip = 'Specifies the number of approved purchase orders that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Vendors - Payment on Hold"; Rec."Vendors - Payment on Hold")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = VendorsPaymentonHoldStyle;
                    ToolTip = 'Specifies the number of vendor payments on hold that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Purchase Return Orders"; Rec."Purchase Return Orders")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = PurchaseReturnOrdersStyle;
                    ToolTip = 'Specifies the number of approved purchase return orders that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Sales Return Orders - All"; Rec."Sales Return Orders - All")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = SalesReturnOrdersAllStyle;
                    ToolTip = 'Specifies the number of sales return orders that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Enviroments - Blocked"; Rec."Enviroments - Blocked")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = EnviromentsBlockedStyle;
                    ToolTip = 'Specifies the number of blocked tenants.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Overdue Purchase Documents"; Rec."Overdue Purchase Documents")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = OverduePurchaseDocumentsStyle;
                    ToolTip = 'Specifies the number of overdue purchase documents that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Purchase Discounts Next Week"; Rec."Purchase Discounts Next Week")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = PurchaseDiscountsNextWeekStyle;
                    ToolTip = 'Specifies the number of purchase discounts for the next week.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Purch. Invoices Due Next Week"; Rec."Purch. Invoices Due Next Week")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = PurchInvoicesDueNextWeekStyle;
                    ToolTip = 'Specifies the number of purchase invoices that are due for the next week.';
                    Visible = false;
                    DrillDown = false;
                }
                field("New Incoming Documents"; Rec."New Incoming Documents")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = NewIncomingDocumentsStyle;
                    ToolTip = 'Specifies the number of new incoming documents that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Approved Incoming Documents"; Rec."Approved Incoming Documents")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = ApprovedIncomingDocumentsStyle;
                    ToolTip = 'Specifies the number of approved incoming documents that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("OCR Pending"; Rec."OCR Pending")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = OCRPendingStyle;
                    ToolTip = 'Specifies the number of documents pending for OCR that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("OCR Completed"; Rec."OCR Completed")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = OCRCompletedStyle;
                    ToolTip = 'Specifies the number of documents on which OCR is completed that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Requests to Approve"; Rec."Requests to Approve")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = RequeststoApproveStyle;
                    ToolTip = 'Specifies the number of requests to approve that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Requests Sent for Approval"; Rec."Requests Sent for Approval")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = RequestsSentforApprovalStyle;
                    ToolTip = 'Specifies the number of requests sent to approval that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Non-Applied Payments"; Rec."Non-Applied Payments")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = NonAppliedPaymentsStyle;
                    ToolTip = 'Specifies the number of non-applied payments that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Cash Accounts Balance"; Rec."Cash Accounts Balance")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = CashAccountsBalanceStyle;
                    ToolTip = 'Specifies the balance on cash accounts.  ';
                    Visible = false;
                    DrillDown = false;
                }

                field("Cash Accounts Balance Decimal"; Rec."Cash Accounts Balance Decimal")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = AmountFormatExpression;
                    AutoFormatType = 11;
                    StyleExpr = CashAccountsBalanceStyle;
                    BlankZero = true;
                    Caption = 'Cash Accounts Balance';
                    ToolTip = 'Specifies the balance on cash accounts.  ';
                    Visible = false;
                    DrillDown = false;
                }

                field("Last Depreciated Posted Date"; Rec."Last Depreciated Posted Date")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = LastDepreciatedPostedDateStyle;
                    ToolTip = 'Specifies the last depreciated posted date.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Ongoing Sales Invoices"; Rec."Ongoing Sales Invoices")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = OngoingSalesInvoicesStyle;
                    ToolTip = 'Specifies the number of ongoing sales invoices that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Ongoing Purchase Invoices"; Rec."Ongoing Purchase Invoices")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = OngoingPurchaseInvoicesStyle;
                    ToolTip = 'Specifies the number of ongoing purchase invoices that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Sales This Month"; Rec."Sales This Month")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = SalesThisMonthStyle;
                    ToolTip = 'Specifies the total sales for this month.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Top 10 Company Sales YTD"; Rec."Top 10 Company Sales YTD")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = Top10CompanySalesYTDStyle;
                    ToolTip = 'Specifies the top 10 company sales year to date.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Overdue Purch. Invoice Amount"; Rec."Overdue Purch. Invoice Amount")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = OverduePurchInvoiceAmountStyle;
                    ToolTip = 'Specifies the total amount on overdue purchase invoices.';
                    Visible = false;
                    DrillDown = false;
                }

                field("Overdue Purch. Invoice Amount Decimal"; Rec."Overdue Purch. Inv Amt Decimal")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = AmountFormatExpression;
                    AutoFormatType = 11;
                    BlankZero = true;
                    Caption = 'Overdue Purch. Invoice Amount';
                    StyleExpr = OverduePurchInvoiceAmountStyle;
                    ToolTip = 'Specifies the total amount on overdue purchase invoices.';
                    Visible = false;
                    DrillDown = false;
                }

                field("Overdue Sales Invoice Amount"; Rec."Overdue Sales Invoice Amount")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = OverdueSalesInvoiceAmountStyle;
                    ToolTip = 'Specifies the total amount on overdue sales invoices.';
                    Visible = false;
                    DrillDown = false;
                }

                field("Overdue Sales Invoice Amount Decimal"; Rec."Overdue Sales Inv. Amt. Dec.")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = AmountFormatExpression;
                    AutoFormatType = 11;
                    BlankZero = true;
                    StyleExpr = OverdueSalesInvoiceAmountStyle;
                    Caption = 'Overdue Sales Invoice Amount';
                    ToolTip = 'Specifies the total amount on overdue sales invoices.';
                    Visible = false;
                    DrillDown = false;
                }

                field("Average Collection Days"; Rec."Average Collection Days")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = AverageCollectionDaysStyle;
                    ToolTip = 'Specifies the average collection days.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Ongoing Sales Quotes"; Rec."Ongoing Sales Quotes")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = OngoingSalesQuotesStyle;
                    ToolTip = 'Specifies the number of ongoing sales quotes that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Sales Inv. - Pending Doc.Exch."; Rec."Sales Inv. - Pending Doc.Exch.")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = SalesInvPendingDocExchStyle;
                    ToolTip = 'Specifies the number of sales invoices pending sending to document exchange that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Sales CrM. - Pending Doc.Exch."; Rec."Sales CrM. - Pending Doc.Exch.")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = SalesCrMPendingDocExchStyle;
                    ToolTip = 'Specifies the number of sales credit memos pending sending to the document exchange that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("My Incoming Documents"; Rec."My Incoming Documents")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = MyIncomingDocumentsStyle;
                    ToolTip = 'Specifies the number of my incoming documents that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Sales Invoices Due Next Week"; Rec."Sales Invoices Due Next Week")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = SalesInvoicesDueNextWeekStyle;
                    ToolTip = 'Specifies the number of sales invoices due for next week that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Ongoing Sales Orders"; Rec."Ongoing Sales Orders")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = OngoingSalesOrdersStyle;
                    ToolTip = 'Specifies the number of ongoing sales orders that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Inc. Doc. Awaiting Verfication"; Rec."Inc. Doc. Awaiting Verfication")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inc. Doc. Awaiting Verification';
                    StyleExpr = IncDocAwaitingVerficationStyle;
                    ToolTip = 'Specifies the number of inconming documents awaiting verfication that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Purchase Orders"; Rec."Purchase Orders")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = PurchaseOrdersStyle;
                    ToolTip = 'Specifies the number of purchase orders that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Last Refreshed"; Rec."Last Refreshed")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Last Refreshed';
                    ToolTip = 'Specifies the last refreshed date.';
                    Visible = false;
                    DrillDown = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(RefreshCurrentCompany)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Refresh Current Company';
                Image = Refresh;
                Scope = Repeater;
                ToolTip = 'Get fresh data for the chosen company.';
                Visible = true;

                trigger OnAction();
                begin
                    COHUBCore.UpdateEnviromentCompany(Rec."Enviroment No.", Rec."Company Name", Rec."Assigned To");
                    Codeunit.Run(Codeunit::"COHUB Group Summary Sync");
                    CurrPage.Update(false);
                end;
            }
            action(ReloadAllCompanies)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Reload';
                Image = WorkCenterLoad;
                ToolTip = 'Reload all enviroments and update company data.';
                Visible = true;

                trigger OnAction();
                begin
                    COHUBCore.UpdateAllCompanies(false);
                    Codeunit.Run(Codeunit::"COHUB Group Summary Sync");
                    CurrPage.Update(false);
                end;
            }

            action(GoToCompany)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Go To Company';
                Image = Company;
                Scope = Repeater;
                ToolTip = 'Open this company in a new window.';
                Visible = true;

                trigger OnAction();
                begin
                    CurrPage.Update(false);
                    if COHUBEnviroment.Get(Rec."Enviroment No.") then
                        COHUBCore.GoToCompany(COHUBEnviroment, Rec."Company Name");
                end;
            }
        }
    }

    trigger OnAfterGetRecord();
    var
        COHUBFormatAmount: Codeunit "COHUB Format Amount";
    begin
        Indentation := Rec.Indent;
        SetStyleDescriptions();
        SetUserTasksKPI();
        CalcFields("Currency Symbol");
        if not IsGroupEntry(Rec) then
            if not COHUBEnviroment.Get(Rec."Enviroment No.") then
                Rec.Delete()
            else
                AmountFormatExpression := COHUBFormatAmount.GetAmountFormat(Rec."Currency Symbol");

        if Rec."Company Display Name" <> '' then
            CompanyDisplayNameTxt := Rec."Company Display Name"
        else
            CompanyDisplayNameTxt := Rec."Company Name";
    end;

    trigger OnOpenPage();
    var
        COHUBEnviroment1: Record "COHUB Enviroment";
        COHUBCore1: Codeunit "COHUB Core";
    begin
        // Give users access to records with their security id or the sample data
        Rec.SetFilter("Assigned To", '%1|%2', UserSecurityId(), '00000000-0000-0000-0000-000000000000');

        if COHUBEnviroment1.IsEmpty() then
            COHUBCore1.ShowSetupCompanyHubNotification()
        else
            COHUBCore1.UpdateAllCompanies(true);

        Codeunit.Run(Codeunit::"COHUB Group Summary Sync");
        CurrPage.Update(false);
    end;

    var
        COHUBEnviroment: Record "COHUB Enviroment";
        COHUBCore: Codeunit "COHUB Core";
        Indentation: Integer;
        OverdueSalesDocumentsStyle: Text;
        PurchaseDocumentsDueTodayStyle: Text;
        POsPendingApprovalStyle: Text;
        SOsPendingApprovalStyle: Text;
        ApprovedSalesOrdersStyle: Text;
        ApprovedPurchaseOrdersStyle: Text;
        VendorsPaymentonHoldStyle: Text;
        PurchaseReturnOrdersStyle: Text;
        SalesReturnOrdersAllStyle: Text;
        EnviromentsBlockedStyle: Text;
        OverduePurchaseDocumentsStyle: Text;
        PurchaseDiscountsNextWeekStyle: Text;
        PurchInvoicesDueNextWeekStyle: Text;
        NewIncomingDocumentsStyle: Text;
        ApprovedIncomingDocumentsStyle: Text;
        OCRPendingStyle: Text;
        OCRCompletedStyle: Text;
        RequeststoApproveStyle: Text;
        RequestsSentforApprovalStyle: Text;
        NonAppliedPaymentsStyle: Text;
        CashAccountsBalanceStyle: Text;
        LastDepreciatedPostedDateStyle: Text;
        OngoingSalesInvoicesStyle: Text;
        OngoingPurchaseInvoicesStyle: Text;
        SalesThisMonthStyle: Text;
        Top10CompanySalesYTDStyle: Text;
        OverduePurchInvoiceAmountStyle: Text;
        OverdueSalesInvoiceAmountStyle: Text;
        AverageCollectionDaysStyle: Text;
        OngoingSalesQuotesStyle: Text;
        SalesInvPendingDocExchStyle: Text;
        SalesCrMPendingDocExchStyle: Text;
        MyIncomingDocumentsStyle: Text;
        SalesInvoicesDueNextWeekStyle: Text;
        OngoingSalesOrdersStyle: Text;
        IncDocAwaitingVerficationStyle: Text;
        PurchaseOrdersStyle: Text;
        MyUserTasks: Text[5];
        MyOverdueTasks: Text[5];
        MyUserTaskStyle: Text;
        CompanyDisplayNameTxt: Text;
        GroupDrillDownMsg: Label 'You have chosen the name of a group, and there is nothing to look up.';
        DisplayNameStyle: Text;
        IsGroup: Boolean;
        AmountFormatExpression: Text;

    local procedure SetStyleDescriptions()
    begin
        IsGroup := IsGroupEntry(Rec);
        if IsGroup then
            DisplayNameStyle := 'StrongAccent'
        else begin
            DisplayNameStyle := 'Standard';
            SetFieldStyles();
        end;
    end;

    local procedure IsGroupEntry(COHUBGroupCompanySummary: Record "COHUB Group Company Summary"): Boolean
    begin
        exit((COHUBGroupCompanySummary."Enviroment No." = '') and (COHUBGroupCompanySummary.Indent = 0));
    end;

    local procedure SetFieldStyles()
    begin
        // Since these are flow fields we have to force a read or styles won't work.
        Rec.CalcFields("Overdue Sales Documents Style");
        OverdueSalesDocumentsStyle := Format(Rec."Overdue Sales Documents Style");

        Rec.CalcFields("Purch. Docs Due Today Style");
        PurchaseDocumentsDueTodayStyle := Format(Rec."Purch. Docs Due Today Style");

        Rec.CalcFields("POs Pending Approval Style");
        POsPendingApprovalStyle := Format(Rec."POs Pending Approval Style");

        Rec.CalcFields("SOs Pending Approval Style");
        SOsPendingApprovalStyle := Format(Rec."SOs Pending Approval Style");

        Rec.CalcFields("Approved Sales Orders Style");
        ApprovedSalesOrdersStyle := Format(Rec."Approved Sales Orders Style");

        Rec.CalcFields("Approved Purchase Orders Style");
        ApprovedPurchaseOrdersStyle := Format(Rec."Approved Purchase Orders Style");

        Rec.CalcFields("Vendors-Payment on Hold Style");
        VendorsPaymentonHoldStyle := Format(Rec."Vendors-Payment on Hold Style");

        Rec.CalcFields("Purchase Return Orders Style");
        PurchaseReturnOrdersStyle := Format(Rec."Purchase Return Orders Style");

        Rec.CalcFields("Sales Return Orders-All Style");
        SalesReturnOrdersAllStyle := Format(Rec."Sales Return Orders-All Style");

        Rec.CalcFields("Enviroments - Blocked Style");
        EnviromentsBlockedStyle := Format(Rec."Enviroments - Blocked Style");

        Rec.CalcFields("Overdue Purch. Docs  Style");
        OverduePurchaseDocumentsStyle := Format(Rec."Overdue Purch. Docs  Style");

        Rec.CalcFields("Purch. Disc Next Week Style");
        PurchaseDiscountsNextWeekStyle := Format(Rec."Purch. Disc Next Week Style");

        Rec.CalcFields("Purch. Inv Due Next Week Style");
        PurchInvoicesDueNextWeekStyle := Format(Rec."Purch. Inv Due Next Week Style");

        Rec.CalcFields("New Incoming Documents Style");
        NewIncomingDocumentsStyle := Format(Rec."New Incoming Documents Style");

        Rec.CalcFields("Approved Incoming Docs Style");
        ApprovedIncomingDocumentsStyle := Format(Rec."Approved Incoming Docs Style");

        Rec.CalcFields("OCR Pending Style");
        OCRPendingStyle := Format(Rec."OCR Pending Style");

        Rec.CalcFields("OCR Completed Style");
        OCRCompletedStyle := Format(Rec."OCR Completed Style");

        Rec.CalcFields("Requests to Approve Style");
        RequeststoApproveStyle := Format(Rec."Requests to Approve Style");

        Rec.CalcFields("Req Sent for Approval Style");
        RequestsSentforApprovalStyle := Format(Rec."Req Sent for Approval Style");

        Rec.CalcFields("Non-Applied Payments Style");
        NonAppliedPaymentsStyle := Format(Rec."Non-Applied Payments Style");

        Rec.CalcFields("Cash Accounts Balance Style");
        CashAccountsBalanceStyle := Format(Rec."Cash Accounts Balance Style");

        Rec.CalcFields("Last Dep Posted Date Style");
        LastDepreciatedPostedDateStyle := Format(Rec."Last Dep Posted Date Style");

        Rec.CalcFields("Ongoing Sales Invoices Style");
        OngoingSalesInvoicesStyle := Format(Rec."Ongoing Sales Invoices Style");

        Rec.CalcFields("Ongoing Purch. Invoices Style");
        OngoingPurchaseInvoicesStyle := Format(Rec."Ongoing Purch. Invoices Style");

        Rec.CalcFields("Sales This Month Style");
        SalesThisMonthStyle := Format(Rec."Sales This Month Style");

        Rec.CalcFields("Top 10 Cust Sales YTD Style");
        Top10CompanySalesYTDStyle := Format(Rec."Top 10 Cust Sales YTD Style");

        Rec.CalcFields("Overdue Purch. Inv Amt Style");
        OverduePurchInvoiceAmountStyle := Format(Rec."Overdue Purch. Inv Amt Style");

        Rec.CalcFields("Overdue Sales Inv Amt Style");
        OverdueSalesInvoiceAmountStyle := Format(Rec."Overdue Sales Inv Amt Style");

        Rec.CalcFields("Average Collection Days Style");
        AverageCollectionDaysStyle := Format(Rec."Average Collection Days Style");

        Rec.CalcFields("Ongoing Sales Quotes Style");
        OngoingSalesQuotesStyle := Format(Rec."Ongoing Sales Quotes Style");

        Rec.CalcFields("Sales Inv-Pend DocExch Style");
        SalesInvPendingDocExchStyle := Format(Rec."Sales Inv-Pend DocExch Style");

        Rec.CalcFields("Sales CrM-Pend DocExch Style");
        SalesCrMPendingDocExchStyle := Format(Rec."Sales CrM-Pend DocExch Style");

        Rec.CalcFields("My Incoming Documents Style");
        MyIncomingDocumentsStyle := Format(Rec."My Incoming Documents Style");

        Rec.CalcFields("Sales Inv Due Next Week Style");
        SalesInvoicesDueNextWeekStyle := Format(Rec."Sales Inv Due Next Week Style");

        Rec.CalcFields("Ongoing Sales Orders Style");
        OngoingSalesOrdersStyle := Format(Rec."Ongoing Sales Orders Style");

        Rec.CalcFields("Inc Doc Awaiting Verf Style");
        IncDocAwaitingVerficationStyle := Format(Rec."Inc Doc Awaiting Verf Style");

        Rec.CalcFields("Purchase Orders Style");
        PurchaseOrdersStyle := Format(Rec."Purchase Orders Style");

        Rec.CalcFields("My User Task Style");
        MyUserTaskStyle := Format(Rec."My User Task Style");
    end;

    local procedure SetUserTasksKPI()
    var
        COHUBUserTask: Record "COHUB User Task";
    begin
        if (Rec."Enviroment No." = '') and (Rec.Indent = 0) then begin // this is a group
            MyUserTasks := '';
            MyOverdueTasks := '';
        end
        else
            COHUBUserTask.GetUserTaskCounts(Rec."Enviroment No.", Rec."Company Name", MyUserTasks, MyOverdueTasks);
    end;
}
