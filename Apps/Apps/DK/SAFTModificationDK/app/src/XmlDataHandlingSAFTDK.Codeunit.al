// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Enums;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

codeunit 13689 "Xml Data Handling SAF-T DK" implements XmlDataHandlingSAFT
{
    Access = Internal;

    var
        XmlHelper: Codeunit "Xml Helper SAF-T Public";
        SAFTDataMgt: Codeunit "SAF-T Data Mgt.";
        NamespacePrefixTxt: label 'n1', Locked = true;
        NamespaceUriTxt: label 'urn:StandardAuditFile-Taxation-Financial:DK', Locked = true;
        GLAccIDTagNameTxt: label 'AccountID', Locked = true;
        TaxAuthValueTxt: label 'Skattestyrelsen', Locked = true;
        TaxAccBasisTxt: label 'Regnskab', Locked = true;
        GLAccTypeAssetTxt: label 'Asset', Locked = true;
        GLAccTypeLiabilityTxt: label 'Liability', Locked = true;
        GLAccTypeSaleTxt: label 'Sale', Locked = true;
        GLAccTypeExpenseTxt: label 'Expense', Locked = true;
        GLAccTypeOtherTxt: label 'Other', Locked = true;
        TaxTableEntryDescrTxt: label 'Moms', Locked = true;
        ProductTxt: label 'Vare', Locked = true;
        ServiceTxt: label 'Service', Locked = true;

    procedure GetAuditFileNamespace(var NamespacePrefix: Text; var NamespaceUri: Text)
    begin
        NamespacePrefix := NamespacePrefixTxt;
        NamespaceUri := NamespaceUriTxt;
    end;

    procedure GetHeaderModificationAllowed(var AddPrevSiblingsAllowed: Boolean; var AddNextSiblingsAllowed: Boolean; var AddChildNodesAllowed: Boolean; var SetNameValueAllowed: Boolean; var RemoveNodeAllowed: Boolean)
    begin
        AddPrevSiblingsAllowed := false;
        AddNextSiblingsAllowed := true;
        AddChildNodesAllowed := false;
        SetNameValueAllowed := true;
        RemoveNodeAllowed := false;
    end;

    procedure GetNodeModificationAllowed(AuditFileExportDataType: Enum "Audit File Export Data Type"; var AddPrevSiblingsAllowed: Boolean; var AddNextSiblingsAllowed: Boolean; var AddChildNodesAllowed: Boolean; var SetNameValueAllowed: Boolean; var RemoveNodeAllowed: Boolean)
    begin
        AddPrevSiblingsAllowed := false;
        AddNextSiblingsAllowed := false;
        AddChildNodesAllowed := false;
        SetNameValueAllowed := false;
        RemoveNodeAllowed := false;

        case AuditFileExportDataType of
            Enum::"Audit File Export Data Type"::GeneralLedgerAccounts:
                SetNameValueAllowed := true;
            Enum::"Audit File Export Data Type"::Customers:
                begin
                    AddNextSiblingsAllowed := true;
                    SetNameValueAllowed := true;
                end;
            Enum::"Audit File Export Data Type"::Suppliers:
                begin
                    AddNextSiblingsAllowed := true;
                    SetNameValueAllowed := true;
                end;
            Enum::"Audit File Export Data Type"::TaxTable:
                SetNameValueAllowed := true;
            Enum::"Audit File Export Data Type"::Products:
                SetNameValueAllowed := true;
            Enum::"Audit File Export Data Type"::Assets:
                AddNextSiblingsAllowed := true;
            Enum::"Audit File Export Data Type"::GeneralLedgerEntries:
                AddNextSiblingsAllowed := true;
            Enum::"Audit File Export Data Type"::SalesInvoices:
                begin
                    AddNextSiblingsAllowed := true;
                    SetNameValueAllowed := true;
                end;
            Enum::"Audit File Export Data Type"::PurchaseInvoices:
                begin
                    AddNextSiblingsAllowed := true;
                    SetNameValueAllowed := true;
                end;
            Enum::"Audit File Export Data Type"::Payments:
                AddNextSiblingsAllowed := true;
            Enum::"Audit File Export Data Type"::MovementOfGoods:
                AddNextSiblingsAllowed := true;
            Enum::"Audit File Export Data Type"::AssetTransactions:
                AddNextSiblingsAllowed := true;
        end;
    end;

    procedure GetPrevSiblingsToAdd(RecRef: RecordRef; XPath: Text; NamespaceUri: Text; var Params: Dictionary of [Text, Text]) SiblingXmlNodes: XmlNodeList
    begin
    end;

    procedure GetNextSiblingsToAdd(RecRef: RecordRef; XPath: Text; NamespaceUri: Text; var Params: Dictionary of [Text, Text]) SiblingXmlNodes: XmlNodeList
    begin
        if XPath.EndsWith('Address/StreetName') then begin
            XmlHelper.InitNamespace(NamespaceUri);
            SiblingXmlNodes := CreateAddressNumberNode();
            exit;
        end;

        if XPath.EndsWith('/TaxInformation/TaxCode') or XPath.EndsWith('/TaxInformationTotals/TaxCode') then begin
            XmlHelper.InitNamespace(NamespaceUri);
            SiblingXmlNodes := CreateStandardTaxAndCountryCodeNodes(Params);
            exit;
        end;

        case XPath of
            '/AuditFile/MasterFiles/Customers/Customer/RegistrationNumber',
            '/AuditFile/MasterFiles/Suppliers/Supplier/RegistrationNumber':
                begin
                    XmlHelper.InitNamespace(NamespaceUri);
                    SiblingXmlNodes := CreateEntityTypeSENRNode(RecRef);
                    exit;
                end;
            '/AuditFile/MasterFiles/Customers/Customer/Contact',
            '/AuditFile/MasterFiles/Suppliers/Supplier/Contact':
                begin
                    XmlHelper.InitNamespace(NamespaceUri);
                    SiblingXmlNodes := CreateTaxRegistrationNode(RecRef);
                    exit;
                end;
        end;

        if XPath.EndsWith('/BankAccount/IBANNumber') or XPath.EndsWith('/BankAccount/SortCode') then begin
            XmlHelper.InitNamespace(NamespaceUri);
            SiblingXmlNodes := CreateBicCurrencyCodeAccountIdNode(RecRef);
            exit;
        end;
    end;

    procedure GetChildNodesToAdd(RecRef: RecordRef; XPath: Text; NamespaceUri: Text; var Params: Dictionary of [Text, Text]) ChildXmlNodes: XmlNodeList
    begin
    end;

    procedure SetCurrXmlElementNameValue(var Name: Text; var Content: Text; var EmptyContentAllowed: Boolean; RecRef: RecordRef; XPath: Text; var Params: Dictionary of [Text, Text])
    begin
        case XPath of
            '/AuditFile/MasterFiles/Customers/Customer/RegistrationNumber',
            '/AuditFile/MasterFiles/Suppliers/Supplier/RegistrationNumber':
                begin
                    Content := GetCustVendorRegistrationNumber(RecRef);
                    exit;
                end;
            '/AuditFile/MasterFiles/GeneralLedgerAccounts/Account/AccountType':
                begin
                    Content := GetGLAccountType(RecRef);    // Asset, Liability, Sale, Expense, Other
                    exit;
                end;
            '/AuditFile/MasterFiles/TaxTable/TaxTableEntry/Description':
                begin
                    Content := TaxTableEntryDescrTxt;       // Moms
                    exit;
                end;
            '/AuditFile/Header/TaxAccountingBasis':
                begin
                    Content := TaxAccBasisTxt;              // Regnskab
                    exit;
                end;
        end;

        if XPath.EndsWith('/GoodsServicesID') then
            Content := GetGoodsServicesID(Params);          // Vare, Service

        if XPath.EndsWith('/TaxRegistration/TaxAuthority') then
            Content := TaxAuthValueTxt;                     // Skattestyrelsen
    end;

    procedure RemoveCurrentXmlElement(RecRef: RecordRef; XPath: Text; var Params: Dictionary of [Text, Text]) RemoveElement: Boolean
    begin
    end;

    local procedure CreateEntityTypeSENRNode(RecRef: RecordRef) EntityTypeSENRNodes: XmlNodeList
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        PartnerType: Enum "Partner Type";
        SENR: Text;
        EntityType: Text;
    begin
        case RecRef.Number of
            Database::Customer:
                begin
                    RecRef.SetTable(Customer);
                    PartnerType := Customer."Partner Type";
                    SENR := Customer."Registration Number";
                end;
            Database::Vendor:
                begin
                    RecRef.SetTable(Vendor);
                    PartnerType := Vendor."Partner Type";
                    SENR := Vendor."Registration Number";
                end;
            else
                Error('RecordRef must refer to the Customer or Vendor record.');
        end;

        case PartnerType of
            Enum::"Partner Type"::Company:
                EntityType := 'Company';
            Enum::"Partner Type"::Person:
                EntityType := 'Private';
            Enum::"Partner Type"::Government:
                EntityType := 'Government';
            else
                EntityType := 'Other';
        end;

        XmlHelper.Initialize();
        XmlHelper.AppendXmlNode('EntityType', EntityType);
        XmlHelper.AppendXmlNode('SENR', SENR);

        EntityTypeSENRNodes := XmlHelper.GetXmlNodes();
    end;

    local procedure CreateAddressNumberNode() AddressNumberNodes: XmlNodeList
    begin
        XmlHelper.Initialize();
        XmlHelper.AppendXMLNodeEmptyContentAllowed('Number', '');

        AddressNumberNodes := XmlHelper.GetXmlNodes();
    end;

    local procedure CreateTaxRegistrationNode(RecRef: RecordRef) TaxRegistrationNodes: XmlNodeList
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        VATRegistrationNo: Text;
    begin
        case RecRef.Number of
            Database::Customer:
                begin
                    RecRef.SetTable(Customer);
                    VATRegistrationNo := Customer."VAT Registration No.";
                end;
            Database::Vendor:
                begin
                    RecRef.SetTable(Vendor);
                    VATRegistrationNo := Vendor."VAT Registration No.";
                end;
            else
                Error('RecordRef must refer to the Customer or Vendor record.');
        end;

        if VATRegistrationNo = '' then
            exit;

        XmlHelper.Initialize();
        XmlHelper.AddNewXmlNode('TaxRegistration', '');
        XmlHelper.AppendXmlNode('TaxRegistrationNumber', VATRegistrationNo);
        XmlHelper.AppendXmlNode('TaxAuthority', TaxAuthValueTxt);
        XmlHelper.FinalizeXmlNode();

        TaxRegistrationNodes := XmlHelper.GetXmlNodes();
    end;

    local procedure CreateStandardTaxAndCountryCodeNodes(var Params: Dictionary of [Text, Text]) TaxInformationNodes: XmlNodeList
    var
        CompanyInformation: Record "Company Information";
        StandardTaxCode: Text;
    begin
        // Standard Tax Code is added for DK in Tax Informaton node
        if not Params.ContainsKey('StandardTaxCode') then
            Error('StandardTaxCode must be specified in Params.');
        StandardTaxCode := Params.Get('StandardTaxCode');

        CompanyInformation.SetLoadFields("Country/Region Code");
        CompanyInformation.Get();

        XmlHelper.Initialize();
        XmlHelper.AppendXmlNode('StandardTaxCode', StandardTaxCode);
        XmlHelper.AppendXmlNode('Country', SAFTDataMgt.GetISOCountryCode(CompanyInformation."Country/Region Code"));

        TaxInformationNodes := XmlHelper.GetXmlNodes();
    end;

    local procedure CreateBicCurrencyCodeAccountIdNode(RecRef: RecordRef) BankAccountNodes: XmlNodeList
    var
        CompanyInformation: Record "Company Information";
        CustomerBankAccount: Record "Customer Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
        BankAccount: Record "Bank Account";
        SWIFT: Text;
        CurrencyCode: Code[10];
        AccountNo: Code[20];
    begin
        case RecRef.Number of
            Database::"Company Information":
                begin
                    RecRef.SetTable(CompanyInformation);
                    SWIFT := CompanyInformation."SWIFT Code";
                end;
            Database::"Bank Account":
                begin
                    RecRef.SetTable(BankAccount);
                    SWIFT := BankAccount."SWIFT Code";
                    CurrencyCode := BankAccount."Currency Code";
                    AccountNo := GetGLAccFromBankAccPostingGroup(BankAccount."Bank Acc. Posting Group");
                end;
            Database::"Customer Bank Account":
                begin
                    RecRef.SetTable(CustomerBankAccount);
                    SWIFT := CustomerBankAccount."SWIFT Code";
                    CurrencyCode := CustomerBankAccount."Currency Code";
                end;
            Database::"Vendor Bank Account":
                begin
                    RecRef.SetTable(VendorBankAccount);
                    SWIFT := VendorBankAccount."SWIFT Code";
                    CurrencyCode := VendorBankAccount."Currency Code";
                end;
            else
                Error('RecordRef must refer to the Company Information, Bank Account, Customer Bank Account or Vendor Bank Account record.');
        end;

        XmlHelper.Initialize();
        XmlHelper.AppendXmlNode('BIC', SWIFT);
        XmlHelper.AppendXmlNode('CurrencyCode', SAFTDataMgt.GetISOCurrencyCode(CurrencyCode));
        XmlHelper.AppendXmlNode(GLAccIDTagNameTxt, AccountNo);

        BankAccountNodes := XmlHelper.GetXmlNodes();
    end;

    local procedure GetGLAccFromBankAccPostingGroup(BankAccPostGroupCode: Code[20]): Code[20]
    var
        BankAccPostingGroup: Record "Bank Account Posting Group";
    begin
        if BankAccPostGroupCode = '' then
            exit('');
        if not BankAccPostingGroup.Get(BankAccPostGroupCode) then
            exit('');
        exit(BankAccPostingGroup."G/L Account No.");
    end;

    local procedure GetGLAccountType(RecRef: RecordRef) GLAccountType: Text
    var
        GLAccount: Record "G/L Account";
    begin
        if RecRef.Number <> Database::"G/L Account" then
            Error('RecordRef must refer to the G/L Account record.');
        RecRef.SetTable(GLAccount);

        case GLAccount."Account Category" of
            "G/L Account Category"::Assets:
                GLAccountType := GLAccTypeAssetTxt;       // Asset
            "G/L Account Category"::Liabilities:
                GLAccountType := GLAccTypeLiabilityTxt;   // Liability
            "G/L Account Category"::Income:
                GLAccountType := GLAccTypeSaleTxt;        // Sale
            "G/L Account Category"::Expense:
                GLAccountType := GLAccTypeExpenseTxt;     // Expense
            else
                GLAccountType := GLAccTypeOtherTxt;       // Other
        end;
        exit(SAFTDataMgt.GetSAFTShortText(GLAccountType));
    end;

    local procedure GetCustVendorRegistrationNumber(RecRef: RecordRef) RegistrationNumber: Text
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        case RecRef.Number of
            Database::Customer:
                begin
                    RecRef.SetTable(Customer);
                    RegistrationNumber := Customer."Registration Number";
                end;
            Database::Vendor:
                begin
                    RecRef.SetTable(Vendor);
                    RegistrationNumber := Vendor."Registration Number";
                end;
            else
                Error('RecordRef must refer to the Customer or Vendor record.');
        end;

        RegistrationNumber := SAFTDataMgt.GetSAFTMiddle1Text(RegistrationNumber);
    end;

    local procedure GetGoodsServicesID(var Params: Dictionary of [Text, Text]) GoodsServicesID: Text
    var
        IsService: Boolean;
    begin
        if not Params.ContainsKey('IsService') then
            Error('IsService must be specified in Params.');
        Evaluate(IsService, Params.Get('IsService'));

        if IsService then
            GoodsServicesID := ServiceTxt     // Service
        else
            GoodsServicesID := ProductTxt;    // Vare

        GoodsServicesID := SAFTDataMgt.GetSAFTCodeText(GoodsServicesID);
    end;
}
