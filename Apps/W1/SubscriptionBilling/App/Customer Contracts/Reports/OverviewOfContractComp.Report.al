namespace Microsoft.SubscriptionBilling;

report 8004 "Overview Of Contract Comp"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Overview of contract components';
    DefaultRenderingLayout = "OverviewOfContractComponents.xlsx";
    ExcelLayoutMultipleDataSheets = true;

    dataset
    {

        dataitem(CustomerContract; "Customer Contract")
        {
            RequestFilterFields = "No.", "Sell-to Customer No.", "Contract Type", "Salesperson Code", "Assigned User ID";
            PrintOnlyIfDetail = true;
            column(SellToCustomerNo; "Sell-to Customer No.") { }
            column(SellToCustomerName; "Sell-to Customer Name") { }
            column(ContractNo; "No.") { }
            column(ContractDescription; "Description Preview") { }
            column(ContractType; ContractType.GetDescription("Contract Type")) { }
            dataitem(ServiceCommitment; "Service Commitment")
            {
                RequestFilterFields = "Service Start Date", "Service End Date", "Cancellation Possible Until", "Term Until";
                DataItemLink = "Contract No." = field("No.");
                DataItemTableView = where(Partner = filter("Service Partner"::Customer));
                column(ServiceObjectNo; "Service Object No.") { IncludeCaption = true; }
                column(ServiceObjectDescription; "Service Object Description") { IncludeCaption = true; }
                column(UniqueAttribute; ServiceObject.GetPrimaryAttributeValue()) { }
                column(ServiceCommitmentDescription; Description) { }
                column(ServiceStartDate; "Service Start Date") { IncludeCaption = true; }
                column(ServiceEndDate; "Service End Date") { IncludeCaption = true; }
                column(NextBillingDate; "Next Billing Date") { IncludeCaption = true; }
                column(CustomerReference; ServiceObject."Customer Reference") { IncludeCaption = true; }
                column(SerialNo; ServiceObject."Serial No.") { IncludeCaption = true; }
                column(Quantity; "Quantity Decimal") { IncludeCaption = true; }
                column(Price; Price) { IncludeCaption = true; }
                column(DiscountPct; "Discount %") { IncludeCaption = true; }
                column(ServiceAmount; "Service Amount") { IncludeCaption = true; }

                trigger OnPreDataItem()
                begin
                    if not ShowClosedContractLines then
                        SetRange(Closed, false);
                end;

                trigger OnAfterGetRecord()
                begin
                    if not ServiceObject.Get("Service Object No.") then
                        Clear(ServiceObject);
                end;
            }
            trigger OnPreDataItem()
            begin
                if not IncludeInactiveCustomerContracts then
                    CustomerContract.SetRange(Active, true);
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
    rendering
    {
        layout("OverviewOfContractComponents.xlsx")
        {
            Type = Excel;
            LayoutFile = './Customer Contracts/Reports/OverviewOfContractComponents.xlsx';
            Caption = 'Overview of contract components (Excel)';
            Summary = 'The Overview of contract components (Excel) provides an excel layout that is relatively easy for an end-user to modify. Report uses Query connections';
        }
    }
    labels
    {
        CustomerNoLbl = 'Customer No.';
        CustomerNameLbl = 'Customer Name';
        ContractNoLbl = 'Contract No.';
        ContractTypeLbl = 'Contract Type';
        ContractDescriptionLbl = 'Contract Description';
        ServiceCommitmentDescriptionLbl = 'Service Commitment Description';
        OverviewOfContractComponents = 'Overview of Contract Components';
        ContractComponents = 'Contract Components';
        UniqueAttributeLbl = 'Unique Attribute';
        CustomerReferenceLbl = 'Customer Reference';
        SerialNoLbl = 'Serial No.';
        DataRetrieved = 'Data retrieved:';
    }

    var
        ContractType: Record "Contract Type";
        ServiceObject: Record "Service Object";
        ShowClosedContractLines: Boolean;
        IncludeInactiveCustomerContracts: Boolean;

    internal procedure SetIncludeInactiveCustomerContracts(NewIncludeInactiveCustomerContracts: Boolean)
    begin
        IncludeInactiveCustomerContracts := NewIncludeInactiveCustomerContracts;
    end;
}