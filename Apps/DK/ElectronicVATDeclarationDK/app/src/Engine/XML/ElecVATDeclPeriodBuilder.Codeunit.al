namespace Microsoft.Finance.VAT.Reporting;

using System.Xml;

codeunit 13617 "Elec. VAT Decl. Period Builder" implements "Elec. VAT Decl. Payload Builder"
{
    Access = Internal;

    procedure BuildPayload(ElecVATDeclParameters: Record "Elec. VAT Decl. Parameters"; var Body: XmlNode; var ReferenceList: List of [Text]; var TransactionID: Code[100])
    var
        XMLDomManagement: Codeunit "XML Dom Management";
        ElecVATDeclXml: Codeunit "Elec. VAT Decl. Xml";
        VirksomhedKalenderHent_I: XmlNode;
        HovedOplysninger: XmlNode;
        TransaktionIdentifikator: XmlNode;
        TransaktionTid: XmlNode;
        AngivelseTypeNavn: XmlNode;
        VirksomhedSENummerIdentifikator: XmlNode;
        AngivelseBetalingFristHentFra: XmlNode;
        SoegeDatoFraDate: XmlNode;
        SoegeDatoTilDate: XmlNode;
        BodyTokenId: Text;
    begin
        // Body start
        Body := XmlElement.Create('Body', ElecVATDeclXml.GetSoapNamespace()).AsXmlNode();
        BodyTokenId := ElecVATDeclXml.GetBodyIdTok();
        XMLDomManagement.AddAttribute(Body, 'Id', BodyTokenId);
        ReferenceList.Add(BodyTokenId);

        XMLDomManagement.AddNamespaceDeclaration(Body, 'ns1', ElecVATDeclXml.GetSkatNamespace1());
        XMLDomManagement.AddNamespaceDeclaration(Body, 'ns2', ElecVATDeclXml.GetSkatNamespace2());
        XMLDomManagement.AddNamespaceDeclaration(Body, 'ns3', ElecVATDeclXml.GetSkatNamespace3());
        XMLDomManagement.AddNamespaceDeclaration(Body, 'ns4', ElecVATDeclXml.GetSkatNamespace4());
        // -VirksomhedKalenderHent_I
        XMLDomManagement.AddElement(Body, 'VirksomhedKalenderHent_I', '', ElecVATDeclXml.GetSkatNamespace1(), VirksomhedKalenderHent_I);
        // --HovedOplysninger start
        XMLDomManagement.AddElement(VirksomhedKalenderHent_I, 'HovedOplysninger', '', ElecVATDeclXml.GetSkatNamespace2(), HovedOplysninger);
        // ---TransaktionIdentifikator
        TransactionID := ElecVATDeclXml.GetTransactionID();
        XMLDomManagement.AddElement(HovedOplysninger, 'TransaktionIdentifikator', TransactionID, ElecVATDeclXml.GetSkatNamespace2(), TransaktionIdentifikator);
        // ---TransaktionTid
        XMLDomManagement.AddElement(HovedOplysninger, 'TransaktionTid', ElecVATDeclXml.GetTimeStamp(0), ElecVATDeclXml.GetSkatNamespace2(), TransaktionTid);
        // --HovedOplysninger end
        // --VirksomhedSENummerIdentifikator
        XMLDomManagement.AddElement(VirksomhedKalenderHent_I, 'VirksomhedSENummerIdentifikator', ElecVATDeclXml.GetCompanyID(), ElecVATDeclXml.GetSkatNamespace3(), VirksomhedSENummerIdentifikator);
        // --AngivelseTypeNavn
        XMLDomManagement.AddElement(VirksomhedKalenderHent_I, 'AngivelseTypeNavn', 'Moms', ElecVATDeclXml.GetSkatNamespace4(), AngivelseTypeNavn);
        // --AngivelseBetalingFristHentFra start
        XMLDomManagement.AddElement(VirksomhedKalenderHent_I, 'AngivelseBetalingFristHentFra', '', ElecVATDeclXml.GetSkatNamespace1(), AngivelseBetalingFristHentFra);
        // ---SoegeDatoFraDate
        XMLDomManagement.AddElement(AngivelseBetalingFristHentFra, 'SoegeDatoFraDate', ElecVATDeclXml.Date_AsXMLText(ElecVATDeclParameters."From Date"), ElecVATDeclXml.GetSkatNamespace4(), SoegeDatoFraDate);
        // ---SoegeDatoTilDate
        XMLDomManagement.AddElement(AngivelseBetalingFristHentFra, 'SoegeDatoTilDate', ElecVATDeclXml.Date_AsXMLText(ElecVATDeclParameters."To Date"), ElecVATDeclXml.GetSkatNamespace4(), SoegeDatoTilDate);
        // --AngivelseBetalingFristHentFra end
        // -VirksomhedKalenderHent_I end
        // Body end
    end;
}