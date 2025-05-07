namespace Microsoft.SubscriptionBilling;

page 8056 "Service Commitment Package"
{
    Caption = 'Subscription Package';
    PageType = Card;
    SourceTable = "Subscription Package";
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies a code to identify this Subscription Package.';
                    trigger OnValidate()
                    begin
                        PackageLinesEnabled := Rec.Code <> '';
                    end;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the Subscription Package.';
                }
                field("Price Group"; Rec."Price Group")
                {
                    ToolTip = 'Specifies the customer price group that will be used for the invoicing of Subscription Lines.';
                }
            }
            part(PackageLines; "Service Comm. Package Lines")
            {
                Editable = DynamicEditable;
                Enabled = PackageLinesEnabled;
                SubPageLink = "Subscription Package Code" = field(Code);
                UpdatePropagation = Both;
            }

        }
    }
    actions
    {
        area(Navigation)
        {
            action(AssignedItems)
            {
                Caption = 'Assigned Items';
                Image = ItemLedger;
                RunObject = page "Assigned Items";
                RunPageLink = Code = field(Code);
                ToolTip = 'Shows items related to a package.';
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(AssignedItems_Promoted; AssignedItems)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        PackageLinesEnabled := Rec.Code <> '';
    end;

    trigger OnAfterGetCurrRecord()
    begin
        DynamicEditable := CurrPage.Editable;
    end;

    var
        DynamicEditable: Boolean;
        PackageLinesEnabled: Boolean;
}
