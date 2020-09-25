codeunit 11423 "Digital Tax. Decl. Mgt."
{

    var
        ReceiveDeclarationTxt: Label 'Receiving Electronic Tax Declaration Responses...';
        HeaderNotFoundErr: Label 'VAT Report header %1,%2 could not be found.', Comment = '%1,%2 - key values';
        // fault model labels
        DigipoortTok: Label 'DigipoortTelemetryCategoryTok', Locked = true;
        ProcessingResponseMsg: Label 'Processing response message', Locked = true;
        ResponseProcessedSuccessMsg: Label 'Response message succesfully processed', Locked = true;
        HeaderNotFoundErrMsg: Label 'Error while processing response: Cannot find VAT report header.', Locked = true;
        ErrorStatusCodeMsg: Label 'Error while processing response, status code %1', Locked = true;
        AcceptedStatusCodeMsg: Label 'Successful response, status code: %1', Locked = true;

    trigger OnRun()
    begin
    end;

    procedure AddInstallationDistanceSalesWithinTheEC(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        AddElectronicTaxCode(TempNameValueBuffer, '3C', 'InstallationDistanceSalesWithinTheEC');
    end;

    procedure AddSmallEntrepreneurProvisionReduction(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        AddElectronicTaxCode(TempNameValueBuffer, '5D', 'SmallEntrepreneurProvisionReduction');
    end;

    procedure AddSuppliesServicesNotTaxed(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        AddElectronicTaxCode(TempNameValueBuffer, '1E', 'SuppliesServicesNotTaxed');
    end;

    procedure AddSuppliesToCountriesOutsideTheEC(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        AddElectronicTaxCode(TempNameValueBuffer, '3A', 'SuppliesToCountriesOutsideTheEC');
    end;

    procedure AddSuppliesToCountriesWithinTheEC(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        AddElectronicTaxCode(TempNameValueBuffer, '3B', 'SuppliesToCountriesWithinTheEC');
    end;

    procedure AddTaxedTurnoverPrivateUse(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        AddElectronicTaxCode(TempNameValueBuffer, '1D1', 'TaxedTurnoverPrivateUse');
    end;

    procedure AddTaxedTurnoverSuppliesServicesGeneralTariff(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        AddElectronicTaxCode(TempNameValueBuffer, '1A-1', 'TaxedTurnoverSuppliesServicesGeneralTariff');
    end;

    procedure AddTaxedTurnoverSuppliesServicesOtherRates(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        AddElectronicTaxCode(TempNameValueBuffer, '1C-1', 'TaxedTurnoverSuppliesServicesOtherRates');
    end;

    procedure AddTaxedTurnoverSuppliesServicesReducedTariff(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        AddElectronicTaxCode(TempNameValueBuffer, '1B-1', 'TaxedTurnoverSuppliesServicesReducedTariff');
    end;

    procedure AddTurnoverFromTaxedSuppliesFromCountriesOutsideTheEC(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        AddElectronicTaxCode(TempNameValueBuffer, '4A-1', 'TurnoverFromTaxedSuppliesFromCountriesOutsideTheEC');
    end;

    procedure AddTurnoverFromTaxedSuppliesFromCountriesWithinTheEC(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        AddElectronicTaxCode(TempNameValueBuffer, '4B-1', 'TurnoverFromTaxedSuppliesFromCountriesWithinTheEC');
    end;

    procedure AddTurnoverSuppliesServicesByWhichVATTaxationIsTransferred(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        AddElectronicTaxCode(TempNameValueBuffer, '4A-1', 'TurnoverSuppliesServicesByWhichVATTaxationIsTransferred');
    end;

    procedure AddValueAddedTaxOnInput(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        AddElectronicTaxCode(TempNameValueBuffer, '5B', 'ValueAddedTaxOnInput');
    end;

    procedure AddValueAddedTaxOnSuppliesFromCountriesOutsideTheEC(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        AddElectronicTaxCode(TempNameValueBuffer, '4A-2', 'ValueAddedTaxOnSuppliesFromCountriesOutsideTheEC');
    end;

    procedure AddValueAddedTaxOnSuppliesFromCountriesWithinTheEC(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        AddElectronicTaxCode(TempNameValueBuffer, '4B-2', 'ValueAddedTaxOnSuppliesFromCountriesWithinTheEC');
    end;

    procedure AddValueAddedTaxOwed(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        AddElectronicTaxCode(TempNameValueBuffer, '5A', 'ValueAddedTaxOwed');
    end;

    procedure AddValueAddedTaxOwedToBePaidBack(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        AddElectronicTaxCode(TempNameValueBuffer, '5G', 'ValueAddedTaxOwedToBePaidBack');
    end;

    procedure AddValueAddedTaxPrivateUse(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        AddElectronicTaxCode(TempNameValueBuffer, '1D-2', 'ValueAddedTaxPrivateUse');
    end;

    procedure AddValueAddedTaxSuppliesServicesByWhichVATTaxationIsTransferred(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        AddElectronicTaxCode(TempNameValueBuffer, '2A-2', 'ValueAddedTaxSuppliesServicesByWhichVATTaxationIsTransferred');
    end;

    procedure AddValueAddedTaxSuppliesServicesGeneralTariff(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        AddElectronicTaxCode(TempNameValueBuffer, '1A-2', 'ValueAddedTaxSuppliesServicesGeneralTariff');
    end;

    procedure AddValueAddedTaxSuppliesServicesOtherRates(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        AddElectronicTaxCode(TempNameValueBuffer, '1C-2', 'ValueAddedTaxSuppliesServicesOtherRates');
    end;

    procedure AddValueAddedTaxSuppliesServicesReducedTariff(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        AddElectronicTaxCode(TempNameValueBuffer, '1B-2', 'ValueAddedTaxSuppliesServicesReducedTariff');
    end;

    procedure AddElectronicTaxCode(var TempNameValueBuffer: Record "Name/Value Buffer" temporary; Name: Text[250]; Value: Text[250])
    var
        ID: Integer;
    begin
        TempNameValueBuffer.Reset();
        if TempNameValueBuffer.FindLast() then
            ID := TempNameValueBuffer.ID;
        ID += 1;
        TempNameValueBuffer.ID := ID;
        TempNameValueBuffer.Name := Name;
        TempNameValueBuffer.Value := Value;
        TempNameValueBuffer.Insert();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Elec. Tax Decl. Response Msgs.", 'OnReceiveResponseMessages', '', false, false)]
    [NonDebuggable]
    procedure OnReceiveResponseMessages(var Handled: Boolean; var ElecTaxDeclResponseMessages: Record "Elec. Tax Decl. Response Msg.");
    var
        VATReportHeader: Record "VAT Report Header";
        ElecTaxDeclarationSetup: Record "Elec. Tax Declaration Setup";
        ElecTaxDeclarationMgt: Codeunit "Elec. Tax Declaration Mgt.";
        DotNet_SecureString: Codeunit DotNet_SecureString;
        ClientCertificateBase64: Text;
        ServiceCertificateBase64: Text;
        Window: Dialog;
    begin
        with ElecTaxDeclResponseMessages do
            if GetFilter("VAT Report No.") <> '' then begin
                Handled := true;
                ElecTaxDeclarationSetup.Get();
                ElecTaxDeclarationSetup.CheckDigipoortSetup();
                if GuiAllowed() then
                    Window.Open(ReceiveDeclarationTxt);

                ElecTaxDeclarationSetup.Get();
                ElecTaxDeclarationSetup.CheckDigipoortSetup();
                VATReportHeader.SetRange("No.", GetFilter("VAT Report No."));
                VATReportHeader.SetFilter("VAT Report Config. Code", GetFilter("VAT Report Config. Code"));
                if not VATReportHeader.FindFirst() then
                    exit;
                ElecTaxDeclarationMgt.InitCertificatesWithPassword(
                    ClientCertificateBase64, DotNet_SecureString, ServiceCertificateBase64);
                ElecTaxDeclarationMgt.ReceiveResponse(VATReportHeader, ClientCertificateBase64, DotNet_SecureString, ServiceCertificateBase64);
                if GuiAllowed() then
                    Window.Close();
            end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Elec. Tax Decl. Response Msgs.", 'OnProcessResponseMessages', '', false, false)]
    procedure OnProcessResponseMessages(var Handled: Boolean; var ElecTaxDeclResponseMessages: Record "Elec. Tax Decl. Response Msg.");
    begin
        with ElecTaxDeclResponseMessages do
            if GetFilter("VAT Report No.") <> '' then begin
                if ElecTaxDeclResponseMessages.FindSet() then
                    repeat
                        ProcessResponseMessage(ElecTaxDeclResponseMessages);
                    until ElecTaxDeclResponseMessages.Next() = 0;
                Handled := true;
            end;
    end;

    local procedure ProcessResponseMessage(var ElecTaxDeclResponseMessages: Record "Elec. Tax Decl. Response Msg.")
    var
        VATReportHeader: Record "VAT Report Header";
        ErrorLog: Record "Elec. Tax Decl. Error Log";
        VATReportArchive: Record "VAT Report Archive";
        TempBlob: Codeunit "Temp Blob";
        XMLDoc: XmlDocument;
        InStream: InStream;
        BlobOutStream: OutStream;
        NodeList: XmlNodeList;
        XmlNode: XmlNode;
        Index: Integer;
        NextErrorNo: Integer;
    begin
        with ElecTaxDeclResponseMessages do begin
            Session.LogMessage('0000CJ3', ProcessingResponseMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DigipoortTok);

            if not VATReportHeader.Get("VAT Report Config. Code", "VAT Report No.") then begin
                Session.LogMessage('0000CJ4', HeaderNotFoundErrMsg, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DigipoortTok);
                Error(HeaderNotFoundErr, "VAT Report Config. Code", "VAT Report No.");
            end;

            ErrorLog.Reset();
            ErrorLog.SetRange("VAT Report Config. Code", "VAT Report Config. Code");
            ErrorLog.SetRange("VAT Report No.", "VAT Report No.");
            if not ErrorLog.FindLast() then
                ErrorLog."No." := 0;
            NextErrorNo := ErrorLog."No." + 1;

            CalcFields(Message);
            if Message.HasValue() and ("Status Code" in ['311']) then begin
                Message.CreateInStream(InStream);
                XmlDocument.ReadFrom(InStream, XMLDoc);
                TempBlob.CreateOutStream(BlobOutStream);
                CopyStream(BlobOutStream, InStream);
                VATReportArchive.ArchiveResponseMessage(VATReportHeader."VAT Report Config. Code", VATReportHeader."No.", TempBlob);

                XMLDoc.SelectNodes('msg', NodeList);
                for Index := 0 to NodeList.Count() - 1 do begin
                    NodeList.Get(Index, XmlNode);

                    ErrorLog.Init();
                    ErrorLog."No." := NextErrorNo;
                    ErrorLog."Declaration Type" := "Declaration Type";
                    ErrorLog."Declaration No." := "Declaration No.";
                    ErrorLog."Error Class" := CopyStr(GetAttributeValue(XmlNode, 'level'), 1, MaxStrLen(ErrorLog."Error Class"));
                    ErrorLog."Error Description" := CopyStr(XmlNode.AsXmlText().Value(), 1, MaxStrLen(ErrorLog."Error Description"));

                    ErrorLog.Insert(true);
                    NextErrorNo += 1;
                end;
            end;

            case "Status Code" of
                '210', '220', '311', '410', '510', '710':
                    begin
                        VATReportHeader.Status := VATReportHeader.Status::Rejected;
                        Session.LogMessage('0000CJ5', StrSubstNo(ErrorStatusCodeMsg, "Status Code"), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DigipoortTok);
                    end;
                '100', '230', '321', '420', '720':
                    if VATReportHeader.Status <> VATReportHeader.Status::Rejected then begin
                        VATReportHeader.Status := VATReportHeader.Status::Accepted;
                        Session.LogMessage('0000CJ6', StrSubstNo(AcceptedStatusCodeMsg, "Status Code"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DigipoortTok);
                    end;
            end;

            Status := Status::Processed;
            Modify(true);

            VATReportHeader.Modify(true);

            Session.LogMessage('0000CJ8', ResponseProcessedSuccessMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DigipoortTok);
        end;
    end;

    local procedure GetAttributeValue(var XMLNode: XmlNode; "Key": Text): Text
    var
        XmlAtt: XmlAttribute;
        XmlAttributes: XmlAttributeCollection;
    begin
        XmlAttributes := XMLNode.AsXmlElement().Attributes();
        XmlAttributes.Get(Key, XmlAtt);
        exit(XmlAtt.Value());
    end;
}

