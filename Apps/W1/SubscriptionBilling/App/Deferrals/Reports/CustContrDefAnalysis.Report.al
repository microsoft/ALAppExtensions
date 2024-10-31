namespace Microsoft.SubscriptionBilling;

using System.Text;
using Microsoft.Sales.Customer;

report 8052 "Cust. Contr. Def. Analysis"
{
    Caption = 'Customer Contract Deferrals Analysis';
    DefaultRenderingLayout = "CustContrDefAnalysis.xlsx";
    ExcelLayoutMultipleDataSheets = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem(CustomerContract; "Customer Contract")
        {
            DataItemTableView = sorting("No.");

            column(ContractNo; "No.") { IncludeCaption = true; }
            column(BillToCustomerNo; "Bill-to Customer No.") { IncludeCaption = true; }
            column(BillToName; "Bill-to Name") { IncludeCaption = true; }
            column(BalanceBroughtForward; BalanceBroughtForward) { }
            column(InvoicedInPeriod; InvoicedInPeriod) { }
            column(ReleasedInPeriod; ReleasedInPeriod) { }
            column(DeadlineValue; BalanceBroughtForward + InvoicedInPeriod - ReleasedInPeriod) { }
            column(ReleasedUntil; ReleasedUntil) { }
            column(ToReleaseInPeriod; ToReleaseInPeriod) { }
            column(BalanceAfterPeriod; ToReleaseAfterPeriod) { }
            column(DateLastRelease; DateLastRelease) { }

            trigger OnAfterGetRecord()
            begin
                if not CustomerContractDeferralsExist("No.") then
                    CurrReport.Skip();

                CalculatePeriodValues("No.");
            end;

            trigger OnPreDataItem()
            begin
                if ContractNoFilter <> '' then
                    CustomerContract.SetFilter("No.", ContractNoFilter);
                if CustomerNoFilter <> '' then
                    CustomerContract.SetFilter("Bill-to Customer No.", CustomerNoFilter);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(EvaluationPeriod; DocPostDateFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Evaluation Period';
                        ToolTip = 'Document Posting Date filter in the form of ''Date1..Date2''.';
                        ShowMandatory = true;

                        trigger OnValidate()
                        begin
                            SetPeriodFilter();
                        end;
                    }
                    field(ContractNo; ContractNoFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Contract No.';
                        ToolTip = 'Specifies Contracts to Analyse.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            CustomerContract: Record "Customer Contract";
                        begin
                            if Page.RunModal(0, CustomerContract) = Action::LookupOK then begin
                                Text += CustomerContract."No.";
                                exit(true);
                            end;
                        end;
                    }
                    field(CustomerNo; CustomerNoFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Customer No.';
                        ToolTip = 'Specifies Customers to Analyse.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            Customer: Record Customer;
                        begin
                            if Page.RunModal(0, Customer) = Action::LookupOK then begin
                                Text += Customer."No.";
                                exit(true);
                            end;
                        end;
                    }
                    field(DocumentType; DocumentTypeFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Document Type';
                        ToolTip = 'Specifies Document Type to Analyse.';
                    }
                    field(DocumentNo; DocumentNoFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies Documents to Analyse.';
                    }
                }
            }
        }

        trigger OnInit()
        begin
            DocPostDateFilter := 'Y';
            SetPeriodFilter();
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            if CloseAction <> Action::Cancel then
                SetPeriodFilter();
        end;
    }
    rendering
    {
        layout("CustContrDefAnalysis.xlsx")
        {
            Type = Excel;
            LayoutFile = './Deferrals/Reports/CustContrDefAnalysis.xlsx';
            Caption = 'Customer Contract Deferrals Analysis (Excel)';
            Summary = 'The Customer Contract Deferrals Analysis (Excel) provides an excel layout that is relatively easy for an end-user to modify. Report uses Query connections';
        }
    }
    labels
    {
        ContractDeferralsLbl = 'Customer Contract Deferrals';
        DeferralsLbl = 'Deferrals';
        EvaluationPeriodLbl = 'Evaluation Period';
        BalanceBroughtForwardLbl = 'Balance Brought Forward';
        InvoicedInPeriodLbl = 'Invoiced in Period';
        ReleasedInPeriodLbl = 'Released In Period';
        DeadlineValueLbl = 'Deadline Value';
        ReleasedUntilLbl = 'Released until';
        ToReleaseInPeriodLbl = 'To release in Period';
        BalanceAfterPeriodLbl = 'Balance after Period';
        DateLastReleaseLbl = 'Date last Release';
        DataRetrieved = 'Data retrieved:';
    }
    var
        ContractNoFilter: Text;
        CustomerNoFilter: Text;
        DocumentTypeFilter: Enum "Rec. Billing Document Type";
        DocumentNoFilter: Text;
        DocPostDateFilter: Text;
        StartDate: Date;
        EndDate: Date;
        BalanceBroughtForward: Decimal;
        InvoicedInPeriod: Decimal;
        ReleasedInPeriod: Decimal;
        ToReleaseAfterPeriod: Decimal;
        ReleasedUntil: Date;
        ToReleaseInPeriod: Decimal;
        DateLastRelease: Date;
        PeriodEvaluationErrorLbl: Label 'Please enter a valid evaluation period in the form ''Date1..Date2''.';
        StartEndDateEvalErrorLbl: Label 'Ending Date must be greater than Starting Date.';

    local procedure CustomerContractDeferralsExist(SourceContractNo: Code[20]): Boolean
    var
        CustomerContractDeferral: Record "Customer Contract Deferral";
    begin
        SetContractDeferralFilter(CustomerContractDeferral, SourceContractNo);
        if DocPostDateFilter <> '' then begin
            CustomerContractDeferral.SetFilter("Document Posting Date", DocPostDateFilter);
            if not CustomerContractDeferral.FindFirst() then begin
                CustomerContractDeferral.SetRange("Document Posting Date");
                CustomerContractDeferral.SetFilter("Posting Date", '<%1', EndDate);
            end;
        end;
        exit(not CustomerContractDeferral.IsEmpty());
    end;

    local procedure CalculatePeriodValues(SourceContractNo: Code[20])
    var
        CustomerContractDeferral: Record "Customer Contract Deferral";
    begin
        BalanceBroughtForward := 0;
        InvoicedInPeriod := 0;
        ReleasedInPeriod := 0;
        ReleasedUntil := 0D;
        ToReleaseInPeriod := 0;
        ToReleaseAfterPeriod := 0;
        DateLastRelease := 0D;

        CustomerContractDeferral.Reset();
        SetContractDeferralFilter(CustomerContractDeferral, SourceContractNo);

        CalculateBalanceBroughtForward(CustomerContractDeferral);
        CalculateInvoicedInPeriod(CustomerContractDeferral);

        CalculateReleasedInPeriod(CustomerContractDeferral);
        GetReleasedUntil(CustomerContractDeferral);

        CalculateToReleaseInPeriod(CustomerContractDeferral);
        CalculateToReleaseAfterPeriod(CustomerContractDeferral);
        GetDateOfLastRelease(CustomerContractDeferral);
    end;

    local procedure SetContractDeferralFilter(var CustomerContractDeferral: Record "Customer Contract Deferral"; SourceContractNo: Code[20])
    begin
        CustomerContractDeferral.SetRange("Contract No.", SourceContractNo);
        CustomerContractDeferral.SetFilter("Document Type", Format(DocumentTypeFilter));
        CustomerContractDeferral.SetFilter("Document No.", DocumentNoFilter);
    end;

    local procedure SetPeriodFilter()
    var
        FilterTokens: Codeunit "Filter Tokens";
    begin
        FilterTokens.MakeDateFilter(DocPostDateFilter);
        if (DocPostDateFilter <> '') then
            TestDocumentPostingDateFilter()
        else
            Error(PeriodEvaluationErrorLbl);
    end;

    local procedure TestDocumentPostingDateFilter()
    var
        CustomerContractDeferral: Record "Customer Contract Deferral";
    begin
        CustomerContractDeferral.Reset();
        CustomerContractDeferral.SetFilter("Posting Date", DocPostDateFilter);
        StartDate := CustomerContractDeferral.GetRangeMin("Posting Date");
        EndDate := CustomerContractDeferral.GetRangeMax("Posting Date");
        if (StartDate = 0D) or (StartDate = EndDate) then
            Error(PeriodEvaluationErrorLbl);
        if EndDate < StartDate then
            Error(StartEndDateEvalErrorLbl);
        CustomerContractDeferral.SetRange("Posting Date");
    end;

    local procedure ResetPostingDateFilters(var CustomerContractDeferral: Record "Customer Contract Deferral")
    begin
        CustomerContractDeferral.SetRange("Release Posting Date");
        CustomerContractDeferral.SetRange("Document Posting Date");
        CustomerContractDeferral.SetRange("Posting Date");
    end;

    local procedure CalculateBalanceBroughtForward(var CustomerContractDeferral: Record "Customer Contract Deferral")
    begin
        CustomerContractDeferral.SetFilter("Document Posting Date", '<%1', StartDate);
        CustomerContractDeferral.SetFilter("Release Posting Date", ''''' | >=%1', StartDate);
        CustomerContractDeferral.CalcSums("Amount");
        BalanceBroughtForward := CustomerContractDeferral."Amount";
    end;

    local procedure CalculateInvoicedInPeriod(var CustomerContractDeferral: Record "Customer Contract Deferral")
    begin
        ResetPostingDateFilters(CustomerContractDeferral);
        CustomerContractDeferral.SetFilter("Document Posting Date", DocPostDateFilter);
        CustomerContractDeferral.CalcSums("Amount");
        InvoicedInPeriod := CustomerContractDeferral."Amount";
    end;

    local procedure CalculateReleasedInPeriod(var CustomerContractDeferral: Record "Customer Contract Deferral")
    begin
        ResetPostingDateFilters(CustomerContractDeferral);
        CustomerContractDeferral.SetFilter("Release Posting Date", DocPostDateFilter);
        CustomerContractDeferral.CalcSums("Amount");
        ReleasedInPeriod := CustomerContractDeferral."Amount";
    end;

    local procedure GetReleasedUntil(var CustomerContractDeferral: Record "Customer Contract Deferral")
    begin
        if CustomerContractDeferral.FindLast() then
            ReleasedUntil := CustomerContractDeferral."Release Posting Date";
    end;

    local procedure CalculateToReleaseInPeriod(var CustomerContractDeferral: Record "Customer Contract Deferral")
    begin
        ResetPostingDateFilters(CustomerContractDeferral);
        CustomerContractDeferral.SetFilter("Posting Date", '<=%1', EndDate);
        CustomerContractDeferral.SetRange("Release Posting Date", 0D);
        CustomerContractDeferral.CalcSums(Amount);
        ToReleaseInPeriod := CustomerContractDeferral.Amount;
    end;

    local procedure CalculateToReleaseAfterPeriod(var CustomerContractDeferral: Record "Customer Contract Deferral")
    begin
        ResetPostingDateFilters(CustomerContractDeferral);
        CustomerContractDeferral.SetFilter("Posting Date", '>%1', EndDate);
        CustomerContractDeferral.SetFilter("Release Posting Date", ''''' | >%1', EndDate);
        CustomerContractDeferral.CalcSums(Amount);
        ToReleaseAfterPeriod := CustomerContractDeferral.Amount;
        CustomerContractDeferral.SetFilter("Posting Date", DocPostDateFilter);
        CustomerContractDeferral.SetFilter("Release Posting Date", '>%1', EndDate);
        CustomerContractDeferral.CalcSums(Amount);
        ToReleaseAfterPeriod := ToReleaseAfterPeriod + CustomerContractDeferral.Amount;
    end;

    local procedure GetDateOfLastRelease(var CustomerContractDeferral: Record "Customer Contract Deferral")
    begin
        ResetPostingDateFilters(CustomerContractDeferral);
        if CustomerContractDeferral.FindLast() then
            DateLastRelease := CustomerContractDeferral."Posting Date";
    end;
}
