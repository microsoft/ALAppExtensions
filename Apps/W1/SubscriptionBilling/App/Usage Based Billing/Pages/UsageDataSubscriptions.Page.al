namespace Microsoft.SubscriptionBilling;

page 8042 "Usage Data Subscriptions"
{
    ApplicationArea = All;
    SourceTable = "Usage Data Subscription";
    Caption = 'Usage Data Subscriptions';
    UsageCategory = Lists;
    PageType = List;
    LinksAllowed = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the sequential number assigned to the record when it was created.';
                    Visible = false;
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Supplier No."; Rec."Supplier No.")
                {
                    ToolTip = 'Specifies the number of the supplier to which this subscription refers.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Supplier Description"; Rec."Supplier Description")
                {
                    ToolTip = 'Specifies the description of the supplier to which this subscription refers.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the internal number of the customer to which this subscription refers.';
                    StyleExpr = UsageDataSubscriptionStyle;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ToolTip = 'Specifies the name of the customer to which this subscription refers.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Service Object No."; Rec."Service Object No.")
                {
                    ToolTip = 'Specifies the number of the service object to which this subscription refers.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Service Commitment"; Rec."Service Commitment Entry No.")
                {
                    ToolTip = 'Specifies the service to which this subscription is linked.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Product Name"; Rec."Product Name")
                {
                    ToolTip = 'Specifies the vendor''s product name for this subscription.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the status of this subscription.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Billing Cycle"; Rec."Billing Cycle")
                {
                    ToolTip = 'Specifies the billing cycle of the subscription.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the quantity that refers to this subscription.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Unit Type"; Rec."Unit Type")
                {
                    ToolTip = 'Specifies the unit of the subscription.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ToolTip = 'Specifies when the subscription was created.';
                    Visible = false;
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("End Date"; Rec."End Date")
                {
                    ToolTip = 'Specifies the end date of the subscription.';
                    Visible = false;
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Supplier Reference Entry No."; Rec."Supplier Reference Entry No.")
                {
                    ToolTip = 'Specifies the sequential number of the ID in the reference table for this subscription.';
                    Visible = false;
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Supplier Reference"; Rec."Supplier Reference")
                {
                    ToolTip = 'Specifies the unique ID of the subscription at the supplier.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Customer ID"; Rec."Customer ID")
                {
                    ToolTip = 'Specifies the unique ID of the customer for this subscription at the supplier.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Customer Description"; Rec."Customer Description")
                {
                    ToolTip = 'Specifies the name of the customer for this subscription with the supplier.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Product ID"; Rec."Product ID")
                {
                    ToolTip = 'Specifies the unique ID of the product for this subscription with the supplier.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Processing Status"; Rec."Processing Status")
                {
                    ToolTip = 'Specifies the processing status of this subscription.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ExtendContract)
            {
                Caption = 'Extend Contract';
                ToolTip = 'Opens the action for creating a service object with services that directly extend the specified contracts.';
                Image = AddAction;

                trigger OnAction()
                var
                    UsageDataCustomer: Record "Usage Data Customer";
                    ExtendContractPage: Page "Extend Contract";
                begin
                    if Rec."Service Commitment Entry No." <> 0 then
                        Error(AlreadyConnectedErr, Rec."Service Object No.", Rec."Service Commitment Entry No.");

                    ExtendContractPage.SetParameters(UsageDataCustomer."Customer No.", '', Rec."Start Date", UsageDataCustomer."Customer No." <> '');
                    ExtendContractPage.SetUsageBasedParameters(Rec."Supplier No.", Rec."Entry No.");
                    ExtendContractPage.LookupMode(true);
                    ExtendContractPage.RunModal();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(ExtendContract_Promoted; ExtendContract)
                {
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        SetUsageDataSubscriptionStyleExpresion();
    end;

    local procedure SetUsageDataSubscriptionStyleExpresion()
    begin
        UsageDataSubscriptionStyle := 'Standard';
        if Rec."Service Commitment Entry No." = 0 then
            UsageDataSubscriptionStyle := 'StandardAccent';
        if Rec."Processing Status" = Enum::"Processing Status"::Error then
            UsageDataSubscriptionStyle := 'Attention';
    end;

    var
        AlreadyConnectedErr: Label 'This Subscription is already connected to Service Object %1 Service Commitment %2. Contract extension is not possible.';
        UsageDataSubscriptionStyle: Text;
}
