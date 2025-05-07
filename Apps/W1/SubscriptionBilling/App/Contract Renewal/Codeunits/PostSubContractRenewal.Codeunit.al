namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using Microsoft.Purchases.History;

codeunit 8004 "Post Sub. Contract Renewal"
{
    TableNo = "Sales Header";

    trigger OnRun()
    begin
        RunCheck(Rec);
        Post(Rec);
    end;

    local procedure RunCheck(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        SalesServiceCommitment: Record "Sales Subscription Line";
        SalesLine: Record "Sales Line";
        ContractRenewalMgt: Codeunit "Sub. Contract Renewal Mgt.";
        NoContractRenewalLinesFoundErr: Label 'Contract Renewal cannot be executed: no contract Renewal lines found in %1 %2.', Comment = '%1 = SalesHeader."Document Type", %2 = SalesHeader."No."';
    begin
        SalesHeader.TestField("Document Type", SalesHeader."Document Type"::Order);
        if not ContractRenewalMgt.IsContractRenewal(SalesHeader) then
            Error(NoContractRenewalLinesFoundErr, SalesHeader."Document Type", SalesHeader."No.");
        Customer.Get(SalesHeader."Sell-to Customer No.");
        Customer.CheckBlockedCustOnDocs(Customer, SalesHeader."Document Type"::Order, true, false);
        if SalesHeader."Sell-to Customer No." <> SalesHeader."Bill-to Customer No." then begin
            Customer.Get(SalesHeader."Bill-to Customer No.");
            Customer.CheckBlockedCustOnDocs(Customer, SalesHeader."Document Type"::Order, true, false);
        end;

        ContractRenewalMgt.FilterSalesLinesWithTypeServiceObject(SalesLine, SalesHeader);
        if SalesLine.FindSet() then
            repeat
                if SalesLine."Quantity Shipped" <> SalesLine.Quantity then begin
                    SalesServiceCommitment.FilterOnSalesLine(SalesLine);
                    if SalesServiceCommitment.FindSet() then
                        repeat
                            SalesServiceCommitment.TestField("Subscription Header No.");
                            SalesServiceCommitment.TestField("Subscription Line Entry No.");
                        until SalesServiceCommitment.Next() = 0;
                end;
            until SalesLine.Next() = 0;
    end;

    local procedure Post(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        ContractRenewalMgt: Codeunit "Sub. Contract Renewal Mgt.";
    begin
        ContractRenewalMgt.FilterSalesLinesWithTypeServiceObject(SalesLine, SalesHeader);
        if SalesLine.FindSet() then
            repeat
                if SalesLine."Quantity Shipped" <> SalesLine.Quantity then begin
                    CreatePlannedServiceCommitments(SalesHeader, SalesLine);
                    ProcessPlannedServiceCommitment(SalesLine);
                    SetQuantites(SalesLine);
                end;
            until SalesLine.Next() = 0;
    end;

    local procedure CreatePlannedServiceCommitments(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        SalesServiceCommitment: Record "Sales Subscription Line";
    begin

        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        if SalesServiceCommitment.FindSet() then
            repeat
                InsertPlannedServiceCommitmentFromSalesServiceCommitment(SalesHeader, SalesLine, SalesServiceCommitment);
            until SalesServiceCommitment.Next() = 0;
    end;

    local procedure InsertPlannedServiceCommitmentFromSalesServiceCommitment(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; SalesServiceCommitment: Record "Sales Subscription Line")
    var
        PlannedServiceCommitment: Record "Planned Subscription Line";
        ServiceCommitment: Record "Subscription Line";
        TempServiceCommitment: Record "Subscription Line" temporary;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInsertPlannedSubscriptionLineFromSalesSubscriptionLine(SalesLine, SalesServiceCommitment, IsHandled);
        if IsHandled then
            exit;

        SalesServiceCommitment.TestField("Subscription Header No.");
        SalesServiceCommitment.TestField("Subscription Line Entry No.");
        ServiceCommitment.Get(SalesServiceCommitment."Subscription Line Entry No.");

        TempServiceCommitment.Init();
        TempServiceCommitment."Subscription Header No." := SalesServiceCommitment."Subscription Header No.";
        TempServiceCommitment."Entry No." := SalesServiceCommitment."Subscription Line Entry No.";
        TempServiceCommitment."Customer Price Group" := SalesLine."Customer Price Group";
        if SalesServiceCommitment."Agreed Sub. Line Start Date" <> 0D then
            TempServiceCommitment.Validate("Subscription Line Start Date", SalesServiceCommitment."Agreed Sub. Line Start Date")
        else
            if Format(SalesServiceCommitment."Sub. Line Start Formula") = '' then
                TempServiceCommitment.Validate("Subscription Line Start Date", SalesLine."Shipment Date")
            else
                TempServiceCommitment.Validate("Subscription Line Start Date", CalcDate(SalesServiceCommitment."Sub. Line Start Formula", SalesLine."Shipment Date"));
        if (TempServiceCommitment."Subscription Line Start Date" <> 0D) and (Format(SalesServiceCommitment."Initial Term") <> '') then begin
            TempServiceCommitment."Subscription Line End Date" := CalcDate(SalesServiceCommitment."Initial Term", TempServiceCommitment."Subscription Line Start Date");
            TempServiceCommitment."Subscription Line End Date" := CalcDate('<-1D>', TempServiceCommitment."Subscription Line End Date");
        end;
        TempServiceCommitment.CopyFromSalesServiceCommitment(SalesServiceCommitment);
        TempServiceCommitment.CalculateInitialTermUntilDate();
        TempServiceCommitment.CalculateInitialServiceEndDate();
        TempServiceCommitment.CalculateInitialCancellationPossibleUntilDate();
        TempServiceCommitment.SetCurrencyData(SalesHeader."Currency Factor", SalesHeader."Posting Date", SalesHeader."Currency Code");
        TempServiceCommitment.SetLCYFields(true);
        TempServiceCommitment.SetDefaultDimensions(true);
        TempServiceCommitment.GetCombinedDimensionSetID(SalesLine."Dimension Set ID", TempServiceCommitment."Dimension Set ID");

        PlannedServiceCommitment.TransferFields(TempServiceCommitment, true);
        PlannedServiceCommitment."Sales Order No." := SalesHeader."No.";
        PlannedServiceCommitment."Sales Order Line No." := SalesLine."Line No.";
        PlannedServiceCommitment."Subscription Contract No." := ServiceCommitment."Subscription Contract No.";
        PlannedServiceCommitment."Subscription Contract Line No." := ServiceCommitment."Subscription Contract Line No.";
        PlannedServiceCommitment."Type Of Update" := Enum::"Type Of Price Update"::"Contract Renewal";
        PlannedServiceCommitment.Insert(false);

        OnAfterInsertPlannedSubscriptionLineFromSalesSubscriptionLine(SalesLine, TempServiceCommitment, PlannedServiceCommitment);
    end;

    local procedure ProcessPlannedServiceCommitment(SalesLine: Record "Sales Line")
    var
        PlannedServiceCommitment: Record "Planned Subscription Line";
    begin
        PlannedServiceCommitment.Reset();
        PlannedServiceCommitment.SetCurrentKey("Sales Order No.");
        PlannedServiceCommitment.SetRange("Sales Order No.", SalesLine."Document No.");
        PlannedServiceCommitment.SetRange("Sales Order Line No.", SalesLine."Line No.");
        if PlannedServiceCommitment.FindSet() then
            repeat
                ProcessPlannedServiceCommitment(PlannedServiceCommitment);
            until PlannedServiceCommitment.Next() = 0;
    end;

    internal procedure ProcessPlannedServCommsForPostedSalesInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        TempPlannedServiceCommitment: Record "Planned Subscription Line" temporary;
    begin
        DropPlannedServiceCommitmentBuffer(TempPlannedServiceCommitment);

        SalesInvoiceLine.Reset();
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SetFilter("Subscription Contract No.", '<>%1', '');
        SalesInvoiceLine.SetFilter("Subscription Contract Line No.", '<>%1', 0);
        if SalesInvoiceLine.FindSet() then begin
            CustomerContractLine.SetLoadFields("Subscription Header No.", "Subscription Line Entry No.");
            repeat
                if CustomerContractLine.Get(SalesInvoiceLine."Subscription Contract No.", SalesInvoiceLine."Subscription Contract Line No.") then
                    CreatePlannedServiceCommitmentBuffer(TempPlannedServiceCommitment, CustomerContractLine."Subscription Header No.", CustomerContractLine."Subscription Line Entry No.");
            until SalesInvoiceLine.Next() = 0;
        end;

        ProcessPlannedServiceCommitmentBuffer(TempPlannedServiceCommitment);
    end;

    internal procedure ProcessPlannedServCommsForPostedSalesCreditMemo(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentArchive: Record "Subscription Line Archive";
    begin
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetFilter("Subscription Contract No.", '<>%1', '');
        SalesCrMemoLine.SetFilter("Subscription Contract Line No.", '<>%1', 0);
        if SalesCrMemoLine.FindSet() then begin
            CustomerContractLine.SetLoadFields("Subscription Header No.", "Subscription Line Entry No.");
            repeat
                if CustomerContractLine.Get(SalesCrMemoLine."Subscription Contract No.", SalesCrMemoLine."Subscription Contract Line No.") then begin
                    CustomerContractLine.GetServiceCommitment(ServiceCommitment);
                    if ServiceCommitment.ServiceCommitmentArchiveExistsForPeriodExists(ServiceCommitmentArchive, SalesCrMemoLine."Recurring Billing from", SalesCrMemoLine."Recurring Billing to") then begin
                        CreatePlannedServiceCommitmentFromServiceCommitment(ServiceCommitment, ServiceCommitmentArchive);
                        ServiceCommitment.UpdateServiceCommitmentFromServiceCommitmentArchive(ServiceCommitmentArchive);
                    end;
                end;
            until SalesCrMemoLine.Next() = 0;
        end;
    end;

    internal procedure ProcessPlannedServCommsForPostedPurchaseInvoice(var PurchInvHeader: Record "Purch. Inv. Header")
    var
        PurchInvLine: Record "Purch. Inv. Line";
        VendorContractLine: Record "Vend. Sub. Contract Line";
        TempPlannedServiceCommitment: Record "Planned Subscription Line" temporary;
    begin
        DropPlannedServiceCommitmentBuffer(TempPlannedServiceCommitment);

        PurchInvLine.Reset();
        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
        PurchInvLine.SetFilter("Subscription Contract No.", '<>%1', '');
        PurchInvLine.SetFilter("Subscription Contract Line No.", '<>%1', 0);
        if PurchInvLine.FindSet() then begin
            VendorContractLine.SetLoadFields("Subscription Header No.", "Subscription Line Entry No.");
            repeat
                if VendorContractLine.Get(PurchInvLine."Subscription Contract No.", PurchInvLine."Subscription Contract Line No.") then
                    CreatePlannedServiceCommitmentBuffer(TempPlannedServiceCommitment, VendorContractLine."Subscription Header No.", VendorContractLine."Subscription Line Entry No.");
            until PurchInvLine.Next() = 0;
        end;

        ProcessPlannedServiceCommitmentBuffer(TempPlannedServiceCommitment);
    end;

    internal procedure ProcessPlannedServCommsForPostedPurchaseCreditMemo(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        VendorContractLine: Record "Vend. Sub. Contract Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentArchive: Record "Subscription Line Archive";
    begin
        PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHdr."No.");
        PurchCrMemoLine.SetFilter("Subscription Contract No.", '<>%1', '');
        PurchCrMemoLine.SetFilter("Subscription Contract Line No.", '<>%1', 0);
        if PurchCrMemoLine.FindSet() then begin
            VendorContractLine.SetLoadFields("Subscription Header No.", "Subscription Line Entry No.");
            repeat
                if VendorContractLine.Get(PurchCrMemoLine."Subscription Contract No.", PurchCrMemoLine."Subscription Contract Line No.") then begin
                    VendorContractLine.GetServiceCommitment(ServiceCommitment);
                    if ServiceCommitment.ServiceCommitmentArchiveExistsForPeriodExists(ServiceCommitmentArchive, PurchCrMemoLine."Recurring Billing from", PurchCrMemoLine."Recurring Billing to") then begin
                        CreatePlannedServiceCommitmentFromServiceCommitment(ServiceCommitment, ServiceCommitmentArchive);
                        ServiceCommitment.UpdateServiceCommitmentFromServiceCommitmentArchive(ServiceCommitmentArchive);
                    end;
                end;
            until PurchCrMemoLine.Next() = 0;
        end;
    end;

    local procedure DropPlannedServiceCommitmentBuffer(var TempPlannedServiceCommitment: Record "Planned Subscription Line" temporary)
    begin
        TempPlannedServiceCommitment.Reset();
        if not TempPlannedServiceCommitment.IsEmpty() then
            TempPlannedServiceCommitment.DeleteAll(false);
    end;

    local procedure CreatePlannedServiceCommitmentBuffer(var TempPlannedServiceCommitment: Record "Planned Subscription Line" temporary; ServiceObjectNo: Code[20]; ServiceCommitmentEntryNo: Integer)
    begin
        if not TempPlannedServiceCommitment.Get(ServiceCommitmentEntryNo) then begin
            TempPlannedServiceCommitment."Subscription Header No." := ServiceObjectNo;
            TempPlannedServiceCommitment."Entry No." := ServiceCommitmentEntryNo;
            TempPlannedServiceCommitment.Insert(false);
        end;
    end;

    local procedure CreatePlannedServiceCommitmentFromServiceCommitment(ServiceCommitment: Record "Subscription Line"; ServiceCommitmentArchive: Record "Subscription Line Archive")
    var
        PlannedServiceCommitment: Record "Planned Subscription Line";
    begin
        PlannedServiceCommitment.Init();
        PlannedServiceCommitment.TransferFields(ServiceCommitment);
        PlannedServiceCommitment."Type Of Update" := ServiceCommitmentArchive."Type Of Update";
        PlannedServiceCommitment."Perform Update On" := ServiceCommitmentArchive."Perform Update On";
        PlannedServiceCommitment.Insert(false);
    end;

    local procedure ProcessPlannedServiceCommitmentBuffer(var TempPlannedServiceCommitment: Record "Planned Subscription Line" temporary)
    var
        PlannedServiceCommitment: Record "Planned Subscription Line";
    begin
        TempPlannedServiceCommitment.Reset();
        if TempPlannedServiceCommitment.FindSet() then
            repeat
                if PlannedServiceCommitment.Get(TempPlannedServiceCommitment."Entry No.") then
                    ProcessPlannedServiceCommitment(PlannedServiceCommitment);
            until TempPlannedServiceCommitment.Next() = 0;
    end;

    local procedure ProcessPlannedServiceCommitment(PlannedServiceCommitment: Record "Planned Subscription Line")
    var
        ServiceCommitment: Record "Subscription Line";
        IsHandled: Boolean;
    begin
        PlannedServiceCommitment.TestField("Subscription Header No.");
        PlannedServiceCommitment.TestField("Entry No.");

        IsHandled := false;
        OnBeforeProcessPlannedSubscriptionLine(PlannedServiceCommitment, IsHandled);
        if IsHandled then
            exit;

        if ServiceCommitment.Get(PlannedServiceCommitment."Entry No.") then
            if CheckPerformServiceCommitmentUpdate(ServiceCommitment, PlannedServiceCommitment) then begin
                ServiceCommitment."Subscription Line End Date" := PlannedServiceCommitment."Subscription Line End Date";
                ServiceCommitment.Amount := PlannedServiceCommitment.Amount;
                ServiceCommitment."Calculation Base Amount" := PlannedServiceCommitment."Calculation Base Amount";
                ServiceCommitment."Calculation Base %" := PlannedServiceCommitment."Calculation Base %";
                ServiceCommitment.Price := PlannedServiceCommitment.Price;
                ServiceCommitment."Discount %" := PlannedServiceCommitment."Discount %";
                ServiceCommitment."Discount Amount" := PlannedServiceCommitment."Discount Amount";
                ServiceCommitment."Unit Cost" := PlannedServiceCommitment."Unit Cost";
                ServiceCommitment.SetLCYFields(true);
                ServiceCommitment."Billing Rhythm" := PlannedServiceCommitment."Billing Rhythm";
                ServiceCommitment."Billing Base Period" := PlannedServiceCommitment."Billing Base Period";
                ServiceCommitment."Term Until" := PlannedServiceCommitment."Term Until";
                ServiceCommitment."Cancellation Possible Until" := PlannedServiceCommitment."Cancellation Possible Until";
                ServiceCommitment."Next Price Update" := PlannedServiceCommitment."Next Price Update";
                ServiceCommitment."Price Binding Period" := PlannedServiceCommitment."Price Binding Period";
                OnBeforeUpdateSubscriptionLineFromPlannedSubscriptionLine(ServiceCommitment, PlannedServiceCommitment);

                ServiceCommitment.ArchiveServiceCommitment(CalcDate('<-1D>', ServiceCommitment."Next Billing Date"), PlannedServiceCommitment."Type Of Update");
                ServiceCommitment.Modify(false);
                PlannedServiceCommitment.Delete(true);
            end;
    end;

    local procedure CheckPerformServiceCommitmentUpdate(ServiceCommitment: Record "Subscription Line"; PlannedServiceCommitment: Record "Planned Subscription Line"): Boolean
    var
        PerformUpdate: Boolean;
    begin
        PerformUpdate :=
            (ServiceCommitment."Next Billing Date" >= ServiceCommitment."Subscription Line End Date") or
            ((ServiceCommitment."Calculation Base Amount" = PlannedServiceCommitment."Calculation Base Amount") and
             (ServiceCommitment."Calculation Base %" = PlannedServiceCommitment."Calculation Base %") and
             (ServiceCommitment.Price = PlannedServiceCommitment.Price) and
             (ServiceCommitment."Discount %" = PlannedServiceCommitment."Discount %") and
             (ServiceCommitment."Discount Amount" = PlannedServiceCommitment."Discount Amount") and
             (ServiceCommitment."Billing Rhythm" = PlannedServiceCommitment."Billing Rhythm") and
             (ServiceCommitment."Billing Base Period" = PlannedServiceCommitment."Billing Base Period"));

        ServiceCommitment.SetPerformUpdateForContractPriceUpdate(PerformUpdate, PlannedServiceCommitment."Type Of Update", PlannedServiceCommitment."Perform Update On");

        OnCheckPerformSubscriptionLineUpdate(ServiceCommitment, PlannedServiceCommitment, PerformUpdate);
        exit(PerformUpdate);
    end;

    local procedure SetQuantites(var SalesLine: Record "Sales Line")
    begin
        SalesLine."Quantity Shipped" := SalesLine."Qty. to Ship";
        SalesLine."Quantity Invoiced" := SalesLine."Quantity Shipped";
        SalesLine."Qty. Invoiced (Base)" := SalesLine."Qty. Shipped (Base)";
        SalesLine."Qty. Shipped Not Invoiced" := 0;
        SalesLine."Qty. Shipped Not Invd. (Base)" := 0;
        SalesLine."Shipped Not Invoiced" := 0;
        SalesLine."Shipped Not Invoiced (LCY)" := 0;
        SalesLine."Shipped Not Inv. (LCY) No VAT" := 0;
        SalesLine."Qty. to Ship" := 0;
        SalesLine."Qty. to Invoice" := 0;
        SalesLine.Modify(false);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateSubscriptionLineFromPlannedSubscriptionLine(var SubscriptionLine: Record "Subscription Line"; var PlannedSubscriptionLine: Record "Planned Subscription Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckPerformSubscriptionLineUpdate(SubscriptionLine: Record "Subscription Line"; PlannedSubscriptionLine: Record "Planned Subscription Line"; var PerformUpdate: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPlannedSubscriptionLineFromSalesSubscriptionLine(SalesLine: Record "Sales Line"; SalesSubscriptionLine: Record "Sales Subscription Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPlannedSubscriptionLineFromSalesSubscriptionLine(SalesLine: Record "Sales Line"; var TempSubscriptionLine: Record "Subscription Line"; var PlannedSubscriptionLine: Record "Planned Subscription Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessPlannedSubscriptionLine(var PlannedSubscriptionLine: Record "Planned Subscription Line"; var IsHandled: Boolean)
    begin
    end;
}