namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.History;
using System.Threading;

/// <summary>
/// Table Shpfy Cue (ID 30100).
/// </summary>
table 30100 "Shpfy Cue"
{
    Access = Internal;
    Caption = 'Shopify Cue';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; "Unmapped Customers"; Integer)
        {
            CalcFormula = count("Shpfy Customer" where("Customer No." = const('')));
            Caption = 'Unmapped Customers';
            FieldClass = FlowField;
        }
        field(3; "Unmapped Products"; Integer)
        {
            CalcFormula = count("Shpfy Product" where("Item No." = const('')));
            Caption = 'Unmapped Products';
            FieldClass = FlowField;
        }
        field(4; "Unprocessed Orders"; Integer)
        {
            CalcFormula = count("Shpfy Order Header" where(Processed = const(false)));
            Caption = 'Unprocessed Orders';
            FieldClass = FlowField;
        }
        field(5; "Unprocessed Shipments"; Integer)
        {
            CalcFormula = count("Sales Shipment Header" where("Shpfy Order Id" = filter(<> 0), "Shpfy Fulfillment Id" = filter(= 0)));
            Caption = 'Unprocessed Shipments';
            FieldClass = FlowField;
        }
        field(6; "Synchronization Errors"; Integer)
        {
            CalcFormula = count("Job Queue Log Entry" where(Status = const(Error),
                                                            "Object Type to Run" = const(Report),
                                                            "Object ID to Run" = filter(Report::"Shpfy Sync Orders from Shopify" |
                                                                Report::"Shpfy Sync Shipm. to Shopify" |
                                                                Report::"Shpfy Sync Products" |
                                                                Report::"Shpfy Sync Stock to Shopify" |
                                                                Report::"Shpfy Sync Images" |
                                                                Report::"Shpfy Sync Customers" |
                                                                Report::"Shpfy Sync Payments" |
                                                                Report::"Shpfy Sync Companies" |
                                                                Report::"Shpfy Sync Catalogs" |
                                                                Report::"Shpfy Sync Catalog Prices")));
            Caption = 'Synchronization Errors';
            FieldClass = FlowField;
        }
        field(7; "Shipment Errors"; Integer)
        {
            CalcFormula = count("Sales Shipment Header" where("Shpfy Order Id" = filter(<> 0), "Shpfy Fulfillment Id" = filter(= -1)));
            Caption = 'Shipments Errors';
            FieldClass = FlowField;
        }
        field(8; "Unprocessed Order Updates"; Integer)
        {
            CalcFormula = count("Shpfy Order Header" where("Has Order State Error" = const(true)));
            Caption = 'Unprocessed Order Updates';
            FieldClass = FlowField;
        }
        field(9; "Unmapped Companies"; Integer)
        {
            CalcFormula = count("Shpfy Company" where("Customer No." = const('')));
            Caption = 'Unmapped Companies';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}