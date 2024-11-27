namespace Microsoft.SubscriptionBilling;

page 8001 "Create Billing Document"
{

    Caption = 'Create Billing Document';
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
                field(BillingTo; BillingTo)
                {
                    Caption = 'Billing To';
                    ToolTip = 'Specifies the date to which the service is billed.';

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
                field(OpenDocument; OpenDocument)
                {
                    Caption = 'Open Document';
                    ToolTip = 'Specifies whether the created document will be opened automatically.';
                    trigger OnValidate()
                    begin
                        if OpenDocument then
                            PostDocument := not OpenDocument;
                    end;
                }
                field(PostDocument; PostDocument)
                {
                    Caption = 'Post Document';
                    ToolTip = 'Specifies whether the created document will be posted automatically.';
                    trigger OnValidate()
                    begin
                        if PostDocument then
                            OpenDocument := not PostDocument;
                    end;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        BillingDate := WorkDate();
        DocumentDate := WorkDate();
        PostingDate := WorkDate();
        PostDocument := false;
        OpenDocument := true;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::OK then
            CreateBillingDocumentForContract();
    end;

    internal procedure SetContractData(ServicePartnerValue: Enum "Service Partner"; ContractNoValue: Code[20]; BillingRhythmFilterValue: Text)
    begin
        ContractNo := ContractNoValue;
        ServicePartner := ServicePartnerValue;
        BillingRhytmFilter := BillingRhythmFilterValue;
    end;

    var
        BillingProposal: Codeunit "Billing Proposal";
        PostDocument: Boolean;
        BillingTo: Date;
        OpenDocument: Boolean;
        ServicePartner: Enum "Service Partner";
        BillingRhytmFilter: Text;
        NoInvoiceCreatedErr: Label 'No contract lines were found that can be billed with the specified parameters.';

    protected var
        ContractNo: Code[20];
        DocumentDate: Date;
        PostingDate: Date;
        BillingDate: Date;

    internal procedure GetData(var NewDocumentDate: Date; var NewPostingDate: Date; var NewPostDocument: Boolean)
    begin
        NewDocumentDate := DocumentDate;
        NewPostingDate := PostingDate;
        NewPostDocument := PostDocument;
    end;

    local procedure CreateBillingDocumentForContract()
    begin
        BillingProposal.CreateBillingProposalForContract(ServicePartner, ContractNo, '', BillingRhytmFilter, BillingDate, BillingTo);
        if not BillingProposal.CreateBillingDocument(ServicePartner, ContractNo, DocumentDate, PostingDate, PostDocument, OpenDocument) then
            Error(NoInvoiceCreatedErr);
    end;
}
