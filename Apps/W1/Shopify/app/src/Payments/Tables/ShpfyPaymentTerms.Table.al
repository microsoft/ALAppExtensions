namespace Microsoft.Integration.Shopify;

using Microsoft.Foundation.PaymentTerms;

/// <summary>
/// Table Shpfy Payment Terms (ID 30158).
/// </summary>
table 30158 "Shpfy Payment Terms"
{
    Caption = 'Payment Terms';
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            TableRelation = "Shpfy Shop";
            Editable = false;
        }
        field(2; Id; BigInteger)
        {
            Caption = 'ID';
            Editable = false;
        }
        field(20; Name; Text[50])
        {
            Caption = 'Name';
            Editable = false;
        }
        field(30; "Due In Days"; Integer)
        {
            Caption = 'Due In Days';
            Editable = false;
        }
        field(40; Description; Text[50])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(50; Type; Code[20])
        {
            Caption = 'Type';
            Editable = false;
        }
        field(60; "Is Primary"; Boolean)
        {
            Caption = 'Is Primary';

            trigger OnValidate()
            var
                ShpfyPaymentTerms: Record "Shpfy Payment Terms";
                PrimaryPaymentTermsExistsErr: Label 'Primary payment terms already exist for this shop.';
            begin
                ShpfyPaymentTerms.SetRange("Shop Code", Rec."Shop Code");
                ShpfyPaymentTerms.SetRange("Is Primary", true);
                ShpfyPaymentTerms.SetFilter(Id, '<>%1', Rec.Id);

                if not ShpfyPaymentTerms.IsEmpty() then
                    Error(PrimaryPaymentTermsExistsErr);
            end;
        }
        field(70; "Payment Terms Code"; Code[10])
        {
            TableRelation = "Payment Terms";
            Caption = 'Payment Terms Code';
        }
    }

    keys
    {
        key(PK; "Shop Code", Id)
        {
            Clustered = true;
        }
    }
}