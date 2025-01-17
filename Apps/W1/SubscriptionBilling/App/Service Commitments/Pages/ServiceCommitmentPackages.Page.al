namespace Microsoft.SubscriptionBilling;

page 8057 "Service Commitment Packages"
{
    ApplicationArea = All;
    Caption = 'Service Commitment Packages';
    PageType = List;
    SourceTable = "Service Commitment Package";
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
                    ToolTip = 'Specifies a code to identify this service commitment package.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the service commitment package.';
                }
                field("Price Group"; Rec."Price Group")
                {
                    ToolTip = 'Specifies the customer price group that will be used for the invoicing of services.';
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
                Caption = 'Copy Service Commitment Package';
                Image = Copy;
                ToolTip = 'Creates a copy of the current service commitment package.';
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
