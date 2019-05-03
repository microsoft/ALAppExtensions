// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

xmlport 1881 "C5 VendTable"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = XML;


    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            XmlName = 'VendTableDocument';
            tableelement(C5VendTable; "C5 VendTable")
            {
                fieldelement(DEL_UserLock; C5VendTable.DEL_UserLock) { }
                fieldelement(Account; C5VendTable.Account) { }
                fieldelement(Name; C5VendTable.Name) { }
                fieldelement(Address1; C5VendTable.Address1) { }
                fieldelement(Address2; C5VendTable.Address2) { }
                fieldelement(ZipCity; C5VendTable.ZipCity) { }
                fieldelement(Country; C5VendTable.Country) { }
                fieldelement(Attention; C5VendTable.Attention) { }
                fieldelement(Phone; C5VendTable.Phone) { }
                fieldelement(Fax; C5VendTable.Fax) { }
                fieldelement(InvoiceAccount; C5VendTable.InvoiceAccount) { }
                fieldelement(Group; C5VendTable.Group) { }
                fieldelement(FixedDiscPct; C5VendTable.FixedDiscPct) { }
                fieldelement(DiscGroup; C5VendTable.DiscGroup) { }
                fieldelement(CashDisc; C5VendTable.CashDisc) { }
                fieldelement(Approved; C5VendTable.Approved) { }
                fieldelement(DEL_ExclDuty; C5VendTable.DEL_ExclDuty) { }
                fieldelement(InclVat; C5VendTable.InclVat) { }
                fieldelement(Currency; C5VendTable.Currency) { }
                fieldelement(Language_; C5VendTable.Language_) { }
                fieldelement(Payment; C5VendTable.Payment) { }
                fieldelement(Delivery; C5VendTable.Delivery) { }
                fieldelement(Interest; C5VendTable.Interest) { }
                fieldelement(Blocked; C5VendTable.Blocked) { }
                fieldelement(Purchaser; C5VendTable.Purchaser) { }
                fieldelement(Vat; C5VendTable.Vat) { }
                fieldelement(DEL_StatType; C5VendTable.DEL_StatType) { }
                fieldelement(ESRnumber; C5VendTable.ESRnumber) { }
                fieldelement(GiroNumber; C5VendTable.GiroNumber) { }
                fieldelement(OurAccount; C5VendTable.OurAccount) { }
                fieldelement(BankAccount; C5VendTable.BankAccount) { }
                fieldelement(VatNumber; C5VendTable.VatNumber) { }
                fieldelement(Department; C5VendTable.Department) { }
                fieldelement(OnetimeSupplier; C5VendTable.OnetimeSupplier) { }
                fieldelement(ImageFile; C5VendTable.ImageFile) { }
                fieldelement(Inventory; C5VendTable.Inventory) { }
                fieldelement(EDIAddress; C5VendTable.EDIAddress) { }
                fieldelement(Balance; C5VendTable.Balance) { }
                fieldelement(Balance30; C5VendTable.Balance30) { }
                fieldelement(Balance60; C5VendTable.Balance60) { }
                fieldelement(Balance90; C5VendTable.Balance90) { }
                fieldelement(Balance120; C5VendTable.Balance120) { }
                fieldelement(Balance120Plus; C5VendTable.Balance120Plus) { }
                fieldelement(AmountDue; C5VendTable.AmountDue) { }
                textelement(CalculationDateText)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        C5HelperFunctions.TryConvertFromStringDate(CalculationDateText, CopyStr(DateFormatStringTxt, 1, 20), C5VendTable.CalculationDate);
                    end;
                }

                fieldelement(BalanceMax; C5VendTable.BalanceMax) { }
                fieldelement(BalanceMST; C5VendTable.BalanceMST) { }
                fieldelement(SearchName; C5VendTable.SearchName) { }
                fieldelement(DEL_Transport; C5VendTable.DEL_Transport) { }
                fieldelement(CashPayment; C5VendTable.CashPayment) { }
                fieldelement(PaymentMode; C5VendTable.PaymentMode) { }
                fieldelement(PaymSpec; C5VendTable.PaymSpec) { }
                fieldelement(Telex; C5VendTable.Telex) { }
                fieldelement(PaymId; C5VendTable.PaymId) { }
                fieldelement(PurchGroup; C5VendTable.PurchGroup) { }
                fieldelement(TradeCode; C5VendTable.TradeCode) { }
                fieldelement(TransportCode; C5VendTable.TransportCode) { }
                fieldelement(Email; C5VendTable.Email) { }
                fieldelement(URL; C5VendTable.URL) { }
                fieldelement(CellPhone; C5VendTable.CellPhone) { }
                fieldelement(KrakNumber; C5VendTable.KrakNumber) { }
                fieldelement(Centre; C5VendTable.Centre) { }
                fieldelement(Purpose; C5VendTable.Purpose) { }
                textelement(LastInvoiceDateText)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        C5HelperFunctions.TryConvertFromStringDate(LastInvoiceDateText, CopyStr(DateFormatStringTxt, 1, 20), C5VendTable.LastInvoiceDate);
                    end;
                }

                textelement(LastPaymentDateText)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        C5HelperFunctions.TryConvertFromStringDate(LastPaymentDateText, CopyStr(DateFormatStringTxt, 1, 20), C5VendTable.LastPaymentDate);
                    end;
                }

                fieldelement(LastInvoiceNumber; C5VendTable.LastInvoiceNumber) { }
                fieldelement(XMLImport; C5VendTable.XMLImport) { }
                fieldelement(EanNumber; C5VendTable.EanNumber) { }
                fieldelement(VatGroup; C5VendTable.VatGroup) { }
                fieldelement(CardType; C5VendTable.CardType) { }
                fieldelement(StdAccount; C5VendTable.StdAccount) { }
                fieldelement(VatNumberType; C5VendTable.VatNumberType) { }

                trigger OnBeforeInsertRecord();
                begin
                    C5VendTable.RecId := Counter;
                    Counter += 1;
                end;
            }
        }
    }

    var
        C5HelperFunctions: Codeunit "C5 Helper Functions";
        DateFormatStringTxt: label 'yyyy/MM/dd', locked = true;
        Counter: Integer;
}

