namespace Microsoft.SubscriptionBilling;

page 8034 "Create Usage B. Vend. B. Docs"
{
    Caption = 'Create Billing Documents';
    PageType = StandardDialog;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(DateFields)
            {
                Caption = 'Billing';
                field(BillingDate; BillingDate)
                {
                    Caption = 'Billing Date';
                    ToolTip = 'Specifies the date up to which the billable services will be taken into account.';
                }
            }
            group(Posting)
            {
                Caption = 'Posting';
                field(DocumentDate; DocumentDate)
                {
                    Caption = 'Document Date';
                    ToolTip = 'Specifies the date which is taken over as the document date in the documents.';
                }
                field(PostingDate; PostingDate)
                {
                    Caption = 'Posting Date';
                    ToolTip = 'Specifies the date which is used as the posting date in the documents.';
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        BillingDate := WorkDate();
        DocumentDate := WorkDate();
        PostingDate := WorkDate();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::OK then
            CreateBillingDocumentForContract();
    end;

    internal procedure SetContractData(ServicePartnerValue: Enum "Service Partner"; ContractNoFilterValue: Text; ContractLineFilterValue: Text; BillingRhythmFilterValue: Text)
    begin
        ContractNoFilter := ContractNoFilterValue;
        ContractLineFilter := ContractLineFilterValue;
        ServicePartner := ServicePartnerValue;
        BillingRhytmFilter := BillingRhythmFilterValue;
    end;

    var
        BillingProposal: Codeunit "Billing Proposal";
        DocumentDate: Date;
        PostingDate: Date;
        BillingDate: Date;
        ContractNoFilter: Text;
        ContractLineFilter: Text;
        ServicePartner: Enum "Service Partner";
        BillingRhytmFilter: Text;
        NoInvoiceCreatedErr: Label 'No contract lines were found that can be billed with the specified parameters.';

    internal procedure GetData(var NewDocumentDate: Date; var NewPostingDate: Date)
    begin
        NewDocumentDate := DocumentDate;
        NewPostingDate := PostingDate;
    end;

    local procedure CreateBillingDocumentForContract()
    var
        VendorContract: Record "Vendor Contract";
    begin
        if ServicePartner = ServicePartner::Customer then
            exit;

        VendorContract.SetFilter("No.", ContractNoFilter);
        if VendorContract.FindSet() then
            repeat
                BillingProposal.CreateBillingProposalForContract(ServicePartner, VendorContract."No.", ContractLineFilter, BillingRhytmFilter, BillingDate, 0D);
            until VendorContract.Next() = 0;

        //NOTE: CreateBillingDocument works with all Billing lines previously created by BillingProposal.CreateBillingProposalForContract
        //Therefore it will batch create documents for Usage based billing lines
        if not BillingProposal.CreateBillingDocument(ServicePartner, VendorContract."No.", DocumentDate, PostingDate, false, false) then
            Error(NoInvoiceCreatedErr);
        ContractNoFilter := '';
    end;
}
