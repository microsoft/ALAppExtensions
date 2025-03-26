#pragma warning disable AA0247
report 8005 "Create Contract Analysis"
{
    ApplicationArea = All;
    Caption = 'Create Subscription Contract Analysis';
    UsageCategory = Tasks;
    ProcessingOnly = true;
    UseRequestPage = false;

    dataset
    {
        dataitem(ServiceCommitment; "Subscription Line")
        {
            DataItemTableView = sorting("Subscription Contract No.", "Subscription Contract Line No.");

            trigger OnPreDataItem()
            begin
                SetFilter("Subscription Contract No.", '<>%1', '');
                SetFilter("Subscription Line End Date", '%1|>=%2', 0D, Today());
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
        ContractAnalysisEntry: Record "Sub. Contr. Analysis Entry";
    begin
        ContractAnalysisEntry.SetRange("Subscription Header No.", ServiceCommitment."Subscription Header No.");
        ContractAnalysisEntry.SetRange("Subscription Line Entry No.", ServiceCommitment."Entry No.");
        ContractAnalysisEntry.SetRange("Analysis Date", CalcDate('<-CM>', Today()), CalcDate('<CM>', Today()));
        exit(not ContractAnalysisEntry.IsEmpty());
    end;

    local procedure CreateContractAnalysisEntry()
    var
        ContractAnalysisEntry: Record "Sub. Contr. Analysis Entry";
    begin
        ContractAnalysisEntry.InitFromServiceCommitment(ServiceCommitment);
        ContractAnalysisEntry."Analysis Date" := Today();
        ContractAnalysisEntry.CalculateMonthlyRecurringRevenue(ServiceCommitment);
        ContractAnalysisEntry.CalculateMonthlyRecurringCost(ServiceCommitment);
        ContractAnalysisEntry.Insert(true);
    end;
}
