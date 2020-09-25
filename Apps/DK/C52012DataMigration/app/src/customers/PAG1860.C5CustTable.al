// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

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
                field(Account; Account) { ApplicationArea = All; }
                field(Name; Name) { ApplicationArea = All; }
                field(Address1; Address1) { ApplicationArea = All; }
                field(Address2; Address2) { ApplicationArea = All; }
                field(ZipCity; ZipCity) { ApplicationArea = All; }
                field(Country; Country) { ApplicationArea = All; }
                field(Attention; Attention) { ApplicationArea = All; }
                field(Phone; Phone) { ApplicationArea = All; }
                field(Fax; Fax) { ApplicationArea = All; }
                field(InvoiceAccount; InvoiceAccount) { ApplicationArea = All; }
                field(Group; Group) { ApplicationArea = All; }
                field(FixedDiscPct; FixedDiscPct) { ApplicationArea = All; }
                field(Approved; Approved) { ApplicationArea = All; }
                field(PriceGroup; PriceGroup) { ApplicationArea = All; }
                field(DiscGroup; DiscGroup) { ApplicationArea = All; }
                field(CashDisc; CashDisc) { ApplicationArea = All; }
                field(ImageFile; ImageFile) { ApplicationArea = All; }
                field(Currency; Currency) { ApplicationArea = All; }
                field(Language_; Language_) { ApplicationArea = All; }
                field(Payment; Payment) { ApplicationArea = All; }
                field(Delivery; Delivery) { ApplicationArea = All; }
                field(Blocked; Blocked) { ApplicationArea = All; }
                field(SalesRep; SalesRep) { ApplicationArea = All; }
                field(Vat; Vat) { ApplicationArea = All; }
                field(DEL_StatType; DEL_StatType) { ApplicationArea = All; }
                field(GiroNumber; GiroNumber) { ApplicationArea = All; }
                field(VatNumber; VatNumber) { ApplicationArea = All; }
                field(Interest; Interest) { ApplicationArea = All; }
                field(Department; Department) { ApplicationArea = All; }
                field(ReminderCode; ReminderCode) { ApplicationArea = All; }
                field(OnetimeCustomer; OnetimeCustomer) { ApplicationArea = All; }
                field(Inventory; Inventory) { ApplicationArea = All; }
                field(EDIAddress; EDIAddress) { ApplicationArea = All; }
                field(Balance; Balance) { ApplicationArea = All; }
                field(Balance30; Balance30) { ApplicationArea = All; }
                field(Balance60; Balance60) { ApplicationArea = All; }
                field(Balance90; Balance90) { ApplicationArea = All; }
                field(Balance120; Balance120) { ApplicationArea = All; }
                field(Balance120Plus; Balance120Plus) { ApplicationArea = All; }
                field(AmountDue; AmountDue) { ApplicationArea = All; }
                field(CalculationDate; CalculationDate) { ApplicationArea = All; }
                field(BalanceMax; BalanceMax) { ApplicationArea = All; }
                field(BalanceMST; BalanceMST) { ApplicationArea = All; }
                field(SearchName; SearchName) { ApplicationArea = All; }
                field(DEL_Transport; DEL_Transport) { ApplicationArea = All; }
                field(CashPayment; CashPayment) { ApplicationArea = All; }
                field(PaymentMode; PaymentMode) { ApplicationArea = All; }
                field(SalesGroup; SalesGroup) { ApplicationArea = All; }
                field(ProjGroup; ProjGroup) { ApplicationArea = All; }
                field(TradeCode; TradeCode) { ApplicationArea = All; }
                field(TransportCode; TransportCode) { ApplicationArea = All; }
                field(Email; Email) { ApplicationArea = All; }
                field(URL; URL) { ApplicationArea = All; }
                field(CellPhone; CellPhone) { ApplicationArea = All; }
                field(KrakNumber; KrakNumber) { ApplicationArea = All; }
                field(Centre; Centre) { ApplicationArea = All; }
                field(Purpose; Purpose) { ApplicationArea = All; }
                field(EanNumber; EanNumber) { ApplicationArea = All; }
                field(DimAccountCode; DimAccountCode) { ApplicationArea = All; }
                field(XMLInvoice; XMLInvoice) { ApplicationArea = All; }
                field(LastInvoiceDate; LastInvoiceDate) { ApplicationArea = All; }
                field(LastPaymentDate; LastPaymentDate) { ApplicationArea = All; }
                field(LastReminderDate; LastReminderDate) { ApplicationArea = All; }
                field(LastInterestDate; LastInterestDate) { ApplicationArea = All; }
                field(LastInvoiceNumber; LastInvoiceNumber) { ApplicationArea = All; }
                field(XMLImport; XMLImport) { ApplicationArea = All; }
                field(VatGroup; VatGroup) { ApplicationArea = All; }
                field(StdAccount; StdAccount) { ApplicationArea = All; }
                field(VatNumberType; VatNumberType) { ApplicationArea = All; }
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
                    RunPageLink = Employee = field (SalesRep);
                    RunPageMode = Edit;
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
                    RunPageLink = Payment = field (Payment);
                    RunPageMode = Edit;
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
                    RunPageLink = Delivery = field (Delivery);
                    RunPageMode = Edit;
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
                    RunPageLink = DiscGroup = field (DiscGroup);
                    RunPageMode = Edit;
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
                    RunPageLink = Group = field (PriceGroup);
                    RunPageMode = Edit;
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
                    RunPageLink = Code = field (PaymentMode);
                    RunPageMode = Edit;
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
                    RunPageLink = Group = field (Group);
                    RunPageMode = Edit;
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
                    RunPageLink = Account = field (Account), Open = const (Yes), BudgetCode = const (Actual);
                    RunPageMode = Edit;
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
                    RunPageLink = Account = field (Account);
                    RunPageMode = Edit;
                }
            }
        }
    }
}