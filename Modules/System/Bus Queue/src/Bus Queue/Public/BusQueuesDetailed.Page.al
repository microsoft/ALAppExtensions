page 51753 "Bus Queues Detailed"
{
    PageType = List;
    Caption = 'Bus Queues Detailed';
    SourceTable = "Bus Queue Detailed";
    ApplicationArea = Basic, Suite;
    SourceTableView = sorting("Entry No.") order(descending);
    Editable = false;
    Extensible = false;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Parent Entry No."; Rec."Parent Entry No.")
                {
                    ToolTip = 'Specifies the parent entry no.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the status.';
                }
                field("No. Of Try"; Rec."No. Of Try")
                {
                    ToolTip = 'Specifies the number of try.';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the date and time of creation.';
                }
                field(ViewResponse; ViewResponseLbl)
                {
                    Caption = 'View response';
                    ToolTip = 'Allows to view the response of the detailed bus queue.';

                    trigger OnDrillDown()
                    var
                        BusQueueResponse: Record "Bus Queue Response";
                    begin
                        BusQueueResponse.SetRange("Bus Queue Detailed Entry No.", Rec."Entry No.");
                        Page.Run(Page::"Bus Queue Responses", BusQueueResponse);
                    end;
                }
            }
        }
    }

    var
        ViewResponseLbl: Label 'View response';
}