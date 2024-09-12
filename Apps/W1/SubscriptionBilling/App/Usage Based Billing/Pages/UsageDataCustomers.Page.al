namespace Microsoft.SubscriptionBilling;

page 8037 "Usage Data Customers"
{
    ApplicationArea = All;
    SourceTable = "Usage Data Customer";
    Caption = 'Usage Data Customers';
    UsageCategory = Lists;
    PageType = List;
    LinksAllowed = false;
    DelayedInsert = true;
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
                    ToolTip = 'Specifies the number of the supplier to which this reference refers.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Supplier Description"; Rec."Supplier Description")
                {
                    ToolTip = 'Specifies the description of the supplier to which this reference refers.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the internal number of the customer to which this record refers.';
                    StyleExpr = UsageDataSubscriptionStyle;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ToolTip = 'Specifies the name of the customer to which this record refers.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("E-mail"; Rec."E-mail")
                {
                    ToolTip = 'Specifies the customer''s email address that is on file with the vendor.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field(Domain; Rec."Domain")
                {
                    ToolTip = 'Specifies the domain of the customer, which is stored at the supplier.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field(Culture; Rec.Culture)
                {
                    ToolTip = 'Specifies which regional settings (date format, decimal separator, etc.) are stored for the customer at the supplier.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Supplier Reference"; Rec."Supplier Reference")
                {
                    ToolTip = 'Specifies the unique ID of the customer at the supplier.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Supplier Reference Entry No."; Rec."Supplier Reference Entry No.")
                {
                    ToolTip = 'Specifies the sequential number of the ID in the reference table for this customer.';
                    Visible = false;
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Tenant ID"; Rec."Tenant ID")
                {
                    ToolTip = 'Specifies the unique ID of the tenant at the supplier.';
                    StyleExpr = UsageDataSubscriptionStyle;
                    Visible = false;
                }
                field("Customer ID"; Rec."Customer ID")
                {
                    ToolTip = 'Specifies the unique ID of the customer at the supplier.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Customer Description"; Rec."Customer Description")
                {
                    ToolTip = 'Specifies the name of the customer at the supplier.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
                field("Processing Status"; Rec."Processing Status")
                {
                    ToolTip = 'Specifies the processing status of the reference.';
                    StyleExpr = UsageDataSubscriptionStyle;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetUsageDataSubscriptionStyleExpresion();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if Rec.GetFilter("Supplier No.") <> '' then
            Rec.Validate("Supplier No.", Rec.GetRangeMin("Supplier No."));
        if Rec.GetFilter("Supplier Reference") <> '' then
            Rec.Validate("Supplier Reference", Rec.GetRangeMin("Supplier Reference"));
    end;

    local procedure SetUsageDataSubscriptionStyleExpresion()
    begin
        UsageDataSubscriptionStyle := 'Standard';
        if Rec."Customer No." = '' then
            UsageDataSubscriptionStyle := 'AttentionAccent';
    end;

    var
        UsageDataSubscriptionStyle: Text;
}
