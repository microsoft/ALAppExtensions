codeunit 5376 "Create E-Document Transactions"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    EventSubscriberInstance = Manual;
    Permissions = tabledata "Sales Invoice Header" = rimd,
                  tabledata "Sales Invoice Line" = rimd;


    trigger OnRun()
    var
        SalesTempBlobList: Codeunit "Temp Blob List";
        PurchaseOrdersList: List of [Code[20]];
    begin
        SalesTempBlobList := CreateSalesInvoicesAndExportToBlobList();
        PurchaseOrdersList := CreatePurchaseOrders();
        CreateEdocs(SalesTempBlobList, PurchaseOrdersList);
    end;

    internal procedure TryCreatePurchaseOrders() PurchaseOrdersList: List of [Code[20]]
    var
        PurchaseHeader: Record "Purchase Header";
        EDocumentModuleSetup: Record "E-Document Module Setup";
        ContosoPurchase: Codeunit "Contoso Purchase";
        CommonUoM: Codeunit "Create Common Unit Of Measure";
    begin
        if EDocumentModuleSetup.Get() then;
        PurchaseHeader := CreateOrder(EDocumentModuleSetup."Vendor No. 1");
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'WRB-1000', 50, CommonUoM.Piece(), 100);
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'WRB-1001', 50, CommonUoM.Piece(), 100);
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'WRB-1003', 50, CommonUoM.Piece(), 120);
        PostPurchaseOrder(PurchaseHeader, PurchaseOrdersList);

        PurchaseHeader := CreateOrder(EDocumentModuleSetup."Vendor No. 1");
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'WRB-1004', 100, CommonUoM.Piece(), 120);
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'WRB-1005', 100, CommonUoM.Piece(), 120);
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'WRB-1006', 100, CommonUoM.Piece(), 120);
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'WRB-1007', 100, CommonUoM.Piece(), 120);
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'WDB-1000', 50, CommonUoM.Piece(), 113);
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'WDB-1001', 50, CommonUoM.Piece(), 113);
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'GRH-1000', 20, CommonUoM.Piece(), 149);
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'GRH-1001', 10, CommonUoM.Piece(), 219);
        PostPurchaseOrder(PurchaseHeader, PurchaseOrdersList);

        PurchaseHeader := CreateOrder(EDocumentModuleSetup."Vendor No. 2");
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'GRH-1000', 15, CommonUoM.Piece(), 124);
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'GRH-1001', 5, CommonUoM.Piece(), 235);
        PostPurchaseOrder(PurchaseHeader, PurchaseOrdersList);

        PurchaseHeader := CreateOrder(EDocumentModuleSetup."Vendor No. 2");
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'WRB-1001', 150, CommonUoM.Piece(), 125, 20);
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'WDB-1003', 25, CommonUoM.Piece(), 170, 10);
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'WDB-1004', 50, CommonUoM.Piece(), 120);
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'WDB-1005', 50, CommonUoM.Piece(), 140);
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'WDB-1006', 40, CommonUoM.Piece(), 140);
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'WDB-1007', 15, CommonUoM.Piece(), 119);
        PostPurchaseOrder(PurchaseHeader, PurchaseOrdersList);

        PurchaseHeader := CreateOrder(EDocumentModuleSetup."Vendor No. 3");
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'WRB-1004', 60, CommonUoM.Piece(), 110);
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'WRB-1005', 60, CommonUoM.Piece(), 110);
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'WRB-1004', 40, CommonUoM.Piece(), 110);
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'WRB-1005', 40, CommonUoM.Piece(), 110);
        PostPurchaseOrder(PurchaseHeader, PurchaseOrdersList);

        PurchaseHeader := CreateOrder(EDocumentModuleSetup."Vendor No. 3");
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, 'GRH-1001', 20, CommonUoM.Piece(), 289);
        PostPurchaseOrder(PurchaseHeader, PurchaseOrdersList);
    end;

    local procedure PostPurchaseOrder(var PurchaseHeader: Record "Purchase Header"; var PurchaseOrdersList: List of [Code[20]])
    var
        PurchPostYesNo: Codeunit "Purch.-Post (Yes/No)";
    begin
        PurchaseHeader.Receive := true;
        PurchaseHeader.Modify();
        PurchPostYesNo.Run(PurchaseHeader);
        PurchaseOrdersList.Add(PurchaseHeader."No.");
    end;

    local procedure CreatePurchaseOrders() PurchaseOrdersList: List of [Code[20]];
    var
        CreateEDocTransactions: Codeunit "Create E-Document Transactions";
    begin
        BindSubscription(CreateEDocTransactions);
        PurchaseOrdersList := CreateEDocTransactions.TryCreatePurchaseOrders();
        UnbindSubscription(CreateEDocTransactions);
    end;

    /// <summary>
    /// Some localisations set the customer country region code to empty when domestic.
    /// PEPPOL export requires bill and ship to fields to be filled out, so this correction is nessesary in those countries.
    /// </summary>
    local procedure CorrectSalesInvHeader(var SalesInvHeader: Record "Sales Invoice Header")
    var
        CompanyInfo: Record "Company Information";
        Modified: Boolean;
    begin
        if SalesInvHeader."Bill-to Country/Region Code" = '' then begin
            CompanyInfo.Get();
            SalesInvHeader."Bill-to Country/Region Code" := CompanyInfo."Country/Region Code";
            Modified := true;
        end;
        if SalesInvHeader."Ship-to Country/Region Code" = '' then begin
            CompanyInfo.Get();
            SalesInvHeader."Ship-to Country/Region Code" := CompanyInfo."Country/Region Code";
            Modified := true;
        end;
        if Modified then
            SalesInvHeader.Modify();
    end;

    local procedure CreateSalesInvoicesAndExportToBlobList(): Codeunit "Temp Blob List";
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesSetup: Record "Sales & Receivables Setup";
        ContosoCustomer: Codeunit "Create Common Customer/Vendor";
        CreateEDocTransactions: Codeunit "Create E-Document Transactions";
        ExportSalesInv: Codeunit "Exp. Sales Inv. PEPPOL BIS3.0";
        TempBlob: Codeunit "Temp Blob";
        TempBlobList: Codeunit "Temp Blob List";
        OutStr: OutStream;
        TempDate: Date;
    begin
        BindSubscription(CreateEDocTransactions);

        SalesSetup.Get();
        TempDate := SalesSetup."Allow Document Deletion Before";
        SalesSetup."Allow Document Deletion Before" := WorkDate() + 1;
        SalesSetup.Modify();

        SalesHeader := CreateSalesInvoice(ContosoCustomer.DomesticCustomer1());
        SalesHeader."Your Reference" := '1';
        SalesHeader."External Document No." := '1';
        SalesHeader."No. Printed" := 1;
        SalesHeader.Modify();
        SalesInvHeader.TransferFields(SalesHeader);
        SalesInvHeader.Insert();
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 20, 'Colombian Roasted Coffee', 125.0, 20);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 20, 'Rio BR Whole Roasted Beans', 125.0, 20);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 20, 'Fortaleza BR Whole Roasted Beans', 125.0, 20);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 20, 'Espresso Roast. Beans, Mexico', 120.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 20, 'Mexican Mocha Beans', 120.0);
        CorrectSalesInvHeader(SalesInvHeader);

        TempBlob.CreateOutStream(OutStr);
        ExportSalesInv.GenerateXMLFile(SalesInvHeader, OutStr);
        TempBlobList.Add(TempBlob);
        SalesInvHeader.Delete(true);
        SalesHeader.Delete();

        SalesHeader := CreateSalesInvoice(ContosoCustomer.DomesticCustomer1());
        SalesHeader."Your Reference" := '1';
        SalesHeader."External Document No." := '1';
        SalesHeader."No. Printed" := 1;
        SalesHeader.Modify();
        SalesInvHeader.TransferFields(SalesHeader);
        SalesInvHeader.Insert();
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 25, 'Kenyan Espresso Coffee', 120.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 25, 'Mocha Beans from Kenia', 120.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 20, 'Costa Rica - cafe noir', 120.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 20, 'C.Rica Jamocha Rst. Beans', 120.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 20, 'Roasted Cafe Costa Rica Beans', 120.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 50, 'Ethiop. Whole Roasted Beans', 120.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 60, 'Roasted Coffee Beans, Hawaii', 120.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 30, 'Colombian Demitasse', 113.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 20, 'Colombian Decaf', 113.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 36, 'Brazilian Roast Whole Decaf', 113.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 10, 'Grind - Brew Like a Pro', 149.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 10, 'Coffee Grinder Contoso', 149.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 5, 'Smart Metal Grinder Black', 219.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 5, 'Super Metal Grinder Red Color', 219.0);
        CorrectSalesInvHeader(SalesInvHeader);

        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStr);
        ExportSalesInv.GenerateXMLFile(SalesInvHeader, OutStr);
        TempBlobList.Add(TempBlob);
        SalesInvHeader.Delete(true);
        SalesHeader.Delete();

        SalesHeader := CreateSalesInvoice(ContosoCustomer.DomesticCustomer1());
        SalesHeader."Your Reference" := '1';
        SalesHeader."External Document No." := '1';
        SalesHeader."No. Printed" := 1;
        SalesHeader.Modify();
        SalesInvHeader.TransferFields(SalesHeader);
        SalesInvHeader.Insert();
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 3, 'Precision Home Crusher', 124.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 3, 'Home Coffee Mill', 124.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 4, 'Home Coffee Mincer Purple', 124.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 2, 'LuxuryHome Grinder', 235.0);
        CorrectSalesInvHeader(SalesInvHeader);

        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStr);
        ExportSalesInv.GenerateXMLFile(SalesInvHeader, OutStr);
        TempBlobList.Add(TempBlob);
        SalesInvHeader.Delete(true);
        SalesHeader.Delete();

        SalesHeader := CreateSalesInvoice(ContosoCustomer.DomesticCustomer1());
        SalesHeader."Your Reference" := '1';
        SalesHeader."External Document No." := '1';
        SalesHeader."No. Printed" := 1;
        SalesHeader.Modify();
        SalesInvHeader.TransferFields(SalesHeader);
        SalesInvHeader.Insert();
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 25, 'Fresh Dark Brazilian Roast', 100.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 25, 'Whole Bean Coffee - Brazil', 100.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 25, 'Medium Roast Braz. Coffee', 100.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 10, 'Whole Decaf Beans Tijuana', 170.0, 10);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 35, '100% Decaf Kenya, Whole Bean', 120.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 20, 'Rio BR Whole Roasted Beans', 125.0, 20);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 20, 'Decaf Costa Rica Whole Bean Coffee Medium Roast', 140.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 20, 'Ethiopian Decaf Dark Roast Coffee Bag', 140.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 5, 'Whole Bean Coffee - Hawaii Decaf', 119.0);
        CorrectSalesInvHeader(SalesInvHeader);

        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStr);
        ExportSalesInv.GenerateXMLFile(SalesInvHeader, OutStr);
        TempBlobList.Add(TempBlob);
        SalesInvHeader.Delete(true);
        SalesHeader.Delete();

        SalesHeader := CreateSalesInvoice(ContosoCustomer.DomesticCustomer1());
        SalesHeader."Your Reference" := '1';
        SalesHeader."External Document No." := '1';
        SalesHeader."No. Printed" := 1;
        SalesHeader.Modify();
        SalesInvHeader.TransferFields(SalesHeader);
        SalesInvHeader.Insert();
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 20, 'Whole Indonesian Coffee Beans, Roasted', 110.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 20, 'Kenyan Organic Whole Roasted Coffee Bean', 110.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 15, 'Whole Roasted Coffe Beans, Costa Rica', 110.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 15, 'Talamanca Origin Coffee Whole Beans', 110.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 5, 'Organic Decaf Roast Beans - Nairobi', 110.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 5, 'Organic Decaf Roast Beans - Mombasa', 110.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 15, 'Decaf Roasted Beans - Costa Rica', 110.0);
        CorrectSalesInvHeader(SalesInvHeader);

        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStr);
        ExportSalesInv.GenerateXMLFile(SalesInvHeader, OutStr);
        TempBlobList.Add(TempBlob);
        SalesInvHeader.Delete(true);
        SalesHeader.Delete();

        SalesHeader := CreateSalesInvoice(ContosoCustomer.DomesticCustomer1());
        SalesHeader."Your Reference" := '1';
        SalesHeader."External Document No." := '1';
        SalesHeader."No. Printed" := 1;
        SalesHeader.Modify();
        SalesInvHeader.TransferFields(SalesHeader);
        SalesInvHeader.Insert();
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 5, 'Stainless Steel Basic Coffee Bean Grinder', 289.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 5, 'Flat Coffee Grinder, Electric', 289.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 5, 'One-touch Home Coffee Grinder', 289.0);
        CreateSalesInvLine(SalesHeader, GetItemWRB1003(), 5, 'Coffee Grinder- Electric Coffee Mill for Espresso', 289.0);
        CorrectSalesInvHeader(SalesInvHeader);

        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStr);
        ExportSalesInv.GenerateXMLFile(SalesInvHeader, OutStr);
        TempBlobList.Add(TempBlob);
        SalesInvHeader.Delete(true);
        SalesHeader.Delete();

        SalesSetup.Get();
        SalesSetup."Allow Document Deletion Before" := TempDate;
        SalesSetup.Modify();

        UnbindSubscription(CreateEDocTransactions);
        exit(TempBlobList);
    end;

    local procedure CreateEdocs(var SalesTempBlobList: Codeunit "Temp Blob List"; PurchaseOrdersList: List of [Code[20]])
    var
        Vendor: Record Vendor;
        EDocumentModuleSetup: Record "E-Document Module Setup";
        CompanyInfo: Record "Company Information";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        XML: Text;
    begin
        if EDocumentModuleSetup.Get() then;
        if CompanyInfo.Get() then;
        Vendor.Get(EDocumentModuleSetup."Vendor No. 1");
        SalesTempBlobList.Get(1, TempBlob);
        UpdateXMLWihVendorAndCompInfo(Vendor, CompanyInfo, 'FK24-8691', PurchaseOrdersList.Get(1), TempBlob);
        TempBlob.CreateInStream(InStream);
        InStream.Read(XML, TempBlob.Length());
        CreateEDocument(XML);

        SalesTempBlobList.Get(2, TempBlob);
        UpdateXMLWihVendorAndCompInfo(Vendor, CompanyInfo, 'FK24-6222', PurchaseOrdersList.Get(2), TempBlob);
        TempBlob.CreateInStream(InStream);
        InStream.Read(XML, TempBlob.Length());
        CreateEDocument(XML);

        Vendor.Get(EDocumentModuleSetup."Vendor No. 2");
        SalesTempBlobList.Get(3, TempBlob);
        UpdateXMLWihVendorAndCompInfo(Vendor, CompanyInfo, 'FK24-6098', PurchaseOrdersList.Get(3), TempBlob);
        TempBlob.CreateInStream(InStream);
        InStream.Read(XML, TempBlob.Length());
        CreateEDocument(XML);

        SalesTempBlobList.Get(4, TempBlob);
        UpdateXMLWihVendorAndCompInfo(Vendor, CompanyInfo, 'FK24-5260', PurchaseOrdersList.Get(4), TempBlob);
        TempBlob.CreateInStream(InStream);
        InStream.Read(XML, TempBlob.Length());
        CreateEDocument(XML);

        Vendor.Get(EDocumentModuleSetup."Vendor No. 3");
        SalesTempBlobList.Get(5, TempBlob);
        UpdateXMLWihVendorAndCompInfo(Vendor, CompanyInfo, 'FK24-2896', PurchaseOrdersList.Get(5), TempBlob);
        TempBlob.CreateInStream(InStream);
        InStream.Read(XML, TempBlob.Length());
        CreateEDocument(XML);

        SalesTempBlobList.Get(6, TempBlob);
        UpdateXMLWihVendorAndCompInfo(Vendor, CompanyInfo, 'FK24-2811', PurchaseOrdersList.Get(6), TempBlob);
        TempBlob.CreateInStream(InStream);
        InStream.Read(XML, TempBlob.Length());
        CreateEDocument(XML);
    end;

    local procedure UpdateXMLWihVendorAndCompInfo(Vendor: Record Vendor; CompanyInfo: Record "Company Information"; OrderNo: Code[20]; RefNo: Code[20]; var TempBlob: Codeunit "Temp Blob")
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        InStream: InStream;
    begin
        TempBlob.CreateInStream(InStream);
        TempXMLBuffer.LoadFromStream(InStream);
        UpdateValueInBuffer(TempXMLBuffer, '/Invoice/cbc:ID', OrderNo);
        UpdateValueInBuffer(TempXMLBuffer, '/Invoice/cac:OrderReference/cbc:ID', RefNo);
        UpdateValueInBuffer(TempXMLBuffer, '/Invoice/cbc:BuyerReference', RefNo);
        // Update Supplier
        UpdateValueInBuffer(TempXMLBuffer, '/Invoice/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID', Vendor."VAT Registration No.");
        UpdateValueInBuffer(TempXMLBuffer, '/Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyName/cbc:Name', Vendor.Name);
        UpdateValueInBuffer(TempXMLBuffer, '/Invoice/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode', Vendor."Country/Region Code");
        DeleteInBuffer(TempXMLBuffer, '/Invoice/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName');
        DeleteInBuffer(TempXMLBuffer, '/Invoice/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:CityName');
        DeleteInBuffer(TempXMLBuffer, '/Invoice/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:PostalZone');
        UpdateValueInBuffer(TempXMLBuffer, '/Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID', Vendor."VAT Registration No.");
        UpdateValueInBuffer(TempXMLBuffer, '/Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName', Vendor.Name);
        UpdateValueInBuffer(TempXMLBuffer, '/Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID', Vendor."VAT Registration No.");
        // Update Customer
        UpdateValueInBuffer(TempXMLBuffer, '/Invoice/cac:AccountingCustomerParty/cac:Party/cbc:EndpointID', CompanyInfo."VAT Registration No.");
        UpdateValueInBuffer(TempXMLBuffer, '/Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyName/cbc:Name', CompanyInfo.Name);
        UpdateValueInBuffer(TempXMLBuffer, '/Invoice/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode', CompanyInfo."Country/Region Code");
        DeleteInBuffer(TempXMLBuffer, '/Invoice/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:StreetName');
        DeleteInBuffer(TempXMLBuffer, '/Invoice/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:CityName');
        DeleteInBuffer(TempXMLBuffer, '/Invoice/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:PostalZone');
        UpdateValueInBuffer(TempXMLBuffer, '/Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID', CompanyInfo."VAT Registration No.");
        UpdateValueInBuffer(TempXMLBuffer, '/Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName', CompanyInfo.Name);
        UpdateValueInBuffer(TempXMLBuffer, '/Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID', CompanyInfo."VAT Registration No.");

        DeleteInBuffer(TempXMLBuffer, '/Invoice/cac:Delivery/cac:DeliveryLocation/cac:Address/cbc:StreetName');
        DeleteInBuffer(TempXMLBuffer, '/Invoice/cac:Delivery/cac:DeliveryLocation/cac:Address/cbc:CityName');
        DeleteInBuffer(TempXMLBuffer, '/Invoice/cac:Delivery/cac:DeliveryLocation/cac:Address/cbc:PostalZone');
        UpdateValueInBuffer(TempXMLBuffer, '/Invoice/cac:Delivery/cac:DeliveryLocation/cac:Address/cac:Country/cbc:IdentificationCode', CompanyInfo."Country/Region Code");

        SetRandomLineItemNumbers(TempXMLBuffer);

        Clear(TempBlob);
        TempXMLBuffer.Reset();
        TempXMLBuffer.FindSet();
        TempXMLBuffer.Save(TempBlob);
    end;

    local procedure SetRandomLineItemNumbers(var TempXMLBuffer: Record "XML Buffer" temporary)
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Element);
        TempXMLBuffer.SetRange(Path, '/Invoice/cac:InvoiceLine/cac:Item/cac:StandardItemIdentification/cbc:ID');
        if TempXMLBuffer.FindSet() then
            repeat
                TempXMLBuffer.Value := Format(Random(100000));
                TempXMLBuffer.Modify();
            until TempXMLBuffer.Next() = 0;
    end;

    local procedure UpdateValueInBuffer(var TempXMLBuffer: Record "XML Buffer" temporary; XPath: Text; XValue: Text[250])
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Element);
        TempXMLBuffer.SetRange(Path, XPath);
        if TempXMLBuffer.FindFirst() then begin
            TempXMLBuffer.Value := XValue;
            TempXMLBuffer.Modify();
        end;
    end;

    local procedure DeleteInBuffer(var TempXMLBuffer: Record "XML Buffer" temporary; XPath: Text)
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Element);
        TempXMLBuffer.SetRange(Path, XPath);
        TempXMLBuffer.DeleteAll();
    end;

    local procedure CreateEDocument(Filetxt: Text)
    var
        EDocument: Record "E-Document";
        TempBlob: Codeunit "Temp Blob";
        EDocImportHelper: Codeunit "E-Document Import Helper";
        XMLOutStream: OutStream;
    begin
        EDocImportHelper.SetHideDialogs(true);
        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(StrSubstNo(Filetxt));
        EDocument := CreateEDoc(TempBlob);
        EDocImportHelper.ProcessDocument(EDocument, false);
    end;

    local procedure CreateEDoc(var TempBlob: Codeunit "Temp Blob"): Record "E-Document";
    var
        EDocument: Record "E-Document";
        EDocService: Record "E-Document Service";
        EDocServiceStatus: Record "E-Document Service Status";
        CreateEDocumentSetup: Codeunit "Create E-Document Setup";
        EDocumentLog: Codeunit "E-Document Log Helper";

    begin
        EDocument.Init();
        EDocument."Entry No" := 0;
        EDocument.Status := EDocument.Status::"In Progress";
        EDocument.Direction := EDocument.Direction::Incoming;
        EDocument.Insert();

        EDocService.Get(CreateEDocumentSetup.EDocService());
        EDocumentLog.InsertLog(EDocument, EDocService, TempBlob, Enum::"E-Document Service Status"::Imported);
        EDocServiceStatus.Init();
        EDocServiceStatus."E-Document Entry No" := EDocument."Entry No";
        EDocServiceStatus."E-Document Service Code" := EDocService.Code;
        EDocServiceStatus.Status := Enum::"E-Document Service Status"::Imported;
        EDocServiceStatus.Insert();

        exit(EDocument);
    end;

    local procedure CreateSalesInvoice(CustomerNo: Code[20]): Record "Sales Header"
    var
        ContosoSales: Codeunit "Contoso Sales";
    begin
        exit(ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CustomerNo, '', WorkDate(), ''))
    end;

    local procedure CreateSalesInvLine(var SalesHeader: Record "Sales Header"; ItemNo: Code[20]; Quantity: Integer; NewDescription: Text[100]; Cost: Decimal): Record "Sales Header"
    begin
        exit(CreateSalesInvLine(SalesHeader, ItemNo, Quantity, NewDescription, Cost, 0));
    end;

    local procedure CreateSalesInvLine(var SalesHeader: Record "Sales Header"; ItemNo: Code[20]; Quantity: Integer; NewDescription: Text[100]; Cost: Decimal; Discount: Decimal): Record "Sales Header"
    var
        SalesLine: Record "Sales Line";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesInvHeader: Record "Sales Invoice Header";
        ContosoSales: Codeunit "Contoso Sales";
    begin
        ContosoSales.InsertSalesLineWithItem(SalesHeader, ItemNo, Quantity);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.FindLast();
        SalesLine.Description := NewDescription;
        SalesLine.Validate("Unit Price", Cost);
        SalesLine.Validate("Line Discount %", Discount);
        SalesLine.Modify();
        SalesInvHeader.Get(SalesHeader."No.");
        SalesInvoiceLine.InitFromSalesLine(SalesInvHeader, SalesLine);
        SalesInvoiceLine."Line No." := GetNextSalesInvLineNo(SalesInvHeader);
        SalesInvoiceLine.Insert();
        SalesLine.Delete();
    end;

    local procedure GetNextSalesInvLineNo(SalesInvHeader: Record "Sales Invoice Header"): Integer
    var
        SalesInvLine: Record "Sales Invoice Line";
    begin
        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        SalesInvLine.SetCurrentKey("Line No.");

        if SalesInvLine.FindLast() then
            exit(SalesInvLine."Line No." + 10000)
        else
            exit(10000);
    end;

    local procedure GetItemWRB1003(): Code[20]
    begin
        exit('WRB-1003');
    end;

    local procedure CreateOrder(VendorNo: Code[20]): Record "Purchase Header";
    var
        ContosoPurchase: Codeunit "Contoso Purchase";
    begin
        exit(ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, VendorNo, '', 20240301D, ''));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post (Yes/No)", OnBeforeConfirmPost, '', false, false)]
    local procedure OnBeforeConfirmPurchPost(var PurchaseHeader: Record "Purchase Header"; var HideDialog: Boolean; var IsHandled: Boolean; var DefaultOption: Integer)
    begin
        HideDialog := true;
        DefaultOption := 1;
    end;

}