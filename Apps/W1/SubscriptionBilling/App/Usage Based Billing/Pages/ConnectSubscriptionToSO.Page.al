namespace Microsoft.SubscriptionBilling;

using System.Utilities;

page 8031 "Connect Subscription To SO"
{
    Caption = 'Connect Subscription to Service Object';
    ApplicationArea = All;
    SourceTable = "Usage Data Subscription";
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
                    Visible = false;
                }
                field("Service Commitment"; Rec."Service Commitment Entry No.")
                {
                    ToolTip = 'Specifies the service to which this subscription is linked.';
                    StyleExpr = UsageDataSubscriptionStyle;
                    Visible = false;
                }
                field("Product Name"; Rec."Product Name")
                {
                    ToolTip = 'Specifies the vendor''s product name for this subscription.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Connect to Service Object No."; Rec."Connect to Service Object No.")
                {
                    ToolTip = 'Specifies the service object to which the subscription should be connected.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Connect to SO Method"; Rec."Connect to SO Method")
                {
                    ToolTip = 'Specifies whether new service commitments will be created or existing service commitments will be updated for the service object.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Connect to SO at Date"; Rec."Connect to SO at Date")
                {
                    ToolTip = 'Specifies the date on which the new service commitments will be created.';
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
                field("Reason (Preview)"; Rec."Reason (Preview)")
                {
                    ToolTip = 'Specifies the preview why the last processing step failed.';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowReason();
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Connect Subscriptions to Service Objects")
            {
                Caption = 'Connect Subscriptions to Service Objects';
                ToolTip = 'Connects the selected subscriptions to the selected service objects as specified.';
                Ellipsis = true;
                Image = CarryOutActionMessage;
                Scope = Repeater;

                trigger OnAction()
                var
                    UsageDataSubscription: Record "Usage Data Subscription";
                    UsageBasedBillingMgmt: Codeunit "Usage Based Billing Mgmt.";
                    ConfirmManagement: Codeunit "Confirm Management";
                begin
                    if not ConfirmManagement.GetResponse(ProceedConnectingServiceObjectToSubscriptionQst, true) then
                        exit;
                    CurrPage.SetSelectionFilter(UsageDataSubscription);
                    UsageBasedBillingMgmt.ConnectSubscriptionsToServiceObjects(UsageDataSubscription);
                end;
            }
            action("Reset Processing Status")
            {
                Caption = 'Reset Processing Status';
                ToolTip = 'Resets the processing status for the selected subscriptions.';
                Ellipsis = true;
                Image = ResetStatus;
                Scope = Repeater;

                trigger OnAction()
                var
                    UsageDataSubscription: Record "Usage Data Subscription";
                    ConfirmManagement: Codeunit "Confirm Management";
                begin
                    if not ConfirmManagement.GetResponse(ResetProcessingStatusQst, true) then
                        exit;

                    CurrPage.SetSelectionFilter(UsageDataSubscription);
                    UsageDataSubscription.ResetProcessingStatus(UsageDataSubscription);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("Connect Subscriptions to Service Objects_Promoted"; "Connect Subscriptions to Service Objects")
                {
                }
                actionref("Reset Processing Status_Promoted"; "Reset Processing Status")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetRange("Service Commitment Entry No.", 0);
    end;

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
        UsageDataSubscriptionStyle: Text;
        ProceedConnectingServiceObjectToSubscriptionQst: Label 'If you continue, the selected Subscriptions will be connected to their respective Service Object by either creating new service commitment or by updating existing service commitment.\\Do you want to continue?';
        ResetProcessingStatusQst: Label 'Do you want to reset the Processing Status for all selected Subscriptions?';
}
