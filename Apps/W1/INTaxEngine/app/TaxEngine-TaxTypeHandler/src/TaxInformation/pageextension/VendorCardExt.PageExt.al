pageextension 20262 "Vendor Card Ext" extends "Vendor Card"
{
    layout
    {
        addafter(VendorHistBuyFromFactBox)
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
        if RecordId() = EmptyRecordID then
            ShowTaxAttributes := false
        else begin
            AttributeManagement.UpdateTaxAttributeFactbox(Rec);
            ShowTaxAttributes := CurrPage.TaxAttributes.Page.SetRecordFilter(RecordId());
        end;
    end;

    trigger OnOpenPage()
    var
        AttributeManagement: Codeunit "Tax Attribute Management";
    begin
        AttributeManagement.UpdateTaxAttributeFactbox(Rec);
    end;

    var
        EmptyRecordID: RecordId;
        ShowTaxAttributes: Boolean;
}