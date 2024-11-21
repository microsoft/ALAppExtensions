namespace Microsoft.Finance.Latepayment;

codeunit 1958 "Late Payment Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany();
    begin
        FillLastPostingDateFromExactInvoiceCount();
    end;

    trigger OnUpgradePerDatabase();
    begin
    end;

    local procedure FillLastPostingDateFromExactInvoiceCount();
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        LPFeatureTableHelper: Codeunit "LP Feature Table Helper";
        LppSalesInvoiceHeaderInput: Query "LPP Sales Invoice Header Input";
    begin
        if not LPMachineLearningSetup.Get() then // never been initialized
            exit;
        if LPMachineLearningSetup."Posting Date OnLastML" <> 0D then // already trained with the last posting date
            exit;
        LPFeatureTableHelper.SetFiltersOnSalesInvoiceHeaderToAddToInput(LppSalesInvoiceHeaderInput, '');
        LppSalesInvoiceHeaderInput.Open();
        while LppSalesInvoiceHeaderInput.Read() do;
        LPMachineLearningSetup."Posting Date OnLastML" := LppSalesInvoiceHeaderInput.PostingDate;
        LppSalesInvoiceHeaderInput.Close();
        LPMachineLearningSetup.Modify(true);
    end;
}
