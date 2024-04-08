namespace Microsoft.Integration.Shopify;
enum 30154 "Shpfy Dispute Status"
{
    /// <summary>
    /// Enum Shpfy Dispute Status (ID 30150).
    /// </summary>

    Caption = 'Shopify Dispute Status';

    value(0; Unknown)
    {
        Caption = ' ';
    }
    /// <summary>
    /// The dispute has been open and needs an evidence submission.
    /// </summary>
    value(1; "Needs Response")
    {
        Caption = 'Needs Response';
    }
    /// <summary>
    /// The evidence has been submitted and is being reviewed by the cardholder's bank.
    /// </summary>
    value(2; "Under Review")
    {
        Caption = 'Under Review';
    }
    /// <summary>
    /// The merchant refunded the inquiry amount.
    /// </summary>
    value(3; "Charge Refunded")
    {
        Caption = 'Charge Refunded';
    }
    /// <summary>
    /// The merchant has accepted the dispute as being valid.
    /// </summary>
    value(4; "Accepted")
    {
        Caption = 'Accepted';
    }
    /// <summary>
    /// The cardholder's bank reached a final decision in the merchant's favor.
    /// </summary>
    value(5; "Won")
    {
        Caption = 'Won';
    }
    /// <summary>
    /// The cardholder's bank reached a final decision in the buyer's favor.
    /// </summary>
    value(6; "Lost")
    {
        Caption = 'Lost';
    }
}