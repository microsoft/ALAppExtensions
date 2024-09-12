namespace Microsoft.SubscriptionBilling;

page 8033 "Create Usage B. Cust. B. Docs"
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
                Caption = 'Dates';
                field(BillingDate; BillingDate)
                {
                    Caption = 'Billing Date';
                    ToolTip = 'Specifies the date up to which the billable services will be taken into account.';
                }
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
                field(PostDocument; PostDocument)
                {
                    Caption = 'Post Document';
                    ToolTip = 'Specifies whether the created document will be posted automatically.';
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
        PostDocument: Boolean;
        BillingDate: Date;
        ContractNoFilter: Text;
        ContractLineFilter: Text;
        ServicePartner: Enum "Service Partner";
        BillingRhytmFilter: Text;
        NoInvoiceCreatedErr: Label 'No contract lines were found that can be billed with the specified parameters.';

    internal procedure GetData(var NewDocumentDate: Date; var NewPostingDate: Date; var NewPostDocument: Boolean)
    begin
        NewDocumentDate := DocumentDate;
        NewPostingDate := PostingDate;
        NewPostDocument := PostDocument;
    end;

    local procedure CreateBillingDocumentForContract()
    var
        CustomerContract: Record "Customer Contract";
    begin
        if ServicePartner = ServicePartner::Vendor then
            exit;

        CustomerContract.SetFilter("No.", ContractNoFilter);
        if CustomerContract.FindSet() then
            repeat
                BillingProposal.CreateBillingProposalForContract(ServicePartner, CustomerContract."No.", ContractLineFilter, BillingRhytmFilter, BillingDate, 0D);
            until CustomerContract.Next() = 0;

        //NOTE: CreateBillingDocument works with all Billing lines previously created by BillingProposal.CreateBillingProposalForContract
        //Therefore it will batch create documents for Usage based billing lines 
        if not BillingProposal.CreateBillingDocument(ServicePartner, CustomerContract."No.", DocumentDate, PostingDate, PostDocument, false) then
            Error(NoInvoiceCreatedErr);
        ContractNoFilter := '';
    end;
}
