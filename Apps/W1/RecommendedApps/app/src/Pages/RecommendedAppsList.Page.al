page 4750 "Recommended Apps List"
{
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Recommended Apps';
    PageType = List;
    SourceTable = "Recommended Apps";
    SourceTableView = sorting(SortingId);
    CardPageID = "Recommended App Card";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Name';
                }
                field(Publisher; Rec.Publisher)
                {
                    ApplicationArea = All;
                    ToolTip = 'App publisher';
                }
                field("Recommended by"; Rec."Recommended by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Recommended by';
                    Caption = 'Recommended by';
                }
                field("Short Description"; Rec."Short Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Short Description';
                }
            }
        }
    }

    views
    {
        view("Your Microsoft Reseller")
        {
            Caption = 'Your Microsoft Reseller';
            Filters = where("Recommended By" = filter('Your Microsoft Reseller'));
        }
    }
}