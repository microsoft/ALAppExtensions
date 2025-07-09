namespace Microsoft.SubscriptionBilling;

using System.Text;

report 8000 "Select Contract Renewal"
{
    Caption = 'Select Subscriptions for Contract Renewal';
    ProcessingOnly = true;
    UsageCategory = None;

    dataset
    {
        dataitem(CustomerContractFilter; "Customer Subscription Contract")
        {
            RequestFilterFields = "No.", "Contract Type";

            trigger OnPreDataItem()
            begin
                CurrReport.Break();
            end;
        }
        dataitem(CustomerContractLineFilter; "Cust. Sub. Contract Line")
        {
            DataItemTableView = sorting("Subscription Contract No.") where(Closed = const(false));

            trigger OnPreDataItem()
            begin
                CurrReport.Break();
            end;
        }
        dataitem(ServiceCommitmentFilter; "Subscription Line")
        {
            RequestFilterFields = "Subscription Header No.", "Subscription Line Start Date";

            trigger OnPreDataItem()
            begin
                CurrReport.Break();
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ServiceEndDatePeriodFilterCtrl; ServiceEndDatePeriodFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Subscription Line End Date Period';
                        ToolTip = 'Specifies the Date Filter used to select then Contract Lines based on the Subscription Line End Date of the Subscription Lines.';

                        trigger OnValidate()
                        var
                            FilterTokens: Codeunit "Filter Tokens";
                        begin
                            FilterTokens.MakeDateFilter(ServiceEndDatePeriodFilter);
                        end;
                    }
                    field(AddVendorServicesCtrl; AddVendorServices)
                    {
                        ApplicationArea = All;
                        Caption = 'Add Vendor Subscription Contract Lines';
#pragma warning disable AA0219                    
                        ToolTip = 'Selecting this Option will also select and add the related Vendor Subscription Contract Lines.';
#pragma warning disable AA0219                    
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        ProcessSelection();
    end;

    local procedure ProcessSelection()
    begin
        CustomerContractFilter.SetLoadFields("No.");
        CustomerContractLineFilter.SetLoadFields("Subscription Contract No.", "Line No.");
        if CustomerContractFilter.FindSet() then
            repeat
                CustomerContractLineFilter.FilterGroup(2);
                CustomerContractLineFilter.SetRange("Subscription Contract No.", CustomerContractFilter."No.");
                CustomerContractLineFilter.FilterGroup(0);
                CustomerContractLineFilter.SetRange("Planned Sub. Line exists", false);
                if CustomerContractLineFilter.FindSet() then
                    repeat
                        InsertFromCustContrLine(CustomerContractLineFilter);
                    until CustomerContractLineFilter.Next() = 0;
            until CustomerContractFilter.Next() = 0;
    end;

    internal procedure InsertFromCustContrLine(var CustomerContractLine: Record "Cust. Sub. Contract Line")
    var
        ServiceCommitment: Record "Subscription Line";
        ContractRenewalLine: Record "Sub. Contract Renewal Line";
        EmptyDateFormula: DateFormula;
    begin
        ServiceCommitment.Reset();
        if ServiceCommitmentFilter.GetFilters() <> '' then
            ServiceCommitment.Copy(ServiceCommitmentFilter);
        ServiceCommitment.FilterGroup(2);
        ServiceCommitment.SetRange("Subscription Contract No.", CustomerContractLine."Subscription Contract No.");
        ServiceCommitment.SetRange("Subscription Contract Line No.", CustomerContractLine."Line No.");
        ServiceCommitment.SetFilter("Subscription Line End Date", '<>%1', 0D);
        if ServiceEndDatePeriodFilter <> '' then
            ServiceCommitment.SetFilter("Subscription Line End Date", ServiceEndDatePeriodFilter);
        if not UseRequestPage() then
            ServiceCommitment.SetFilter("Renewal Term", '<>%1', EmptyDateFormula);
        ServiceCommitment.FilterGroup(0);
        if ServiceCommitment.FindFirst() then begin
            if ContractRenewalLine.InitFromServiceCommitment(ServiceCommitment) then
                ContractRenewalLine.Insert(false);
            if AddVendorServices then
                AddVendorService(ServiceCommitment);
        end;
    end;

    local procedure AddVendorService(ServiceCommitment: Record "Subscription Line")
    var
        ServiceCommitmentVend: Record "Subscription Line";
        ContractRenewalLine: Record "Sub. Contract Renewal Line";
        ContractRenewalMgt: Codeunit "Sub. Contract Renewal Mgt.";
    begin
        if AddVendorServices then begin
            ContractRenewalMgt.FilterServCommVendFromServCommCust(ServiceCommitment, ServiceCommitmentVend);
            if ServiceCommitmentVend.FindSet() then
                repeat
                    if ContractRenewalLine.InitFromServiceCommitment(ServiceCommitmentVend) then begin
                        ContractRenewalLine."Linked to Sub. Line Entry No." := ServiceCommitment."Entry No.";
                        ContractRenewalLine."Linked to Sub. Contract No." := ServiceCommitment."Subscription Contract No.";
                        ContractRenewalLine."Linked to Sub. Contr. Line No." := ServiceCommitment."Subscription Contract Line No.";
                        ContractRenewalLine.Insert(false);
                    end;
                until ServiceCommitmentVend.Next() = 0;
        end;
    end;

    procedure SetAddVendorServices(NewAddVendorServices: Boolean)
    begin
        AddVendorServices := NewAddVendorServices;
    end;

    var
        ServiceEndDatePeriodFilter: Text;
        AddVendorServices: Boolean;
}