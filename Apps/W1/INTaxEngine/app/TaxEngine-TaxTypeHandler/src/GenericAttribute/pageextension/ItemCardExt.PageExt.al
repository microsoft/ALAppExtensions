pageextension 20233 "Item Card Ext" extends "Item Card"
{
    Caption = '';
    layout
    {

        addafter(ItemAttributesFactbox)
        {
            part(TaxAttributes; "Entity Value Factbox")
            {
                Visible = ShowTaxAttributes;
                Caption = 'Tax Attributes';
                ApplicationArea = Basic, Suite;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        AttributeManagement: Codeunit "Tax Attribute Management";
    begin
        AttributeManagement.UpdateTaxAttributeFactbox(Rec);
        ShowTaxAttributes := CurrPage.TaxAttributes.Page.SetRecordFilter(RecordId());
    end;

    trigger OnOpenPage()
    var
        AttributeManagement: Codeunit "Tax Attribute Management";
    begin
        AttributeManagement.UpdateTaxAttributeFactbox(Rec);
    end;

    var
        ShowTaxAttributes: Boolean;
}