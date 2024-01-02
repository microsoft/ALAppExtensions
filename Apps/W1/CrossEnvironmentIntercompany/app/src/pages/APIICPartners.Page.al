namespace Microsoft.Intercompany.CrossEnvironment;

using Microsoft.Intercompany.Partner;

page 30413 "API - IC Partners"
{
    PageType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'intercompany';
    APIVersion = 'v1.0';
    EntityName = 'intercompanyPartner';
    EntitySetName = 'intercompanyPartners';
    EntityCaption = 'Intercompany Partner';
    EntitySetCaption = 'Intercompany Partners';
    SourceTable = "IC Partner";
    DelayedInsert = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ODataKeyFields = SystemId;
    Extensible = false;
    Editable = false;
    DataAccessIntent = ReadOnly;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                }
                field(partnerCode; Rec.Code)
                {
                    Caption = 'Intercompany Partner Code';
                }
                field(name; Rec.Name)
                {
                    Caption = 'Name';
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                }
                field(inboxType; Rec."Inbox Type")
                {
                    Caption = 'Inbox Type';
                }
                field(inboxTypeOrdinal; InboxTypeOrdinal)
                {
                    Caption = 'Inbox Type Ordinal';
                }
                field(inboxDetails; Rec."Inbox Details")
                {
                    Caption = 'Inbox Details';
                }
                field(receivablesAccount; Rec."Receivables Account")
                {
                    Caption = 'Receivables Account';
                }
                field(payablesAccount; Rec."Payables Account")
                {
                    Caption = 'Payables Account';
                }
                field(countryRegionCode; Rec."Country/Region Code")
                {
                    Caption = 'Country/Region Code';
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked';
                }
                field(customerNumber; Rec."Customer No.")
                {
                    Caption = 'Customer Number';
                }
                field(vendorNumber; Rec."Vendor No.")
                {
                    Caption = 'Vendor Number';
                }
                field(outboundSalesItemNumberType; Rec."Outbound Sales Item No. Type")
                {
                    Caption = 'Outbound Sales Item Number Type';
                }
                field(outboundSalesItemNumberTypeOrdinal; OutboundSalesItemNumberTypeOrdinal)
                {
                    Caption = 'Outbound Sales Item Number Type Ordinal';
                }
                field(outboundPurchaseItemNumberType; Rec."Outbound Purch. Item No. Type")
                {
                    Caption = 'Outbound Purchase Item Number Type';
                }
                field(outboundPurchaseItemNumberTypeOrdinal; OutboundPurchaseItemNumberTypeOrdinal)
                {
                    Caption = 'Outbound Purchase Item Number Type Ordinal';
                }
                field(costDistributionInLCY; Rec."Cost Distribution in LCY")
                {
                    Caption = 'Cost Distribution in LCY';
                }
                field(autoAcceptTransactions; Rec."Auto. Accept Transactions")
                {
                    Caption = 'Auto Accept Transactions';
                }
                field(dataExchangeType; Rec."Data Exchange Type")
                {
                    Caption = 'Data Exchange Type';
                }
                field(dataExchangeTypeOrdinal; DataExchangeTypeOrdinal)
                {
                    Caption = 'Data Exchange Type Ordinal';
                }

            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        InboxTypeOrdinal := Rec."Inbox Type".AsInteger();
        OutboundSalesItemNumberTypeOrdinal := Rec."Outbound Sales Item No. Type".AsInteger();
        OutboundPurchaseItemNumberTypeOrdinal := Rec."Outbound Purch. Item No. Type".AsInteger();
        DataExchangeTypeOrdinal := Rec."Data Exchange Type".AsInteger();
    end;

    var
        InboxTypeOrdinal, OutboundSalesItemNumberTypeOrdinal, OutboundPurchaseItemNumberTypeOrdinal, DataExchangeTypeOrdinal : Integer;
}