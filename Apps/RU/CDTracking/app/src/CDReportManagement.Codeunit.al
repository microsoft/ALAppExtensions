#pragma warning disable AA0247
codeunit 14101 "CD Report Management"
{

    var
        ItemTrackingManagement: Codeunit "Item Tracking Management";
        ValueMissingErr: Label '%1 is missing for %2 items %3 in line %4.', Comment = '%1 tracking caption, %2 - quantity, %3 - item no, %4 - line no.';

    // report "Order Factura Invoice (A)"

    [EventSubscriber(ObjectType::Report, Report::"Order Factura-Invoice (A)", 'OnItemTrackingLineOnBeforeTransferReportValues', '', false, false)]
    local procedure OrderFacturaInvoiceOnItemTrackingLineOnBeforeTransferReportValues(SalesLine: Record "Sales Line"; var TempTrackingSpecification: Record "Tracking Specification" temporary; var TempTrackingSpecification2: Record "Tracking Specification" temporary; var MultipleCD: Boolean; var CDNo: Text; var CountryCode: Code[10]; var CountryName: Text; var TrackingSpecCount: Integer)
    begin
        SalesOrderRetrieveCDSpecification(
            SalesLine, TempTrackingSpecification, TempTrackingSpecification2, MultipleCD, CDNo, CountryCode, CountryName, TrackingSpecCount);
    end;

    procedure SalesOrderRetrieveCDSpecification(SalesLine: Record "Sales Line"; var TempTrackingSpecification: Record "Tracking Specification" temporary; var TempTrackingSpecification2: Record "Tracking Specification" temporary; var MultipleCD: Boolean; var CDNo: Text; var CountryCode: Code[10]; var CountryName: Text; var TrackingSpecCount: Integer)
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ItemTrackingSetup: Record "Item Tracking Setup";
        PackageNoInformation: Record "Package No. Information";
        ReservationEntry: Record "Reservation Entry";
        ReservationEntry2: Record "Reservation Entry";
        TrackedQty: Decimal;
    begin
        MultipleCD := false;
        CDNo := '';
        CountryName := '';
        CountryCode := '';
        TrackedQty := 0;

        case SalesLine.Type of
            SalesLine.Type::Item:
                begin
                    Item.Get(SalesLine."No.");
                    if Item."Item Tracking Code" <> '' then begin
                        SalesLine.TestField("Appl.-to Item Entry", 0);
                        SalesLine.TestField("Appl.-from Item Entry", 0);
                        ItemTrackingCode.Code := Item."Item Tracking Code";
                        ItemTrackingManagement.GetItemTrackingSetup(ItemTrackingCode, "Item Ledger Entry Type"::Sale, false, ItemTrackingSetup);
                        if ItemTrackingSetup."Package No. Required" then begin
                            TempTrackingSpecification.SetSourceFilter(
                                DATABASE::"Sales Line", SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", true);
                            TempTrackingSpecification2.DeleteAll();
                            if TempTrackingSpecification.FindSet() then
                                repeat
                                    TempTrackingSpecification2.SetRange("Package No.", TempTrackingSpecification."Package No.");
                                    if TempTrackingSpecification2.FindFirst() then begin
                                        TempTrackingSpecification2."Quantity (Base)" += TempTrackingSpecification."Quantity (Base)";
                                        TrackedQty += TempTrackingSpecification."Quantity (Base)";
                                        TempTrackingSpecification2.Modify();
                                    end else begin
                                        TempTrackingSpecification2.Init();
                                        TempTrackingSpecification2 := TempTrackingSpecification;
                                        TempTrackingSpecification2.TestField("Quantity (Base)");
                                        TrackedQty += TempTrackingSpecification."Quantity (Base)";
                                        TempTrackingSpecification2."Lot No." := '';
                                        TempTrackingSpecification2."Serial No." := '';
                                        TempTrackingSpecification2.Insert();
                                    end;
                                until TempTrackingSpecification.Next() = 0;
                            TempTrackingSpecification2.Reset();
                            TrackingSpecCount := TempTrackingSpecification2.Count();
                            if TrackingSpecCount = 0 then begin
                                // find reservation specification
                                SalesLine.CalcFields("Reserved Qty. (Base)");
                                if SalesLine."Reserved Qty. (Base)" <> 0 then begin
                                    ReservationEntry.SetSourceFilter(
                                        DATABASE::"Sales Line", SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", true);
                                    if ReservationEntry.FindSet() then
                                        repeat
                                            ReservationEntry2.Get(ReservationEntry."Entry No.", not ReservationEntry.Positive);
                                            TempTrackingSpecification2.Init();
                                            TempTrackingSpecification2.TransferFields(ReservationEntry2);
                                            TrackedQty += TempTrackingSpecification2."Quantity (Base)";
                                            TempTrackingSpecification2."Lot No." := '';
                                            TempTrackingSpecification2."Serial No." := '';
                                            TempTrackingSpecification2.Insert();
                                        until ReservationEntry.Next() = 0;
                                end;
                            end;

                            if TrackedQty <> SalesLine."Qty. to Ship (Base)" then
                                Error(ValueMissingErr,
                                  TempTrackingSpecification2.FieldCaption("Package No."),
                                  SalesLine."Qty. to Ship (Base)" - TrackedQty,
                                  TempTrackingSpecification2."Item No.", SalesLine."Line No.");

                            TempTrackingSpecification2.Reset();
                            TrackingSpecCount := TempTrackingSpecification2.Count();
                            case TrackingSpecCount of
                                1:
                                    begin
                                        TempTrackingSpecification2.FindFirst();
                                        CDNo := TempTrackingSpecification2."Package No.";
                                        if PackageNoInformation.Get(
                                             TempTrackingSpecification2."Item No.", TempTrackingSpecification2."Variant Code", TempTrackingSpecification2."Package No.")
                                        then begin
                                            CountryName := PackageNoInformation.GetCountryName();
                                            CountryCode := PackageNoInformation.GetCountryLocalCode();
                                        end;
                                    end;
                                else
                                    MultipleCD := true;
                            end;
                        end;
                    end;
                end;
            SalesLine.Type::"Fixed Asset":
                GetFAInfo(SalesLine."No.", CDNo, CountryName);
        end;
    end;

    // report 12484 "Posted Cr. M. Factura-Invoice"

    [EventSubscriber(ObjectType::Report, Report::"Posted Cr. M. Factura-Invoice", 'OnItemTrackingLineOnBeforeTransferReportValues', '', false, false)]
    local procedure PostedCrMFacturaInvoiceOnItemTrackingLineOnBeforeTransferReportValues(SalesCrMemoLine: Record "Sales Cr.Memo Line"; var TempTrackingSpecification: Record "Tracking Specification" temporary; var TempTrackingSpecification2: Record "Tracking Specification" temporary; var MultipleCD: Boolean; var CDNo: Text; var CountryCode: Code[10]; var CountryName: Text; var TrackingSpecCount: Integer)
    begin
        PostedSalesCrMemoRetrieveCDSpecification(
            SalesCrMemoLine, TempTrackingSpecification, TempTrackingSpecification2, MultipleCD, CDNo, CountryCode, CountryName, TrackingSpecCount);
    end;

    local procedure PostedSalesCrMemoRetrieveCDSpecification(SalesCrMemoLine: Record "Sales Cr.Memo Line"; var TempTrackingSpecification: Record "Tracking Specification" temporary; var TempTrackingSpecification2: Record "Tracking Specification" temporary; var MultipleCD: Boolean; var CDNo: Text; var CountryCode: Code[10]; var CountryName: Text; var TrackingSpecCount: Integer)
    var
        PackageNoInformation: Record "Package No. Information";
    begin
        MultipleCD := false;
        CDNo := '';
        CountryName := '-';
        CountryCode := '';

        case SalesCrMemoLine.Type of
            SalesCrMemoLine.Type::Item:
                begin
                    TempTrackingSpecification.SetSourceFilter(
                        DATABASE::"Sales Cr.Memo Line", 0, SalesCrMemoLine."Document No.", SalesCrMemoLine."Line No.", true);
                    TempTrackingSpecification2.DeleteAll();
                    if TempTrackingSpecification.FindSet() then
                        repeat
                            TempTrackingSpecification2.SetRange("Package No.", TempTrackingSpecification."Package No.");
                            if TempTrackingSpecification2.FindFirst() then begin
                                TempTrackingSpecification2."Quantity (Base)" += TempTrackingSpecification."Quantity (Base)";
                                TempTrackingSpecification2.Modify();
                            end else begin
                                TempTrackingSpecification2.Init();
                                TempTrackingSpecification2 := TempTrackingSpecification;
                                TempTrackingSpecification2.TestField("Quantity (Base)");
                                TempTrackingSpecification2."Lot No." := '';
                                TempTrackingSpecification2."Serial No." := '';
                                TempTrackingSpecification2.Insert();
                            end;
                        until TempTrackingSpecification.Next() = 0;
                    TempTrackingSpecification2.Reset();
                    TrackingSpecCount := TempTrackingSpecification2.Count();
                    case TrackingSpecCount of
                        1:
                            begin
                                TempTrackingSpecification2.FindFirst();
                                CDNo := TempTrackingSpecification2."Package No.";
                                if PackageNoInformation.Get(
                                     TempTrackingSpecification2."Item No.", TempTrackingSpecification2."Variant Code", TempTrackingSpecification2."Package No.")
                                then begin
                                    CountryName := PackageNoInformation.GetCountryName();
                                    CountryCode := PackageNoInformation.GetCountryLocalCode();
                                end;
                            end;
                        else
                            MultipleCD := true;
                    end;
                end;
            SalesCrMemoLine.Type::"Fixed Asset":
                GetFAInfo(SalesCrMemoLine."No.", CDNo, CountryName);
        end;
    end;

    // report 12418 "Posted Factura-Invoice (A)"

    [EventSubscriber(ObjectType::Report, Report::"Posted Factura-Invoice (A)", 'OnItemTrackingLineOnBeforeTransferReportValues', '', false, false)]
    local procedure PostedFacturaInvoiceOnItemTrackingLineOnBeforeTransferReportValues(SalesInvoiceLine: Record "Sales Invoice Line"; var TempTrackingSpecification: Record "Tracking Specification" temporary; var TempTrackingSpecification2: Record "Tracking Specification" temporary; var MultipleCD: Boolean; var CDNo: Text; var CountryCode: Code[10]; var CountryName: Text; var TrackingSpecCount: Integer)
    begin
        PostedSalesInvoiceRetrieveCDSpecification(
            SalesInvoiceLine, TempTrackingSpecification, TempTrackingSpecification2, MultipleCD, CDNo, CountryCode, CountryName, TrackingSpecCount);
    end;

    local procedure PostedSalesInvoiceRetrieveCDSpecification(SalesInvoiceLine: Record "Sales Invoice Line"; var TempTrackingSpecification: Record "Tracking Specification" temporary; var TempTrackingSpecification2: Record "Tracking Specification" temporary; var MultipleCD: Boolean; var CDNo: Text; var CountryCode: Code[10]; var CountryName: Text; var TrackingSpecCount: Integer)
    var
        PackageNoInformation: Record "Package No. Information";
    begin
        MultipleCD := false;
        CDNo := '';
        CountryName := '-';
        CountryCode := '';

        case SalesInvoiceLine.Type of
            SalesInvoiceLine.Type::Item:
                begin
                    TempTrackingSpecification.SetSourceFilter(
                        DATABASE::"Sales Invoice Line", 0, SalesInvoiceLine."Document No.", SalesInvoiceLine."Line No.", true);
                    TempTrackingSpecification2.DeleteAll();
                    if TempTrackingSpecification.FindSet() then
                        repeat
                            TempTrackingSpecification2.SetRange("Package No.", TempTrackingSpecification."Package No.");
                            if TempTrackingSpecification2.FindFirst() then begin
                                TempTrackingSpecification2."Quantity (Base)" += TempTrackingSpecification."Quantity (Base)";
                                TempTrackingSpecification2.Modify();
                            end else begin
                                TempTrackingSpecification2.Init();
                                TempTrackingSpecification2 := TempTrackingSpecification;
                                TempTrackingSpecification2.TestField("Quantity (Base)");
                                TempTrackingSpecification2."Lot No." := '';
                                TempTrackingSpecification2."Serial No." := '';
                                TempTrackingSpecification2.Insert();
                            end;
                        until TempTrackingSpecification.Next() = 0;
                    TempTrackingSpecification2.Reset();
                    TrackingSpecCount := TempTrackingSpecification2.Count();
                    case TrackingSpecCount of
                        1:
                            begin
                                TempTrackingSpecification2.FindFirst();
                                CDNo := TempTrackingSpecification2."Package No.";
                                if PackageNoInformation.Get(
                                     TempTrackingSpecification2."Item No.", TempTrackingSpecification2."Variant Code", TempTrackingSpecification2."Package No.")
                                then begin
                                    CountryName := PackageNoInformation.GetCountryName();
                                    CountryCode := PackageNoInformation.GetCountryLocalCode();
                                end;
                            end;
                        else
                            MultipleCD := true;
                    end;
                end;
            SalesInvoiceLine.Type::"Fixed Asset":
                GetFAInfo(SalesInvoiceLine."No.", CDNo, CountryName);
        end;
    end;

    // report 14939 "Pstd. Purch. Factura-Invoice"

    [EventSubscriber(ObjectType::Report, Report::"Pstd. Purch. Factura-Invoice", 'OnItemTrackingLineOnBeforeTransferReportValues', '', false, false)]
    local procedure PostedPurchFacturaInvoiceOnItemTrackingLineOnBeforeTransferReportValues(PurchInvLine: Record "Purch. Inv. Line"; var TempTrackingSpecification: Record "Tracking Specification" temporary; var TempTrackingSpecification2: Record "Tracking Specification" temporary; var MultipleCD: Boolean; var CDNo: Text; var CountryCode: Code[10]; var CountryName: Text; var TrackingSpecCount: Integer)
    begin
        PostedPurchInvoiceRetrieveCDSpecification(
            PurchInvLine, TempTrackingSpecification, TempTrackingSpecification2, MultipleCD, CDNo, CountryCode, CountryName, TrackingSpecCount);
    end;

    local procedure PostedPurchInvoiceRetrieveCDSpecification(PurchInvLine: Record "Purch. Inv. Line"; var TempTrackingSpecification: Record "Tracking Specification" temporary; var TempTrackingSpecification2: Record "Tracking Specification" temporary; var MultipleCD: Boolean; var CDNo: Text; var CountryCode: Code[10]; var CountryName: Text; var TrackingSpecCount: Integer)
    var
        PackageNoInformation: Record "Package No. Information";
    begin
        MultipleCD := false;
        CDNo := '';
        CountryName := '-';
        CountryCode := '';

        case PurchInvLine.Type of
            PurchInvLine.Type::Item:
                begin
                    TempTrackingSpecification.SetSourceFilter(
                        DATABASE::"Purch. Inv. Line", 0, PurchInvLine."Document No.", PurchInvLine."Line No.", true);
                    TempTrackingSpecification2.DeleteAll();
                    if TempTrackingSpecification.FindSet() then
                        repeat
                            TempTrackingSpecification2.SetRange("Package No.", TempTrackingSpecification."Package No.");
                            if TempTrackingSpecification2.FindFirst() then begin
                                TempTrackingSpecification2."Quantity (Base)" += TempTrackingSpecification."Quantity (Base)";
                                TempTrackingSpecification2.Modify();
                            end else begin
                                TempTrackingSpecification2.Init();
                                TempTrackingSpecification2 := TempTrackingSpecification;
                                TempTrackingSpecification2.TestField("Quantity (Base)");
                                TempTrackingSpecification2."Lot No." := '';
                                TempTrackingSpecification2."Serial No." := '';
                                TempTrackingSpecification2.Insert();
                            end;
                        until TempTrackingSpecification.Next() = 0;
                    TempTrackingSpecification2.Reset();
                    TrackingSpecCount := TempTrackingSpecification2.Count();
                    case TrackingSpecCount of
                        1:
                            begin
                                TempTrackingSpecification2.FindFirst();
                                CDNo := TempTrackingSpecification2."Package No.";
                                if PackageNoInformation.Get(
                                     TempTrackingSpecification2."Item No.", TempTrackingSpecification2."Variant Code", TempTrackingSpecification2."Package No.")
                                then begin
                                    CountryName := PackageNoInformation.GetCountryName();
                                    CountryCode := PackageNoInformation.GetCountryLocalCode();
                                end;
                            end;
                        else
                            MultipleCD := true;
                    end;
                end;
            PurchInvLine.Type::"Fixed Asset":
                GetFAInfo(PurchInvLine."No.", CDNo, CountryName);
        end;
    end;

    procedure GetFAInfo(FANo: Code[20]; var CDNo: Text; var CountryName: Text)
    var
        FixedAsset: Record "Fixed Asset";
        CDFAInformation: Record "CD FA Information";
    begin
        CDNo := '';
        CountryName := '';

        FixedAsset.Get(FANo);
        if FixedAsset."CD Number" <> '' then begin
            CDNo := FixedAsset."CD Number";
            CDFAInformation.Get(FixedAsset."No.", FixedAsset."CD Number");
            CountryName := CDFAInformation.GetCountryName();
        end;
    end;
}
