namespace Microsoft.SubscriptionBilling;

using Microsoft.Foundation.Attachment;
using Microsoft.Sales.Customer;
using Microsoft.Finance.Dimension;

page 8053 "Customer Contracts"
{
    ApplicationArea = All;
    Caption = 'Customer Contracts';
    CardPageID = "Customer Contract";
    DataCaptionFields = "Sell-to Customer No.";
    Editable = false;
    PageType = List;
    QueryCategory = 'Customer Contract List';
    RefreshOnActivate = true;
    SourceTable = "Customer Contract";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(DescriptionText; DescriptionText)
                {
                    Caption = 'Description';
                    ToolTip = 'Specifies the products or service being offered.';
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ToolTip = 'Specifies the number of the customer who will receive the contractual services and be billed by default.';
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ToolTip = 'Specifies the name of the customer who will receive the contractual services and be billed by default.';
                }
                field("Sell-to Post Code"; Rec."Sell-to Post Code")
                {
                    ToolTip = 'Specifies the postal code of the customer''s main address.';
                    Visible = false;
                }
                field("Sell-to Country/Region Code"; Rec."Sell-to Country/Region Code")
                {
                    ToolTip = 'Specifies the country/region code of the customer''s main address.';
                    Visible = false;
                }
                field("Sell-to Contact"; Rec."Sell-to Contact")
                {
                    ToolTip = 'Specifies the name of the contact person at the customer''s main address.';
                    Visible = false;
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ToolTip = 'Specifies the number of the customer that you send or sent the invoice or credit memo to.';
                }
                field("Bill-to Name"; Rec."Bill-to Name")
                {
                    ToolTip = 'Specifies the customer to whom you will send the contract invoice, when different from the contractor.';
                }
                field("Bill-to Post Code"; Rec."Bill-to Post Code")
                {
                    ToolTip = 'Specifies the postal code of the customer''s billing address.';
                    Visible = false;
                }
                field("Bill-to Country/Region Code"; Rec."Bill-to Country/Region Code")
                {
                    ToolTip = 'Specifies the country/region code of the customer''s billing address.';
                    Visible = false;
                }
                field("Bill-to Contact"; Rec."Bill-to Contact")
                {
                    ToolTip = 'Specifies the name of the contact person at the customer''s billing address.';
                    Visible = false;
                }
                field("Contract Type"; Rec."Contract Type")
                {
                    ToolTip = 'Specifies the classification of the contract.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the name of the salesperson who is assigned to the customer.';
                }
                field("Assigned User ID"; Rec."Assigned User ID")
                {
                    ToolTip = 'Specifies the ID of the user who is responsible for the document.';
                }
                field(Active; Rec.Active)
                {
                    Visible = false;
                    ToolTip = 'Specifies whether the contract is active.';
                }
                field("Your Reference"; Rec."Your Reference")
                {
                    ToolTip = 'Specifies the customer''s reference. The content will be printed on contract invoice.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the currency of amounts on the contract invoice.';
                    Visible = false;
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    ToolTip = 'Specifies a formula that calculates the payment due date, payment discount date, and payment discount amount.';
                    Visible = false;
                }
                field("Exclude from Price Update"; Rec.DefaultExcludeFromPriceUpdate)
                {
                    ToolTip = 'Specifies whether price updates are are allowed for that contract. Setting it to yes will exclude all contract lines from all price updates.';
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            part(Control1902018507; "Customer Statistics FactBox")
            {
                SubPageLink = "No." = field("Bill-to Customer No.");
            }
            part(Control1900316107; "Customer Details FactBox")
            {
                SubPageLink = "No." = field("Bill-to Customer No.");
            }
            part("Attached Documents"; "Doc. Attachment List Factbox")
            {
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(Database::"Customer Contract"),
                              "No." = field("No.");
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Contract)
            {
                Caption = 'Customer Contract';
                Image = "Order";
                action(CreateContractInvoice)
                {
                    ApplicationArea = All;
                    Caption = 'Create Contract Invoice';
                    Image = CreateDocuments;
                    ToolTip = 'The action creates a contract invoice for the current contract.';

                    trigger OnAction()
                    begin
                        Rec.CreateBillingProposal()
                    end;
                }

                action(Dimensions)
                {
                    AccessByPermission = tabledata Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDocDim();
                    end;
                }
                action("Customer Contract Deferrals")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Contract Deferrals';
                    ToolTip = 'Customer Contract Deferrals.';
                    Image = LedgerEntries;
                    ShortcutKey = 'Ctrl+F7';
                    RunObject = Page "Customer Contract Deferrals";
                    RunPageView = sorting("Contract No.");
                    RunPageLink = "Contract No." = field("No.");

                }
                action(UpdateDimensionsInDeferrals)
                {
                    ApplicationArea = All;
                    Caption = 'Update Dimensions in Deferrals';
                    ToolTip = 'Updates the dimensions in all contract deferrals that have not yet been released for this contract.';
                    Image = ChangeDimensions;
                    Enabled = UpdateDimensionsInDeferralsEnabled;
                    trigger OnAction()
                    begin
                        Rec.UpdateDimensionsInDeferrals();
                    end;
                }
            }
            group(Print)
            {
                Caption = 'Print';
                action(OverviewOfContractComponents)
                {
                    Caption = 'Overview of contract components';
                    ToolTip = 'View a detailed list of services for the selected contract(s).';
                    Image = QualificationOverview;
                    ApplicationArea = All;
                    RunObject = Report "Overview Of Contract Comp";
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(CreateContractInvoice_Promoted; CreateContractInvoice)
                {
                }
            }
            group(Category_Category5)
            {
                Caption = 'Contract';

                actionref(Dimensions_Promoted; Dimensions)
                {
                }
                actionref("Customer Contract Deferrals_Promoted"; "Customer Contract Deferrals")
                {
                }
                actionref(UpdateDimensionsInDeferrals_Promoted; UpdateDimensionsInDeferrals)
                {
                }
            }
            group(Category_Category6)
            {
                Caption = 'Print';
                actionref(OverviewOfContractComponent; OverviewOfContractComponents) { }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        DescriptionText := Rec.GetDescription();
        UpdateDimensionsInDeferralsEnabled := Rec.NotReleasedCustomerContractDeferralsExists();
    end;

    trigger OnOpenPage()
    begin
        Rec.CopySellToCustomerFilter();
        Rec.SetRange(Active, true);
    end;

    var
        DescriptionText: Text;
        UpdateDimensionsInDeferralsEnabled: Boolean;
}

