namespace Microsoft.SubscriptionBilling;

page 8013 "Imported Customer Contracts"
{
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Imported Customer Contract";
    Caption = 'Imported Customer Contracts';

    layout
    {
        area(Content)
        {
            repeater(ImportedServiceCommitments)
            {
                field("Contract No."; Rec."Contract No.")
                {
                    ToolTip = 'Specifies the number of Contract that will be created.';
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ToolTip = 'Specifies the number of the customer who will receive the contractual services and be billed by default.';
                }
                field("Sell-to Contact No."; Rec."Sell-to Contact No.")
                {
                    ToolTip = 'Specifies the number of the contact that receives the contractual services.';
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ToolTip = 'Specifies the customer that the contract invoice will be sent to. Default (Customer): The same as the customer on the contract. Another Customer: Any customer that you specify in the fields below.';
                }
                field("Bill-to Contact No."; Rec."Bill-to Contact No.")
                {
                    ToolTip = 'Specifies the number of the contact the invoice will be sent to.';
                }
                field("Contract Type"; Rec."Contract Type")
                {
                    ToolTip = 'Specifies the classification of the contract.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the internal description of the contract.';
                }
                field("Your Reference"; Rec."Your Reference")
                {
                    ToolTip = 'Specifies the customer''s reference. The content will be printed on contract invoice.';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ToolTip = 'Specifies the name of the salesperson who is assigned to the customer.';
                }
                field("Assigned User ID"; Rec."Assigned User ID")
                {
                    ToolTip = 'Specifies the ID of the user who is responsible for the document.';
                }
                field("Without Contract Deferrals"; Rec."Without Contract Deferrals")
                {
                    ToolTip = 'Specifies whether deferrals should be generated for the contract. If the field is activated, no deferrals are generated and the invoices are posted directly to profit or loss.';
                }
                field("Detail Overview"; Rec."Detail Overview")
                {
                    ToolTip = 'Specifies whether the billing details for this contract are automatically output with invoices and credit memos.';
                }
                field("Dimension from Job No."; Rec."Dimension from Job No.")
                {
                    ToolTip = 'Specifies the Project number from which the dimensions for the contract are transfered.';
                }
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    ToolTip = 'Specifies the code for another shipment address than the customer''s own address, which is entered by default.';
                    Visible = false;
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    ToolTip = 'Specifies a formula that calculates the payment due date, payment discount date, and payment discount amount.';
                    Visible = false;
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ToolTip = 'Specifies how to make payment, such as with bank transfer, cash, or check.';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the currency of amounts on the contract invoice.';
                    Visible = false;
                }
                field("Contract created"; Rec."Contract created")
                {
                    ToolTip = 'Specifies whether a Customer Contract has been created.';
                }
                field("Error Text"; Rec."Error Text")
                {
                    ToolTip = 'Specifies the error in processing the record.';
                }
                field("Processed by"; Rec."Processed by")
                {
                    ToolTip = 'Specifies who processed the record.';
                }
                field("Processed at"; Rec."Processed at")
                {
                    ToolTip = 'Specifies when the record was processed.';
                }
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref(PromotedCreateCustomerContracts; CreateCustomerContracts)
            {
            }
        }
        area(Processing)
        {
            action(CreateCustomerContracts)
            {
                ApplicationArea = All;
                Caption = 'Create Customer Contracts';
                ToolTip = 'Creates Customer Contracts.';
                Image = CreateBinContent;

                trigger OnAction()
                var
                    ImportedCustomerContract: Record "Imported Customer Contract";
                begin
                    CurrPage.SetSelectionFilter(ImportedCustomerContract);
                    Report.Run(Report::"Create Customer Contracts", false, false, ImportedCustomerContract);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
