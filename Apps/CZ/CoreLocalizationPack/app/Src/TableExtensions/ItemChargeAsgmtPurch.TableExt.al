tableextension 31019 "Item Charge Asgmt. (Purch) CZL" extends "Item Charge Assignment (Purch)"
{
    fields
    {
        field(31052; "Incl. in Intrastat Amount CZL"; Boolean)
        {
            Caption = 'Incl. in Intrastat Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                StatutoryReportingSetupCZL.CheckItemChargesInIntrastatCZL();
            end;
        }
        field(31053; "Incl. in Intrastat S.Value CZL"; Boolean)
        {
            Caption = 'Incl. in Intrastat Stat. Value';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                StatutoryReportingSetupCZL.CheckItemChargesInIntrastatCZL();
            end;
        }
    }

    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";

    procedure SetIncludeAmountCZL(): Boolean
    var
        PurchaseHeader: Record "Purchase Header";
        VendorNo: Code[20];
    begin
        if PurchaseHeader.Get("Document Type", "Document No.") then begin
            VendorNo := GetVendor();
            if (VendorNo <> '') then
                exit(PurchaseHeader."Buy-from Vendor No." = VendorNo);
        end;
    end;

    local procedure GetVendor(): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        ReturnShipmentHeader: Record "Return Shipment Header";
        VendorNo: Code[20];
    begin
        case "Applies-to Doc. Type" of
            "Applies-to Doc. Type"::Order, "Applies-to Doc. Type"::Invoice,
            "Applies-to Doc. Type"::"Return Order", "Applies-to Doc. Type"::"Credit Memo":
                begin
                    PurchaseHeader.Get("Applies-to Doc. Type", "Applies-to Doc. No.");
                    VendorNo := PurchaseHeader."Buy-from Vendor No.";
                end;
            "Applies-to Doc. Type"::Receipt:
                begin
                    PurchRcptHeader.Get("Applies-to Doc. No.");
                    VendorNo := PurchRcptHeader."Buy-from Vendor No.";
                end;
            "Applies-to Doc. Type"::"Return Shipment":
                begin
                    ReturnShipmentHeader.Get("Applies-to Doc. No.");
                    VendorNo := ReturnShipmentHeader."Buy-from Vendor No.";
                end;
            "Applies-to Doc. Type"::"Transfer Receipt":
                VendorNo := '';
            "Applies-to Doc. Type"::"Sales Shipment":
                VendorNo := '';
            "Applies-to Doc. Type"::"Return Receipt":
                VendorNo := '';
        end;

        exit(VendorNo);
    end;
}