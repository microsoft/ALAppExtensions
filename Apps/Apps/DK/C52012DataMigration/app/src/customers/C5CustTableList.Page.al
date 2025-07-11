// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

using System.Integration;

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
#pragma warning disable AA0218
                field("Error Message"; MigrationErrorText)
                {
                    ApplicationArea = All;
                    Caption = 'Error Message';
                    Enabled = false;
                }
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

    var
        C5MigrDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
        MigrationErrorText: Text[250];

    trigger OnAfterGetRecord();
    var
        DataMigrationError: Record "Data Migration Error";
    begin
        DataMigrationError.GetErrorMessage(C5MigrDashboardMgt.GetC5MigrationTypeTxt(), Rec.RecordId(), MigrationErrorText);
    end;

}
