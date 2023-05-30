tableextension 4816 "Intrastat Report Serv. Head." extends "Service Header"
{
    fields
    {
        modify("Customer No.")
        {
            trigger OnAfterValidate()
            begin
                if Rec.IsTemporary() then
                    exit;

                if IntrastatReportSetup.Get() and (IntrastatReportSetup."VAT No. Based On" = IntrastatReportSetup."VAT No. Based On"::"Sell-to VAT") then
                    UpdateIntrastatFields("Customer No.");
            end;
        }
        modify("Bill-to Customer No.")
        {
            trigger OnAfterValidate()
            begin
                if Rec.IsTemporary() then
                    exit;

                if IntrastatReportSetup.Get() and (IntrastatReportSetup."VAT No. Based On" = IntrastatReportSetup."VAT No. Based On"::"Bill-to VAT") then
                    UpdateIntrastatFields("Bill-to Customer No.");
            end;
        }
    }

    var
        IntrastatReportSetup: Record "Intrastat Report Setup";

    local procedure UpdateIntrastatFields(CustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        if Customer.Get(CustomerNo) then begin
            Validate("Transport Method", Customer."Def. Transport Method");

            if "Document Type" = "Document Type"::"Credit Memo" then
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
}