#pragma warning disable AA0247
page 14104 "Customs Declarations"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Custom Declarations';
    CardPageID = "Customs Declaration";
    Editable = false;
    PageType = List;
    SourceTable = "CD Number Header";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1210002)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("Declaration Date"; "Declaration Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the declaration date associated with this custom declaration header.';
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source type that applies to the source number that is shown in the Source No. field.';
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the source document that the entry originates from.';
                }
                field("Country/Region of Origin Code"; "Country/Region of Origin Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code for the country/region where the item was produced or processed.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
        }
    }

    actions
    {
    }
}

