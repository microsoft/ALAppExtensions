pageextension 11743 "Posted Return Shipment CZL" extends "Posted Return Shipment"
{
    layout
    {
#if not CLEAN20
#pragma warning disable AL0432
        movelast(General; "Posting Description")
#pragma warning restore AL0432
#else
        addlast(General)
        {
            field("Posting Description CZL"; Rec."Posting Description")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies a description of the document. The posting description also appers on vendor and G/L entries.';
                Visible = false;
            }
        }
#endif
        addafter("Document Date")
        {
            field("Correction CZL"; Rec.Correction)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies if you need to post a corrective entry to an account.';
            }
        }
        addlast(Invoicing)
        {
            field("VAT Bus. Posting Group CZL"; Rec."VAT Bus. Posting Group")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies a VAT business posting group code.';
            }
            field("Vendor Posting Group CZL"; Rec."Vendor Posting Group")
            {
                ApplicationArea = Suite;
                Editable = false;
                ToolTip = 'Specifies the vendor''s market type to link business transactions made for the vendor with the appropriate account in the general ledger.';
            }
            field("VAT Registration No. CZL"; Rec."VAT Registration No.")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the VAT registration number. The field will be used when you do business with partners from EU countries/regions.';
            }
            field("Registration No. CZL"; Rec."Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the registration number of vendor.';
            }
            field("Tax Registration No. CZL"; Rec."Tax Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the secondary VAT registration number for the vendor.';
                Importance = Additional;
            }
        }
        addlast("Foreign Trade")
        {
            field("Language Code CZL"; Rec."Language Code")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the language to be used on printouts for this document.';
            }
            field("VAT Country/Region Code CZL"; Rec."VAT Country/Region Code")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the VAT country/region code of vendor';
            }
            field("Transaction Type CZL"; Rec."Transaction Type")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the transaction type for the customer record. This information is used for Intrastat reporting.';
            }
            field("Transaction Specification CZL"; Rec."Transaction Specification")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies a code for the purchase document''s transaction specification, for the purpose of reporting to INTRASTAT.';
            }
            field("Transport Method CZL"; Rec."Transport Method")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the transport method, for the purpose of reporting to INTRASTAT.';
            }
            field("Entry Point CZL"; Rec."Entry Point")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the code of the port of entry where the items pass into your country/region.';
            }
            field("Area CZL"; Rec.Area)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the area code used in the invoice';
            }
            field("EU 3-Party Trade CZL"; Rec."EU 3-Party Trade CZL")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies whether the document is part of a three-party trade.';
            }
            field("Intrastat Exclude CZL"; Rec."Intrastat Exclude CZL")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies that entry will be excluded from intrastat.';
            }
        }
    }
}
