// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

page 1860 "C5 CustTable"
{
    PageType = Card;
    SourceTable = "C5 CustTable";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'C5 Customer Table';
    PromotedActionCategories = 'Related Entities';

    layout
    {
        area(content)
        {
            group(General)
            {
#pragma warning disable AA0218
                field(Account; Rec.Account) { ApplicationArea = All; }
                field(Name; Rec.Name) { ApplicationArea = All; }
                field(Address1; Rec.Address1) { ApplicationArea = All; }
                field(Address2; Rec.Address2) { ApplicationArea = All; }
                field(ZipCity; Rec.ZipCity) { ApplicationArea = All; }
                field(Country; Rec.Country) { ApplicationArea = All; }
                field(Attention; Rec.Attention) { ApplicationArea = All; }
                field(Phone; Rec.Phone) { ApplicationArea = All; }
                field(Fax; Rec.Fax) { ApplicationArea = All; }
                field(InvoiceAccount; Rec.InvoiceAccount) { ApplicationArea = All; }
                field(Group; Rec.Group) { ApplicationArea = All; }
                field(FixedDiscPct; Rec.FixedDiscPct) { ApplicationArea = All; }
                field(Approved; Rec.Approved) { ApplicationArea = All; }
                field(PriceGroup; Rec.PriceGroup) { ApplicationArea = All; }
                field(DiscGroup; Rec.DiscGroup) { ApplicationArea = All; }
                field(CashDisc; Rec.CashDisc) { ApplicationArea = All; }
                field(ImageFile; Rec.ImageFile) { ApplicationArea = All; }
                field(Currency; Rec.Currency) { ApplicationArea = All; }
                field(Language_; Rec.Language_) { ApplicationArea = All; }
                field(Payment; Rec.Payment) { ApplicationArea = All; }
                field(Delivery; Rec.Delivery) { ApplicationArea = All; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
                field(SalesRep; Rec.SalesRep) { ApplicationArea = All; }
                field(Vat; Rec.Vat) { ApplicationArea = All; }
                field(DEL_StatType; Rec.DEL_StatType) { ApplicationArea = All; }
                field(GiroNumber; Rec.GiroNumber) { ApplicationArea = All; }
                field(VatNumber; Rec.VatNumber) { ApplicationArea = All; }
                field(Interest; Rec.Interest) { ApplicationArea = All; }
                field(Department; Rec.Department) { ApplicationArea = All; }
                field(ReminderCode; Rec.ReminderCode) { ApplicationArea = All; }
                field(OnetimeCustomer; Rec.OnetimeCustomer) { ApplicationArea = All; }
                field(Inventory; Rec.Inventory) { ApplicationArea = All; }
                field(EDIAddress; Rec.EDIAddress) { ApplicationArea = All; }
                field(Balance; Rec.Balance) { ApplicationArea = All; }
                field(Balance30; Rec.Balance30) { ApplicationArea = All; }
                field(Balance60; Rec.Balance60) { ApplicationArea = All; }
                field(Balance90; Rec.Balance90) { ApplicationArea = All; }
                field(Balance120; Rec.Balance120) { ApplicationArea = All; }
                field(Balance120Plus; Rec.Balance120Plus) { ApplicationArea = All; }
                field(AmountDue; Rec.AmountDue) { ApplicationArea = All; }
                field(CalculationDate; Rec.CalculationDate) { ApplicationArea = All; }
                field(BalanceMax; Rec.BalanceMax) { ApplicationArea = All; }
                field(BalanceMST; Rec.BalanceMST) { ApplicationArea = All; }
                field(SearchName; Rec.SearchName) { ApplicationArea = All; }
                field(DEL_Transport; Rec.DEL_Transport) { ApplicationArea = All; }
                field(CashPayment; Rec.CashPayment) { ApplicationArea = All; }
                field(PaymentMode; Rec.PaymentMode) { ApplicationArea = All; }
                field(SalesGroup; Rec.SalesGroup) { ApplicationArea = All; }
                field(ProjGroup; Rec.ProjGroup) { ApplicationArea = All; }
                field(TradeCode; Rec.TradeCode) { ApplicationArea = All; }
                field(TransportCode; Rec.TransportCode) { ApplicationArea = All; }
                field(Email; Rec.Email) { ApplicationArea = All; }
                field(URL; Rec.URL) { ApplicationArea = All; }
                field(CellPhone; Rec.CellPhone) { ApplicationArea = All; }
                field(KrakNumber; Rec.KrakNumber) { ApplicationArea = All; }
                field(Centre; Rec.Centre) { ApplicationArea = All; }
                field(Purpose; Rec.Purpose) { ApplicationArea = All; }
                field(EanNumber; Rec.EanNumber) { ApplicationArea = All; }
                field(DimAccountCode; Rec.DimAccountCode) { ApplicationArea = All; }
                field(XMLInvoice; Rec.XMLInvoice) { ApplicationArea = All; }
                field(LastInvoiceDate; Rec.LastInvoiceDate) { ApplicationArea = All; }
                field(LastPaymentDate; Rec.LastPaymentDate) { ApplicationArea = All; }
                field(LastReminderDate; Rec.LastReminderDate) { ApplicationArea = All; }
                field(LastInterestDate; Rec.LastInterestDate) { ApplicationArea = All; }
                field(LastInvoiceNumber; Rec.LastInvoiceNumber) { ApplicationArea = All; }
                field(XMLImport; Rec.XMLImport) { ApplicationArea = All; }
                field(VatGroup; Rec.VatGroup) { ApplicationArea = All; }
                field(StdAccount; Rec.StdAccount) { ApplicationArea = All; }
                field(VatNumberType; Rec.VatNumberType) { ApplicationArea = All; }
#pragma warning restore
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            group(RelatedEntities)
            {
                Caption = 'Related entities';

                action(C5SalesRep)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Representative';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = SalesPerson;
                    RunObject = Page "C5 Employee";
                    RunPageLink = Employee = field(SalesRep);
                    RunPageMode = Edit;
                    ToolTip = 'Open the C5 Employee page.';
                }

                action(C5Payment)
                {
                    ApplicationArea = All;
                    Caption = 'Payment';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = Payment;
                    RunObject = Page "C5 Payment";
                    RunPageLink = Payment = field(Payment);
                    RunPageMode = Edit;
                    ToolTip = 'Open the C5 Payment page.';
                }

                action(C5Delivery)
                {
                    ApplicationArea = All;
                    Caption = 'Delivery';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = Delivery;
                    RunObject = Page "C5 Delivery";
                    RunPageLink = Delivery = field(Delivery);
                    RunPageMode = Edit;
                    ToolTip = 'Open the C5 Delivery page.';
                }

                action(C5CustDiscGroup)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Discount Group';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = Discount;
                    RunObject = Page "C5 CustDiscGroup";
                    RunPageLink = DiscGroup = field(DiscGroup);
                    RunPageMode = Edit;
                    ToolTip = 'Open the C5 Customer Discount Groups page.';
                }

                action(C5PriceGroup)
                {
                    ApplicationArea = All;
                    Caption = 'Price Group';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = Price;
                    RunObject = Page "C5 InvenPriceGroup";
                    RunPageLink = Group = field(PriceGroup);
                    RunPageMode = Edit;
                    ToolTip = 'Open the C5 Inventory Price Groups page.';
                }

                action(C5PaymentMode)
                {
                    ApplicationArea = All;
                    Caption = 'Payment Mode';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = SuggestPayment;
                    RunObject = Page "C5 ProcCode";
                    RunPageLink = Code = field(PaymentMode);
                    RunPageMode = Edit;
                    ToolTip = 'Open the C5 Process Codes page.';
                }

                action(C5CustGroup)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Group';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = Group;
                    RunObject = Page "C5 CustGroup";
                    RunPageLink = Group = field(Group);
                    RunPageMode = Edit;
                    ToolTip = 'Open the C5 Customer Groups page.';
                }

                action(C5CustTrans)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Entries';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = EntriesList;
                    RunObject = Page "C5 CustTrans";
                    RunPageLink = Account = field(Account), Open = const(Yes), BudgetCode = const(Actual);
                    RunPageMode = Edit;
                    ToolTip = 'Open the C5 Customer Entries.';
                }

                action(C5CustContact)
                {
                    ApplicationArea = All;
                    Caption = 'Contact Persons';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = ContactPerson;
                    RunObject = Page "C5 CustContact";
                    RunPageLink = Account = field(Account);
                    RunPageMode = Edit;
                    ToolTip = 'Open the C5 Customer Contact Persons.';
                }
            }
        }
    }
}
