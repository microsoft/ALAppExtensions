codeunit 18429 "GST Service Transfer"
{
    Subtype = Test;

    [Test]
    [HandlerFunctions('TaxRatesPage,OptionMenu,ServiceTransferOrderDeletionHandler')]
    procedure PostFromInterStateServiceTransfer()
    var
        FromLocation, ToLocation, InTransitLocation : Record Location;
        ServiceTransferHeader: Record "Service Transfer Header";
        ServiceTransferLine: Record "Service Transfer Line";
        GSTGroupType: Enum "GST Group Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [354835] Check if the system is calculating GST in case of Inter-State Services Transfer.
        // [GIVEN] Created GST Setup and Transfer Locations
        CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);
        CreateGSTSetup(GSTGroupType::Service, false);

        // [WHEN] Create and Post Service Transfer Order for InterState Transactions
        PostedDocumentNo := CreateandPostServiceTransferOrder(ServiceTransferHeader, ServiceTransferLine);

        //[THEN] GST and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatesPage,OptionMenu,ServiceTransferOrderDeletionHandler')]
    procedure PostFromIntraStateServiceTransfer()
    var
        FromLocation, ToLocation, InTransitLocation : Record Location;
        ServiceTransferHeader: Record "Service Transfer Header";
        ServiceTransferline: Record "Service Transfer Line";
        GSTGroupType: Enum "GST Group Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [354844] Check if the system is calculating GST in case of Intra-State Services Transfer.
        // [GIVEN] Created GST Setup and Transfer Locations for IntraState Transactions
        CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);
        CreateGSTSetup(GSTGroupType::Service, true);

        // [WHEN] Create and Post Service Transfer Order for IntraState Transactions
        PostedDocumentNo := CreateandPostServiceTransferOrder(ServiceTransferHeader, ServiceTransferLine);

        //[THEN] GST and Detailed GST Ledger Entries Verified for IntraState Transactions
        VerifyGSTEntries(PostedDocumentNo);
    end;

    local procedure CreateTransferLocations(
        var FromLocation: Record Location;
        var ToLocation: Record Location;
        var InTransitLocation: Record Location)
    begin
        LibraryWarehouse.CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);
        LibraryStorage.Set(FromLocationLbl, FromLocation.Code);
        LibraryStorage.Set(ToLocationLbl, ToLocation.Code);
        LibraryStorage.Set(InTransitLocationLbl, InTransitLocation.Code);
    end;

    local procedure CreateGLAccount(): Code[20]
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        exit(LibraryGST.CreateGLAccWithGSTDetails(
            VATPostingSetup,
            (LibraryStorage.Get(GSTGroupCodeLbl)),
            (LibraryStorage.Get(HSNSACCodeLbl)),
            false, false))
    end;

    local procedure CreateandPostServiceTransferOrder(
        var ServiceTransferHeader: Record "Service Transfer Header";
        var ServiceTransferLine: Record "Service Transfer Line"): Code[20]
    var
        ReceiveServiceTransferHeader: Record "Service Transfer Header";
        ServiceTransferPost: Codeunit "Service Transfer Post";
        DocumentNo: Code[20];
    begin
        CreateServiceHeader(ServiceTransferHeader);
        CreateServiceLine(ServiceTransferHeader, ServiceTransferLine);

        DocumentNo := ServiceTransferHeader."No.";
        LibraryStorage.Set(DocumentNoLbl, DocumentNo);
        Clear(ServiceTransferPost);
        ServiceTransferPost.Run(ServiceTransferHeader);
        LibraryStorage.Set(ShippedLbl, Format(true));

        ReceiveServiceTransferHeader.Get(DocumentNo);
        Clear(ServiceTransferPost);
        ServiceTransferPost.Run(ReceiveServiceTransferHeader);
        LibraryStorage.Remove(ShippedLbl);
        exit(GetServiceTransferShipmentNo(DocumentNo));
    end;

    local procedure GetServiceTransferShipmentNo(DocumentNo: Code[20]): Code[20]
    var
        ServiceTransferShptHeader: Record "Service Transfer Shpt. Header";
    begin
        ServiceTransferShptHeader.SetRange("Service Transfer Order No.", DocumentNo);
        ServiceTransferShptHeader.FindFirst();
        exit(ServiceTransferShptHeader."No.")
    end;

    local procedure CreateServiceHeader(var ServiceTransferHeader: Record "Service Transfer Header")
    var
        LibraryERM: Codeunit "Library - ERM";
    begin
        Clear(ServiceTransferHeader);
        ServiceTransferHeader.Init();
        ServiceTransferHeader.Validate("No.", LibraryERM.CreateNoSeriesCode());
        ServiceTransferHeader.Validate("Transfer-from Code", (LibraryStorage.Get(FromLocationLbl)));
        ServiceTransferHeader.Validate("Transfer-to Code", (LibraryStorage.Get(ToLocationLbl)));
        ServiceTransferHeader.Validate("Ship Control Account", LibraryERM.CreateGLAccountNoWithDirectPosting());
        ServiceTransferHeader.Validate("Receive Control Account", LibraryERM.CreateGLAccountNoWithDirectPosting());
        ServiceTransferHeader.Validate("Receipt Date", WorkDate());
        ServiceTransferHeader.Validate("No.", LibraryERM.CreateNoSeriesCode());
        ServiceTransferHeader.Insert(true);
    end;

    local procedure CreateServiceLine(
        var ServiceTransferHeader: Record "Service Transfer Header";
        var ServiceTransferLine: Record "Service Transfer Line")
    var
        RecordRef: RecordRef;
    begin
        Clear(ServiceTransferLine);
        ServiceTransferLine.Init();
        RecordRef.GetTable(ServiceTransferLine);
        ServiceTransferLine.Validate("Document No.", ServiceTransferHeader."No.");
        ServiceTransferLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecordRef, ServiceTransferLine.FieldNo("Line No.")));
        ServiceTransferLine.Insert(true);
        ServiceTransferLine.Validate("Transfer From G/L Account No.", CreateGLAccount());
        ServiceTransferLine.Validate("Transfer To G/L Account No.", CreateGLAccount());
        ServiceTransferLine.Validate("Transfer Price", LibraryRandom.RandDecInDecimalRange(10000, 20000, 0));
        ServiceTransferLine.Modify(true);
    end;

    local procedure SetupServiceNoSeries()
    var
        InventorySetup: Record "Inventory Setup";
        LibraryERM: Codeunit "Library - ERM";
    begin
        InventorySetup.Get();
        InventorySetup.Validate("Service Transfer Order Nos.", LibraryERM.CreateNoSeriesCode());
        InventorySetup.Validate("Posted Serv. Trans. Shpt. Nos.", LibraryERM.CreateNoSeriesCode());
        InventorySetup.Validate("Posted Serv. Trans. Rcpt. Nos.", LibraryERM.CreateNoSeriesCode());
        InventorySetup.Modify(true);
    end;

    local procedure FillCompanyInformation()
    var
        CompanyInformation: Record "Company information";
        LocationStateCode: Code[10];
        LocationGSTRegNo: Code[15];
        LocPan: Code[20];
    begin
        CompanyInformation.Get();
        if CompanyInformation."P.A.N. No." = '' then begin
            CompanyInformation."P.A.N. No." := LibraryGST.CreatePANNos();
            CompanyInformation.Modify();
        end else
            LocPan := CompanyInformation."P.A.N. No.";
        LocPan := CompanyInformation."P.A.N. No.";

        LibraryGST.CreateNoVatSetup();

        LocationStateCode := LibraryGST.CreateInitialSetup();
        LibraryStorage.Set(LocationStateCodeLbl, LocationStateCode);

        LocationGSTRegNo := LibraryGST.CreateGSTRegistrationNos(LocationStateCode, LocPan);
        if CompanyInformation."GST Registration No." = '' then begin
            CompanyInformation."GST Registration No." := LocationGSTRegNo;
            CompanyInformation.MODIFY(TRUE);
        end;
    end;

    local procedure CreateGSTSetup(GSTGroupType: Enum "GST Group Type"; IntraState: Boolean)
    var
        GSTGroup: Record "GST Group";
        HSNSAC: Record "HSN/SAC";
        HSNSACCode: Code[10];
        GSTGroupCode: Code[20];
        HsnSacType: Enum "GST Goods And Services Type";
    begin
        LibraryGST.CreateInitialSetup();
        FillCompanyInformation();
        SetupServiceNoSeries();

        GSTGroupCode := LibraryGST.CreateGSTGroup(GSTGroup, GSTGroupType, GSTGroup."GST Place Of Supply"::" ", false);
        LibraryStorage.Set(GSTGroupCodeLbl, GSTGroupCode);

        HSNSACCode := LibraryGST.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::HSN);
        LibraryStorage.Set(HSNSACCodeLbl, HSNSACCode);
        if IntraState then
            IntraStateSetup()
        else
            InterStateSetup();
        CreateTaxRate();
    end;

    local procedure IntraStateSetup()
    var
        TaxComponent: Record "Tax Component";
        Location: Record Location;
        GSTcomponentcode: Text[30];
    begin
        Location.Reset();
        Location.Get(LibraryStorage.Get(FromLocationLbl));
        Location."State Code" := CopyStr(LibraryStorage.Get(LocationStateCodeLbl), 1, 10);
        Location."GST Registration No." := Format(LibraryRandom.RandText(15));
        Location.Modify(true);

        Location.Reset();
        Location.Get(LibraryStorage.Get(ToLocationLbl));
        Location."State Code" := CopyStr(LibraryStorage.Get(LocationStateCodeLbl), 1, 10);
        Location."GST Registration No." := Format(LibraryRandom.RandText(15));
        Location.Modify(true);

        CreateGSTSetupTaxRateParameters(true, Location."State Code", Location."State Code");
        LibraryGST.CreateGSTComponentAndPostingSetup(true, Location."State Code", TaxComponent, GSTcomponentcode);
    end;

    local procedure InterStateSetup()
    var
        TaxComponent: Record "Tax Component";
        Location: Record Location;
        State: Record State;
        GSTcomponentcode: Text[30];
        FromStateCode, ToStateCode : Code[10];
    begin
        Location.Reset();
        Location.Get(LibraryStorage.Get(FromLocationLbl));
        Location."State Code" := (LibraryStorage.Get(LocationStateCodeLbl));
        FromStateCode := Location."State Code";
        Location."GST Registration No." := Format(LibraryRandom.RandText(15));
        Location."Location ARN No." := Format(LibraryRandom.RandIntInRange(1000, 9999));
        Location.Modify(true);

        Location.Reset();
        Location.Get(LibraryStorage.Get(ToLocationLbl));
        LibraryGST.CreateState(State);
        Location."State Code" := State.Code;
        ToStateCode := Location."State Code";
        Location."GST Registration No." := Format(LibraryRandom.RandText(15));
        Location."Location ARN No." := Format(LibraryRandom.RandIntInRange(1000, 9999));
        Location.Modify(true);

        CreateGSTSetupTaxRateParameters(false, FromStateCode, ToStateCode);
        LibraryGST.CreateGSTComponentAndPostingSetup(false, FromStateCode, TaxComponent, GSTComponentCode);
        LibraryGST.CreateGSTComponentAndPostingSetup(false, ToStateCode, TaxComponent, GSTComponentCode);
    end;

    local procedure CreateGSTSetupTaxRateParameters(IntraState: Boolean; FromState: Code[10]; ToState: Code[10])
    var
        GSTTaxPercent: decimal;
    begin
        LibraryStorage.Set(FromStateCodeLbl, FromState);
        LibraryStorage.Set(ToStateCodeLbl, ToState);
        GSTTaxPercent := LibraryRandom.RandDecInRange(10, 18, 0);

        if IntraState then begin
            ComponentPerArray[1] := (GSTTaxPercent / 2);
            ComponentPerArray[2] := (GSTTaxPercent / 2);
            ComponentPerArray[3] := 0;
        end else
            ComponentPerArray[4] := GSTTaxPercent;
    end;

    local procedure CreateTaxRate()
    var
        GSTSetup: Record "GST Setup";
        TaxTypes: TestPage "Tax Types";
    begin
        GSTSetup.Get();
        TaxTypes.OpenEdit();
        TaxTypes.Filter.SetFilter(Code, GSTSetup."GST Tax Type");
        TaxTypes.TaxRates.Invoke();
    end;

    local procedure VerifyGSTEntries(DocumentNo: Code[20])
    var
        ServiceTransferShptLine: Record "Service Transfer Shpt. Line";
        ComponentList: List of [Code[30]];
    begin
        ServiceTransferShptLine.Reset();
        ServiceTransferShptLine.SetRange("Document No.", DocumentNo);
        ServiceTransferShptLine.FindSet();
        repeat
            FillComponentList(ComponentList, ServiceTransferShptLine."GST Group Code");
            VerifyGSTEntriesForTransfer(ServiceTransferShptLine, DocumentNo, ComponentList);
            VerifyDetailedGSTEntriesForTransfer(ServiceTransferShptLine, DocumentNo, ComponentList);
        until ServiceTransferShptLine.Next() = 0;
    end;

    local procedure FillComponentList(
       var ComponentList: List of [Code[30]];
       GSTGroupCode: Code[20])
    var
        GSTGroup: Record "GST Group";
    begin
        GSTGroup.Get(GSTGroupCode);
        Clear(ComponentList);
        if LibraryStorage.Get(FromStateCodeLbl) = LibraryStorage.Get(ToStateCodeLbl) then begin
            ComponentList.Add(CGSTLbl);
            ComponentList.Add(SGSTLbl);
        end else
            ComponentList.Add(IGSTLbl);
    end;

    local procedure GetTransactionNo(DocumentNo: Code[20]; PostingDate: Date; DocumentType: Enum "Gen. Journal Document Type"): Integer
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("Posting Date", PostingDate);
        GLEntry.SetRange("Document Type", DocumentType);
        GLEntry.FindFirst();

        exit(GLEntry."Transaction No.");
    end;

    local procedure VerifyGSTEntriesForTransfer(
        ServiceTransferShptLine: Record "Service Transfer Shpt. Line";
        DocumentNo: Code[20];
        ComponentList: List of [Code[30]])
    var
        GSTLedgerEntry: Record "GST Ledger Entry";
        ServiceTransferShptHeader: Record "Service Transfer Shpt. Header";
        GSTAmount: Decimal;
        ComponentCode: Code[30];
        TransactionNo: Integer;
        DocumentType: Enum "Gen. Journal Document Type";
    begin
        ServiceTransferShptHeader.Get(DocumentNo);

        ServiceTransferShptLine.SetRange("Document No.", DocumentNo);
        ServiceTransferShptLine.FindFirst();

        TransactionNo := GetTransactionNo(DocumentNo, ServiceTransferShptHeader."Shipment Date", DocumentType::Invoice);

        foreach ComponentCode in ComponentList do begin
            GSTLedgerEntry.Reset();
            GSTLedgerEntry.SetRange("GST Component Code", ComponentCode);
            GSTLedgerEntry.SetRange("Document No.", DocumentNo);
            GSTLedgerEntry.SetRange("Posting Date", ServiceTransferShptHeader."Shipment Date");
            GSTLedgerEntry.SetRange("Document Type", GSTLedgerEntry."Document Type"::Invoice);
            GSTLedgerEntry.FindFirst();

            if LibraryStorage.Get(FromStateCodeLbl) <> LibraryStorage.Get(ToStateCodeLbl) then
                GSTAmount := (ServiceTransferShptLine."Transfer Price" * ComponentPerArray[4]) / 100
            else
                GSTAmount := ServiceTransferShptLine."Transfer Price" * ComponentPerArray[1] / 100;

            Assert.AreEqual(ServiceTransferShptHeader."Shipment Date", GSTLedgerEntry."Posting Date",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Posting Date"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(DocumentNo, GSTLedgerEntry."Document No.",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Posting Date"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(GSTLedgerEntry."Document Type"::Invoice, GSTLedgerEntry."Document Type",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Document Type"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(GSTLedgerEntry."Transaction Type"::Sales, GSTLedgerEntry."Transaction Type",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Transaction Type"), GSTLedgerEntry.TableCaption));

            Assert.AreNearlyEqual(-ServiceTransferShptLine."Transfer Price", GSTLedgerEntry."GST Base Amount", LibraryGST.GetGSTRoundingPrecision(GSTLedgerEntry."GST Component Code"),
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("GST Base Amount"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(UserId, GSTLedgerEntry."User ID",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("User ID"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(ComponentCode, GSTLedgerEntry."GST Component Code",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("GST Component Code"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(TransactionNo, GSTLedgerEntry."Transaction No.",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Transaction No."), GSTLedgerEntry.TableCaption));

            Assert.AreNearlyEqual(-GSTAmount, GSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(GSTLedgerEntry."GST Component Code"),
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("GST Amount"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(GSTLedgerEntry."Entry Type"::"Initial Entry", GSTLedgerEntry."Entry Type",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Entry Type"), GSTLedgerEntry.TableCaption));
        end;
    end;

    local procedure VerifyDetailedGSTEntriesForTransfer(ServiceTransferShptLine: Record "Service Transfer Shpt. Line";
        DocumentNo: Code[20];
        ComponentList: List of [Code[30]])
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        ServiceTransferShptHeader: Record "Service Transfer Shpt. Header";
        FromLocation: Record Location;
        ToLocation: Record Location;
        GSTAmount: Decimal;
        TransactionNo: Integer;
        DocumentType: Enum "Gen. Journal Document Type";
        ComponentCode: Code[30];
    begin
        ServiceTransferShptHeader.Get(DocumentNo);

        ServiceTransferShptLine.SetRange("Document No.", DocumentNo);
        ServiceTransferShptLine.FindFirst();

        FromLocation.Get(LibraryStorage.Get(FromLocationLbl));
        ToLocation.Get(LibraryStorage.Get(ToLocationLbl));

        TransactionNo := GetTransactionNo(DocumentNo, ServiceTransferShptHeader."Shipment Date", DocumentType::Invoice);

        foreach ComponentCode in ComponentList do begin
            DetailedGSTLedgerEntry.Reset();
            DetailedGSTLedgerEntry.SetRange("GST Component Code", ComponentCode);
            DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
            DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
            DetailedGSTLedgerEntry.FindFirst();

            DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.");

            if LibraryStorage.Get(FromStateCodeLbl) <> LibraryStorage.Get(ToStateCodeLbl) then
                GSTAmount := (ServiceTransferShptLine."Transfer Price" * ComponentPerArray[4]) / 100
            else
                GSTAmount := ServiceTransferShptLine."Transfer Price" * ComponentPerArray[1] / 100;

            Assert.AreEqual(DetailedGSTLedgerEntry."Entry Type"::"Initial Entry", DetailedGSTLedgerEntry."Entry Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Entry Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntry."Transaction Type"::Sales, DetailedGSTLedgerEntry."Transaction Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Transaction Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntry."Document Type"::Invoice, DetailedGSTLedgerEntry."Document Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Document Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(ServiceTransferShptHeader."Shipment Date", DetailedGSTLedgerEntry."Posting Date",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Posting Date"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntry.Type::"G/L Account", DetailedGSTLedgerEntry.Type,
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption(Type), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(ServiceTransferShptLine."Transfer From G/L Account No.", DetailedGSTLedgerEntry."No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(LibraryGST.GetGSTPayableAccountNo((LibraryStorage.Get(FromStateCodeLbl)), DetailedGSTLedgerEntry."GST Component Code"), DetailedGSTLedgerEntry."G/L Account No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("G/L Account No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntry."Source Type"::Customer, DetailedGSTLedgerEntry."Source Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Source Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(ServiceTransferShptLine."SAC Code", DetailedGSTLedgerEntry."HSN/SAC Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("HSN/SAC Code"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(ServiceTransferShptLine."GST Group Code", DetailedGSTLedgerEntry."GST Group Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Group Code"), DetailedGSTLedgerEntry.TableCaption));

            if LibraryStorage.Get(FromStateCodeLbl) <> LibraryStorage.Get(ToStateCodeLbl) then
                Assert.AreEqual(DetailedGSTLedgerEntry."GST Jurisdiction Type"::Interstate, DetailedGSTLedgerEntry."GST Jurisdiction Type",
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Jurisdiction Type"), DetailedGSTLedgerEntry.TableCaption))
            else
                Assert.AreEqual(DetailedGSTLedgerEntry."GST Jurisdiction Type"::Intrastate, DetailedGSTLedgerEntry."GST Jurisdiction Type",
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Jurisdiction Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreNearlyEqual(-ServiceTransferShptLine."Transfer Price", DetailedGSTLedgerEntry."GST Base Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Base Amount"), DetailedGSTLedgerEntry.TableCaption));

            if DetailedGSTLedgerEntry."GST Jurisdiction Type" = DetailedGSTLedgerEntry."GST Jurisdiction Type"::Interstate then
                Assert.AreEqual(ComponentPerArray[4], DetailedGSTLedgerEntry."GST %",
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption))
            else
                Assert.AreEqual(ComponentPerArray[1], DetailedGSTLedgerEntry."GST %",
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreNearlyEqual(-GSTAmount, DetailedGSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Amount"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(ServiceTransferShptHeader."Service Transfer Order No.", DetailedGSTLedgerEntry."External Document No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("External Document No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(-1.00, DetailedGSTLedgerEntry.Quantity,
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName(Quantity), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(ServiceTransferShptLine."Line No.", DetailedGSTLedgerEntry."Document Line No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Reverse Charge"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(LibraryStorage.Get(FromStateCodeLbl), DetailedGSTLedgerEntryInfo."Location State Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Location State Code"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(LibraryStorage.Get(ToStateCodeLbl), DetailedGSTLedgerEntryInfo."Buyer/Seller State Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Buyer/Seller State Code"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(FromLocation."GST Registration No.", DetailedGSTLedgerEntry."Location  Reg. No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("Location  Reg. No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(ToLocation."GST Registration No.", DetailedGSTLedgerEntry."Buyer/Seller Reg. No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("Buyer/Seller Reg. No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntry."GST Group Type"::Service, DetailedGSTLedgerEntry."GST Group Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("GST Group Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(TransactionNo, DetailedGSTLedgerEntry."Transaction No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Transaction No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntryInfo."Original Doc. Type"::"Transfer Shipment", DetailedGSTLedgerEntryInfo."Original Doc. Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Original Doc. Type"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(ServiceTransferShptHeader."Service Transfer Order No.", DetailedGSTLedgerEntryInfo."Original Doc. No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Original Doc. No."), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(LibraryStorage.Get(FromLocationLbl), DetailedGSTLedgerEntry."Location Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Location Code"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(UserId, DetailedGSTLedgerEntryInfo."User ID",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("User ID"), DetailedGSTLedgerEntryInfo.TableCaption));
        end;
    end;

    [PageHandler]
    procedure TaxRatesPage(var TaxRates: TestPage "Tax Rates")
    begin
        TaxRates.New();
        TaxRates.AttributeValue1.SetValue(LibraryStorage.Get(GSTGroupCodeLbl));
        TaxRates.AttributeValue2.SetValue(LibraryStorage.Get(HSNSACCodeLbl));
        TaxRates.AttributeValue3.SetValue(LibraryStorage.Get(FromStateCodeLbl));
        TaxRates.AttributeValue4.SetValue(LibraryStorage.Get(ToStateCodeLbl));
        TaxRates.AttributeValue5.SetValue(Today);
        TaxRates.AttributeValue6.SetValue(CalcDate('<10Y>', Today));
        TaxRates.AttributeValue7.SetValue(ComponentPerArray[1]);
        TaxRates.AttributeValue8.SetValue(ComponentPerArray[2]);
        TaxRates.AttributeValue9.SetValue(ComponentPerArray[4]);
        TaxRates.AttributeValue10.SetValue(ComponentPerArray[3]);
        TaxRates.OK().Invoke();
    end;

    [MessageHandler]
    procedure ServiceTransferOrderDeletionHandler(SuccessMsg: Text[1024])
    begin
        if SuccessMsg <> StrSubstNo(SuccessTextMsg, LibraryStorage.Get(DocumentNoLbl)) then
            Error(NotPostedErr);
    end;

    [StrMenuHandler]
    procedure OptionMenu(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024]);
    begin
        if LibraryStorage.ContainsKey(ShippedLbl) then
            Choice := 2
        else
            Choice := 1;
    end;

    var
        LibraryGST: Codeunit "Library GST";
        Assert: Codeunit Assert;
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryStorage: Dictionary of [Text, Text];
        ComponentPerArray: array[20] of Decimal;
        LocationStateCodeLbl: Label 'LocationStateCode';
        DocumentNoLbl: Label 'Document No', Locked = true;
        GSTGroupCodeLbl: Label 'GSTGroupCode';
        HSNSACCodeLbl: Label 'HSNSACCode';
        FromStateCodeLbl: Label 'FromStateCode';
        ToStateCodeLbl: Label 'ToStateCode';
        CGSTLbl: Label 'CGST';
        SGSTLbl: Label 'SGST';
        IGSTLbl: Label 'IGST';
        FromLocationLbl: Label 'FromLocation';
        ToLocationLbl: Label 'ToLocation';
        ShippedLbl: Label 'Shipped';
        InTransitLocationLbl: Label 'InTransitLocation';
        SuccessTextMsg: Label 'Service Transfer Order %1 has been deleted.', Comment = '%1 = Transfer Order Number';
        NotPostedErr: Label 'The entries were not posted.', locked = true;
        GSTLEVerifyErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = Field Caption and Table Caption';
}