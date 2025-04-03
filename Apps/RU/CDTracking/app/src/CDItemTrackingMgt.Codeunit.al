#pragma warning disable AA0247
codeunit 14100 "CD Item Tracking Mgt."
{

    var
        ItemTrackingDoesNotMatchErr: Label 'Item Tracking does not match for line %1, %2 %3, %4 %5', Comment = '%1 = line no., %2 = line type, %3 = item no., %4 = field caption, %5 = qty. to ship';
        ItemTrackingMatchErr: Label 'The %1 does not match the quantity defined in item tracking.', Comment = '%1 = error text';
        CDTxt: Label 'CD', Comment = 'Abbreviation for Customs Declaration';

    // ReleaseSalesDocument.Codeunit.al
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnCodeOnCheckTracking', '', false, false)]
    local procedure ReleaseSalesDocumentOnCodeOnCheckTracking(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        TestSalesTrackingSpecification(SalesHeader, SalesLine);
    end;

    procedure TestSalesTrackingSpecification(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        SalesLineToCheck: Record "Sales Line";
        ReservationEntry: Record "Reservation Entry";
        ItemTrackingCode: Record "Item Tracking Code";
        ItemTrackingSetup: Record "Item Tracking Setup";
        CDLocationSetup: Record "CD Location Setup";
        Item: Record Item;
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        ItemTrackingManagement: Codeunit "Item Tracking Management";
        ErrorFieldCaption: Text;
        SignFactor: Integer;
        SalesLineQtyHandled: Decimal;
        SalesLineQtyToHandle: Decimal;
        TrackingQtyHandled: Decimal;
        TrackingQtyToHandle: Decimal;
        Inbound: Boolean;
        CheckSalesLine: Boolean;
    begin
        // if a SalesLine is posted with ItemTracking then the whole quantity of
        // the regarding SalesLine has to be post with Item-Tracking

        SalesLine.SetRange("Drop Shipment");

        if SalesHeader."Document Type" in
          [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Return Order"] = false
        then
            exit;

        TrackingQtyToHandle := 0;
        TrackingQtyHandled := 0;

        SalesLineToCheck.Copy(SalesLine);
        SalesLineToCheck.SetRange(Type, SalesLineToCheck.Type::Item);
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
            SalesLineToCheck.SetFilter("Qty. to Ship", '<>%1', 0);
            ErrorFieldCaption := SalesLineToCheck.FieldCaption("Qty. to Ship");
        end else begin
            SalesLineToCheck.SetFilter("Return Qty. to Receive", '<>%1', 0);
            ErrorFieldCaption := SalesLineToCheck.FieldCaption("Return Qty. to Receive");
        end;

        if SalesLineToCheck.FindSet() then begin
            ReservationEntry."Source Type" := DATABASE::"Sales Line";
            ReservationEntry."Source Subtype" := SalesHeader."Document Type".AsInteger();
            SignFactor := CreateReservEntry.SignFactor(ReservationEntry);
            repeat
                // Only Item where no SerialNo or LotNo is required
                Item.Get(SalesLineToCheck."No.");
                if Item."Item Tracking Code" <> '' then begin
                    Inbound := (SalesLineToCheck.Quantity * SignFactor) > 0;
                    ItemTrackingCode.Code := Item."Item Tracking Code";
                    if CDLocationSetup.Get(Item."Item Tracking Code", SalesLineToCheck."Location Code") then;
                    ItemTrackingManagement.GetItemTrackingSetup(ItemTrackingCode, "Item ledger Entry Type"::Sale, Inbound, ItemTrackingSetup);
                    GetCDLocationSetup(ItemTrackingCode, CDLocationSetup, ItemTrackingSetup);
                    CheckSalesLine := ItemTrackingSetup."Package No. Required" and CDLocationSetup."CD Sales Check on Release";
                    if CheckSalesLine then
                        if not GetSalesTrackingQuantities(SalesLineToCheck, 0, TrackingQtyToHandle, TrackingQtyHandled) then
                            if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then
                                Error(ItemTrackingDoesNotMatchErr,
                                  SalesLineToCheck."Line No.", Format(SalesLineToCheck.Type), SalesLineToCheck."No.",
                                  SalesLineToCheck.FieldCaption("Qty. to Ship"), SalesLineToCheck."Qty. to Ship")
                            else
                                Error(ItemTrackingDoesNotMatchErr,
                                  SalesLineToCheck."Line No.", Format(SalesLineToCheck.Type), SalesLineToCheck."No.",
                                  SalesLineToCheck.FieldCaption("Return Qty. to Receive"), SalesLineToCheck."Return Qty. to Receive")
                end else
                    CheckSalesLine := false;

                TrackingQtyToHandle := 0;
                TrackingQtyHandled := 0;

                if CheckSalesLine then begin
                    if CDLocationSetup."CD Info. Must Exist" then
                        GetSalesTrackingQuantities(SalesLineToCheck, 2, TrackingQtyToHandle, TrackingQtyHandled);
                    GetSalesTrackingQuantities(SalesLineToCheck, 1, TrackingQtyToHandle, TrackingQtyHandled);
                    TrackingQtyToHandle := TrackingQtyToHandle * SignFactor;
                    TrackingQtyHandled := TrackingQtyHandled * SignFactor;
                    if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
                        SalesLineQtyToHandle := SalesLineToCheck."Qty. to Ship (Base)";
                        SalesLineQtyHandled := SalesLineToCheck."Qty. Shipped (Base)";
                    end else begin
                        SalesLineQtyToHandle := SalesLineToCheck."Return Qty. to Receive (Base)";
                        SalesLineQtyHandled := SalesLineToCheck."Return Qty. Received (Base)";
                    end;
                    if ((TrackingQtyHandled + TrackingQtyToHandle) <> (SalesLineQtyHandled + SalesLineQtyToHandle)) or
                       (TrackingQtyToHandle <> SalesLineQtyToHandle)
                    then
                        Error(ItemTrackingMatchErr, ErrorFieldCaption);
                end;
            until SalesLineToCheck.Next() = 0;
        end;
    end;

    local procedure GetSalesTrackingQuantities(SalesLine: Record "Sales Line"; FunctionType: Option CheckTrackingExists,GetQty,CheckTempCDNo; var TrackingQtyToHandle: Decimal; var TrackingQtyHandled: Decimal): Boolean
    var
        Item: Record Item;
        TrackingSpecification: Record "Tracking Specification";
        ReservationEntry: Record "Reservation Entry";
        PackageNoInformation: Record "Package No. Information";
        CDLocationSetup: Record "CD Location Setup";
    begin
        TrackingSpecification.SetSourceFilter(DATABASE::"Sales Line", SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", true);
        TrackingSpecification.SetSourceFilter('', 0);

        ReservationEntry.SetSourceFilter(DATABASE::"Sales Line", SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", true);
        ReservationEntry.SetSourceFilter('', 0);

        case FunctionType of
            FunctionType::CheckTrackingExists:
                begin
                    TrackingSpecification.SetRange(Correction, false);
                    if not TrackingSpecification.IsEmpty() then
                        exit(true);
                    ReservationEntry.SetFilter("Serial No.", '<>%1', '');
                    if not ReservationEntry.IsEmpty() then
                        exit(true);
                    ReservationEntry.SetRange("Serial No.");
                    ReservationEntry.SetFilter("Lot No.", '<>%1', '');
                    if not ReservationEntry.IsEmpty() then
                        exit(true);
                    ReservationEntry.SetRange("Lot No.");
                    ReservationEntry.SetFilter("Package No.", '<>%1', '');
                    if not ReservationEntry.IsEmpty() then
                        exit(true);
                end;
            FunctionType::GetQty:
                begin
                    TrackingSpecification.CalcSums("Quantity Handled (Base)");
                    TrackingQtyHandled := TrackingSpecification."Quantity Handled (Base)";
                    if ReservationEntry.FindSet() then
                        repeat
                            if ReservationEntry.TrackingExists() then
                                TrackingQtyToHandle := TrackingQtyToHandle + ReservationEntry."Qty. to Handle (Base)";
                        until ReservationEntry.Next() = 0;
                end;
            FunctionType::CheckTempCDNo:
                if ReservationEntry.FindSet() then
                    repeat
                        if ReservationEntry."Package No." <> '' then begin
                            Item.Get(ReservationEntry."Item No.");
                            CDLocationSetup.Get(Item."Item Tracking Code", ReservationEntry."Location Code");
                            PackageNoInformation.Get(ReservationEntry."Item No.", ReservationEntry."Variant Code", ReservationEntry."Package No.");
                            if not CDLocationSetup."Allow Temporary CD Number" then
                                PackageNoInformation.TestField("Temporary CD Number", false);
                        end;
                    until ReservationEntry.Next() = 0;
        end;
    end;

    // ReleasePurchaseDocument.Codeunit.al

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnCodeOnCheckTracking', '', false, false)]
    local procedure ReleasePurchaseDocumentOnCodeOnCheckTracking(PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line")
    begin
        TestPurchTrackingSpecification(PurchaseHeader, PurchaseLine);
    end;

    procedure TestPurchTrackingSpecification(PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line")
    var
        CheckedPurchaseLine: Record "Purchase Line";
        ReservationEntry: Record "Reservation Entry";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ItemTrackingSetup: Record "Item Tracking Setup";
        CDLocationSetup: Record "CD Location Setup";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        ItemTrackingManagement: Codeunit "Item Tracking Management";
        ErrorFieldCaption: Text;
        SignFactor: Integer;
        PurchLineQtyHandled: Decimal;
        PurchLineQtyToHandle: Decimal;
        TrackingQtyHandled: Decimal;
        TrackingQtyToHandle: Decimal;
        Inbound: Boolean;
        CheckPurchLine: Boolean;
    begin
        // if a PurchaseLine is posted with ItemTracking then the whole quantity of
        // the regarding PurchaseLine has to be post with Item-Tracking
        PurchaseLine.SetRange("Drop Shipment");

        if not
          ((PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order) or
           (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Return Order"))
        then
            exit;

        TrackingQtyToHandle := 0;
        TrackingQtyHandled := 0;

        CheckedPurchaseLine.Copy(PurchaseLine);
        CheckedPurchaseLine.SetRange(Type, CheckedPurchaseLine.Type::Item);
        if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order then begin
            CheckedPurchaseLine.SetFilter("Qty. to Receive", '<>%1', 0);
            ErrorFieldCaption := CheckedPurchaseLine.FieldCaption("Qty. to Receive");
        end else begin
            CheckedPurchaseLine.SetFilter("Return Qty. to Ship", '<>%1', 0);
            ErrorFieldCaption := CheckedPurchaseLine.FieldCaption("Return Qty. to Ship");
        end;

        if CheckedPurchaseLine.FindSet() then begin
            ReservationEntry."Source Type" := DATABASE::"Purchase Line";
            ReservationEntry."Source Subtype" := PurchaseHeader."Document Type".AsInteger();
            SignFactor := CreateReservEntry.SignFactor(ReservationEntry);
            repeat
                // Only Item where no SerialNo or LotNo is required
                Item.Get(CheckedPurchaseLine."No.");
                if Item."Item Tracking Code" <> '' then begin
                    Inbound := (CheckedPurchaseLine.Quantity * SignFactor) > 0;
                    ItemTrackingCode.Code := Item."Item Tracking Code";
                    if CDLocationSetup.Get(Item."Item Tracking Code", CheckedPurchaseLine."Location Code") then;
                    ItemTrackingManagement.GetItemTrackingSetup(ItemTrackingCode, "Item Ledger Entry type"::Purchase, Inbound, ItemTrackingSetup);
                    GetCDLocationSetup(ItemTrackingCode, CDLocationSetup, ItemTrackingSetup);
                    CheckPurchLine := ItemTrackingSetup."Package No. Required" and CDLocationSetup."CD Purchase Check on Release";
                    if CheckPurchLine then
                        if not GetPurchaseTrackingQuantities(CheckedPurchaseLine, 0, TrackingQtyToHandle, TrackingQtyHandled) then
                            if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order then
                                Error(ItemTrackingDoesNotMatchErr,
                                  CheckedPurchaseLine."Line No.", Format(CheckedPurchaseLine.Type), CheckedPurchaseLine."No.",
                                  CheckedPurchaseLine.FieldCaption("Qty. to Receive"), CheckedPurchaseLine."Qty. to Receive")
                            else
                                Error(ItemTrackingDoesNotMatchErr,
                                  CheckedPurchaseLine."Line No.", Format(CheckedPurchaseLine.Type), CheckedPurchaseLine."No.",
                                  CheckedPurchaseLine.FieldCaption("Qty. to Receive"), CheckedPurchaseLine."Return Qty. to Ship")
                end else
                    CheckPurchLine := false;

                TrackingQtyToHandle := 0;
                TrackingQtyHandled := 0;

                if CheckPurchLine then begin
                    GetPurchaseTrackingQuantities(CheckedPurchaseLine, 1, TrackingQtyToHandle, TrackingQtyHandled);
                    TrackingQtyToHandle := TrackingQtyToHandle * SignFactor;
                    TrackingQtyHandled := TrackingQtyHandled * SignFactor;
                    if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order then begin
                        PurchLineQtyToHandle := CheckedPurchaseLine."Qty. to Receive (Base)";
                        PurchLineQtyHandled := CheckedPurchaseLine."Qty. Received (Base)";
                    end else begin
                        PurchLineQtyToHandle := CheckedPurchaseLine."Return Qty. to Ship (Base)";
                        PurchLineQtyHandled := CheckedPurchaseLine."Return Qty. Shipped (Base)";
                    end;
                    if ((TrackingQtyHandled + TrackingQtyToHandle) <> (PurchLineQtyHandled + PurchLineQtyToHandle)) or
                       (TrackingQtyToHandle <> PurchLineQtyToHandle)
                    then
                        Error(ItemTrackingMatchErr, ErrorFieldCaption);
                end;
            until CheckedPurchaseLine.Next() = 0;
        end;
    end;

    local procedure GetPurchaseTrackingQuantities(PurchaseLine: Record "Purchase Line"; FunctionType: Option CheckTrackingExists,GetQty; var TrackingQtyToHandle: Decimal; var TrackingQtyHandled: Decimal): Boolean
    var
        TrackingSpecification: Record "Tracking Specification";
        ReservationEntry: Record "Reservation Entry";
    begin
        TrackingSpecification.SetSourceFilter(DATABASE::"Purchase Line", PurchaseLine."Document Type".AsInteger(), PurchaseLine."Document No.", PurchaseLine."Line No.", true);
        TrackingSpecification.SetSourceFilter('', 0);

        ReservationEntry.SetSourceFilter(DATABASE::"Purchase Line", PurchaseLine."Document Type".AsInteger(), PurchaseLine."Document No.", PurchaseLine."Line No.", true);
        ReservationEntry.SetSourceFilter('', 0);

        case FunctionType of
            FunctionType::CheckTrackingExists:
                begin
                    TrackingSpecification.SetRange(Correction, false);
                    if not TrackingSpecification.IsEmpty() then
                        exit(true);
                    ReservationEntry.SetFilter("Serial No.", '<>%1', '');
                    if not ReservationEntry.IsEmpty() then
                        exit(true);
                    ReservationEntry.SetRange("Serial No.");
                    ReservationEntry.SetFilter("Lot No.", '<>%1', '');
                    if not ReservationEntry.IsEmpty() then
                        exit(true);
                    ReservationEntry.SetRange("Lot No.");
                    ReservationEntry.SetFilter("Package No.", '<>%1', '');
                    if not ReservationEntry.IsEmpty() then
                        exit(true);
                end;
            FunctionType::GetQty:
                begin
                    TrackingSpecification.CalcSums("Quantity Handled (Base)");
                    TrackingQtyHandled := TrackingSpecification."Quantity Handled (Base)";
                    if ReservationEntry.FindSet() then
                        repeat
                            if (ReservationEntry."Lot No." <> '') or (ReservationEntry."Serial No." <> '') or
                              (ReservationEntry."Package No." <> '')
                            then
                                TrackingQtyToHandle := TrackingQtyToHandle + ReservationEntry."Qty. to Handle (Base)";
                        until ReservationEntry.Next() = 0;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnSetupSplitJnlLineOnAfterGetItemTrackingSetup', '', false, false)]
    local procedure ItemJnlPostLineOnSetupSplitJnlLineOnAfterGetItemTrackingSetup(ItemTrackingCode: Record "Item Tracking Code"; var ItemTrackingSetup: Record "Item Tracking Setup"; ItemJnlLine: Record "Item Journal Line")
    var
        CDLocationSetup: Record "CD Location Setup";
    begin
        if (ItemTrackingCode.Code <> '') or (ItemJnlLine."Location Code" <> '') then
            if not CDLocationSetup.Get(ItemTrackingCode.Code, ItemJnlLine."Location Code") then
                Clear(CDLocationSetup);

        ItemTrackingSetup."Package No. Info Required" := CDLocationSetup."CD Info. Must Exist";
        ItemTrackingSetup."Package No. Required" := ItemTrackingCode."Package Specific Tracking";

        if ItemJnlLine."New Location Code" <> '' then
            if CDLocationSetup.Get(ItemTrackingCode.Code, ItemJnlLine."New Location Code") then
                ItemTrackingSetup."Package No. Info Required" := CDLocationSetup."CD Info. Must Exist";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Package Info. Management", 'OnAfterTestPackageNoInformation', '', false, false)]
    local procedure OnAfterTestPackageNoInformation(PackageNoInfo: Record "Package No. Information"; ItemTrackingCode: Code[10]; LocationCode: Code[10])
    var
        CDLocationSetup: Record "CD Location Setup";
    begin
        if CDLocationSetup.Get(ItemTrackingCode, LocationCode) then;
        if not CDLocationSetup."Allow Temporary CD Number" then
            PackageNoInfo.TestField("Temporary CD Number", false);
    end;

    procedure GetCDLocationSetup(ItemTrackingCode: Record "Item Tracking Code"; var CDLocationSetup: Record "CD Location Setup"; var ItemTrackingSetup: Record "Item Tracking Setup")
    begin
        if (CDLocationSetup."Item Tracking Code" = '') or (CDLocationSetup."Location Code" = '') then
            Clear(CDLocationSetup)
        else
            if not CDLocationSetup.Get(CDLocationSetup."Item Tracking Code", CDLocationSetup."Location Code") then
                Clear(CDLocationSetup);

        ItemTrackingSetup."Package No. Info Required" := CDLocationSetup."CD Info. Must Exist";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tracking Specification", 'OnCheckPackageNo', '', false, false)]
    local procedure TrackingSpecificationOnCheckPackageNo(TrackingSpecification: Record "Tracking Specification"; PackageNo: Code[50])
    var
        Item: Record Item;
        CDLocationSetup: Record "CD Location Setup";
        CDNumberFormat: Record "CD Number Format";
    begin
        Item.Get(TrackingSpecification."Item No.");
        if CDLocationSetup.Get(Item."Item Tracking Code", TrackingSpecification."Location Code") then;
        if not CDLocationSetup."Allow Temporary CD Number" then
            CDNumberFormat.Check(PackageNo, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnPostItemJnlLinePrepareJournalLineOnCheckApplyFrom', '', false, false)]
    local procedure OnPostItemJnlLinePrepareJournalLineOnCheckApplyFrom(SalesLine: Record "Sales Line")
    begin
        CheckSalesLineApplyFrom(SalesLine);
    end;

    local procedure CheckSalesLineApplyFrom(SalesLine: Record "Sales Line")
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ItemTrackingSetup: Record "Item Tracking Setup";
        ReservationEntry: Record "Reservation Entry";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        ItemTrackingManagement: Codeunit "Item Tracking Management";
        SignFactor: Integer;
        Inbound: Boolean;
        ItemTracking: Boolean;
    begin
        if SalesLine.Type <> SalesLine.Type::Item then
            exit;

        Item.Get(SalesLine."No.");
        if Item."Item Tracking Code" <> '' then begin
            ReservationEntry."Source Type" := DATABASE::"Sales Line";
            ReservationEntry."Source Subtype" := SalesLine."Document Type".AsInteger();
            SignFactor := CreateReservEntry.SignFactor(ReservationEntry);
            Inbound := (SalesLine.Quantity * SignFactor) > 0;
            ItemTrackingCode.Code := Item."Item Tracking Code";
            ItemTrackingManagement.GetItemTrackingSetup(ItemTrackingCode, "Item ledger Entry Type"::Sale, Inbound, ItemTrackingSetup);
            if ItemTrackingSetup."Package No. Required" then begin
                ItemTracking := true;
                ReservationEntry.SetSourceFilter(
                    DATABASE::"Sales Line", SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", false);
                if ReservationEntry.FindSet() then
                    repeat
                        if ReservationEntry."Appl.-from Item Entry" = 0 then
                            ItemTracking := false;
                    until ReservationEntry.Next() = 0
                else
                    ItemTracking := false;
                if not ItemTracking and SalesLine.IsCreditDocType() then
                    if SalesLine.Quantity > 0 then
                        SalesLine.TestField("Appl.-from Item Entry");
            end;
        end;
    end;

    procedure CDCaption(): Text
    begin
        exit(CDTxt);
    end;
}
