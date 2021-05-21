tableextension 11739 "VAT Statement Line CZL" extends "VAT Statement Line"
{
    fields
    {
        field(11780; "Attribute Code CZL"; Code[20])
        {
            Caption = 'Attribute Code';
            TableRelation = "VAT Attribute Code CZL".Code where("VAT Statement Template Name" = field("Statement Template Name"));
            DataClassification = CustomerContent;
        }
        field(11781; "G/L Amount Type CZL"; Option)
        {
            Caption = 'G/L Amount Type';
            OptionCaption = 'Net Change,Debit,Credit';
            OptionMembers = "Net Change",Debit,Credit;
            DataClassification = CustomerContent;
        }
        field(11782; "Gen. Bus. Posting Group CZL"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
            DataClassification = CustomerContent;
        }
        field(11783; "Gen. Prod. Posting Group CZL"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
            DataClassification = CustomerContent;
        }
        field(11784; "Show CZL"; Option)
        {
            Caption = 'Show';
            OptionCaption = ' ,Zero If Negative,Zero If Positive';
            OptionMembers = " ","Zero If Negative","Zero If Positive";
            DataClassification = CustomerContent;
        }
        field(31072; "EU 3-Party Intermed. Role CZL"; Option)
        {
            Caption = 'EU 3-Party Intermediate Role';
            OptionCaption = ' ,Yes,No';
            OptionMembers = " ",Yes,No;
            DataClassification = CustomerContent;
        }
        field(31073; "EU-3 Party Trade CZL"; Option)
        {
            Caption = 'EU-3 Party Trade';
            OptionCaption = ' ,Yes,No';
            OptionMembers = " ",Yes,No;
            DataClassification = CustomerContent;
        }
        field(31110; "VAT Ctrl. Report Section CZL"; Code[20])
        {
            Caption = 'VAT Control Report Section Code';
            TableRelation = "VAT Ctrl. Report Section CZL";
            DataClassification = CustomerContent;
        }
        field(31111; "Ignore Simpl. Doc. Limit CZL"; Boolean)
        {
            Caption = 'Ignore Simplified Tax Document Limit';
            DataClassification = CustomerContent;
        }
    }
}
