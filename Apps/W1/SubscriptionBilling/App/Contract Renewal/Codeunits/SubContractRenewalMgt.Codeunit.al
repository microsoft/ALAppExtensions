namespace Microsoft.SubscriptionBilling;

using System.Utilities;
using System.Environment.Configuration;
using Microsoft.Sales.Document;
using Microsoft.Utilities;

codeunit 8003 "Sub. Contract Renewal Mgt."
{
    TableNo = "Cust. Sub. Contract Line";

    trigger OnRun()
    var
        CustomerContractLine: Record "Cust. Sub. Contract Line";
    begin
        Clear(CreateContractRenewal);
        CreateContractRenewal.ClearCollectedSalesQuotes();
        CustomerContractLine.Copy(Rec);
        CustomerContractLine.FindFirst();
        CreateContractRenewalLines(CustomerContractLine);
        CreateSalesQuoteForContract(CustomerContractLine."Subscription Contract No.");
    end;

    local procedure CreateContractRenewalLines(var CustomerContractLine: Record "Cust. Sub. Contract Line")
    var
        ContractRenewalLine: Record "Sub. Contract Renewal Line";
        NoLinesCreatedMsg: Label 'No Contract Renewal Lines have been created.';
    begin
        CustomerContractLine.TestField("Subscription Contract No.");
        CreateContractRenewalLinesFromContractLineSelection(CustomerContractLine, AddVendorServices);

        ContractRenewalLine.Reset();
        ContractRenewalLine.SetRange("Linked to Sub. Contract No.", CustomerContractLine."Subscription Contract No.");
        if ContractRenewalLine.IsEmpty() then
            Error(NoLinesCreatedMsg);
    end;

    internal procedure StartContractRenewalFromContract(CustomerContract: Record "Customer Subscription Contract")
    var
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ContractRenewalSelection: Page "Contract Renewal Selection";
    begin
        if DropContractRenewalLines(CustomerContract."No.") then
            Commit(); // close transaction before opening page

        CustomerContract.TestField("No.");
        FilterRenewableContractLines(CustomerContract."No.", CustomerContractLine);

        Clear(ContractRenewalSelection);
        ContractRenewalSelection.LookupMode(true);
        ContractRenewalSelection.Editable(true);
        ContractRenewalSelection.SetTableView(CustomerContractLine);
        if ContractRenewalSelection.RunModal() = Action::LookupOK then
            if ContractRenewalSelection.GetSalesQuoteCreated() then
                CreateContractRenewal.OpenSalesQuotes();
    end;

    local procedure CreateContractRenewalLinesFromContractLineSelection(var CustomerContractLine: Record "Cust. Sub. Contract Line"; AddVendServices: Boolean)
    var
        SelectContractRenewal: Report "Select Contract Renewal";
    begin
        Clear(SelectContractRenewal);
        SelectContractRenewal.SetAddVendorServices(AddVendServices);
        CustomerContractLine.FindSet();
        repeat
            SelectContractRenewal.InsertFromCustContrLine(CustomerContractLine);
        until CustomerContractLine.Next() = 0;
    end;

    local procedure CreateSalesQuoteForContract(CustomerContractNo: Code[20])
    var
        CustomerContract: Record "Customer Subscription Contract";
        ContractRenewalLine: Record "Sub. Contract Renewal Line";
        IsHandled: Boolean;
    begin
        CustomerContract.Get(CustomerContractNo);
        CustomerContract.SetRecFilter();

        ContractRenewalLine.Reset();
        ContractRenewalLine.SetRange("Linked to Sub. Contract No.", CustomerContract."No.");

        IsHandled := false;
        OnBeforeRunCreateContractRenewalFromContract(CustomerContract, ContractRenewalLine, IsHandled);
        if not IsHandled then begin
            ContractRenewalLine.Reset();
            ContractRenewalLine.SetRange("Linked to Sub. Contract No.", CustomerContract."No.");
            Clear(CreateContractRenewal);
            CreateContractRenewal.ClearCollectedSalesQuotes();
            CreateContractRenewal.Run(ContractRenewalLine);
        end;
    end;

    local procedure FilterRenewableContractLines(CustomerContractNo: Code[20]; var CustomerContractLine: Record "Cust. Sub. Contract Line")
    var
        ServiceCommitment: Record "Subscription Line";
    begin
        CustomerContractLine.Reset();
        CustomerContractLine.SetRange("Subscription Contract No.", CustomerContractNo);
        CustomerContractLine.SetRange("Planned Sub. Line exists", false);
        CustomerContractLine.FilterOnServiceObjectContractLineType();
        CustomerContractLine.SetRange(Closed, false);
        if CustomerContractLine.FindSet() then
            repeat
                CustomerContractLine.TestField("Subscription Header No.");
                CustomerContractLine.TestField("Subscription Line Entry No.");
                ServiceCommitment.Get(CustomerContractLine."Subscription Line Entry No.");
                if ServiceCommitment."Subscription Line End Date" <> 0D then
                    CustomerContractLine.Mark(true);
            until CustomerContractLine.Next() = 0;
        CustomerContractLine.MarkedOnly(true);
        OnAfterFilterRenewableSubContrLines(CustomerContractNo, CustomerContractLine);
    end;

    local procedure DropContractRenewalLines(LinkedToCustomerContractNo: Code[20]): Boolean
    var
        ContractRenewalLine: Record "Sub. Contract Renewal Line";
        DropExistingLinesQst: Label 'Existing Contract Renewal Lines for Contract %1 will be dropped.\Do you want to continue?', Comment = '%1 = Contract No.';
    begin
        ContractRenewalLine.Reset();
        ContractRenewalLine.SetRange("Linked to Sub. Contract No.", LinkedToCustomerContractNo);
        if ContractRenewalLine.IsEmpty() then
            exit(false);
        if not ConfirmManagement.GetResponse(StrSubstNo(DropExistingLinesQst, LinkedToCustomerContractNo), true) then
            Error('');
        ContractRenewalLine.DeleteAll(true);
        exit(true);
    end;

    internal procedure IsContractRenewal(var SalesLine: Record "Sales Line"): Boolean
    begin
        exit(SalesLine.IsContractRenewalQuote());
    end;

    internal procedure IsContractRenewal(var RecRef: RecordRef): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        case RecRef.Number of
            Database::"Sales Header":
                begin
                    RecRef.SetTable(SalesHeader);
                    if SalesHeader."Document Type" = SalesHeader."Document Type"::Quote then
                        exit(IsContractRenewal(SalesHeader));
                end;
            Database::"Sales Line":
                begin
                    RecRef.SetTable(SalesLine);
                    exit(IsContractRenewal(SalesLine));
                end;
        end;
        exit(false);
    end;

    internal procedure IsContractRenewal(var SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                if SalesLine.IsContractRenewal() then
                    exit(true);
            until SalesLine.Next() = 0;
        exit(false);
    end;

    internal procedure FilterSalesLinesWithTypeServiceObject(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::"Service Object");
    end;

    internal procedure ShowRenewalSalesDocumentForContract(SalesDocumentType: Enum "Sales Document Type"; ContractNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        SalesServiceCommitment: Record "Sales Subscription Line";
        TempSalesHeader: Record "Sales Header" temporary;
        TextManagement: Codeunit "Text Management";
        PageManagement: Codeunit "Page Management";
        DocumentNoFilter: Text;
        Counter: Integer;
    begin
        DocumentNoFilter := '';
        Counter := 0;

        SalesServiceCommitment.SetRange("Document Type", SalesServiceCommitment."Document Type"::Quote, SalesServiceCommitment."Document Type"::Order);
        SalesServiceCommitment.SetRange("Linked to No.", ContractNo);
        SalesServiceCommitment.SetRange(Process, Enum::Process::"Contract Renewal");
        if SalesServiceCommitment.FindSet() then
            repeat
                if not TempSalesHeader.Get(SalesServiceCommitment."Document Type", SalesServiceCommitment."Document No.") then begin
                    TempSalesHeader."Document Type" := SalesServiceCommitment."Document Type";
                    TempSalesHeader."No." := SalesServiceCommitment."Document No.";
                    TempSalesHeader.Insert(false);
                    TextManagement.AppendText(DocumentNoFilter, TempSalesHeader."No.", '|');
                    Counter += 1;
                end;
            until SalesServiceCommitment.Next() = 0;

        if Counter = 1 then begin
            TempSalesHeader.FindFirst();
            SalesHeader.Get(TempSalesHeader."Document Type", TempSalesHeader."No.");
            PageManagement.PageRun(SalesHeader);
        end else begin
            TextManagement.ReplaceInvalidFilterChar(DocumentNoFilter);
            SalesHeader.Reset();
            SalesHeader.SetRange("Document Type", SalesDocumentType);
            SalesHeader.SetRange("No.", '');
            if DocumentNoFilter <> '' then
                SalesHeader.SetFilter("No.", DocumentNoFilter);
            if SalesDocumentType = "Sales Document Type"::Quote then
                Page.Run(Page::"Sales Quotes", SalesHeader)
            else
                Page.Run(Page::"Sales Order List", SalesHeader)
        end;
    end;

    internal procedure FilterServCommVendFromServCommCust(ServiceCommitmentCust: Record "Subscription Line"; var ServiceCommitmentVend: Record "Subscription Line")
    begin
        ServiceCommitmentVend.Reset();
        ServiceCommitmentVend.SetRange("Subscription Header No.", ServiceCommitmentCust."Subscription Header No.");
        ServiceCommitmentVend.SetRange(Partner, ServiceCommitmentVend.Partner::Vendor);
        ServiceCommitmentVend.SetFilter("Subscription Contract No.", '<>%1', '');
        ServiceCommitmentVend.SetFilter("Subscription Line End Date", '<>%1', 0D);
    end;

    internal procedure SetAddVendorServices(NewAddVendorServices: Boolean)
    begin
        AddVendorServices := NewAddVendorServices;
    end;

    local procedure GetNotificationIDForInvalidLinesHidden(): Guid
    begin
        exit('2b855d5f-35cd-4b36-9e48-51f7adf0c237');
    end;

    internal procedure NotifyIfLinesNotShown(var CustomerContractLine: Record "Cust. Sub. Contract Line")
    var
        CustomerContractLine2: Record "Cust. Sub. Contract Line";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        Notify: Notification;
        RecID: RecordId;
        NotAllLinesShownMsg: Label 'Note: Some lines are not valid for a renewal and are not shown here. Possible reasons can be a missing Ending Date or a pending planned Subscription Line.';
        DoNotShowAgainActionLbl: Label 'Don''t show again';
    begin
        if not NotificationIsActiveForLinesNotShown() then
            exit;

        CustomerContractLine2.Reset();
        CustomerContractLine2.SetRange("Subscription Contract No.", CustomerContractLine."Subscription Contract No.");
        CustomerContractLine2.FilterOnServiceObjectContractLineType();
        CustomerContractLine2.SetRange(Closed, false);
        if CustomerContractLine2.Count() <> CustomerContractLine.Count() then begin
            PrepareNotification(Notify, GetNotificationIDForInvalidLinesHidden(), NotAllLinesShownMsg, 'HideNotificationActiveForLinesNotShownForCurrentUser', DoNotShowAgainActionLbl);
            RecID := CustomerContractLine.RecordId;
            NotificationLifecycleMgt.SendNotification(Notify, RecID);
        end;
    end;

    local procedure NotificationIsActiveForLinesNotShown(): Boolean
    var
        MyNotification: Record "My Notifications";
        MyNotifications: Page "My Notifications";
    begin
        if not MyNotification.Get(UserId, GetNotificationIDForInvalidLinesHidden()) then begin
            MyNotifications.InitializeNotificationsWithDefaultState();
            if not MyNotification.Get(UserId, GetNotificationIDForInvalidLinesHidden()) then
                exit(false);
        end;
        exit(MyNotification.IsEnabled(GetNotificationIDForInvalidLinesHidden()));
    end;

    local procedure PrepareNotification(var Notify: Notification; NotificationID: Guid; NotificationMsg: Text; MethodName: Text; ActionCaption: Text)
    begin
        Clear(Notify);
        Notify.Id := NotificationID;
        Notify.Scope := Notify.Scope::LocalScope;
        Notify.AddAction(ActionCaption, Codeunit::"Sub. Contract Renewal Mgt.", MethodName);
        Notify.Message := NotificationMsg;
    end;

    internal procedure HideNotificationActiveForLinesNotShownForCurrentUser(Notify: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        if Notify.Id = GetNotificationIDForInvalidLinesHidden() then
            MyNotifications.Disable(Notify.Id);
    end;

    [EventSubscriber(ObjectType::Page, Page::"My Notifications", OnInitializingNotificationWithDefaultState, '', false, false)]
    local procedure InitializeNotificationLinesNotShown()
    var
        MyNotification: Record "My Notifications";
        NotificationLinesNotShownNameTxt: Label 'Notifies the User of Records that are not shown during an Contract Renewal', MaxLength = 128;
        NotificationLinesNotShownDescriptionTxt: Label 'Show a notification when selecting Customer Subscription Contract Lines for a Contract Renewal, that some of the lines are excluded from the selection.';
    begin
        if not MyNotification.Get(UserId, GetNotificationIDForInvalidLinesHidden()) then
            MyNotification.InsertDefault(
                GetNotificationIDForInvalidLinesHidden(),
                NotificationLinesNotShownNameTxt,
                NotificationLinesNotShownDescriptionTxt,
                true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunCreateContractRenewalFromContract(CustomerSubscriptionContractSource: Record "Customer Subscription Contract"; var SubContractRenewalLines: Record "Sub. Contract Renewal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFilterRenewableSubContrLines(CustomerContractNo: Code[20]; var CustSubContractLine: Record "Cust. Sub. Contract Line")
    begin
    end;

    internal procedure GetContractRenewalIdentifierLabel(): Code[20]
    begin
        exit(ContractRenewalIdentifierLbl);
    end;

    internal procedure ExistsInSalesOrderOrSalesQuote(ServicePartner: Enum "Service Partner"; ContractNo: Code[20]; ContractLineNo: Integer): Boolean
    var
        SalesServiceCommitment: Record "Sales Subscription Line";
    begin
        SalesServiceCommitment.SetRange("Document Type", SalesServiceCommitment."Document Type"::Quote, SalesServiceCommitment."Document Type"::Order);
        SalesServiceCommitment.SetRange(Partner, ServicePartner);
        SalesServiceCommitment.SetRange("Linked to No.", ContractNo);
        SalesServiceCommitment.SetRange("Linked to Line No.", ContractLineNo);
        SalesServiceCommitment.SetRange(Process, Enum::Process::"Contract Renewal");
        exit(not SalesServiceCommitment.IsEmpty());
    end;

    var
        CreateContractRenewal: Codeunit "Create Sub. Contract Renewal";
        ConfirmManagement: Codeunit "Confirm Management";
        AddVendorServices: Boolean;
        ContractRenewalIdentifierLbl: Label 'CONTRACTRENEWAL', Locked = true;
}