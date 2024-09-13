namespace Microsoft.SubscriptionBilling;

page 8023 "Vendor Contracts API"
{
    APIGroup = 'subsBilling';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    EntityName = 'vendorContract';
    EntitySetName = 'vendorContracts';
    PageType = API;
    SourceTable = "Vendor Contract";
    ODataKeyFields = SystemId;
    Extensible = false;
    Editable = false;
    DataAccessIntent = ReadOnly;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(systemId; Rec.SystemId)
                {
                }
                field(buyFromVendorNo; Rec."Buy-from Vendor No.")
                {
                }
                field(no; Rec."No.")
                {
                }
                field(payToVendorNo; Rec."Pay-to Vendor No.")
                {
                }
                field(payToName; Rec."Pay-to Name")
                {
                }
                field(payToName2; Rec."Pay-to Name 2")
                {
                }
                field(payToAddress; Rec."Pay-to Address")
                {
                }
                field(payToAddress2; Rec."Pay-to Address 2")
                {
                }
                field(payToCity; Rec."Pay-to City")
                {
                }
                field(payToContact; Rec."Pay-to Contact")
                {
                }
                field(yourReference; Rec."Your Reference")
                {
                }
                field(paymentTermsCode; Rec."Payment Terms Code")
                {
                }
                field(shortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
                {
                }
                field(shortcutDimension2Code; Rec."Shortcut Dimension 2 Code")
                {
                }
                field(currencyCode; Rec."Currency Code")
                {
                }
                field(purchaserCode; Rec."Purchaser Code")
                {
                }
                field(buyFromVendorName; Rec."Buy-from Vendor Name")
                {
                }
                field(buyFromVendorName2; Rec."Buy-from Vendor Name 2")
                {
                }
                field(buyFromAddress; Rec."Buy-from Address")
                {
                }
                field(buyFromAddress2; Rec."Buy-from Address 2")
                {
                }
                field(buyFromCity; Rec."Buy-from City")
                {
                }
                field(buyFromContact; Rec."Buy-from Contact")
                {
                }
                field(payToPostCode; Rec."Pay-to Post Code")
                {
                }
                field(payToCounty; Rec."Pay-to County")
                {
                }
                field(payToCountryRegionCode; Rec."Pay-to Country/Region Code")
                {
                }
                field(buyFromPostCode; Rec."Buy-from Post Code")
                {
                }
                field(buyFromCounty; Rec."Buy-from County")
                {
                }
                field(buyFromCountryRegionCode; Rec."Buy-from Country/Region Code")
                {
                }
                field(paymentMethodCode; Rec."Payment Method Code")
                {
                }
                field(noSeries; Rec."No. Series")
                {
                }
                field(description; Rec.Description)
                {
                }
                field(descriptionPreview; Rec."Description Preview")
                {
                }
                field(dimensionSetID; Rec."Dimension Set ID")
                {
                }
                field(buyFromContactNo; Rec."Buy-from Contact No.")
                {
                }
                field(payToContactNo; Rec."Pay-to Contact No.")
                {
                }
                field(assignedUserID; Rec."Assigned User ID")
                {
                }
                field(active; Rec.Active)
                {
                }
                field(contractType; Rec."Contract Type")
                {
                }
                field(withoutContractDeferrals; Rec."Without Contract Deferrals")
                {
                }
                field(billingRhythmFilter; Rec."Billing Rhythm Filter")
                {
                }
                part(vendorContractLinesAPI; "Vendor Contract Lines API")
                {
                    Caption = 'vendorContractLines', Locked = true;
                    EntityName = 'vendorContractLines';
                    EntitySetName = 'vendorContractLines';
                    SubPageLink = "Contract No." = field("No.");
                }
            }
        }
    }
}
