namespace Microsoft.SubscriptionBilling;

using System.Text;

report 8000 "Select Contract Renewal"
{
    Caption = 'Select Services for Contract Renewal';
    ProcessingOnly = true;
    UsageCategory = None;

    dataset
    {
        dataitem(CustomerContractFilter; "Customer Contract")
        {
            RequestFilterFields = "No.", "Contract Type";

            trigger OnPreDataItem()
            begin
                CurrReport.Break();
            end;
        }
        dataitem(CustomerContractLineFilter; "Customer Contract Line")
        {
            DataItemTableView = sorting("Contract No.") where(Closed = const(false));

            trigger OnPreDataItem()
            begin
                CurrReport.Break();
            end;
        }
        dataitem(ServiceCommitmentFilter; "Service Commitment")
        {
            RequestFilterFields = "Service Object No.", "Service Start Date";

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
                        Caption = 'Service End Date Period';
                        ToolTip = 'This Date Filter is used to select then Contract Lines based on the Service End Date of the Service Commitments.';

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
                        Caption = 'Add Vendor Contract Lines';
                        ToolTip = 'Selecting this Option will also select and add the related Vendor Contract Lines.';
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
        CustomerContractLineFilter.SetLoadFields("Contract No.", "Line No.");
        if CustomerContractFilter.FindSet() then
            repeat
                CustomerContractLineFilter.FilterGroup(2);
                CustomerContractLineFilter.SetRange("Contract No.", CustomerContractFilter."No.");
                CustomerContractLineFilter.FilterGroup(0);
                CustomerContractLineFilter.SetRange("Planned Serv. Comm. exists", false);
                if CustomerContractLineFilter.FindSet() then
                    repeat
                        InsertFromCustContrLine(CustomerContractLineFilter);
                    until CustomerContractLineFilter.Next() = 0;
            until CustomerContractFilter.Next() = 0;
        Processed := true;
    end;

    internal procedure InsertFromCustContrLine(var CustomerContractLine: Record "Customer Contract Line")
    var
        ServiceCommitment: Record "Service Commitment";
        ContractRenewalLine: Record "Contract Renewal Line";
        EmptyDateFormula: DateFormula;
    begin
        ServiceCommitment.Reset();
        if ServiceCommitmentFilter.GetFilters() <> '' then
            ServiceCommitment.Copy(ServiceCommitmentFilter);
        ServiceCommitment.FilterGroup(2);
        ServiceCommitment.SetRange("Contract No.", CustomerContractLine."Contract No.");
        ServiceCommitment.SetRange("Contract Line No.", CustomerContractLine."Line No.");
        ServiceCommitment.SetFilter("Service End Date", '<>%1', 0D);
        if ServiceEndDatePeriodFilter <> '' then
            ServiceCommitment.SetFilter("Service End Date", ServiceEndDatePeriodFilter);
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

    local procedure AddVendorService(ServiceCommitment: Record "Service Commitment")
    var
        ServiceCommitmentVend: Record "Service Commitment";
        ContractRenewalLine: Record "Contract Renewal Line";
        ContractRenewalMgt: Codeunit "Contract Renewal Mgt.";
    begin
        if AddVendorServices then begin
            ContractRenewalMgt.FilterServCommVendFromServCommCust(ServiceCommitment, ServiceCommitmentVend);
            if ServiceCommitmentVend.FindSet() then
                repeat
                    if ContractRenewalLine.InitFromServiceCommitment(ServiceCommitmentVend) then begin
                        ContractRenewalLine."Linked to Ser. Comm. Entry No." := ServiceCommitment."Entry No.";
                        ContractRenewalLine."Linked to Contract No." := ServiceCommitment."Contract No.";
                        ContractRenewalLine."Linked to Contract Line No." := ServiceCommitment."Contract Line No.";
                        ContractRenewalLine.Insert(false);
                    end;
                until ServiceCommitmentVend.Next() = 0;
        end;
    end;

    internal procedure GetProcessed(): Boolean
    begin
        exit(Processed);
    end;

    procedure SetAddVendorServices(NewAddVendorServices: Boolean)
    begin
        AddVendorServices := NewAddVendorServices;
    end;

    var
        ServiceEndDatePeriodFilter: Text;
        AddVendorServices: Boolean;
        Processed: Boolean;
}