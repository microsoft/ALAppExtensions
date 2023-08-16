tableextension 4815 "Intrastat Report Sales Head." extends "Sales Header"
{
    fields
    {
        modify("Sell-to Customer No.")
        {
            trigger OnAfterValidate()
            begin
                UpdateIntrastatFields(FieldNo("Sell-to Customer No."));
            end;
        }
        modify("Bill-to Customer No.")
        {
            trigger OnAfterValidate()
            begin
                UpdateIntrastatFields(FieldNo("Bill-to Customer No."));
            end;
        }
    }

    local procedure UpdateIntrastatFields(FieldNo: Integer)
    var
        Customer: Record Customer;
        IntrastatReportSetup: Record "Intrastat Report Setup";
        CustomerNo: Code[20];
        IsHandled: Boolean;
    begin
        OnBeforeUpdateIntrastatFields(Rec, FieldNo, IsHandled);
        if IsHandled then
            exit;

        if Rec.IsTemporary() then
            exit;

        if not IntrastatReportSetup.Get() then
            exit;

        if (FieldNo = FieldNo("Sell-to Customer No.")) and
           (IntrastatReportSetup."VAT No. Based On" = IntrastatReportSetup."VAT No. Based On"::"Sell-to VAT")
        then
            CustomerNo := "Sell-to Customer No.";

        if (FieldNo = FieldNo("Bill-to Customer No.")) and
           (IntrastatReportSetup."VAT No. Based On" = IntrastatReportSetup."VAT No. Based On"::"Bill-to VAT")
        then
            CustomerNo := "Bill-to Customer No.";

        if CustomerNo = '' then
            exit;

        if Customer.Get(CustomerNo) then begin
            Validate("Transport Method", Customer."Def. Transport Method");

            if "Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"] then
                if Customer."Default Trans. Type - Return" <> '' then
                    Validate("Transaction Type", Customer."Default Trans. Type - Return")
                else
                    Validate("Transaction Type", IntrastatReportSetup."Default Trans. - Return");

            if "Document Type" in ["Document Type"::Invoice, "Document Type"::Order] then
                if Customer."Default Trans. Type" <> '' then
                    Validate("Transaction Type", Customer."Default Trans. Type")
                else
                    Validate("Transaction Type", IntrastatReportSetup."Default Trans. - Purchase");
        end else begin
            Validate("Transport Method", '');
            Validate("Transaction Type", '');
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateIntrastatFields(var SalesHeader: Record "Sales Header"; FieldNo: Integer; var IsHandled: Boolean);
    begin
    end;
}