namespace Microsoft.SubscriptionBilling;

page 8093 "Assign Service Comm. Packages"
{
    Caption = 'Assign Service Commitment Packages';
    InsertAllowed = false;
    DeleteAllowed = false;
    PageType = List;
    SourceTable = "Service Commitment Package";
    SourceTableTemporary = true;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Selected; Rec.Selected)
                {
                    ToolTip = 'Specifies which additional service commitment packages are taken into account when creating the service object.';
                }
                field("Code"; Rec.Code)
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies a code to identify this service commitment package.';
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the service commitment package.';
                    Editable = false;
                }
                field("Price Group"; Rec."Price Group")
                {
                    ToolTip = 'Specifies the customer price group that will be used for the invoicing of services.';
                    Editable = false;
                }
            }
        }
    }
    internal procedure GetSelectionFilter(var ServiceCommitmentPackage: Record "Service Commitment Package")
    begin
        CurrPage.SetSelectionFilter(ServiceCommitmentPackage);
    end;
}
