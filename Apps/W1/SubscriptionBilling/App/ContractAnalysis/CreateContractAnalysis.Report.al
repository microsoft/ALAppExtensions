report 8005 "Create Contract Analysis"
{
    ApplicationArea = All;
    Caption = 'Create Contract Analysis Entries';
    UsageCategory = Tasks;
    ProcessingOnly = true;
    UseRequestPage = false;

    dataset
    {
        dataitem(ServiceCommitment; "Service Commitment")
        {
            DataItemTableView = sorting("Contract No.", "Contract Line No.");

            trigger OnPreDataItem()
            begin
                SetFilter("Contract No.", '<>%1', '');
                SetFilter("Service End Date", '%1|>=%2', 0D, Today());
            end;

            trigger OnAfterGetRecord()
            begin
                if ContractAnalysisEntryExist() then
                    CurrReport.Skip();

                CreateContractAnalysisEntry();
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
            }
        }
        actions
        {
            area(Processing)
            {
            }
        }
    }

    local procedure ContractAnalysisEntryExist(): Boolean
    var
        ContractAnalysisEntry: Record "Contract Analysis Entry";
    begin
        ContractAnalysisEntry.SetRange("Service Object No.", ServiceCommitment."Service Object No.");
        ContractAnalysisEntry.SetRange("Service Commitment Entry No.", ServiceCommitment."Entry No.");
        ContractAnalysisEntry.SetRange("Analysis Date", CalcDate('<-CM>', Today()), CalcDate('<CM>', Today()));
        exit(not ContractAnalysisEntry.IsEmpty());
    end;

    local procedure CreateContractAnalysisEntry()
    var
        ContractAnalysisEntry: Record "Contract Analysis Entry";
    begin
        ContractAnalysisEntry.InitFromServiceCommitment(ServiceCommitment);
        ContractAnalysisEntry."Analysis Date" := Today();
        ContractAnalysisEntry.CalculateMonthlyRecurringRevenue(ServiceCommitment);
        ContractAnalysisEntry.CalculateMonthlyRecurringCost(ServiceCommitment);
        ContractAnalysisEntry.Insert(true);
    end;
}
