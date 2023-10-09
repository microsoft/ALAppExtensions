codeunit 148097 "Swiss QR-Bill Xml"
{
    var
        AttachmentXmlDocText: Text;

    procedure InitAttachmentXmlDocText(Params: Dictionary of [Text, Text])
    var
        TypeHelper: Codeunit "Type Helper";
        CRLF: Text[2];
        ReferenceNo: Text;
        VendorName: Text;
    begin
        if not Params.Get('qrreference', ReferenceNo) then
            ReferenceNo := '000000000000000000000000026';

        if not Params.Get('supplier', VendorName) then
            VendorName := 'Test Vendor Name';

        CRLF := TypeHelper.CRLFSeparator();
        AttachmentXmlDocText :=
            '<Document xmlns:i="http://www.w3.org/2001/XMLSchema-instance">' + CRLF +
            '    <Id>0691bd5cff80171a4823b5c155091d25</Id>' + CRLF +
            '    <Version i:nil="true"/>' + CRLF +
            '    <Type>CHEPO</Type>' + CRLF +
            '    <OriginalFilename>Swiss QR-Bill.pdf</OriginalFilename>' + CRLF +
            '    <Filename>0691bd5cff80171a4823b5c155091d25.tif</Filename>' + CRLF +
            '    <Parties>' + CRLF +
            '        <Party>' + CRLF +
            '            <Type>buyer</Type>' + CRLF +
            '            <Name>CRONUS International Ltd.</Name>' + CRLF +
            '            <Id>9e9971eddc45464398563aa71daca822</Id>' + CRLF +
            '            <ExternalId i:nil="true"/>' + CRLF +
            '            <Description/>' + CRLF +
            '            <TaxRegistrationNumber/>' + CRLF +
            '            <OrganizationNumber/>' + CRLF +
            '            <Street/>' + CRLF +
            '            <PostalCode/>' + CRLF +
            '            <City/>' + CRLF +
            '            <CountryName/>' + CRLF +
            '            <PaymentTerm/>' + CRLF +
            '            <PaymentMethod/>' + CRLF +
            '            <CurrencyCode/>' + CRLF +
            '            <BankAccounts i:nil="true"/>' + CRLF +
            '            <ValidationError>0</ValidationError>' + CRLF +
            '            <ValidationErrorMessage/>' + CRLF +
            '            <Location/>' + CRLF +
            '            <State/>' + CRLF +
            '            <Blocked>false</Blocked>' + CRLF +
            '            <TelephoneNumber/>' + CRLF +
            '            <FaxNumber/>' + CRLF +
            '            <TaxCode/>' + CRLF +
            '        </Party>' + CRLF +
            '        <Party>' + CRLF +
            '            <Type>supplier</Type>' + CRLF +
            '            <Name>' + VendorName + '</Name>' + CRLF +
            '            <Id>dc564efa-6bc1-44cb-a683-bde3f1c0bb22</Id>' + CRLF +
            '            <ExternalId/>' + CRLF +
            '            <Description/>' + CRLF +
            '            <TaxRegistrationNumber/>' + CRLF +
            '            <OrganizationNumber/>' + CRLF +
            '            <Street/>' + CRLF +
            '            <PostalCode/>' + CRLF +
            '            <City/>' + CRLF +
            '            <CountryName/>' + CRLF +
            '            <PaymentTerm/>' + CRLF +
            '            <PaymentMethod/>' + CRLF +
            '            <CurrencyCode/>' + CRLF +
            '            <BankAccounts i:nil="true"/>' + CRLF +
            '            <ValidationError>0</ValidationError>' + CRLF +
            '            <ValidationErrorMessage/>' + CRLF +
            '            <Location/>' + CRLF +
            '            <State/>' + CRLF +
            '            <Blocked>false</Blocked>' + CRLF +
            '            <TelephoneNumber/>' + CRLF +
            '            <FaxNumber/>' + CRLF +
            '            <TaxCode/>' + CRLF +
            '        </Party>' + CRLF +
            '    </Parties>' + CRLF +
            '    <HeaderFields>' + CRLF +
            '        <HeaderField>' + CRLF +
            '            <Name>CreditInvoice</Name>' + CRLF +
            '            <Type>creditinvoice</Type>' + CRLF +
            '            <Format/>' + CRLF +
            '            <Text>false</Text>' + CRLF +
            '            <ValidationError>0</ValidationError>' + CRLF +
            '            <Position>0,0,0,0</Position>' + CRLF +
            '            <PageNumber>1</PageNumber>' + CRLF +
            '            <ValidationErrorMessage/>' + CRLF +
            '            <IsReadOnly>' + CRLF +
            '                <Value>false</Value>' + CRLF +
            '            </IsReadOnly>' + CRLF +
            '            <DataType i:nil="true"/>' + CRLF +
            '            <TextDetail i:nil="true"/>' + CRLF +
            '            <IsHidden>false</IsHidden>' + CRLF +
            '            <ValidationDetails i:nil="true"/>' + CRLF +
            '        </HeaderField>' + CRLF +
            '        <HeaderField>' + CRLF +
            '            <Name>InvoiceNumber</Name>' + CRLF +
            '            <Type>invoicenumber</Type>' + CRLF +
            '            <Format>^.{1,100}$</Format>' + CRLF +
            '            <Text>103032</Text>' + CRLF +
            '            <ValidationError>0</ValidationError>' + CRLF +
            '            <Position>0, 0, 0, 0</Position>' + CRLF +
            '            <PageNumber>1</PageNumber>' + CRLF +
            '            <ValidationErrorMessage i:nil="true"/>' + CRLF +
            '            <IsReadOnly>' + CRLF +
            '                <Value>false</Value>' + CRLF +
            '            </IsReadOnly>' + CRLF +
            '            <DataType>0</DataType>' + CRLF +
            '            <TextDetail i:nil="true"/>' + CRLF +
            '            <IsHidden>false</IsHidden>' + CRLF +
            '            <ValidationDetails/>' + CRLF +
            '        </HeaderField>' + CRLF +
            '        <HeaderField>' + CRLF +
            '            <Name>InvoiceDate</Name>' + CRLF +
            '            <Type>invoicedate</Type>' + CRLF +
            '            <Format>.*</Format>' + CRLF +
            '            <Text>20250123</Text>' + CRLF +
            '            <ValidationError>0</ValidationError>' + CRLF +
            '            <Position>0, 0, 0, 0</Position>' + CRLF +
            '            <PageNumber>1</PageNumber>' + CRLF +
            '            <ValidationErrorMessage i:nil="true"/>' + CRLF +
            '            <IsReadOnly>' + CRLF +
            '                <Value>false</Value>' + CRLF +
            '            </IsReadOnly>' + CRLF +
            '            <DataType>2</DataType>' + CRLF +
            '            <TextDetail i:nil="true"/>' + CRLF +
            '            <IsHidden>false</IsHidden>' + CRLF +
            '            <ValidationDetails/>' + CRLF +
            '        </HeaderField>' + CRLF +
            '        <HeaderField>' + CRLF +
            '            <Name>VATAmount</Name>' + CRLF +
            '            <Type>invoicetotalvatamount</Type>' + CRLF +
            '            <Format>.*</Format>' + CRLF +
            '            <Text>0.00</Text>' + CRLF +
            '            <ValidationError>0</ValidationError>' + CRLF +
            '            <Position>0, 0, 0, 0</Position>' + CRLF +
            '            <PageNumber>1</PageNumber>' + CRLF +
            '            <ValidationErrorMessage i:nil="true"/>' + CRLF +
            '            <IsReadOnly>' + CRLF +
            '                <Value>false</Value>' + CRLF +
            '            </IsReadOnly>' + CRLF +
            '            <DataType>1</DataType>' + CRLF +
            '            <TextDetail i:nil="true"/>' + CRLF +
            '            <IsHidden>false</IsHidden>' + CRLF +
            '            <ValidationDetails/>' + CRLF +
            '        </HeaderField>' + CRLF +
            '        <HeaderField>' + CRLF +
            '            <Name>GrossValue</Name>' + CRLF +
            '            <Type>invoicetotalvatincludedamount</Type>' + CRLF +
            '            <Format>.*</Format>' + CRLF +
            '            <Text>4320.00</Text>' + CRLF +
            '            <ValidationError>0</ValidationError>' + CRLF +
            '            <Position>791, 2467, 543, 543</Position>' + CRLF +
            '            <PageNumber>1</PageNumber>' + CRLF +
            '            <ValidationErrorMessage i:nil="true"/>' + CRLF +
            '            <IsReadOnly>' + CRLF +
            '                <Value>false</Value>' + CRLF +
            '            </IsReadOnly>' + CRLF +
            '            <DataType>1</DataType>' + CRLF +
            '            <TextDetail i:nil="true"/>' + CRLF +
            '            <IsHidden>false</IsHidden>' + CRLF +
            '            <ValidationDetails/>' + CRLF +
            '        </HeaderField>' + CRLF +
            '        <HeaderField>' + CRLF +
            '            <Name>Currency</Name>' + CRLF +
            '            <Type>invoicecurrency</Type>' + CRLF +
            '            <Format>^.{1,100}$</Format>' + CRLF +
            '            <Text>CHF</Text>' + CRLF +
            '            <ValidationError>0</ValidationError>' + CRLF +
            '            <Position>791, 2467, 543, 543</Position>' + CRLF +
            '            <PageNumber>1</PageNumber>' + CRLF +
            '            <ValidationErrorMessage i:nil="true"/>' + CRLF +
            '            <IsReadOnly>' + CRLF +
            '                <Value>false</Value>' + CRLF +
            '            </IsReadOnly>' + CRLF +
            '            <DataType>0</DataType>' + CRLF +
            '            <TextDetail i:nil="true"/>' + CRLF +
            '            <IsHidden>false</IsHidden>' + CRLF +
            '            <ValidationDetails/>' + CRLF +
            '        </HeaderField>' + CRLF +
            '        <HeaderField>' + CRLF +
            '            <Name>VATReg</Name>' + CRLF +
            '            <Type>suppliervatregistrationnumber</Type>' + CRLF +
            '            <Format>^.{1,100}$</Format>' + CRLF +
            '            <Text/>' + CRLF +
            '            <ValidationError>0</ValidationError>' + CRLF +
            '            <Position>0, 0, 0, 0</Position>' + CRLF +
            '            <PageNumber>1</PageNumber>' + CRLF +
            '            <ValidationErrorMessage i:nil="true"/>' + CRLF +
            '            <IsReadOnly>' + CRLF +
            '                <Value>false</Value>' + CRLF +
            '            </IsReadOnly>' + CRLF +
            '            <DataType>0</DataType>' + CRLF +
            '            <TextDetail i:nil="true"/>' + CRLF +
            '            <IsHidden>false</IsHidden>' + CRLF +
            '            <ValidationDetails/>' + CRLF +
            '        </HeaderField>' + CRLF +
            '        <HeaderField>' + CRLF +
            '            <Name>NetAmount</Name>' + CRLF +
            '            <Type>invoicetotalvatexcludedamount</Type>' + CRLF +
            '            <Format>.*</Format>' + CRLF +
            '            <Text>4320.00</Text>' + CRLF +
            '            <ValidationError>0</ValidationError>' + CRLF +
            '            <Position>190, 3129, 159, 30</Position>' + CRLF +
            '            <PageNumber>1</PageNumber>' + CRLF +
            '            <ValidationErrorMessage i:nil="true"/>' + CRLF +
            '            <IsReadOnly>' + CRLF +
            '                <Value>false</Value>' + CRLF +
            '            </IsReadOnly>' + CRLF +
            '            <DataType>1</DataType>' + CRLF +
            '            <TextDetail i:nil="true"/>' + CRLF +
            '            <IsHidden>false</IsHidden>' + CRLF +
            '            <ValidationDetails/>' + CRLF +
            '        </HeaderField>' + CRLF +
            '        <HeaderField>' + CRLF +
            '            <Name>PurchaseOrderNumber</Name>' + CRLF +
            '            <Type>invoiceordernumber</Type>' + CRLF +
            '            <Format>^.{1,100}$</Format>' + CRLF +
            '            <Text/>' + CRLF +
            '            <ValidationError>0</ValidationError>' + CRLF +
            '            <Position>0, 0, 0, 0</Position>' + CRLF +
            '            <PageNumber>0</PageNumber>' + CRLF +
            '            <ValidationErrorMessage i:nil="true"/>' + CRLF +
            '            <IsReadOnly>' + CRLF +
            '                <Value>false</Value>' + CRLF +
            '            </IsReadOnly>' + CRLF +
            '            <DataType>0</DataType>' + CRLF +
            '            <TextDetail i:nil="true"/>' + CRLF +
            '            <IsHidden>false</IsHidden>' + CRLF +
            '            <ValidationDetails/>' + CRLF +
            '        </HeaderField>' + CRLF +
            '        <HeaderField>' + CRLF +
            '            <Name>BankAccount</Name>' + CRLF +
            '            <Type>supplieraccountnumber1</Type>' + CRLF +
            '            <Format>^.{1,100}$</Format>' + CRLF +
            '            <Text/>' + CRLF +
            '            <ValidationError>0</ValidationError>' + CRLF +
            '            <Position>0, 0, 0, 0</Position>' + CRLF +
            '            <PageNumber>1</PageNumber>' + CRLF +
            '            <ValidationErrorMessage i:nil="true"/>' + CRLF +
            '            <IsReadOnly>' + CRLF +
            '                <Value>false</Value>' + CRLF +
            '            </IsReadOnly>' + CRLF +
            '            <DataType>0</DataType>' + CRLF +
            '            <TextDetail i:nil="true"/>' + CRLF +
            '            <IsHidden>false</IsHidden>' + CRLF +
            '            <ValidationDetails/>' + CRLF +
            '        </HeaderField>' + CRLF +
            '        <HeaderField>' + CRLF +
            '            <Name>DueDate</Name>' + CRLF +
            '            <Type>invoiceduedate</Type>' + CRLF +
            '            <Format>.*</Format>' + CRLF +
            '            <Text>20250123</Text>' + CRLF +
            '            <ValidationError>0</ValidationError>' + CRLF +
            '            <Position>0, 0, 0, 0</Position>' + CRLF +
            '            <PageNumber>1</PageNumber>' + CRLF +
            '            <ValidationErrorMessage i:nil="true"/>' + CRLF +
            '            <IsReadOnly>' + CRLF +
            '                <Value>false</Value>' + CRLF +
            '            </IsReadOnly>' + CRLF +
            '            <DataType>2</DataType>' + CRLF +
            '            <TextDetail i:nil="true"/>' + CRLF +
            '            <IsHidden>false</IsHidden>' + CRLF +
            '            <ValidationDetails/>' + CRLF +
            '        </HeaderField>' + CRLF +
            '        <HeaderField>' + CRLF +
            '            <Name>IBAN</Name>' + CRLF +
            '            <Type>supplieriban1</Type>' + CRLF +
            '            <Format>^.{1,100}$</Format>' + CRLF +
            '            <Text>CH5800791123000889012</Text>' + CRLF +
            '            <ValidationError>0</ValidationError>' + CRLF +
            '            <Position>791, 2467, 543, 543</Position>' + CRLF +
            '            <PageNumber>1</PageNumber>' + CRLF +
            '            <ValidationErrorMessage i:nil="true"/>' + CRLF +
            '            <IsReadOnly>' + CRLF +
            '                <Value>false</Value>' + CRLF +
            '            </IsReadOnly>' + CRLF +
            '            <DataType>0</DataType>' + CRLF +
            '            <TextDetail i:nil="true"/>' + CRLF +
            '            <IsHidden>false</IsHidden>' + CRLF +
            '            <ValidationDetails/>' + CRLF +
            '        </HeaderField>' + CRLF +
            '        <HeaderField>' + CRLF +
            '            <Name>QrReference</Name>' + CRLF +
            '            <Type>qrreference</Type>' + CRLF +
            '            <Format>^.{1,100}$</Format>' + CRLF +
            '            <Text>' + ReferenceNo + '</Text>' + CRLF +
            '            <ValidationError>0</ValidationError>' + CRLF +
            '            <Position>791, 2467, 543, 543</Position>' + CRLF +
            '            <PageNumber>1</PageNumber>' + CRLF +
            '            <ValidationErrorMessage i:nil="true"/>' + CRLF +
            '            <IsReadOnly>' + CRLF +
            '                <Value>false</Value>' + CRLF +
            '            </IsReadOnly>' + CRLF +
            '            <DataType>0</DataType>' + CRLF +
            '            <TextDetail i:nil="true"/>' + CRLF +
            '            <IsHidden>false</IsHidden>' + CRLF +
            '            <ValidationDetails/>' + CRLF +
            '        </HeaderField>' + CRLF +
            '    </HeaderFields>' + CRLF +
            '    <Tables>' + CRLF +
            '        <Table>' + CRLF +
            '            <Type>LineItem</Type>' + CRLF +
            '            <TableColumns>' + CRLF +
            '                <TableColumn>' + CRLF +
            '                    <Name>ArticleNumber</Name>' + CRLF +
            '                    <Type>LIT_ArticleIdentifier</Type>' + CRLF +
            '                    <Format>^[#$%&amp;''()*+,\-.\/0-9:&lt;&gt;@[\\\]_£€A-ZÅÄÖÉÆØÜßÀÂÁÇÈÊÎÏÍÌÔÓÒÕÙÛÚÜÑŠŽa-zåäöéæøüßàâáçèêîïíìôóòõùûúüñšž]{1,30}$</Format>' + CRLF +
            '                    <DataType>0</DataType>' + CRLF +
            '                </TableColumn>' + CRLF +
            '                <TableColumn>' + CRLF +
            '                    <Name>Quantity</Name>' + CRLF +
            '                    <Type>LIT_DeliveredQuantity</Type>' + CRLF +
            '                    <Format>.*</Format>' + CRLF +
            '                    <DataType>1</DataType>' + CRLF +
            '                </TableColumn>' + CRLF +
            '                <TableColumn>' + CRLF +
            '                    <Name>Unit</Name>' + CRLF +
            '                    <Type>LIT_DeliveredQuantityUnitCode</Type>' + CRLF +
            '                    <Format>^[A-ZÅÄÖÉÆØÜßÀÂÁÇÈÊÎÏÍÌÔÓÒÕÙÛÚÜÑŠŽa-zåäöéæøüßàâáçèêîïíìôóòõùûúüñšž]{1,20}$</Format>' + CRLF +
            '                    <DataType>0</DataType>' + CRLF +
            '                </TableColumn>' + CRLF +
            '                <TableColumn>' + CRLF +
            '                    <Name>UnitPrice</Name>' + CRLF +
            '                    <Type>LIT_UnitPriceAmount</Type>' + CRLF +
            '                    <Format>.*</Format>' + CRLF +
            '                    <DataType>1</DataType>' + CRLF +
            '                </TableColumn>' + CRLF +
            '                <TableColumn>' + CRLF +
            '                    <Name>RowTotal</Name>' + CRLF +
            '                    <Type>LIT_VatExcludedAmount</Type>' + CRLF +
            '                    <Format>.*</Format>' + CRLF +
            '                    <DataType>1</DataType>' + CRLF +
            '                </TableColumn>' + CRLF +
            '                <TableColumn>' + CRLF +
            '                    <Name>ArticleName</Name>' + CRLF +
            '                    <Type>LIT_ArticleName</Type>' + CRLF +
            '                    <Format>^[#$%&amp;''()*+,\-.\/0-9:&lt;&gt;@[\\\]_£€A-ZÅÄÖÉÆØÜßÀÂÁÇÈÊÎÏÍÌÔÓÒÕÙÛÚÜÑŠŽa-zåäöéæøüßàâáçèêîïíìôóòõùûúüñšž  ]{1,100}$</Format>' + CRLF +
            '                    <DataType>0</DataType>' + CRLF +
            '                </TableColumn>' + CRLF +
            '            </TableColumns>' + CRLF +
            '            <TableRows/>' + CRLF +
            '        </Table>' + CRLF +
            '    </Tables>' + CRLF +
            '    <ProcessMessages/>' + CRLF +
            '    <SystemFields/>' + CRLF +
            '    <AccountingInformation>' + CRLF +
            '        <CodingLines/>' + CRLF +
            '        <ParkDocument>false</ParkDocument>' + CRLF +
            '    </AccountingInformation>' + CRLF +
            '    <ErpCorrelationData i:nil="true"/>' + CRLF +
            '    <BaseType>SupplierInvoice</BaseType>' + CRLF +
            '    <Permalink i:nil="true"/>' + CRLF +
            '    <TrackId>20230330-1/1</TrackId>' + CRLF +
            '    <DocumentType>CHEPO</DocumentType>' + CRLF +
            '    <ValidationInfoCollection/>' + CRLF +
            '    <Origin i:nil="true"/>' + CRLF +
            '    <EmbeddedImage i:nil="true"/>' + CRLF +
            '    <DocumentSubType>Other</DocumentSubType>' + CRLF +
            '    <Attachments/>' + CRLF +
            '</Document>';
    end;

    procedure GetAttachmentXmlDocContent(var TempBlob: Codeunit "Temp Blob")
    var
        DocOutStream: OutStream;
    begin
        TempBlob.CreateOutStream(DocOutStream, TextEncoding::UTF8);
        DocOutStream.Write(AttachmentXmlDocText);
    end;
}