#pragma warning disable AA0247
page 14103 "Customs Declaration"
{
    Caption = 'Customs Declaration';
    PageType = Document;
    SourceTable = "CD Number Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description associated with this line.';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source type that applies to the source number that is shown in the Source No. field.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the source document that the entry originates from.';
                }
                field("Country/Region of Origin Code"; Rec."Country/Region of Origin Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code for the country/region where the item was produced or processed.';

                    trigger OnValidate()
                    begin
                        if Rec."Country/Region of Origin Code" <> xRec."Country/Region of Origin Code" then
                            CurrPage.ItemLines.PAGE.UpdateForm();
                    end;
                }
                field("Declaration Date"; Rec."Declaration Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the declaration date associated with this custom declaration header.';
                }
            }
            part(ItemLines; "Customs Declaration Subform")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "CD Header Number" = FIELD("No.");
                SubPageView = SORTING("CD Header Number", "Package No.");
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
        area(processing)
        {
            action("Navigate")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Find entries...';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Find all entries and documents that exist for the document number and posting date on the selected entry or document.';

                trigger OnAction()
                begin
                    CurrPage.ItemLines.Page.Navigate();
                end;
            }
        }
    }
}

