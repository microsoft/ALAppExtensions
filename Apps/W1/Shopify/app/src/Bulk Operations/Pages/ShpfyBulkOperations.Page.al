namespace Microsoft.Integration.Shopify;

page 30152 "Shpfy Bulk Operations"
{
    ApplicationArea = All;
    Caption = 'Shopify Bulk Operations';
    PageType = List;
    SourceTable = "Shpfy Bulk Operation";
    UsageCategory = Lists;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    SourceTableView = sorting(SystemCreatedAt) order(descending);

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Bulk Operation Id"; Rec."Bulk Operation Id")
                {
                    Caption = 'Id';
                    ToolTip = 'Specifies the unique identifier of the bulk operation.';
                }
                field("Shop Code"; Rec."Shop Code")
                {
                    Caption = 'Shop Code';
                    ToolTip = 'Specifies the shop code of the shop that the bulk operation belongs to.';
                }
                field(Type; Rec.Type)
                {
                    Caption = 'Type';
                    ToolTip = 'Specifies the type of the bulk operation.';
                }
                field(Description; Rec.Name)
                {
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the bulk operation.';
                }
                field(Status; CurrentStatus)
                {
                    Caption = 'Status';
                    ToolTip = 'Specifies the status of the bulk operation.';
                }
                field("Completed At"; Rec."Completed At")
                {
                    Caption = 'Completed At';
                    ToolTip = 'Specifies the date and time when the bulk operation was completed.';
                }
                field("Error Code"; Rec."Error Code")
                {
                    Caption = 'Error Code';
                    ToolTip = 'Specifies the error code of the bulk operation.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetData)
            {
                ApplicationArea = All;
                Caption = 'Get Data';
                Image = Download;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Get bulk operation data from Shopify.';

                trigger OnAction();
                var
                    Shop: Record "Shpfy Shop";
                    BulkOperationMgt: Codeunit "Shpfy Bulk Operation Mgt.";
                begin
                    Shop.Get(Rec."Shop Code");
                    BulkOperationMgt.GetBulkOperationResult(Shop, Rec."Bulk Operation Id");
                end;
            }
            action(Refresh)
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Refresh status of bulk operations.';

                trigger OnAction();
                var
                    Shop: Record "Shpfy Shop";
                    BulkOperation: Record "Shpfy Bulk Operation";
                    BulkOperationMgt: Codeunit "Shpfy Bulk Operation Mgt.";
                    BulkOperationStatus: Enum "Shpfy Bulk Operation Status";
                begin
                    BulkOperation.SetFilter(Status, '%1|%2', BulkOperation.Status::Created, BulkOperation.Status::Running);
                    if BulkOperation.FindSet() then
                        repeat
                            Shop.Get(BulkOperation."Shop Code");
                            BulkOperationMgt.UpdateBulkOperationStatus(Shop, BulkOperation."Bulk Operation Id", BulkOperation.Type, BulkOperationStatus);
                        until BulkOperation.Next() = 0;
                end;
            }
            action(Delete7Days)
            {
                ApplicationArea = All;
                Caption = 'Delete Entries Older Than 7 Days';
                Image = ClearLog;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Clear the list of bulk operations that are older than 7 days.';

                trigger OnAction();
                var
                    BulkOperationMgt: Codeunit "Shpfy Bulk Operation Mgt.";
                begin
                    BulkOperationMgt.DeleteEntries(Rec, 7);
                end;
            }
        }
    }

    var
        CurrentStatus: Text;
        InProgressLbl: Label 'In Progress';
        ErrorLbl: Label 'Error';
        CompletedLbl: Label 'Completed';

    trigger OnAfterGetRecord()
    begin
        if Rec.Status in [Rec.Status::Created, Rec.Status::Running, Rec.Status::Canceled] then
            CurrentStatus := InProgressLbl;
        if Rec.Status in [Rec.Status::Canceled, Rec.Status::Failed, Rec.Status::Expired] then
            CurrentStatus := ErrorLbl;
        if Rec.Status = Rec.Status::Completed then
            CurrentStatus := CompletedLbl;
    end;
}