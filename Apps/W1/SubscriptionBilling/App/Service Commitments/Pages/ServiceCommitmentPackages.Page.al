namespace Microsoft.SubscriptionBilling;

page 8057 "Service Commitment Packages"
{
    ApplicationArea = All;
    Caption = 'Subscription Packages';
    PageType = List;
    SourceTable = "Subscription Package";
    UsageCategory = Administration;
    CardPageId = "Service Commitment Package";
    Editable = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec.Code)
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies a code to identify this Subscription Package.';
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
            action(CopyServiceCommitmentPackage)
            {
                Caption = 'Copy Subscription Package';
                Image = Copy;
                ToolTip = 'Creates a copy of the current Subscription Package.';
                trigger OnAction()
                begin
                    Rec.CopyServiceCommitmentPackage();
                end;

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
                actionref(CopyServiceCommitmentPackage_Promoted; CopyServiceCommitmentPackage)
                {
                }
            }
        }
    }
}
