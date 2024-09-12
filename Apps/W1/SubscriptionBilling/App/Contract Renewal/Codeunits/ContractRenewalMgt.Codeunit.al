namespace Microsoft.SubscriptionBilling;

using System.Utilities;
using System.Environment.Configuration;
using Microsoft.Sales.Document;

codeunit 8003 "Contract Renewal Mgt."
{
    Access = Internal;
    TableNo = "Customer Contract Line";

    trigger OnRun()
    var
        CustomerContractLine: Record "Customer Contract Line";
    begin
        Clear(CreateContractRenewal);
        CreateContractRenewal.ClearCollectedSalesQuotes();
        CustomerContractLine.Copy(Rec);
        CustomerContractLine.FindFirst();
        CreateContractRenewalLines(CustomerContractLine);
        CreateSalesQuoteForContract(CustomerContractLine."Contract No.");
    end;

    local procedure CreateContractRenewalLines(var CustomerContractLine: Record "Customer Contract Line")
    var
        ContractRenewalLine: Record "Contract Renewal Line";
        NoLinesCreatedMsg: Label 'No Contract Renewal Lines have been created.';
    begin
        CustomerContractLine.TestField("Contract No.");
        CreateContractRenewalLinesFromContractLineSelection(CustomerContractLine, AddVendorServices);

        ContractRenewalLine.Reset();
        ContractRenewalLine.SetRange("Linked to Contract No.", CustomerContractLine."Contract No.");
        if ContractRenewalLine.IsEmpty() then
            Error(NoLinesCreatedMsg);
    end;

    procedure StartContractRenewalFromContract(CustomerContract: Record "Customer Contract")
    var
        CustomerContractLine: Record "Customer Contract Line";
        ContractRenewalSelection: Page "Contract Renewal Selection";
    begin
        if DropContractRenewalLines(CustomerContract."No.") then
            Commit(); // close transaction before opening page

        CustomerContract.TestField("No.");
        FilterRenewalableContractLines(CustomerContract."No.", CustomerContractLine);

        Clear(ContractRenewalSelection);
        ContractRenewalSelection.LookupMode(true);
        ContractRenewalSelection.Editable(true);
        ContractRenewalSelection.SetTableView(CustomerContractLine);
        if ContractRenewalSelection.RunModal() = Action::LookupOK then
            if ContractRenewalSelection.GetSalesQuoteCreated() then
                CreateContractRenewal.OpenSalesQuotes();
    end;

    internal procedure CreateContractRenewalLinesFromContractLineSelection(var CustomerContractLine: Record "Customer Contract Line"; AddVendServices: Boolean)
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

    internal procedure CreateSalesQuoteForContract(CustomerContractNo: Code[20])
    var
        CustomerContract: Record "Customer Contract";
        ContractRenewalLine: Record "Contract Renewal Line";
        IsHandled: Boolean;
    begin
        CustomerContract.Get(CustomerContractNo);
        CustomerContract.SetRecFilter();

        ContractRenewalLine.Reset();
        ContractRenewalLine.SetRange("Linked to Contract No.", CustomerContract."No.");

        IsHandled := false;
        OnBeforeRunCreateContractRenewalFromContract(CustomerContract, ContractRenewalLine, IsHandled);
        if not IsHandled then begin
            ContractRenewalLine.Reset();
            ContractRenewalLine.SetRange("Linked to Contract No.", CustomerContract."No.");
            Clear(CreateContractRenewal);
            CreateContractRenewal.ClearCollectedSalesQuotes();
            CreateContractRenewal.Run(ContractRenewalLine);
        end;
    end;

    local procedure FilterRenewalableContractLines(CustomerContractNo: Code[20]; var CustomerContractLine: Record "Customer Contract Line")
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        CustomerContractLine.Reset();
        CustomerContractLine.SetRange("Contract No.", CustomerContractNo);
        CustomerContractLine.SetRange("Planned Serv. Comm. exists", false);
        CustomerContractLine.SetRange("Contract Line Type", CustomerContractLine."Contract Line Type"::"Service Commitment");
        CustomerContractLine.SetRange(Closed, false);
        if CustomerContractLine.FindSet() then
            repeat
                CustomerContractLine.TestField("Service Object No.");
                CustomerContractLine.TestField("Service Commitment Entry No.");
                ServiceCommitment.Get(CustomerContractLine."Service Commitment Entry No.");
                if ServiceCommitment."Service End Date" <> 0D then
                    CustomerContractLine.Mark(true);
            until CustomerContractLine.Next() = 0;
        CustomerContractLine.MarkedOnly(true);
        OnAfterFilterRenewalableContractLines(CustomerContractNo, CustomerContractLine);
    end;

    local procedure DropContractRenewalLines(LinkedToCustomerContractNo: Code[20]): Boolean
    var
        ContractRenewalLine: Record "Contract Renewal Line";
        DropExistingLinesQst: Label 'Existing Contract Renewal Lines for Contract %1 will be dropped.\Do you want to continue?';
    begin
        ContractRenewalLine.Reset();
        ContractRenewalLine.SetRange("Linked to Contract No.", LinkedToCustomerContractNo);
        if ContractRenewalLine.IsEmpty() then
            exit(false);
        if not ConfirmManagement.GetResponse(StrSubstNo(DropExistingLinesQst, LinkedToCustomerContractNo), true) then
            Error('');
        ContractRenewalLine.DeleteAll(true);
        exit(true);
    end;

    procedure IsContractRenewal(var SalesLine: Record "Sales Line"): Boolean
    begin
        exit(SalesLine.IsContractRenewalQuote());
    end;

    procedure IsContractRenewal(var RecRef: RecordRef): Boolean
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

    procedure IsContractRenewal(var SalesHeader: Record "Sales Header"): Boolean
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

    procedure ShowRenewalSalesDocumentForContract(SalesDocumentType: Enum "Sales Document Type"; ContractNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        SalesServiceCommitment: Record "Sales Service Commitment";
        TempSalesHeader: Record "Sales Header" temporary;
        TextManagement: Codeunit "Text Management";
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
            if SalesDocumentType = "Sales Document Type"::Quote then
                Page.Run(Page::"Sales Quote", SalesHeader)
            else
                Page.Run(Page::"Sales Order", SalesHeader)
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

    procedure FilterServCommVendFromServCommCust(ServiceCommitmentCust: Record "Service Commitment"; var ServiceCommitmentVend: Record "Service Commitment")
    begin
        ServiceCommitmentVend.Reset();
        ServiceCommitmentVend.SetRange("Service Object No.", ServiceCommitmentCust."Service Object No.");
        ServiceCommitmentVend.SetRange(Partner, ServiceCommitmentVend.Partner::Vendor);
        ServiceCommitmentVend.SetFilter("Contract No.", '<>%1', '');
        ServiceCommitmentVend.SetFilter("Service End Date", '<>%1', 0D);
    end;

    procedure SetAddVendorServices(NewAddVendorServices: Boolean)
    begin
        AddVendorServices := NewAddVendorServices;
    end;

    internal procedure GetNotificationIDForInvalidLinesHidden(): Guid
    begin
        exit('2b855d5f-35cd-4b36-9e48-51f7adf0c237');
    end;

    procedure NotifyIfLinesNotShown(var CustomerContractLine: Record "Customer Contract Line")
    var
        CustomerContractLine2: Record "Customer Contract Line";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        Notify: Notification;
        RecID: RecordId;
        NotAllLinesShownMsg: Label 'Note: Some lines are not valid for a renewal and are not shown here. Possible reasons can be a missing Ending Date or a pending planned Service commitment.';
        DontShowAgainActionLbl: Label 'Don''t show again';
    begin
        if not NotificationIsActiveForLinesNotShown() then
            exit;

        CustomerContractLine2.Reset();
        CustomerContractLine2.SetRange("Contract No.", CustomerContractLine."Contract No.");
        CustomerContractLine2.SetRange("Contract Line Type", CustomerContractLine."Contract Line Type"::"Service Commitment");
        CustomerContractLine2.SetRange(Closed, false);
        if CustomerContractLine2.Count() <> CustomerContractLine.Count() then begin
            PrepareNotification(Notify, GetNotificationIDForInvalidLinesHidden(), NotAllLinesShownMsg, 'HideNotificationActiveForLinesNotShownForCurrentUser', DontShowAgainActionLbl);
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

    internal procedure PrepareNotification(var Notify: Notification; NotificationID: Guid; NotificationMsg: Text; MethodName: Text; ActionCaption: Text)
    begin
        Clear(Notify);
        Notify.Id := NotificationID;
        Notify.Scope := Notify.Scope::LocalScope;
        Notify.AddAction(ActionCaption, Codeunit::"Contract Renewal Mgt.", MethodName);
        Notify.Message := NotificationMsg;
    end;

    procedure HideNotificationActiveForLinesNotShownForCurrentUser(Notify: Notification)
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
        NotificationLinesNotShownDescriptionTxt: Label 'Show a notification when selecting Customer Contract Lines for a Contract Renewal, that some of the lines are excluded from the selection.';
    begin
        if not MyNotification.Get(UserId, GetNotificationIDForInvalidLinesHidden()) then
            MyNotification.InsertDefault(
                GetNotificationIDForInvalidLinesHidden(),
                NotificationLinesNotShownNameTxt,
                NotificationLinesNotShownDescriptionTxt,
                true);
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeRunCreateContractRenewalFromContract(CustomerContractSource: Record "Customer Contract"; var ContractRenewalLines: Record "Contract Renewal Line"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterFilterRenewalableContractLines(CustomerContractNo: Code[20]; var CustomerContractLine: Record "Customer Contract Line")
    begin
    end;

    procedure GetContractRenewalIdentifierLabel(): Code[20]
    begin
        exit(ContractRenewalIdentifierLbl);
    end;

    internal procedure ExistsInSalesOrderOrSalesQuote(ServicePartner: Enum "Service Partner"; ContractNo: Code[20]; ContractLineNo: Integer): Boolean
    var
        SalesServiceCommitment: Record "Sales Service Commitment";
    begin
        SalesServiceCommitment.SetRange("Document Type", SalesServiceCommitment."Document Type"::Quote, SalesServiceCommitment."Document Type"::Order);
        SalesServiceCommitment.SetRange(Partner, ServicePartner);
        SalesServiceCommitment.SetRange("Linked to No.", ContractNo);
        SalesServiceCommitment.SetRange("Linked to Line No.", ContractLineNo);
        SalesServiceCommitment.SetRange(Process, Enum::Process::"Contract Renewal");
        exit(not SalesServiceCommitment.IsEmpty());
    end;

    var
        CreateContractRenewal: Codeunit "Create Contract Renewal";
        ConfirmManagement: Codeunit "Confirm Management";
        AddVendorServices: Boolean;
        ContractRenewalIdentifierLbl: Label 'CONTRACTRENEWAL', Locked = true;
}