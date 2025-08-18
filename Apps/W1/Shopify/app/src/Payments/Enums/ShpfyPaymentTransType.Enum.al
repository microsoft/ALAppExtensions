// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Payment Transcation Type (ID 30127).
/// </summary>
enum 30127 "Shpfy Payment Trans. Type"
{
    Caption = 'Shopify Payment Transcation Type';
    Extensible = false;

    value(0; Unknown)
    {
        Caption = ' ';
    }
    value(1; Charge)
    {
        Caption = 'Charge';
    }
    value(2; Refund)
    {
        Caption = 'Refund';
    }
    /// <summary>This value is no longer supported by Shopify but kept to support old transactions with this type.</summary>
    value(3; Dispute)
    {
        Caption = 'Dispute';
    }
    /// <summary>This value is no longer supported by Shopify but kept to support old transactions with this type.</summary>
    value(4; Reserve)
    {
        Caption = 'Reserve';
    }
    value(5; Adjustment)
    {
        Caption = 'Adjustment';
    }
    /// <summary>This value is no longer supported by Shopify but kept to support old transactions with this type.</summary>
    value(6; Credit)
    {
        Caption = 'Credit';
    }
    /// <summary>This value is no longer supported by Shopify but kept to support old transactions with this type.</summary>
    value(7; Debit)
    {
        Caption = 'Debit';
    }
    /// <summary>This value is no longer supported by Shopify but kept to support old transactions with this type.</summary>
    value(8; Payout)
    {
        Caption = 'Payout';
    }
    /// <summary>This value is no longer supported by Shopify but kept to support old transactions with this type.</summary>
    value(9; "Payout Failure")
    {
        Caption = 'Payout Failure';
    }
    /// <summary>This value is no longer supported by Shopify but kept to support old transactions with this type.</summary>
    value(10; "Payout Cancellation")
    {
        Caption = 'Payout Cancellation';
    }
    /// <summary>This value is no longer supported by Shopify but kept to support old transactions with this type.</summary>
    value(11; "Payment Refund")
    {
        Caption = 'Payment Refund';
    }
    value(12; "Shop Cash Credit")
    {
        Caption = 'Shop Cash Credit';
    }
    value(13; "Anomaly Debit")
    {
        Caption = 'Anomaly Debit';
    }
    value(14; "Anomaly Debit Reversal")
    {
        Caption = 'Anomaly Debit Reversal';
    }
    value(15; "Application Fee Refund")
    {
        Caption = 'Application Fee Refund';
    }
    value(16; "Balance Transfer Inbound")
    {
        Caption = 'Balance Transfer Inbound';
    }
    value(17; "Billing Debit")
    {
        Caption = 'Billing Debit';
    }
    value(18; "Billing Debit Reversal")
    {
        Caption = 'Billing Debit Reversal';
    }
    value(19; "Channel Credit")
    {
        Caption = 'Channel Credit';
    }
    value(20; "Channel Credit Reversal")
    {
        Caption = 'Channel Credit Reversal';
    }
    value(21; "Channel Promotion Credit")
    {
        Caption = 'Channel Promotion Credit';
    }
    value(22; "Channel Promotion Credit Reversal")
    {
        Caption = 'Channel Promotion Credit Reversal';
    }
    value(23; "Channel Transfer Credit")
    {
        Caption = 'Channel Transfer Credit';
    }
    value(24; "Channel Transfer Credit Reversal")
    {
        Caption = 'Channel Transfer Credit Reversal';
    }
    value(25; "Channel Transfer Debit")
    {
        Caption = 'Channel Transfer Debit';
    }
    value(26; "Channel Transfer Debit Reversal")
    {
        Caption = 'Channel Transfer Debit Reversal';
    }
    value(27; "Chargeback Fee")
    {
        Caption = 'Chargeback Fee';
    }
    value(28; "Chargeback Fee Refund")
    {
        Caption = 'Chargeback Fee Refund';
    }
    value(29; "Chargeback Hold")
    {
        Caption = 'Chargeback Hold';
    }
    value(30; "Chargeback Hold Release")
    {
        Caption = 'Chargeback Hold Release';
    }
    value(31; "Chargeback Protection Credit")
    {
        Caption = 'Chargeback Protection Credit';
    }
    value(32; "Chargeback Protection Credit Reversal")
    {
        Caption = 'Chargeback Protection Credit Reversal';
    }
    value(33; "Chargeback Protection Debit")
    {
        Caption = 'Chargeback Protection Debit';
    }
    value(34; "Chargeback Protection Debit Reversal")
    {
        Caption = 'Chargeback Protection Debit Reversal';
    }
    value(35; "Charge Adjustment")
    {
        Caption = 'Charge Adjustment';
    }
    value(36; "Collections Credit")
    {
        Caption = 'Collections Credit';
    }
    value(37; "Collections Credit Reversal")
    {
        Caption = 'Collections Credit Reversal';
    }
    value(38; "Customs Duty")
    {
        Caption = 'Customs Duty';
    }
    value(39; "Customs Duty Adjustment")
    {
        Caption = 'Customs Duty Adjustment';
    }
    value(40; "Dispute Reversal")
    {
        Caption = 'Dispute Reversal';
    }
    value(41; "Dispute Withdrawal")
    {
        Caption = 'Dispute Withdrawal';
    }
    value(42; "Import Tax")
    {
        Caption = 'Import Tax';
    }
    value(43; "Import Tax Adjustment")
    {
        Caption = 'Import Tax Adjustment';
    }
    value(44; "Marketplace Fee Credit")
    {
        Caption = 'Marketplace Fee Credit';
    }
    value(45; "Marketplace Fee Credit Reversal")
    {
        Caption = 'Marketplace Fee Credit Reversal';
    }
    value(46; "Markets Pro Credit")
    {
        Caption = 'Markets Pro Credit';
    }
    value(47; "Merchant Goodwill Credit")
    {
        Caption = 'Merchant Goodwill Credit';
    }
    value(48; "Merchant Goodwill Credit Reversal")
    {
        Caption = 'Merchant Goodwill Credit Reversal';
    }
    value(49; "Merchant To Merchant Credit")
    {
        Caption = 'Merchant To Merchant Credit';
    }
    value(50; "Merchant To Merchant Credit Reversal")
    {
        Caption = 'Merchant To Merchant Credit Reversal';
    }
    value(51; "Merchant To Merchant Debit")
    {
        Caption = 'Merchant To Merchant Debit';
    }
    value(52; "Merchant To Merchant Debit Reversal")
    {
        Caption = 'Merchant To Merchant Debit Reversal';
    }
    value(53; "Promotion Credit")
    {
        Caption = 'Promotion Credit';
    }
    value(54; "Promotion Credit Reversal")
    {
        Caption = 'Promotion Credit Reversal';
    }
    value(55; "Refund Adjustment")
    {
        Caption = 'Refund Adjustment';
    }
    value(56; "Refund Failure")
    {
        Caption = 'Refund Failure';
    }
    value(57; "Reserved Funds")
    {
        Caption = 'Reserved Funds';
    }
    value(58; "Reserved Funds Reversal")
    {
        Caption = 'Reserved Funds Reversal';
    }
    value(59; "Reserved Funds Withdrawal")
    {
        Caption = 'Reserved Funds Withdrawal';
    }
    value(60; "Risk Reversal")
    {
        Caption = 'Risk Reversal';
    }
    value(61; "Risk Withdrawal")
    {
        Caption = 'Risk Withdrawal';
    }
    value(62; "Seller Protection Credit")
    {
        Caption = 'Seller Protection Credit';
    }
    value(63; "Seller Protection Credit Reversal")
    {
        Caption = 'Seller Protection Credit Reversal';
    }
    value(64; "Shipping Label")
    {
        Caption = 'Shipping Label';
    }
    value(65; "Shipping Label Adjustment")
    {
        Caption = 'Shipping Label Adjustment';
    }
    value(66; "Shipping Label Adjustment Base")
    {
        Caption = 'Shipping Label Adjustment Base';
    }
    value(67; "Shipping Label Adjustment Surcharge")
    {
        Caption = 'Shipping Label Adjustment Surcharge';
    }
    value(68; "Shipping Other Carrier Charge Adjustment")
    {
        Caption = 'Shipping Other Carrier Charge Adjustment';
    }
    value(69; "Shipping Return To Origin Adjustment")
    {
        Caption = 'Shipping Return To Origin Adjustment';
    }
    value(70; "Shopify Collective Credit")
    {
        Caption = 'Shopify Collective Credit';
    }
    value(71; "Shopify Collective Credit Reversal")
    {
        Caption = 'Shopify Collective Credit Reversal';
    }
    value(72; "Shopify Collective Debit")
    {
        Caption = 'Shopify Collective Debit';
    }
    value(73; "Shopify Collective Debit Reversal")
    {
        Caption = 'Shopify Collective Debit Reversal';
    }
    value(74; "Shopify Source Credit")
    {
        Caption = 'Shopify Source Credit';
    }
    value(75; "Shopify Source Credit Reversal")
    {
        Caption = 'Shopify Source Credit Reversal';
    }
    value(76; "Shopify Source Debit")
    {
        Caption = 'Shopify Source Debit';
    }
    value(77; "Shopify Source Debit Reversal")
    {
        Caption = 'Shopify Source Debit Reversal';
    }
    value(78; "Shop Cash Billing Debit")
    {
        Caption = 'Shop Cash Billing Debit';
    }
    value(79; "Shop Cash Billing Debit Reversal")
    {
        Caption = 'Shop Cash Billing Debit Reversal';
    }
    value(80; "Shop Cash Campaign Billing Credit")
    {
        Caption = 'Shop Cash Campaign Billing Credit';
    }
    value(81; "Shop Cash Campaign Billing Credit Reversal")
    {
        Caption = 'Shop Cash Campaign Billing Credit Reversal';
    }
    value(82; "Shop Cash Campaign Billing Debit")
    {
        Caption = 'Shop Cash Campaign Billing Debit';
    }
    value(83; "Shop Cash Campaign Billing Debit Reversal")
    {
        Caption = 'Shop Cash Campaign Billing Debit Reversal';
    }
    value(84; Advance)
    {
        Caption = 'Advance';
    }
    value(85; "Shop Cash Credit Reversal")
    {
        Caption = 'Shop Cash Credit Reversal';
    }
    value(86; "Shop Cash Refund Debit")
    {
        Caption = 'Shop Cash Refund Debit';
    }
    value(87; "Shop Cash Refund Debit Reversal")
    {
        Caption = 'Shop Cash Refund Debit Reversal';
    }
    value(88; "Stripe Fee")
    {
        Caption = 'Stripe Fee';
    }
    value(89; "Tax Adjustment Credit")
    {
        Caption = 'Tax Adjustment Credit';
    }
    value(90; "Tax Adjustment Credit Reversal")
    {
        Caption = 'Tax Adjustment Credit Reversal';
    }
    value(91; "Tax Adjustment Debit")
    {
        Caption = 'Tax Adjustment Debit';
    }
    value(92; "Tax Adjustment Debit Reversal")
    {
        Caption = 'Tax Adjustment Debit Reversal';
    }
    value(93; Transfer)
    {
        Caption = 'Transfer';
    }
    value(94; "Transfer Cancel")
    {
        Caption = 'Transfer Cancel';
    }
    value(95; "Transfer Failure")
    {
        Caption = 'Transfer Failure';
    }
    value(96; "Transfer Refund")
    {
        Caption = 'Transfer Refund';
    }
    value(97; "VAT Refund Credit")
    {
        Caption = 'VAT Refund Credit';
    }
    value(98; "VAT Refund Credit Reversal")
    {
        Caption = 'VAT Refund Credit Reversal';
    }
    value(99; "Advance Funding")
    {
        Caption = 'Advance Funding';
    }
    value(100; "Anomaly Credit")
    {
        Caption = 'Anomaly Credit';
    }
    value(101; "Anomaly Credit Reversal")
    {
        Caption = 'Anomaly Credit Reversal';
    }
}