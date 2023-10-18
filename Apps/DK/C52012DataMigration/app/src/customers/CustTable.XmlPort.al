// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

xmlport 1864 "C5 CustTable"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = XML;


    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            XmlName = 'CustTableDocument';
            tableelement(C5CustTable; "C5 CustTable")
            {
                fieldelement(DEL_UserLock; C5CustTable.DEL_UserLock) { }
                fieldelement(Account; C5CustTable.Account) { }
                fieldelement(Name; C5CustTable.Name) { }
                fieldelement(Address1; C5CustTable.Address1) { }
                fieldelement(Address2; C5CustTable.Address2) { }
                fieldelement(ZipCity; C5CustTable.ZipCity) { }
                fieldelement(Country; C5CustTable.Country) { }
                fieldelement(Attention; C5CustTable.Attention) { }
                fieldelement(Phone; C5CustTable.Phone) { }
                fieldelement(Fax; C5CustTable.Fax) { }
                fieldelement(InvoiceAccount; C5CustTable.InvoiceAccount) { }
                fieldelement(Group; C5CustTable.Group) { }
                fieldelement(FixedDiscPct; C5CustTable.FixedDiscPct) { }
                fieldelement(Approved; C5CustTable.Approved) { }
                fieldelement(PriceGroup; C5CustTable.PriceGroup) { }
                fieldelement(DiscGroup; C5CustTable.DiscGroup) { }
                fieldelement(CashDisc; C5CustTable.CashDisc) { }
                fieldelement(ImageFile; C5CustTable.ImageFile) { }
                fieldelement(Currency; C5CustTable.Currency) { }
                fieldelement(Language_; C5CustTable.Language_) { }
                fieldelement(Payment; C5CustTable.Payment) { }
                fieldelement(Delivery; C5CustTable.Delivery) { }
                fieldelement(Blocked; C5CustTable.Blocked) { }
                fieldelement(SalesRep; C5CustTable.SalesRep) { }
                fieldelement(Vat; C5CustTable.Vat) { }
                fieldelement(DEL_StatType; C5CustTable.DEL_StatType) { }
                fieldelement(GiroNumber; C5CustTable.GiroNumber) { }
                fieldelement(VatNumber; C5CustTable.VatNumber) { }
                fieldelement(Interest; C5CustTable.Interest) { }
                fieldelement(Department; C5CustTable.Department) { }
                fieldelement(ReminderCode; C5CustTable.ReminderCode) { }
                fieldelement(OnetimeCustomer; C5CustTable.OnetimeCustomer) { }
                fieldelement(Inventory; C5CustTable.Inventory) { }
                fieldelement(EDIAddress; C5CustTable.EDIAddress) { }
                fieldelement(Balance; C5CustTable.Balance) { }
                fieldelement(Balance30; C5CustTable.Balance30) { }
                fieldelement(Balance60; C5CustTable.Balance60) { }
                fieldelement(Balance90; C5CustTable.Balance90) { }
                fieldelement(Balance120; C5CustTable.Balance120) { }
                fieldelement(Balance120Plus; C5CustTable.Balance120Plus) { }
                fieldelement(AmountDue; C5CustTable.AmountDue) { }
                textelement(CalculationDateText)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        C5HelperFunctions.TryConvertFromStringDate(CalculationDateText, CopyStr(DateFormatStringTxt, 1, 20), C5CustTable.CalculationDate);
                    end;
                }

                fieldelement(BalanceMax; C5CustTable.BalanceMax) { }
                fieldelement(BalanceMST; C5CustTable.BalanceMST) { }
                fieldelement(SearchName; C5CustTable.SearchName) { }
                fieldelement(DEL_Transport; C5CustTable.DEL_Transport) { }
                fieldelement(CashPayment; C5CustTable.CashPayment) { }
                fieldelement(PaymentMode; C5CustTable.PaymentMode) { }
                fieldelement(SalesGroup; C5CustTable.SalesGroup) { }
                fieldelement(ProjGroup; C5CustTable.ProjGroup) { }
                fieldelement(TradeCode; C5CustTable.TradeCode) { }
                fieldelement(TransportCode; C5CustTable.TransportCode) { }
                fieldelement(Email; C5CustTable.Email) { }
                fieldelement(URL; C5CustTable.URL) { }
                fieldelement(CellPhone; C5CustTable.CellPhone) { }
                fieldelement(KrakNumber; C5CustTable.KrakNumber) { }
                fieldelement(Centre; C5CustTable.Centre) { }
                fieldelement(Purpose; C5CustTable.Purpose) { }
                fieldelement(EanNumber; C5CustTable.EanNumber) { }
                fieldelement(DimAccountCode; C5CustTable.DimAccountCode) { }
                fieldelement(XMLInvoice; C5CustTable.XMLInvoice) { }
                textelement(LastInvoiceDateText)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        C5HelperFunctions.TryConvertFromStringDate(LastInvoiceDateText, CopyStr(DateFormatStringTxt, 1, 20), C5CustTable.LastInvoiceDate);
                    end;
                }

                textelement(LastPaymentDateText)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        C5HelperFunctions.TryConvertFromStringDate(LastPaymentDateText, CopyStr(DateFormatStringTxt, 1, 20), C5CustTable.LastPaymentDate);
                    end;
                }

                textelement(LastReminderDateText)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        C5HelperFunctions.TryConvertFromStringDate(LastReminderDateText, CopyStr(DateFormatStringTxt, 1, 20), C5CustTable.LastReminderDate);
                    end;
                }

                textelement(LastInterestDateText)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        C5HelperFunctions.TryConvertFromStringDate(LastInterestDateText, CopyStr(DateFormatStringTxt, 1, 20), C5CustTable.LastInterestDate);
                    end;
                }

                fieldelement(LastInvoiceNumber; C5CustTable.LastInvoiceNumber) { }
                fieldelement(XMLImport; C5CustTable.XMLImport) { }
                fieldelement(VatGroup; C5CustTable.VatGroup) { }
                fieldelement(StdAccount; C5CustTable.StdAccount) { }
                fieldelement(VatNumberType; C5CustTable.VatNumberType) { }

                trigger OnBeforeInsertRecord();
                begin
                    C5CustTable.RecId := Counter;
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

