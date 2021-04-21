page 4703 "VAT Group Approved Member List"
{
    PageType = List;
    Caption = 'VAT Group Approved Members';
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "VAT Group Approved Member";
    SourceTableView = sorting("Group Member Name");

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(ID; Rec.ID)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the identifier of the group member.';
                }
                field("Group Member Name"; Rec."Group Member Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the group member.';
                }
                field(Company; Rec.Company)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company from which the group member will send VAT returns in Business Central.';
                }
                field("Contact Person Name"; Rec."Contact Person Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the contact person in the group member company.';
                }
                field("Contact Person Email"; Rec."Contact Person Email")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the email of the contact person in the group member company.';
                }
            }
        }
    }
}