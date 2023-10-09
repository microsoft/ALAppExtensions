namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.History;
using System.Threading;

/// <summary>
/// Page Shpfy Activities (ID 30100).
/// </summary>
page 30100 "Shpfy Activities"
{
    Caption = 'Shopify Activities';
    PageType = CardPart;
    SourceTable = "Shpfy Cue";
    RefreshOnActivate = true;
    ShowFilter = false;

    layout
    {
        area(Content)
        {
            cuegroup(ShopInfo)
            {
                Caption = 'Shopify Shop info';
                field("Unmapped Customers"; Rec."Unmapped Customers")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "Shpfy Customers";
                    ToolTip = 'Specifies the number of imported customers that aren''t mapped.';
                }
                field(UnmappedProducts; Rec."Unmapped Products")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "Shpfy Products";
                    ToolTip = 'Specifies the number of imported products that aren''t mapped.';
                }
                field(UnprocessedOrders; Rec."Unprocessed Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "Shpfy Orders";
                    ToolTip = 'Specifies the number of imported orders that aren''t processed.';
                }
                field(UnprocessedShipment; Rec."Unprocessed Shipments")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of shipments that aren''t processed.';

                    trigger OnDrillDown()
                    var
                        SalesShipmentHeader: Record "Sales Shipment Header";
                    begin
                        SalesShipmentHeader.SetFilter("Shpfy Order Id", '<>0');
                        SalesShipmentHeader.SetFilter("Shpfy Fulfillment Id", '0');
                        Page.Run(Page::"Posted Sales Shipments", SalesShipmentHeader);
                    end;
                }
                field(ShipmentErrors; Rec."Shipment Errors")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of shipments that are failed to synchronize.';

                    trigger OnDrillDown()
                    var
                        SalesShipmentHeader: Record "Sales Shipment Header";
                    begin
                        SalesShipmentHeader.SetFilter("Shpfy Order Id", '<>0');
                        SalesShipmentHeader.SetFilter("Shpfy Fulfillment Id", '-1');
                        Page.Run(Page::"Posted Sales Shipments", SalesShipmentHeader);
                    end;
                }
                field(SynchronizationErrors; Rec."Synchronization Errors")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of synchronization errors.';

                    trigger OnDrillDown()
                    var
                        JobQueueLogEntry: Record "Job Queue Log Entry";
                    begin
                        JobQueueLogEntry.SetRange(Status, JobQueueLogEntry.Status::Error);
                        JobQueueLogEntry.SetRange("Object Type to Run", JobQueueLogEntry."Object Type to Run"::Report);
                        JobQueueLogEntry.SetFilter("Object Id to Run", '%1|%2|%3|%4|%5|%6|%7', Report::"Shpfy Sync Orders from Shopify",
                                                                Report::"Shpfy Sync Shipm. to Shopify",
                                                                Report::"Shpfy Sync Products",
                                                                Report::"Shpfy Sync Stock to Shopify",
                                                                Report::"Shpfy Sync Images",
                                                                Report::"Shpfy Sync Customers",
                                                                Report::"Shpfy Sync Payments");
                        Page.Run(Page::"Job Queue Log Entries", JobQueueLogEntry);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
            Commit();
        end;
    end;
}