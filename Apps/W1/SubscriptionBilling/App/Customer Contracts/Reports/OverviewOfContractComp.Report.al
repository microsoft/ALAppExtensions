namespace Microsoft.SubscriptionBilling;

using System.Utilities;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;

report 8004 "Overview Of Contract Comp"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Overview of contract components';
    WordLayout = './Customer Contracts/Reports/OverviewOfContractComponents.docx';
    DefaultLayout = Word;
    WordMergeDataItem = Customer;


    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = sorting("No.");
            PrintOnlyIfDetail = true;

            dataitem(CustomerContract; "Customer Contract")
            {
                RequestFilterFields = "No.", "Sell-to Customer No.", "Contract Type", "Salesperson Code", "Assigned User ID";
                DataItemLink = "Sell-to Customer No." = field("No.");
                column(Sell_To_Customer_No; "Sell-to Customer No.")
                {
                }
                column(Sell_To_Customer_Name; "Sell-to Customer Name")
                {
                }
                column(Contract_No; "No.")
                {
                }
                column(Description_Preview; "Description Preview")
                {
                }
                column(Contract_Type; ContractTypeDescription)
                {
                }
                column(UserID; UserId())
                {
                }
                column(CompanyName; CompanyName())
                {
                }
                column(Overview_Of_Contract_Components_Lbl; OverviewOfContractComponentsLbl)
                {
                }
                column(Customer_No_Lbl; CustomerNoLbl)
                {
                }
                column(Customer_Name_Lbl; CustomerNameLbl)
                {
                }
                column(Contract_No_Lbl; Service_Commitment.FieldCaption("Contract No."))
                {
                }
                column(Contract_Description_Lbl; CustomerContract.FieldCaption(Description))
                {
                }
                column(Contract_Type_Lbl; CustomerContract.FieldCaption("Contract Type"))
                {
                }
                column(Serv_Obj_Lbl; ServiceObjectNoLbl)
                {
                }
                column(Service_Object_Description_Lbl; Service_Commitment.FieldCaption("Service Object Description"))
                {
                }
                column(Quantity_Lbl; ServiceObjectQuantityLbl)
                {
                }
                column(Description_Lbl; Service_Commitment.FieldCaption(Description))
                {
                }
                column(Serv_Start_Date_Lbl; Service_Commitment.FieldCaption("Service Start Date"))
                {
                }
                column(Serv_End_Date_Lbl; Service_Commitment.FieldCaption("Service End Date"))
                {
                }
                column(Next_Bill_Date_Lbl; Service_Commitment.FieldCaption("Next Billing Date"))
                {
                }
                column(Price_Lbl; Service_Commitment.FieldCaption(Price))
                {
                }
                column(Disc_Pctg_Lbl; Service_Commitment.FieldCaption("Discount %"))
                {
                }
                column(Serv_Amt_Lbl; Service_Commitment.FieldCaption("Service Amount"))
                {
                }
                column(Unique_Att_Lbl; UniqueAttributeLbl)
                {
                }
                column(CompanyPicture; CompanyInformation.Picture)
                {

                }
                dataitem(Service_Commitment; "Service Commitment")
                {
                    RequestFilterFields = "Service Start Date", "Service End Date", "Cancellation Possible Until", "Term Until";
                    DataItemLink = "Contract No." = field("No.");
                    DataItemTableView = where(Partner = filter("Service Partner"::Customer));
                    column(Service_Object_No; "Service Object No.")
                    {
                    }
                    column(Service_Object_Description; "Service Object Description")
                    {
                    }
                    column(Service_Object_Quantity; CustomerContractLine."Service Obj. Quantity Decimal")
                    {
                    }
                    column(Description; Description)
                    {
                    }
                    column(Service_Start_Date; Format("Service Start Date", 0, 1))
                    {
                    }
                    column(Service_End_Date; Format("Service End Date", 0, 1))
                    {
                    }
                    column(Next_Billing_Date; Format("Next Billing Date", 0, 1))
                    {
                    }
                    column(Price; Price)
                    {
                    }
                    column(Discount_Pctg; "Discount %")
                    {
                    }
                    column(Service_Amount; "Service Amount")
                    {
                    }
                    column(Unique_Attribute; ServiceObject.GetPrimaryAttributeValue())
                    {
                    }
                    column(Date_Value; System.Today())
                    {
                    }
                    dataitem(SerialNoCustomerReferenceLine; "Integer")
                    {
                        DataItemTableView = sorting(Number) where(Number = const(1));
                        column(Customer_Reference; CustomerReferenceValue)
                        {
                        }
                        column(Serial_No; SerialNoValue)
                        {
                        }
                        column(Customer_Reference_Lbl; CustomerReferenceLbl)
                        {
                        }
                        column(Serial_No_Lbl; SerialNoLbl)
                        {
                        }
                        trigger OnAfterGetRecord()
                        begin
                            if (ServiceObject."Customer Reference" = '') and (ServiceObject."Serial No." = '') then
                                CurrReport.Break();

                            SetCustomerReference(ServiceObject."Customer Reference", ServiceObject."Customer Reference" <> '');
                            SetSerialNo(ServiceObject."Serial No.", ServiceObject."Serial No." <> '');
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        ServiceObject.Get(Service_Commitment."Service Object No.");

                        CustomerContractLine.Get(Service_Commitment."Contract No.", Service_Commitment."Contract Line No.");
                        CustomerContractLine.CalcFields("Service Obj. Quantity Decimal");
                        if not ShowClosedContractLines then
                            if CustomerContractLine.Closed then
                                CurrReport.Skip();
                    end;

                }

                trigger OnPreDataItem()
                begin
                    if not IncludeInactiveCustomerContracts then
                        CustomerContract.SetRange(Active, true);
                end;

                trigger OnAfterGetRecord()
                var
                    ServiceCommitment: Record "Service Commitment";
                begin
                    ServiceCommitment.SetRange("Contract No.", CustomerContract."No.");
                    if ServiceCommitment.IsEmpty() then
                        CurrReport.Skip();

                    ContractTypeDescription := ContractType.GetDescription(CustomerContract."Contract Type");
                end;
            }
            trigger OnAfterGetRecord()
            var
                CustomerContract: Record "Customer Contract";
            begin
                CustomerContract.SetRange("Sell-to Customer No.", Customer."No.");
                if CustomerContract.IsEmpty() then
                    CurrReport.Skip();
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
                    field("Show closed contract lines"; ShowClosedContractLines)
                    {
                        Caption = 'Show closed contract lines';
                        ToolTip = 'Specifies if you want the report to include already closed contract lines.';
                        ApplicationArea = All;

                    }
                    field("Include Inactive contracts"; IncludeInactiveCustomerContracts)
                    {
                        ApplicationArea = All;
                        Caption = 'Include Inactive contracts';
                        ToolTip = 'Specifies if you want to include Inactive contracts in the report.';
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
    end;

    var
        CustomerContractLine: Record "Customer Contract Line";
        ServiceObject: Record "Service Object";
        ContractType: Record "Contract Type";
        CompanyInformation: Record "Company Information";
        CustomerReferenceValue: Text;
        SerialNoValue: Text;
        CustomerReferenceLbl: Text;
        SerialNoLbl: Text;
        ShowClosedContractLines: Boolean;
        IncludeInactiveCustomerContracts: Boolean;
        ContractTypeDescription: Text[50];
        CustomerNoLbl: Label 'Customer No.';
        CustomerNameLbl: Label 'Customer Name';
        ServiceObjectQuantityLbl: Label 'Quantity';
        OverviewOfContractComponentsLbl: Label 'Overview of Contract Components';
        UniqueAttributeLbl: Label 'Unique Attribute';
        ServiceObjectNoLbl: Label 'Service Object';

    internal procedure SetIncludeInactiveCustomerContracts(NewIncludeInactiveCustomerContracts: Boolean)
    begin
        IncludeInactiveCustomerContracts := NewIncludeInactiveCustomerContracts;
    end;

    local procedure SetCustomerReference(NewCustomerReferece: Text[250]; AssignCustomerReferenceLbl: Boolean)
    begin
        if not AssignCustomerReferenceLbl then
            CustomerReferenceLbl := ''
        else
            CustomerReferenceLbl := ServiceObject.FieldCaption("Customer Reference");

        CustomerReferenceValue := NewCustomerReferece;
    end;

    local procedure SetSerialNo(NewSerialNo: Text[250]; AssignSerialNoLbl: Boolean)
    begin
        if not AssignSerialNoLbl then
            SerialNoLbl := ''
        else
            SerialNoLbl := ServiceObject.FieldCaption("Serial No.");
        SerialNoValue := NewSerialNo;
    end;
}