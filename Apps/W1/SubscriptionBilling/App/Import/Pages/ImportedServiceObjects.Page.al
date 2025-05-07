namespace Microsoft.SubscriptionBilling;

page 8008 "Imported Service Objects"
{
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Imported Subscription Header";
    Caption = 'Imported Subscriptions';

    layout
    {
        area(Content)
        {
            repeater(ImportedServiceObjects)
            {
                field("Service Object No."; Rec."Subscription Header No.")
                {
                    ToolTip = 'Specifies the number of the Subscription.';
                }
                field("End-User Customer No."; Rec."End-User Customer No.")
                {
                    ToolTip = 'Specifies the number of the customer to whom the Subscription Line was sold.';
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ToolTip = 'Specifies the customer to whom you will send the sales invoice, when different from the customer that you are selling to.';
                    Visible = false;
                }
                field("Bill-to Contact No."; Rec."Bill-to Contact No.")
                {
                    ToolTip = 'Specifies the number of the contact the invoice will be sent to.';
                    Visible = false;
                }
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    ToolTip = 'Specifies the address that the Subscription and Subscription Lines were shipped.';
                    Visible = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the Item No. of the Subscription.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the Subscription.';
                }
                field(Quantity; Rec."Quantity (Decimal)")
                {
                    ToolTip = 'Specifies the number of units of Subscription.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Customer Reference"; Rec."Customer Reference")
                {
                    ToolTip = 'Specifies the reference by which the customer identifies the Subscription.';
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ToolTip = 'Specifies the Serial No. assigned to the Subscription.';
                    Visible = false;
                }
                field(Version; Rec.Version)
                {
                    ToolTip = 'Specifies the version of the Subscription.';
                    Visible = false;
                }
                field("Key"; Rec."Key")
                {
                    ToolTip = 'Specifies the additional information (ex. License) of the Subscription.';
                    Visible = false;
                }
                field("Provision Start Date"; Rec."Provision Start Date")
                {
                    ToolTip = 'Specifies the date from which the subject of the Subscription Line and the associated Subscription Lines were made available to the customer.';
                    Visible = false;
                }
                field("Provision End Date"; Rec."Provision End Date")
                {
                    ToolTip = 'Specifies the date from which the subject of the Subscription Line and the associated Subscription Line are not longer available to the customer.';
                    Visible = false;
                }
                field("End-User Contact No."; Rec."End-User Contact No.")
                {
                    ToolTip = 'Specifies the number of the contact of the customer to whom the serSubscription Linevice was sold.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ToolTip = 'Specifies the unit of measure code.';
                    Visible = false;
                }
                field("Service Object created"; Rec."Subscription Header created")
                {
                    ToolTip = 'Specifies whether the Subscription has been created.';
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
            actionref(PromotedCreateServiceObjects; CreateServiceObjects)
            {
            }
        }
        area(Processing)
        {
            action(CreateServiceObjects)
            {
                ApplicationArea = All;
                Caption = 'Create Subscriptions';
                ToolTip = 'Creates Subscriptions.';
                Image = CreateBins;

                trigger OnAction()
                var
                    ImportedServiceObject: Record "Imported Subscription Header";
                begin
                    CurrPage.SetSelectionFilter(ImportedServiceObject);
                    Report.Run(Report::"Create Service Objects", false, false, ImportedServiceObject);
                end;
            }
        }
    }
}