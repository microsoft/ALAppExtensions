// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

page 1899 "C5 CustTable List"
{
    PageType = List;
    SourceTable = "C5 CustTable";
    CardPageId = "C5 CustTable";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    Caption = 'Customers';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Error Message"; MigrationErrorText)
                {
                    ApplicationArea = All;

                    Enabled = false;
                }
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

    var
        C5MigrDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
        MigrationErrorText: Text[250];

    trigger OnAfterGetRecord();
    var
        DataMigrationError: Record "Data Migration Error";
    begin
        DataMigrationError.GetErrorMessage(C5MigrDashboardMgt.GetC5MigrationTypeTxt(), RecordId(), MigrationErrorText);
    end;

}