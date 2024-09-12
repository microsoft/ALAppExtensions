namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using Microsoft.Purchases.History;

codeunit 8004 "Post Contract Renewal"
{
    Access = Internal;
    TableNo = "Sales Header";

    trigger OnRun()
    begin
        RunCheck(Rec);
        Post(Rec);
    end;

    local procedure RunCheck(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        SalesServiceCommitment: Record "Sales Service Commitment";
        SalesLine: Record "Sales Line";
        ContractRenewalMgt: Codeunit "Contract Renewal Mgt.";
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
                            SalesServiceCommitment.TestField("Service Object No.");
                            SalesServiceCommitment.TestField("Service Commitment Entry No.");
                        until SalesServiceCommitment.Next() = 0;
                end;
            until SalesLine.Next() = 0;
    end;

    internal procedure Post(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        ContractRenewalMgt: Codeunit "Contract Renewal Mgt.";
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
        SalesServiceCommitment: Record "Sales Service Commitment";
    begin

        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        if SalesServiceCommitment.FindSet() then
            repeat
                InsertPlannedServiceCommitmentFromSalesServiceCommitment(SalesHeader, SalesLine, SalesServiceCommitment);
            until SalesServiceCommitment.Next() = 0;
    end;

    procedure InsertPlannedServiceCommitmentFromSalesServiceCommitment(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; SalesServiceCommitment: Record "Sales Service Commitment")
    var
        PlannedServiceCommitment: Record "Planned Service Commitment";
        ServiceCommitment: Record "Service Commitment";
        TempServiceCommitment: Record "Service Commitment" temporary;
        ServiceObject: Record "Service Object";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInsertPlannedServiceCommitmentFromSalesServiceCommitment(SalesLine, SalesServiceCommitment, IsHandled);
        if IsHandled then
            exit;

        SalesServiceCommitment.TestField("Service Object No.");
        SalesServiceCommitment.TestField("Service Commitment Entry No.");
        ServiceObject.Get(SalesServiceCommitment."Service Object No.");
        ServiceCommitment.Get(SalesServiceCommitment."Service Commitment Entry No.");

        TempServiceCommitment.Init();
        TempServiceCommitment."Service Object No." := SalesServiceCommitment."Service Object No.";
        TempServiceCommitment."Entry No." := SalesServiceCommitment."Service Commitment Entry No.";
        TempServiceCommitment."Customer Price Group" := SalesLine."Customer Price Group";
        if SalesServiceCommitment."Agreed Serv. Comm. Start Date" <> 0D then
            TempServiceCommitment.Validate("Service Start Date", SalesServiceCommitment."Agreed Serv. Comm. Start Date")
        else
            if Format(SalesServiceCommitment."Service Comm. Start Formula") = '' then
                TempServiceCommitment.Validate("Service Start Date", SalesLine."Shipment Date")
            else
                TempServiceCommitment.Validate("Service Start Date", CalcDate(SalesServiceCommitment."Service Comm. Start Formula", SalesLine."Shipment Date"));
        if (TempServiceCommitment."Service Start Date" <> 0D) and (Format(SalesServiceCommitment."Initial Term") <> '') then begin
            TempServiceCommitment."Service End Date" := CalcDate(SalesServiceCommitment."Initial Term", TempServiceCommitment."Service Start Date");
            TempServiceCommitment."Service End Date" := CalcDate('<-1D>', TempServiceCommitment."Service End Date");
        end;
        TempServiceCommitment.CopyFromSalesServiceCommitment(SalesServiceCommitment);
        TempServiceCommitment.CalculateInitialTermUntilDate();
        TempServiceCommitment.CalculateInitialServiceEndDate();
        TempServiceCommitment.CalculateInitialCancellationPossibleUntilDate();
        TempServiceCommitment.SetCurrencyData(SalesHeader."Currency Factor", SalesHeader."Posting Date", SalesHeader."Currency Code");
        TempServiceCommitment.SetLCYFields(TempServiceCommitment.Price, TempServiceCommitment."Service Amount", TempServiceCommitment."Discount Amount", TempServiceCommitment."Calculation Base Amount");
        TempServiceCommitment.SetDefaultDimensionFromItem(ServiceObject."Item No.");
        TempServiceCommitment.GetCombinedDimensionSetID(SalesLine."Dimension Set ID", TempServiceCommitment."Dimension Set ID");

        PlannedServiceCommitment.TransferFields(TempServiceCommitment, true);
        PlannedServiceCommitment."Sales Order No." := SalesHeader."No.";
        PlannedServiceCommitment."Sales Order Line No." := SalesLine."Line No.";
        PlannedServiceCommitment."Contract No." := ServiceCommitment."Contract No.";
        PlannedServiceCommitment."Contract Line No." := ServiceCommitment."Contract Line No.";
        PlannedServiceCommitment."Type Of Update" := Enum::"Type Of Price Update"::"Contract Renewal";
        PlannedServiceCommitment.Insert(false);

        OnAfterInsertPlannedServiceCommitmentFromSalesServiceCommitment(SalesLine, TempServiceCommitment, PlannedServiceCommitment);
    end;

    local procedure ProcessPlannedServiceCommitment(SalesLine: Record "Sales Line")
    var
        PlannedServiceCommitment: Record "Planned Service Commitment";
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
        CustomerContractLine: Record "Customer Contract Line";
        TempPlannedServiceCommitment: Record "Planned Service Commitment" temporary;
    begin
        DropPlannedServiceCommitmentBuffer(TempPlannedServiceCommitment);

        SalesInvoiceLine.Reset();
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SetFilter("Contract No.", '<>%1', '');
        SalesInvoiceLine.SetFilter("Contract Line No.", '<>%1', 0);
        if SalesInvoiceLine.FindSet() then begin
            CustomerContractLine.SetLoadFields("Service Object No.", "Service Commitment Entry No.");
            repeat
                if CustomerContractLine.Get(SalesInvoiceLine."Contract No.", SalesInvoiceLine."Contract Line No.") then
                    CreatePlannedServiceCommitmentBuffer(TempPlannedServiceCommitment, CustomerContractLine."Service Object No.", CustomerContractLine."Service Commitment Entry No.");
            until SalesInvoiceLine.Next() = 0;
        end;

        ProcessPlannedServiceCommitmentBuffer(TempPlannedServiceCommitment);
    end;

    internal procedure ProcessPlannedServCommsForPostedSalesCreditMemo(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        CustomerContractLine: Record "Customer Contract Line";
        ServiceCommitment: Record "Service Commitment";
        ServiceCommitmentArchive: Record "Service Commitment Archive";
    begin
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetFilter("Contract No.", '<>%1', '');
        SalesCrMemoLine.SetFilter("Contract Line No.", '<>%1', 0);
        if SalesCrMemoLine.FindSet() then begin
            CustomerContractLine.SetLoadFields("Service Object No.", "Service Commitment Entry No.");
            repeat
                if CustomerContractLine.Get(SalesCrMemoLine."Contract No.", SalesCrMemoLine."Contract Line No.") then begin
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
        VendorContractLine: Record "Vendor Contract Line";
        TempPlannedServiceCommitment: Record "Planned Service Commitment" temporary;
    begin
        DropPlannedServiceCommitmentBuffer(TempPlannedServiceCommitment);

        PurchInvLine.Reset();
        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
        PurchInvLine.SetFilter("Contract No.", '<>%1', '');
        PurchInvLine.SetFilter("Contract Line No.", '<>%1', 0);
        if PurchInvLine.FindSet() then begin
            VendorContractLine.SetLoadFields("Service Object No.", "Service Commitment Entry No.");
            repeat
                if VendorContractLine.Get(PurchInvLine."Contract No.", PurchInvLine."Contract Line No.") then
                    CreatePlannedServiceCommitmentBuffer(TempPlannedServiceCommitment, VendorContractLine."Service Object No.", VendorContractLine."Service Commitment Entry No.");
            until PurchInvLine.Next() = 0;
        end;

        ProcessPlannedServiceCommitmentBuffer(TempPlannedServiceCommitment);
    end;

    internal procedure ProcessPlannedServCommsForPostedPurchaseCreditMemo(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        VendorContractLine: Record "Vendor Contract Line";
        ServiceCommitment: Record "Service Commitment";
        ServiceCommitmentArchive: Record "Service Commitment Archive";
    begin
        PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHdr."No.");
        PurchCrMemoLine.SetFilter("Contract No.", '<>%1', '');
        PurchCrMemoLine.SetFilter("Contract Line No.", '<>%1', 0);
        if PurchCrMemoLine.FindSet() then begin
            VendorContractLine.SetLoadFields("Service Object No.", "Service Commitment Entry No.");
            repeat
                if VendorContractLine.Get(PurchCrMemoLine."Contract No.", PurchCrMemoLine."Contract Line No.") then begin
                    VendorContractLine.GetServiceCommitment(ServiceCommitment);
                    if ServiceCommitment.ServiceCommitmentArchiveExistsForPeriodExists(ServiceCommitmentArchive, PurchCrMemoLine."Recurring Billing from", PurchCrMemoLine."Recurring Billing to") then begin
                        CreatePlannedServiceCommitmentFromServiceCommitment(ServiceCommitment, ServiceCommitmentArchive);
                        ServiceCommitment.UpdateServiceCommitmentFromServiceCommitmentArchive(ServiceCommitmentArchive);
                    end;
                end;
            until PurchCrMemoLine.Next() = 0;
        end;
    end;

    local procedure DropPlannedServiceCommitmentBuffer(var TempPlannedServiceCommitment: Record "Planned Service Commitment" temporary)
    begin
        TempPlannedServiceCommitment.Reset();
        if not TempPlannedServiceCommitment.IsEmpty() then
            TempPlannedServiceCommitment.DeleteAll(false);
    end;

    local procedure CreatePlannedServiceCommitmentBuffer(var TempPlannedServiceCommitment: Record "Planned Service Commitment" temporary; ServiceObjectNo: Code[20]; ServiceCommitmentEntryNo: Integer)
    begin
        if not TempPlannedServiceCommitment.Get(ServiceCommitmentEntryNo) then begin
            TempPlannedServiceCommitment."Service Object No." := ServiceObjectNo;
            TempPlannedServiceCommitment."Entry No." := ServiceCommitmentEntryNo;
            TempPlannedServiceCommitment.Insert(false);
        end;
    end;

    local procedure CreatePlannedServiceCommitmentFromServiceCommitment(ServiceCommitment: Record "Service Commitment"; ServiceCommitmentArchive: Record "Service Commitment Archive")
    var
        PlannedServiceCommitment: Record "Planned Service Commitment";
    begin
        PlannedServiceCommitment.Init();
        PlannedServiceCommitment.TransferFields(ServiceCommitment);
        PlannedServiceCommitment."Type Of Update" := ServiceCommitmentArchive."Type Of Update";
        PlannedServiceCommitment."Perform Update On" := ServiceCommitmentArchive."Perform Update On";
        PlannedServiceCommitment.Insert(false);
    end;

    local procedure ProcessPlannedServiceCommitmentBuffer(var TempPlannedServiceCommitment: Record "Planned Service Commitment" temporary)
    var
        PlannedServiceCommitment: Record "Planned Service Commitment";
    begin
        TempPlannedServiceCommitment.Reset();
        if TempPlannedServiceCommitment.FindSet() then
            repeat
                if PlannedServiceCommitment.Get(TempPlannedServiceCommitment."Entry No.") then
                    ProcessPlannedServiceCommitment(PlannedServiceCommitment);
            until TempPlannedServiceCommitment.Next() = 0;
    end;

    procedure ProcessPlannedServiceCommitment(PlannedServiceCommitment: Record "Planned Service Commitment")
    var
        ServiceCommitment: Record "Service Commitment";
        IsHandled: Boolean;
    begin
        PlannedServiceCommitment.TestField("Service Object No.");
        PlannedServiceCommitment.TestField("Entry No.");

        IsHandled := false;
        OnBeforeProcessPlannedServComm(PlannedServiceCommitment, IsHandled);
        if IsHandled then
            exit;

        if ServiceCommitment.Get(PlannedServiceCommitment."Entry No.") then
            if CheckPerformServiceCommitmentUpdate(ServiceCommitment, PlannedServiceCommitment) then begin
                ServiceCommitment."Service End Date" := PlannedServiceCommitment."Service End Date";
                ServiceCommitment."Service Amount" := PlannedServiceCommitment."Service Amount";
                ServiceCommitment."Calculation Base Amount" := PlannedServiceCommitment."Calculation Base Amount";
                ServiceCommitment."Calculation Base %" := PlannedServiceCommitment."Calculation Base %";
                ServiceCommitment.Price := PlannedServiceCommitment.Price;
                ServiceCommitment."Discount %" := PlannedServiceCommitment."Discount %";
                ServiceCommitment."Discount Amount" := PlannedServiceCommitment."Discount Amount";
                ServiceCommitment."Billing Rhythm" := PlannedServiceCommitment."Billing Rhythm";
                ServiceCommitment."Billing Base Period" := PlannedServiceCommitment."Billing Base Period";
                ServiceCommitment."Term Until" := PlannedServiceCommitment."Term Until";
                ServiceCommitment."Cancellation Possible Until" := PlannedServiceCommitment."Cancellation Possible Until";
                ServiceCommitment."Next Price Update" := PlannedServiceCommitment."Next Price Update";
                ServiceCommitment."Price Binding Period" := PlannedServiceCommitment."Price Binding Period";
                OnBeforeUpdateServCommFromPlannedServComm(ServiceCommitment, PlannedServiceCommitment);

                ServiceCommitment.ArchiveServiceCommitment(CalcDate('<-1D>', ServiceCommitment."Next Billing Date"), PlannedServiceCommitment."Type Of Update");
                ServiceCommitment.Modify(false);
                PlannedServiceCommitment.Delete(true);
            end;
    end;

    local procedure CheckPerformServiceCommitmentUpdate(ServiceCommitment: Record "Service Commitment"; PlannedServiceCommitment: Record "Planned Service Commitment"): Boolean
    var
        PerformUpdate: Boolean;
    begin
        PerformUpdate :=
            (ServiceCommitment."Next Billing Date" >= ServiceCommitment."Service End Date") or
            ((ServiceCommitment."Calculation Base Amount" = PlannedServiceCommitment."Calculation Base Amount") and
             (ServiceCommitment."Calculation Base %" = PlannedServiceCommitment."Calculation Base %") and
             (ServiceCommitment.Price = PlannedServiceCommitment.Price) and
             (ServiceCommitment."Discount %" = PlannedServiceCommitment."Discount %") and
             (ServiceCommitment."Discount Amount" = PlannedServiceCommitment."Discount Amount") and
             (ServiceCommitment."Billing Rhythm" = PlannedServiceCommitment."Billing Rhythm") and
             (ServiceCommitment."Billing Base Period" = PlannedServiceCommitment."Billing Base Period"));

        ServiceCommitment.SetPerformUpdateForContractPriceUpdate(PerformUpdate, PlannedServiceCommitment."Type Of Update", PlannedServiceCommitment."Perform Update On");

        OnCheckPerformServCommUpdate(ServiceCommitment, PlannedServiceCommitment, PerformUpdate);
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

    [InternalEvent(false, false)]
    local procedure OnBeforeUpdateServCommFromPlannedServComm(var ServiceCommitment: Record "Service Commitment"; var PlannedServiceCommitment: Record "Planned Service Commitment")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCheckPerformServCommUpdate(ServiceCommitment: Record "Service Commitment"; PlannedServiceCommitment: Record "Planned Service Commitment"; var PerformUpdate: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeInsertPlannedServiceCommitmentFromSalesServiceCommitment(SalesLine: Record "Sales Line"; SalesServiceCommitment: Record "Sales Service Commitment"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterInsertPlannedServiceCommitmentFromSalesServiceCommitment(SalesLine: Record "Sales Line"; var TempServiceCommitment: Record "Service Commitment"; PlannedServiceCommitment: Record "Planned Service Commitment")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeProcessPlannedServComm(var PlannedServiceCommitment: Record "Planned Service Commitment"; var IsHandled: Boolean)
    begin
    end;
}