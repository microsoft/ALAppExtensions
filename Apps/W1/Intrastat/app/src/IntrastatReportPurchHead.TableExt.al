tableextension 4817 "Intrastat Report Purch. Head." extends "Purchase Header"
{
    fields
    {
        modify("Buy-from Vendor No.")
        {
            trigger OnAfterValidate()
            begin
                if Rec.IsTemporary() then
                    exit;

                if IntrastatReportSetup.Get() and (IntrastatReportSetup."VAT No. Based On" = IntrastatReportSetup."VAT No. Based On"::"Sell-to VAT") then
                    UpdateIntrastatFields("Buy-from Vendor No.");
            end;
        }
        modify("Pay-to Vendor No.")
        {
            trigger OnAfterValidate()
            begin
                if Rec.IsTemporary() then
                    exit;

                if IntrastatReportSetup.Get() and (IntrastatReportSetup."VAT No. Based On" = IntrastatReportSetup."VAT No. Based On"::"Bill-to VAT") then
                    UpdateIntrastatFields("Pay-to Vendor No.");
            end;
        }
    }

    var
        IntrastatReportSetup: Record "Intrastat Report Setup";

    local procedure UpdateIntrastatFields(VendorNo: Code[20])
    var
        Vendor: Record Vendor;
    begin
        if Vendor.Get(VendorNo) then begin
            Validate("Transport Method", Vendor."Def. Transport Method");

            if "Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"] then
                if Vendor."Default Trans. Type - Return" <> '' then
                    Validate("Transaction Type", Vendor."Default Trans. Type - Return")
                else
                    Validate("Transaction Type", IntrastatReportSetup."Default Trans. - Return");

            if "Document Type" in ["Document Type"::Invoice, "Document Type"::Order] then
                if Vendor."Default Trans. Type" <> '' then
                    Validate("Transaction Type", Vendor."Default Trans. Type")
                else
                    Validate("Transaction Type", IntrastatReportSetup."Default Trans. - Purchase");
        end else begin
            Validate("Transport Method", Vendor."Def. Transport Method");
            Validate("Transaction Type", Vendor."Default Trans. Type");
        end;
    end;
}