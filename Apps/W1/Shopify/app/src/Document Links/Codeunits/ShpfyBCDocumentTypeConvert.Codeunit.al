codeunit 30259 "Shpfy BC Document Type Convert"
{
    var
        NotSupportedErr: Label 'Not Supported';

    procedure Convert(SalesDocumentType: enum "Sales Document Type"): enum "Shpfy BC Document Type";
    begin
        case SalesDocumentType of
            "Sales Document Type"::Order:
                exit("Shpfy BC Document Type"::"Sales Order");
            "Sales Document Type"::Invoice:
                exit("Shpfy BC Document Type"::"Sales Invoice");
            "Sales Document Type"::"Return Order":
                exit("Shpfy BC Document Type"::"Sales Return Order");
            "Sales Document Type"::"Credit Memo":
                exit("Shpfy BC Document Type"::"Sales Credit Memo");
        end;
        exit("Shpfy BC Document Type"::" ");
    end;

    procedure CanConvert(RecordVariant: Variant): Boolean
    var
        RecordRef: RecordRef;
    begin
        if RecordVariant.IsRecord then begin
            RecordRef.GetTable(RecordVariant);
            case RecordRef.Number of
                Database::"Sales Header",
                Database::"Sales Shipment Header",
                Database::"Sales Invoice Header",
                Database::"Return Receipt Header",
                Database::"Sales Cr.Memo Header":
                    exit(true);
            end;
        end;
    end;

    procedure Convert(RecordVariant: Variant): enum "Shpfy BC Document Type";
    var
        RecordRef: RecordRef;
        SalesDocumentType: enum "Sales Document Type";
    begin
        if RecordVariant.IsRecord then begin
            RecordRef.GetTable(RecordVariant);
            case RecordRef.Number of
                Database::"Sales Header":
                    begin
                        SalesDocumentType := RecordRef.Field(1).Value;
                        exit(Convert(SalesDocumentType));
                    end;
                Database::"Sales Shipment Header":
                    exit("Shpfy BC Document Type"::"Posted Sales Shipment");
                Database::"Sales Invoice Header":
                    exit("Shpfy BC Document Type"::"Posted Sales Invoice");
                Database::"Return Receipt Header":
                    exit("Shpfy BC Document Type"::"Posted Return Receipt");
                Database::"Sales Cr.Memo Header":
                    exit("Shpfy BC Document Type"::"Posted Sales Credit Memo");
            end;
        end;
        Error(NotSupportedErr);
    end;

    procedure CanConvert(BCDocumentType: enum "Shpfy BC Document Type"): Boolean
    begin
        case BCDocumentType of
            "Shpfy BC Document Type"::"Sales Order",
            "Shpfy BC Document Type"::"Sales Invoice",
            "Shpfy BC Document Type"::"Sales Return Order",
            "Shpfy BC Document Type"::"Sales Credit Memo":
                exit(true);
        end;
    end;

    procedure Convert(BCDocumentType: enum "Shpfy BC Document Type"): enum "Sales Document Type";
    begin
        case BCDocumentType of
            "Shpfy BC Document Type"::"Sales Order":
                exit("Sales Document Type"::Order);
            "Shpfy BC Document Type"::"Sales Invoice":
                exit("Sales Document Type"::Invoice);
            "Shpfy BC Document Type"::"Sales Return Order":
                exit("Sales Document Type"::"Return Order");
            "Shpfy BC Document Type"::"Sales Credit Memo":
                exit("Sales Document Type"::"Credit Memo");
        end;
        Error(NotSupportedErr);
    end;
}
