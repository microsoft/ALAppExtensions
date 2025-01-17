namespace Microsoft.SubscriptionBilling;

using System.Text;
using Microsoft.Purchases.Vendor;

report 8053 "Vend Contr. Def. Analysis"
{
    Caption = 'Vendor Contract Deferrals Analysis';
    DefaultRenderingLayout = "VendContrDefAnalysis.xlsx";
    ExcelLayoutMultipleDataSheets = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem(VendorContract; "Vendor Contract")
        {
            DataItemTableView = sorting("No.");

            column(ContractNo; "No.") { IncludeCaption = true; }
            column(PaytoVendorNo; "Pay-to Vendor No.") { IncludeCaption = true; }
            column(PayToName; "Pay-to Name") { IncludeCaption = true; }
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
                if not VendorContrDeferralsExist("No.") then
                    CurrReport.Skip();

                CalculatePeriodValues("No.");
            end;

            trigger OnPreDataItem()
            begin
                if ContractNoFilter <> '' then
                    VendorContract.SetFilter("No.", ContractNoFilter);
                if VendorNoFilter <> '' then
                    VendorContract.SetFilter("Pay-to Vendor No.", VendorNoFilter);
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
                    field(VendorNo; VendorNoFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Vendor No.';
                        ToolTip = 'Specifies Vendors to Analyse.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            Vendor: Record Vendor;
                        begin
                            if Page.RunModal(0, Vendor) = Action::LookupOK then begin
                                Text += Vendor."No.";
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
        layout("VendContrDefAnalysis.xlsx")
        {
            Type = Excel;
            LayoutFile = './Deferrals/Reports/VendContrDefAnalysis.xlsx';
            Caption = 'Vendor Contract Deferrals Analysis (Excel)';
            Summary = 'The Vendor Contract Deferrals Analysis (Excel) provides an excel layout that is relatively easy for an end-user to modify. Report uses Query connections';
        }
    }
    labels
    {
        ContractDeferralsLbl = 'Vendor Contract Deferrals';
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
        VendorNoFilter: Text;
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

    local procedure VendorContrDeferralsExist(SourceContractNo: Code[20]): Boolean
    var
        VendorContractDeferral: Record "Vendor Contract Deferral";
    begin
        SetContractDeferralFilter(VendorContractDeferral, SourceContractNo);
        if DocPostDateFilter <> '' then begin
            VendorContractDeferral.SetFilter("Document Posting Date", DocPostDateFilter);
            if not VendorContractDeferral.FindFirst() then begin
                VendorContractDeferral.SetRange("Document Posting Date");
                VendorContractDeferral.SetFilter("Posting Date", '<%1', EndDate);
            end;
        end;
        exit(not VendorContractDeferral.IsEmpty());
    end;

    local procedure CalculatePeriodValues(SourceContractNo: Code[20])
    var
        VendorContractDeferral: Record "Vendor Contract Deferral";
    begin
        BalanceBroughtForward := 0;
        InvoicedInPeriod := 0;
        ReleasedInPeriod := 0;
        ReleasedUntil := 0D;
        ToReleaseInPeriod := 0;
        ToReleaseAfterPeriod := 0;
        DateLastRelease := 0D;

        VendorContractDeferral.Reset();
        SetContractDeferralFilter(VendorContractDeferral, SourceContractNo);

        CalculateBalanceBroughtForward(VendorContractDeferral);
        CalculateInvoicedInPeriod(VendorContractDeferral);

        CalculateReleasedInPeriod(VendorContractDeferral);
        GetReleasedUntil(VendorContractDeferral);

        CalculateToReleasedInPeriod(VendorContractDeferral);
        CalculateToReleaseAfterPeriod(VendorContractDeferral);
        GetDateOfLastRelease(VendorContractDeferral);
    end;

    local procedure SetContractDeferralFilter(var VendorContractDeferral: Record "Vendor Contract Deferral"; SourceContractNo: Code[20])
    begin
        VendorContractDeferral.SetRange("Contract No.", SourceContractNo);
        VendorContractDeferral.SetFilter("Document Type", Format(DocumentTypeFilter));
        VendorContractDeferral.SetFilter("Document No.", DocumentNoFilter);
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
        VendorContractDeferral: Record "Vendor Contract Deferral";
    begin
        VendorContractDeferral.Reset();
        VendorContractDeferral.SetFilter("Posting Date", DocPostDateFilter);
        StartDate := VendorContractDeferral.GetRangeMin("Posting Date");
        EndDate := VendorContractDeferral.GetRangeMax("Posting Date");
        if (StartDate = 0D) or (StartDate = EndDate) then
            Error(PeriodEvaluationErrorLbl);
        if EndDate < StartDate then
            Error(StartEndDateEvalErrorLbl);
        VendorContractDeferral.SetRange("Posting Date");
    end;

    local procedure ResetPostingDateFilters(var VendorContractDeferral: Record "Vendor Contract Deferral")
    begin
        VendorContractDeferral.SetRange("Release Posting Date");
        VendorContractDeferral.SetRange("Document Posting Date");
        VendorContractDeferral.SetRange("Posting Date");
    end;

    local procedure CalculateBalanceBroughtForward(var VendorContractDeferral: Record "Vendor Contract Deferral")
    begin
        VendorContractDeferral.SetFilter("Document Posting Date", '<%1', StartDate);
        VendorContractDeferral.SetFilter("Release Posting Date", ''''' | >=%1', StartDate);
        VendorContractDeferral.CalcSums("Amount");
        BalanceBroughtForward := VendorContractDeferral."Amount";
    end;

    local procedure CalculateInvoicedInPeriod(var VendorContractDeferral: Record "Vendor Contract Deferral")
    begin
        ResetPostingDateFilters(VendorContractDeferral);
        VendorContractDeferral.SetFilter("Document Posting Date", DocPostDateFilter);
        VendorContractDeferral.CalcSums("Amount");
        InvoicedInPeriod := VendorContractDeferral."Amount";
    end;

    local procedure CalculateReleasedInPeriod(var VendorContractDeferral: Record "Vendor Contract Deferral")
    begin
        ResetPostingDateFilters(VendorContractDeferral);
        VendorContractDeferral.SetFilter("Release Posting Date", DocPostDateFilter);
        VendorContractDeferral.CalcSums("Amount");
        ReleasedInPeriod := VendorContractDeferral."Amount";
    end;

    local procedure GetReleasedUntil(var VendorContractDeferral: Record "Vendor Contract Deferral")
    begin
        if VendorContractDeferral.FindLast() then
            ReleasedUntil := VendorContractDeferral."Release Posting Date";
    end;

    local procedure CalculateToReleasedInPeriod(var VendorContractDeferral: Record "Vendor Contract Deferral")
    begin
        ResetPostingDateFilters(VendorContractDeferral);
        VendorContractDeferral.SetFilter("Posting Date", '<=%1', EndDate);
        VendorContractDeferral.SetRange("Release Posting Date", 0D);
        VendorContractDeferral.CalcSums(Amount);
        ToReleaseInPeriod := VendorContractDeferral.Amount;
    end;

    local procedure CalculateToReleaseAfterPeriod(var VendorContractDeferral: Record "Vendor Contract Deferral")
    begin
        ResetPostingDateFilters(VendorContractDeferral);
        VendorContractDeferral.SetFilter("Posting Date", '>%1', EndDate);
        VendorContractDeferral.SetFilter("Release Posting Date", ''''' | >%1', EndDate);
        VendorContractDeferral.CalcSums(Amount);
        ToReleaseAfterPeriod := VendorContractDeferral.Amount;
        VendorContractDeferral.SetFilter("Posting Date", DocPostDateFilter);
        VendorContractDeferral.SetFilter("Release Posting Date", '>%1', EndDate);
        VendorContractDeferral.CalcSums(Amount);
        ToReleaseAfterPeriod := ToReleaseAfterPeriod + VendorContractDeferral.Amount;
    end;

    local procedure GetDateOfLastRelease(var VendorContractDeferral: Record "Vendor Contract Deferral")
    begin
        ResetPostingDateFilters(VendorContractDeferral);
        if VendorContractDeferral.FindLast() then
            DateLastRelease := VendorContractDeferral."Posting Date";
    end;
}
