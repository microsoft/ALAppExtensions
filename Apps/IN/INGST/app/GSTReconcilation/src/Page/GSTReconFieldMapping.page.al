page 18284 "GST Recon. Field Mapping"
{
    Caption = 'GST Recon. Field Mapping';
    PageType = List;
    SourceTable = Field;
    SourceTableView = sorting(TableNo, "No.")
                      where(TableNo = filter(18281));
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(TableNo; Rec.TableNo)
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GSTIN for which GST reconciliation is created.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number.';
                }
                field(FieldName; Rec.FieldName)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Reconciliation Name Field No.';
                }
            }
        }
    }
}
