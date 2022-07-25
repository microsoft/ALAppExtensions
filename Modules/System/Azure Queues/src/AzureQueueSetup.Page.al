page 50100 "Azure Queue Setup"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Azure Queue Setup';
    PageType = List;
    SourceTable = "Azure Queue Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                Caption = 'Setup';

                field("Storage Account Name"; Rec."Storage Account Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Name of the Azure Storage Account.';
                }
                field("SAS Key"; Rec."SAS Key")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Shared Access Signature Key for the Azure Storage Account.';
                }
            }
        }
    }

}
