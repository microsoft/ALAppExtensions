namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.History;
using System.Threading;
using System.Visualization;

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
                field("Unmapped Companies"; Rec."Unmapped Companies")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "Shpfy Companies";
                    ToolTip = 'Specifies the number of imported companoes that aren''t mapped.';
                    Visible = B2BEnabled;
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
                        JobQueueLogEntry.SetFilter("Object Id to Run", '%1|%2|%3|%4|%5|%6|%7|%8|%9|%10', Report::"Shpfy Sync Orders from Shopify",
                                                                Report::"Shpfy Sync Shipm. to Shopify",
                                                                Report::"Shpfy Sync Products",
                                                                Report::"Shpfy Sync Stock to Shopify",
                                                                Report::"Shpfy Sync Images",
                                                                Report::"Shpfy Sync Customers",
                                                                Report::"Shpfy Sync Payments",
                                                                Report::"Shpfy Sync Companies",
                                                                Report::"Shpfy Sync Catalogs",
                                                                Report::"Shpfy Sync Catalog Prices");
                        Page.Run(Page::"Job Queue Log Entries", JobQueueLogEntry);
                    end;
                }
                field(UnprocessedOrderUpdates; Rec."Unprocessed Order Updates")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of order updates that aren''t processed.';
                    DrillDownPageId = "Shpfy Orders";
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Set Up Cues")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Set Up Cues';
                Image = Setup;
                ToolTip = 'Set up the cues (status tiles) related to the role.';

                trigger OnAction()
                var
                    CuesAndKpis: Codeunit "Cues And KPIs";
                    CueRecordRef: RecordRef;
                begin
                    CueRecordRef.GetTable(Rec);
                    CuesAndKpis.OpenCustomizePageForCurrentUser(CueRecordRef.Number);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        Shop: Record "Shpfy Shop";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        ApiVersion: Text;
        ApiVersionExpiryDateTime: DateTime;
    begin
        Rec.Reset();
        if not Rec.Get() then
            if Rec.WritePermission then begin
                Rec.Init();
                Rec.Insert();
                Commit();
            end;

        Shop.SetRange("B2B Enabled", true);
        B2BEnabled := not Shop.IsEmpty();

        Shop.Reset();
        Shop.SetRange(Enabled, true);
        if Shop.FindFirst() then begin
            ApiVersion := CommunicationMgt.GetApiVersion();
            ApiVersionExpiryDateTime := CommunicationMgt.GetApiVersionExpiryDate();
            Shop.CheckApiVersionExpiryDate(ApiVersion, ApiVersionExpiryDateTime);
        end;
    end;

    var
        B2BEnabled: Boolean;
}